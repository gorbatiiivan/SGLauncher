unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Types,
  System.IOUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons, Vcl.Imaging.jpeg, Vcl.Imaging.pngimage,
  Vcl.Imaging.GIFImg, ShellAPI, System.ImageList, Vcl.ImgList, Vcl.ToolWin,
  IniFiles, ShlObj, StrUtils, System.Generics.Collections,Vcl.Themes,
  System.TypInfo, SyncObjs, Math, Winapi.CommCtrl, System.DateUtils,
  Vcl.ActnPopup, Vcl.PlatformDefaultStyleActnCtrls, Vcl.Menus, Vcl.TabView,
  Vcl.TitleBarCtrls, Vcl.NavView;

const
  //Бинарный кэш для игр
  CACHE_VERSION: Word = 2;

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
    CommandLine: string;
    PlayMode: string;
    Source: string;
    ConfigurationCommandLine: string;
    Emulator: string;
  end;

  TTileEntry = class
    Bmp: TBitmap;
    LastUsed: Cardinal;
    destructor Destroy; override;
  end;

  TTileRequest = record
    ID, RawID, Platform, GameName, Year, ForceName: string;
    RealIndex, ItemIndex: Integer;
    Side: Integer;
  end;

type
  TSGLMainForm = class(TForm)
    TrayIcon: TTrayIcon;
    ToolBar1: TToolBar;
    ImageList1: TImageList;
    TrayPopupActionBar: TPopupActionBar;
    ShowMenuItem: TMenuItem;
    N11: TMenuItem;
    Options2: TMenuItem;
    SpecifylanguagefoldersMenuItem: TMenuItem;
    SpecifyfoldersMenuItem: TMenuItem;
    N12: TMenuItem;
    Core2: TMenuItem;
    EmptyWorkingSetMenuItem: TMenuItem;
    UseBinaryCacheMenuItem: TMenuItem;
    oolBar1: TMenuItem;
    ToolBarAlignMenuItem: TMenuItem;
    ToolBarRightMenuItem: TMenuItem;
    ToolBarLeftMenuItem: TMenuItem;
    ToolBarBottomMenuItem: TMenuItem;
    ToolBarTopMenuItem: TMenuItem;
    ToolBarShowMenuItem: TMenuItem;
    StyleMenuItem: TMenuItem;
    GameDetails2: TMenuItem;
    EnabledimagegalleryMenuItem: TMenuItem;
    ShowGameDetailsMenuItem: TMenuItem;
    ListView2: TMenuItem;
    ShowImageonHoverMenuItem: TMenuItem;
    N13: TMenuItem;
    ViewasListMenuItem: TMenuItem;
    ViewasThumbnailsMenuItem: TMenuItem;
    HideonstartupMenuItem: TMenuItem;
    AutostartMenuItem: TMenuItem;
    N14: TMenuItem;
    AboutMenuItem: TMenuItem;
    N15: TMenuItem;
    ExitMenuItem: TMenuItem;
    ListViewPopupActionBar: TPopupActionBar;
    RunMenuItem: TMenuItem;
    ConfigurationMenuItem: TMenuItem;
    N3: TMenuItem;
    DownloadarchiveMenuItem: TMenuItem;
    DeletearchiveMenuItem: TMenuItem;
    N4: TMenuItem;
    AddtoFavoritesMenuItem: TMenuItem;
    N5: TMenuItem;
    ManualMenuItem: TMenuItem;
    N6: TMenuItem;
    CreatedesktopshortcutMenuItem: TMenuItem;
    N10: TMenuItem;
    CustomimagenameMenuItem: TMenuItem;
    sepDynamicStart: TMenuItem;
    pmPlatformFilter: TPopupActionBar;
    TabView1: TTabView;
    Panel1: TPanel;
    Splitter2: TSplitter;
    Panel2: TPanel;
    ScreenShotImage: TImage;
    NextImgBtn: TSpeedButton;
    PrevImgBtn: TSpeedButton;
    Splitter3: TSplitter;
    ScrollBox2: TScrollBox;
    FlowPanel1: TFlowPanel;
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
    PlayModeLabel: TLabel;
    Panel3: TPanel;
    ListView1: TListView;
    Panel4: TPanel;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    PlatformBtn: TButton;
    Splitter1: TSplitter;
    TitleBarPanel1: TTitleBarPanel;
    NavigationView1: TNavigationView;
    Splitter4: TSplitter;
    VerticaltabsMenuItem: TMenuItem;
    BtnMenu: TButton;
    Image1: TImage;
    ShowImagesMenuItem: TMenuItem;
    Edit1: TEdit;
    procedure FormResize(Sender: TObject);
    procedure ListView1Data(Sender: TObject; Item: TListItem);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure ComboBox1Change(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure ScreenShotImageClick(Sender: TObject);
    procedure ListView1DblClick(Sender: TObject);
    procedure TrayIconClick(Sender: TObject);
    procedure ListView1KeyPress(Sender: TObject; var Key: Char);
    procedure ListView1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure NextImgBtnClick(Sender: TObject);
    procedure PrevImgBtnClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ListView1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ToolBar1Click(Sender: TObject);
    procedure ToolBarTop1Click(Sender: TObject);
    procedure Splitter3Moved(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure DeveloperLabelMouseEnter(Sender: TObject);
    procedure DeveloperLabelMouseLeave(Sender: TObject);
    procedure DeveloperLabelClick(Sender: TObject);
    procedure PlatformBtnClick(Sender: TObject);
    procedure ListView1AdvancedCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; Stage: TCustomDrawStage;
      var DefaultDraw: Boolean);
    procedure ListView1MouseLeave(Sender: TObject);
    procedure ExitMenuItemClick(Sender: TObject);
    procedure AboutMenuItemClick(Sender: TObject);
    procedure AutostartMenuItemClick(Sender: TObject);
    procedure HideonstartupMenuItemClick(Sender: TObject);
    procedure ViewasThumbnailsMenuItemClick(Sender: TObject);
    procedure ViewasListMenuItemClick(Sender: TObject);
    procedure ShowImageonHoverMenuItemClick(Sender: TObject);
    procedure ShowGameDetailsMenuItemClick(Sender: TObject);
    procedure EnabledimagegalleryMenuItemClick(Sender: TObject);
    procedure ToolBarShowMenuItemClick(Sender: TObject);
    procedure UseBinaryCacheMenuItemClick(Sender: TObject);
    procedure EmptyWorkingSetMenuItemClick(Sender: TObject);
    procedure SpecifyfoldersMenuItemClick(Sender: TObject);
    procedure SpecifylanguagefoldersMenuItemClick(Sender: TObject);
    procedure RunMenuItemClick(Sender: TObject);
    procedure ConfigurationMenuItemClick(Sender: TObject);
    procedure DownloadarchiveMenuItemClick(Sender: TObject);
    procedure DeletearchiveMenuItemClick(Sender: TObject);
    procedure AddtoFavoritesMenuItemClick(Sender: TObject);
    procedure ManualMenuItemClick(Sender: TObject);
    procedure CreatedesktopshortcutMenuItemClick(Sender: TObject);
    procedure CustomimagenameMenuItemClick(Sender: TObject);
    procedure PopupActionBar1Popup(Sender: TObject);
    procedure TabView1ChangeTab(Sender: TObject);
    procedure TitleBarPanel1CustomButtons0Paint(Sender: TObject);
    procedure TitleBarPanel1CustomButtons0Click(Sender: TObject);
    procedure NavigationView1ChangeItem(Sender: TObject);
    procedure VerticaltabsMenuItemClick(Sender: TObject);
    procedure BtnMenuClick(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image1DblClick(Sender: TObject);
    procedure ShowImagesMenuItemClick(Sender: TObject);
  protected
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
    FLastInstalledRefresh: TDateTime;   // Время последней проверки ФС
    // Таймер для переключение игр в ListView
    FSelectionTimer: TTimer;
    FPendingItemIndex: Integer;   // -1 = нет ожидающего выделения
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
    // Эмуляторы (из Data\Emulators.xml)
    FEmuAppPaths: TDictionary<string, string>;  // EmuID -> ApplicationPath (exe)
    FEmuCmdLines: TDictionary<string, string>;  // EmuID|Platform -> CommandLine
    FEmuByPlatformDefaults: TDictionary<string, string>; // Platform -> EmuID (Default=true)
    // Кэш распарсенных LanguagesPack по платформам
    FLangPackCache: TDictionary<string, TStringList>;
    FLangPackLock:  TCriticalSection;
    // Для поиска
    FTypeBuffer: string;
    FLastTypeTick: Cardinal;
    // Для потоковой загрузки изображений
    FImageLoadThread: TThread;
    FImageLoadPending: Boolean;        // Флаг, что нужно загрузить изображения
    FImageLoadGameIndex: Integer;      // Индекс игры для загрузки
    FImageLoadRealIndex: Integer;      // Реальный индекс в FGameData
    FImageLoadItemIndex: Integer;      // Индекс в ListView
    FImageLoadLock: TCriticalSection;  // Для синхронизации доступа к данным
    FImageGeneration: Integer;         // счётчик поколений
    // Кэш списка файлов изображений по платформам
    FImageFileCache:     TDictionary<string, TStringDynArray>;
    FImageFileCacheLock: TCriticalSection;
    //Для миниатюр
    FSelectedPanel: TPanel;
    FAllImageFiles: TArray<string>;
    FCurrentLoadedCount: Integer;
    FBatchSize: Integer;
    FThumbnailGeneration: Integer;
    // Для потоковой загрузки миниатюр
    FThumbnailLoadThread: TThread;
    FThumbnailLock: TCriticalSection;
    FThumbnailCancel: Boolean;
    FThumbnailPending: Boolean;
    FCurrentThumbnailIndex: Integer;
	  // Для отмены загрузки полного изображения:
    FFullImageThread: TThread;
    FFullImageCancel: Boolean;
    //Динамические размеры миниатюр
    FThumbWidth: Integer;
    FThumbHeight: Integer;
    PADDING2: Integer;
    // Для фильтра по платформам
    FSelectedPlatformsAll: TStringList;      // Для вкладки "All"
    FSelectedPlatformsInstalled: TStringList; // Для вкладки "Installed"
    FPlatformFilterActiveAll: Boolean;
    FPlatformFilterActiveInstalled: Boolean;
    // Избранные
    FSelectedPlatformsFavorites: TStringList;
    FPlatformFilterActiveFavorites: Boolean;
    FFavoriteIDs: TDictionary<string, Boolean>; // Кэш ID избранных игр в памяти
    // ListView imagelist thumbnails
    FListItemHeightImages: TImageList;
    // Превью скриншота при наведении (Hot) на плитку ListView
    FHoverBitmap:       TBitmap;          // текущая превью-картинка (переиспользуется)
    FHoverBitmapID:     string;           // ID игры, чья картинка сейчас в FHoverBitmap
    FHoverQueuedID:     string;           // ID игры, которую сейчас декодирует поток ('' = нет)
    FHoverLock:         TCriticalSection; // защита FHoverPendingIndex/FHoverQueuedID
    FHoverEvent:        TEvent;           // сигнал потоку "появился новый запрос"
    FHoverPendingIndex: Integer;          // RealIndex к обработке (-1 = нет), затирается новым hover
    FHoverLoadThread:   TThread;
    FShowImageOnHover: Boolean;           // Показываем изображение по курсору
    // Debounce + кэш путей для превью по наведению
    FHoverDwellTimer:  TTimer;            // старт поиска картинки только после задержки курсора
    FHoverDwellID:     string;            // ID элемента, ожидающего срабатывания таймера
    FHoverDwellIndex:  Integer;           // RealIndex элемента, ожидающего срабатывания таймера
    FHoverPathCache:   TDictionary<string, string>; // GameID -> найденный путь (не сбрасывается при уходе курсора)
    FHoverNotFoundCache: TDictionary<string, TDateTime>; // GameID -> момент, когда закэшировано "не найдено" (TTL, см. HOVER_NOTFOUND_TTL_SEC)
    SkipHoverImage: Boolean;                           // Необходимо чтобы появилось надписи на квадратом с FHoverNotFoundCache
    FViewAsList: Boolean;
    // Переключение на вертикальные вкладки
    FUpdatingNavView: Boolean;
    // Миниатюры видимых элементов ListView
    FTileCache:   TObjectDictionary<string, TTileEntry>; // только главный поток
    FTileNoImage: TDictionary<string, Boolean>;          // ID без картинки
    FTileQueued:  TDictionary<string, Boolean>;          // ID в очереди (под FTileLock)
    FTileStack:   TList<TTileRequest>;                   // LIFO (под FTileLock)
    FTileLock:    TCriticalSection;
    FTileEvent:   TEvent;
    FTileThread:  TThread;
    FTileGen:     Integer;
    FTileRepaintPending: Boolean;
    FTileFolderIndex: TObjectDictionary<string, TDictionary<string, string>>; // платформа -> (имя файла в нижнем регистре -> путь); только поток миниатюр
    FShowListImages: Boolean;
    //----------------------
    //----CONFIG----
    function GetFConfig: TMemIniFile;
    function GetNConfig: TMemIniFile;
    function GetFTorrentConfig: TMemIniFile; //Загрузка торрентов
    procedure RegIni(Write: Boolean);
    //----FORM----
    procedure WMPostScrollSync(var Msg: TMessage); message WM_USER + 100;
    procedure WMCopyData(var Msg: TWMCopyData); message WM_COPYDATA;
    //----OTHER COMPONENTS----
    procedure ApplyTransparentBackgroundToInfoPanel;
    procedure StyleMenuClick(Sender: TObject);
    //----MENUEXTRAS----
    procedure OnExtrasMenuItemClick(Sender: TObject);
    //----TOOLBAR----
    procedure PinToolBarOnTop;
    procedure ToolBarMenuClick(Sender: TObject);
    // Переключение фильтр по информационным лейблам
    procedure ApplyLabelFilter(const Category: string; const Value: string);
    procedure LabelFilterMenuItemClick(Sender: TObject);
    // ListView thumbnails
    procedure ResizeListViewTiles(Delta: Integer);
    function GetListViewUsableWidth: Integer;
    // Переключение на вертикальные вкладки
    procedure SyncNavigationViewFromTabView;
    procedure SyncNavViewSelection;
    procedure ApplyTabsLayout(Vertical: Boolean);
   public
    FConfig: TMemIniFile;
    FTorrentConfig: TMemIniFile;
  end;

var
  SGLMainForm: TSGLMainForm;
  LaunchBoxDir: String = '';
  IgnoreDir: String;
  HideInTray: Boolean = False;
  EnabledMiniatures: Boolean = False;
  CachedAt: TDateTime;

implementation

{$R *.dfm}

uses FullScreenImage, DialogForm, Help, ToolBtnProperties, GamesCore,
     SystemUtils, ToolBars;

destructor TTileEntry.Destroy;
begin
  Bmp.Free;
  inherited;
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

function TSGLMainForm.GetFTorrentConfig: TMemIniFile;
begin
  if FTorrentConfig = nil then
  FTorrentConfig := TMemIniFile.Create(ExtractFilePath(ParamStr(0)) + 'torrents\torrents.txt', TEncoding.UTF8);
  Result := FTorrentConfig;
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
  if FConfig.ReadBool('SGAllSettings', 'ShowDetailsPanel', True) then
    FConfig.WriteInteger('SGAllSettings', 'ListViewWidth', Panel3.Width);
  FConfig.WriteInteger('SGAllSettings', 'InfoPanelHeight', ScrollBox1.Height);
  FConfig.WriteBool('SGAllSettings', 'ShowToolBar', ToolBar1.Visible);
  FConfig.WriteString('SGAllSettings', 'ToolBarPosition', GetEnumName(TypeInfo(TAlign), Ord(ToolBar1.Align)));
  FConfig.WriteString('SGAllSettings', 'Styles', TStyleManager.ActiveStyle.Name);
  if TabView1.Tabs.Count > 0 then
    FConfig.WriteString('SGAllSettings', 'LastTab', TabView1.Tabs[TabView1.TabIndex].Caption);
  if EnabledMiniatures then
    FConfig.WriteInteger('SGAllSettings', 'ThumbPos', ScrollBox2.Height);
  FConfig.WriteInteger('SGAllSettings', 'LastFilterCategory', ComboBox1.ItemIndex);
  FConfig.WriteInteger('SGAllSettings', 'NavViewWidth', NavigationView1.Width);
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
  HideonstartupMenuItem.Checked := FConfig.ReadBool('SGAllSettings', 'HideInTray', False);
  if isIconic(Handle) then
  ShowMenuItem.Caption := 'Show' else ShowMenuItem.Caption := 'Hide';
  if FConfig.ReadBool('SGAllSettings', 'ShowDetailsPanel', True) then
    Panel3.Width := FConfig.ReadInteger('SGAllSettings', 'ListViewWidth', SGLMainForm.Width div 3);
  NavigationView1.Width := FConfig.ReadInteger('SGAllSettings', 'NavViewWidth',NavigationView1.Width);
  if NavigationView1.Width < 80 then NavigationView1.Width := 180;
  ScrollBox1.Height := FConfig.ReadInteger('SGAllSettings', 'InfoPanelHeight', ScrollBox1.Height);
  if FConfig.ReadBool('SGAllSettings', 'ShowToolBar', False) then
   begin
    ToolBar1.Visible := True;
    ToolBarShowMenuItem.Checked := True;
   end else
   begin
    ToolBar1.Visible := False;
    ToolBarShowMenuItem.Checked := False;
   end;
  //ToolBar
  s := FConfig.ReadString('SGAllSettings', 'ToolBarPosition', 'alTop');
  ToolBar1.Align := TAlign(GetEnumValue(TypeInfo(TAlign), s));
  // Делаем ToolBar всегда первым в left
  PinToolBarOnTop;
  if ToolBar1.Align = alTop then ToolBar1.Top := -1;

  UpdateToolbarMenuChecks(ToolBarTopMenuItem, ToolBar1);
  //---------------------------------------------------------------------------
  AutostartMenuItem.Checked := IsInStartupFolder;
  EmptyWorkingSetMenuItem.Checked := FConfig.ReadBool('SGAllSettings', 'EmptyWorkingSet', False);
  if FConfig.ReadBool('SGAllSettings', 'Enabled miniatures', False) then
   begin
    EnabledMiniatures := True;
    ScrollBox2.Visible := True;
    EnabledimagegalleryMenuItem.Checked := True;
    Splitter3.Visible := True;
    ScrollBox2.Height := FConfig.ReadInteger('SGAllSettings', 'ThumbPos', ScrollBox2.Height);
    // Пересчитываем размер миниатюр под загруженную высоту
    FThumbHeight := ScrollBox2.Height - GetSystemMetrics(SM_CYHSCROLL) - (PADDING2 * 2) - 8;
    if FThumbHeight < 20 then FThumbHeight := 20;
    FThumbWidth  := MulDiv(FThumbHeight, 100, 74);
   end else
   begin
    EnabledMiniatures := False;
    ScrollBox2.Visible := False;
    EnabledimagegalleryMenuItem.Checked := False;
    Splitter3.Visible := False;
   end;
  // Принудительно заполняем ComboBox1 один раз при запуске
  ComboBox1.ItemIndex := FConfig.ReadInteger('SGAllSettings', 'LastFilterCategory', 0);
  FillGenreSeriesCombo('All');
  //---------------------------------------------------------------------------
  UseBinaryCacheMenuItem.Checked := FConfig.ReadBool('SGAllSettings', 'UseBinaryCache', False);
  if FConfig.ReadBool('SGAllSettings', 'ShowDetailsPanel', True) then
    begin
     ShowGameDetailsMenuItem.Checked := True;
     Panel3.Align := alLeft;
     Panel3.Width := FConfig.ReadInteger('SGAllSettings', 'ListViewWidth', SGLMainForm.Width div 3);
     Splitter1.Visible := True;
     Splitter1.Align := alLeft;
     Panel1.Visible := True;
     EnabledimagegalleryMenuItem.Enabled := True;
    end else
    begin
     ShowGameDetailsMenuItem.Checked := False;
     Panel1.Visible := False;
     Splitter1.Visible := False;
     Panel3.Align := alClient;
     EnabledimagegalleryMenuItem.Enabled := False;
    end;
  FShowImageOnHover := FConfig.ReadBool('SGAllSettings', 'ShowImageOnHover', False);
  FShowListImages := FConfig.ReadBool('SGAllSettings', 'ShowListImages', False);
  ShowImagesMenuItem.Checked := FShowListImages;
  ShowImageonHoverMenuItem.Checked := FShowImageOnHover;
  ViewasThumbnailsMenuItem.Checked := FConfig.ReadBool('SGAllSettings', 'ViewAsIcons', False);
  ViewasListMenuItem.Checked := FConfig.ReadBool('SGAllSettings', 'ViewAsList', False);
  FViewAsList         := ViewasListMenuItem.Checked;
  ShowImageonHoverMenuItem.Enabled := ViewasThumbnailsMenuItem.Checked or ViewasListMenuItem.Checked;
  if FViewAsList then
  begin
    ListView1.ViewStyle := vsIcon;
    ListView1.LargeImages := nil;
    FListItemHeightImages.Width  := 100;
    FListItemHeightImages.Height := 50;
    ListView1.LargeImages := FListItemHeightImages;
    ListView1.OnAdvancedCustomDrawItem := ListView1AdvancedCustomDrawItem;
    ResizeListViewTiles(0);
  end
  else if ViewasThumbnailsMenuItem.Checked then
  begin
    ListView1.ViewStyle := vsIcon;
    FListItemHeightImages.Width  := FConfig.ReadInteger('SGAllSettings', 'TileWidth', 125);
    FListItemHeightImages.Height := FConfig.ReadInteger('SGAllSettings', 'TileHeight', 100);
    ListView1.LargeImages := FListItemHeightImages;
    ListView1.OnAdvancedCustomDrawItem := ListView1AdvancedCustomDrawItem;
  end else
  begin
    ListView1.ViewStyle := vsReport;
    ListView1.OnAdvancedCustomDrawItem := nil;
  end;
  VerticaltabsMenuItem.Checked := FConfig.ReadBool('SGAllSettings', 'VerticalTabs', False);
  ApplyTabsLayout(VerticaltabsMenuItem.Checked);
 end;
end;

//----FORM----
//------------------------------------------------------------------------------

procedure TSGLMainForm.WMPostScrollSync(var Msg: TMessage);
begin
  // Синхронизируем прокрутку к первому элементу после того, как UI обновился
  if not FClosing and (FlowPanel1.ControlCount > 0) then
  begin
    ScrollBox2.HorzScrollBar.Position := 0;
    FlowPanel1.Realign;
  end;
end;

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
var
  WaitCount: Integer;
  TempFolder: String;
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

  if Assigned(FSelectionTimer) then
  begin
    FSelectionTimer.Enabled := False;
    FSelectionTimer.Free;
  end;

  if Assigned(FGameDataLock) then FreeAndNil(FGameDataLock);
  if Assigned(FGameDict) then FreeAndNil(FGameDict);

  CanClose := True;

  // Освобождение ресурсов
  if Assigned(ImgList) then FreeAndNil(ImgList);
  if Assigned(FIgnoredFolders) then FreeAndNil(FIgnoredFolders);

  // Кэш распарсенных LanguagesPack по платформам
  if Assigned(FLangPackCache) then
  begin
    for var SL in FLangPackCache.Values do SL.Free;
    FreeAndNil(FLangPackCache);
  end;
  if Assigned(FLangPackLock) then FreeAndNil(FLangPackLock);

  // Кэш списка файлов изображений по платформам
  if Assigned(FImageFileCache) then
  begin
    FImageFileCache.Clear; // TStringDynArray освобождать вручную не нужно
    FreeAndNil(FImageFileCache);
  end;
  if Assigned(FImageFileCacheLock) then FreeAndNil(FImageFileCacheLock);

  if EnabledMiniatures then
  begin
  // Останавливаем загрузку миниатюр
  if Assigned(FThumbnailLock) then
  begin
    FThumbnailLock.Enter;
    try
      FThumbnailCancel := True;
      FThumbnailPending := False;
    finally
      FThumbnailLock.Leave;
    end;
  end;
  // завершения потока миниатюр с увеличенным таймаутом
  if Assigned(FThumbnailLoadThread) then
  begin
    FThumbnailLoadThread.Terminate;
    FThumbnailLoadThread.WaitFor;
    FreeAndNil(FThumbnailLoadThread);
  end;

  if Assigned(FFullImageThread) then
  begin
    FFullImageThread.Terminate;
    FFullImageThread.WaitFor;
    FreeAndNil(FFullImageThread);
  end;
  end;

  if Assigned(FImageLoadLock) then FreeAndNil(FImageLoadLock);
  if Assigned(FTabChangeLock) then FreeAndNil(FTabChangeLock);

  // Эмуляторы
  if Assigned(FEmuAppPaths) then FreeAndNil(FEmuAppPaths);
  if Assigned(FEmuCmdLines) then FreeAndNil(FEmuCmdLines);
  if Assigned(FEmuByPlatformDefaults) then FreeAndNil(FEmuByPlatformDefaults);

  // Для фильтра по платформам
  if Assigned(FSelectedPlatformsAll) then FreeAndNil(FSelectedPlatformsAll);
  if Assigned(FSelectedPlatformsInstalled) then FreeAndNil(FSelectedPlatformsInstalled);
  if Assigned(FSelectedPlatformsFavorites) then FreeAndNil(FSelectedPlatformsFavorites);
  // Ибранные
  if Assigned(FFavoriteIDs) then FreeAndNil(FFavoriteIDs);
  // ListView thumbnails
  if Assigned(FListItemHeightImages) then FreeAndNil(FListItemHeightImages);
  // Превью по наведению (Hot) в ListView
  if Assigned(FHoverLoadThread) then begin
    FHoverLoadThread.Terminate;
    if Assigned(FHoverEvent) then FHoverEvent.SetEvent; // разбудить поток, чтобы он вышел
    FHoverLoadThread.WaitFor;
    FreeAndNil(FHoverLoadThread);
  end;
  // Миниатюры видимых элементов ListView
  if Assigned(FTileThread) then
  begin
    ClearTileCache;
    FTileThread.Terminate;
    if Assigned(FTileEvent) then FTileEvent.SetEvent;
    FTileThread.WaitFor;
    FreeAndNil(FTileThread);
  end;
  FreeAndNil(FTileEvent);
  FreeAndNil(FTileLock);
  FreeAndNil(FTileStack);
  FreeAndNil(FTileQueued);
  FreeAndNil(FTileNoImage);
  FreeAndNil(FTileCache);
  FreeAndNil(FTileFolderIndex);

  if Assigned(FHoverEvent) then FreeAndNil(FHoverEvent);
  if Assigned(FHoverLock)  then FreeAndNil(FHoverLock);
  if Assigned(FHoverBitmap) then FreeAndNil(FHoverBitmap);
  if Assigned(FHoverDwellTimer) then FreeAndNil(FHoverDwellTimer);
  if Assigned(FHoverPathCache)  then FreeAndNil(FHoverPathCache);
  if Assigned(FHoverNotFoundCache)  then FreeAndNil(FHoverNotFoundCache);
  //------------------------------------

  RegIni(True);

  if Assigned(FConfig) then FreeAndNil(FConfig);
  if Assigned(NConfig) then FreeAndNil(NConfig);

  // Загрузка торрентов
  if Assigned(FTorrentConfig) then FreeAndNil(FTorrentConfig);
  // Удаление папки temp рядом с программой, если она есть
  TempFolder := ExtractFilePath(Application.ExeName) + 'temp';
  if TDirectory.Exists(TempFolder) then
  begin
    try
      TDirectory.Delete(TempFolder, True);
    except
      // игнорируем ошибку удаления (например, файл занят), чтобы не блокировать закрытие
    end;
  end;
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

  // Таймер для переключение игр в ListView
  FPendingItemIndex := -1;
  FLastInstalledRefresh := 0;
  FSelectionTimer := TTimer.Create(Self);
  FSelectionTimer.Interval := 80;        // 70-100 мс — оптимально
  FSelectionTimer.Enabled := False;
  FSelectionTimer.OnTimer := SelectionTimerTimer;

  FLastInstalledRefresh := 0;
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

  // Кэш распарсенных LanguagesPack по платформам
  FLangPackCache := TDictionary<string, TStringList>.Create;
  FLangPackLock  := TCriticalSection.Create;
  // Кэш списка файлов изображений по платформам
  FImageFileCache     := TDictionary<string, TStringDynArray>.Create;
  FImageFileCacheLock := TCriticalSection.Create;
  // Кастомная отрисовка элементов ListView
  FListItemHeightImages := TImageList.Create(Self);
  // Превью по наведению (Hot) в ListView
  FHoverBitmap := TBitmap.Create;
  FHoverBitmap.PixelFormat := pf32bit;
  FHoverLock   := TCriticalSection.Create;
  FHoverEvent  := TEvent.Create(nil, True, False, '');
  FHoverPendingIndex := -1;
  StartHoverLoadThread;
  FHoverPathCache  := TDictionary<string, string>.Create;
  FHoverDwellID    := '';
  FHoverDwellIndex := -1;
  FHoverDwellTimer := TTimer.Create(Self);
  FHoverDwellTimer.Interval := 150;   // задержка перед стартом поиска картинки
  FHoverDwellTimer.Enabled  := False;
  FHoverDwellTimer.OnTimer  := HoverDwellTimerTimer;
  FHoverNotFoundCache := TDictionary<string, TDateTime>.Create;
  // Миниатюры видимых элементов ListView
  FTileCache   := TObjectDictionary<string, TTileEntry>.Create([doOwnsValues]);
  FTileFolderIndex := TObjectDictionary<string, TDictionary<string, string>>.Create([doOwnsValues]);
  FTileNoImage := TDictionary<string, Boolean>.Create;
  FTileQueued  := TDictionary<string, Boolean>.Create;
  FTileStack   := TList<TTileRequest>.Create;
  FTileLock    := TCriticalSection.Create;
  FTileEvent   := TEvent.Create(nil, True, False, '');
  StartTileLoadThread;

  LaunchBoxDir := 'E:\LaunchBox'{GetExecPath};
  GetFConfig;
  GetNConfig;
  GetFTorrentConfig;
  RegIni(False);

  // Убираем рамку фокуса
  SendMessage(BtnMenu.Handle, WM_CHANGEUISTATE, MakeLong(UIS_SET, UISF_HIDEFOCUS), 0);

  // Загрузка эмуляторов из Data\Emulators.xml
  FEmuAppPaths := TDictionary<string, string>.Create;
  FEmuCmdLines := TDictionary<string, string>.Create;
  FEmuByPlatformDefaults := TDictionary<string, string>.Create;
  LoadEmulatorsXML;

  // Переключение на вертикальные вкладки
  FUpdatingNavView := False;

  if EnabledMiniatures then
  begin
   // Инициализация для миниатюр
   FThumbnailLock := TCriticalSection.Create;
   FThumbnailCancel := False;
   FThumbnailPending := False;
   FCurrentThumbnailIndex := 0;
   FThumbnailLoadThread := nil;
   FFullImageThread := nil;
   FFullImageCancel := False;
   FSelectedPanel := nil;
   FAllImageFiles := nil;
   FImageLoadThread := nil;
   FImageGeneration := 0;
   PADDING2 := 2;
   // Дополнительная настройка ScrollBox для корректной прокрутки
   ScrollBox2.HorzScrollBar.Increment := FThumbWidth + 8 + (PADDING2 * 2);
   ScrollBox2.DoubleBuffered := True;
   ScrollBox2.VertScrollBar.Visible := False;
   ScrollBox2.HorzScrollBar.Visible := True;
   ScrollBox2.HorzScrollBar.Tracking := True;
   FlowPanel1.DoubleBuffered := True;
   FlowPanel1.Align := alNone;
   FlowPanel1.AutoSize := False;
   FlowPanel1.FlowStyle := fsLeftRightTopBottom;
   FlowPanel1.AutoWrap := False;
  end;
  //------------------------------------

  FIgnoredFolders := TStringList.Create;
  FIgnoredFolders.CaseSensitive := False;
  StrToList(IgnoreDir, ';', FIgnoredFolders);

  SGLMainForm.Icon := LoadIconFromRCDATA('OnLoadIcon');
  TrayIcon.Icon := LoadIconFromRCDATA('OnLoadIcon');
  TrayIcon.Visible := True;
  Application.ShowMainForm := not FConfig.ReadBool('SGAllSettings', 'HideInTray', False);

  // Favorites
  FSelectedPlatformsFavorites := TStringList.Create;
  FSelectedPlatformsFavorites.Sorted := True;
  FSelectedPlatformsFavorites.Duplicates := dupIgnore;
  // Кэш ID избранных игр в памяти — грузим из FConfig один раз при старте
  FFavoriteIDs := TDictionary<string, Boolean>.Create;
  LoadFavoritesFromConfig;

  // Инициализация для фильтра платформ
  FSelectedPlatformsAll := TStringList.Create;
  FSelectedPlatformsAll.Sorted := True;
  FSelectedPlatformsAll.Duplicates := dupIgnore;
  FSelectedPlatformsInstalled := TStringList.Create;
  FSelectedPlatformsInstalled.Sorted := True;
  FSelectedPlatformsInstalled.Duplicates := dupIgnore;
  LoadPlatformFilterSettings; // Загружаем сохранённые настройки

  //ToolBar
  with ToolBtnPropertiesForm do
   begin
    LoadToolButtons(ToolBar1, FConfig, ImageList1, ToolBar1Click);
    AddItemToButtonPopup(ToolBar1, FConfig, Self, ToolBarMenuClick);
   end;

  //Создание список стиль
  BuildStylesMenu(StyleMenuItem, StyleMenuClick);
  StylesLoad(FConfig, StyleMenuItem);
  ApplyTransparentBackgroundToInfoPanel;

  FinalizeLoading;

  // Убираем мерцание в ListView когда включены стили
  ListView1.ControlStyle := ListView1.ControlStyle + [csOpaque];

  // Коррекции размера плиток при первом запуске
  if ViewasThumbnailsMenuItem.Checked then
    ResizeListViewTiles(0);

  // Делаем ToolBar всегда первым в left
  PinToolBarOnTop;
end;

procedure TSGLMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key = ORD(VK_F1) then AboutMenuItemClick(Sender);

 if Key = VK_F5 then
  begin
   if FConfig.ReadBool('SGAllSettings', 'UseBinaryCache', False) then
    begin
     FinalizeLoading(True);
     Key := 0;
     Exit;
    end;
  end;

  //Ctrl+Tab to change tabs
  if (ssCtrl in Shift) and (Ord(Key) = VK_TAB) then
  begin
    var NewIdx: Integer;
    if ssShift in Shift then
    begin
      if TabView1.TabIndex > 0 then
        NewIdx := TabView1.TabIndex - 1
      else
        NewIdx := TabView1.Tabs.Count - 1;
    end
    else
    begin
      if TabView1.TabIndex < TabView1.Tabs.Count - 1 then
        NewIdx := TabView1.TabIndex + 1
      else
        NewIdx := 0;
    end;

    FUpdatingNavView := True;
    try
      TabView1.TabIndex := NewIdx;   // OnChangeTab подавлен
    finally
      FUpdatingNavView := False;
    end;

    TabView1ChangeTab(TabView1);    // единственный явный вызов
    Key := 0;
    Exit;
  end;

  //Ctrl + '+' / Ctrl + '-' — размер плиток ListView (только vsIcon)
  if (ssCtrl in Shift) and ((Key = VK_OEM_PLUS) or (Key = VK_ADD)) then
   begin
    ResizeListViewTiles(15);
    Key := 0;
    Exit;
   end;

  if (ssCtrl in Shift) and ((Key = VK_OEM_MINUS) or (Key = VK_SUBTRACT)) then
   begin
    ResizeListViewTiles(-15);
    Key := 0;
    Exit;
   end;
end;

procedure TSGLMainForm.FormResize(Sender: TObject);
var
  NewW: Integer;
begin
  // Колонки в Report-режиме
  if ListView1.ViewStyle = vsReport then
    AutoSizeListViewColumns;

  Edit1.Width := Panel3.Width div 3 - 10;
  ComboBox1.Width := Edit1.Width - 10;
  ComboBox2.Width := Edit1.Width - 10;

  ResizeLabelToText(Label1);
  UpdateToolBarWrap(ToolBar1);

  //--- Миниатюры (нижняя галерея) ---
  if EnabledMiniatures and ScrollBox2.Visible then
  begin
    FlowPanel1.Height := ScrollBox2.Height - GetSystemMetrics(SM_CYHSCROLL);
    ScrollBox2.HorzScrollBar.Range := FlowPanel1.Width;
  end;

  //--- Плитки / список в ListView ---
  if not Assigned(FListItemHeightImages) then Exit;
  if ListView1.ViewStyle <> vsIcon then Exit;

  if FViewAsList then
  begin
    ResizeListViewTiles(0);
    Exit;
  end;
end;

//----FORM COMPONENTS----
//------------------------------------------------------------------------------

//----LISTVIEW----
//------------------------------------------------------------------------------
procedure TSGLMainForm.ListView1AdvancedCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; Stage: TCustomDrawStage;
  var DefaultDraw: Boolean);
const
  HOVER_NOTFOUND_TTL_SEC = 20;
  RADIUS = 6;

  //— Цвет тени под текущий стиль (было 15 строк if-else → 6 строк) —
  function ShadowColor(DefaultColor: TColor): TColor;
  const
    WhiteStyles: array[0..10] of string = (
      'Windows', 'Material Oxford Blue', 'Stellar Dark', 'Sky', 'Glow',
      'Windows11 Impressive Dark', 'Calypso', 'Calypso LE', 'Glossy',
      'Slate Classico', 'Windows11 Polar Dark');
  var
    i: Integer;
  begin
    for i := Low(WhiteStyles) to High(WhiteStyles) do
      if SameText(TStyleManager.ActiveStyle.Name, WhiteStyles[i]) then
        Exit(clWhite);
    Result := DefaultColor;
  end;

  //— Отрисовка BMP вписано в ClipR с центрированием и обрезкой (было 3 копии) —
  procedure DrawImageContain(const ClipR: TRect; Bmp: TBitmap);
  var
    Scale: Double;
    DrawW, DrawH: Integer;
    DstR: TRect;
  begin
    if (Bmp = nil) or (Bmp.Width <= 0) or (Bmp.Height <= 0) then Exit;
    Scale := Min((ClipR.Right - ClipR.Left) / Bmp.Width,
                 (ClipR.Bottom - ClipR.Top) / Bmp.Height);
    DrawW := Max(1, Round(Bmp.Width * Scale));
    DrawH := Max(1, Round(Bmp.Height * Scale));
    DstR := Rect(0, 0, DrawW, DrawH);
    OffsetRect(DstR,
      ClipR.Left + ((ClipR.Right - ClipR.Left) - DrawW) div 2,
      ClipR.Top  + ((ClipR.Bottom - ClipR.Top) - DrawH) div 2);
    SaveDC(Sender.Canvas.Handle);
    try
      IntersectClipRect(Sender.Canvas.Handle, ClipR.Left, ClipR.Top,
        ClipR.Right, ClipR.Bottom);
      SetStretchBltMode(Sender.Canvas.Handle, HALFTONE);
      SetBrushOrgEx(Sender.Canvas.Handle, 0, 0, nil);
      Sender.Canvas.StretchDraw(DstR, Bmp);
    finally
      RestoreDC(Sender.Canvas.Handle, -1);
    end;
  end;

  //— Единая точка отрисовки текста, опционально с тенью (было 4 копии) —
  procedure DrawTxt(const Txt: string; const R: TRect; Flags: UINT;
    Color: TColor; UseShadow: Boolean);
  var
    TR: TRect;
  begin
    TR := R;
    Sender.Canvas.Brush.Style := bsClear;
    if UseShadow then
      CanvasTextShadowBorder(Sender.Canvas, Txt, TR, Flags, ShadowColor(Color), 1)
    else
    begin
      Sender.Canvas.Font.Color := Color;
      DrawText(Sender.Canvas.Handle, PChar(Txt), Length(Txt), TR, Flags);
    end;
end;

var
  RealIndex, TextH, OldSize: Integer;
  NameStr, PlatStr, GameID: string;
  R, BorderR, TextR, CalcR, ImgR: TRect;
  IsSelected, IsHot, IsFocused, WillDrawHover, SkipHover: Boolean;
  BgColor, BorderColor, TextColor, PlatColor: TColor;
  LStyle: TCustomStyleServices;
  TileBmp: TBitmap;
  CachedAt: TDateTime;
begin
  if Stage <> cdPrePaint then begin DefaultDraw := True; Exit; end;
  DefaultDraw := False;

  if FClosing or not FLoadingComplete then Exit;
  if (Item.Index < 0) or (Item.Index >= Length(FFilteredIndices)) then Exit;

  RealIndex := FFilteredIndices[Item.Index];
  if (RealIndex < 0) or (RealIndex >= Length(FGameData)) then Exit;

  // === Текст ===
  NameStr := FGameData[RealIndex].GameName;
  PlatStr := FGameData[RealIndex].Platforms;
  if FGameData[RealIndex].ReleaseYear <> 0 then
  begin
    if PlatStr <> '' then
      PlatStr := PlatStr + '  -  ' + IntToStr(FGameData[RealIndex].ReleaseYear)
    else
      PlatStr := IntToStr(FGameData[RealIndex].ReleaseYear);
  end;

  R := Item.DisplayRect(drBounds);
  IsSelected := cdsSelected in State;
  IsHot      := cdsHot in State;
  IsFocused  := cdsFocused in State;
  LStyle     := StyleServices;

  // === Цвета ===
  if IsSelected then
  begin
    BgColor     := LStyle.GetSystemColor(clHighlight);
    BorderColor := LStyle.GetSystemColor(clHighlight);
    TextColor   := LStyle.GetSystemColor(clHighlightText);
    PlatColor   := LStyle.GetSystemColor(clHighlightText);
  end
  else if IsHot then
  begin
    BgColor     := LStyle.GetSystemColor(clBtnFace);
    BorderColor := LStyle.GetSystemColor(clBtnShadow);
    TextColor   := LStyle.GetSystemColor(clWindowText);
    PlatColor   := LStyle.GetSystemColor(clGrayText);
  end
  else
  begin
    BgColor     := LStyle.GetSystemColor(clWindow);
    BorderColor := LStyle.GetSystemColor(clBtnFace);
    TextColor   := LStyle.GetSystemColor(clWindowText);
    PlatColor   := LStyle.GetSystemColor(clGrayText);
  end;

  // === Фон + рамка (явно bsSolid — иначе RoundRect не зальётся после DrawText) ===
  BorderR := R;
  InflateRect(BorderR, -2, -2);
  if FViewAsList and IsHot then
    InflateRect(BorderR, -2, -2);

  Sender.Canvas.Brush.Style := bsSolid;
  Sender.Canvas.Brush.Color := BgColor;
  Sender.Canvas.Pen.Color   := BorderColor;
  Sender.Canvas.Pen.Width   := 1;
  Sender.Canvas.RoundRect(BorderR.Left, BorderR.Top,
                          BorderR.Right, BorderR.Bottom, RADIUS, RADIUS);

  if IsFocused and IsSelected then
  begin
    InflateRect(BorderR, 1, 1);
    Sender.Canvas.Brush.Style := bsClear;
    Sender.Canvas.RoundRect(BorderR.Left, BorderR.Top,
                            BorderR.Right, BorderR.Bottom, RADIUS + 1, RADIUS + 1);
    Sender.Canvas.Brush.Style := bsSolid;
  end;

  // === Определяем, будет ли нарисовано hover-превью ===
  GameID := '';
  WillDrawHover := False;
  SkipHover := False;

  if IsHot and FShowImageOnHover then
  begin
    GameID := FGameData[RealIndex].ID;
    if GameID = '' then GameID := '#' + IntToStr(RealIndex);

    FHoverLock.Enter;
    try
      if FHoverNotFoundCache.TryGetValue(GameID, CachedAt) then
      begin
        if SecondsBetween(Now, CachedAt) < HOVER_NOTFOUND_TTL_SEC then
          SkipHover := True
        else
          FHoverNotFoundCache.Remove(GameID);
      end;
    finally
      FHoverLock.Leave;
    end;

    if not SkipHover then
    begin
      if (GameID <> FHoverBitmapID) and (FHoverBitmap.Width > 0) then
      begin
        FHoverBitmapID := '';
        FHoverBitmap.SetSize(0, 0);
        FHoverBitmap.Dormant;
      end;

      if (GameID <> FHoverQueuedID) and
         ((GameID <> FHoverBitmapID) or (FHoverBitmap.Width = 0)) then
      begin
        if GameID <> FHoverDwellID then
        begin
          FHoverDwellID := GameID;
          FHoverDwellIndex := RealIndex;
          FHoverDwellTimer.Enabled := False;
          FHoverDwellTimer.Enabled := True;
        end;
      end;

      if not FViewAsList and (GameID = FHoverBitmapID) and (FHoverBitmap.Width > 0) then
        WillDrawHover := True;
    end;
  end;

  // === Миниатюра (только для плиточного режима) ===
  TileBmp := nil;
  if FShowListImages and not WillDrawHover then
    TileBmp := GetTileBitmap(Item.Index, RealIndex);

  ImgR := BorderR;
  InflateRect(ImgR, -2, -2);

  // =====================================================
  // РЕЖИМ СПИСКА
  // =====================================================
  if FViewAsList then
  begin
    var RowH := BorderR.Bottom - BorderR.Top;
    var IconH := Max(1, RowH - 2);
    var IconW := Max(1, MulDiv(IconH, 4, 3));
    var IconTop := BorderR.Top + ((RowH - IconH) div 2);
    var IconR := Rect(BorderR.Left + 2, IconTop,
                      BorderR.Left + 2 + IconW, IconTop + IconH);

    // На Hot — превью, иначе — тайл
    var IconBmp: TBitmap := nil;
    if IsHot and (GameID <> '') and (GameID = FHoverBitmapID) and
       (FHoverBitmap.Width > 0) then
      IconBmp := FHoverBitmap
    else
      IconBmp := TileBmp;

    var ShowIcon := Assigned(IconBmp) and (IconBmp.Width > 0) and (IconBmp.Height > 0);
    if ShowIcon then
      DrawImageContain(IconR, IconBmp);

    var TxtR := BorderR;
    if ShowIcon then
      TxtR.Left := IconR.Right + 10
    else
      TxtR.Left := BorderR.Left + 6;
    TxtR.Right := BorderR.Right - 2;
    InflateRect(TxtR, 0, -2);

    var CapR := TxtR;
    CapR.Top    := CapR.Top + 4;
    CapR.Bottom := CapR.Top + ((TxtR.Bottom - TxtR.Top) div 2) - 2;

    DrawTxt(NameStr, CapR,
      DT_LEFT or DT_WORDBREAK or DT_NOPREFIX or DT_END_ELLIPSIS,
      TextColor, False);

    if PlatStr <> '' then
    begin
      var PlatR2 := TxtR;
      PlatR2.Top := CapR.Bottom + 2;
      OldSize := Sender.Canvas.Font.Size;
      try
        Sender.Canvas.Font.Size := Max(7, ListView1.Font.Size - 2);
        DrawTxt(PlatStr, PlatR2,
          DT_LEFT or DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS or DT_NOPREFIX,
          PlatColor, False);
      finally
        Sender.Canvas.Font.Size := OldSize;
      end;
    end;
    Exit;
  end;

  // =====================================================
  // РЕЖИМ ПЛИТОК
  // =====================================================
  var UseShadow := False;

  if Assigned(TileBmp) then
  begin
    DrawImageContain(ImgR, TileBmp);
    UseShadow := True;
  end;

  if WillDrawHover then
  begin
    DrawImageContain(ImgR, FHoverBitmap);
    UseShadow := True;
  end;

  // === Название по центру с переносом ===
  TextR := BorderR;
  InflateRect(TextR, -6, -4);
  TextR.Bottom := TextR.Bottom - 18;

  CalcR := TextR;
  DrawText(Sender.Canvas.Handle, PChar(NameStr), Length(NameStr), CalcR,
    DT_CENTER or DT_WORDBREAK or DT_CALCRECT or DT_NOPREFIX or DT_END_ELLIPSIS);
  TextH := CalcR.Bottom - CalcR.Top;

  if UseShadow or (IsHot and FShowImageOnHover) then
  begin
    TextR.Top    := BorderR.Top + 4;
    TextR.Bottom := TextR.Top + TextH;
  end
  else if TextH < (TextR.Bottom - TextR.Top) then
    TextR.Top := TextR.Top + ((TextR.Bottom - TextR.Top) - TextH) div 2;

  DrawTxt(NameStr, TextR,
    DT_CENTER or DT_WORDBREAK or DT_NOPREFIX or DT_END_ELLIPSIS,
    TextColor, UseShadow);

  // === Платформа снизу слева ===
  if PlatStr <> '' then
  begin
    var PlatR2 := BorderR;
    PlatR2.Top := PlatR2.Bottom - 20;
    InflateRect(PlatR2, -6, -1);
    OldSize := Sender.Canvas.Font.Size;
    try
      Sender.Canvas.Font.Size := Max(7, ListView1.Font.Size - 2);
      DrawTxt(PlatStr, PlatR2,
        DT_LEFT or DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS or DT_NOPREFIX,
        TextColor, UseShadow);  // здесь оригинал тоже использует TextColor
    finally
      Sender.Canvas.Font.Size := OldSize;
    end;
  end;
end;

procedure TSGLMainForm.ListView1ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  Item: TListItem;
begin
  // 1. Клавиатура: MousePos = (-1,-1) — берём выбранный элемент
  if (MousePos.X = -1) and (MousePos.Y = -1) then
    Item := ListView1.Selected
  else
    Item := ListView1.GetItemAt(MousePos.X, MousePos.Y);

  // 2. Нет элемента (или рассинхрон индексов) — меню не показываем
  if (Item = nil) or (Item.Index >= Length(FFilteredIndices)) then
  begin
    Handled := True;
    Exit;
  end;

  Handled := False;
  ListView1.ItemIndex := Item.Index;

  // 3. Ошибка в динамической части не должна убивать всё меню
  try
    UpdateExtrasMenu(FFilteredIndices[Item.Index]);
  except
    on E: Exception do
      OutputDebugString(PChar('UpdateExtrasMenu: ' + E.Message));
  end;

  UpdateFavoritesMenuItem;
  UpdateMenuItemsForCurrentGame;
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

  if ListView1.ViewStyle = vsReport then
    Item.Caption := FGameData[RealIndex].GameName
  else
    Item.Caption := '';

  if ListView1.Columns.Count >= 2 then
  begin
    SelectedPlatform := TabView1.Tabs[TabView1.TabIndex].Caption;
    if SameText(SelectedPlatform, 'All') or SameText(SelectedPlatform, 'Installed') or
       SameText(SelectedPlatform, 'Favorites') then
      Item.SubItems.Add(FGameData[RealIndex].Platforms);
  end;
end;

procedure TSGLMainForm.ListView1DblClick(Sender: TObject);
begin
  if ListView1.ItemIndex = -1 then Exit;
  LaunchGame(FFilteredIndices[ListView1.ItemIndex]);
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

procedure TSGLMainForm.ListView1MouseLeave(Sender: TObject);
begin
  // Полностью сбрасываем только когда курсор реально ушёл из ListView
  FHoverDwellTimer.Enabled := False;
  FHoverDwellID    := '';
  FHoverDwellIndex := -1;

  FHoverLock.Enter;
  try
    FHoverPendingIndex := -1;
    FHoverQueuedID     := '';
  finally
    FHoverLock.Leave;
  end;

  // Картинку можно оставить — она пропадёт при следующем paint без IsHot
  // Если хотите жёстко очищать:
   FHoverBitmapID := '';
   FHoverBitmap.SetSize(0, 0);
end;

procedure TSGLMainForm.ListView1SelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
 if FClosing then Exit;

  if not Selected then
  begin
    ClearGameInfo;
    Exit;
  end;
  FSelectionTimer.Enabled := False;
  FPendingItemIndex := Item.Index;
  FSelectionTimer.Enabled := True;
end;

// ListView thumbnails
procedure TSGLMainForm.ResizeListViewTiles(Delta: Integer);
const
  MinW      = 80;
  AspectNum = 100;
  AspectDen = 125;
  ListMinW  = 160;
  ListH     = 50;
var
  NewW, NewH, MaxW, MaxW_W, MaxW_H, UsableW: Integer;
begin
  if not Assigned(FListItemHeightImages) then Exit;
  if ListView1.ViewStyle <> vsIcon then Exit;

  UsableW := GetListViewUsableWidth;

  // === View as List ===
  if FViewAsList then
  begin
    MaxW := UsableW - 8;
    if MaxW < ListMinW then MaxW := ListMinW;

    NewW := FListItemHeightImages.Width + Delta;
    if NewW < ListMinW then NewW := ListMinW;
    if NewW > MaxW    then NewW := MaxW;

    // Всегда пересоздаём/перепривязываем ImageList и spacing.
    // После смены стиля (особенно 'Windows') ListView сбрасывает
    // LVM_SETICONSPACING — простой Perform без rebind не помогает.
    ListView1.LargeImages := nil;
    if (FListItemHeightImages.Width <> NewW) or
       (FListItemHeightImages.Height <> ListH) then
    begin
      FreeAndNil(FListItemHeightImages);
      FListItemHeightImages := TImageList.Create(Self);
      FListItemHeightImages.Width  := NewW;
      FListItemHeightImages.Height := ListH;
    end;
    ListView1.LargeImages := FListItemHeightImages;

    ListView1.Perform(LVM_SETICONSPACING, 0,
      MAKELPARAM(UsableW, ListH + 25));
    ListView1.Invalidate;
    Exit;
  end;

  // === View as Thumbnails ===
  if not ViewasThumbnailsMenuItem.Checked then Exit;

  MaxW_W := UsableW - 20;
  if MaxW_W < MinW then MaxW_W := MinW;

  MaxW_H := Round((ListView1.ClientHeight - 20) * AspectDen / AspectNum);
  if MaxW_H < MinW then MaxW_H := MinW;

  MaxW := Min(MaxW_W, MaxW_H);

  NewW := FListItemHeightImages.Width + Delta;
  if NewW < MinW then NewW := MinW;
  if NewW > MaxW then NewW := MaxW;
  if NewW = FListItemHeightImages.Width then Exit;

  NewH := MulDiv(NewW, AspectNum, AspectDen);

  ListView1.LargeImages := nil;
  FreeAndNil(FListItemHeightImages);
  FListItemHeightImages := TImageList.Create(Self);
  FListItemHeightImages.Width  := NewW;
  FListItemHeightImages.Height := NewH;
  ListView1.LargeImages := FListItemHeightImages;

  ListView1.Perform(LVM_SETICONSPACING, 0, MAKELPARAM(-1, -1));
  ListView1.Invalidate;
  // меняем размер изображении
  ClearTileCache;

  FConfig.WriteInteger('SGAllSettings', 'TileWidth',  NewW);
  FConfig.WriteInteger('SGAllSettings', 'TileHeight', NewH);
  FConfig.UpdateFile;
end;

function TSGLMainForm.GetListViewUsableWidth: Integer;
var
  SbW: Integer;
  HasVScroll: Boolean;
begin
  SbW := GetSystemMetrics(SM_CXVSCROLL);
  HasVScroll := ListView1.HandleAllocated and
                ((GetWindowLong(ListView1.Handle, GWL_STYLE) and WS_VSCROLL) <> 0);

  Result := ListView1.ClientWidth;
  if not HasVScroll then
    Result := Result - SbW;   // резервируем место под будущий скроллбар

  if Result < 100 then
    Result := 100;
end;

//----OTHER COMPONENTS----
//------------------------------------------------------------------------------
procedure TSGLMainForm.ApplyTransparentBackgroundToInfoPanel;
begin
  // ScrollBox1 — показываем фон Panel1/формы (со стилем VCL)
  ScrollBox1.ParentBackground := True;
  ScrollBox1.ParentColor     := True;
  ScrollBox1.DoubleBuffered  := True;
  ScrollBox1.StyleElements   := ScrollBox1.StyleElements - [seClient];

  TitleLabel.Transparent      := True;
  DeveloperLabel.Transparent  := True;
  PublisherLabel.Transparent  := True;
  GenreLabel.Transparent      := True;
  SeriesLabel.Transparent     := True;
  PlatformLabel.Transparent   := True;
  ReleaseLabel.Transparent    := True;
  PlayModeLabel.Transparent   := True;
  Label1.Transparent          := True;

  // ScrollBox2 + FlowPanel1 — прозрачный фон, только миниатюры
  if Assigned(ScrollBox2) then
  begin
    ScrollBox2.ParentBackground := True;
    ScrollBox2.ParentColor      := True;
    ScrollBox2.DoubleBuffered   := True;
    ScrollBox2.StyleElements    := ScrollBox2.StyleElements - [seClient];
  end;
  if Assigned(FlowPanel1) then
  begin
    FlowPanel1.ParentBackground := True;
    FlowPanel1.ParentColor      := True;
    FlowPanel1.DoubleBuffered   := True;
  end;
end;

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

  // После смены стиля метрики применяются не сразу (особенно для 'Windows').
  // ForceQueue + повторный вызов для системного стиля.
  TThread.ForceQueue(nil,
    procedure
    begin
      if FClosing then Exit;
      FormResize(Self);
      ResizeListViewTiles(0);
      ApplyTransparentBackgroundToInfoPanel;

      // Системный стиль 'Windows' сбрасывает icon spacing позже остальных —
      // делаем ещё один отложенный проход.
      if SameText(CurrentStyleName, 'Windows') then
        TThread.ForceQueue(nil,
          procedure
          begin
            if FClosing then Exit;
            ResizeListViewTiles(0);
          end);
    end);
end;

procedure TSGLMainForm.TabView1ChangeTab(Sender: TObject);
var
  CurrentIdx: Integer;
begin
  // Подавляем автоматический OnChangeTab при программной смене TabIndex
  // (NavigationView1ChangeItem и Ctrl+Tab ставят FUpdatingNavView вокруг присваивания)
  if FUpdatingNavView then Exit;

  // === Синхронизация зеркала ===
  if Assigned(NavigationView1) and
     (NavigationView1.ItemIndex <> TabView1.TabIndex) then
  begin
    FUpdatingNavView := True;
    try
      if (TabView1.TabIndex >= 0) and (TabView1.TabIndex < NavigationView1.Items.Count) then
        NavigationView1.ItemIndex := TabView1.TabIndex;
    finally
      FUpdatingNavView := False;
    end;
  end;

  SyncNavViewSelection;

  CurrentIdx := TabView1.TabIndex;

  FTabChangeLock.Enter;
  try
    if FIsChangingTab then
    begin
      FPendingTabIndex := CurrentIdx;
      FTabChangeTimer.Enabled := True;
      Exit;
    end;
    FIsChangingTab := True;
  finally
    FTabChangeLock.Leave;
  end;

  try
    PerformTabChange(CurrentIdx);
    ComboBox2.ItemIndex := 0;
  finally
    FTabChangeLock.Enter;
    try
      FIsChangingTab := False;   // ← сбрасываем сразу, а не ждём таймера
    finally
      FTabChangeLock.Leave;
    end;
  end;
end;

procedure TSGLMainForm.TitleBarPanel1CustomButtons0Click(Sender: TObject);
begin
  Hide;
  ShowMenuItem.Caption := 'Show';
end;

procedure TSGLMainForm.TitleBarPanel1CustomButtons0Paint(Sender: TObject);
var
  Button: TSystemTitlebarButton;
  R: TRect;
  BtnBgColor, BtnFgColor: TColor;
begin
  Button := Sender as TSystemTitlebarButton;
  R := Button.ClientRect;

  // Получаем системные цвета в зависимости от текущей темы
  BtnFgColor := TStyleManager.ActiveStyle.GetSystemColor(clCaptionText);

  // --- Рисуем иконку "стрелка вниз" (символ сворачивания в трей) ---
  Button.Canvas.Pen.Color := BtnFgColor;
  Button.Canvas.Brush.Style := bsClear;

  // Координаты подобраны для примера, их можно менять
  Button.Canvas.MoveTo(R.Left + 15, R.Top + 12);
  Button.Canvas.LineTo(R.Right - 15, R.Top + 12);
  Button.Canvas.MoveTo(R.Left + 20, R.Top + 16);
  Button.Canvas.LineTo(R.Right - 20, R.Top + 16);
end;

procedure TSGLMainForm.TrayIconClick(Sender: TObject);
begin
// Проверяем, что форма ещё не уничтожается
if csDestroying in ComponentState then Exit;

if Visible then
  begin
   Hide;
   ShowMenuItem.Caption := 'Show';
  end
  else
  begin
    Show;
    Application.BringToFront;
    SetForegroundWindow(Handle);
    ShowMenuItem.Caption := 'Hide';
  end;
end;

procedure TSGLMainForm.ComboBox1Change(Sender: TObject);
var
  OldIndex: Integer;
begin
  OldIndex := ComboBox2.ItemIndex;

  FillFilterValues; // Заполняем новые значения для выбранной категории

  // Если раньше был выбран конкретный фильтр — сбрасываем на "All"
  if OldIndex > 0 then
    ComboBox2.ItemIndex := 0;

  // ВСЕГДА применяем фильтры после смены категории
  ApplyFilters();

  // Выделяем первую игру в списке
  if ListView1.Items.Count > 0 then
  begin
    ListView1.ItemIndex := 0;
    ListView1.Selected := ListView1.Items[0];
    ListView1.Selected.MakeVisible(False);
  end;

  ActiveControl := ListView1;
end;

procedure TSGLMainForm.ComboBox2Change(Sender: TObject);
begin
  ApplyFilters;

  // Выделяем первую игру в списке
  if ListView1.Items.Count > 0 then
  begin
    ListView1.ItemIndex := 0;
    ListView1.Selected := ListView1.Items[0];
    ListView1.Selected.MakeVisible(False);
  end;

  ActiveControl := ListView1;
end;

procedure TSGLMainForm.Edit1Change(Sender: TObject);
begin
  FSearchText := Edit1.Text;
  ApplyFilters;
end;

procedure TSGLMainForm.ScreenShotImageClick(Sender: TObject);
var
  Bmp: TBitmap;
begin
  if ListView1.ItemIndex = -1 then Exit;
  if ScreenShotImage.Picture.Graphic = nil then Exit;
  if ScreenShotImage.Picture.Graphic.Empty then Exit;

  with FullScreenForm do
    begin
      Label1.Caption := FGameData[FFilteredIndices[ListView1.ItemIndex]].GameName;
      FullScreenForm.FullScreenImage.Picture.Assign(ScreenShotImage.Picture);
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

  // Синхронизируем выделение в галерее миниатюр
  if EnabledMiniatures then SyncThumbnailSelection;
end;

procedure TSGLMainForm.NextImgBtnClick(Sender: TObject);
begin
  if ImgList.Count = 0 then Exit;

  ImgCurIndex := (ImgCurIndex + 1) mod ImgList.Count;

  LoadImageWithRetry(ImgList[ImgCurIndex], ScreenShotImage);

  // Синхронизируем выделение в галерее миниатюр
  if EnabledMiniatures then SyncThumbnailSelection;
end;

procedure TSGLMainForm.Splitter3Moved(Sender: TObject);
var
  i, Idx, NewH, NewW: Integer;
  Pnl: TPanel;
begin
  if not EnabledMiniatures then Exit;

  NewH := ScrollBox2.Height - GetSystemMetrics(SM_CYHSCROLL) - (PADDING2 * 2) - 8;
  if NewH < 20 then NewH := 20;
  // Сохраняем пропорцию 100:74
  NewW := MulDiv(NewH, 100, 74);

  FThumbWidth := NewW;
  FThumbHeight := NewH;

  FlowPanel1.Height := FThumbHeight + 8 + (PADDING2 * 2);

  for i := 0 to FlowPanel1.ControlCount - 1 do
  begin
    if not (FlowPanel1.Controls[i] is TPanel) then Continue;
    Pnl := TPanel(FlowPanel1.Controls[i]);
    Idx := Pnl.Tag;
    if (Idx >= 0) and (Idx < Length(FAllImageFiles)) then
      ResizeThumbnail(Pnl, FAllImageFiles[Idx]);
  end;

  // Пересчитать общую ширину
  var ThumbW := FThumbWidth + 8 + (PADDING2 * 2);
  var TotalWidth := FlowPanel1.ControlCount * ThumbW + PADDING2;
  FlowPanel1.Width := TotalWidth + 30;

  ScrollBox2.HorzScrollBar.Range := FlowPanel1.Width;
  FlowPanel1.Realign;
  FlowPanel1.Invalidate;
end;

procedure TSGLMainForm.PlatformBtnClick(Sender: TObject);
var
  AnyChecked: Boolean;
  i: Integer;
  ClearAllItem, SelectAllItem: TMenuItem;
  CurrentTab: string;
begin
  if not FLoadingComplete then Exit;

  CurrentTab := TabView1.Tabs[TabView1.TabIndex].Caption;

  // === Если не на All и не на Installed — ничего не делаем ===
  if not (SameText(CurrentTab, 'All') or
          SameText(CurrentTab, 'Installed') or
          SameText(CurrentTab, 'Favorites')) then
    Exit;   // ← Выходим, ничего не выполняем

  // === Дальше — только для вкладок All и Installed ===
  RefreshPlatformFilterMenu;

  AnyChecked := False;

  // Проверяем состояние чекбоксов
  for i := 0 to pmPlatformFilter.Items.Count - 1 do
  begin
    if (pmPlatformFilter.Items[i].Hint <> '') and
       pmPlatformFilter.Items[i].Checked then
    begin
      AnyChecked := True;
      Break;
    end;
  end;

  // Находим пункты Select All и Clear All
  ClearAllItem := nil;
  SelectAllItem := nil;
  for i := 0 to pmPlatformFilter.Items.Count - 1 do
  begin
    if pmPlatformFilter.Items[i].Tag = 1 then
      SelectAllItem := pmPlatformFilter.Items[i]
    else if pmPlatformFilter.Items[i].Tag = 2 then
      ClearAllItem := pmPlatformFilter.Items[i];
  end;

  // Выполняем действие
  if AnyChecked then
  begin
    if Assigned(ClearAllItem) then
      PlatformFilterMenuClick(ClearAllItem);
  end
  else
  begin
    if Assigned(SelectAllItem) then
      PlatformFilterMenuClick(SelectAllItem);
  end;

  AutoSizeListViewColumns;
end;

procedure TSGLMainForm.PopupActionBar1Popup(Sender: TObject);
begin
  RefreshPlatformFilterMenu;
end;

procedure TSGLMainForm.Image1Click(Sender: TObject);
procedure ShowSysMenu(X, Y: Integer);
var
  SysMenu: HMENU;
  Cmd: Integer;
begin
  // 1. Получаем дескриптор системного меню формы
  SysMenu := GetSystemMenu(Handle, False);

  // 2. Показываем меню в экранных координатах (TPM_RETURNCMD - вернуть ID команды, а не слать сообщение)
  Cmd := Integer(TrackPopupMenu(SysMenu,
    TPM_RETURNCMD or TPM_LEFTBUTTON,
    X, Y, 0, Handle, nil));

  // 3. Если выбран пункт - отправляем его окну как системную команду
  if Cmd <> 0 then
    SendMessage(Handle, WM_SYSCOMMAND, Cmd, 0);
end;
var
  P: TPoint;
begin
  P := Image1.ClientToScreen(Point(0, Image1.Height));
  ShowSysMenu(P.X, P.Y);
end;

procedure TSGLMainForm.Image1DblClick(Sender: TObject);
begin
 Close;
end;

procedure TSGLMainForm.BtnMenuClick(Sender: TObject);
var
  P: TPoint;
begin
  P := BtnMenu.ClientToScreen(Point(0, BtnMenu.Height));
  TrayPopupActionBar.Popup(P.X, P.Y);
  ActiveControl := ListView1;
end;

//----TOOLBAR----
//------------------------------------------------------------------------------
procedure TSGLMainForm.PinToolBarOnTop;
begin
  // 1) Z-order: тулбар первым в списке контролов (разрешает ничьи при равных Top/Left)
  ToolBar1.SendToBack;
  // 2) Порядок внутри одной стороны задаётся Top/Left — ставим вне диапазона,
  //    после Realign VCL сам выставит реальные координаты
  case ToolBar1.Align of
    alTop:    ToolBar1.Top  := -1;
    alLeft:   ToolBar1.Left := -1;
    alBottom: ToolBar1.Top  := ToolBar1.Parent.ClientHeight;
    alRight:  ToolBar1.Left := ToolBar1.Parent.ClientWidth;
  end;
end;

procedure TSGLMainForm.ToolBar1Click(Sender: TObject);
var
  TempList: TStringList;
  WorkingDir: String;
  IniValue: String;
  ExePath, Params: string;
begin
  if not (Sender is TToolButton) then Exit;

  TempList := TStringList.Create;
  try
    IniValue := FConfig.ReadString('ToolBar', TToolButton(Sender).Hint, '');

    if IniValue = '' then
      Exit;

    StrToList(IniValue, '|', TempList);

    if TempList.Count < 1 then
      Exit;

    ExePath := TempList[0];
    Params := IfThen(TempList.Count > 1, TempList[1], '');

    if (TempList.Count > 2) and (TempList[2] <> '') then
      WorkingDir := TempList[2]
    else
      WorkingDir := ExtractFilePath(ExePath);

      RunProcess(ExePath, Params, WorkingDir, False);

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
   begin
    ToolBar1.Align := TAlign(AlignValue);
    // Делаем ToolBar всегда первым в left
    PinToolBarOnTop;
    if ToolBar1.Align = alTop then ToolBar1.Top := -1;
   end;

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
  ExePath, Params, WorkDir: string;
  IsAdminRequired: Boolean;
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
    // Run as administrator
  if MenuItem.Name = 'miRunAsAdmin' then
  begin
    if Assigned(Button) then
    begin
      TempList := TStringList.Create;
      try
        // Разбираем значения кнопки
        StrToList(FConfig.ReadString('Toolbar', Button.Hint, ''), '|', TempList);

        if TempList.Count < 1 then Exit;

        ExePath := TempList[0];
        Params := IfThen(TempList.Count > 1, TempList[1], '');
        WorkDir := IfThen(TempList.Count > 2, TempList[2], ExtractFilePath(ExePath));

        // Запускаем с правами администратора
        RunProcess(ExePath, Params, WorkDir, True);
      finally
        TempList.Free;
      end;
    end;
  end

  else if MenuItem.Name = 'miOpenFileLocation' then
  begin
    if Assigned(Button) then
    begin
      TempList := TStringList.Create;
      try
        StrToList(FConfig.ReadString('Toolbar', Button.Hint, ''), '|', TempList);
        if TempList.Count >= 1 then
          OpenFileLocation(TempList[0]);
      finally
        TempList.Free;
      end;
    end;
  end

  else if MenuItem.Name = 'miDelete' then
  begin
    if Assigned(Button) then
     if MessageDlg('Are you sure you want to delete?',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
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

// Переключение фильтр по информационным лейблам
//------------------------------------------------------------------------------
procedure TSGLMainForm.ApplyLabelFilter(const Category: string; const Value: string);
var
  i: Integer;
  Found: Boolean;
begin
  if not FLoadingComplete then Exit;

  // 1. Устанавливаем категорию
  Found := False;
  for i := 0 to ComboBox1.Items.Count - 1 do
    if SameText(ComboBox1.Items[i], Category) then
    begin
      if ComboBox1.ItemIndex <> i then
        ComboBox1.ItemIndex := i;
      Found := True;
      Break;
    end;

  if not Found then Exit;

  // 2. Обновляем список значений в ComboBox2
  FillFilterValues();

  // 3. Ищем и устанавливаем нужное значение
  Found := False;
  for i := 0 to ComboBox2.Items.Count - 1 do
    if SameText(ComboBox2.Items[i], Value) then
    begin
      ComboBox2.ItemIndex := i;
      Found := True;
      Break;
    end;

  if not Found then
  begin
    // Если точное совпадение не найдено — ставим текст вручную
    ComboBox2.Text := Value;
    ComboBox2.ItemIndex := -1; // чтобы не было старого индекса
  end;

  // 4. Принудительно применяем фильтр
  ApplyFilters();

  // 5. Выделяем первую игру
  if ListView1.Items.Count > 0 then
  begin
    ListView1.ItemIndex := 0;
    ListView1.Selected := ListView1.Items[0];
    ListView1.Selected.MakeVisible(False);
  end;

  ActiveControl := ListView1;
end;

procedure TSGLMainForm.LabelFilterMenuItemClick(Sender: TObject);
var
  Value: string;
  Category: string;
  Popup: TPopupMenu;
  OriginalLabel: TLabel;
begin
  if not (Sender is TMenuItem) then Exit;

  Value := TMenuItem(Sender).Hint;   // ← Берём из Hint, а не Tag
  if Value = '' then Exit;

  Popup := TPopupMenu(TMenuItem(Sender).GetParentMenu);
  if not Assigned(Popup) then Exit;

  OriginalLabel := TLabel(Popup.Tag);
  if not Assigned(OriginalLabel) then Exit;

  if OriginalLabel = DeveloperLabel then Category := 'Developer'
  else if OriginalLabel = PublisherLabel then Category := 'Publisher'
  else if OriginalLabel = GenreLabel then Category := 'Genre'
  else if OriginalLabel = SeriesLabel then Category := 'Series'
  else if OriginalLabel = PlayModeLabel then Category := 'Play Mode'
  else if OriginalLabel = ReleaseLabel then Category := 'Year'
  else Exit;

  ApplyLabelFilter(Category, Value);
end;

procedure TSGLMainForm.DeveloperLabelClick(Sender: TObject);
var
  LabelText, Category: string;
  Values: TStringDynArray;
  Popup: TPopupMenu;
  MenuItem: TMenuItem;
  i: Integer;
begin
  if not FLoadingComplete then Exit;
  if not (Sender is TLabel) then Exit;

  LabelText := TLabel(Sender).Caption;
  if Pos(': ', LabelText) > 0 then
    LabelText := Copy(LabelText, Pos(': ', LabelText) + 2, MaxInt);

  LabelText := Trim(LabelText);
  if LabelText = '' then Exit;

  // Определяем категорию
  if Sender = DeveloperLabel then Category := 'Developer'
  else if Sender = PublisherLabel then Category := 'Publisher'
  else if Sender = GenreLabel then Category := 'Genre'
  else if Sender = SeriesLabel then Category := 'Series'
  else if Sender = PlayModeLabel then Category := 'Play Mode'
  else if Sender = PlatformLabel then
  begin
    for i := 0 to TabView1.Tabs.Count - 1 do
      if SameText(TabView1.Tabs[i].Caption, LabelText) then
      begin
        TabView1.TabIndex := i;
        TabView1.OnChangeTab(TabView1);
        Exit;
      end;
    Exit;
  end
  else if Sender = ReleaseLabel then Category := 'Year'
  else Exit;

  if Category = 'Genre' then
    Values := LabelText.Split([';'{,'/'}])
  else
    Values := LabelText.Split([';']);

  // Если одно значение — сразу фильтруем
  if Length(Values) = 1 then
  begin
    ApplyLabelFilter(Category, Trim(Values[0]));
    Exit;
  end;

  // Создаём меню
  Popup := TPopupMenu.Create(nil);
  try
    Popup.Tag := NativeInt(Sender); // сохраняем оригинальный Label

    for i := Low(Values) to High(Values) do
    begin
      if Trim(Values[i]) = '' then Continue;

      MenuItem := TMenuItem.Create(Popup);
      MenuItem.Caption := StringReplace(Trim(Values[i]), '&', '&&', [rfReplaceAll]);
      MenuItem.Hint := Trim(Values[i]);           // ← Вот здесь главное изменение!
      MenuItem.OnClick := LabelFilterMenuItemClick;
      Popup.Items.Add(MenuItem);
    end;

    if Popup.Items.Count > 0 then
      Popup.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
  finally
    // Popup освободится сам
  end;
end;

procedure TSGLMainForm.DeveloperLabelMouseEnter(Sender: TObject);
begin
if Sender is TLabel then
    TLabel(Sender).Font.Style := TLabel(Sender).Font.Style + [fsUnderline];
end;

procedure TSGLMainForm.DeveloperLabelMouseLeave(Sender: TObject);
begin
if Sender is TLabel then
    TLabel(Sender).Font.Style := TLabel(Sender).Font.Style - [fsUnderline];
end;

// Переключение на вертикальные вкладки
//-----------------------------------------------------------------------------
procedure TSGLMainForm.SyncNavigationViewFromTabView;
var
  i: Integer;
  NewItem: TNavigationViewItem;
  NeedRebuild: Boolean;
begin
  if not Assigned(NavigationView1) then Exit;

  FUpdatingNavView := True;
  try
    NeedRebuild := NavigationView1.Items.Count <> TabView1.Tabs.Count;
    if not NeedRebuild then
      for i := 0 to TabView1.Tabs.Count - 1 do
        if NavigationView1.Items[i].Caption <> TabView1.Tabs[i].Caption then
        begin
          NeedRebuild := True;
          Break;
        end;

    if NeedRebuild then
    begin
      NavigationView1.Items.BeginUpdate;
      try
        NavigationView1.Items.Clear;
        for i := 0 to TabView1.Tabs.Count - 1 do
        begin
          NewItem := TNavigationViewItem(NavigationView1.Items.Add);
          NewItem.Caption := TabView1.Tabs[i].Caption;
        end;
      finally
        NavigationView1.Items.EndUpdate;
      end;
    end;

    // Индекс
    if (TabView1.TabIndex >= 0) and (TabView1.TabIndex < NavigationView1.Items.Count) then
      NavigationView1.ItemIndex := TabView1.TabIndex
    else if NavigationView1.Items.Count > 0 then
      NavigationView1.ItemIndex := 0
    else
      NavigationView1.ItemIndex := -1;
  finally
    FUpdatingNavView := False;
  end;
end;

procedure TSGLMainForm.SyncNavViewSelection;
begin
  if not Assigned(NavigationView1) then Exit;
  if NavigationView1.Items.Count = 0 then Exit;
  if NavigationView1.ItemIndex = TabView1.TabIndex then Exit; // уже синхронно

  FUpdatingNavView := True;
  try
    if (TabView1.TabIndex >= 0) and (TabView1.TabIndex < NavigationView1.Items.Count) then
      NavigationView1.ItemIndex := TabView1.TabIndex
    else
      NavigationView1.ItemIndex := 0;
  finally
    FUpdatingNavView := False;
  end;
end;

procedure TSGLMainForm.NavigationView1ChangeItem(Sender: TObject);
var
  Idx: Integer;
begin
  if FUpdatingNavView then Exit;
  if FClosing or (csDestroying in ComponentState) then Exit;
  if not FLoadingComplete then Exit;

  Idx := NavigationView1.ItemIndex;
  if Idx < 0 then Exit;
  if Idx = TabView1.TabIndex then Exit;
  if Idx >= TabView1.Tabs.Count then Exit;

  // Подавляем автоматический OnChangeTab, чтобы обработка была ровно одна
  FUpdatingNavView := True;
  try
    TabView1.TabIndex := Idx;
  finally
    FUpdatingNavView := False;
  end;

  TabView1ChangeTab(TabView1);
end;

procedure TSGLMainForm.ApplyTabsLayout(Vertical: Boolean);
begin
  // 1) Видимость
  TabView1.Visible        := not Vertical;
  NavigationView1.Visible := Vertical;
  Splitter4.Visible       := Vertical;

  if not Vertical then
   begin
    PinToolBarOnTop;
    Exit;
   end;

  // 2) Гарантируем корректную ширину ДО расчёта Left
  if NavigationView1.Width < 80 then
    NavigationView1.Width := FConfig.ReadInteger('SGAllSettings', 'NavViewWidth', 180);
  if NavigationView1.Width < 80 then
    NavigationView1.Width := 180;
  Splitter4.Width := 5;

  // 3) Снимаем выравнивание у обоих
  NavigationView1.Align := alNone;
  Splitter4.Align       := alNone;

  // 4) Явные Left: сортировка alLeft идёт по Left, а не по Z-order
  NavigationView1.Left := 0;
  Splitter4.Left       := NavigationView1.Width;
  if Panel3.Align = alLeft then
  begin
    Panel3.Left := Splitter4.Left + Splitter4.Width;
    if Splitter1.Visible then
      Splitter1.Left := Panel3.Left + Panel3.Width;
  end;

  // 5) Выравниваем: сначала панель, затем сплиттер — оба alLeft
  NavigationView1.Align := alLeft;
  Splitter4.Align       := alLeft;
  // Делаем ToolBar всегда первым в left
  PinToolBarOnTop;

  // 6) Синхронизируем выбранный пункт
  SyncNavViewSelection;
end;

procedure TSGLMainForm.VerticaltabsMenuItemClick(Sender: TObject);
begin
  VerticaltabsMenuItem.Checked := not VerticaltabsMenuItem.Checked;

  ApplyTabsLayout(VerticaltabsMenuItem.Checked);

  // Делаем ToolBar всегда первым в left
  ToolBar1.SendToBack;
  case ToolBar1.Align of
    alLeft:   ToolBar1.Left := -1;
  end;

  FConfig.WriteBool('SGAllSettings', 'VerticalTabs', VerticaltabsMenuItem.Checked);
  FConfig.UpdateFile;
end;

//----MENUEXTRAS----
//------------------------------------------------------------------------------
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

// TrayPopupActionBar
//-----------------------------------------------------------------------------
procedure TSGLMainForm.ExitMenuItemClick(Sender: TObject);
begin
  Close;
end;

procedure TSGLMainForm.AboutMenuItemClick(Sender: TObject);
begin
  with HelpForm do
   begin
     Position := poDesktopCenter;
     Label2.Caption := 'ReleaseDate: ' + FormatDateTime('dd.mm.yyyy', Date);
     HELPFORM_PAGECTRL1.ActivePageIndex := 0;
     Show;
   end;
end;

procedure TSGLMainForm.AutostartMenuItemClick(Sender: TObject);
begin
  with Sender as TMenuItem do
   begin
    Checked := not Checked;
    ToggleSelfInStartupFolder(Checked);
   end;
end;

procedure TSGLMainForm.HideonstartupMenuItemClick(Sender: TObject);
begin
  with Sender as TMenuItem do
   begin
    Checked := not Checked;
    FConfig.WriteBool('SGAllSettings', 'HideInTray', Checked);
    FConfig.UpdateFile;
   end;
end;

procedure TSGLMainForm.ViewasThumbnailsMenuItemClick(Sender: TObject);
begin
with Sender as TMenuItem do
 begin
   Checked := not Checked;
   if Checked then
   begin
    if ViewasListMenuItem.Checked then
    begin
      ViewasListMenuItem.Checked := False;
      FViewAsList := False;
      FConfig.WriteBool('SGAllSettings', 'ViewAsList', False);
    end;

    ListView1.ViewStyle := vsIcon;

    // 1) Отвязываем старый ImageList (от list-режима — он «широкий»)
    ListView1.LargeImages := nil;

    // 2) Пересоздаём с размерами плиток
    FreeAndNil(FListItemHeightImages);
    FListItemHeightImages := TImageList.Create(Self);
    FListItemHeightImages.Width  := FConfig.ReadInteger('SGAllSettings', 'TileWidth', 125);
    FListItemHeightImages.Height := FConfig.ReadInteger('SGAllSettings', 'TileHeight', 100);

    // 3) Привязываем
    ListView1.LargeImages := FListItemHeightImages;
    ListView1.OnAdvancedCustomDrawItem := ListView1AdvancedCustomDrawItem;
    ShowImageonHoverMenuItem.Enabled := True;

    // 4) Сбрасываем унаследованный от list-режима спейсинг —
    //    теперь ListView сам подберёт отступы под размер плитки
    ListView1.Perform(LVM_SETICONSPACING, 0, MAKELPARAM(-1, -1));
    ListView1.Invalidate;
   end else
   begin
    ListView1.ViewStyle := vsReport;
    ListView1.OnAdvancedCustomDrawItem := nil;
    ShowImageonHoverMenuItem.Enabled := False;

    // 1. Отменяем запрос, который поток мог как раз обрабатывать
    FHoverLock.Enter;
    try
      FHoverPendingIndex := -1;
      FHoverQueuedID := '';
    finally
      FHoverLock.Leave;
    end;

    // 2. Останавливаем dwell-таймер (иначе может сработать уже после переключения)
    FHoverDwellTimer.Enabled := False;
    FHoverDwellID    := '';
    FHoverDwellIndex := -1;

    // 3. Освобождаем текущее превью-изображение
    FHoverBitmapID := '';
    FHoverBitmap.Width := 0;

    // 4. Очищаем кэши путей — в Report-режиме они не нужны,
    //    а на большой библиотеке съедают заметный объём памяти
    FHoverPathCache.Clear;
    FHoverNotFoundCache.Clear;

    ClearTileCache;
   end;

   ListView1.Invalidate; // OwnerData сам перезапросит Caption/SubItems через OnData

   FConfig.WriteBool('SGAllSettings', 'ViewAsIcons', Checked);
   FConfig.UpdateFile;
 end;
end;

procedure TSGLMainForm.ViewasListMenuItemClick(Sender: TObject);
begin
with Sender as TMenuItem do
  begin
    Checked := not Checked;
    FViewAsList := Checked;

    if Checked then
    begin
      if ViewasThumbnailsMenuItem.Checked then
      begin
        ViewasThumbnailsMenuItem.Checked := False;
        FConfig.WriteBool('SGAllSettings', 'ViewAsIcons', False);
      end;

            // 1) Отвязываем
      ListView1.LargeImages := nil;
      ListView1.ViewStyle   := vsIcon;

      // 2) Пересоздаём ImageList с размерами list-режима
      FreeAndNil(FListItemHeightImages);
      FListItemHeightImages := TImageList.Create(Self);
      FListItemHeightImages.Width  := 100;
      FListItemHeightImages.Height := 50;

      // 3) Привязываем
      ListView1.LargeImages := FListItemHeightImages;
      ListView1.OnAdvancedCustomDrawItem := ListView1AdvancedCustomDrawItem;
      ShowImageonHoverMenuItem.Enabled := True;

      // 4) Устанавливаем «списочный» отступ
      ListView1.Invalidate;
      ResizeListViewTiles(0);

      // Ключевое: заставляем ListView не перекрашивать tile-background поверх нашей отрисовки
      ListView1.ControlStyle := ListView1.ControlStyle + [csOpaque];
    end
    else
    begin
      ListView1.ViewStyle := vsReport;
      ListView1.OnAdvancedCustomDrawItem := nil;
      ShowImageonHoverMenuItem.Enabled := False;

      // Сброс hover-состояния (как в ViewAsThumbnails1Click)
      FHoverLock.Enter;
      try
        FHoverPendingIndex := -1;
        FHoverQueuedID     := '';
      finally
        FHoverLock.Leave;
      end;
      FHoverDwellTimer.Enabled := False;
      FHoverDwellID    := '';
      FHoverDwellIndex := -1;
      FHoverBitmapID   := '';
      FHoverBitmap.Width := 0;
      FHoverPathCache.Clear;
      FHoverNotFoundCache.Clear;
      ClearTileCache;
    end;

    ListView1.Invalidate;
    FConfig.WriteBool('SGAllSettings', 'ViewAsList', Checked);
    FConfig.UpdateFile;
  end;
end;

procedure TSGLMainForm.ShowImageonHoverMenuItemClick(Sender: TObject);
begin
  FShowImageOnHover := not FShowImageOnHover;
  ShowImageonHoverMenuItem.Checked := FShowImageOnHover;
  FConfig.WriteBool('SGAllSettings', 'ShowImageOnHover', FShowImageOnHover);
  FConfig.UpdateFile;

  if not FShowImageOnHover then
  begin
    // Аннулируем ожидающие запросы к потоку
    FHoverLock.Enter;
    try
      FHoverPendingIndex := -1;
      FHoverQueuedID := '';
    finally
      FHoverLock.Leave;
    end;

    // Останавливаем dwell-таймер, чтобы он не сработал после выключения опции
    FHoverDwellTimer.Enabled := False;
    FHoverDwellID    := '';
    FHoverDwellIndex := -1;

    // Сбрасываем уже загруженное превью
    FHoverBitmapID := '';
    FHoverBitmap.Width := 0;
  end;

  // Перерисовываем список
  ListView1.Invalidate;
end;

procedure TSGLMainForm.ShowImagesMenuItemClick(Sender: TObject);
begin
 // 1. Переключаем флаг
 FShowListImages := not FShowListImages;
 ShowImagesMenuItem.Checked := FShowListImages;

 // 2. Сохраняем в конфиг
 FConfig.WriteBool('SGAllSettings', 'ShowListImages', FShowListImages);
 FConfig.UpdateFile;

 if not FShowListImages then ClearTileCache;

 // 3. Перерисовываем: без картинок текст в режиме List сам сдвинется к левому краю
 ListView1.Invalidate;
end;

procedure TSGLMainForm.ShowGameDetailsMenuItemClick(Sender: TObject);
begin
with Sender as TMenuItem do
  begin
   Checked := not Checked;
    if Checked then
    begin
     Panel3.Align := alLeft;
     Panel3.Width := FConfig.ReadInteger('SGAllSettings', 'ListViewWidth', SGLMainForm.Width div 3);
     Splitter1.Visible := True;
     Splitter1.Align := alLeft;
     Panel1.Visible := True;
     EnabledimagegalleryMenuItem.Enabled := True;
    end else
    begin
     FConfig.WriteInteger('SGAllSettings', 'ListViewWidth', Panel3.Width);
     Panel1.Visible := False;
     Splitter1.Visible := False;
     Panel3.Align := alClient;
     EnabledimagegalleryMenuItem.Enabled := False;
    end;
   FConfig.WriteBool('SGAllSettings', 'ShowDetailsPanel', Checked);
   FConfig.UpdateFile;

   if not (csDestroying in ComponentState) then
     SGLMainForm.Resize;
  end;
end;

procedure TSGLMainForm.EnabledimagegalleryMenuItemClick(Sender: TObject);
begin
with Sender as TMenuItem do
   begin
    Checked := not Checked;
    FConfig.WriteBool('SGAllSettings', 'Enabled miniatures', Checked);
    FConfig.UpdateFile;
   end;
if MessageDlg('The application needs to restart to apply the changes. Restart now?',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
 begin
  RegIni(True);
  RestartApplication(FClosing);
 end;
end;

procedure TSGLMainForm.ToolBarShowMenuItemClick(Sender: TObject);
begin
with Sender as TMenuItem do
   begin
    Checked := not Checked;
    ToolBar1.Visible := Checked;
    FConfig.WriteBool('SGAllSettings', 'ShowToolBar', Checked);
    FConfig.UpdateFile;
   end;
end;

procedure TSGLMainForm.UseBinaryCacheMenuItemClick(Sender: TObject);
begin
if not FLoadingComplete then Exit;

with Sender as TMenuItem do
   begin
    Checked := not Checked;
    FConfig.WriteBool('SGAllSettings', 'UseBinaryCache', Checked);
    FConfig.UpdateFile;

    if Checked = True then
      FinalizeLoading(True) // включили кэш → пересканировать + перезапустить
    else
    begin
     if MessageDlg('The application needs to restart to apply the changes. Restart now?',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      begin
       RegIni(True);
       RestartApplication(FClosing);
      end;
    end;
   end;
end;

procedure TSGLMainForm.EmptyWorkingSetMenuItemClick(Sender: TObject);
begin
with Sender as TMenuItem do
   begin
    Checked := not Checked;
    FConfig.WriteBool('SGAllSettings', 'EmptyWorkingSet', Checked);
    FConfig.UpdateFile;
   end;
if MessageDlg('The application needs to restart to apply the changes. Restart now?',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
 begin
  RegIni(True);
  RestartApplication(FClosing);
 end;
end;

procedure TSGLMainForm.SpecifyfoldersMenuItemClick(Sender: TObject);
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
    platformcombo.Visible := False;
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

procedure TSGLMainForm.SpecifylanguagefoldersMenuItemClick(Sender: TObject);
begin
 with DiagForm do
   begin
    Caption := 'Specify languages folder';
    Position := poDesktopCenter;
    ActiveControl := Edit1;
    Label2.Caption := 'Changes will take effect after switching tabs.';
    Button3.Hint := 'Select a dir';
    ifFile := False;
    Edit1.Text := FConfig.ReadString('LanguagesPack', 'MS-DOS', '');
    DialogDir := LaunchBoxDir;
    platformcombo.Items.Clear;
    platformcombo.Visible := True;
    FConfig.ReadSection('LanguagesPack',platformcombo.Items);
    if platformcombo.Items.Count > 0 then
      platformcombo.ItemIndex := 0;
     if (Showmodal <> mrCancel) then
      begin
       FConfig.WriteString('LanguagesPack', platformcombo.Items[platformcombo.ItemIndex], Edit1.Text);
       FConfig.UpdateFile;

       // Сбросить кэш — иначе изменения не подхватятся до перезапуска
       if Assigned(FLangPackCache) then
       begin
         FLangPackLock.Enter;
         try
           for var SL in FLangPackCache.Values do SL.Free;
           FLangPackCache.Clear;
         finally
           FLangPackLock.Leave;
         end;
       end;

      end;
   end;
end;

// ListViewPopupActionBar
//-----------------------------------------------------------------------------
procedure TSGLMainForm.RunMenuItemClick(Sender: TObject);
begin
  if ListView1.ItemIndex = -1 then Exit;
  LaunchGame(FFilteredIndices[ListView1.ItemIndex]);
end;

procedure TSGLMainForm.ConfigurationMenuItemClick(Sender: TObject);
var
  AppPath, CmdLine, FullPath: string;
begin
  if ListView1.ItemIndex <> -1 then
  begin
    AppPath := FGameData[FFilteredIndices[ListView1.ItemIndex]].ConfigurationPath;
    CmdLine := FGameData[FFilteredIndices[ListView1.ItemIndex]].ConfigurationCommandLine;
    FullPath := TPath.Combine(LaunchBoxDir, AppPath);
    ShellOpen(FullPath, CmdLine);
  end;
end;

procedure TSGLMainForm.DownloadarchiveMenuItemClick(Sender: TObject);
var
  raw: string;
  langs: TArray<string>;
  AvailableLangs: TArray<string>;
  selectedLang: string;
  Game: TGameData;
  L: string;
begin
  if ListView1.ItemIndex = -1 then Exit;

  Game := FGameData[FFilteredIndices[ListView1.ItemIndex]];

  // Список языков из настроек (всегда включает 'english')
  raw := FConfig.ReadString('LanguagesPack', Game.Platforms, '');
  langs := PrepareLanguageList(raw);

  // Оставляем только те языки, для которых папка игры существует
  SetLength(AvailableLangs, 0);
  for L in langs do
    if IsGameFolderExists(Game, L) and TorrentFileExists(Game, L) then
    begin
      SetLength(AvailableLangs, Length(AvailableLangs) + 1);
      AvailableLangs[High(AvailableLangs)] := L;
    end;

  // Если ни одного языка не найдено – оставляем английский как резерв
  if Length(AvailableLangs) = 0 then
  begin
    SetLength(AvailableLangs, 1);
    AvailableLangs[0] := 'english';
  end;

  // Диалог выбора языка и запуск загрузки
  if ShowComboDialog(AvailableLangs, selectedLang, 'Select language') then
    Aria2Download(selectedLang);
end;

procedure TSGLMainForm.DeletearchiveMenuItemClick(Sender: TObject);
var
  raw: string;
  langs: TArray<string>;
  selectedLang: string;
  ZipPath: string;
  Game: TGameData;
begin
  if ListView1.ItemIndex = -1 then Exit;

  Game := FGameData[FFilteredIndices[ListView1.ItemIndex]];

  raw := FConfig.ReadString('LanguagesPack', Game.Platforms, '');
  langs := PrepareLanguageList(raw);

  // Оставляем только те языки, для которых реально существует ZIP‑архив
  var AvailableLangs: TArray<string>;
  SetLength(AvailableLangs, 0);
  for var L in langs do
  begin
    ZipPath := GetZipPathForLanguage(Game, L);
    if (ZipPath <> '') and FileExists(ZipPath) then
    begin
      SetLength(AvailableLangs, Length(AvailableLangs) + 1);
      AvailableLangs[High(AvailableLangs)] := L;
    end;
  end;

  if Length(AvailableLangs) = 0 then
  begin
    MessageDlg('No setup archives found for deletion.', mtInformation, [mbOK], 0);
    Exit;
  end;

  if ShowComboDialog(AvailableLangs, selectedLang, 'Select the language of the archive to delete') then
  begin
    ZipPath := GetZipPathForLanguage(Game, selectedLang);
    if (ZipPath <> '') and FileExists(ZipPath) then
    begin
      if MessageDlg('Delete archive?'#10#10 + ZipPath,
                    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
        DeleteFile(ZipPath);
    end;
  end;
end;

procedure TSGLMainForm.AddtoFavoritesMenuItemClick(Sender: TObject);
var
  RealIndex, CurIndex: Integer;
begin
  if ListView1.ItemIndex = -1 then Exit;

  CurIndex := ListView1.ItemIndex;
  RealIndex := FFilteredIndices[CurIndex];
  ToggleFavorite(FGameData[RealIndex].ID);

  if SameText(TabView1.Tabs[TabView1.TabIndex].Caption, 'Favorites') then
    RemoveFilteredIndexFromView(CurIndex)
  else
    ListView1.Invalidate;
end;

procedure TSGLMainForm.ManualMenuItemClick(Sender: TObject);
var
  AppPath, FullPath: string;
begin
  if ListView1.ItemIndex <> -1 then
  begin
    AppPath := FGameData[FFilteredIndices[ListView1.ItemIndex]].Manual;
    FullPath := TPath.Combine(LaunchBoxDir, AppPath);
    ShellOpen(FullPath);
  end;
end;

procedure TSGLMainForm.CreatedesktopshortcutMenuItemClick(Sender: TObject);
begin
  CreateDesktopShellLink(ExcludeTrailingPathDelimiter(LaunchBoxDir) +'\'+
  FGameData[FFilteredIndices[ListView1.ItemIndex]].ApplicationPath, FGameData[FFilteredIndices[ListView1.ItemIndex]].GameName);
end;

procedure TSGLMainForm.CustomimagenameMenuItemClick(Sender: TObject);
var
  RealIndex: Integer;
  RawID, CacheID, Platform: string;
begin
  if ListView1.ItemIndex = -1 then Exit;

  RealIndex := FFilteredIndices[ListView1.ItemIndex];
  RawID     := FGameData[RealIndex].ID;
  Platform  := FGameData[RealIndex].Platforms;

  // Ключ кэшей — та же логика, что в GetTileBitmap / RequestHoverImage
  CacheID := RawID;
  if CacheID = '' then
    CacheID := '#' + IntToStr(RealIndex);

  with DiagForm do
  begin
    Caption := FGameData[RealIndex].GameName;
    Position := poDesktopCenter;
    ActiveControl := Edit1;
    Label2.Caption := 'Example: Tomb Raider Gold-01.jpg > Tomb Raider Gold';
    Button3.Hint := 'Select an image';
    ifFile := True;
    Edit1.Text := NConfig.ReadString(Platform, RawID, '');
    DialogDir := LaunchBoxDir + '\Images\' + Platform;
    platformcombo.Visible := False;

    if (Showmodal <> mrCancel) then
    begin
      // 0. Сохраняем новое имя
      if Edit1.Text = '' then
        NConfig.DeleteKey(Platform, RawID)
      else
        NConfig.WriteString(Platform, RawID, Edit1.Text);
      NConfig.UpdateFile;

      // ============================================================
      // 1. Сброс кэша плиток (FShowListImages)
      //    иначе GetTileBitmap отдаст старый битмап / пометку «нет картинки»
      // ============================================================
      FTileLock.Enter;
      try
        FTileCache.Remove(CacheID);   // старый декодированный битмап
        FTileQueued.Remove(CacheID);  // «в очереди» — чтобы можно было запросить заново
      finally
        FTileLock.Leave;
      end;
      FTileNoImage.Remove(CacheID);   // «картинки нет» с прошлого поиска

      // ============================================================
      // 2. Сброс кэша hover-превью (FShowImageOnHover)
      // ============================================================
      FHoverLock.Enter;
      try
        FHoverPathCache.Remove(CacheID);      // найденный ранее путь
        FHoverNotFoundCache.Remove(CacheID);  // ранее «не найдено»

        // Если поток прямо сейчас декодирует именно эту игру — отменяем
        if FHoverQueuedID = CacheID then
        begin
          FHoverQueuedID     := '';
          FHoverPendingIndex := -1;
        end;
      finally
        FHoverLock.Leave;
      end;

      // Если в FHoverBitmap сейчас лежит устаревшая превьюха этой игры
      if FHoverBitmapID = CacheID then
      begin
        FHoverBitmapID := '';
        FHoverBitmap.SetSize(0, 0);
      end;

      // Сбрасываем dwell-таймер, чтобы hover-запрос пошёл заново
      FHoverDwellTimer.Enabled := False;
      FHoverDwellID    := '';
      FHoverDwellIndex := -1;

      // ============================================================
      // 3. Перезагрузить основной скриншот (верхнее превью + галерея)
      //    StartImageLoadThread также обновит ImgList и CreateThumbnails
      // ============================================================
      StartImageLoadThread(ListView1.ItemIndex, RealIndex);

      // ============================================================
      // 4. Перерисовать ListView — hover и плитки подхватят новое имя
      //    (при следующем paint сработают dwell-таймер и GetTileBitmap)
      // ============================================================
      ListView1.Invalidate;
    end;
  end;
end;

end.
