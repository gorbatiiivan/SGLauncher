unit AutoUpdater;

interface

type
  TksUpdateAvailableEvent = reference to procedure(Sender: TObject; AETag, AVersion: string);
  TksCheckDoneEvent = reference to function(AFound: Boolean): Boolean;

  IksAutoUpdater = interface
    function GetETag: string;
    function GetUpdateUrl: string;
    procedure SetUpdateUrl(const Value: string);
    function CheckForUpdate: Boolean;
    function UpdateAvailable: Boolean;
    procedure DoUpdate(const AReplaceRunningExe: Boolean = False; const AParams: string = '');
    procedure CheckAndUpdate(const AParams: string = '/wait'; AOnDone: TksCheckDoneEvent = nil);
    property UpdateURL: string read GetUpdateUrl write SetUpdateUrl;
    property ETag: string read GetETag;
  end;

  function CreateAutoUpdater(AUrl,
                             ACurrentETag: string;
                             ACurrentReleaseDate: string;
                             AIntervalSeconds: integer;
                             AUpdateAvailableEvent: TksUpdateAvailableEvent): IksAutoUpdater;

  procedure CheckUpdater(ADestroy: Boolean;
    const AUpdateUrl, ACurrentReleaseDate: string;
    const AParams: string = '/wait');

  procedure CleanupOldExeNow;

implementation

uses Windows, Messages, Forms, System.Net.HttpClient, System.Net.URLClient,
  System.JSON, ExtCtrls, Classes, SysUtils, System.IOUtils, ShellAPi, Vcl.ComCtrls,
  IniFiles, DateUtils, System.Zip, Vcl.Dialogs, Vcl.Controls, SyncObjs, Vcl.StdCtrls;

const
  cUpdateReadyMarker      = '.ready';
  cUpdateIncompleteMarker = '.incomplete';
  cOldExeSuffix           = '.old';
  cImgNamesIni            = 'SGLauncherImgNames.ini';

var
  GUpdater: IksAutoUpdater;

type
  TksAutoUpdater = class(TInterfacedObject, IksAutoUpdater)
  private
    FTimer: TTimer;
    FUpdateUrl: string;
    FIntervalSeconds: integer;
    FNewFile: string;
    FExtractDir: string;
    FUpdateAvailable: Boolean;
    FETag: string;
    FETagLock: TCriticalSection;
    FCurrentReleaseDate: string;
    FUpdateAvailableEvent: TksUpdateAvailableEvent;
    FProgressForm: TForm;
    FProgLabel: TLabel;
    FProgBar: TProgressBar;
    FShowProgress: Boolean;
    FLastPercent: Integer;
    function GetETag: string;
    procedure CreateTimer;
    function GetUpdateUrl: string;
    procedure SetUpdateUrl(const Value: string);
    procedure OnTimer(Sender: TObject);
    procedure ShowProgressUI(const APhase: string; APercent: Integer);
    procedure ReportProgress(const APhase: string; APercent: Integer);
    procedure CloseProgress;
    procedure HttpReceiveData(const Sender: TObject; AContentLength: Int64;
      AReadCount: Int64; var AAbort: Boolean);
    function CheckForUpdateAvailable: Boolean;
  public
    constructor Create(AUpdateUrl: string;
                       ACheckIntervalSeconds: integer;
                       AETag: string;
                       ACurrentReleaseDate: string;
                       AOnUpdateAvailable: TksUpdateAvailableEvent); virtual;
    destructor Destroy; override;
    function UpdateAvailable: Boolean;
    function CheckForUpdate: Boolean;
    procedure DoUpdate(const AReplaceRunningExe: Boolean = False; const AParams: string = '');
    procedure CheckAndUpdate(const AParams: string = '/wait'; AOnDone: TksCheckDoneEvent = nil);
    property UpdateUrl: string read GetUpdateUrl write SetUpdateUrl;
    property ETag: string read GetETag;
    function FindCachedUpdate: Boolean;
  end;

// ------------------------------------------------------------------------
// Парсит 'DD.MM.YYYY', 'YYYY-MM-DD' или 'YYYY/MM/DD'.
// ------------------------------------------------------------------------
function ParseReleaseDate(const S: string): TDateTime;
var
  Parts: TArray<string>;
  Y, M, D: Word;
begin
  Parts := S.Trim.Split(['.', '-', '/']);
  if Length(Parts) < 3 then
    raise Exception.Create('Invalid date: ' + S);

  if Length(Parts[0]) = 4 then
  begin
    Y := StrToInt(Parts[0]);
    M := StrToInt(Parts[1]);
    D := StrToInt(Parts[2]);
  end
  else
  begin
    D := StrToInt(Parts[0]);
    M := StrToInt(Parts[1]);
    Y := StrToInt(Parts[2]);
  end;

  if (Y < 2000) or (M < 1) or (M > 12) or (D < 1) or (D > 31) then
    raise Exception.Create('Invalid date: ' + S);

  Result := EncodeDate(Y, M, D);
