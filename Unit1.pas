unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Types,
  System.IOUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons, Vcl.Imaging.jpeg, Vcl.Imaging.pngimage,
  Vcl.Imaging.GIFImg, Xml.XMLIntf, Xml.XMLDoc, Math, ActiveX, ComObj, ShellAPI,
  IniFiles, Vcl.Menus, ShlObj, Vcl.ImgList, StrUtils, System.Generics.Collections,
  System.ImageList, Vcl.ToolWin, Vcl.Themes, System.TypInfo, SyncObjs, PsAPI,
  System.Generics.Defaults;

const
  sReleaseDate = '30.04.2026';

type
  TGameData = record
    GameName: string;
    ApplicationPath: string;
    Platforms: string;
    ReleaseYear: SmallInt;
    Developer: string;
    Publisher: string;
    Genre: string;
    Series: string;
    Notes: string;
    Manual: string;
    ConfigurationPath: string;
    RootFolder: string;
    ID: string;
    IsInstalled: Boolean;
  end;

type
  TSGLMainForm = class(TForm)
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
    Specifyfolders1: TMenuItem;
    About1: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    DesktopShortcut1: TMenuItem;
    ToolBar1: TToolBar;
    ImageList1: TImageList;
    ShowToolBar: TMenuItem;
    ToolBarMenu1: TMenuItem;
    AlignToolBar1: TMenuItem;
    ToolBarLeft1: TMenuItem;
    ToolBarBottom1: TMenuItem;
    ToolBarTop1: TMenuItem;
    ToolBarRight1: TMenuItem;
    StyleMenu1: TMenuItem;
    Autostart1: TMenuItem;
    Specifylanguagefolders1: TMenuItem;
    EmptyWorkingSet1: TMenuItem;
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
    procedure Specifyfolders1Click(Sender: TObject);
    procedure ListView1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure About1Click(Sender: TObject);
    procedure DesktopShortcut1Click(Sender: TObject);
    procedure ToolBar1Click(Sender: TObject);
    procedure ShowToolBarClick(Sender: TObject);
    procedure ToolBarTop1Click(Sender: TObject);
    procedure Autostart1Click(Sender: TObject);
    procedure Specifylanguagefolders1Click(Sender: TObject);
    procedure EmptyWorkingSet1Click(Sender: TObject);
  private
    NConfig: TMemIniFile;
    FClosing: Boolean;
    FMsgShow: UINT; // Для Mutex
    // XML
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
    FIgnoredFolders: TStringList;
    // Переключение вкладок
    FTabChangeLock: TCriticalSection;
    FIsChangingTab: Boolean;
    FPendingTabIndex: Integer;
    FTabChangeTimer: TTimer;
    // Многопоточная загрузка XML-файлов
    FGameDataLock: TCriticalSection;           // Защита массива FGameData
    FLoadedGamesCount: Integer;                // Счётчик загруженных игр (атомарно)
    FTotalXMLFiles: Integer;                   // Общее количество XML для прогресса
    FGameDict: TDictionary<string, Integer>;
    // Для поиска
    //----------------------
    FTypeBuffer: string;
    FLastTypeTick: Cardinal;
    // Для потоковой загрузки изображений
    //----------------------
    FImageLoadThread: TThread;
    FImageLoadPending: Boolean;        // Флаг, что нужно загрузить изображения
    FImageLoadGameIndex: Integer;      // Индекс игры для загрузки
    FImageLoadRealIndex: Integer;      // Реальный индекс в FGameData
    FImageLoadItemIndex: Integer;      // Индекс в ListView
    FImageLoadLock: TCriticalSection;  // Для синхронизации доступа к данным
    FImageGeneration: Integer;         // счётчик поколений
    //----------------------
    procedure AddGameToArray(const G: TGameData);
    procedure SortGameData;
    procedure ScanXMLFromDir(const Dir: string);
    procedure LoadXMLToArrayThreadSafe(const XMLFileName: string);
    procedure LoadXMLFilesMultiThreaded(const XMLFiles: TStringDynArray);
    procedure RefreshInstalledStatus;
    procedure ApplyFilters;
    procedure BuildGenreSeriesList(const PlatformFilter: string; Target: TStringList);
    procedure FillGenreSeriesCombo(const PlatformFilter: string);
    procedure InitializePlatformTabs;
    procedure FinalizeLoading;
    procedure UpdateExtrasMenu(const GameIndex: Integer);
    procedure ClearGameInfo;
    procedure UpdateGenreSeriesComboForCurrentPlatform;
    procedure ShowGameByIndex(const ItemIndex: Integer);
    procedure LoadImageWithRetry(const FileName: string;
              Image: TImage; MaxRetries: Integer = 1);
    procedure StartImageLoadThread(ItemIndex, RealIndex: Integer);
    procedure FindGameImages(const Platforms, GameName, ReleaseDate, ID,
              ForcedName: string; ImageList: TStringList);
    procedure DoProcessPendingTabChange(Sender: TObject);
    procedure PerformTabChange(NewTabIndex: Integer);
    procedure SetupListViewColumns;
    procedure AutoSizeListViewColumns;
    //----------------------
    function GetFConfig: TMemIniFile;
    function GetNConfig: TMemIniFile;
    procedure RegIni(Write: Boolean);
    procedure OnExtrasMenuItemClick(Sender: TObject);
    procedure StyleMenuClick(Sender: TObject);
    procedure ToolBarMenuClick(Sender: TObject);
    //----------------------
    procedure WMCopyData(var Msg: TWMCopyData); message WM_COPYDATA;
   public
    FConfig: TMemIniFile;
  end;

var
  SGLMainForm: TSGLMainForm;
  LaunchBoxDir: String = '';
  IgnoreDir: String;
  HideInTray: Boolean = False;

implementation

{$R *.dfm}

uses FullScreenImage, DialogForm, Help, ToolBtnProperties, SystemUtils, ToolBars;

// XML
//------------------------------------------------------------------------------
function NormalizeLaunchBoxPath(const RelPath: string;
  IgnoredFolders: TStringList; LanguagesPack: TStringList = nil): string;
var
  Parts: TArray<string>;
  CleanParts: TArray<string>;
  I, C: Integer;
  FolderName: string;
  FoundIgnored: Boolean;
  IgnoredFolderName: string;
  HasLanguages: Boolean;
