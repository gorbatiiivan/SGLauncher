unit Aria2Thread;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.IOUtils, Vcl.Dialogs,
  System.AnsiStrings;

type
  TAria2Thread = class(TThread)
  private
    FTorrentFile: string;
    FSaveDir: string;          // куда качает aria2c
    FFinalDir: string;         // куда положить в итоге
    FFileName: string;         // путь файла внутри торрента (eXo/eXoDOS/...)
    FRootFolder: string;       // корневая папка, которую создаёт торрент (например 'eXoDOS' или '')
    FExtraParams: string;
    FIndex: Integer;
    FSuccess: Boolean;
    FErrorMsg: string;

    procedure FindIndex;
    procedure DoDownload;
    procedure MoveAndCleanup;
    procedure ShowResult;
    function GetAria2Exe: string;
  protected
    procedure Execute; override;
  public
    constructor Create(const ATorrent, ASaveDir, AFinalDir, AFileName, ARootFolder, AExtra: string);
  end;

implementation

{ TAria2Thread }

constructor TAria2Thread.Create(const ATorrent, ASaveDir, AFinalDir, AFileName, ARootFolder, AExtra: string);
begin
  inherited Create(False);
  FreeOnTerminate := True;

  FTorrentFile := ATorrent;
  FSaveDir     := ASaveDir;
  FFinalDir    := AFinalDir;
  FFileName    := AFileName;
  FRootFolder  := ARootFolder;
  FExtraParams := AExtra;
  FIndex       := -1;
  FSuccess     := False;
end;

function TAria2Thread.GetAria2Exe: string;
var
  Candidate: string;
begin
  // 1. В папке torrents\ (рядом с .torrent файлом)
  Candidate := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'torrents\aria2c.exe';
  if FileExists(Candidate) then
    Exit(Candidate);

  // 2. В папке eXo\util\aria
  Candidate := TPath.Combine(
    TPath.GetDirectoryName(TPath.GetDirectoryName(ParamStr(0))), 'eXo\util\aria\aria2c.exe');
  if FileExists(Candidate) then
    Exit(Candidate);

  // 3. Fallback — просто имя (поиск в PATH)
  Result := 'aria2c.exe';
end;

procedure TAria2Thread.FindIndex;
var
  CmdLine: string;
  SI: TStartupInfo;
  PI: TProcessInformation;
  Security: TSecurityAttributes;
  ReadPipe, WritePipe: THandle;
  Buffer: array[0..8191] of AnsiChar;
  BytesRead: DWORD;
  Output: string;
  Lines: TStringList;
  i, Idx, P1, P2: Integer;
  Line, PathPart: string;
begin
  FIndex := -1;

  Security.nLength := SizeOf(Security);
  Security.bInheritHandle := True;
  Security.lpSecurityDescriptor := nil;

  if not CreatePipe(ReadPipe, WritePipe, @Security, 0) then
  begin
    FErrorMsg := 'Failed to create pipe';
    Exit;
  end;

  try
    ZeroMemory(@SI, SizeOf(SI));
    SI.cb := SizeOf(SI);
    SI.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
    SI.hStdOutput := WritePipe;
    SI.hStdError  := WritePipe;
    SI.wShowWindow := SW_HIDE;          // для -S окно не нужно

    CmdLine := Format('"%s" -S "%s"', [GetAria2Exe, FTorrentFile]);

    if not CreateProcess(nil, PChar(CmdLine), nil, nil, True,
                         CREATE_NO_WINDOW, nil, nil, SI, PI) then
    begin
      FErrorMsg := 'Failed to start aria2c -S';
      Exit;
    end;

    CloseHandle(WritePipe);
    WritePipe := 0;

    Output := '';
    repeat
      if not ReadFile(ReadPipe, Buffer, SizeOf(Buffer) - 1, BytesRead, nil) then Break;
      if BytesRead = 0 then Break;
      Buffer[BytesRead] := #0;
      Output := Output + string(AnsiString(Buffer));
    until False;

    WaitForSingleObject(PI.hProcess, INFINITE);
    CloseHandle(PI.hThread);
    CloseHandle(PI.hProcess);

    Lines := TStringList.Create;
    try
      Lines.Text := Output;
      for i := 0 to Lines.Count - 1 do
      begin
        Line := Trim(Lines[i]);
        if (Line = '') or (Pos('|', Line) = 0) then Continue;
        if not (Line[1] in ['0'..'9']) then Continue;

        P1 := Pos('|', Line);
        Idx := StrToIntDef(Copy(Line, 1, P1 - 1), -1);
        if Idx < 1 then Continue;

        PathPart := Copy(Line, P1 + 1, MaxInt);
        P2 := Pos('|', PathPart);
        if P2 > 0 then PathPart := Copy(PathPart, 1, P2 - 1);
        PathPart := Trim(PathPart);

        if SameText(ExtractFileName(PathPart), FFileName) or
           ContainsText(PathPart, FFileName) then
        begin
          FIndex := Idx;
          Exit;
        end;
      end;
    finally
      Lines.Free;
    end;

    if FIndex = -1 then
      FErrorMsg := 'File "' + FFileName + '" not found in torrent';
  finally
    if WritePipe <> 0 then CloseHandle(WritePipe);
    CloseHandle(ReadPipe);
  end;