end;

// ------------------------------------------------------------------------
// Ищет в строке подстроку, похожую на дату.
// ------------------------------------------------------------------------
function ExtractDateFromString(const S: string): string;
var
  I, J: Integer;
  Candidate: string;
begin
  Result := '';
  I := 1;
  while I <= Length(S) do
  begin
    if CharInSet(S[I], ['0'..'9']) then
    begin
      Candidate := '';
      J := I;
      while (J <= Length(S)) and CharInSet(S[J], ['0'..'9', '.', '-', '/']) do
      begin
        Candidate := Candidate + S[J];
        Inc(J);
      end;
      try
        ParseReleaseDate(Candidate);
        Result := Candidate;
        Exit;
      except
      end;
      I := J;
    end
    else
      Inc(I);
  end;
end;

// ------------------------------------------------------------------------
// Извлекает owner/repo из github-URL
// ------------------------------------------------------------------------
function ParseGitHubUrl(const AUrl: string; out AOwner, ARepo: string): Boolean;
var
  P: Integer;
  S: string;
begin
  Result := False;
  AOwner := '';
  ARepo := '';

  S := AUrl;
  P := Pos('github.com/', S);
  if P = 0 then Exit;
  S := Copy(S, P + Length('github.com/'), MaxInt);

  P := Pos('/', S);
  if P = 0 then Exit;
  AOwner := Copy(S, 1, P - 1);
  S := Copy(S, P + 1, MaxInt);

  P := Pos('/', S);
  if P > 0 then
    ARepo := Copy(S, 1, P - 1)
  else
    ARepo := S;

  Result := (AOwner <> '') and (ARepo <> '');
end;

// ------------------------------------------------------------------------
// Приводит строку к допустимому имени папки (fallback-путь;
// в норме используется ISO-дата).
// ------------------------------------------------------------------------
function SanitizeFolderName(const S: string): string;
var
  I: Integer;
  C: Char;
