unit SystemUtils;

interface

uses Windows, Classes, SysUtils, Messages, ActiveX, ShlObj, Vcl.Dialogs, ShellApi,
     ExtCtrls, IniFiles, Forms, ComObj, StdCtrls, IOUtils, Graphics, Menus, CommCtrl,
     Vcl.Themes, Vcl.Controls;

// GENERAL FUNCTIONS
// ---------------------------------------------------------------------------
function GetExecPath: String;
procedure RestartApplication(FClosing: Boolean);
function ShellOpen(const FileName: string; const Parameters: string = ''): Boolean;
procedure OpenFileLocation(FileName: TFileName);
function RunProcess(const ExePath: string; const Parameters: string = '';
  const WorkingDir: string = ''; RunAsAdmin: Boolean = False;
  WaitForExit: Boolean = False; ShowError: Boolean = True): Boolean;
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
procedure StylesLoad(Config: TMemIniFile; MenuItem: TMenuItem);
function ToggleSelfInStartupFolder(AddIt: Boolean): Boolean;
function IsInStartupFolder: Boolean;
function GetLastFolderName(const Path: string): string;
function ExtractBaseTitle(const FileName: string): string;
procedure DrawAboutImage(PaintBox: TPaintBox);
function PrepareLanguageList(const RawList: string): TArray<string>;
function ShowComboDialog(const Items: array of string; var Selected: string;
                         const ACaption: string = 'Выберите вариант'): Boolean;
// ---------------------------------------------------------------------------

implementation

                             // GENERAL FUNCTIONS
// ---------------------------------------------------------------------------

function GetExecPath: String;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFileDir(ExtractFileDir(ParamStr(0))));
end;

procedure RestartApplication(FClosing: Boolean);
var
  ExeName: string;
begin
  ExeName := ParamStr(0);

  // Закрываем все меню
  SendMessage(HWND_BROADCAST, WM_CANCELMODE, 0, 0);

  // Создаём отдельный поток для перезапуска
  TThread.CreateAnonymousThread(
    procedure
    begin
      // Ждём пока закроются меню
      Sleep(200);

      // Запускаем новый процесс
      ShellExecute(0, 'open', PChar(ExeName), nil, nil, SW_SHOW);

      // Завершаем основной процесс
      TThread.Queue(nil,
        procedure
        begin
          FClosing := True;
          Application.Terminate;
        end);
    end
  ).Start;

  // Не вызываем Application.Terminate здесь, поток сделает это позже
end;
function ShellOpen(const FileName: string; const Parameters: string = ''): Boolean;
const
  ERR_MSG: array[0..31] of string = (
    '', 'File not found', 'Path not found', '', 'Access denied', '', '', 'Out of memory',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 'The connection is incomplete',
    'DDE is busy', 'DDE error', 'DDE is busy', 'No association', 'DLL not found'
  );
var
  Res: HINST;
  s: string;
  CurrentDir: string;
begin
  // Save current directory
  CurrentDir := GetCurrentDir;

  try
    // Set working directory to the executable's path
    SetCurrentDir(ExtractFilePath(FileName));

    // Execute the file
    Res := ShellExecute(0, 'open', PChar(FileName), PChar(Parameters), PChar(ExtractFilePath(FileName)), SW_SHOWNORMAL);

    Result := Res > 32;
    if Result then Exit;

    if (Res >= Low(ERR_MSG)) and (Res <= High(ERR_MSG)) and (ERR_MSG[Res] <> '') then
      s := ERR_MSG[Res]
    else
      s := Format('Error %d', [Res]);

    MessageDlg('Failed to open:' + #13#10 + FileName + #13#10#13#10 + s,
      mtError, [mbOK], 0);
  finally
    // Restore original directory
    SetCurrentDir(CurrentDir);
  end;
end;

procedure OpenFileLocation(FileName: TFileName);
begin
  ShellExecute(Application.Handle, 'OPEN', PChar('explorer.exe'),
           PChar('/select, "' + FileName + '"'), nil, SW_NORMAL);
end;

function RunProcess(const ExePath: string; const Parameters: string = '';
  const WorkingDir: string = ''; RunAsAdmin: Boolean = False;
  WaitForExit: Boolean = False; ShowError: Boolean = True): Boolean;
var
  SEI: TShellExecuteInfo;
  WorkDir: string;
  FileToRun, ParamsToUse: string;
  IsDir: Boolean;
  ErrorMsg: string;