end;

procedure TAria2Thread.DoDownload;
var
  CmdLine: string;
  SI: TStartupInfo;
  PI: TProcessInformation;
  ExitCode: DWORD;
begin
  // Здесь окно aria2c БУДЕТ видно
  // --bt-remove-unselected-file=true  ← удаляет все невыбранные файлы после завершения
  CmdLine := Format(
    '"%s" -T "%s" --dir="%s" -x16 -s16 -k1M --seed-time=0 ' +
    '--select-file=%d --bt-remove-unselected-file=true %s',
    [GetAria2Exe, FTorrentFile, FSaveDir, FIndex, FExtraParams]
  );

  ZeroMemory(@SI, SizeOf(SI));
  SI.cb := SizeOf(SI);
  SI.dwFlags := STARTF_USESHOWWINDOW;
  SI.wShowWindow := SW_SHOW;            // ← показываем окно

  if not CreateProcess(nil, PChar(CmdLine), nil, nil, False,
                       0,               // без CREATE_NO_WINDOW
                       nil, nil, SI, PI) then
  begin
    FErrorMsg := 'Failed to start aria2c';
    FSuccess := False;
    Exit;
  end;

  WaitForSingleObject(PI.hProcess, INFINITE);
  GetExitCodeProcess(PI.hProcess, ExitCode);
  CloseHandle(PI.hThread);
  CloseHandle(PI.hProcess);

  FSuccess := (ExitCode = 0);
  if not FSuccess then
    FErrorMsg := 'aria2c ended with an error (code ' + IntToStr(ExitCode) + ')';
end;

procedure TAria2Thread.MoveAndCleanup;
var
  SourceFile, DestFile, RelativePath, BaseName: string;
  Files: TArray<string>;
  i: Integer;
begin
  BaseName := ExtractFileName(StringReplace(FFileName, '/', '\', [rfReplaceAll]));
  RelativePath := StringReplace(FFileName, '/', '\', [rfReplaceAll]);

  // 1. Сначала пробуем ожидаемый путь
  if FRootFolder <> '' then
    SourceFile := IncludeTrailingPathDelimiter(FSaveDir) + FRootFolder + '\' + RelativePath
  else
    SourceFile := IncludeTrailingPathDelimiter(FSaveDir) + RelativePath;

  SourceFile := StringReplace(SourceFile, '/', '\', [rfReplaceAll]);

  // 2. Если не нашли — ищем по имени во всей папке (на случай соседних файлов / другой структуры)
  if not FileExists(SourceFile) then
  begin
    Files := TDirectory.GetFiles(FSaveDir, BaseName, TSearchOption.soAllDirectories);
    if Length(Files) = 0 then
    begin
      FErrorMsg := 'File not found:' + sLineBreak + SourceFile;
      FSuccess := False;
      Exit;
    end;

    // Если нашлось несколько — предпочитаем тот, у которого путь ближе к RelativePath
    SourceFile := Files[0];
    for i := 0 to High(Files) do
      if ContainsText(Files[i], RelativePath) or ContainsText(Files[i], FRootFolder) then
      begin
        SourceFile := Files[i];
        Break;
      end;
  end;

  // Куда копируем — только сам файл, без структуры папок
  DestFile := IncludeTrailingPathDelimiter(FFinalDir) + BaseName;
  DestFile := StringReplace(DestFile, '/', '\', [rfReplaceAll]);

  ForceDirectories(ExtractFilePath(DestFile));

  if not CopyFile(PChar(SourceFile), PChar(DestFile), False) then
  begin
    FErrorMsg := Format(
      'Copy error (code %d)' + sLineBreak +
      'Из: %s' + sLineBreak +
      'В:  %s',
      [GetLastError, SourceFile, DestFile]
    );
    FSuccess := False;
    Exit;
  end;

  // Удаляем временную папку (и все остатки, которые aria2 мог оставить)
  try
    if (FRootFolder <> '') and DirectoryExists(IncludeTrailingPathDelimiter(FSaveDir) + FRootFolder) then
      TDirectory.Delete(IncludeTrailingPathDelimiter(FSaveDir) + FRootFolder, True)
    else
    begin
      // если корневой папки нет — чистим всё, что лежит прямо в FSaveDir
      // (осторожно: только если FSaveDir используется исключительно этим потоком)
      // TDirectory.Delete(FSaveDir, True);  // раскомментируй, если нужно
    end;
  except
    // игнорируем ошибки удаления
  end;

  FSuccess := True;
end;

procedure TAria2Thread.ShowResult;
begin
  if not FSuccess then
    ShowMessage(FErrorMsg);
end;

procedure TAria2Thread.Execute;
begin
  FindIndex;
  if FIndex = -1 then
  begin
    Synchronize(ShowResult);
    Exit;
  end;

  DoDownload;
  if not FSuccess then
  begin
    Synchronize(ShowResult);
    Exit;
  end;

  // После успешного скачивания — копируем и чистим
  MoveAndCleanup;

  Synchronize(ShowResult);
end;

end.
