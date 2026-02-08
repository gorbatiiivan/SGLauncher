unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Types,
  System.IOUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons, Vcl.Imaging.jpeg, Vcl.Imaging.pngimage,
  Vcl.Imaging.GIFImg, Xml.XMLIntf, Xml.XMLDoc, Math, ActiveX, ComObj, ShellAPI,
  IniFiles, Vcl.Menus, ShlObj, Vcl.ImgList, StrUtils, System.Generics.Collections;

const
  sReleaseDate = '28.01.2026';

type
  TGameData = record
    GameName: string;
    ApplicationPath: string;
    Platforms: string;
    ReleaseDate: string;
    Developer: string;
    Publisher: string;
    Genre: string;
    Series: string;
    Notes: string;
    Manual: string;
    ConfigurationPath: string;
    RootFolder: string;
  end;

type
  TMainForm = class(TForm)
    TabControl1: TTabControl;
    Panel1: TPanel;
    Panel2: TPanel;
    ScreenShotImage: TImage;
    Panel3: TPanel;
    ListView1: TListView;
    Panel4: TPanel;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    PopupMenu1: TPopupMenu;
    Run1: TMenuItem;
    Configuration1: TMenuItem;
    N1: TMenuItem;
    Manual1: TMenuItem;
    TrayIcon: TTrayIcon;
    NextImgBtn: TSpeedButton;
    ScrollBox1: TScrollBox;
    Label1: TLabel;
    InfoPanel: TPanel;
    TitleLabel: TLabel;
    DeveloperLabel: TLabel;
    PublisherLabel: TLabel;
    GenreLabel: TLabel;
    SeriesLabel: TLabel;
    PlatformLabel: TLabel;
    ReleaseLabel: TLabel;
    PrevImgBtn: TSpeedButton;
    N2: TMenuItem;
    Customimagename1: TMenuItem;
    TrayMenu: TPopupMenu;
    Hideonstartup1: TMenuItem;
    N3: TMenuItem;
    Exit1: TMenuItem;
    Options1: TMenuItem;
    N4: TMenuItem;
    Show1: TMenuItem;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    N5: TMenuItem;
    Specifyfolder1: TMenuItem;
    About1: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    DesktopShortcut1: TMenuItem;
    procedure FormResize(Sender: TObject);
    procedure ListView1Data(Sender: TObject; Item: TListItem);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure ComboBox1Change(Sender: TObject);
    procedure TabControl1Change(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure ScreenShotImageClick(Sender: TObject);
    procedure ListView1DblClick(Sender: TObject);
    procedure Run1Click(Sender: TObject);
    procedure Configuration1Click(Sender: TObject);
    procedure Manual1Click(Sender: TObject);
    procedure TrayIconClick(Sender: TObject);
    procedure ListView1KeyPress(Sender: TObject; var Key: Char);
    procedure ListView1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure NextImgBtnClick(Sender: TObject);
    procedure PrevImgBtnClick(Sender: TObject);
    procedure Customimagename1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Hideonstartup1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Specifyfolder1Click(Sender: TObject);
    procedure ListView1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure About1Click(Sender: TObject);
    procedure DesktopShortcut1Click(Sender: TObject);
  private
    TempWIC: TWICImage;
    FConfig: TMemIniFile;
    NConfig: TMemIniFile;
    FClosing: Boolean;
    //----------------------
    FGameData: array of TGameData;
    FFilteredIndices: TArray<Integer>;
    FLoaderThread: TThread;
    FIsFilterActive: Boolean;
    FLoadingComplete: Boolean;
    FActualGameCount: Integer; // Реальное количество игр
    FSearchText: string;
    ImgCurIndex: Integer;
    ImgList: TStringList;
    // Для поиска
    FTypeBuffer: string;
    FLastTypeTick: Cardinal;
    //----------------------
    // Для кэша изображдения
    FImageCache: TDictionary<string, TStringList>;
    FCacheBuilt: Boolean;
    //----------------------
    procedure AddGameToArray(const G: TGameData);
    procedure SortGameData;
    procedure LoadXMLToArray(const XMLFileName: string);
    procedure ScanXMLFromDir(const Dir: string);
    procedure ApplyFilters;
    procedure AddImagesToList(const ImagesPath: string;
                                    SourcePath: TListView;
                                    const ForcedBaseName: string = '');
    procedure InitializeComboBoxes;
    procedure FinalizeLoading;
    procedure UpdateExtrasMenu(const GameIndex: Integer);
    procedure ClearGameInfo;
    procedure UpdateGenreSeriesComboForCurrentPlatform;
    procedure ShowGameByIndex(const ItemIndex: Integer);
    function GetFConfig: TMemIniFile;
    function GetNConfig: TMemIniFile;
    procedure RegIni(Write: Boolean);
    procedure OnExtrasMenuItemClick(Sender: TObject);
    // Для кэша изображдения
    procedure FreeImageCache;
    procedure BuildImageCache; // один раз собираем всё
    procedure RunCacheImages;
    //----------------------

  end;

var
  MainForm: TMainForm;
  LaunchBoxDir: String = '';
  IgnoreDir: String;
  HideInTray: Boolean = False;

implementation

{$R *.dfm}

uses FullScreenImage, DialogForm, Help;

//----FUNCTIONS----
//------------------------------------------------------------------------------
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

function GetExecPath: String;
begin
  SetCurrentDir(IncludeTrailingPathDelimiter(ExtractFileDir(ExtractFileDir(ParamStr(0)))));
  Result := IncludeTrailingPathDelimiter(ExtractFileDir(ExtractFileDir(ParamStr(0))));
end;

function GetYear(const Date: string): string;
var
  fs: TFormatSettings;
  dt: TDateTime;
begin
  Result := '';
  if Date = '' then Exit;

  fs := TFormatSettings.Create;
  fs.DateSeparator := '-';
  fs.ShortDateFormat := 'yyyy-mm-dd';

  try
    dt := StrToDate(Date, fs);
    Result := FormatDateTime('yyyy', dt);
  except
    Result := '';
  end;
end;

function NormalizeLaunchBoxPath(const RelPath: string): string;
var
  Parts: TArray<string>;
  CleanParts: TArray<string>;
  IgnoredFolders: TStringList;
  I, C: Integer;
  FolderName: string;
begin
  // Разбиваем путь по слешам
  Parts := RelPath.Split(['\', '/']);
  SetLength(CleanParts, Length(Parts));
  C := 0;

  // Список игнорируемых папок
  IgnoredFolders := TStringList.Create;
  try
    IgnoredFolders.CaseSensitive := False;
    StrToList(IgnoreDir, ';', IgnoredFolders);

    for I := 0 to High(Parts) do
    begin
      FolderName := Parts[I];

      // Пустые части (двойные слеши) — сохраняем
      if FolderName = '' then
      begin
        CleanParts[C] := FolderName;
        Inc(C);
        Continue;
      end;

      // Если папка начинается с ! и есть в IgnoreDir — пропускаем
      if (FolderName[1] = '!') and
         (IgnoredFolders.IndexOf(FolderName) >= 0) then
        Continue;

      // Всё остальное — добавляем как есть
      CleanParts[C] := FolderName;
      Inc(C);
    end;
  finally
    IgnoredFolders.Free;
  end;

  SetLength(CleanParts, C);

  // Собираем путь обратно
  Result := string.Join(PathDelim, CleanParts);
end;

function IsGameInstalled(const G: TGameData): Boolean;
var
  CleanRelPath, FullPath, FullDir: string;
begin
  Result := False;
  if Trim(G.ApplicationPath) = '' then
    Exit;

  // Убираем папки вида !xxx из пути (как ты и хотел)
  CleanRelPath := NormalizeLaunchBoxPath(G.ApplicationPath);

  // Если после очистки путь пустой — игра не установлена
  if CleanRelPath = '' then
    Exit;

  // Формируем полный путь к исполняемому файлу
  FullPath := TPath.GetFullPath(TPath.Combine(LaunchBoxDir, CleanRelPath));

  // Сначала проверяем сам файл
  if TFile.Exists(FullPath) then
  begin
    Result := True;
    Exit;
  end;

  // Если файла нет — проверяем, существует ли хотя бы корневая папка игры
  // (полезно для игр, где ApplicationPath указывает на .bat/.exe, но сама папка есть)
  FullDir := ExtractFileDir(FullPath);
  if TDirectory.Exists(FullDir) then
    Result := True;
end;

function LoadIconFromRCDATA(const ResourceName: string): TIcon;
var
  Stream: TResourceStream;
begin
  Result := TIcon.Create;  // Создаём результат сразу
  try
    Stream := TResourceStream.Create(HInstance, ResourceName, RT_RCDATA);
    try
      Result.LoadFromStream(Stream);  // Загружаем в Result
    finally
      Stream.Free;
    end;
  except
    Result.Free;  // Если ошибка — освобождаем и пробрасываем дальше
    raise;
  end;
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

function GetLabelHeight(ALabel: TLabel; const AText: string; AWidth: Integer): Integer;
var
  R: TRect;
begin
  R := Rect(0, 0, AWidth, 0);
  ALabel.Canvas.Font := ALabel.Font;  // Копируем шрифт
  DrawText(ALabel.Canvas.Handle, PChar(AText), -1, R,
           DT_CALCRECT or DT_WORDBREAK or DT_LEFT);
  Result := R.Bottom - R.Top;
end;

function CreateDesktopShellLink(
  const TargetExePath: string;           // полный путь к .exe
  const CustomLinkName: string = '';     // желаемое имя без .lnk (если пусто → берётся из TargetExePath)
  const Description: string = '';         // всплывающая подсказка
  const Arguments: string = '';           // аргументы командной строки
  const WorkingDir: string = '';          // рабочая папка (по умолчанию — папка программы)
  const IconPath: string = '';            // путь к иконке (может быть .exe, .dll, .ico)
  const IconIndex: Integer = 0            // индекс иконки внутри файла
): Boolean;
//Функция для создание ярлыка на рабочем столе
var
  ShellLink   : IShellLink;
  PersistFile : IPersistFile;
  DesktopPIDL : PItemIDList;
  DesktopPath : array[0..MAX_PATH-1] of Char;
  BaseName    : WideString;
  LinkName    : WideString;
  FinalLinkPath : WideString;
  Counter     : Integer;
begin
  Result := False;

  if not FileExists(TargetExePath) then
    Exit;

  // Получаем путь к рабочему столу
  if Failed(SHGetSpecialFolderLocation(0, CSIDL_DESKTOP, DesktopPIDL)) then
    Exit;

  try
    if not SHGetPathFromIDList(DesktopPIDL, DesktopPath) then
      Exit;

    // Определяем базовое имя ярлыка (без .lnk)
    if CustomLinkName <> '' then
      BaseName := CustomLinkName
    else
      BaseName := ChangeFileExt(ExtractFileName(TargetExePath), '');

    // Начинаем с оригинального имени
    LinkName := BaseName + '.lnk';
    FinalLinkPath := WideString(IncludeTrailingPathDelimiter(DesktopPath)) + LinkName;

    // Если существует → добавляем (1), (2), ...
    Counter := 1;
    while FileExists(FinalLinkPath) do
    begin
      LinkName := BaseName + ' (' + IntToStr(Counter) + ').lnk';
      FinalLinkPath := WideString(IncludeTrailingPathDelimiter(DesktopPath)) + LinkName;
      Inc(Counter);
    end;

    // Создаём COM-объект ярлыка
    ShellLink := CreateComObject(CLSID_ShellLink) as IShellLink;

    ShellLink.SetPath(PChar(TargetExePath));
    ShellLink.SetDescription(PChar(Description));

    if WorkingDir <> '' then
      ShellLink.SetWorkingDirectory(PChar(WorkingDir))
    else
      ShellLink.SetWorkingDirectory(PChar(ExtractFilePath(TargetExePath)));

    if Arguments <> '' then
      ShellLink.SetArguments(PChar(Arguments));

    if IconPath <> '' then
      ShellLink.SetIconLocation(PChar(IconPath), IconIndex);

    PersistFile := ShellLink as IPersistFile;

    // Сохраняем
    Result := Succeeded(
      PersistFile.Save(
        PWideChar(FinalLinkPath),
        False
      )
    );

  finally
    if Assigned(DesktopPIDL) then
      CoTaskMemFree(DesktopPIDL);
  end;
end;

procedure TMainForm.AddGameToArray(const G: TGameData);
begin
  // Выделяем память блоками по 100 элементов для ускорения
  if FActualGameCount >= Length(FGameData) then
    SetLength(FGameData, Length(FGameData) + 100);
  FGameData[FActualGameCount] := G;
  Inc(FActualGameCount);
end;

procedure TMainForm.UpdateExtrasMenu(const GameIndex: Integer);

  // Вспомогательная процедура сортировки
  procedure SortStringArray(var Arr: TStringDynArray);
  var
    sl: TStringList;
    i: Integer;
  begin
    sl := TStringList.Create;
    try
      sl.Sorted := False;
      sl.Duplicates := dupAccept;
      for i := 0 to High(Arr) do
        sl.AddObject(ExtractFileName(Arr[i]), TObject(i));
      sl.Sort;
      for i := 0 to sl.Count-1 do
        Arr[i] := TStringDynArray(Arr)[Integer(sl.Objects[i])];
    finally
      sl.Free;
    end;
  end;

  // Рекурсивная процедура добавления содержимого папки в меню
  procedure AddFolderToMenu(ParentMenu: TMenuItem; const FolderPath: string);
  var
    SubDirs   : TStringDynArray;
    Files     : TStringDynArray;
    SubDir    : string;
    FileName  : string;
    SubMenu   : TMenuItem;
    MenuItem  : TMenuItem;
    Icon      : TIcon;
    FileInfo  : TSHFileInfo;
  begin
    // Подпапки
    SubDirs := TDirectory.GetDirectories(FolderPath);
    SortStringArray(SubDirs);

    for SubDir in SubDirs do
    begin
      SubMenu := TMenuItem.Create(ParentMenu);
      SubMenu.Caption := ExtractFileName(SubDir);

      // иконка папки (если получится)
      if SHGetFileInfo(PChar(SubDir), 0, FileInfo, SizeOf(FileInfo),
                       SHGFI_ICON or SHGFI_LARGEICON or SHGFI_SYSICONINDEX) <> 0 then
      begin
        try
          Icon := TIcon.Create;
          try
            Icon.Handle := FileInfo.hIcon;
            SubMenu.ImageIndex := PopupMenu1.Images.AddIcon(Icon);
          finally
            DestroyIcon(FileInfo.hIcon);
            Icon.Free;
          end;
        except
          SubMenu.ImageIndex := -1;
        end;
      end
      else
        SubMenu.ImageIndex := -1;

      // рекурсия
      AddFolderToMenu(SubMenu, SubDir);

      // добавляем подпапку только если в ней что-то есть
      if SubMenu.Count > 0 then
        ParentMenu.Add(SubMenu)
      else
        SubMenu.Free;
    end;

    // Файлы в текущей папке
    Files := TDirectory.GetFiles(FolderPath, '*.*', TSearchOption.soTopDirectoryOnly);
    SortStringArray(Files);

    for FileName in Files do
    begin
      MenuItem := TMenuItem.Create(ParentMenu);
      MenuItem.Caption := ChangeFileExt(ExtractFileName(FileName), '');
      MenuItem.Hint    := FileName;
      MenuItem.OnClick := OnExtrasMenuItemClick;

      // иконка файла
      if SHGetFileInfo(PChar(FileName), 0, FileInfo, SizeOf(FileInfo),
                       SHGFI_ICON or SHGFI_LARGEICON or SHGFI_USEFILEATTRIBUTES) <> 0 then
      begin
        try
          Icon := TIcon.Create;
          try
            Icon.Handle := FileInfo.hIcon;
            MenuItem.ImageIndex := PopupMenu1.Images.AddIcon(Icon);
          finally
            DestroyIcon(FileInfo.hIcon);
            Icon.Free;
          end;
        except
          MenuItem.ImageIndex := -1;
        end;
      end
      else
        MenuItem.ImageIndex := -1;

      ParentMenu.Add(MenuItem);
    end;
  end;

var
  AppPath, BasePath, FullExtrasPath: string;
  Separator: TMenuItem;
begin
  // Очищаем всё, что добавлялось ранее после первых 6 пунктов
  while PopupMenu1.Items.Count > 8 do
    PopupMenu1.Items.Delete(PopupMenu1.Items.Count - 1);

  if GameIndex = -1 then Exit;
  AppPath := FGameData[GameIndex].ApplicationPath;
  if AppPath = '' then Exit;

  BasePath := ExtractFilePath(AppPath);
  FullExtrasPath := IncludeTrailingPathDelimiter(LaunchBoxDir) +
                    IncludeTrailingPathDelimiter(BasePath) + 'Extras';

  if not TDirectory.Exists(FullExtrasPath) then
    Exit;

  // разделитель перед дополнительными пунктами
  Separator := TMenuItem.Create(PopupMenu1);
  Separator.Caption := '-';
  PopupMenu1.Items.Add(Separator);

  // создаём ImageList если его ещё нет
  if not Assigned(PopupMenu1.Images) then
  begin
    PopupMenu1.Images := TImageList.Create(PopupMenu1);
    PopupMenu1.Images.ColorDepth := cd32Bit;
    PopupMenu1.Images.Width  := 16;
    PopupMenu1.Images.Height := 16;
  end;

  // сразу добавляем содержимое Extras в основное меню
  AddFolderToMenu(PopupMenu1.Items, FullExtrasPath);
end;

procedure TMainForm.ClearGameInfo;
begin
  ListView1.ItemIndex := -1;
  TitleLabel.Caption := '';
  PlatformLabel.Caption := '';
  ReleaseLabel.Caption := '';
  DeveloperLabel.Caption := '';
  PublisherLabel.Caption := '';
  GenreLabel.Caption := '';
  SeriesLabel.Caption := '';
  Label1.Caption := '';
  ResizeLabelToText(Label1);
  ScreenShotImage.Picture := nil;
  ImgCurIndex := -1;
  ImgList.Clear;
  NextImgBtn.Enabled := False;
  PrevImgBtn.Enabled := False;
  while PopupMenu1.Items.Count > 8 do
    PopupMenu1.Items.Delete(PopupMenu1.Items.Count - 1);
end;

procedure TMainForm.AddImagesToList(const ImagesPath: string;
  SourcePath: TListView;
  const ForcedBaseName: string = '');
var
  PlatformDir: string;
  Platform2: string;
  Year: string;
  BaseNameNoYear, BaseNameWithYear, BaseNameWithYearNoSpace: string;
  PriorityFolders: TArray<string>;
  Folder: string;
  SearchPath: string;
  Files: TStringDynArray;
  FilePath, FileName: string;
  i: Integer;
  ExcludedDirs: TStringList;

  function OneLine(const s: string): string;
  const
    BadChars1     = ':"''/\<>|?*[]''';  // Старые, критические — заменяем первыми
    //BadChars2     = '?:';         // Новые дополнительные символы (добавьте свои)
  var
    i: Integer;
  begin
   Result := s;

   // Сначала заменяем старые запрещённые символы
   for i := 1 to Length(BadChars1) do
     Result := StringReplace(Result, BadChars1[i], '_', [rfReplaceAll]);

   // Потом — новые дополнительные
   {for i := 1 to Length(BadChars2) do
     Result := StringReplace(Result, BadChars2[i], '_', [rfReplaceAll]);}

   Result := StringReplace(Result, Char($00B3), '#U00b3', [rfReplaceAll]);
   Result := StringReplace(Result, Char($00E9), 'e', [rfReplaceAll]);
   Result := StringReplace(Result, Char($00E0), 'a', [rfReplaceAll]);
   Result := StringReplace(Result, Char($00FF), 'y', [rfReplaceAll]);
   {for i := 1 to Length(Result) do
    if Result[i] in ['?', ':'] then Result[i] := '_';}
  end;

  function IsValidMatch(const FileName, BaseName: string): Boolean;
  var
    NextChar: Char;
  begin
    // Точное совпадение
    if SameText(FileName, BaseName) then
      Exit(True);

    // Совпадение с дефисом и номером (например, Caesar-00)
    if StartsText(BaseName + '-', FileName) then
      Exit(True);

    // Совпадение с годом в скобках (например, Caesar(1998))
    if StartsText(BaseName + '(', FileName) then
      Exit(True);

    // Совпадение с годом и пробелом (например, Caesar (1998))
    if StartsText(BaseName + ' (', FileName) then
      Exit(True);

    // Если имя файла длиннее базового имени
    if Length(FileName) > Length(BaseName) then
    begin
      // Проверяем, что начинается с BaseName
      if StartsText(BaseName, FileName) then
      begin
        NextChar := FileName[Length(BaseName) + 1];
        // Следующий символ НЕ должен быть буквой или цифрой
        // (это означало бы продолжение имени, как в "Caesar II")
        if CharInSet(NextChar, ['A'..'Z', 'a'..'z', '0'..'9']) then
          Exit(False);
      end;
    end;

    Result := False;
  end;

  function MatchForcedPlainName(const FileName, ForcedName: string): Boolean;
  begin
    Result := SameText(FileName, ForcedName);
  end;

  function MatchForcedNumberedName(const FileName, ForcedName: string): Boolean;
  var
    i: Integer;
    Num: string;
  begin
    for i := 0 to 20 do
    begin
      Num := Format('%.2d', [i]); // 00 .. 20
      if SameText(FileName, ForcedName + '-' + Num) then
        Exit(True);
    end;
    Result := False;
  end;

  // Внутренняя функция для добавления файлов из одного набора
  procedure TryAddFromFolder(const BaseFolder: string; MaxWanted: Integer = MaxInt);
  var
    j, added: Integer;
  begin
    SearchPath := IncludeTrailingPathDelimiter(PlatformDir) + BaseFolder;
    if not TDirectory.Exists(SearchPath) then Exit;

    Files := TDirectory.GetFiles(SearchPath, '*.*', TSearchOption.soAllDirectories);
    added := 0;

    for j := 0 to High(Files) do
    begin
      if ImgList.Count >= MaxWanted then Break;

      FilePath := Files[j];
      FileName := OneLine(TPath.GetFileNameWithoutExtension(FilePath));

      if ForcedBaseName <> '' then
      begin
        if SameText(FileName, ForcedBaseName) or
           StartsText(ForcedBaseName + '-', FileName) or
           MatchForcedNumberedName(FileName, ForcedBaseName) then
        begin
          if ImgList.IndexOf(FilePath) = -1 then
          begin
            ImgList.Add(FilePath);
            Inc(added);
          end;
        end;
      end
      else
      begin
        if IsValidMatch(FileName, BaseNameNoYear) or
           ((BaseNameWithYear <> '') and IsValidMatch(FileName, BaseNameWithYear)) or
           ((BaseNameWithYearNoSpace <> '') and IsValidMatch(FileName, BaseNameWithYearNoSpace)) then
        begin
          if ImgList.IndexOf(FilePath) = -1 then
          begin
            ImgList.Add(FilePath);
            Inc(added);
          end;
        end;
      end;
    end;
  end;

begin
  ImgList.Clear;
  ScreenShotImage.Picture := nil;
  NextImgBtn.Enabled := False;
  PrevImgBtn.Enabled := False;
  ImgCurIndex := -1;

  if (SourcePath = nil) or (SourcePath.Selected = nil) then Exit;

  Platform2 := SourcePath.Selected.SubItems[1];  // Platforms
  PlatformDir := IncludeTrailingPathDelimiter(LaunchBoxDir) + 'Images\' + Platform2;

  if not TDirectory.Exists(PlatformDir) then Exit;

  Year := GetYear(SourcePath.Selected.SubItems[2]);

  BaseNameNoYear := OneLine(SourcePath.Selected.Caption);
  BaseNameWithYear := '';
  BaseNameWithYearNoSpace := '';

  if Year <> '' then
  begin
    BaseNameWithYear := OneLine(SourcePath.Selected.Caption + ' (' + Year + ')');
    BaseNameWithYearNoSpace := OneLine(SourcePath.Selected.Caption + '(' + Year + ')');
  end;

  // ───────────────────────────────────────────────
  // 1. Сначала приоритетные папки — в строгом порядке
  // ───────────────────────────────────────────────
  PriorityFolders := [
    'Screenshot - Gameplay',
    'Screenshot - Game Title',
    'Disc',
    'Box - Front',
    'Box - Back'
  ];

  for Folder in PriorityFolders do
    TryAddFromFolder(Folder, 9999);   // лимит высокий, чтобы взять все подходящие

  // ───────────────────────────────────────────────
  // 2. Если почти ничего не нашли — ищем по всей остальной структуре
  // ───────────────────────────────────────────────
  if ImgList.Count < 2 then   // например, если нашли 0 или только 1 картинку
  begin
    // Полный рекурсивный поиск по всей платформе, исключая уже проверенные папки
    var AllFiles := TDirectory.GetFiles(PlatformDir, '*.*', TSearchOption.soAllDirectories);

    for FilePath in AllFiles do
    begin
      // Пропускаем файлы из уже обработанных приоритетных папок
      var InPriority := False;
      for Folder in PriorityFolders do
        if Pos(IncludeTrailingPathDelimiter(Folder), FilePath) > 0 then
        begin
          InPriority := True;
          Break;
        end;

      if InPriority then Continue;

      FileName := OneLine(TPath.GetFileNameWithoutExtension(FilePath));

      if ForcedBaseName <> '' then
      begin
        if SameText(FileName, ForcedBaseName) or
           StartsText(ForcedBaseName + '-', FileName) or
           MatchForcedNumberedName(FileName, ForcedBaseName) then
          if ImgList.IndexOf(FilePath) = -1 then
            ImgList.Add(FilePath);
      end
      else
      begin
        if IsValidMatch(FileName, BaseNameNoYear) or
           ((BaseNameWithYear <> '') and IsValidMatch(FileName, BaseNameWithYear)) or
           ((BaseNameWithYearNoSpace <> '') and IsValidMatch(FileName, BaseNameWithYearNoSpace)) then
          if ImgList.IndexOf(FilePath) = -1 then
            ImgList.Add(FilePath);
      end;
    end;
  end;

  // ───────────────────────────────────────────────
  // Показываем первое изображение, если что-то нашли
  // ───────────────────────────────────────────────
  if ImgList.Count > 0 then
  begin
    try
      TempWIC.LoadFromFile(ImgList[0]);
      ScreenShotImage.Picture.Assign(TempWIC);
      ImgCurIndex := 0;
    except
      // silent fail или можно поставить placeholder
    end;

    NextImgBtn.Enabled := ImgList.Count > 1;
    PrevImgBtn.Enabled := ImgList.Count > 1;
  end;
end;

procedure TMainForm.InitializeComboBoxes;
var
  i, j: Integer;
  Items: TStringList;
  Platforms: TStringList;
  GameGenres, GameSeries: TStringDynArray;
begin
  Items := TStringList.Create;
  Platforms := TStringList.Create;
  try
    Items.Sorted := True;          // Автоматическая сортировка
    Items.Duplicates := dupIgnore; // Без дубликатов

    // Временный список для сортировки платформ
    Platforms.Sorted := True;
    Platforms.Duplicates := dupIgnore;

    for i := 0 to High(FGameData) do
    begin
      // Собираем платформы (кроме специальных)
      if (FGameData[i].Platforms <> '') and
         (FGameData[i].Platforms <> 'All') and
         (FGameData[i].Platforms <> 'Installed') and
         (Platforms.IndexOf(FGameData[i].Platforms) = -1) then
        Platforms.Add(FGameData[i].Platforms);

      // Жанры
      if FGameData[i].Genre <> '' then
      begin
        GameGenres := FGameData[i].Genre.Split([';', '/']);
        for j := 0 to High(GameGenres) do
        begin
          GameGenres[j] := Trim(GameGenres[j]);
          if (GameGenres[j] <> '') and (Items.IndexOf(GameGenres[j]) = -1) then
            Items.Add('[Genre] ' + GameGenres[j]);
        end;
      end;

      // Серии — добавляем с префиксом [Series] для отличия
      if FGameData[i].Series <> '' then
      begin
        GameSeries := FGameData[i].Series.Split([';', '/']);
        for j := 0 to High(GameSeries) do
        begin
          GameSeries[j] := Trim(GameSeries[j]);
          if GameSeries[j] <> '' then
            Items.Add('[Series] ' + GameSeries[j]);
        end;
      end;
    end;

    ComboBox1.Items.Assign(Items);
    ComboBox1.Items.Insert(0, 'All Genres/Series');
    ComboBox1.ItemIndex := 0;

    // Формируем список вкладок с правильным порядком
    TabControl1.Tabs.Clear;
    TabControl1.Tabs.Add('All');  // Первая вкладка
    TabControl1.Tabs.Add('Installed');      // Вторая вкладка

    // Добавляем остальные отсортированные платформы
    for i := 0 to Platforms.Count - 1 do
      TabControl1.Tabs.Add(Platforms[i]);

    TabControl1.TabIndex := 0;
  finally
    Items.Free;
    Platforms.Free;
  end;
end;

procedure TMainForm.FinalizeLoading;
var
  PlatformsDir: string;
  XMLFiles: TStringDynArray;
begin
  PlatformsDir := LaunchBoxDir + '\Data\Platforms\';

  // === НЕТ ПАПКИ ===
  if not TDirectory.Exists(PlatformsDir) then
  begin
    TrayIcon.Icon := Application.Icon;
    MainForm.Icon := Application.Icon;
    Caption := 'Folder not found';
    TrayIcon.Hint := Caption;
    Exit;
  end;

  // === НЕТ XML ФАЙЛОВ ===
  XMLFiles := TDirectory.GetFiles(PlatformsDir, '*.xml',
                                 TSearchOption.soTopDirectoryOnly);
  if Length(XMLFiles) = 0 then
  begin
    TrayIcon.Icon := Application.Icon;
    MainForm.Icon := Application.Icon;
    Caption := 'No XML files';
    TrayIcon.Hint := Caption;
    Exit;
  end;

  // ====== СТАРАЯ ЛОГИКА ======
  FClosing := False;
  FLoadingComplete := False;
  Caption := 'Loading...';
  TrayIcon.Hint := Caption;

  FLoaderThread := TThread.CreateAnonymousThread(
    procedure
    begin
      CoInitialize(nil);
      try
        if TThread.CurrentThread.CheckTerminated or FClosing then Exit;

        ScanXMLFromDir(PlatformsDir);

        if TThread.CurrentThread.CheckTerminated or FClosing then Exit;

        Edit1.Enabled := True;
        ComboBox1.Enabled := True;
        ScrollBox1.Enabled := True;
        NextImgBtn.Enabled := True;
        TrayIcon.Icon := Application.Icon;
        MainForm.Icon := Application.Icon;

        TThread.Queue(nil,
          procedure
          begin
            InitializeComboBoxes;
            FLoadingComplete := True;
            ListView1.Items.Count := Length(FFilteredIndices);
            ListView1.Invalidate;
            ListView1.Refresh;
            Caption := 'Total Games: ' + IntToStr(Length(FGameData));
            TrayIcon.Hint := Caption;
          end
        );
      finally
        CoUninitialize;
      end;
    end
  );

  FLoaderThread.FreeOnTerminate := False;
  FLoaderThread.Start;
end;

procedure TMainForm.ApplyFilters;
var
  i, j, Count: Integer;
  Filtered: TArray<Integer>;
  SelectedGenre, SelectedPlatform: string;
  GameGenres: TStringDynArray;
  GenreMatch: Boolean;
  SelectedGenreClean: string;
  GameSeries: TStringDynArray;
begin
  if not FLoadingComplete then Exit;

  SelectedGenre := ComboBox1.Text;
  SelectedPlatform := TabControl1.Tabs[TabControl1.TabIndex];

  Count := 0;
  SetLength(Filtered, Length(FGameData));

  for i := 0 to High(FGameData) do
  begin
    { === INSTALLED === }
    if SameText(SelectedPlatform, 'Installed') then
    begin
      if not IsGameInstalled(FGameData[i]) then
        Continue;
    end
    { === PLATFORM === }
    else if (SelectedPlatform <> 'All') and
            (not SameText(FGameData[i].Platforms, SelectedPlatform)) then
      Continue;

    { === GENRE === }
    if SelectedGenre <> 'All Genres/Series' then
    begin
      GenreMatch := False;
      SelectedGenreClean := SelectedGenre;

      if StartsText('[Genre] ', SelectedGenreClean) then
        Delete(SelectedGenreClean, 1, Length('[Genre] '))
      else
      if StartsText('[Series] ', SelectedGenreClean) then
        Delete(SelectedGenreClean, 1, Length('[Series] '));

      GameGenres := FGameData[i].Genre.Split([';', '/']);
      for j := 0 to High(GameGenres) do
        if SameText(Trim(GameGenres[j]), SelectedGenreClean) then
        begin
          GenreMatch := True;
          Break;
        end;

      if not GenreMatch then
      begin
        GameSeries := FGameData[i].Series.Split([';', '/']);
        for j := 0 to High(GameSeries) do
          if SameText(Trim(GameSeries[j]), SelectedGenreClean) then
          begin
            GenreMatch := True;
            Break;
          end;
      end;

      if not GenreMatch then
        Continue;
    end;

    { === SEARCH === }
    if (FSearchText <> '') and
       (Pos(LowerCase(FSearchText), LowerCase(FGameData[i].GameName)) = 0) then
      Continue;

    Filtered[Count] := i;
    Inc(Count);
  end;

  SetLength(Filtered, Count);
  FFilteredIndices := Filtered;

  ListView1.Items.Count := Length(FFilteredIndices);
  ListView1.Invalidate;

  Caption := 'Total Games: ' + IntToStr(Length(FFilteredIndices));
  TrayIcon.Hint := Caption;

  ClearGameInfo;
end;

procedure TMainForm.SortGameData;
procedure QuickSort(L, R: Integer);
  var
    I, J: Integer;
    P: string;
    T: TGameData;
  begin
    repeat
      I := L;
      J := R;
      P := FGameData[(L + R) shr 1].GameName;

      repeat
        while CompareText(FGameData[I].GameName, P) < 0 do Inc(I);
        while CompareText(FGameData[J].GameName, P) > 0 do Dec(J);

        if I <= J then
        begin
          if I <> J then
          begin
            T := FGameData[I];
            FGameData[I] := FGameData[J];
            FGameData[J] := T;
          end;
          Inc(I);
          Dec(J);
        end;
      until I > J;

      if L < J then QuickSort(L, J);
      L := I;
    until I >= R;
  end;

begin
  if Length(FGameData) > 1 then
    QuickSort(0, High(FGameData));
end;

procedure TMainForm.UpdateGenreSeriesComboForCurrentPlatform;
var
  i, j: Integer;
  GenresSeries: TStringList;
  SelectedPlatform: string;
  GameGenres, GameSeries: TStringDynArray;
  IsInstalledTab: Boolean;
begin
  if not FLoadingComplete then Exit;

  SelectedPlatform := TabControl1.Tabs[TabControl1.TabIndex];
  IsInstalledTab := SameText(SelectedPlatform, 'Installed');

  GenresSeries := TStringList.Create;
  try
    GenresSeries.Sorted := True;
    GenresSeries.Duplicates := dupIgnore;

    for i := 0 to High(FGameData) do
    begin
      // Если это вкладка Installed — игнорируем платформу, но проверяем установку
      if IsInstalledTab then
      begin
        if not IsGameInstalled(FGameData[i]) then
          Continue;
      end
      else
      // Обычные платформы — фильтруем по совпадению платформы
      if not ((SelectedPlatform = 'All') or
              SameText(FGameData[i].Platforms, SelectedPlatform)) then
        Continue;

      // Добавляем жанры
      if FGameData[i].Genre <> '' then
      begin
        GameGenres := FGameData[i].Genre.Split([';', '/']);
        for j := 0 to High(GameGenres) do
        begin
          GameGenres[j] := Trim(GameGenres[j]);
          if (GameGenres[j] <> '') and (GenresSeries.IndexOf(GameGenres[j]) = -1) then
            GenresSeries.Add('[Genre] ' + GameGenres[j]);
        end;
      end;

      // Добавляем серии с префиксом [Series]
      if FGameData[i].Series <> '' then
      begin
        GameSeries := FGameData[i].Series.Split([';', '/']);
        for j := 0 to High(GameSeries) do
        begin
          GameSeries[j] := Trim(GameSeries[j]);
          if (GameSeries[j] <> '') and
             (GenresSeries.IndexOf('[Series] ' + GameSeries[j]) = -1) then
            GenresSeries.Add('[Series] ' + GameSeries[j]);
        end;
      end;
    end;

    // Обновляем ComboBox
    ComboBox1.Items.BeginUpdate;
    try
      ComboBox1.Items.Clear;
      ComboBox1.Items.Add('All Genres/Series');
      ComboBox1.Items.AddStrings(GenresSeries);
    finally
      ComboBox1.Items.EndUpdate;
    end;

    ComboBox1.ItemIndex := 0;

  finally
    GenresSeries.Free;
  end;
end;

procedure TMainForm.ShowGameByIndex(const ItemIndex: Integer);
var
  RealIndex: Integer;
  ForceImgName: String;
begin
  if ItemIndex < 0 then Exit;
  if ItemIndex >= Length(FFilteredIndices) then Exit;

  RealIndex := FFilteredIndices[ItemIndex];
  if (RealIndex < 0) or (RealIndex >= Length(FGameData)) then Exit;

  // ===== ТЕКСТ =====
  TitleLabel.Caption := FGameData[RealIndex].GameName;
  DeveloperLabel.Caption := 'Developer: ' + FGameData[RealIndex].Developer;
  PlatformLabel.Caption := 'Platform: ' + FGameData[RealIndex].Platforms;
  ReleaseLabel.Caption := 'Release date: ' + GetYear(FGameData[RealIndex].ReleaseDate);
  PublisherLabel.Caption := 'Publisher: ' + FGameData[RealIndex].Publisher;
  GenreLabel.Caption := 'Genre: ' + FGameData[RealIndex].Genre;
  SeriesLabel.Caption := 'Series: ' + FGameData[RealIndex].Series;
  Label1.Caption := FGameData[RealIndex].Notes;
  ResizeLabelToText(Label1);

  // ===== RUN CAPTION =====
  if IsGameInstalled(FGameData[RealIndex]) then
  Run1.Caption := 'Run' else Run1.Caption := 'Install';

  // ===== MANUAL =====
  Manual1.Enabled :=
    FileExists(LaunchBoxDir + '\' + FGameData[RealIndex].Manual);

  // ===== ConfigurationPath =====
  if FGameData[RealIndex].ConfigurationPath = '' then
    Configuration1.Enabled := False
   else
    begin
     //Если игра не установлена нажатие недоступно.
     Configuration1.Enabled := IsGameInstalled(FGameData[RealIndex]);
    end;

  // ===== IMAGES =====
  if not NConfig.ValueExists(FGameData[RealIndex].Platforms, FGameData[RealIndex].GameName) then
   ForceImgName := ''
  else
   ForceImgName := NConfig.ReadString(FGameData[RealIndex].Platforms,
     FGameData[RealIndex].GameName, '');
  AddImagesToList(
    LaunchBoxDir + '\Images\' + FGameData[RealIndex].Platforms,
    ListView1, ForceImgName);

  // ===== EXTRAS =====
  UpdateExtrasMenu(RealIndex);
end;

procedure TMainForm.LoadXMLToArray(const XMLFileName: string);
var
  XML: IXMLDocument;
  Nodes: IXMLNodeList;
  Node, Child: IXMLNode;
  G: TGameData;
  i, j: Integer;
  NodeName: string;
begin
  XML := TXMLDocument.Create(nil);
  try
    XML.Options := [];
    XML.ParseOptions := [];
    XML.LoadFromFile(XMLFileName);
    XML.Active := True;

    if XML.DocumentElement = nil then Exit;
    Nodes := XML.DocumentElement.ChildNodes;

    for i := 0 to Nodes.Count - 1 do
    begin
      Node := Nodes[i];
      if Node.NodeName <> 'Game' then Continue;

      FillChar(G, SizeOf(G), 0);

      // Кэшируем LocalName для ускорения
      for j := 0 to Node.ChildNodes.Count - 1 do
      begin
        Child := Node.ChildNodes[j];
        NodeName := Child.LocalName;

        case IndexStr(NodeName, ['Title', 'ApplicationPath', 'Platform',
                                  'Developer', 'Publisher', 'Genre', 'Series',
                                  'ReleaseDate', 'Notes', 'ManualPath',
                                  'ConfigurationPath', 'RootFolder']) of
          0: G.GameName := Child.Text;
          1: G.ApplicationPath := Child.Text;
          2: G.Platforms := Child.Text;
          3: G.Developer := Child.Text;
          4: G.Publisher := Child.Text;
          5: G.Genre := Child.Text;
          6: G.Series := Child.Text;
          7: G.ReleaseDate := Copy(Child.Text, 1, 10);
          8: G.Notes := Child.Text;
          9: G.Manual := Child.Text;
          10: G.ConfigurationPath := Child.Text;
          11: G.RootFolder := Child.Text;
        end;
      end;

      AddGameToArray(G);
    end;
  finally
    XML := nil;
  end;
end;

procedure TMainForm.ScanXMLFromDir(const Dir: string);
var
  Files: TStringDynArray;
  I: Integer;
  UpdateInterval: Integer;
  LastUpdate: Cardinal;
begin
  FActualGameCount := 0;
  SetLength(FGameData, 500); // Увеличен начальный размер

  Files := TDirectory.GetFiles(Dir, '*.xml', TSearchOption.soTopDirectoryOnly);

  // Обновляем UI не чаще раза в 200мс
  UpdateInterval := Max(10, Length(Files) div 20);
  LastUpdate := GetTickCount;

  for I := 0 to High(Files) do
  begin
    if TThread.CurrentThread.CheckTerminated or FClosing then Exit;
    LoadXMLToArray(Files[I]);

    // Обновляем только если прошло 200мс
    if (GetTickCount - LastUpdate > 200) or (I = High(Files)) then
    begin
      LastUpdate := GetTickCount;
      TThread.Synchronize(nil, procedure
      begin
        Caption := Format('Loading... %d%%', [((I + 1) * 100) div Length(Files)]);
        TrayIcon.Hint := Caption;
      end);
    end;
  end;

  SetLength(FGameData, FActualGameCount);

  if Length(FGameData) > 1 then
    SortGameData;

  SetLength(FFilteredIndices, Length(FGameData));
  for I := 0 to High(FGameData) do
    FFilteredIndices[I] := I;
end;

procedure TMainForm.FreeImageCache;
var
  sl: TStringList;
begin
  if Assigned(FImageCache) then
  begin
    for sl in FImageCache.Values do
      sl.Free;
    FImageCache.Free;
    FImageCache := nil;
  end;
end;

procedure TMainForm.BuildImageCache;
var
  PlatformsDir, ImagesRoot: string;
  Platforms: TStringDynArray;
  Platform: string;
  FileList: TStringList;
  Folders: TArray<string>;
  Folder: string;
  Files: TStringDynArray;
  FullPath: string;
begin
  if FCacheBuilt then Exit;

  FImageCache := TDictionary<string, TStringList>.Create;
  ImagesRoot := IncludeTrailingPathDelimiter(LaunchBoxDir) + 'Images\';

  // Можно взять платформы из TabControl или из папок
  Platforms := TDirectory.GetDirectories(ImagesRoot);

  Folders := [
    'Screenshot - Gameplay',
    'Screenshot - Game Title',
    'Disc',
    'Box - Front',
    'Box - Back'
  // + другие папки, если используешь
  ];

  //Caption := 'Building image cache...';
  //Application.ProcessMessages;

  try
    for var PlatDir in Platforms do
    begin
      Platform := ExtractFileName(PlatDir);
      if not TDirectory.Exists(PlatDir) then Continue;

      FileList := TStringList.Create;
      FileList.Sorted := True;        // полезно для быстрого поиска
      FileList.Duplicates := dupIgnore;

      for Folder in Folders do
      begin
        var SearchPath := IncludeTrailingPathDelimiter(PlatDir) + Folder;
        if not TDirectory.Exists(SearchPath) then Continue;

        Files := TDirectory.GetFiles(SearchPath, '*.*', TSearchOption.soAllDirectories);
        for FullPath in Files do
          FileList.Add(FullPath);
      end;

      // Если нашли файлы — сохраняем
      if FileList.Count > 0 then
        FImageCache.Add(Platform, FileList)
      else
        FileList.Free;
    end;

    FCacheBuilt := True;
  finally
    //Caption := 'Total Games: ' + IntToStr(Length(FGameData));
  end;
end;

procedure TMainForm.RunCacheImages;
begin
  // Запускаем кэш с небольшой задержкой
  TThread.CreateAnonymousThread(
    procedure
    var
      CacheThread: TThread;
    begin
      try
        Sleep(1500);  // или 2000, если хотите ещё больше надёжности

        if TThread.CheckTerminated or FClosing then Exit;

        // Дополнительная защита
        if not Assigned(MainForm) or (MainForm = nil) then Exit;

        FinalizeLoading;
        BuildImageCache;

      except
        on E: Exception do
        begin
          // Можно логировать в файл, но НЕ пытаться показывать MessageBox из фона!
          // TThread.Queue(nil, procedure begin ShowMessage(E.Message); end); ← НЕ делать так
        end;
      end;
    end
  ).Start;
end;

//----CONFIG----
//------------------------------------------------------------------------------
function TMainForm.GetFConfig: TMemIniFile;
var
 AppName: String;
begin
  AppName := ExtractFileName(ChangeFileExt(ParamStr(0),'.ini'));
  SetCurrentDir(ExtractFilePath(Application.ExeName));
  if FConfig = nil then
  FConfig := TMemIniFile.Create(ExtractFilePath(ParamStr(0))+AppName,TEncoding.UTF8);
  Result := FConfig;
end;

function TMainForm.GetNConfig: TMemIniFile;
var
 AppName: String;
begin
  AppName := ExtractFileName(ChangeFileExt(ParamStr(0),''));
  SetCurrentDir(ExtractFilePath(Application.ExeName));
  if NConfig = nil then
  NConfig := TMemIniFile.Create(ExtractFilePath(ParamStr(0))+AppName+'ImgNames.ini',TEncoding.UTF8);
  Result := NConfig;
end;

procedure TMainForm.RegIni(Write: Boolean);
begin
if Write = true then
 begin
  if WindowState = wsNormal then
    FConfig.WriteInteger('SGAllSettings','WindowState', 0) else
  if WindowState = wsMaximized then
    FConfig.WriteInteger('SGAllSettings','WindowState', 1);
  if WindowState = wsNormal then
   begin
    FConfig.WriteInteger('SGAllSettings','Top',Top);
    FConfig.WriteInteger('SGAllSettings','Left',Left);
    FConfig.WriteInteger('SGAllSettings','Width',Width);
    FConfig.WriteInteger('SGAllSettings','Height',Height);
   end;
  if not FConfig.ValueExists('SGAllSettings', 'IgnoreDir') then
     FConfig.WriteString('SGAllSettings', 'IgnoreDir', '');
  FConfig.WriteInteger('SGAllSettings', 'ListViewWidth', Panel3.Width);
  FConfig.WriteInteger('SGAllSettings', 'InfoPanelHeight', ScrollBox1.Height);
  FConfig.UpdateFile;
 end else
 begin
  if FConfig.ReadInteger('SGAllSettings','WindowState', 0) = 1 then
  WindowState := wsMaximized else
  if FConfig.ReadInteger('SGAllSettings','WindowState', 0) = 0 then
   begin
    WindowState := wsNormal;
    Top := FConfig.ReadInteger('SGAllSettings','Top',Top);
    Left := FConfig.ReadInteger('SGAllSettings','Left',Left);
    Width := FConfig.ReadInteger('SGAllSettings','Width',Width);
    Height := FConfig.ReadInteger('SGAllSettings','Height',Height);
  end;
  IgnoreDir := FConfig.ReadString('SGAllSettings', 'IgnoreDir', '');
  HideInTray:= FConfig.ReadBool('SGAllSettings', 'HideInTray', False);
  Hideonstartup1.Checked := FConfig.ReadBool('SGAllSettings', 'HideInTray', False);
  if FConfig.ReadBool('SGAllSettings', 'HideInTray', False) then
  Show1.Caption := 'Show' else Show1.Caption := 'Hide';
  Panel3.Width := FConfig.ReadInteger('SGAllSettings', 'ListViewWidth', MainForm.Width div 3);
  ScrollBox1.Height := FConfig.ReadInteger('SGAllSettings', 'InfoPanelHeight', ScrollBox1.Height);
 end;
end;

//----FORM----
//------------------------------------------------------------------------------
procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
const
  THREAD_TIMEOUT_MS = 5000;  // 5 секунд — достаточно для загрузки XML
var
  WaitResult: Cardinal;
begin
  FClosing := True;

  // Останавливаем и ждём основной поток загрузки
  if Assigned(FLoaderThread) and not FLoaderThread.Finished then
  begin
    FLoaderThread.Terminate;                 // сигнализируем потоку выйти

    WaitResult := FLoaderThread.WaitFor;     // ждём

    // Если таймаут — принудительно убиваем (редко, но безопаснее, чем зависание)
    if WaitResult = WAIT_TIMEOUT then
    begin
      // Опасно, но лучше, чем висеть вечно
      // TerminateThread(FLoaderThread.Handle, 1); // ← только в крайнем случае!
      // Лучше просто логировать и жить дальше
      // Caption := 'Thread timeout on close';
    end;

    FreeAndNil(FLoaderThread);
  end;

  CanClose := True;

  // Освобождение ресурсов
  if Assigned(TempWIC) then FreeAndNil(TempWIC);
  if Assigned(ImgList) then FreeAndNil(ImgList);
  FreeImageCache;

  RegIni(True);

  if Assigned(FConfig) then FreeAndNil(FConfig);
  if Assigned(NConfig) then FreeAndNil(NConfig);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  TempWIC := TWICImage.Create;
  ImgList := TStringList.Create;

  LaunchBoxDir := 'E:\LaunchBox'{GetExecPath};
  GetFConfig;
  GetNConfig;
  RegIni(False);

  MainForm.Icon := LoadIconFromRCDATA('OnLoadIcon');
  TrayIcon.Icon := LoadIconFromRCDATA('OnLoadIcon');
  TrayIcon.Visible := True;
  Application.ShowMainForm := not FConfig.ReadBool('SGAllSettings', 'HideInTray', False);

  RunCacheImages;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key = ORD(VK_F1) then About1Click(Sender);

  //Ctrl+Tab to change tabs
  if (ssCtrl in Shift) and (Ord(Key) = VK_TAB) then
   begin
      if ssShift in Shift then
         if TabControl1.tabIndex > 0 then
            TabControl1.TabIndex := TabControl1.tabIndex - 1
         else
            TabControl1.TabIndex := TabControl1.tabs.Count - 1
         //end if
      else
         if TabControl1.tabIndex < TabControl1.Tabs.Count - 1 then
            TabControl1.TabIndex := TabControl1.tabIndex + 1
         else
            TabControl1.TabIndex := 0;
         //end if
      //end if
      FocusControl(TabControl1);
      TabControl1.OnChange(self);
   end;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  ListView1.Column[0].Width := ListView1.Width - 20;
  Edit1.Width := Panel4.Width div 2 - 6;
  ComboBox1.Left := Edit1.Width + 6;
  ComboBox1.Width := Edit1.Width;
  ResizeLabelToText(Label1);
end;

//----FORM COMPONENTS----
//------------------------------------------------------------------------------

procedure TMainForm.ListView1ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  Item: TListItem;
begin
  Item := (Sender as TListView).GetItemAt(MousePos.X, MousePos.Y);
  if Item = nil then
    Handled := True  // Не показывать меню на пустом месте
  else
    Handled := False; // Показывать меню на элементе
end;

procedure TMainForm.ListView1Data(Sender: TObject; Item: TListItem);
var
  G: TGameData;
  RealIndex: Integer;
begin
  if not FLoadingComplete then Exit;
  if (Item.Index < 0) or (Item.Index >= Length(FFilteredIndices)) then Exit;

  RealIndex := FFilteredIndices[Item.Index];
  if (RealIndex < 0) or (RealIndex >= Length(FGameData)) then Exit;

  G := FGameData[RealIndex];

  Item.Caption := G.GameName;
  Item.SubItems.Clear;
  Item.SubItems.Add(G.ApplicationPath);
  Item.SubItems.Add(G.Platforms);
  Item.SubItems.Add(G.ReleaseDate);
  Item.SubItems.Add(G.Developer);
  Item.SubItems.Add(G.Publisher);
  Item.SubItems.Add(G.Genre);
  Item.SubItems.Add(G.Series);
  Item.SubItems.Add(G.Notes);
  Item.SubItems.Add(G.Manual);
  Item.SubItems.Add(G.ConfigurationPath);
  Item.SubItems.Add(G.RootFolder);
end;

procedure TMainForm.ListView1DblClick(Sender: TObject);
begin
 if ListView1.ItemIndex = -1 then Exit;
  ShellOpen(LaunchBoxDir + '\' + ListView1.Selected.SubItems[0]);
end;

procedure TMainForm.ListView1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
if Key = ORD(VK_RETURN) then ListView1DblClick(Sender);
if Key = ORD(VK_LEFT) then PrevImgBtnClick(Sender);
if Key = ORD(VK_RIGHT) then NextImgBtnClick(Sender);
end;

procedure TMainForm.ListView1KeyPress(Sender: TObject; var Key: Char);
const
  TYPE_TIMEOUT = 800; // мс
var
  I: Integer;
  GameIndex: Integer;
  NowTick: Cardinal;
  SearchText: string;
  ProcessedKey: Char;
begin
  if not FLoadingComplete then Exit;
  if Length(FFilteredIndices) = 0 then Exit;
  // игнорируем управляющие клавиши
  if Key < #32 then Exit;

  ProcessedKey := Key;
  Key := #0; // подавляем стандартную обработку (убирает beep)

  NowTick := GetTickCount;
  // после паузы начинаем новый ввод
  if (NowTick - FLastTypeTick) > TYPE_TIMEOUT then
    FTypeBuffer := '';
  FLastTypeTick := NowTick;
  FTypeBuffer := FTypeBuffer + ProcessedKey;
  SearchText := LowerCase(FTypeBuffer);

  for I := 0 to High(FFilteredIndices) do
  begin
    GameIndex := FFilteredIndices[I];
    if StartsText(SearchText, LowerCase(FGameData[GameIndex].GameName)) then
    begin
      ListView1.ItemIndex := I;
      ListView1.Selected := ListView1.Items[I];
      ListView1.Selected.MakeVisible(False);
      Exit; // найдено — выходим
    end;
  end;

  // если не найдено — просто откатываем последний символ
  Delete(FTypeBuffer, Length(FTypeBuffer), 1);
end;

procedure TMainForm.ListView1SelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
 if Selected then
  ShowGameByIndex(Item.Index) else ClearGameInfo;
end;

procedure TMainForm.TabControl1Change(Sender: TObject);
begin
  if not FLoadingComplete then Exit;

  ClearGameInfo;

  // Обновляем список жанров/серий под текущую платформу
  UpdateGenreSeriesComboForCurrentPlatform;

  // Применяем фильтры (с учётом новой платформы и сброшенного жанра)
  ApplyFilters;

  ActiveControl := ListView1;

  // Выделяем первую игру
  if ListView1.Items.Count > 0 then
  begin
    ListView1.ItemIndex := 0;
    ListView1.Selected := ListView1.Items[0];
    ListView1.Selected.MakeVisible(False);
  end;
end;

procedure TMainForm.TrayIconClick(Sender: TObject);
begin
if Visible then
  begin
   Hide;
   Show1.Caption := 'Show';
  end
  else
  begin
    Show;
    Application.BringToFront;
    SetForegroundWindow(Handle);
    Show1.Caption := 'Hide';
  end;
end;

procedure TMainForm.ScreenShotImageClick(Sender: TObject);
begin
if ListView1.ItemIndex = -1 then Exit;
with FullScreenForm do
 begin
  Label1.Caption := ListView1.Selected.Caption;
  FullScreenImage.Picture.WICImage := (Sender as TImage).Picture.WICImage;
  if (Sender as TImage).Picture.WICImage.Empty <> True then
  Show;
 end;
end;

procedure TMainForm.ComboBox1Change(Sender: TObject);
begin
  ApplyFilters;
end;

procedure TMainForm.Edit1Change(Sender: TObject);
begin
  FSearchText := Edit1.Text;
  ApplyFilters;
end;

procedure TMainForm.Hideonstartup1Click(Sender: TObject);
begin
  with Sender as TMenuItem do
   begin
    Checked := not Checked;
    FConfig.WriteBool('SGAllSettings', 'HideInTray', Checked);
    FConfig.UpdateFile;
   end;
end;

procedure TMainForm.Specifyfolder1Click(Sender: TObject);
begin
  with DiagForm do
   begin
    Caption := 'Specify folder';
    Position := poDesktopCenter;
    ActiveControl := Edit1;
    Label2.Caption := 'You must restart the application for the changes to take effect.';
    Button3.Hint := 'Select a dir';
    ifFile := False;
    Edit1.Text := FConfig.ReadString('SGAllSettings', 'IgnoreDir', '');
    DialogDir := LaunchBoxDir + '\eXo\';
     if (Showmodal <> mrCancel) then
      begin
       FConfig.WriteString('SGAllSettings', 'IgnoreDir', Edit1.Text);
       FConfig.UpdateFile;
      end;
   end;
end;

procedure TMainForm.About1Click(Sender: TObject);
begin
with HelpForm do
   begin
     Position := poDesktopCenter;
     Label2.Caption := 'ReleaseDate: ' + sReleaseDate;
     HELPFORM_PAGECTRL1.ActivePageIndex := 0;
     Show;
   end;
end;

procedure TMainForm.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.OnExtrasMenuItemClick(Sender: TObject);
var
  MenuItem: TMenuItem;
  FullPath: string;
begin
  if Sender is TMenuItem then
  begin
    MenuItem := TMenuItem(Sender);
    FullPath := MenuItem.Hint;

    if FileExists(FullPath) then
    begin
      ShellExecute(0, 'open', PChar(FullPath), nil,
                   PChar(ExtractFilePath(FullPath)), SW_SHOWNORMAL);
    end
    else
    begin
      ShowMessage('File not found: ' + FullPath);
    end;
  end;
end;

procedure TMainForm.Run1Click(Sender: TObject);
begin
  ListView1DblClick(Sender);
end;

procedure TMainForm.Configuration1Click(Sender: TObject);
var
  PathGame: String;
begin
 if ListView1.ItemIndex <> -1 then
  begin
   PathGame := LaunchBoxDir +'\'+ListView1.Selected.SubItems[9];
   ShellExecute(0, 'open', PChar(PathGame), nil,
                   PChar(ExtractFilePath(PathGame)), SW_SHOWNORMAL);
  end;
end;

procedure TMainForm.Manual1Click(Sender: TObject);
var
  PathGame: String;
begin
 if ListView1.ItemIndex <> -1 then
  begin
   PathGame := LaunchBoxDir +'\'+ListView1.Selected.SubItems[8];
   ShellExecute(0, 'open', PChar(PathGame), nil,
                   PChar(ExtractFilePath(PathGame)), SW_SHOWNORMAL);
  end;
end;

procedure TMainForm.Customimagename1Click(Sender: TObject);
begin
  with DiagForm do
   begin
    Caption := ListView1.Items[ListView1.ItemIndex].Caption;
    Position := poDesktopCenter;
    ActiveControl := Edit1;
    Label2.Caption := 'Example: Tomb Raider Gold-01.jpg > Tomb Raider Gold';
    Button3.Hint := 'Select an image';
    ifFile := True;
    Edit1.Text := NConfig.ReadString(ListView1.Items[ListView1.ItemIndex].SubItems[1],
      ListView1.Items[ListView1.ItemIndex].Caption, '');
    DialogDir := LaunchBoxDir + '\Images\' + ListView1.Items[ListView1.ItemIndex].SubItems[1];
     if (Showmodal <> mrCancel) then
      begin
       if Edit1.Text = '' then
       NConfig.DeleteKey(ListView1.Items[ListView1.ItemIndex].SubItems[1],
         ListView1.Items[ListView1.ItemIndex].Caption)
       else
       NConfig.WriteString(ListView1.Items[ListView1.ItemIndex].SubItems[1],
         ListView1.Items[ListView1.ItemIndex].Caption, Edit1.Text);
       NConfig.UpdateFile;
      end;
   end;
end;

procedure TMainForm.DesktopShortcut1Click(Sender: TObject);
begin
  CreateDesktopShellLink(LaunchBoxDir +'\'+ ListView1.Selected.SubItems[0],
    ListView1.Selected.Caption);
end;

procedure TMainForm.PrevImgBtnClick(Sender: TObject);
begin
  if ImgList.Count = 0 then Exit;

  // сдвиг назад с учётом зацикливания
  ImgCurIndex := ImgCurIndex - 1;
  if ImgCurIndex < 0 then
    ImgCurIndex := ImgList.Count - 1;

  TempWIC.LoadFromFile(ImgList[ImgCurIndex]);
  ScreenShotImage.Picture.Assign(TempWIC);
end;

procedure TMainForm.NextImgBtnClick(Sender: TObject);
begin
  if ImgList.Count = 0 then Exit;

  ImgCurIndex := (ImgCurIndex + 1) mod ImgList.Count;
  TempWIC.LoadFromFile(ImgList[ImgCurIndex]);
  ScreenShotImage.Picture.Assign(TempWIC);
end;

end.