begin
  Result := False;

  // Check if path exists
  if not FileExists(ExePath) and not DirectoryExists(ExePath) then
  begin
    if ShowError then
      MessageBox(0, PChar(Format('The file or directory does not exist: %s', [ExePath])),
                 'Error', MB_OK or MB_ICONERROR);
    Exit;
  end;

  IsDir := DirectoryExists(ExePath);

  // Prepare file and parameters
  if IsDir then
  begin
    FileToRun := 'explorer.exe';
    ParamsToUse := '"' + ExePath + '"';
  end
  else
  begin
    FileToRun := ExePath;
    ParamsToUse := Parameters;
  end;

  // Set working directory
  WorkDir := WorkingDir;
  if WorkDir = '' then
    WorkDir := ExtractFilePath(ExePath);

  // Prepare ShellExecuteInfo
  ZeroMemory(@SEI, SizeOf(SEI));
  SEI.cbSize := SizeOf(SEI);
  SEI.fMask := SEE_MASK_NOCLOSEPROCESS or SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;
  SEI.Wnd := 0;

  // Set verb: 'runas' for admin or 'open' for normal user
  if RunAsAdmin then
    SEI.lpVerb := 'runas'
  else
    SEI.lpVerb := 'open';

  SEI.lpFile := PChar(FileToRun);
  SEI.lpParameters := PChar(ParamsToUse);
  SEI.lpDirectory := PChar(WorkDir);
  SEI.nShow := SW_SHOWNORMAL;

  Result := ShellExecuteEx(@SEI);

  // Handle process handle
  if Result and (SEI.hProcess <> 0) then
  begin
    if WaitForExit then
      WaitForSingleObject(SEI.hProcess, INFINITE);
    CloseHandle(SEI.hProcess);
  end;

  // Error handling
  if not Result and ShowError then
  begin
    case GetLastError of
      ERROR_CANCELLED:
        ErrorMsg := 'The user has revoked the elevation of rights. (UAC)';
      ERROR_FILE_NOT_FOUND:
        ErrorMsg := 'File not found';
      else
        ErrorMsg := Format('ShellExecuteEx failed. Error: %d', [GetLastError]);
    end;
    MessageBox(0, PChar(ErrorMsg), 'Error', MB_OK or MB_ICONERROR);
  end;
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
  Item.Hint := 'Windows';
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

procedure StylesLoad(Config: TMemIniFile; MenuItem: TMenuItem);
var
  SavedStyle: string;
  ActiveStyleName: string;
  i: Integer;
begin
  // Загружаем сохранённый стиль
  SavedStyle := Config.ReadString('SGAllSettings', 'Styles', 'Windows');

  // Проверка если есть такой стиль
  if (SavedStyle <> '') and (TStyleManager.Style[SavedStyle] = nil) then
      SavedStyle := 'Windows';

  // Пытаемся применить стиль
  if not TStyleManager.TrySetStyle(SavedStyle, False) then
   begin
     TStyleManager.SetStyle('Windows');
     SavedStyle := 'Windows';
   end;

  // Берём **реальное** имя стиля, которое применилось
  ActiveStyleName := TStyleManager.ActiveStyle.Name;

  // Снимаем все галочки
  for i := 0 to MenuItem.Count - 1 do
    MenuItem.Items[i].Checked := False;

  // Ставим галочку по реальному имени
  for i := 0 to MenuItem.Count - 1 do
    begin
      if SameText(MenuItem.Items[i].Hint, ActiveStyleName) then
      begin
        MenuItem.Items[i].Checked := True;
        Exit;  // нашли → выходим
      end;
    end;

  // Если ничего не нашли по Hint → ищем "Windows" по Tag
  if SameText(ActiveStyleName, 'Windows') then
    for i := 0 to MenuItem.Count - 1 do
     if MenuItem.Items[i].Tag = -1 then
      begin
       MenuItem.Items[i].Checked := True;
       Break;
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

function GetLastFolderName(const Path: string): string;
begin
  Result := TPath.GetFileName(ExcludeTrailingPathDelimiter(Path));
end;

function ExtractBaseTitle(const FileName: string): string;
var
  S: string;
  DashPos: Integer;
  NumPart: string;
  N: Integer;
begin
  // 1. Берём только имя файла
  S := ExtractFileName(FileName);

  // 2. Убираем расширение
  S := ChangeFileExt(S, '');

  // 3. Последний дефис
  DashPos := LastDelimiter('-', S);

  if DashPos > 0 then
  begin
    NumPart := Copy(S, DashPos + 1, MaxInt);

    // 4. Если после дефиса ТОЛЬКО число — удаляем
    if TryStrToInt(NumPart, N) then
      Delete(S, DashPos, MaxInt);
  end;

  Result := S;
