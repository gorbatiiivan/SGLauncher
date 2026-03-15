unit SystemUtils;

interface

uses Windows, Classes, SysUtils, ActiveX, ShlObj, Vcl.Dialogs, ShellApi,
     IniFiles, Forms, ComObj, StdCtrls, IOUtils, Graphics, Menus, Vcl.Themes;

// GENERAL FUNCTIONS
// ---------------------------------------------------------------------------
function GetExecPath: String;
function ShellOpen(const FileName: string): Boolean;
procedure StrToList(const S, Sign: string; SList: TStrings);
function LoadIconFromRCDATA(const ResourceName: string): TIcon;
procedure ResizeLabelToText(ALabel: TLabel);
function CreateDesktopShellLink(
  const TargetExePath: string;           // полный путь к .exe / .bat / ...
  const CustomLinkName: string = '';     // желаемое имя без .lnk
  const Description: string = '';        // всплывающая подсказка
  const Arguments: string = '';          // аргументы командной строки
  const WorkingDir: string = '';         // рабочая папка
  const IconPath: string = '';           // путь к файлу с иконкой (.exe, .dll, .ico)
  const IconIndex: Integer = 0           // индекс иконки
): Boolean;
procedure BuildStylesMenu(ARootMenu: TMenuItem; AOnClick: TNotifyEvent);
function ToggleSelfInStartupFolder(AddIt: Boolean): Boolean;
function IsInStartupFolder: Boolean;
// ---------------------------------------------------------------------------

implementation

                             // GENERAL FUNCTIONS
// ---------------------------------------------------------------------------

function GetExecPath: String;
begin
  SetCurrentDir(IncludeTrailingPathDelimiter(ExtractFileDir(ExtractFileDir(ParamStr(0)))));
  Result := IncludeTrailingPathDelimiter(ExtractFileDir(ExtractFileDir(ParamStr(0))));
end;

function ShellOpen(const FileName: string): Boolean;
const
  ERR_MSG: array[0..31] of string = (
    '', 'File not found', 'Path not found', '', 'Access denied', '', '', 'Out of memory',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 'The connection is incomplete',
    'DDE is busy', 'DDE error', 'DDE is busy', 'No association', 'DLL not found'
  );
var
  Res: HINST;
  s: string;
begin
  Res := ShellExecute(0, 'open', PChar(FileName), nil, PChar(ExtractFilePath(FileName)), SW_SHOWNORMAL);

  Result := Res > 32;
  if Result then Exit;

  if (Res >= Low(ERR_MSG)) and (Res <= High(ERR_MSG)) and (ERR_MSG[Res] <> '') then
    s := ERR_MSG[Res]
  else
    s := Format('Error %d', [Res]);

  MessageDlg('Failed to open:' + #13#10 + FileName + #13#10#13#10 + s,
    mtError, [mbOK], 0);
end;

procedure StrToList(const S, Sign: string; SList: TStrings);
var
  CurPos: integer;
  CurStr: string;
begin
  SList.clear;
  SList.BeginUpdate();
  try
    CurStr := S;
    repeat
      CurPos := Pos(Sign, CurStr);
      if (CurPos > 0) then
      begin
        SList.Add(Copy(CurStr, 1, Pred(CurPos)));
        CurStr := Trim(Copy(CurStr, CurPos + Length(Sign),
          Length(CurStr) - CurPos - Length(Sign) + 1));
      end
      else
        SList.Add(CurStr);
    until CurPos = 0;
  finally
    SList.EndUpdate();
  end;
end;

function LoadIconFromRCDATA(const ResourceName: string): TIcon;
var
  hIco: HICON;
begin
  Result := TIcon.Create;

  // Большая иконка (32x32) — для заголовка, Alt+Tab
  hIco := LoadImage(HInstance, PChar(ResourceName), IMAGE_ICON,
    GetSystemMetrics(SM_CXICON),
    GetSystemMetrics(SM_CYICON),
    LR_DEFAULTCOLOR);

  if hIco <> 0 then
    Result.Handle := hIco;
end;

//Функция для пересчёта высоты Label в ScrollBox
procedure ResizeLabelToText(ALabel: TLabel);
var
  R: TRect;
begin
  R := Rect(0, 0, ALabel.Width, MaxInt);
  ALabel.Canvas.Font.Assign(ALabel.Font);
  DrawText(ALabel.Canvas.Handle,
    PChar(ALabel.Caption),
    -1,
    R,
    DT_WORDBREAK or DT_CALCRECT);

  ALabel.Height := R.Bottom - R.Top;
end;