begin
  Result := S.Trim;
  if Result = '' then
  begin
    Result := 'Update';
    Exit;
  end;

  for I := 1 to Length(Result) do
  begin
    C := Result[I];
    if CharInSet(C, ['\', '/', ':', '*', '?', '"', '<', '>', '|']) or
       (Ord(C) < 32) then
      Result[I] := '_';
  end;

  while (Result <> '') and CharInSet(Result[Length(Result)], ['.', ' ']) do
    Delete(Result, Length(Result), 1);

  if Length(Result) > 100 then
    Result := Copy(Result, 1, 100);

  if Result = '' then
    Result := 'Update';
end;
// ------------------------------------------------------------------------
// Проверяет, что путь из ZIP не выходит за пределы целевой папки.
// Отклоняет: пустые, абсолютные, с диском (C:), с сегментом '..'.
// ------------------------------------------------------------------------
function IsSafeZipEntry(const AEntryName: string): Boolean;
var
  Parts: TArray<string>;
  I: Integer;
  S: string;
begin
  Result := False;
  S := AEntryName.Trim;
  if S = '' then Exit;
  if S[1] = PathDelim then Exit;                          // \server\share
  if (Length(S) >= 2) and (S[2] = ':') then Exit;         // C:\...

  Parts := S.Split([PathDelim]);
  for I := 0 to High(Parts) do
    if Parts[I] = '..' then Exit;                          // только сегмент '..'

  Result := True;
end;
// ------------------------------------------------------------------------
// Дата последнего релиза с GitHub.
// Полностью защищён от сетевых/JSON-исключений.
// ------------------------------------------------------------------------
function GetGitHubReleaseInfo(const AOwner, ARepo: string;
  out AReleaseName, AReleaseDate: string): Boolean;
var
  Http: THTTPClient;
  Resp: IHTTPResponse;
  Json: TJSONObject;
  V, Url: string;
begin
  Result := False;
  AReleaseName := '';
  AReleaseDate := '';

  Url := Format('https://api.github.com/repos/%s/%s/releases/latest',
                [AOwner, ARepo]);

  try
    Http := THTTPClient.Create;
    try
      try Http.UserAgent := 'ksAutoUpdater/1.0'; except end;
      try Http.HandleRedirects := True; except end;

      try
        Resp := Http.Get(Url);
      except
        Exit;
      end;

      if (Resp = nil) or (Resp.StatusCode <> 200) then Exit;

      try
        Json := TJSONObject.ParseJSONValue(
          Resp.ContentAsString(TEncoding.UTF8)) as TJSONObject;
      except
        Exit;
      end;
      if Json = nil then Exit;

      try
        if Json.TryGetValue<string>('name', V) then
        begin
          AReleaseName := V.Trim;
          AReleaseDate := ExtractDateFromString(V);
        end;

        if (AReleaseDate = '') and Json.TryGetValue<string>('tag_name', V) then
        begin
          if AReleaseName = '' then AReleaseName := V.Trim;
          AReleaseDate := ExtractDateFromString(V);
        end;

        if (AReleaseDate = '') and Json.TryGetValue<string>('published_at', V) then
          AReleaseDate := ExtractDateFromString(V);

        Result := AReleaseDate <> '';
      finally
        Json.Free;
      end;
    finally
      Http.Free;
    end;
  except
    Result := False;
  end;
end;

// ------------------------------------------------------------------------
// Поиск .exe в папке (рекурсивно)
// ------------------------------------------------------------------------
function FindExeInDirectory(const ADir: string): string;
var
  SearchRec: TSearchRec;
begin
  Result := '';

  if FindFirst(TPath.Combine(ADir, '*.exe'), faAnyFile, SearchRec) = 0 then
  begin
    try
      repeat
        if (SearchRec.Attr and faDirectory) = 0 then
        begin
          Result := TPath.Combine(ADir, SearchRec.Name);
          Break;
        end;
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
    end;
  end;

  if Result <> '' then Exit;

  if FindFirst(TPath.Combine(ADir, '*'), faDirectory, SearchRec) = 0 then
  try
    repeat
      if ((SearchRec.Attr and faDirectory) <> 0) and
         (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
      begin
        Result := FindExeInDirectory(TPath.Combine(ADir, SearchRec.Name));
        if Result <> '' then Break;
      end;
    until FindNext(SearchRec) <> 0;
  finally
    FindClose(SearchRec);
  end;
end;

function FindFileInDirectory(const ADir, AFileName: string): string;
begin
  Result := '';
  for var F in TDirectory.GetFiles(ADir, '*', TSearchOption.soAllDirectories) do
    if SameText(ExtractFileName(F), AFileName) then
      Exit(F);
end;

// ------------------------------------------------------------------------
// Чистит:
//  - брошенные *.zip в %TEMP% (старше суток);
//  - папки апдейтов в каталоге приложения, в которых есть exe,
//    но нет .ready — либо распаковка не завершилась, либо старая схема.
// Не трогает пользовательские копии («11.11.2026 — копия»).
// ------------------------------------------------------------------------
procedure CleanupOrphanedUpdates;
var
  SearchRec: TSearchRec;
  FilePath, TempDir, BaseDir: string;
  FolderDate: TDateTime;
  DateStr: string;
  HasReady, HasIncomplete, NameIsExactDate: Boolean;
begin
  TempDir := TPath.GetTempPath;

  if FindFirst(TPath.Combine(TempDir, 'SGUpdate_*.zip'), faAnyFile, SearchRec) = 0 then
  try
    repeat
      if (SearchRec.Attr and faDirectory) <> 0 then Continue;
      if (Now - FileDateToDateTime(SearchRec.Time)) < 1 then Continue;
      FilePath := TPath.Combine(TempDir, SearchRec.Name);
      try DeleteFile(FilePath); except end;
    until FindNext(SearchRec) <> 0;
  finally
    FindClose(SearchRec);
  end;

  BaseDir := ExtractFilePath(ParamStr(0));
  if FindFirst(TPath.Combine(BaseDir, '*'), faDirectory, SearchRec) = 0 then
  try
    repeat
      if ((SearchRec.Attr and faDirectory) = 0) or
         (SearchRec.Name = '.') or (SearchRec.Name = '..') then
        Continue;

      DateStr := ExtractDateFromString(SearchRec.Name);
      if DateStr = '' then Continue;
      try
        FolderDate := ParseReleaseDate(DateStr);
      except
        Continue;
      end;

      FilePath := TPath.Combine(BaseDir, SearchRec.Name);
      HasReady        := FileExists(TPath.Combine(FilePath, cUpdateReadyMarker));
      HasIncomplete   := FileExists(TPath.Combine(FilePath, cUpdateIncompleteMarker));
      NameIsExactDate := SameText(Trim(SearchRec.Name), DateStr);

      if (not HasReady) and (HasIncomplete or NameIsExactDate) then
      begin
        if FindExeInDirectory(FilePath) <> '' then
          try TDirectory.Delete(FilePath, True); except end;
      end;
    until FindNext(SearchRec) <> 0;
  finally
    FindClose(SearchRec);
  end;
end;

// ------------------------------------------------------------------------
// Фабрика
// ------------------------------------------------------------------------
function CreateAutoUpdater(AUrl,
                             ACurrentETag: string;
                             ACurrentReleaseDate: string;
                             AIntervalSeconds: integer;
                             AUpdateAvailableEvent: TksUpdateAvailableEvent): IksAutoUpdater;
begin
  Result := TksAutoUpdater.Create(AUrl, AIntervalSeconds, ACurrentETag,
    ACurrentReleaseDate, AUpdateAvailableEvent);
end;

{ TksAutoUpdater }

constructor TksAutoUpdater.Create(AUpdateUrl: string;
                                  ACheckIntervalSeconds: integer;
                                  AETag: string;
                                  ACurrentReleaseDate: string;
                                  AOnUpdateAvailable: TksUpdateAvailableEvent);
begin
  FETagLock := TCriticalSection.Create;
  FETag := AETag;
  FUpdateUrl := AUpdateUrl;
  FUpdateAvailable := False;
  FIntervalSeconds := ACheckIntervalSeconds;
  FCurrentReleaseDate := ACurrentReleaseDate;
  FUpdateAvailableEvent := AOnUpdateAvailable;
  FExtractDir := '';
  CreateTimer;
end;

destructor TksAutoUpdater.Destroy;
begin
  CloseProgress;
  FreeAndNil(FTimer);
  FreeAndNil(FETagLock);
  inherited;
end;

// ------------------------------------------------------------------------
// Рекурсивно копирует содержимое ASrcDir в ADstDir, перезаписывая файлы.
// ------------------------------------------------------------------------
procedure CopyUpdateToAppDir(const ASrcDir, ADstDir, AExcludeExePath: string;
  AAskIni: Boolean; const AOnFile: TProc);
var
  SearchRec: TSearchRec;
  SrcPath, DstPath: string;
  Created: Boolean;
begin
  if not TDirectory.Exists(ASrcDir) then Exit;
  if FindFirst(TPath.Combine(ASrcDir, '*'), faAnyFile, SearchRec) <> 0 then
    Exit;
  try
    repeat
      if (SearchRec.Name = '.') or (SearchRec.Name = '..') then Continue;
      if SameText(SearchRec.Name, cUpdateReadyMarker) then Continue;
      if SameText(SearchRec.Name, cUpdateIncompleteMarker) then Continue;

      SrcPath := TPath.Combine(ASrcDir, SearchRec.Name);
      DstPath := TPath.Combine(ADstDir, SearchRec.Name);

      if (SearchRec.Attr and faDirectory) <> 0 then
      begin
        Created := TDirectory.Exists(DstPath);
        if not Created then
          try
            TDirectory.CreateDirectory(DstPath);
            Created := True;
          except
            Created := False;
          end;
        if not Created then
          Continue;
        CopyUpdateToAppDir(SrcPath, DstPath, AExcludeExePath, AAskIni, AOnFile);
        Continue;
      end;

      if SameText(SrcPath, AExcludeExePath) then Continue;

      if AAskIni and SameText(SearchRec.Name, cImgNamesIni) and
         FileExists(DstPath) then
      begin
        if MessageBox(Application.ActiveFormHandle,
             PChar('File ' + cImgNamesIni + ' already exists.' + #13#10 +
                   'Overwrite it?'),
             'Update',
             MB_YESNO or MB_ICONQUESTION or MB_DEFBUTTON2) <> IDYES then
          Continue;
      end;

      try CopyFile(PChar(SrcPath), PChar(DstPath), False); except end;
      if Assigned(AOnFile) then AOnFile();
    until FindNext(SearchRec) <> 0;
  finally
    FindClose(SearchRec);
  end;
end;

// ------------------------------------------------------------------------
// Безопасная замена exe с откатом при любой ошибке.
// ------------------------------------------------------------------------
procedure TksAutoUpdater.DoUpdate(const AReplaceRunningExe: Boolean = False;
  const AParams: string = '');
var
  OldPath, AppDir: string;
  LTotal, LDone, LLast, LPct: Integer;
begin
  if AReplaceRunningExe then
  begin
    if FNewFile = '' then
    begin
      FUpdateAvailable := False;
      Exit;
    end;

    OldPath := ChangeFileExt(ParamStr(0), cOldExeSuffix);
    DeleteFile(OldPath);
    AppDir  := ExtractFilePath(ParamStr(0));

    // 1) Переименовываем запущенный exe
    if not RenameFile(ParamStr(0), OldPath) then
    begin
      FUpdateAvailable := False;
      Exit;
    end;

    // 2) Копируем содержимое из FExtractDir в каталог приложения.
    //    FNewFile исключается — он копируется отдельно.
    try
    LTotal := Length(TDirectory.GetFiles(ExtractFilePath(FNewFile), '*',
    TSearchOption.soAllDirectories));
    LDone := 0;
    LLast := -1;
    ReportProgress('Installing', 0);
    try
      CopyUpdateToAppDir(ExtractFilePath(FNewFile), AppDir, FNewFile, True,
        procedure
        begin
          Inc(LDone);
          if LTotal > 0 then
            LPct := LDone * 100 div LTotal
          else
            LPct := 100;
          if LPct > 100 then LPct := 100;
          if LPct <> LLast then
          begin
            LLast := LPct;
            ReportProgress('Installing', LPct);
          end;
        end);
    except
    end;
    ReportProgress('Installing', 100);
    except
    end;

    // 3) Копируем сам exe
    if not CopyFile(PChar(FNewFile), PChar(ParamStr(0)), False) then
    begin
      RenameFile(OldPath, ParamStr(0));   // откат
      FUpdateAvailable := False;
      Exit;
    end;

    // 4) Запускаем новый инстанс; при неудаче — откат exe
    if ShellExecute(0, nil, PChar(ParamStr(0)), PChar(AParams), nil,
        SW_SHOWNORMAL) <= 32 then
    begin
      DeleteFile(ParamStr(0));            // удаляем новый exe
      RenameFile(OldPath, ParamStr(0));   // возвращаем старый
      FUpdateAvailable := False;
      Exit;
    end;

    // 5) Чистим временную папку
    if FExtractDir <> '' then
    begin
      try TDirectory.Delete(FExtractDir, True); except end;
      FExtractDir := '';
    end;

    FUpdateAvailable := False;
    FNewFile := '';

    // 6) Полное завершение процесса. .old удалит следующий инстанс
    //    в фоне (ScheduleOldExeCleanup).
    Application.Terminate;
  end
  else
  begin
    if FNewFile <> '' then
      ShellExecute(0, nil, PChar(FNewFile), PChar('/SILENT'), nil, SW_SHOWNORMAL);
  end;
end;

procedure TksAutoUpdater.CheckAndUpdate(const AParams: string; AOnDone: TksCheckDoneEvent);
var
  LSelf: IksAutoUpdater;
  LParams: string;
begin
  LSelf  := Self;
  LParams := AParams;
  FShowProgress := True;

  TThread.CreateAnonymousThread(
    procedure
    var
      Cached, Available, Proceed: Boolean;
    begin
      try CleanupOrphanedUpdates; except end;

      // 1. Уже есть скачанный ранее апдейт?
      Cached := FindCachedUpdate;

      // 2. Лёгкая проверка наличия (без скачивания)
      Available := Cached;
      if not Available then
      begin
        try Available := CheckForUpdateAvailable;
        except Available := False; end;
      end;

      FUpdateAvailable := Available;

      if not Available then
      begin
        TThread.Synchronize(nil,
          procedure
          begin
            CloseProgress;
            if Assigned(AOnDone) then AOnDone(False);
            FShowProgress := False;
            LSelf := nil;
          end);
        Exit;
      end;

      // 3. СПРАШИВАЕМ ПОЛЬЗОВАТЕЛЯ ДО СКАЧИВАНИЯ
      Proceed := True;
      TThread.Synchronize(nil,
        procedure
        begin
          CloseProgress;
          if Assigned(AOnDone) then
            Proceed := AOnDone(True);
        end);

      if not Proceed then
      begin
        FShowProgress := False;
        LSelf := nil;
        Exit;
      end;

      // 4. Скачиваем/распаковываем, только если ещё не было кэша
      if not Cached then
      begin
        try Available := CheckForUpdate;
        except Available := False; end;

        if not Available then
        begin
          FUpdateAvailable := False;
          TThread.Synchronize(nil,
            procedure
            begin
              CloseProgress;
              FShowProgress := False;
              LSelf := nil;
            end);
          Exit;
        end;
      end;

      // 5. Устанавливаем
      TThread.Synchronize(nil,
        procedure
        begin
          CloseProgress;
          DoUpdate(True, LParams);
          CloseProgress;
          FShowProgress := False;
          LSelf := nil;
        end);
    end
  ).Start;
end;

function TksAutoUpdater.GetETag: string;
begin
  FETagLock.Enter;
  try
    Result := FETag;
  finally
    FETagLock.Leave;
  end;
end;

function TksAutoUpdater.GetUpdateUrl: string;
begin
  Result := FUpdateUrl;
end;

procedure TksAutoUpdater.SetUpdateUrl(const Value: string);
begin
  FUpdateUrl := Value;
end;

// ------------------------------------------------------------------------
// Скачивание, распаковка, валидация. Все сетевые/IO-ошибки — «нет обновлений».
// ------------------------------------------------------------------------
function TksAutoUpdater.CheckForUpdate: Boolean;
var
  AHttp: THTTPClient;
  AResponse: IHTTPResponse;
  AStream: TMemoryStream;
  AZipFile: TZipFile;
  AZipPath, AExtractDir, AExeFile: string;
  AOwner, ARepo, AGitHubDate, AGitHubName, AFolderName: string;
  ANewDate, ACurrentDate: TDateTime;
  LNewETag: string;
  I: Integer;
  EntryName, TargetPath: string;
  LFileNames: TArray<string>;
  LPct: Integer;
begin
  Result := False;
  AZipPath := '';

  // 1. owner/repo из URL
  if not ParseGitHubUrl(FUpdateUrl, AOwner, ARepo) then Exit;

  // 2. Дата + имя последнего релиза
  try
    if not GetGitHubReleaseInfo(AOwner, ARepo, AGitHubName, AGitHubDate) then Exit;
  except
    Exit;
  end;

  // 3. Сравнение с текущей датой
  try
    ANewDate     := ParseReleaseDate(AGitHubDate);
    ACurrentDate := ParseReleaseDate(FCurrentReleaseDate);
  except
    Exit;
  end;

  if ANewDate <= ACurrentDate then Exit;

  try
    // 4. Скачиваем ZIP
    try
      AHttp := THTTPClient.Create;
      try
        try AHttp.UserAgent := 'ksAutoUpdater/1.0'; except end;
        try AHttp.HandleRedirects := True; except end;
        FLastPercent := -2;
        AHttp.OnReceiveData := HttpReceiveData;
        AStream := TMemoryStream.Create;
        try
          try
            AResponse := AHttp.Get(FUpdateUrl, AStream);
          except
            Exit;
          end;

          if (AResponse = nil) or (AResponse.StatusCode <> 200) then Exit;

          LNewETag := AResponse.HeaderValue['ETag'];
          if LNewETag <> '' then
          begin
            FETagLock.Enter;
            try FETag := LNewETag; finally FETagLock.Leave; end;
          end;

          AZipPath := TPath.Combine(TPath.GetTempPath,
            'SGUpdate_' + FormatDateTime('yyyymmddhhnnsszzz', Now) + '.zip');
          AStream.SaveToFile(AZipPath);
        finally
          AStream.Free;
        end;
      finally
        AHttp.Free;
      end;

      // 5. Имя папки — ISO-дата релиза, чтобы FindCachedUpdate её находил,
      //    CleanupOrphanedUpdates распознавал, и не было проблем с '/' в дате.
      try
        AFolderName := FormatDateTime('dd.mm.yyyy', ParseReleaseDate(AGitHubDate));
      except
        AFolderName := SanitizeFolderName(AGitHubDate);
      end;
      if AFolderName = '' then
        AFolderName := 'SGUpdate';

      AExtractDir := TPath.Combine(ExtractFilePath(ParamStr(0)), AFolderName);

      if TDirectory.Exists(AExtractDir) then
        try TDirectory.Delete(AExtractDir, True); except end;

      TDirectory.CreateDirectory(AExtractDir);
      try
        TFile.WriteAllText(TPath.Combine(AExtractDir, cUpdateIncompleteMarker),
          'extracting');
      except
        try TDirectory.Delete(AExtractDir, True); except end;
        Exit;
      end;

      // 6. Распаковка с защитой от ZIP-Slip
      try
        AZipFile := TZipFile.Create;
        try
          AZipFile.Open(AZipPath, zmRead);
          try
            LFileNames := AZipFile.FileNames;
            FLastPercent := -2;
            for I := 0 to Length(LFileNames) - 1 do
            begin
              EntryName := LFileNames[I];
              EntryName := EntryName.Replace('/', PathDelim).Replace('\', PathDelim);

              if not IsSafeZipEntry(EntryName) then
                Continue;

              TargetPath := TPath.Combine(AExtractDir, EntryName);

              if EntryName.EndsWith(PathDelim) then
                TDirectory.CreateDirectory(TargetPath)
              else
              begin
                // КРИТИЧНО: TZipFile.Extract НЕ создаёт родительские папки.
                TDirectory.CreateDirectory(ExtractFileDir(TargetPath));
                AZipFile.Extract(I, AExtractDir, True);
              end;
              //прогресс распаковки
              LPct := (I + 1) * 100 div Length(LFileNames);
              if LPct <> FLastPercent then
              begin
                FLastPercent := LPct;
                ReportProgress('Extracting', LPct);
              end;
            end;
          finally
            AZipFile.Close;
          end;
        finally
          AZipFile.Free;
        end;
      except
        try TDirectory.Delete(AExtractDir, True); except end;
        Exit;
      end;

      // 7. Пишем .ready (один раз). Только после успешной распаковки
      //    удаляем .incomplete — best-effort.
      try
        TFile.WriteAllText(TPath.Combine(AExtractDir, cUpdateReadyMarker),
          'ok' + sLineBreak + AGitHubName + sLineBreak + AGitHubDate);
      except
        try TDirectory.Delete(AExtractDir, True); except end;
        Exit;
      end;
      try DeleteFile(TPath.Combine(AExtractDir, cUpdateIncompleteMarker)); except end;

      // 8. Поиск .exe
      AExeFile := FindFileInDirectory(AExtractDir, ExtractFileName(ParamStr(0)));
      if AExeFile = '' then
        AExeFile := FindExeInDirectory(AExtractDir);
      if AExeFile = '' then
      begin
        try TDirectory.Delete(AExtractDir, True); except end;
        Exit;
      end;

      // 9. Нулевой exe — битый архив
      if TFile.GetSize(AExeFile) = 0 then
      begin
        try TDirectory.Delete(AExtractDir, True); except end;
        Exit;
      end;

      // 10. Фиксируем результат
      if (FExtractDir <> '') and (FExtractDir <> AExtractDir) then
        try TDirectory.Delete(FExtractDir, True); except end;

      FExtractDir := AExtractDir;
      FNewFile    := AExeFile;
      Result      := True;

      TThread.Queue(nil,
        procedure
        begin
          if Assigned(FUpdateAvailableEvent) then
            FUpdateAvailableEvent(Self, GetETag, AGitHubDate);
        end);
    except
      // сетевые / IO-ошибки не валят приложение
    end;
  finally
    if AZipPath <> '' then
      try DeleteFile(AZipPath); except end;
  end;
end;

// ------------------------------------------------------------------------
// Периодическая проверка.
// ------------------------------------------------------------------------
procedure TksAutoUpdater.OnTimer(Sender: TObject);
begin
  if FUpdateAvailable then Exit;
  if not Assigned(FTimer) then Exit;

  FTimer.Enabled := False;

  TThread.CreateAnonymousThread(
    procedure
    var
      LFound: Boolean;
    begin
      try LFound := CheckForUpdate;
      except LFound := False; end;

      FUpdateAvailable := LFound;

      if not LFound then
        TThread.Synchronize(nil,
          procedure
          begin
            if Assigned(FTimer) and (FIntervalSeconds > 0) then
            begin
              FTimer.Interval := FIntervalSeconds * 1000;
              FTimer.Enabled := True;
            end;
          end);
    end
  ).Start;
end;

procedure TksAutoUpdater.CreateTimer;
begin
  if FIntervalSeconds <= 0 then Exit;

  FTimer := TTimer.Create(nil);
  FTimer.Interval := 3000;        // первая проверка через 3 сек
  FTimer.OnTimer := OnTimer;
  FTimer.Enabled := True;
end;

function TksAutoUpdater.UpdateAvailable: Boolean;
begin
  Result := FUpdateAvailable;
end;

procedure CheckUpdater(ADestroy: Boolean;
  const AUpdateUrl, ACurrentReleaseDate: string;
  const AParams: string = '/wait');
begin
  if ADestroy then
  begin
    GUpdater := nil;
    Exit;
  end;

  if GUpdater = nil then
    GUpdater := CreateAutoUpdater(AUpdateUrl, '', ACurrentReleaseDate, 0, nil);

  GUpdater.CheckAndUpdate(AParams,
    function(AFound: Boolean): Boolean
    begin
      Result := AFound and
        (MessageDlg('A new version is available. Update now?',
           mtConfirmation, [mbYes, mbNo], 0) = mrYes);
    end);
end;

// ------------------------------------------------------------------------
// Поиск ранее скачанного апдейта в каталоге приложения.
// ------------------------------------------------------------------------
function TksAutoUpdater.FindCachedUpdate: Boolean;
var
  BaseDir, ExeName, FolderName, DateStr, ExeFile, TrimmedName: string;
  SearchRec: TSearchRec;
  CandidateDate, CurrentDate, BestDate: TDateTime;
  BestDir, BestExe: string;
  HasReady: Boolean;
begin
  Result   := False;
  BestDate := 0;
  BestDir  := '';
  BestExe  := '';

  try
    CurrentDate := ParseReleaseDate(FCurrentReleaseDate);
  except
    Exit;
  end;

  BaseDir := ExtractFilePath(ParamStr(0));
  ExeName := ExtractFileName(ParamStr(0));

  if FindFirst(TPath.Combine(BaseDir, '*'), faDirectory, SearchRec) = 0 then
  try
    repeat
      if ((SearchRec.Attr and faDirectory) = 0) or
         (SearchRec.Name = '.') or (SearchRec.Name = '..') then
        Continue;

      DateStr := ExtractDateFromString(SearchRec.Name);
      if DateStr = '' then Continue;

      try
        CandidateDate := ParseReleaseDate(DateStr);
      except
        Continue;
      end;

      if CandidateDate <= CurrentDate then Continue;

      // ▼ ГЛАВНОЕ: имя папки должно ТОЧНО совпадать с датой релиза.
      //   "11.11.2026 — копия", "11.11.2026-copy", "backup 11.11.2026"
      //   и т.п. игнорируются.
      TrimmedName := Trim(SearchRec.Name);
      if not SameText(TrimmedName, DateStr) then Continue;

      FolderName := TPath.Combine(BaseDir, SearchRec.Name);

      HasReady := FileExists(TPath.Combine(FolderName, cUpdateReadyMarker));
      if not HasReady then Continue;

      ExeFile := FindFileInDirectory(FolderName, ExeName);
      if ExeFile = '' then
        ExeFile := FindExeInDirectory(FolderName);
      if ExeFile = '' then Continue;

      // тайбрейкер по exact-дате больше не нужен — все папки уже exact
      if CandidateDate > BestDate then
      begin
        BestDate := CandidateDate;
        BestDir  := FolderName;
        BestExe  := ExeFile;
      end;
    until FindNext(SearchRec) <> 0;
  finally
    FindClose(SearchRec);
  end;

  if BestDir <> '' then
  begin
    FExtractDir := BestDir;
    FNewFile    := BestExe;
    Result      := True;
  end;
end;

procedure TksAutoUpdater.ShowProgressUI(const APhase: string; APercent: Integer);
begin
  if FProgressForm = nil then
  begin
    FProgressForm := TForm.CreateNew(nil);
    FProgressForm.BorderStyle := bsDialog;
    FProgressForm.Caption := 'Update';
    FProgressForm.Position := poScreenCenter;
    FProgressForm.FormStyle := fsStayOnTop;
    FProgressForm.ClientWidth := 360;
    FProgressForm.ClientHeight := 70;

    FProgLabel := TLabel.Create(FProgressForm);
    FProgLabel.Parent := FProgressForm;
    FProgLabel.SetBounds(12, 10, 336, 17);

    FProgBar := TProgressBar.Create(FProgressForm);
    FProgBar.Parent := FProgressForm;
    FProgBar.SetBounds(12, 34, 336, 20);
    FProgBar.Max := 100;

    FProgressForm.Show;
  end;

  if APercent < 0 then      // размер неизвестен
  begin
    FProgLabel.Caption := APhase + '...';
    FProgBar.Style := pbstMarquee;
  end
  else
  begin
    FProgBar.Style := pbstNormal;
    FProgLabel.Caption := Format('%s: %d%%', [APhase, APercent]);
    FProgBar.Position := APercent;
  end;
  FProgressForm.Repaint;
end;

// Можно вызывать из любого потока
procedure TksAutoUpdater.ReportProgress(const APhase: string; APercent: Integer);
var
  LPhase: string;
  LPercent: Integer;
begin
  if not FShowProgress then Exit;
  LPhase := APhase;
  LPercent := APercent;
  if TThread.CurrentThread.ThreadID = MainThreadID then
    ShowProgressUI(LPhase, LPercent)
  else
    TThread.Queue(nil,
      procedure
      begin
        ShowProgressUI(LPhase, LPercent);
      end);
end;

procedure TksAutoUpdater.CloseProgress;
begin
  FProgLabel := nil;
  FProgBar := nil;
  FreeAndNil(FProgressForm);
end;

procedure TksAutoUpdater.HttpReceiveData(const Sender: TObject;
  AContentLength: Int64; AReadCount: Int64; var AAbort: Boolean);
var
  P: Integer;
begin
  if AContentLength > 0 then
    P := Integer(AReadCount * 100 div AContentLength)
  else
    P := -1;
  if P = FLastPercent then Exit;     // не засоряем очередь
  FLastPercent := P;
  ReportProgress('Downloading', P);
end;

// ------------------------------------------------------------------------
// Лёгкая проверка: есть ли более новый релиз на GitHub.
// Ничего не скачивает и не пишет на диск.
// ------------------------------------------------------------------------
function TksAutoUpdater.CheckForUpdateAvailable: Boolean;
var
  AOwner, ARepo, AGitHubDate, AGitHubName: string;
  ANewDate, ACurrentDate: TDateTime;
begin
  Result := False;

  if not ParseGitHubUrl(FUpdateUrl, AOwner, ARepo) then Exit;

  try
    if not GetGitHubReleaseInfo(AOwner, ARepo, AGitHubName, AGitHubDate) then Exit;
  except
    Exit;
  end;

  try
    ANewDate     := ParseReleaseDate(AGitHubDate);
    ACurrentDate := ParseReleaseDate(FCurrentReleaseDate);
  except
    Exit;
  end;

  Result := ANewDate > ACurrentDate;
end;

function ForceDeleteFile(const AFileName: string): Boolean;
var
  TempName: string;
begin
  Result := False;
  if not FileExists(AFileName) then
    Exit(True);

  // Сначала обычная попытка
  if DeleteFile(AFileName) then
    Exit(True);

  // Пробуем переименовать в temp
  TempName := TPath.Combine(TPath.GetTempPath,
    'old_' + FormatDateTime('yyyymmddhhnnsszzz', Now) + '.tmp');

  if RenameFile(AFileName, TempName) then
  begin
    // Удаляем уже из temp (можно и не удалять — система потом почистит)
    DeleteFile(TempName);
    Result := True;
  end;
end;

procedure CleanupOldExeNow;
var
  OldPath: string;
  I: Integer;
begin
  OldPath := ChangeFileExt(ParamStr(0), cOldExeSuffix);
  if not FileExists(OldPath) then Exit;

  // Быстрые попытки
  for I := 1 to 15 do
  begin
    if ForceDeleteFile(OldPath) then Exit;
    Sleep(100);
  end;

  // Если не получилось — фоновый поток с более долгими ретраями
  TThread.CreateAnonymousThread(
    procedure
    var
      J: Integer;
    begin
      for J := 1 to 40 do
      begin
        if ForceDeleteFile(OldPath) then Exit;
        Sleep(250);
      end;
    end
  ).Start;
end;

initialization
  CleanupOldExeNow;

end.