begin
  Result := '';

  if Trim(RelPath) = '' then Exit;

  // === Быстрая проверка: если LanguagesPack пустой — сразу чистим только игнорируемые папки ===
  HasLanguages := Assigned(LanguagesPack) and (LanguagesPack.Count > 0) and
                  (Trim(LanguagesPack.DelimitedText) <> '');

  Parts := RelPath.Split(['\', '/']);
  SetLength(CleanParts, Length(Parts));
  C := 0;
  FoundIgnored := False;
  IgnoredFolderName := '';

  for I := 0 to High(Parts) do
  begin
    FolderName := Parts[I];
    if FolderName = '' then
    begin
      CleanParts[C] := FolderName;
      Inc(C);
      Continue;
    end;

    // Пропускаем игнорируемые папки (начинающиеся с !)
    if (Length(FolderName) > 0) and (FolderName[1] = '!') and
       (IgnoredFolders.IndexOf(FolderName) >= 0) then
    begin
      FoundIgnored := True;
      IgnoredFolderName := FolderName;
      Continue;
    end;

    CleanParts[C] := FolderName;
    Inc(C);
  end;

  SetLength(CleanParts, C);
  Result := string.Join(PathDelim, CleanParts);

  // Если нет языковых папок или не найдена игнорируемая папка — возвращаем очищенный путь
  if not (FoundIgnored and HasLanguages) then
    Exit;

  // === Только если есть и игнорируемая папка, и языковые варианты — ищем альтернативы ===
  for var LangIdx := 0 to LanguagesPack.Count - 1 do
  begin
    var LangFolder := Trim(LanguagesPack[LangIdx]);
    if LangFolder = '' then Continue;

    var AltParts: TArray<string>;
    SetLength(AltParts, 0);

    for I := 0 to High(Parts) do
    begin
      FolderName := Parts[I];
      if FolderName = IgnoredFolderName then
        AltParts := AltParts + [LangFolder]
      else if FolderName <> '' then
        AltParts := AltParts + [FolderName];
    end;

    var AltPath := string.Join(PathDelim, AltParts);
    var FullAltPath := TPath.GetFullPath(TPath.Combine(LaunchBoxDir, AltPath));

    if TFile.Exists(FullAltPath) or TDirectory.Exists(ExtractFileDir(FullAltPath)) then
    begin
      Result := AltPath;   // Нашли лучший вариант — используем его
      Exit;
    end;
  end;

  // Если ничего не нашли — оставляем основной очищенный путь
end;

function IsGameInstalled(const G: TGameData; LanguagesPack: TStringList = nil): Boolean;
var
  CleanRelPath, FullPath, FullDir: string;
  Paths: TArray<string>;
  I: Integer;
  OwnLP: TStringList;
  ActiveLP: TStringList;  // то, что реально используем
begin
  Result := False;
  if Trim(G.ApplicationPath) = '' then Exit;

  OwnLP := nil;
  ActiveLP := LanguagesPack;  // по умолчанию — то, что передали

  // Если не передали — создаём свой из конфига
  if not Assigned(ActiveLP) then
  begin
    OwnLP := TStringList.Create;
    OwnLP.Delimiter := ';';
    OwnLP.StrictDelimiter := True;
    OwnLP.DelimitedText := SGLMainForm.FConfig.ReadString('SGAllSettings', 'LanguagesPack', '');
    ActiveLP := OwnLP;
  end;

  try
    // Одна ветка вместо двух — NormalizeLaunchBoxPath сама обработает пустой список
    CleanRelPath := NormalizeLaunchBoxPath(G.ApplicationPath,
      SGLMainForm.FIgnoredFolders, ActiveLP);
  finally
    OwnLP.Free;  // nil.Free безопасен, но теперь OwnLP реально может быть создан
  end;

  if CleanRelPath = '' then Exit;

  Paths := CleanRelPath.Split(['|']);
  for I := 0 to High(Paths) do
  begin
    if Trim(Paths[I]) = '' then Continue;
    FullPath := TPath.GetFullPath(TPath.Combine(LaunchBoxDir, Paths[I]));
    FullDir := ExtractFileDir(FullPath);
    if DirectoryExists(FullDir) or FileExists(FullPath) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure TSGLMainForm.AddGameToArray(const G: TGameData);
var
  ExistingIndex: Integer;
begin
  if Trim(G.GameName) = '' then Exit;

  FGameDataLock.Enter;
  try
    if (G.ID <> '') and FGameDict.TryGetValue(G.ID, ExistingIndex) then
    begin
      // Обновляем существующую игру
      if G.ApplicationPath <> '' then FGameData[ExistingIndex].ApplicationPath := G.ApplicationPath;
      if G.Platforms <> '' then FGameData[ExistingIndex].Platforms := G.Platforms;
      if G.ReleaseYear > 0 then FGameData[ExistingIndex].ReleaseYear := G.ReleaseYear;
      if G.Developer <> '' then FGameData[ExistingIndex].Developer := G.Developer;
      if G.Publisher <> '' then FGameData[ExistingIndex].Publisher := G.Publisher;
      if G.Genre <> '' then FGameData[ExistingIndex].Genre := G.Genre;
      if G.Series <> '' then FGameData[ExistingIndex].Series := G.Series;
      if G.Notes <> '' then FGameData[ExistingIndex].Notes := G.Notes;
      if G.Manual <> '' then FGameData[ExistingIndex].Manual := G.Manual;
      if G.ConfigurationPath <> '' then FGameData[ExistingIndex].ConfigurationPath := G.ConfigurationPath;
    end
    else
    begin
      // Добавляем новую игру
      if FActualGameCount >= Length(FGameData) then
        SetLength(FGameData, Length(FGameData) * 2 + 512);

      FGameData[FActualGameCount] := G;
      if G.ID <> '' then
        FGameDict.Add(G.ID, FActualGameCount);
      Inc(FActualGameCount);
    end;
  finally
    FGameDataLock.Leave;
  end;
end;

procedure TSGLMainForm.UpdateExtrasMenu(const GameIndex: Integer);

  // Вспомогательная процедура сортировки
  procedure SortStringArray(var Arr: TStringDynArray);
  begin
    TArray.Sort<string>(Arr,
    TComparer<string>.Construct(
      function(const A, B: string): Integer
      begin
        Result := CompareText(ExtractFileName(A), ExtractFileName(B));
      end
    )
  );
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

  // Функция для преобразования названия папки в название меню
  function GetLanguageCaption(const LangFolder: string): string;
  var
    LangName: string;
  begin
   // Убираем только ведущий '!', если есть
   if (Length(LangFolder) > 0) and (LangFolder[1] = '!') then
     LangName := Copy(LangFolder, 2, MaxInt)
   else
     LangName := LangFolder;

   // Преобразуем первую букву в заглавную
   if Length(LangName) > 0 then
     LangName := UpperCase(LangName[1]) + Copy(LangName, 2, MaxInt);

   Result := LangName;
  end;

  // Процедура добавления языковых extras
  // Процедура добавления языковых extras
procedure AddLanguageExtras(const BasePath, LangFolder: string);
var
  LangMenu: TMenuItem;
  LangPath: string;
  RelativePath: string;
  GameFolder: string;
  PathWithoutGame: string;
  LangCaption: string;
begin
  // Получаем название для меню
  LangCaption := GetLanguageCaption(LangFolder);

  // Получаем относительный путь (убираем последний слеш)
  RelativePath := ExcludeTrailingPathDelimiter(BasePath);

  // Находим папку игры (последний компонент пути)
  GameFolder := ExtractFileName(RelativePath);

  // Получаем путь без папки игры
  PathWithoutGame := ExcludeTrailingPathDelimiter(ExtractFilePath(RelativePath));

  // Строим новый путь - Обратите внимание: НЕ добавляем LaunchBoxDir повторно,
  // так как BasePath уже включает относительный путь от LaunchBoxDir
  LangPath := IncludeTrailingPathDelimiter(LaunchBoxDir) +
              PathWithoutGame + '\' + LangFolder + '\' +
              GameFolder + '\Extras';

  // Для отладки - показываем путь
  // ShowMessage(LangPath);

  // Проверяем существование
  if not TDirectory.Exists(LangPath) then
    Exit;

  LangMenu := TMenuItem.Create(PopupMenu1);
  LangMenu.Caption := LangCaption;

  AddFolderToMenu(LangMenu, LangPath);

  if LangMenu.Count > 0 then
    PopupMenu1.Items.Add(LangMenu)
  else
    LangMenu.Free;
end;

  // Процедура для разделения строки с языками и добавления их
  procedure AddLanguagesFromString(const BasePath, LanguagesString: string);
  var
    Languages: TStringList;
    i: Integer;
  begin
    Languages := TStringList.Create;
    try
      // Разделяем строку по точке с запятой
      Languages.Delimiter := ';';
      Languages.StrictDelimiter := True;
      Languages.DelimitedText := LanguagesString;

      // Добавляем каждый язык
      for i := 0 to Languages.Count - 1 do
      begin
        if Trim(Languages[i]) <> '' then
          AddLanguageExtras(BasePath, Trim(Languages[i]));
      end;
    finally
      Languages.Free;
    end;
  end;

var
  AppPath, BasePath, FullExtrasPath, LanguagesString: string;
  Separator: TMenuItem;
  ExtrasMenu: TMenuItem;
  HasItems: Boolean;
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

  // Проверяем, есть ли что-нибудь для добавления
  HasItems := TDirectory.Exists(FullExtrasPath);

  // Проверяем наличие языковых папок (можно добавить функцию для проверки)
  LanguagesString := FConfig.ReadString('SGAllSettings', 'LanguagesPack', '');

  // Если нет ни основной папки, ни языковых - выходим
  if not HasItems and (LanguagesString = '') then
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

  if Assigned(PopupMenu1.Images) then
  PopupMenu1.Images.Clear;

  // Добавляем основную папку Extras, если она существует
  if HasItems then
  begin
    ExtrasMenu := TMenuItem.Create(PopupMenu1);
    ExtrasMenu.Caption := 'English';

    // сразу добавляем содержимое Extras в основное меню
    AddFolderToMenu(ExtrasMenu, FullExtrasPath);

    // если папка не пустая - добавляем пункт
    if ExtrasMenu.Count > 0 then
      PopupMenu1.Items.Add(ExtrasMenu)
    else
      ExtrasMenu.Free;
  end;

  // Добавляем языковые папки (даже если основной папки нет)
  if LanguagesString <> '' then
    AddLanguagesFromString(BasePath, LanguagesString);
end;

procedure TSGLMainForm.ClearGameInfo;
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
  if PopupMenu1.Images <> nil then
    (PopupMenu1.Images as TImageList).Clear; // очистить накопленные иконки
end;

procedure TSGLMainForm.BuildGenreSeriesList(const PlatformFilter: string;
  Target: TStringList);
var
  i, j: Integer;
  GameGenres, GameSeries: TStringDynArray;
  IsAll, IsInstalled: Boolean;
begin
  IsAll       := SameText(PlatformFilter, 'All');
  IsInstalled := SameText(PlatformFilter, 'Installed');

  for i := 0 to High(FGameData) do
  begin
    // Фильтрация по платформе
    if IsInstalled then
    begin
      if not FGameData[i].IsInstalled then Continue;
    end
    else if not IsAll then
    begin
      if not SameText(FGameData[i].Platforms, PlatformFilter) then Continue;
    end;

    // Жанры
    if FGameData[i].Genre <> '' then
    begin
      GameGenres := FGameData[i].Genre.Split([';', '/']);
      for j := 0 to High(GameGenres) do
      begin
        GameGenres[j] := Trim(GameGenres[j]);
        if GameGenres[j] <> '' then
          Target.Add('[Genre] ' + GameGenres[j]); // дубликаты игнорирует сам список
      end;
    end;

    // Серии
    if FGameData[i].Series <> '' then
    begin
      GameSeries := FGameData[i].Series.Split([';', '/']);
      for j := 0 to High(GameSeries) do
      begin
        GameSeries[j] := Trim(GameSeries[j]);
        if GameSeries[j] <> '' then
          Target.Add('[Series] ' + GameSeries[j]);
      end;
    end;
  end;
end;

procedure TSGLMainForm.FillGenreSeriesCombo(const PlatformFilter: string);
var
  GenresSeries: TStringList;
begin
  GenresSeries := TStringList.Create;
  try
    GenresSeries.Sorted     := True;
    GenresSeries.Duplicates := dupIgnore;

    BuildGenreSeriesList(PlatformFilter, GenresSeries);

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

procedure TSGLMainForm.InitializePlatformTabs;
var
  i: Integer;
  Platforms: TStringList;
begin
  Platforms := TStringList.Create;
  try
    Platforms.Sorted     := True;
    Platforms.Duplicates := dupIgnore;

    for i := 0 to High(FGameData) do
      if (FGameData[i].Platforms <> '') and
         (FGameData[i].Platforms <> 'All') and
         (FGameData[i].Platforms <> 'Installed') then
        Platforms.Add(FGameData[i].Platforms);

    // Строим вкладки
    TabControl1.Tabs.Clear;
    TabControl1.Tabs.Add('All');
    TabControl1.Tabs.Add('Installed');
    for i := 0 to Platforms.Count - 1 do
      TabControl1.Tabs.Add(Platforms[i]);
    TabControl1.TabIndex := 0;

    // Заполняем ComboBox (через общий метод, фильтр = 'All')
    FillGenreSeriesCombo('All');
  finally
    Platforms.Free;
  end;
end;

procedure TSGLMainForm.FinalizeLoading;
var
  PlatformsDir: string;
  XMLFiles: TStringDynArray;
  SavedTab: string;
  TabIdx: Integer;
begin
  PlatformsDir := LaunchBoxDir + '\Data\Platforms\';

  // === НЕТ ПАПКИ ===
  if not TDirectory.Exists(PlatformsDir) then
  begin
    TrayIcon.Icon := Application.Icon;
    SGLMainForm.Icon := Application.Icon;
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
    SGLMainForm.Icon := Application.Icon;
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
        ScanXMLFromDir(PlatformsDir);
        SetLength(FGameData, FActualGameCount);

        if TThread.CurrentThread.CheckTerminated or FClosing then Exit;

        TThread.Queue(nil,
          procedure
          begin
            if FClosing or (csDestroying in ComponentState) then Exit;

            // Разблокируем контролы
            Edit1.Enabled := True;
            ComboBox1.Enabled := True;
            ScrollBox1.Enabled := True;
            NextImgBtn.Enabled := True;
            TrayIcon.Icon := Application.Icon;
            SGLMainForm.Icon := Application.Icon;

            InitializePlatformTabs; // строятся вкладки
            FLoadingComplete := True; // разрешаем фильтрацию
            // Загрузка последней сохраненной вкладке
            SavedTab := FConfig.ReadString('SGAllSettings', 'LastTab', 'All');
            TabIdx := TabControl1.Tabs.IndexOf(SavedTab);
            if TabIdx < 0 then TabIdx := TabControl1.Tabs.IndexOf('All');
            if TabIdx < 0 then TabIdx := 0;
            TabControl1.TabIndex := TabIdx;

            // Замораживаем отрисовку на время настройки колонок и фильтрации
            SendMessage(ListView1.Handle, WM_SETREDRAW, WPARAM(False), 0);
            try
              SetupListViewColumns;
              UpdateGenreSeriesComboForCurrentPlatform;
              ApplyFilters;
              ListView1.Items.Count := Length(FFilteredIndices);
              AutoSizeListViewColumns;
            finally
              SendMessage(ListView1.Handle, WM_SETREDRAW, WPARAM(True), 0);
              RedrawWindow(ListView1.Handle, nil, 0,
                RDW_ERASE or RDW_FRAME or RDW_INVALIDATE or RDW_ALLCHILDREN);
            end;

            if FConfig.ReadBool('SGAllSettings', 'EmptyWorkingSet', False) then
            if Win32Platform = VER_PLATFORM_WIN32_NT then
             begin
              EmptyWorkingSet(GetCurrentProcess);
              SetProcessWorkingSetSize(GetCurrentProcess, SIZE_T(-1), SIZE_T(-1));
             end;

            Caption := Format('%s %d', [TabControl1.Tabs[TabControl1.TabIndex]+' - ', Length(FFilteredIndices)]);
            if Length(FGameData) <> Length(FFilteredIndices) then
              Caption := Caption + Format(' / %d', [Length(FGameData)]);
            TrayIcon.Hint := Caption;

            // Выделяем первую игру
            ActiveControl := ListView1;
            if ListView1.Items.Count > 0 then
             begin
              ListView1.ItemIndex := 0;
              ListView1.Selected := ListView1.Items[0];
              ListView1.Selected.MakeVisible(False);
             end;
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

procedure TSGLMainForm.ApplyFilters;
var
  i, j, Count: Integer;
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
  SetLength(FFilteredIndices, Length(FGameData));

  for i := 0 to High(FGameData) do
  begin
    { === INSTALLED === }
    if SameText(SelectedPlatform, 'Installed') then
    begin
      if not FGameData[i].IsInstalled then
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

    FFilteredIndices[Count] := i;
    Inc(Count);
  end;

  SetLength(FFilteredIndices, Count);

  ListView1.Items.Count := Length(FFilteredIndices);
  ListView1.Invalidate;

  Caption := Format('%s %d', [TabControl1.Tabs[TabControl1.TabIndex]+' - ', Length(FFilteredIndices)]);
  if Length(FGameData) <> Length(FFilteredIndices) then
    Caption := Caption + Format(' / %d', [Length(FGameData)]);
  TrayIcon.Hint := Caption;

  ClearGameInfo;
end;

procedure TSGLMainForm.SortGameData;
begin
  TArray.Sort<TGameData>(FGameData,
    TComparer<TGameData>.Construct(
      function(const A, B: TGameData): Integer
      begin
        Result := CompareText(A.GameName, B.GameName);
      end));
end;

procedure TSGLMainForm.UpdateGenreSeriesComboForCurrentPlatform;
begin
  if not FLoadingComplete or FClosing or (csDestroying in ComponentState) then Exit;

  FillGenreSeriesCombo(TabControl1.Tabs[TabControl1.TabIndex]);
end;

procedure TSGLMainForm.ShowGameByIndex(const ItemIndex: Integer);
var
  RealIndex: Integer;
begin
  if ItemIndex < 0 then Exit;
  if ItemIndex >= Length(FFilteredIndices) then Exit;

  RealIndex := FFilteredIndices[ItemIndex];
  if (RealIndex < 0) or (RealIndex >= Length(FGameData)) then Exit;

  // ===== ТЕКСТ =====
  TitleLabel.Caption := FGameData[RealIndex].GameName;
  DeveloperLabel.Caption := 'Developer: ' + FGameData[RealIndex].Developer;
  PlatformLabel.Caption := 'Platform: ' + FGameData[RealIndex].Platforms;
  if FGameData[RealIndex].ReleaseYear > 0 then
   ReleaseLabel.Caption := 'Release year: ' + IntToStr(FGameData[RealIndex].ReleaseYear)
  else ReleaseLabel.Caption := 'Release year: unknown';
  PublisherLabel.Caption := 'Publisher: ' + FGameData[RealIndex].Publisher;
  GenreLabel.Caption := 'Genre: ' + FGameData[RealIndex].Genre;
  SeriesLabel.Caption := 'Series: ' + FGameData[RealIndex].Series;
  Label1.Caption := FGameData[RealIndex].Notes;
  ResizeLabelToText(Label1);

  // ===== RUN CAPTION =====
  if FGameData[RealIndex].IsInstalled then
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
     Configuration1.Enabled := FGameData[RealIndex].IsInstalled;
    end;

  // ===== ЗАПУСКАЕМ ПОТОК ДЛЯ ЗАГРУЗКИ ИЗОБРАЖЕНИЙ =====
  StartImageLoadThread(ItemIndex, RealIndex);

  // ===== EXTRAS =====
  UpdateExtrasMenu(RealIndex);
end;

procedure TSGLMainForm.LoadImageWithRetry(const FileName: string;
  Image: TImage; MaxRetries: Integer = 1);
var
  WICImage: TWICImage;
  RetryCount: Integer;
  LoadSuccess: Boolean;
begin
  RetryCount := 0;
  LoadSuccess := False;

  while (RetryCount < MaxRetries) and not LoadSuccess do
  begin
    try
      WICImage := TWICImage.Create;
      try
        WICImage.LoadFromFile(FileName);

        if not WICImage.Empty then
        begin
          Image.Picture.Assign(WICImage);
          LoadSuccess := True; // Успех!
        end;
      finally
        WICImage.Free;
      end;

    except
      on E: Exception do
      begin
        Inc(RetryCount);
        // Просто увеличиваем счётчик, никаких пауз
      end;
    end;
  end;

  // Если все попытки неудачны - просто очищаем изображение
  if not LoadSuccess then
    Image.Picture := nil;
end;

procedure TSGLMainForm.StartImageLoadThread(ItemIndex, RealIndex: Integer);
begin
    // ===== ЗАПУСКАЕМ ПОТОК ДЛЯ ЗАГРУЗКИ ИЗОБРАЖЕНИЙ =====
    FImageLoadLock.Enter;
    try
      Inc(FImageGeneration);         // ← каждый новый запрос — новое поколение
      FImageLoadPending := True;
      FImageLoadGameIndex := RealIndex;
      FImageLoadItemIndex := ItemIndex;
    finally
      FImageLoadLock.Leave;
    end;

    // Если поток уже работает — он сам увидит новое поколение
  if (FImageLoadThread <> nil) and not FImageLoadThread.Finished then
    Exit;

  // ── Создаём рабочий поток ─────────────────────────────────────────────
  FImageLoadThread := TThread.CreateAnonymousThread(
    procedure
    var
      CapturedGeneration : Integer;   // Поколение текущего задания
      LocalGameIndex     : Integer;
      LocalItemIndex     : Integer;
      LocalPlatform      : string;
      LocalGameName      : string;
      LocalReleaseDate   : string;
      LocalID            : string;
      LocalForceName     : string;
      LocalImgList       : TStringList; // Строится в потоке
      QueueList          : TStringList; // Передаётся в Queue (отдельный захват!)
    begin
      while not (TThread.CurrentThread.CheckTerminated or FClosing) do
      begin

        // ── 1. Читаем задание под блокировкой ──────────────────────────
        FImageLoadLock.Enter;
        try
          // Нет нового задания — поток завершает работу
          if not FImageLoadPending or FClosing then
            Break;

          CapturedGeneration := FImageGeneration;   // Запоминаем "наше" поколение
          LocalGameIndex     := FImageLoadGameIndex;
          LocalItemIndex     := FImageLoadItemIndex;
          LocalPlatform      := FGameData[LocalGameIndex].Platforms;
          LocalGameName      := FGameData[LocalGameIndex].GameName;
          LocalReleaseDate   := IntToStr(FGameData[LocalGameIndex].ReleaseYear);
          LocalID            := FGameData[LocalGameIndex].ID;

          if NConfig.ValueExists(LocalPlatform, LocalID) then
            LocalForceName := NConfig.ReadString(LocalPlatform, LocalID, '')
          else
            LocalForceName := '';

          FImageLoadPending := False;  // Задание принято в обработку
        finally
          FImageLoadLock.Leave;
        end;

        // ── 2. Ищем файлы изображений (тяжёлая операция) ───────────────
        LocalImgList := TStringList.Create;
        try
          LocalImgList.Duplicates    := dupIgnore;
          LocalImgList.CaseSensitive := False;

          try
            FindGameImages(LocalPlatform, LocalGameName,
                           LocalReleaseDate, LocalID, LocalForceName,
                           LocalImgList);
          except
            // Подавляем ошибки поиска — продолжаем с пустым списком
          end;

          // Прерывание по закрытию/terminate
          if TThread.CurrentThread.CheckTerminated or FClosing then
            Break;

          // ── 3. Проверяем актуальность результата ─────────────────────
          // Пока мы искали — мог прийти новый запрос (новое поколение)
          if FImageGeneration <> CapturedGeneration then
            Continue;  // Результат устарел. finally освободит LocalImgList.
                       // Следующая итерация подхватит новый FImageLoadPending.

          // ── 4. Передаём результат в главный поток ────────────────────
          // ВАЖНО: используем две переменные, чтобы:
          //   - QueueList  захватилась замыканием Queue (владение → Queue)
          //   - LocalImgList стала nil → finally не освободит дважды
          QueueList    := LocalImgList;
          LocalImgList := nil;

          TThread.Queue(nil,
            procedure
            begin
              // QueueList — отдельный захват, не связан с LocalImgList
              try
                if FClosing or (csDestroying in ComponentState) then Exit;

                // Финальная проверка: вдруг пользователь успел сменить игру
                // уже после того как Queue встал в очередь
                if FImageGeneration <> CapturedGeneration then Exit;

                ImgList.Clear;
                ImgList.Assign(QueueList);

                if ImgList.Count > 0 then
                begin
                  try
                    LoadImageWithRetry(ImgList[0], ScreenShotImage);
                    if Assigned(FullScreenForm) and FullScreenForm.Showing then
                      LoadImageWithRetry(ImgList[0], FullScreenForm.FullScreenImage);
                    ImgCurIndex := 0;
                  except
                    // Подавляем ошибки загрузки конкретного файла
                  end;
                  NextImgBtn.Enabled := ImgList.Count > 1;
                  PrevImgBtn.Enabled := ImgList.Count > 1;
                end
                else
                begin
                  // Изображений нет — явно очищаем UI
                  ScreenShotImage.Picture := nil;
                  ImgCurIndex             := -1;
                  NextImgBtn.Enabled      := False;
                  PrevImgBtn.Enabled      := False;
                end;

              finally
                QueueList.Free;  // Освобождаем в главном потоке
              end;
            end
          );

        finally
          LocalImgList.Free; // nil-safe: сработает только если НЕ передали в Queue
        end;

        Sleep(50); // Небольшая пауза перед следующей итерацией
      end;
    end
  );

  FImageLoadThread.FreeOnTerminate := False;
  FImageLoadThread.Start;
end;

procedure TSGLMainForm.FindGameImages(const Platforms, GameName, ReleaseDate, ID, ForcedName: string; ImageList: TStringList);
var
  PlatformDir: string;                 // Папка платформы LaunchBox (например Images\PC)
  Year: string;                        // Год игры
  BaseNameNoYear: string;              // Имя игры без года
  BaseNameWithYear: string;            // Имя игры + (год)
  BaseNameWithYearNoSpace: string;     // Имя игры +(год) без пробела
  PriorityFolders: TArray<string>;     // Приоритетные папки поиска
  Folder: string;
  Files: TStringDynArray;
  FilePath, FileName: string;

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

  procedure TryAddFromFolder(const BaseFolder: string);
  var
    SearchPath: string;
    j: Integer;
  begin
    SearchPath := IncludeTrailingPathDelimiter(PlatformDir) + BaseFolder;
    if not TDirectory.Exists(SearchPath) then Exit;

    Files := TDirectory.GetFiles(SearchPath, '*.*', TSearchOption.soAllDirectories);

    for j := 0 to High(Files) do
    begin
      if TThread.CurrentThread.CheckTerminated then Exit;

      FilePath := Files[j];
      FileName := OneLine(TPath.GetFileNameWithoutExtension(FilePath));

      if ForcedName <> '' then
      begin
        if SameText(FileName, ForcedName) or
           StartsText(ForcedName + '-', FileName) then
        begin
          ImageList.Add(FilePath);
        end;
      end
      else
      begin
        if IsValidMatch(FileName, BaseNameNoYear) or
           ((BaseNameWithYear <> '') and IsValidMatch(FileName, BaseNameWithYear)) or
           ((BaseNameWithYearNoSpace <> '') and IsValidMatch(FileName, BaseNameWithYearNoSpace)) then
        begin
          ImageList.Add(FilePath);
        end;
      end;
    end;
  end;

begin
  // очищаем список результатов
  ImageList.Clear;

  // путь к папке платформы
  PlatformDir := IncludeTrailingPathDelimiter(LaunchBoxDir) +
                 'Images\' + Platforms;

  // если папка платформы не существует — выход
  if not TDirectory.Exists(PlatformDir) then Exit;

  // получаем год из даты релиза
  Year := ReleaseDate;

  // базовое имя игры
  BaseNameNoYear := OneLine(GameName);

  BaseNameWithYear := '';
  BaseNameWithYearNoSpace := '';

  // формируем варианты имени с годом
  if Year <> '' then
  begin
    BaseNameWithYear := OneLine(GameName + ' (' + Year + ')');
    BaseNameWithYearNoSpace := OneLine(GameName + '(' + Year + ')');
  end;

  // -------------------------------------------------
  // ПРИОРИТЕТНЫЕ ПАПКИ LaunchBox
  // -------------------------------------------------
  PriorityFolders := [
    'Screenshot - Gameplay',
    'Screenshot - Game Title',
    'Disc',
    'Box - Front',
    'Box - Back'
  ];

  // Сначала ищем только в этих папках
  for Folder in PriorityFolders do
    TryAddFromFolder(Folder);

  // -------------------------------------------------
  // Если нашли мало изображений — ищем везде
  // -------------------------------------------------
  if ImageList.Count < 2 then
  begin
    var AllFiles := TDirectory.GetFiles(
      PlatformDir,'*.*',TSearchOption.soAllDirectories);

    for FilePath in AllFiles do
    begin
      if TThread.CurrentThread.CheckTerminated or FClosing then Exit;

      // пропускаем уже обработанные папки
      var InPriority := False;

      for Folder in PriorityFolders do
        if Pos(IncludeTrailingPathDelimiter(Folder),FilePath) > 0 then
        begin
          InPriority := True;
          Break;
        end;

      if InPriority then Continue;

      FileName := OneLine(TPath.GetFileNameWithoutExtension(FilePath));

      if ForcedName <> '' then
      begin
        if SameText(FileName, ForcedName) or
           StartsText(ForcedName + '-', FileName) or
           MatchForcedNumberedName(FileName, ForcedName) then
          ImageList.Add(FilePath);
      end
      else
      begin
        if IsValidMatch(FileName, BaseNameNoYear) or
           ((BaseNameWithYear <> '') and IsValidMatch(FileName, BaseNameWithYear)) or
           ((BaseNameWithYearNoSpace <> '') and IsValidMatch(FileName, BaseNameWithYearNoSpace)) then
          ImageList.Add(FilePath);
      end;
    end;
  end;

  // -------------------------------------------------
  // Если ничего не нашли — ищем по GUID (ID игры)
  // -------------------------------------------------
  if (ImageList.Count = 0) and (ID <> '') then
  begin
    BaseNameNoYear := OneLine(ID);

    BaseNameWithYear := '';
    BaseNameWithYearNoSpace := '';

    for Folder in PriorityFolders do
      TryAddFromFolder(Folder);
  end;

end;

procedure TSGLMainForm.ScanXMLFromDir(const Dir: string);
var
  XMLFiles: TStringDynArray;
  i: Integer;
begin
  FActualGameCount := 0;
  SetLength(FGameData, 4096);
  FGameDict.Clear;

  XMLFiles := TDirectory.GetFiles(Dir, '*.xml', TSearchOption.soTopDirectoryOnly);
  FTotalXMLFiles := Length(XMLFiles);

  if Length(XMLFiles) = 0 then
  begin
    Caption := 'No XML files found in ' + Dir;
    TrayIcon.Hint := Caption;
    Exit;
  end;

  LoadXMLFilesMultiThreaded(XMLFiles);

  SetLength(FGameData, FActualGameCount);

  FGameDict.Clear;
  FGameDict.TrimExcess;

  if Length(FGameData) > 1 then
    SortGameData;

  // === Кэшируем IsInstalled один раз в фоновом потоке ===
  // Создаём LanguagesPack один раз для всех игр — не в каждом вызове
  var SharedLP := TStringList.Create;
  try
    SharedLP.Delimiter := ';';
    SharedLP.StrictDelimiter := True;
    SharedLP.DelimitedText := FConfig.ReadString('SGAllSettings', 'LanguagesPack', '');
    for i := 0 to High(FGameData) do
      FGameData[i].IsInstalled := IsGameInstalled(FGameData[i], SharedLP);
  finally
    SharedLP.Free;
  end;
  // ======================================================

  SetLength(FFilteredIndices, Length(FGameData));
  for i := 0 to High(FGameData) do
    FFilteredIndices[i] := i;
end;

procedure TSGLMainForm.LoadXMLToArrayThreadSafe(const XMLFileName: string);
var
  XML: IXMLDocument;
  Nodes: IXMLNodeList;
  Node, Child: IXMLNode;
  G: TGameData;
  i, j: Integer;
  NodeName: string;
  PlatformFromFile: string;
begin
  XML := TXMLDocument.Create(nil);
  try
    XML.LoadFromFile(XMLFileName);
    XML.Active := True;

    if (XML.DocumentElement = nil) then Exit;

    Nodes := XML.DocumentElement.ChildNodes;
    PlatformFromFile := ChangeFileExt(ExtractFileName(XMLFileName), '');

    for i := 0 to Nodes.Count - 1 do
    begin
      Node := Nodes[i];
      if Node.NodeName <> 'Game' then Continue;

      FillChar(G, SizeOf(G), 0);

      for j := 0 to Node.ChildNodes.Count - 1 do
      begin
        Child := Node.ChildNodes[j];
        if not Assigned(Child) then Continue;

        NodeName := Child.LocalName;

        case IndexStr(NodeName, ['Title','ApplicationPath','Platform','Developer',
                                  'Publisher','Genre','Series','ReleaseDate','Notes',
                                  'ManualPath','ConfigurationPath','RootFolder','ID']) of
          0: G.GameName          := Trim(Child.Text);
          1: G.ApplicationPath   := Trim(Child.Text);
          2: G.Platforms         := Trim(Child.Text);
          3: G.Developer         := Trim(Child.Text);
          4: G.Publisher         := Trim(Child.Text);
          5: G.Genre             := Trim(Child.Text);
          6: G.Series            := Trim(Child.Text);
          7: G.ReleaseYear       := StrToIntDef(Copy(Trim(Child.Text),1,4), 0);
          8: G.Notes             := Trim(Child.Text);
          9: G.Manual            := Trim(Child.Text);
          10:G.ConfigurationPath := Trim(Child.Text);
          11:G.RootFolder        := Trim(Child.Text);
          12:G.ID                := Trim(Child.Text);
        end;
      end;

      if G.GameName = '' then Continue;

      // Если платформа не указана в XML — берём из имени файла
      if G.Platforms = '' then
        G.Platforms := PlatformFromFile;

      // Добавляем игру (с проверкой на дубликаты по ID)
      AddGameToArray(G);

    end;
  finally
    XML := nil;
  end;
end;

procedure TSGLMainForm.LoadXMLFilesMultiThreaded(const XMLFiles: TStringDynArray);
var
  ThreadCount: Integer;
  Threads: TArray<TThread>;
  I: Integer;
  NextFileIdx: Integer;  // атомарный индекс следующего файла для обработки
  LoadedCount: Integer;  // атомарный счётчик завершённых файлов
begin
  ThreadCount := TThread.ProcessorCount;
  if ThreadCount > Length(XMLFiles) then ThreadCount := Length(XMLFiles);
  if ThreadCount < 1 then ThreadCount := 1;

  NextFileIdx := 0;
  LoadedCount := 0;
  SetLength(Threads, ThreadCount);

  // Все потоки одинаковые — нет проблемы захвата переменных замыканием.
  // Каждый поток сам атомарно берёт следующий свободный файл из очереди.
  for I := 0 to ThreadCount - 1 do
  begin
    Threads[I] := TThread.CreateAnonymousThread(
      procedure
      var
        MyIdx: Integer;
        Loaded: Integer;
        LastUpdate: Cardinal;  // локальная для каждого потока — нет race condition
      begin
        CoInitialize(nil);
        LastUpdate := GetTickCount;
        try
          while True do
          begin
            if TThread.CurrentThread.CheckTerminated or FClosing then Break;

            // Атомарно берём следующий файл из очереди
            MyIdx := TInterlocked.Increment(NextFileIdx) - 1;
            if MyIdx >= Length(XMLFiles) then Break;  // все файлы разобраны

            // Игры добавляются в FGameData через AddGameToArray внутри (с блокировкой)
            LoadXMLToArrayThreadSafe(XMLFiles[MyIdx]);

            Loaded := TInterlocked.Increment(LoadedCount);

            // Прогресс — обновляем не чаще раза в 150 мс
            if (GetTickCount - LastUpdate > 150) or (Loaded = FTotalXMLFiles) then
            begin
              var CapturedLoaded := Loaded;
              TThread.Queue(nil,
                procedure
                begin
                  if not FClosing then
                  begin
                    Caption := Format('Loading... %d%%  (%d/%d)',
                      [CapturedLoaded * 100 div FTotalXMLFiles,
                       CapturedLoaded, FTotalXMLFiles]);
                    TrayIcon.Hint := Caption;
                  end;
                end);
              LastUpdate := GetTickCount;
            end;
          end;
        finally
          CoUninitialize;
        end;
      end
    );

    Threads[I].FreeOnTerminate := False;
    Threads[I].Start;
  end;

  // Ожидаем завершения всех потоков
  for I := 0 to High(Threads) do
  begin
    Threads[I].WaitFor;
    FreeAndNil(Threads[I]);
  end;
end;

procedure TSGLMainForm.RefreshInstalledStatus;
var
  i: Integer;
  SharedLP: TStringList;
begin
  if not FLoadingComplete then Exit;
  if FActualGameCount = 0 then Exit;

  // Проверяем, не отменена ли операция
  if FClosing or (csDestroying in ComponentState) then Exit;

  SharedLP := TStringList.Create;
  try
    SharedLP.Delimiter := ';';
    SharedLP.StrictDelimiter := True;
    SharedLP.DelimitedText := FConfig.ReadString('SGAllSettings', 'LanguagesPack', '');

    for i := 0 to FActualGameCount - 1 do
    begin
      // Проверяем отмену в цикле
      if FClosing or (csDestroying in ComponentState) then Exit;
      FGameData[i].IsInstalled := IsGameInstalled(FGameData[i], SharedLP);
    end;
  finally
    SharedLP.Free;
  end;
end;

procedure TSGLMainForm.DoProcessPendingTabChange(Sender: TObject);
// Функция для переключение вкладок
begin
  FTabChangeTimer.Enabled := False;

  FTabChangeLock.Enter;
  try
    if FPendingTabIndex >= 0 then
    begin
      PerformTabChange(FPendingTabIndex);
      FPendingTabIndex := -1;
    end;
    FIsChangingTab := False;
  finally
    FTabChangeLock.Leave;
  end;
end;

procedure TSGLMainForm.PerformTabChange(NewTabIndex: Integer);
// Функция для переключение вкладок
var
  SelectedPlatform: string;
  RedrawRestored: Boolean;
begin
  if not FLoadingComplete or (csDestroying in ComponentState) then Exit;

  // Инвалидируем любой текущий и ожидающий поиск изображений
  FImageLoadLock.Enter;
    try
     Inc(FImageGeneration);      // ← поток увидит несовпадение и бросит результат
     FImageLoadPending := False; // ← новых запросов не брать
    finally
      FImageLoadLock.Leave;
    end;

  if Assigned(FImageLoadThread) and not FImageLoadThread.Finished then
  begin
    FImageLoadThread.Terminate;
    FImageLoadThread.FreeOnTerminate := True;
    FImageLoadThread := nil;
  end
  else
    FreeAndNil(FImageLoadThread);

  if (NewTabIndex < 0) or (NewTabIndex >= TabControl1.Tabs.Count) then
    Exit;

  TabControl1.TabIndex := NewTabIndex;
  SelectedPlatform := TabControl1.Tabs[NewTabIndex];

  // --- Замораживаем отрисовку ListView полностью ---
  SendMessage(ListView1.Handle, WM_SETREDRAW, WPARAM(False), 0);
  RedrawRestored := False;
  try
    ClearGameInfo;
    SetupListViewColumns;

    // --- Вкладка "Installed": RefreshInstalledStatus уходит в фон ---
    if SameText(SelectedPlatform, 'Installed') then
    begin
      // Пока заморожены — выставляем ширины и очищаем список,
      // чтобы при разморозке всё выглядело правильно сразу
      ListView1.Items.Count := 0;
      AutoSizeListViewColumns;

      // Восстанавливаем рисование ДО запуска фонового потока
      SendMessage(ListView1.Handle, WM_SETREDRAW, WPARAM(True), 0);
      RedrawWindow(ListView1.Handle, nil, 0,
        RDW_ERASE or RDW_FRAME or RDW_INVALIDATE or RDW_ALLCHILDREN);
      RedrawRestored := True;

      TThread.CreateAnonymousThread(
        procedure
        begin
          RefreshInstalledStatus;

          TThread.Queue(nil,
            procedure
            begin
              if FClosing or (csDestroying in ComponentState) then Exit;

              // Снова замораживаем на время обновления данных
              SendMessage(ListView1.Handle, WM_SETREDRAW, WPARAM(False), 0);
              try
                ListView1.Items.BeginUpdate;
                try
                  UpdateGenreSeriesComboForCurrentPlatform;
                  ApplyFilters;
                finally
                  ListView1.Items.EndUpdate;
                end;
                AutoSizeListViewColumns;
              finally
                SendMessage(ListView1.Handle, WM_SETREDRAW, WPARAM(True), 0);
                RedrawWindow(ListView1.Handle, nil, 0,
                  RDW_ERASE or RDW_FRAME or RDW_INVALIDATE or RDW_ALLCHILDREN);
              end;

              ActiveControl := ListView1;
              if ListView1.Items.Count > 0 then
              begin
                ListView1.ItemIndex := 0;
                ListView1.Items[0].Selected := True;
                ListView1.Items[0].MakeVisible(False);
              end;
            end
          );
        end
      ).Start;

      Exit;
    end;

    // --- Остальные вкладки ---
    ListView1.Items.BeginUpdate;
    try
      UpdateGenreSeriesComboForCurrentPlatform;
      ApplyFilters;
    finally
      ListView1.Items.EndUpdate;
    end;
    AutoSizeListViewColumns;

  finally
    if not RedrawRestored then
    begin
      SendMessage(ListView1.Handle, WM_SETREDRAW, WPARAM(True), 0);
      RedrawWindow(ListView1.Handle, nil, 0,
        RDW_ERASE or RDW_FRAME or RDW_INVALIDATE or RDW_ALLCHILDREN);
    end;
  end;

  ActiveControl := ListView1;
  if ListView1.Items.Count > 0 then
  begin
    ListView1.ItemIndex := 0;
    ListView1.Items[0].Selected := True;
    ListView1.Items[0].MakeVisible(False);
  end;
end;

procedure TSGLMainForm.SetupListViewColumns;
// управляет колонками All и Installed для отображения платформы
var
  SelectedPlatform: string;
  Col: TListColumn;
  NeedPlatformCol: Boolean;
begin
  if TabControl1.Tabs.Count = 0 then Exit;
  SelectedPlatform := TabControl1.Tabs[TabControl1.TabIndex];
  NeedPlatformCol := SameText(SelectedPlatform, 'All') or
                     SameText(SelectedPlatform, 'Installed');

  ListView1.Columns.BeginUpdate;
  try
    ListView1.Columns.Clear;

    Col := ListView1.Columns.Add;
    Col.Caption := 'Name';
    Col.AutoSize := False;

    if NeedPlatformCol then
    begin
      Col := ListView1.Columns.Add;
      Col.Caption := 'Platform';
      Col.AutoSize := False;
    end;
  finally
    ListView1.Columns.EndUpdate;
  end;
end;

procedure TSGLMainForm.AutoSizeListViewColumns;
// управляет размеры колонками ListView
var
  i, RealIndex: Integer;
  PlatWidth, MaxPlatWidth, Padding: Integer;
  SaveFont: TFont;
begin
  // Одна колонка — просто растягиваем на всю ширину
  if ListView1.Columns.Count < 2 then
  begin
    if ListView1.Columns.Count >= 1 then
      ListView1.Column[0].Width := ListView1.Width - 20;
    Exit;
  end;

  Padding := 16; // отступы внутри ячейки

  // Минимальная ширина — по заголовку "Platform"
  SaveFont := TFont.Create;
  try
    SaveFont.Assign(ListView1.Canvas.Font);
    ListView1.Canvas.Font.Style := [fsBold]; // заголовок обычно жирный
    MaxPlatWidth := ListView1.Canvas.TextWidth('Platform') + Padding;
    ListView1.Canvas.Font.Assign(SaveFont);
  finally
    SaveFont.Free;
  end;

  // Перебираем отфильтрованные игры и ищем максимальную ширину платформы
  if FLoadingComplete then
  begin
    ListView1.Canvas.Font := ListView1.Font;
    for i := 0 to High(FFilteredIndices) do
    begin
      RealIndex := FFilteredIndices[i];
      if (RealIndex >= 0) and (RealIndex < Length(FGameData)) then
      begin
        PlatWidth := ListView1.Canvas.TextWidth(FGameData[RealIndex].Platforms) + Padding;
        if PlatWidth > MaxPlatWidth then
          MaxPlatWidth := PlatWidth;
      end;
    end;
  end;

  // Ограничиваем: платформа занимает не более 40% ширины списка
  if MaxPlatWidth > (ListView1.Width - 20) * 2 div 5 then
    MaxPlatWidth := (ListView1.Width - 20) * 2 div 5;

  ListView1.Column[1].Width := MaxPlatWidth;
  ListView1.Column[0].Width := ListView1.Width - 20 - MaxPlatWidth;
end;

//-----------------------------------------------------------------------------

procedure TSGLMainForm.StyleMenuClick(Sender: TObject);
//Нажатие на меню для скинов
var
  I: Integer;
  Root: TMenuItem;
  CurrentStyleName: string;
begin
  if not (Sender is TMenuItem) then Exit;

  Root := TMenuItem(Sender).Parent;

  // Снимаем все галочки
  for I := 0 to Root.Count - 1 do
    Root.Items[I].Checked := False;

  TMenuItem(Sender).Checked := True;

  // Применяем выбранный стиль
  if TMenuItem(Sender).Tag = -1 then
    TStyleManager.SetStyle('Windows')
  else
    TStyleManager.TrySetStyle(TMenuItem(Sender).Hint);

  CurrentStyleName := TStyleManager.ActiveStyle.Name;

  FConfig.WriteString('SGAllSettings', 'Styles', CurrentStyleName);
  FConfig.UpdateFile;
end;

//----CONFIG----
//------------------------------------------------------------------------------
function TSGLMainForm.GetFConfig: TMemIniFile;
var
 AppName: String;
begin
  AppName := ExtractFileName(ChangeFileExt(ParamStr(0),'.ini'));
  if FConfig = nil then
  FConfig := TMemIniFile.Create(ExtractFilePath(ParamStr(0))+AppName,TEncoding.UTF8);
  Result := FConfig;
end;

function TSGLMainForm.GetNConfig: TMemIniFile;
var
 AppName: String;
begin
  AppName := ExtractFileName(ChangeFileExt(ParamStr(0),''));
  if NConfig = nil then
  NConfig := TMemIniFile.Create(ExtractFilePath(ParamStr(0))+AppName+'ImgNames.ini',TEncoding.UTF8);
  Result := NConfig;
end;

procedure TSGLMainForm.RegIni(Write: Boolean);
var
 s: String;
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
  FConfig.WriteBool('SGAllSettings', 'ShowToolBar', ToolBar1.Visible);
  FConfig.WriteString('SGAllSettings', 'ToolBarPosition', GetEnumName(TypeInfo(TAlign), Ord(ToolBar1.Align)));
  FConfig.WriteString('SGAllSettings', 'Styles', TStyleManager.ActiveStyle.Name);
  if TabControl1.Tabs.Count > 0 then
  FConfig.WriteString('SGAllSettings', 'LastTab', TabControl1.Tabs[TabControl1.TabIndex]);
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
  Panel3.Width := FConfig.ReadInteger('SGAllSettings', 'ListViewWidth', SGLMainForm.Width div 3);
  ScrollBox1.Height := FConfig.ReadInteger('SGAllSettings', 'InfoPanelHeight', ScrollBox1.Height);
  if FConfig.ReadBool('SGAllSettings', 'ShowToolBar', False) then
   begin
    ToolBar1.Visible := True;
    ShowToolBar.Checked := True;
   end else
   begin
    ToolBar1.Visible := False;
    ShowToolBar.Checked := False;
   end;
  //ToolBar
  s := FConfig.ReadString('SGAllSettings', 'ToolBarPosition', 'alTop');
  ToolBar1.Align := TAlign(GetEnumValue(TypeInfo(TAlign), s));
  UpdateToolbarMenuChecks(ToolBarTop1, ToolBar1);
  //---------------------------------------------------------------------------
  Autostart1.Checked := IsInStartupFolder;
  EmptyWorkingSet1.Checked := FConfig.ReadBool('SGAllSettings', 'EmptyWorkingSet', False);
 end;
end;

//----FORM----
//------------------------------------------------------------------------------
procedure TSGLMainForm.WMCopyData(var Msg: TWMCopyData);
//Нужно для показа формы если нажать на exe снова
begin
  // если скрыта
  if not IsWindowVisible(Handle) then
    Show;

  // если свернута
  if IsIconic(Handle) then
    ShowWindow(Handle, SW_RESTORE);

  ShowWindow(Handle, SW_SHOW);

  // Обход Windows focus protection
  SetWindowPos(Handle, HWND_TOPMOST, 0,0,0,0, SWP_NOMOVE or SWP_NOSIZE);

  SetWindowPos(Handle, HWND_NOTOPMOST, 0,0,0,0, SWP_NOMOVE or SWP_NOSIZE);

  SetForegroundWindow(Handle);
  BringWindowToTop(Handle);
  SetActiveWindow(Handle);

  Msg.Result := 1;
end;

procedure TSGLMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  FClosing := True;

  // Останавливаем таймер переключение вкладок
  if Assigned(FTabChangeTimer) then FTabChangeTimer.Enabled := False;

  if Assigned(FImageLoadThread) then begin
    FImageLoadThread.Terminate;
    FImageLoadThread.WaitFor;
    FreeAndNil(FImageLoadThread);
  end;
    if Assigned(FLoaderThread) then begin
    FLoaderThread.Terminate;
    FLoaderThread.WaitFor;
    FreeAndNil(FLoaderThread);
  end;

  if Assigned(FGameDataLock) then FreeAndNil(FGameDataLock);
  if Assigned(FGameDict) then FreeAndNil(FGameDict);

  CanClose := True;

  // Освобождение ресурсов
  if Assigned(ImgList) then FreeAndNil(ImgList);
  if Assigned(FIgnoredFolders) then FreeAndNil(FIgnoredFolders);

  RegIni(True);

  if Assigned(FConfig) then FreeAndNil(FConfig);
  if Assigned(NConfig) then FreeAndNil(NConfig);
end;

procedure TSGLMainForm.FormCreate(Sender: TObject);
begin
  FMsgShow := RegisterWindowMessage('StartGameLauncher_ShowMessage_Unique_String'); //Для Mutex

  // многопоточная загрузка XML-файлов
  FGameDict := TDictionary<string, Integer>.Create;
  FGameDataLock := TCriticalSection.Create;
  FLoadedGamesCount := 0;

  // Инициализация для потоковой загрузки изображений
  FImageLoadLock := TCriticalSection.Create;
  FImageLoadPending := False;

  // Переключение вкладок
  FTabChangeLock := TCriticalSection.Create;
  FIsChangingTab := False;
  FPendingTabIndex := -1;
  FTabChangeTimer := TTimer.Create(Self);
  FTabChangeTimer.Interval := 100;
  FTabChangeTimer.Enabled := False;
  FTabChangeTimer.OnTimer := DoProcessPendingTabChange;

  ImgList := TStringList.Create;
  ImgList.Duplicates := dupIgnore;
  ImgList.CaseSensitive := False;

  LaunchBoxDir := 'E:\LaunchBox'{GetExecPath};
  GetFConfig;
  GetNConfig;
  RegIni(False);

  FIgnoredFolders := TStringList.Create;
  FIgnoredFolders.CaseSensitive := False;
  StrToList(IgnoreDir, ';', FIgnoredFolders);

  SGLMainForm.Icon := LoadIconFromRCDATA('OnLoadIcon');
  TrayIcon.Icon := LoadIconFromRCDATA('OnLoadIcon');
  TrayIcon.Visible := True;
  Application.ShowMainForm := not FConfig.ReadBool('SGAllSettings', 'HideInTray', False);

  //ToolBar
  with ToolBtnPropertiesForm do
   begin
    LoadToolButtons(ToolBar1, FConfig, ImageList1, ToolBar1Click);
    AddItemToButtonPopup(ToolBar1, FConfig, Self, ToolBarMenuClick);
   end;

  //Создание список стиль
  BuildStylesMenu(StyleMenu1, StyleMenuClick);
  StylesLoad(FConfig, StyleMenu1);

  FinalizeLoading;
end;

procedure TSGLMainForm.FormKeyDown(Sender: TObject; var Key: Word;
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

procedure TSGLMainForm.FormResize(Sender: TObject);
begin
  AutoSizeListViewColumns;
  Edit1.Width := Panel4.Width div 2 - 6;
  ComboBox1.Left := Edit1.Width + 6;
  ComboBox1.Width := Edit1.Width;
  ResizeLabelToText(Label1);
end;

//----FORM COMPONENTS----
//------------------------------------------------------------------------------

//----LISTVIEW----
//------------------------------------------------------------------------------
procedure TSGLMainForm.ListView1ContextPopup(Sender: TObject; MousePos: TPoint;
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

procedure TSGLMainForm.ListView1Data(Sender: TObject; Item: TListItem);
var
  RealIndex: Integer;
  SelectedPlatform: string;
begin
  if not FLoadingComplete then Exit;
  if (Item.Index < 0) or (Item.Index >= Length(FFilteredIndices)) then Exit;

  RealIndex := FFilteredIndices[Item.Index];
  if (RealIndex < 0) or (RealIndex >= Length(FGameData)) then Exit;

  Item.Caption := FGameData[RealIndex].GameName;

  if ListView1.Columns.Count >= 2 then
  begin
    SelectedPlatform := TabControl1.Tabs[TabControl1.TabIndex];
    if SameText(SelectedPlatform, 'All') or SameText(SelectedPlatform, 'Installed') then
      Item.SubItems.Add(FGameData[RealIndex].Platforms);
  end;
end;

procedure TSGLMainForm.ListView1DblClick(Sender: TObject);
begin
 if ListView1.ItemIndex = -1 then Exit;
  ShellOpen(LaunchBoxDir + '\' + FGameData[FFilteredIndices[ListView1.ItemIndex]].ApplicationPath);
end;

procedure TSGLMainForm.ListView1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
if Key = VK_RETURN then ListView1DblClick(Sender);
if Key = VK_LEFT then PrevImgBtnClick(Sender);
if Key = VK_RIGHT then NextImgBtnClick(Sender);
end;

procedure TSGLMainForm.ListView1KeyPress(Sender: TObject; var Key: Char);
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

procedure TSGLMainForm.ListView1SelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
 if Selected then
  ShowGameByIndex(Item.Index) else ClearGameInfo;
end;

//----OTHER COMPONENTS----
//------------------------------------------------------------------------------
procedure TSGLMainForm.TabControl1Change(Sender: TObject);
var
  SelectedPlatform: string;
begin
FTabChangeLock.Enter;
  try
    if FIsChangingTab then
    begin
      // Откладываем изменение вкладки
      FPendingTabIndex := TabControl1.TabIndex;
      FTabChangeTimer.Enabled := True;
      Exit;
    end;

    FIsChangingTab := True;
  finally
    FTabChangeLock.Leave;
  end;

  PerformTabChange(TabControl1.TabIndex);
end;

procedure TSGLMainForm.TrayIconClick(Sender: TObject);
begin
// Проверяем, что форма ещё не уничтожается
if csDestroying in ComponentState then Exit;

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

procedure TSGLMainForm.ComboBox1Change(Sender: TObject);
begin
  ApplyFilters;
end;

procedure TSGLMainForm.Edit1Change(Sender: TObject);
begin
  FSearchText := Edit1.Text;
  ApplyFilters;
end;

procedure TSGLMainForm.ScreenShotImageClick(Sender: TObject);
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

procedure TSGLMainForm.PrevImgBtnClick(Sender: TObject);
begin
  if ImgList.Count = 0 then Exit;

  // сдвиг назад с учётом зацикливания
  ImgCurIndex := ImgCurIndex - 1;
  if ImgCurIndex < 0 then
    ImgCurIndex := ImgList.Count - 1;

  LoadImageWithRetry(ImgList[ImgCurIndex], ScreenShotImage);
end;

procedure TSGLMainForm.NextImgBtnClick(Sender: TObject);
begin
  if ImgList.Count = 0 then Exit;

  ImgCurIndex := (ImgCurIndex + 1) mod ImgList.Count;

  LoadImageWithRetry(ImgList[ImgCurIndex], ScreenShotImage);
end;

//----MENUITEMS----
//------------------------------------------------------------------------------
procedure TSGLMainForm.Autostart1Click(Sender: TObject);
begin
with Sender as TMenuItem do
   begin
    Checked := not Checked;
    ToggleSelfInStartupFolder(Checked);
   end;
end;

procedure TSGLMainForm.Hideonstartup1Click(Sender: TObject);
begin
  with Sender as TMenuItem do
   begin
    Checked := not Checked;
    FConfig.WriteBool('SGAllSettings', 'HideInTray', Checked);
    FConfig.UpdateFile;
   end;
end;

procedure TSGLMainForm.ShowToolBarClick(Sender: TObject);
begin
with Sender as TMenuItem do
   begin
    Checked := not Checked;
    ToolBar1.Visible := Checked;
    FConfig.WriteBool('SGAllSettings', 'ShowToolBar', Checked);
    FConfig.UpdateFile;
   end;
end;

procedure TSGLMainForm.EmptyWorkingSet1Click(Sender: TObject);
begin
with Sender as TMenuItem do
   begin
    Checked := not Checked;
    FConfig.WriteBool('SGAllSettings', 'EmptyWorkingSet', Checked);
    FConfig.UpdateFile;
   end;
ShowMessage('Changes will take effect after restarting ' + ExtractFileName(ChangeFileExt(ParamStr(0),'')));
end;

procedure TSGLMainForm.Specifyfolders1Click(Sender: TObject);
begin
  with DiagForm do
   begin
    Caption := 'Specify folder';
    Position := poDesktopCenter;
    ActiveControl := Edit1;
    Label2.Caption := 'Changes will take effect after switching tabs.';
    Button3.Hint := 'Select a dir';
    ifFile := False;
    Edit1.Text := FConfig.ReadString('SGAllSettings', 'IgnoreDir', '');
    DialogDir := LaunchBoxDir;
     if (Showmodal <> mrCancel) then
      begin
       FConfig.WriteString('SGAllSettings', 'IgnoreDir', Edit1.Text);
       FConfig.UpdateFile;
       IgnoreDir := Edit1.Text;

       // Обновляем кэшированный список:
       FIgnoredFolders.Clear;
       StrToList(IgnoreDir, ';', FIgnoredFolders);
      end;
   end;
end;

procedure TSGLMainForm.Specifylanguagefolders1Click(Sender: TObject);
begin
  with DiagForm do
   begin
    Caption := 'Specify languages folder';
    Position := poDesktopCenter;
    ActiveControl := Edit1;
    Label2.Caption := 'Changes will take effect after switching tabs.';
    Button3.Hint := 'Select a dir';
    ifFile := False;
    Edit1.Text := FConfig.ReadString('SGAllSettings', 'LanguagesPack', '');
    DialogDir := LaunchBoxDir;
     if (Showmodal <> mrCancel) then
      begin
       FConfig.WriteString('SGAllSettings', 'LanguagesPack', Edit1.Text);
       FConfig.UpdateFile;
      end;
   end;
end;

procedure TSGLMainForm.About1Click(Sender: TObject);
begin
with HelpForm do
   begin
     Position := poDesktopCenter;
     Label2.Caption := 'ReleaseDate: ' + sReleaseDate;
     HELPFORM_PAGECTRL1.ActivePageIndex := 0;
     Show;
   end;
end;

procedure TSGLMainForm.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TSGLMainForm.OnExtrasMenuItemClick(Sender: TObject);
var
  MenuItem: TMenuItem;
  FullPath: string;
begin
  if Sender is TMenuItem then
  begin
    MenuItem := TMenuItem(Sender);
    FullPath := MenuItem.Hint;
    ShellOpen(FullPath);
  end;
end;

procedure TSGLMainForm.Run1Click(Sender: TObject);
begin
  ListView1DblClick(Sender);
end;

procedure TSGLMainForm.Configuration1Click(Sender: TObject);
begin
 if ListView1.ItemIndex <> -1 then
    ShellOpen(LaunchBoxDir +'\'+FGameData[FFilteredIndices[ListView1.ItemIndex]].ConfigurationPath);
end;

procedure TSGLMainForm.Manual1Click(Sender: TObject);
begin
 if ListView1.ItemIndex <> -1 then
    ShellOpen(LaunchBoxDir +'\'+FGameData[FFilteredIndices[ListView1.ItemIndex]].Manual);
end;

procedure TSGLMainForm.Customimagename1Click(Sender: TObject);
begin
  with DiagForm do
   begin
    Caption := ListView1.Selected.Caption;
    Position := poDesktopCenter;
    ActiveControl := Edit1;
    Label2.Caption := 'Example: Tomb Raider Gold-01.jpg > Tomb Raider Gold';
    Button3.Hint := 'Select an image';
    ifFile := True;
    Edit1.Text := NConfig.ReadString(FGameData[FFilteredIndices[ListView1.ItemIndex]].Platforms,
      FGameData[FFilteredIndices[ListView1.ItemIndex]].ID, '');
    DialogDir := LaunchBoxDir + '\Images\' + FGameData[FFilteredIndices[ListView1.ItemIndex]].Platforms;
     if (Showmodal <> mrCancel) then
      begin
       if Edit1.Text = '' then
       NConfig.DeleteKey(FGameData[FFilteredIndices[ListView1.ItemIndex]].Platforms,
         FGameData[FFilteredIndices[ListView1.ItemIndex]].ID)
       else
       NConfig.WriteString(FGameData[FFilteredIndices[ListView1.ItemIndex]].Platforms,
         FGameData[FFilteredIndices[ListView1.ItemIndex]].ID, Edit1.Text);
       NConfig.UpdateFile;
      end;
   end;
end;

procedure TSGLMainForm.DesktopShortcut1Click(Sender: TObject);
begin
  CreateDesktopShellLink(ExcludeTrailingPathDelimiter(LaunchBoxDir) +'\'+
  FGameData[FFilteredIndices[ListView1.ItemIndex]].ApplicationPath, ListView1.Selected.Caption);
end;

//----TOOLBAR----
//------------------------------------------------------------------------------
procedure TSGLMainForm.ToolBar1Click(Sender: TObject);
var
 TempList: TStringList;
 WorkingDir: String;
 IniValue: String;
begin
 if not (Sender is TToolButton) then Exit;

 TempList := TStringList.Create;
 try
  // Читаем значение из INI
  IniValue := FConfig.ReadString('ToolBar', TToolButton(Sender).Hint, '');

  // Проверяем, что значение не пустое
  if IniValue = '' then
    Exit;

  // Разбираем строку
  StrToList(IniValue, '|', TempList);

  // Проверяем минимальное количество элементов
  if TempList.Count < 1 then
    Exit;

  // Определяем рабочую директорию
  if (TempList.Count > 2) and (TempList[2] <> '') then
    WorkingDir := TempList[2]
  else
    WorkingDir := ExtractFilePath(TempList[0]);

  // Запускаем приложение
  ShellExecute(0, 'open',
               PChar(TempList[0]),  // Путь к файлу
               PChar(IfThen(TempList.Count > 1, TempList[1], '')),  // Параметры
               PChar(WorkingDir),   // Рабочая директория
               SW_SHOWNORMAL);
 finally
  TempList.Free;
 end;
end;

procedure TSGLMainForm.ToolBarTop1Click(Sender: TObject);
var
  I: Integer;
  Root: TMenuItem;
  AlignValue: Integer;
begin
  if not (Sender is TMenuItem) then Exit;

  Root := TMenuItem(Sender).Parent;

  // снимаем все галочки
  for I := 0 to Root.Count - 1 do
    Root.Items[I].Checked := False;

  TMenuItem(Sender).Checked := True;

  AlignValue :=
    GetEnumValue(TypeInfo(TAlign), TMenuItem(Sender).Hint);

  if AlignValue >= 0 then
    ToolBar1.Align := TAlign(AlignValue);

  case ToolBar1.Align of
    alTop, alBottom:
      ToolBar1.Height := 40;

    alLeft, alRight:
      ToolBar1.Width := 40;
  end;
end;

procedure TSGLMainForm.ToolBarMenuClick(Sender: TObject);
var
  MenuItem: TMenuItem;
  Button: TToolButton;
  Popup: TPopupMenu;
  Index: WORD;
  TempList: TStringList;
  OldHint, DialogDir: String;
begin
  if not (Sender is TMenuItem) then Exit;
  MenuItem := TMenuItem(Sender);

  Popup := TPopupMenu(MenuItem.GetParentMenu);
  if Popup = nil then Exit;

  if Popup.PopupComponent is TToolButton then
    Button := TToolButton(Popup.PopupComponent)
  else
    Button := nil;

  // ────────────────────── Обработка пунктов меню ──────────────────────
  if MenuItem.Name = 'miDelete' then
  begin
    if Assigned(Button) then
      DeleteToolButton(ToolBar1, Button.Hint, FConfig, ImageList1, ToolBar1Click);
  end

  else if MenuItem.Name = 'miAddButton' then
  begin
   if OpenDialogEx('Select the executable file', True, DialogDir) then
    begin
     with ToolBtnPropertiesForm do
        begin
         LNKPROP_EDIT1.EditText := ExtractFileName(ChangeFileExt(DialogDir,''));
         LNKPROP_EDIT2.EditText := DialogDir;
         LNKPROP_EDIT3.EditText := '';
         LNKPROP_EDIT4.EditText := '';
         LNKPROP_EDIT5.EditText := '';
         // Загрузка иконки
          Index := 0;
          if (LNKPROP_EDIT5.Text = '') and (LNKPROP_EDIT2.Text <> '') then
            Image1.Picture.Icon.Handle := ExtractAssociatedIcon(hInstance, PChar(LNKPROP_EDIT2.Text), Index)
          else if LNKPROP_EDIT5.Text <> '' then
            Image1.Picture.Icon.Handle := ExtractAssociatedIcon(hInstance, PChar(LNKPROP_EDIT5.Text), Index);
          if ShowModal <> mrCancel then
           begin
            // ← СОХРАНЯЕМ новую запись
            FConfig.WriteString('Toolbar', LNKPROP_EDIT1.EditText,
              LNKPROP_EDIT2.EditText + '|' + LNKPROP_EDIT3.EditText + '|' +
              LNKPROP_EDIT4.EditText + '|' +LNKPROP_EDIT5.EditText);
            FConfig.UpdateFile;

            // ← ПЕРЕЗАГРУЖАЕМ кнопки
            ToolBar1.AutoSize := False;
            LoadToolButtons(ToolBar1, FConfig, ImageList1, ToolBar1Click);
            ToolBar1.AutoSize := True;
           end;
        end;
    end;
  end

  else if MenuItem.Name = 'miProperties' then
  begin
    if Assigned(Button) then
    begin
      TempList := TStringList.Create;
      try
        // ← СОХРАНЯЕМ старый Hint ДО изменения
        OldHint := Button.Hint;

        // Разбираем текущие значения кнопки
        StrToList(FConfig.ReadString('Toolbar', Button.Hint, ''), '|', TempList);

        with ToolBtnPropertiesForm do
        begin
          Caption := Button.Hint;
          LNKPROP_EDIT1.EditText := Button.Hint;

          // ← Проверка и заполнение полей
          if TempList.Count >= 1 then
            LNKPROP_EDIT2.EditText := TempList[0]
          else
            LNKPROP_EDIT2.EditText := '';

          if TempList.Count >= 2 then
            LNKPROP_EDIT3.EditText := TempList[1]
          else
            LNKPROP_EDIT3.EditText := '';

          if TempList.Count >= 3 then
            LNKPROP_EDIT4.EditText := TempList[2]
          else
            LNKPROP_EDIT4.EditText := '';

          if TempList.Count >= 4 then
            LNKPROP_EDIT5.EditText := TempList[3]
          else
            LNKPROP_EDIT5.EditText := '';

          // Загрузка иконки
          Index := 0;
          if (LNKPROP_EDIT5.Text = '') and (LNKPROP_EDIT2.Text <> '') then
            Image1.Picture.Icon.Handle := ExtractAssociatedIcon(hInstance, PChar(LNKPROP_EDIT2.Text), Index)
          else if LNKPROP_EDIT5.Text <> '' then
            Image1.Picture.Icon.Handle := ExtractAssociatedIcon(hInstance, PChar(LNKPROP_EDIT5.Text), Index);

          // ← Показываем диалог
          if ShowModal <> mrCancel then
          begin
            // ← УДАЛЯЕМ старую запись (используем сохранённый OldHint)
            if OldHint <> LNKPROP_EDIT1.EditText then
              FConfig.DeleteKey('Toolbar', OldHint);

            // ← СОХРАНЯЕМ новую запись
            FConfig.WriteString('Toolbar', LNKPROP_EDIT1.EditText,
              LNKPROP_EDIT2.EditText + '|' +
              LNKPROP_EDIT3.EditText + '|' +
              LNKPROP_EDIT4.EditText + '|' +
              LNKPROP_EDIT5.EditText);
            FConfig.UpdateFile;

            // ← ПЕРЕЗАГРУЖАЕМ кнопки
            ToolBar1.AutoSize := False;
            LoadToolButtons(ToolBar1, FConfig, ImageList1, ToolBar1Click);
            ToolBar1.AutoSize := True;
          end;
        end;
      finally
        TempList.Free;
      end;
    end;
  end;
end;

end.