function CreateDesktopShellLink(
  const TargetExePath: string;           // полный путь к .exe / .bat / ...
  const CustomLinkName: string = '';     // желаемое имя без .lnk
  const Description: string = '';        // всплывающая подсказка
  const Arguments: string = '';          // аргументы командной строки
  const WorkingDir: string = '';         // рабочая папка
  const IconPath: string = '';           // путь к файлу с иконкой (.exe, .dll, .ico)
  const IconIndex: Integer = 0           // индекс иконки
): Boolean;

 function SanitizeLinkName(const Name: string): string;
 begin
  Result := Name;

  // Заменяем проблемные символы, которые ломают ярлыки в Windows
  Result := StringReplace(Result, ',', ' -', [rfReplaceAll]);
  Result := StringReplace(Result, ';',  ' -', [rfReplaceAll]);
  Result := StringReplace(Result, ':',  ' -', [rfReplaceAll]);
  Result := StringReplace(Result, '/',  '-',  [rfReplaceAll]);
  Result := StringReplace(Result, '\',  '-',  [rfReplaceAll]);
  Result := StringReplace(Result, '*',  '',   [rfReplaceAll]);
  Result := StringReplace(Result, '?',  '',   [rfReplaceAll]);
  Result := StringReplace(Result, '"',  '''', [rfReplaceAll]);
  Result := StringReplace(Result, '<',  '',   [rfReplaceAll]);
  Result := StringReplace(Result, '>',  '',   [rfReplaceAll]);
  Result := StringReplace(Result, '|',  '-',  [rfReplaceAll]);

  // Убираем множественные пробелы и обрезаем
  while Pos('  ', Result) > 0 do
    Result := StringReplace(Result, '  ', ' ', [rfReplaceAll]);
  Result := Trim(Result);

  // Если после очистки имя стало пустым — ставим заглушку
  if Result = '' then
    Result := 'Link';
 end;

var
  ShellLink   : IShellLink;
  PersistFile : IPersistFile;
  DesktopPIDL : PItemIDList;
  DesktopPath : array[0..MAX_PATH-1] of Char;
  BaseName    : string;
  LinkName    : string;
  FinalLinkPath : WideString;
  Counter     : Integer;
begin
  Result := False;

  // Проверяем существование целевого файла
  if not TFile.Exists(TargetExePath) then
    Exit;

  // Получаем путь к рабочему столу текущего пользователя
  if Failed(SHGetSpecialFolderLocation(0, CSIDL_DESKTOP, DesktopPIDL)) then
    Exit;

  try
    if not SHGetPathFromIDList(DesktopPIDL, DesktopPath) then
      Exit;

    // Определяем базовое имя ярлыка
    if CustomLinkName <> '' then
      BaseName := CustomLinkName
    else
      BaseName := ChangeFileExt(ExtractFileName(TargetExePath), '');

    // Очищаем имя от опасных символов
    BaseName := SanitizeLinkName(BaseName);

    // Формируем имя файла ярлыка
    LinkName := BaseName + '.lnk';
    FinalLinkPath := IncludeTrailingPathDelimiter(DesktopPath) + LinkName;

    // Если такой ярлык уже существует — добавляем (1), (2), ...
    Counter := 1;
    while TFile.Exists(FinalLinkPath) do
    begin
      LinkName := BaseName + ' (' + IntToStr(Counter) + ').lnk';
      FinalLinkPath := IncludeTrailingPathDelimiter(DesktopPath) + LinkName;
      Inc(Counter);
      if Counter > 99 then Break; // защита от бесконечного цикла
    end;

    // Создаём объект ярлыка
    OleCheck(CoCreateInstance(CLSID_ShellLink, nil, CLSCTX_INPROC_SERVER, IShellLink, ShellLink));

    try
      // Устанавливаем основные свойства
      OleCheck(ShellLink.SetPath(PChar(TargetExePath)));

      if Description <> '' then
        OleCheck(ShellLink.SetDescription(PChar(Description)));

      if Arguments <> '' then
        OleCheck(ShellLink.SetArguments(PChar(Arguments)));

      // Рабочая директория
      if WorkingDir <> '' then
        OleCheck(ShellLink.SetWorkingDirectory(PChar(WorkingDir)))
      else
        OleCheck(ShellLink.SetWorkingDirectory(PChar(ExtractFilePath(TargetExePath))));

      // Иконка (если указана)
      if IconPath <> '' then
        OleCheck(ShellLink.SetIconLocation(PChar(IconPath), IconIndex));

      // Сохраняем ярлык
      PersistFile := ShellLink as IPersistFile;
      Result := Succeeded(PersistFile.Save(PWideChar(FinalLinkPath), False));
    finally
      ShellLink := nil;
    end;

  finally
    if Assigned(DesktopPIDL) then
      CoTaskMemFree(DesktopPIDL);
  end;
end;

// VCL Styles -----------------------------------------------------------------
procedure BuildStylesMenu(ARootMenu: TMenuItem; AOnClick: TNotifyEvent);
//Добавление скинов
var
  StyleName: string;
  Item: TMenuItem;
begin
  if ARootMenu = nil then Exit;
  ARootMenu.Clear;

  // Сначала всегда добавляем Windows (Standard)
  Item := TMenuItem.Create(ARootMenu);
  Item.Caption := 'Windows';
  Item.Tag := -1;
  Item.OnClick := AOnClick;
  if SameText('Windows', TStyleManager.ActiveStyle.Name) then
    Item.Checked := True;
  ARootMenu.Add(Item);

  ARootMenu.Add(NewLine);

  // Затем все остальные стили (включая возможные другие встроенные, если они есть)
  for StyleName in TStyleManager.StyleNames do
  begin
    if SameText(StyleName, 'Windows') then
      Continue;

    Item := TMenuItem.Create(ARootMenu);
    Item.Caption := StyleName;
    Item.Hint := StyleName;
    Item.Tag := 0;
    Item.OnClick := AOnClick;
    if SameText(StyleName, TStyleManager.ActiveStyle.Name) then
      Item.Checked := True;
    ARootMenu.Add(Item);
  end;
end;

//----Autostart----
//------------------------------------------------------------------------------
function ToggleSelfInStartupFolder(AddIt: Boolean): Boolean;
var
  StartupPath: array[0..MAX_PATH] of Char;
  LinkFile: string;
  ShellLink: IShellLink;
  PersistFile: IPersistFile;
begin
  Result := False;

  if SHGetFolderPath(0, CSIDL_STARTUP, 0, 0, StartupPath) <> S_OK then
    Exit;

  LinkFile := IncludeTrailingPathDelimiter(StartupPath) +
              ChangeFileExt(ExtractFileName(ParamStr(0)), '.lnk');

  if AddIt then
  begin
    CoInitialize(nil);
    try
      ShellLink := CreateComObject(CLSID_ShellLink) as IShellLink;
      ShellLink.SetPath(PChar(ParamStr(0)));
      ShellLink.SetWorkingDirectory(PChar(ExtractFileDir(ParamStr(0))));

      PersistFile := ShellLink as IPersistFile;
      Result := Succeeded(PersistFile.Save(PWideChar(WideString(LinkFile)), True));
    finally
      CoUninitialize;
    end;
  end
  else
  begin
    if FileExists(LinkFile) then
      Result := DeleteFile(LinkFile)
    else
      Result := True;
  end;
end;

function IsInStartupFolder: Boolean;
var
  StartupPath : array[0..MAX_PATH-1] of Char;
  LinkPath    : string;
  SL          : IShellLink;
  PF          : IPersistFile;
  TargetBuf   : array[0..MAX_PATH-1] of Char;
  WideBuf     : array[0..MAX_PATH-1] of WideChar;
  FoundData   : TWin32FindData;
  hr          : HRESULT;
begin
  Result := False;

  // Получаем папку Startup
  if SHGetFolderPath(0, CSIDL_STARTUP, 0, 0, StartupPath) <> S_OK then
    Exit;

  LinkPath := IncludeTrailingPathDelimiter(string(StartupPath)) +
              ChangeFileExt(ExtractFileName(ParamStr(0)), '.lnk');

  if not FileExists(LinkPath) then
    Exit;

  // Пытаемся открыть .lnk как COM-объект
  hr := CoCreateInstance(CLSID_ShellLink, nil, CLSCTX_INPROC_SERVER,
                         IShellLink, SL);
  if Failed(hr) then
    Exit;

  try
    PF := SL as IPersistFile;

    // Загружаем файл ярлыка
    StringToWideChar(LinkPath, WideBuf, MAX_PATH);
    hr := PF.Load(WideBuf, STGM_READ);
    if Failed(hr) then
      Exit;

    // Получаем путь цели ярлыка
    hr := SL.GetPath(TargetBuf, MAX_PATH, FoundData, SLGP_UNCPRIORITY or SLGP_RAWPATH);
    if Failed(hr) then
      Exit;

    // Сравниваем с путём текущей программы
    Result := SameText(string(TargetBuf), ParamStr(0));

  finally
    SL := nil;   // освобождаем интерфейс
  end;
end;

end.
