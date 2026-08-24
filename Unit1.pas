unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Types,
  System.IOUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons, Vcl.Imaging.jpeg, Vcl.Imaging.pngimage,
  Vcl.Imaging.GIFImg, ShellAPI, System.ImageList, Vcl.ImgList, Vcl.ToolWin,
  IniFiles, Vcl.Menus, ShlObj, StrUtils, System.Generics.Collections,Vcl.Themes,
  System.TypInfo, SyncObjs;

const
  sReleaseDate = '25.08.2026';
  //Бинарный кэш для игр
  CACHE_VERSION: Word = 1;

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
    ScrollBox2: TScrollBox;
    FlowPanel1: TFlowPanel;
    Enabledimagegallery1: TMenuItem;
    PlayModeLabel: TLabel;
    Splitter3: TSplitter;
    Edit1: TEdit;
    ComboBox2: TComboBox;
    Multilinetabs1: TMenuItem;
    UseBinaryCache1: TMenuItem;
    Core1: TMenuItem;
    pmPlatformFilter: TPopupMenu;
    PlatformBtn: TButton;
    Favorites1: TMenuItem;
    N8: TMenuItem;
    Download1: TMenuItem;
    DeleteZIP1: TMenuItem;
    N9: TMenuItem;
    sepDynamicStart: TMenuItem;
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
    procedure Enabledimagegallery1Click(Sender: TObject);
    procedure Splitter3Moved(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure DeveloperLabelMouseEnter(Sender: TObject);
    procedure DeveloperLabelMouseLeave(Sender: TObject);
    procedure DeveloperLabelClick(Sender: TObject);
    procedure Multilinetabs1Click(Sender: TObject);
    procedure UseBinaryCache1Click(Sender: TObject);
    procedure pmPlatformFilterPopup(Sender: TObject);
    procedure PlatformBtnClick(Sender: TObject);
    procedure Favorites1Click(Sender: TObject);
    procedure Download1Click(Sender: TObject);
    procedure DeleteZIP1Click(Sender: TObject);
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
    //----------------------
    procedure StyleMenuClick(Sender: TObject);
    function GetFConfig: TMemIniFile;
    function GetNConfig: TMemIniFile;
    //Загрузка торрентов
    function GetFTorrentConfig: TMemIniFile;
    procedure RegIni(Write: Boolean);
    procedure WMPostScrollSync(var Msg: TMessage); message WM_USER + 100;
    procedure WMCopyData(var Msg: TWMCopyData); message WM_COPYDATA;
    procedure OnExtrasMenuItemClick(Sender: TObject);
    procedure ToolBarMenuClick(Sender: TObject);
    // Переключение фильтр по информационным лейблам
    procedure ApplyLabelFilter(const Category: string; const Value: string);
    procedure LabelFilterMenuItemClick(Sender: TObject);
   public
    FConfig: TMemIniFile;
    //Загрузка торрентов
    FTorrentConfig: TMemIniFile;
  end;

var
  SGLMainForm: TSGLMainForm;
  LaunchBoxDir: String = '';
  IgnoreDir: String;
  HideInTray: Boolean = False;
  EnabledMiniatures: Boolean = False;

implementation

{$R *.dfm}

uses FullScreenImage, DialogForm, Help, ToolBtnProperties, GamesCore,
     SystemUtils, ToolBars;

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
  FConfig.WriteInteger('SGAllSettings', 'ListViewWidth', Panel3.Width);
  FConfig.WriteInteger('SGAllSettings', 'InfoPanelHeight', ScrollBox1.Height);
  FConfig.WriteBool('SGAllSettings', 'ShowToolBar', ToolBar1.Visible);
  FConfig.WriteString('SGAllSettings', 'ToolBarPosition', GetEnumName(TypeInfo(TAlign), Ord(ToolBar1.Align)));
  FConfig.WriteString('SGAllSettings', 'Styles', TStyleManager.ActiveStyle.Name);
  if TabControl1.Tabs.Count > 0 then
    FConfig.WriteString('SGAllSettings', 'LastTab', TabControl1.Tabs[TabControl1.TabIndex]);
  if EnabledMiniatures then
    FConfig.WriteInteger('SGAllSettings', 'ThumbPos', ScrollBox2.Height);
  FConfig.WriteInteger('SGAllSettings', 'LastFilterCategory', ComboBox1.ItemIndex);
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
  if isIconic(Handle) then
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
  if FConfig.ReadBool('SGAllSettings', 'Enabled miniatures', False) then
   begin
    EnabledMiniatures := True;
    ScrollBox2.Visible := True;
    Enabledimagegallery1.Checked := True;
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
    Enabledimagegallery1.Checked := False;
    Splitter3.Visible := False;
   end;
  // Принудительно заполняем ComboBox1 один раз при запуске
  ComboBox1.ItemIndex := FConfig.ReadInteger('SGAllSettings', 'LastFilterCategory', 0);
  FillGenreSeriesCombo('All');
  //---------------------------------------------------------------------------
  if FConfig.ReadBool('SGAllSettings', 'MultiLineTab', False) then
   begin
    Multilinetabs1.Checked := True;
    TabControl1.MultiLine := True;
   end;
  UseBinaryCache1.Checked := FConfig.ReadBool('SGAllSettings', 'UseBinaryCache', False);
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

  // Для фильтра по платформам
  if Assigned(FSelectedPlatformsAll) then FreeAndNil(FSelectedPlatformsAll);
  if Assigned(FSelectedPlatformsInstalled) then FreeAndNil(FSelectedPlatformsInstalled);
  if Assigned(FSelectedPlatformsFavorites) then FreeAndNil(FSelectedPlatformsFavorites);
  if Assigned(FFavoriteIDs) then FreeAndNil(FFavoriteIDs);
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
  FSelectionTimer := TTimer.Create(Self);
  FSelectionTimer.Interval := 80;        // 70-100 мс — оптимально
  FSelectionTimer.Enabled := False;
  FSelectionTimer.OnTimer := SelectionTimerTimer;

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
  GetFTorrentConfig;
  RegIni(False);

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
  BuildStylesMenu(StyleMenu1, StyleMenuClick);
  StylesLoad(FConfig, StyleMenu1);

  FinalizeLoading;
end;

procedure TSGLMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key = ORD(VK_F1) then About1Click(Sender);

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
  ComboBox1.Width := Panel4.Width div 2 - 6;
  ComboBox2.Left := ComboBox1.Width + 6;
  ComboBox2.Width := ComboBox1.Width - 42;
  PlatformBtn.Left := Panel4.Width - 42;
  ResizeLabelToText(Label1);
  UpdateToolBarWrap(ToolBar1);
  //Миниатюры
  if EnabledMiniatures and ScrollBox2.Visible then
  begin
    // Фиксируем высоту под одну строку миниатюр
    FlowPanel1.Height := ScrollBox2.Height - GetSystemMetrics(SM_CYHSCROLL);

    // Пересчитываем ширину контента
    ScrollBox2.HorzScrollBar.Range := FlowPanel1.Width;
  end;
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
   begin
    Handled := False; // Показывать меню на элементе
    ListView1.ItemIndex := Item.Index;
    UpdateFavoritesMenuItem;
    UpdateMenuItemsForCurrentGame;
   end;
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
    if SameText(SelectedPlatform, 'All') or SameText(SelectedPlatform, 'Installed') or
       SameText(SelectedPlatform, 'Favorites') then
      Item.SubItems.Add(FGameData[RealIndex].Platforms);
  end;
end;

procedure TSGLMainForm.ListView1DblClick(Sender: TObject);
var
  AppPath, CmdLine, FullPath: string;
begin
  if ListView1.ItemIndex = -1 then Exit;

  AppPath := FGameData[FFilteredIndices[ListView1.ItemIndex]].ApplicationPath;
  CmdLine := FGameData[FFilteredIndices[ListView1.ItemIndex]].CommandLine;

  FullPath := TPath.Combine(LaunchBoxDir, AppPath);

  ShellOpen(FullPath, CmdLine);
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
 if FClosing then Exit; // ← добавь сюда

  if not Selected then
  begin
    ClearGameInfo;
    Exit;
  end;
  FSelectionTimer.Enabled := False;
  FPendingItemIndex := Item.Index;
  FSelectionTimer.Enabled := True;
end;

//----OTHER COMPONENTS----
//------------------------------------------------------------------------------
procedure TSGLMainForm.TabControl1Change(Sender: TObject);
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
  ComboBox2.ItemIndex := 0;   // сбрасываем фильтр при смене вкладки
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
      Label1.Caption := ListView1.Selected.Caption;
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
if MessageDlg('The application needs to restart to apply the changes. Restart now?',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
 begin
  RegIni(True);
  RestartApplication(FClosing);
 end;
end;

procedure TSGLMainForm.Enabledimagegallery1Click(Sender: TObject);
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

procedure TSGLMainForm.Multilinetabs1Click(Sender: TObject);
begin
with Sender as TMenuItem do
   begin
    Checked := not Checked;
    TabControl1.MultiLine := Checked;
    if Checked then TabControl1.TabWidth := 0;
    Resize;
    FConfig.WriteBool('SGAllSettings', 'MultiLineTab', Checked);
    FConfig.UpdateFile;
   end;
end;

procedure TSGLMainForm.UseBinaryCache1Click(Sender: TObject);
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
var
  AppPath, FullPath: string;
begin
  if ListView1.ItemIndex <> -1 then
  begin
    AppPath := FGameData[FFilteredIndices[ListView1.ItemIndex]].ConfigurationPath;
    FullPath := TPath.Combine(LaunchBoxDir, AppPath);
    ShellOpen(FullPath);
  end;
end;

procedure TSGLMainForm.Favorites1Click(Sender: TObject);
var
  RealIndex, CurIndex: Integer;
begin
  if ListView1.ItemIndex = -1 then Exit;

  CurIndex := ListView1.ItemIndex;
  RealIndex := FFilteredIndices[CurIndex];
  ToggleFavorite(FGameData[RealIndex].ID);

  if SameText(TabControl1.Tabs[TabControl1.TabIndex], 'Favorites') then
    RemoveFilteredIndexFromView(CurIndex)
  else
    ListView1.Invalidate;
end;

procedure TSGLMainForm.Manual1Click(Sender: TObject);
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
    platformcombo.Visible := False;
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

procedure TSGLMainForm.pmPlatformFilterPopup(Sender: TObject);
begin
  RefreshPlatformFilterMenu;
end;

procedure TSGLMainForm.PlatformBtnClick(Sender: TObject);
var
  AnyChecked: Boolean;
  i: Integer;
  ClearAllItem, SelectAllItem: TMenuItem;
  CurrentTab: string;
begin
  if not FLoadingComplete then Exit;

  CurrentTab := TabControl1.Tabs[TabControl1.TabIndex];

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

//------------------------------------------------------------------------------
// Переключение фильтр по информационным лейблам
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
    for i := 0 to TabControl1.Tabs.Count - 1 do
      if SameText(TabControl1.Tabs[i], LabelText) then
      begin
        TabControl1.TabIndex := i;
        TabControl1.OnChange(TabControl1);
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

procedure TSGLMainForm.Download1Click(Sender: TObject);
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
  if ShowComboDialog(AvailableLangs, selectedLang, 'Выберите язык') then
    Aria2Download(selectedLang);
end;

procedure TSGLMainForm.DeleteZIP1Click(Sender: TObject);
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

//-----------------------------------------------------------------------------

end.