end;

procedure DrawAboutImage(PaintBox: TPaintBox);
const
 IID_IImageList: TGUID = '{46EB5926-582E-4017-9FDF-E8998DAA0950}';
var
  Icon: TIcon;
  FileInfo: TSHFileInfo;
  IconIndex: Integer;
  hIconLarge: HICON;
begin
  Icon := TIcon.Create;
  try
    // Получаем индекс иконки
    SHGetFileInfo(PChar(ParamStr(0)), 0, FileInfo, SizeOf(FileInfo),
      SHGFI_SYSICONINDEX);
    IconIndex := FileInfo.iIcon;

    // Извлекаем иконку максимального размера (обычно 256x256)
    SHGetImageList(SHIL_JUMBO, IID_IImageList, Pointer(hIconLarge));
    Icon.Handle := ImageList_GetIcon(hIconLarge, IconIndex, ILD_NORMAL);

    // Рисуем с масштабированием до 512x512
    PaintBox.Canvas.StretchDraw(Rect(2, 2, 514, 514),Icon);
  finally
    Icon.Free;
  end;
end;

function PrepareLanguageList(const RawList: string): TArray<string>;
var
  sl: TStringList;
  i: Integer;
  lang: string;
begin
  sl := TStringList.Create;
  try
    // Разбиваем строку по ';'
    sl.Delimiter := ';';
    sl.StrictDelimiter := True;
    sl.DelimitedText := RawList;

    // Убираем ведущий '!' у каждого элемента и добавляем в Result
    for i := 0 to sl.Count - 1 do
    begin
      lang := sl[i];
      if (Length(lang) > 0) and (lang[1] = '!') then
        Delete(lang, 1, 1);   // удаляем первый символ
      // Если строка не пустая, добавляем
      if lang <> '' then
        sl[i] := lang
      else
        sl[i] := '';  // помечаем пустые для последующего удаления
    end;

    // Удаляем пустые строки (если были)
    for i := sl.Count - 1 downto 0 do
      if sl[i] = '' then
        sl.Delete(i);

    // Проверяем наличие 'english'
    if sl.IndexOf('english') = -1 then
      sl.Insert(0, 'english');   // добавляем первым

    // Преобразуем TStringList в массив
    Result := sl.ToStringArray;
  finally
    sl.Free;
  end;
end;

function ShowComboDialog(const Items: array of string; var Selected: string;
                         const ACaption: string = 'Выберите вариант'): Boolean;
var
  frm: TForm;
  cmb: TComboBox;
  btnOk, btnCancel: TButton;
  i: Integer;
begin
  Result := False;
  Selected := '';

  frm := TForm.Create(Application);
  try
    frm.Caption := ACaption;
    frm.Width := 320;
    frm.Height := 170;
    frm.Position := poScreenCenter;
    frm.BorderStyle := bsDialog;

    // ComboBox
    cmb := TComboBox.Create(frm);
    cmb.Parent := frm;
    cmb.Left := 20;
    cmb.Top := 20;
    cmb.Width := frm.Width - 60;
    cmb.Style := csDropDownList;

    // Заполняем из переданного массива
    for i := Low(Items) to High(Items) do
      cmb.Items.Add(Items[i]);

    if cmb.Items.Count > 0 then
      cmb.ItemIndex := 0
    else
      cmb.ItemIndex := -1;

    // Кнопка OK
    btnOk := TButton.Create(frm);
    btnOk.Parent := frm;
    btnOk.Caption := 'OK';
    btnOk.Left := 60;
    btnOk.Top := 70;
    btnOk.Width := 80;
    btnOk.ModalResult := mrOk;
    btnOk.Default := True;   // Enter → OK

    // Кнопка Cancel
    btnCancel := TButton.Create(frm);
    btnCancel.Parent := frm;
    btnCancel.Caption := 'Отмена';
    btnCancel.Left := btnOk.Left + btnOk.Width + 20;
    btnCancel.Top := 70;
    btnCancel.Width := 80;
    btnCancel.ModalResult := mrCancel;
    btnCancel.Cancel := True;  // Escape → Отмена

    if frm.ShowModal = mrOk then
    begin
      if cmb.ItemIndex >= 0 then
        Selected := cmb.Items[cmb.ItemIndex]
      else
        Selected := '';
      Result := True;
    end;
  finally
    frm.Free;
  end;
end;

end.
