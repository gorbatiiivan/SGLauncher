unit GamesCore;

interface

uses
  Unit1, SystemUtils, FullScreenImage, Winapi.Windows, Winapi.Messages, System.SysUtils,
  System.Types, System.IOUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms, System.Classes,
  Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.ImgList, SyncObjs, PsAPI,
  Vcl.Imaging.jpeg, Vcl.Imaging.pngimage, Vcl.Imaging.GIFImg, Xml.XMLIntf,
  Xml.XMLDoc, Math, ActiveX, ShellAPI, Vcl.Menus, ShlObj, StrUtils,
  System.Generics.Collections, System.Generics.Defaults;

type
  TSGLMainFormHelper = class helper for TSGLMainForm
    function IsGameInstalled(const G: TGameData; LanguagesPack: TStringList = nil): Boolean;
    procedure AddGameToArray(const G: TGameData);
    procedure SortGameData;
    procedure ScanXMLFromDir(const Dir: string);
    procedure LoadXMLToArrayThreadSafe(const XMLFileName: string);
    procedure LoadXMLFilesMultiThreaded(const XMLFiles: TStringDynArray);
    procedure RefreshInstalledStatus;
    procedure ApplyFilters;
    procedure BuildGenreSeriesList(const PlatformFilter: string; Target: TStringList);
    procedure FillGenreSeriesCombo(const PlatformFilter: string);
    procedure FillFilterValues;
    procedure InitializePlatformTabs;
    procedure FinalizeLoading(ADeleteCache: Boolean = False);
    procedure UpdateLanguagesPackFromGames;
    procedure UpdateExtrasMenu(const GameIndex: Integer);
    procedure ClearGameInfo;
    procedure UpdateGenreSeriesComboForCurrentPlatform;
    procedure ShowGameByIndex(const ItemIndex: Integer);
    procedure UpdateMenuItemsForCurrentGame;
    procedure LoadImageWithRetry(const FileName: string;
              Image: TImage; MaxRetries: Integer = 1);
    procedure StartImageLoadThread(ItemIndex, RealIndex: Integer);
    procedure FindGameImages(const Platforms, GameName, ReleaseDate, ID,
              ForcedName: string; ImageList: TStringList);
    procedure DoProcessPendingTabChange(Sender: TObject);
    procedure PerformTabChange(NewTabIndex: Integer);
    procedure SetupListViewColumns;
    procedure AutoSizeListViewColumns;
    procedure SelectionTimerTimer(Sender: TObject);
    //Для миниатюр
    procedure CreateThumbnails;
    procedure ThumbnailClick(Sender: TObject);
    procedure HighlightSelected(APanel: TPanel);
    procedure StartThumbnailLoadThread;
    procedure ThumbnailLoadThreadProc;
    procedure CreateThumbnailSafe(const FilePath: string; Index: Integer);
    procedure UpdateThumbnailsUI;
    procedure SyncThumbnailWithCurrentIndex;
	  procedure ShowFirstImageAsync;
    procedure LoadFullImageAsync(const FilePath: string);
    procedure SyncThumbnailSelection;
    procedure ResizeThumbnail(Pnl: TPanel; const FilePath: string);
    //Бинарный кэш для спискок игр
    function  IsCacheValid(const CacheFile, XMLDir: string): Boolean;
    procedure SaveGameCache(const CacheFile: string; const XMLFiles: TStringDynArray);
    function  LoadGameCache(const CacheFile: string): Boolean;
    // Для фильтра по платформам
    procedure RefreshPlatformFilterMenu;
    procedure PlatformFilterMenuClick(Sender: TObject);
    procedure LoadPlatformFilterSettings;
    // Избранные
    function IsFavorite(const GameID: string): Boolean;
    procedure ToggleFavorite(const GameID: string);
    procedure UpdateFavoritesMenuItem;
    procedure LoadFavoritesFromConfig;
    procedure RemoveFilteredIndexFromView(ItemIndex: Integer);
    // Загрузка торрентов
    function IsExoFirstFolder(const Path: string): Boolean;
    function GetExoFolderName(const FullPath: string; const Del: Char): string;
    function GetExoFolderNamewithYear(const FullPath: string; const Del: Char; const Year: string): string;
    procedure Aria2Download(Language: String);
    function GetZipPathForLanguage(const G: TGameData; const Language: string): string;
    function TorrentFileExists(const G: TGameData; const Language: string): Boolean;
    function IsGameFolderExists(const G: TGameData; const Language: string): Boolean;
  end;

implementation

uses Aria2Thread;

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

function TSGLMainFormHelper.IsGameInstalled(const G: TGameData; LanguagesPack: TStringList = nil): Boolean;
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
    OwnLP.DelimitedText := SGLMainForm.FConfig.ReadString('LanguagesPack', G.Platforms, '');
    ActiveLP := OwnLP;
  end;

  try
    // Одна ветка вместо двух — NormalizeLaunchBoxPath сама обработает пустой список
    CleanRelPath := NormalizeLaunchBoxPath(G.ApplicationPath,
      FIgnoredFolders, ActiveLP);
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

procedure TSGLMainFormHelper.AddGameToArray(const G: TGameData);
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
      if G.CommandLine <> '' then FGameData[ExistingIndex].CommandLine := G.CommandLine;
      if G.PlayMode <> '' then FGameData[ExistingIndex].PlayMode := G.PlayMode;
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

procedure TSGLMainFormHelper.UpdateExtrasMenu(const GameIndex: Integer);

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
  FixedMenuCount: Integer;
  MarkerIdx: Integer;
begin
  // Удаляем всё, что после маркера
  MarkerIdx := PopupMenu1.Items.IndexOf(sepDynamicStart);
  if MarkerIdx >= 0 then
  begin
    while PopupMenu1.Items.Count > MarkerIdx + 1 do
      PopupMenu1.Items.Delete(PopupMenu1.Items.Count - 1);
  end;

  if GameIndex = -1 then Exit;
  AppPath := FGameData[GameIndex].ApplicationPath;
  if AppPath = '' then Exit;

  BasePath := ExtractFilePath(AppPath);
  FullExtrasPath := IncludeTrailingPathDelimiter(LaunchBoxDir) +
                    IncludeTrailingPathDelimiter(BasePath) + 'Extras';

  // Проверяем, есть ли что-нибудь для добавления
  HasItems := TDirectory.Exists(FullExtrasPath);

  // Проверяем наличие языковых папок (можно добавить функцию для проверки)
  LanguagesString := FConfig.ReadString('LanguagesPack', FGameData[GameIndex].Platforms, '');

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

procedure TSGLMainFormHelper.ClearGameInfo;
begin
  // Таймер для переключения игр
  FSelectionTimer.Enabled := False;
  FPendingItemIndex := -1;

  ListView1.ItemIndex := -1;
  TitleLabel.Caption := '';
  PlatformLabel.Caption := '';
  ReleaseLabel.Caption := '';
  DeveloperLabel.Caption := '';
  PublisherLabel.Caption := '';
  GenreLabel.Caption := '';
  SeriesLabel.Caption := '';
  PlayModeLabel.Caption := '';
  Label1.Caption := '';
  ResizeLabelToText(Label1);
  ScreenShotImage.Picture := nil;
  ImgCurIndex := -1;
  ImgList.Clear;
  NextImgBtn.Enabled := False;
  PrevImgBtn.Enabled := False;

  // очистить накопленные иконки
  while PopupMenu1.Items.Count > 12 do
    PopupMenu1.Items.Delete(PopupMenu1.Items.Count - 1);
  if PopupMenu1.Images <> nil then
    (PopupMenu1.Images as TImageList).Clear;

  // очистка миниатюр
  FThumbnailCancel := True;
  // завершения потока загрузки миниатюр
  if Assigned(FThumbnailLoadThread) then
  begin
    FThumbnailLoadThread.Terminate;
    FThumbnailLoadThread.WaitFor;
    FreeAndNil(FThumbnailLoadThread);
  end;

  while FlowPanel1.ControlCount > 0 do
    FlowPanel1.Controls[0].Free;

  FSelectedPanel := nil;
  FAllImageFiles := nil;
  FCurrentThumbnailIndex := 0;
  // Сбрасываем флаги потока
  FThumbnailPending := False;
  FThumbnailCancel := False;
  //------------------------------------
end;

procedure TSGLMainFormHelper.BuildGenreSeriesList(const PlatformFilter: string;
  Target: TStringList);
var
  i, j: Integer;
  GameGenres, GameSeries, PlayModes: TStringDynArray;
  IsAll, IsInstalled: Boolean;
begin
  IsAll       := SameText(PlatformFilter, 'All');
  IsInstalled := SameText(PlatformFilter, 'Installed');

  for i := 0 to High(FGameData) do
  begin
    if IsInstalled then
    begin
      if not FGameData[i].IsInstalled then Continue;
    end
    else if not IsAll then
    begin
      if not SameText(FGameData[i].Platforms, PlatformFilter) then Continue;
    end;

    // === Жанры ===
    if FGameData[i].Genre <> '' then
    begin
      GameGenres := FGameData[i].Genre.Split([';'{, '/'}]);
      for j := 0 to High(GameGenres) do
      begin
        GameGenres[j] := Trim(GameGenres[j]);
        if GameGenres[j] <> '' then
          Target.Add('[Genre] ' + GameGenres[j]);
      end;
    end;

    // === Серии ===
    if FGameData[i].Series <> '' then
    begin
      GameSeries := FGameData[i].Series.Split([';'{, '/'}]);
      for j := 0 to High(GameSeries) do
      begin
        GameSeries[j] := Trim(GameSeries[j]);
        if GameSeries[j] <> '' then
          Target.Add('[Series] ' + GameSeries[j]);
      end;
    end;

    // === PlayMode ===
    if FGameData[i].PlayMode <> '' then
    begin
      PlayModes := FGameData[i].PlayMode.Split([';']);
      for j := 0 to High(PlayModes) do
      begin
        PlayModes[j] := Trim(PlayModes[j]);
        if PlayModes[j] <> '' then
          Target.Add('[PlayMode] ' + PlayModes[j]);
      end;
    end;

    // === Developer ===
    if FGameData[i].Developer <> '' then
      Target.Add('[Developer] ' + Trim(FGameData[i].Developer));

    // === Publisher ===
    if FGameData[i].Publisher <> '' then
      Target.Add('[Publisher] ' + Trim(FGameData[i].Publisher));

    // === Source ===
    if FGameData[i].Source <> '' then
     begin
      var Sources := FGameData[i].Source.Split([';']);
      for var s in Sources do
      if Trim(s) <> '' then
        Target.Add('[Source] ' + Trim(s));
     end;

    // === Year ===
    if FGameData[i].ReleaseYear > 0 then
      Target.Add('[Year] ' + IntToStr(FGameData[i].ReleaseYear));
  end;
end;

procedure TSGLMainFormHelper.FillGenreSeriesCombo(const PlatformFilter: string);
var
  SavedIndex: Integer;
begin
  // === Заполняем ComboBox1 ТОЛЬКО если он ещё пустой (при запуске) ===
  if ComboBox1.Items.Count = 0 then
  begin
    SavedIndex := FConfig.ReadInteger('SGAllSettings', 'LastFilterCategory', 0);

    ComboBox1.Items.BeginUpdate;
    try
      ComboBox1.Clear;
      ComboBox1.Items.AddStrings(['Genre', 'Series', 'Developer', 'Publisher', 'Play Mode', 'Source', 'Year']);

      if (SavedIndex >= 0) and (SavedIndex < ComboBox1.Items.Count) then
        ComboBox1.ItemIndex := SavedIndex
      else
        ComboBox1.ItemIndex := 0;
    finally
      ComboBox1.Items.EndUpdate;
    end;
  end;

  // Всегда обновляем только ComboBox2
  FillFilterValues;
end;

procedure TSGLMainFormHelper.FillFilterValues;
var
  SL: TStringList;
  i: Integer;
  Parts: TStringDynArray;
  SelectedPlatform: string;
  IsAllTab, IsInstalledTab, IsFavoritesTab: Boolean;
  SelectedPlatforms: TStringList;
  PlatformFilterActive: Boolean;
  GamePlatforms: string;
begin
  if TabControl1.TabIndex < 0 then Exit;

  SL := TStringList.Create;
  try
    SL.Sorted := True;
    SL.Duplicates := dupIgnore;

    SelectedPlatform := TabControl1.Tabs[TabControl1.TabIndex];
    IsAllTab := SameText(SelectedPlatform, 'All');
    IsInstalledTab := SameText(SelectedPlatform, 'Installed');
    IsFavoritesTab := SameText(SelectedPlatform, 'Favorites');

    // Определяем, какой список платформ использовать
    if IsAllTab then
    begin
      SelectedPlatforms := FSelectedPlatformsAll;
      PlatformFilterActive := FPlatformFilterActiveAll;
    end
    else if IsInstalledTab then
    begin
      SelectedPlatforms := FSelectedPlatformsInstalled;
      PlatformFilterActive := FPlatformFilterActiveInstalled;
    end
    else if IsFavoritesTab then
    begin
      SelectedPlatforms := FSelectedPlatformsFavorites;
      PlatformFilterActive := FPlatformFilterActiveFavorites;
    end
    else
    begin
      SelectedPlatforms := nil;
      PlatformFilterActive := False;
    end;

    for i := 0 to High(FGameData) do
    begin
      // === Основной фильтр по вкладке ===
      if IsInstalledTab then
      begin
        if not FGameData[i].IsInstalled then Continue;
      end
      else if IsFavoritesTab then
      begin
        if not IsFavorite(FGameData[i].ID) then Continue;
      end
      else if not IsAllTab then
      begin
        if not SameText(FGameData[i].Platforms, SelectedPlatform) then Continue;
      end;

      // === Дополнительный фильтр по выбранным платформам (pmPlatformFilter) ===
      if PlatformFilterActive and Assigned(SelectedPlatforms) then
      begin
        GamePlatforms := FGameData[i].Platforms;
        if (GamePlatforms <> '') and (SelectedPlatforms.IndexOf(GamePlatforms) < 0) then
          Continue;
      end;

      case ComboBox1.ItemIndex of
        0: Parts := FGameData[i].Genre.Split([';'{,'/'}]);
        1: Parts := FGameData[i].Series.Split([';'{,'/'}]);
        2: Parts := FGameData[i].Developer.Split([';']);
        3: Parts := FGameData[i].Publisher.Split([';']);
        4: Parts := FGameData[i].PlayMode.Split([';']);
        5: Parts := FGameData[i].Source.Split([';']);
        6: // Year
          begin
            if FGameData[i].ReleaseYear > 0 then
              SL.Add(IntToStr(FGameData[i].ReleaseYear));
            Continue; // пропускаем Parts
          end;
      else
        Continue;
      end;

      for var s in Parts do
        if Trim(s) <> '' then
          SL.Add(Trim(s));
    end;

    ComboBox2.Items.BeginUpdate;
    try
      ComboBox2.Clear;
      ComboBox2.Items.Add('All');
      ComboBox2.Items.AddStrings(SL);
      ComboBox2.ItemIndex := 0;
    finally
      ComboBox2.Items.EndUpdate;
    end;
  finally
    SL.Free;
  end;
end;

procedure TSGLMainFormHelper.InitializePlatformTabs;
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
         (FGameData[i].Platforms <> 'Installed') and
         (FGameData[i].Platforms <> 'Favorites') then
        Platforms.Add(FGameData[i].Platforms);

    TabControl1.Tabs.Clear;
    TabControl1.Tabs.Add('All');
    TabControl1.Tabs.Add('Installed');
    TabControl1.Tabs.Add('Favorites');
    for i := 0 to Platforms.Count - 1 do
      TabControl1.Tabs.Add(Platforms[i]);
    TabControl1.TabIndex := 0;

    FillGenreSeriesCombo('All');
  finally
    Platforms.Free;
  end;
end;

procedure TSGLMainFormHelper.FinalizeLoading(ADeleteCache: Boolean = False);
var
  PlatformsDir: string;
  CacheFile: string;
  XMLFiles: TStringDynArray;
  SavedTab: string;
  TabIdx: Integer;
begin
  PlatformsDir := LaunchBoxDir + '\Data\Platforms\';

  // 1. При вызове через F5/меню — защита от двойного вызова
  if ADeleteCache then
  begin
    if FClosing or (csDestroying in ComponentState) or not FLoadingComplete then Exit;
    if Assigned(FLoaderThread) and not FLoaderThread.Finished then Exit;
  end;

  // 2. При старте — проверяем наличие папки и XML
  if not ADeleteCache then
  begin
    if not TDirectory.Exists(PlatformsDir) then
    begin
      TrayIcon.Icon := Application.Icon;
      SGLMainForm.Icon := Application.Icon;
      Caption := 'Folder not found';
      TrayIcon.Hint := Caption;
      Exit;
    end;

    XMLFiles := TDirectory.GetFiles(PlatformsDir, '*.xml', TSearchOption.soTopDirectoryOnly);
    if Length(XMLFiles) = 0 then
    begin
      TrayIcon.Icon := Application.Icon;
      SGLMainForm.Icon := Application.Icon;
      Caption := 'No XML files';
      TrayIcon.Hint := Caption;
      Exit;
    end;
  end;

  // 3. Общая подготовка UI
  FClosing := False;
  FLoadingComplete := False;
  UseBinaryCache1.Enabled := False;

  if ADeleteCache then
  begin
    // 4a. Режим пересоздания кэша (F5 / меню)
    ClearGameInfo;
    ListView1.Items.Count := 0;
    Caption := 'Refreshing database...';

    // 5. Удаляем .bin чтобы ScanXMLFromDir пересоздал его
    CacheFile := ExtractFilePath(ParamStr(0)) + ExtractFileName(ChangeFileExt(ParamStr(0), '.bin'));
    if FileExists(CacheFile) then
      try
        TFile.Delete(CacheFile);
      except
        // ignore
      end;
  end
  else
  begin
    // 4b. Режим первого запуска
    Caption := 'Loading...';
  end;

  TrayIcon.Hint := Caption;

  // 6. Запускаем поток загрузки
  FLoaderThread := TThread.CreateAnonymousThread(
    procedure
    begin
      CoInitialize(nil);
      try
        ScanXMLFromDir(PlatformsDir);
        SetLength(FGameData, FActualGameCount);

        if TThread.CurrentThread.CheckTerminated or FClosing then Exit;

        // 7. Восстанавливаем UI в главном потоке
        TThread.Queue(nil,
          procedure
          begin
            if FClosing or (csDestroying in ComponentState) then Exit;

            Edit1.Enabled := True;
            ComboBox1.Enabled := True;
            ComboBox2.Enabled := True;
            PlatformBtn.Enabled := True;
            ScrollBox1.Enabled := True;
            NextImgBtn.Enabled := True;
            UseBinaryCache1.Enabled := True;
            TrayIcon.Icon := Application.Icon;
            SGLMainForm.Icon := Application.Icon;

            InitializePlatformTabs;
            FLoadingComplete := True;
            UpdateLanguagesPackFromGames;

            SavedTab := FConfig.ReadString('SGAllSettings', 'LastTab', 'All');
            TabIdx := TabControl1.Tabs.IndexOf(SavedTab);
            if TabIdx < 0 then TabIdx := TabControl1.Tabs.IndexOf('All');
            if TabIdx < 0 then TabIdx := 0;
            TabControl1.TabIndex := TabIdx;

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

            Caption := Format('%s %d', [TabControl1.Tabs[TabControl1.TabIndex] + ' - ', Length(FFilteredIndices)]);
            if Length(FGameData) <> Length(FFilteredIndices) then
              Caption := Caption + Format(' / %d', [Length(FGameData)]);
            TrayIcon.Hint := Caption;

            ActiveControl := ListView1;
            if ListView1.Items.Count > 0 then
            begin
              ListView1.ItemIndex := 0;
              ListView1.Selected := ListView1.Items[0];
              ListView1.Selected.MakeVisible(False);
            end;
          end);
      finally
        CoUninitialize;
      end;
    end
  );

  FLoaderThread.FreeOnTerminate := False;
  FLoaderThread.Start;
end;

procedure TSGLMainFormHelper.UpdateLanguagesPackFromGames;
var
  i: Integer;
  Platform: string;
  SL: TStringList;
begin
  if not Assigned(FConfig) then Exit;

  SL := TStringList.Create;
  try
    SL.Sorted := True;
    SL.Duplicates := dupIgnore;

    // Собираем уникальные платформы из всех игр
    for i := 0 to High(FGameData) do
    begin
      Platform := Trim(FGameData[i].Platforms);
      if Platform = '' then Continue;
      // Исключаем служебные значения, которые не являются реальными платформами
      if SameText(Platform, 'All') or SameText(Platform, 'Installed') or SameText(Platform, 'Favorites') then
        Continue;
      SL.Add(Platform);
    end;

    // Добавляем недостающие платформы в секцию LanguagesPack с пустым значением
    for i := 0 to SL.Count - 1 do
    begin
      Platform := SL[i];
      if not FConfig.ValueExists('LanguagesPack', Platform) then
        FConfig.WriteString('LanguagesPack', Platform, '');
    end;

    FConfig.UpdateFile;
  finally
    SL.Free;
  end;
end;

procedure TSGLMainFormHelper.ApplyFilters;
var
  i, Count: Integer;
  SelectedPlatform: string;
  FilterValue: string;
  Match: Boolean;
  IsPlatformTab: Boolean;
  SelectedPlatforms: TStringList;
  PlatformFilterActive: Boolean;
begin
  if not FLoadingComplete then Exit;

  SelectedPlatform := TabControl1.Tabs[TabControl1.TabIndex];
  Count := 0;
  SetLength(FFilteredIndices, Length(FGameData));

  // Определяем, является ли текущая вкладка конкретной платформой
  IsPlatformTab := not (SameText(SelectedPlatform, 'All') or
                        SameText(SelectedPlatform, 'Installed') or
                        SameText(SelectedPlatform, 'Favorites'));

  // Выбираем правильные настройки фильтра
  if SameText(SelectedPlatform, 'All') then
  begin
    SelectedPlatforms := FSelectedPlatformsAll;
    PlatformFilterActive := FPlatformFilterActiveAll;
  end
  else if SameText(SelectedPlatform, 'Installed') then
  begin
    SelectedPlatforms := FSelectedPlatformsInstalled;
    PlatformFilterActive := FPlatformFilterActiveInstalled;
  end
  else if SameText(SelectedPlatform, 'Favorites') then
  begin
    SelectedPlatforms := FSelectedPlatformsFavorites;
    PlatformFilterActive := FPlatformFilterActiveFavorites;
  end
  else
  begin
    SelectedPlatforms := nil;
    PlatformFilterActive := False;
  end;

  for i := 0 to High(FGameData) do
  begin
    // Фильтр по платформе / Installed
    if SameText(SelectedPlatform, 'Installed') then
    begin
      if not FGameData[i].IsInstalled then Continue;
    end
    else if SameText(SelectedPlatform, 'Favorites') then
    begin
      if not IsFavorite(FGameData[i].ID) then Continue;
    end
    else if (SelectedPlatform <> 'All') and
            not SameText(FGameData[i].Platforms, SelectedPlatform) then
      Continue;

        // ==================== ФИЛЬТР ПО ВЫБРАННЫМ ПЛАТФОРМАМ (pmPlatformFilter) ====================
    // Применяем ТОЛЬКО на вкладках "All" и "Installed"
    if not IsPlatformTab and PlatformFilterActive and Assigned(SelectedPlatforms) then
    begin
      if SelectedPlatforms.IndexOf(FGameData[i].Platforms) < 0 then
        Continue;
    end;

    // ==================== ФИЛЬТР ПО ComboBox2 ====================
    if (ComboBox2.ItemIndex > 0) and (ComboBox2.Text <> 'All') then
    begin
      Match := False;
      FilterValue := Trim(ComboBox2.Text);

      case ComboBox1.ItemIndex of
        0: // Genre
          if FGameData[i].Genre <> '' then
            for var g in FGameData[i].Genre.Split([';'{,'/'}]) do
              if SameText(Trim(g), FilterValue) then begin Match := True; Break; end;

        1: // Series
          if FGameData[i].Series <> '' then
            for var s in FGameData[i].Series.Split([';'{,'/'}]) do
              if SameText(Trim(s), FilterValue) then begin Match := True; Break; end;

        2: // Developer
          if FGameData[i].Developer <> '' then
            for var d in FGameData[i].Developer.Split([';']) do
              if SameText(Trim(d), FilterValue) then begin Match := True; Break; end;

        3: // Publisher
          if FGameData[i].Publisher <> '' then
            for var p in FGameData[i].Publisher.Split([';']) do
              if SameText(Trim(p), FilterValue) then begin Match := True; Break; end;

        4: // Play Mode
          if FGameData[i].PlayMode <> '' then
            for var pm in FGameData[i].PlayMode.Split([';']) do
              if SameText(Trim(pm), FilterValue) then begin Match := True; Break; end;

        5: // Source
          if FGameData[i].Source <> '' then
            for var s in FGameData[i].Source.Split([';']) do
              if SameText(Trim(s), FilterValue) then begin Match := True; Break; end;

        6: // Year
          if (FGameData[i].ReleaseYear > 0) and
             (FGameData[i].ReleaseYear = StrToIntDef(FilterValue, 0)) then
            Match := True;
      end;

      if not Match then Continue;
    end;

    // Поиск по названию игры
    if (FSearchText <> '') and
       (Pos(LowerCase(FSearchText), LowerCase(FGameData[i].GameName)) = 0) then
      Continue;

    FFilteredIndices[Count] := i;
    Inc(Count);
  end;

  SetLength(FFilteredIndices, Count);
  ListView1.Items.Count := Length(FFilteredIndices);
  ListView1.Invalidate;

  Caption := Format('%s %d', [SelectedPlatform + ' - ', Length(FFilteredIndices)]);
  if Length(FGameData) <> Length(FFilteredIndices) then
    Caption := Caption + Format(' / %d', [Length(FGameData)]);

  TrayIcon.Hint := Caption;

  ClearGameInfo;
end;

procedure TSGLMainFormHelper.SortGameData;
begin
  TArray.Sort<TGameData>(FGameData,
    TComparer<TGameData>.Construct(
      function(const A, B: TGameData): Integer
      begin
        Result := CompareText(A.GameName, B.GameName);
      end));
end;

procedure TSGLMainFormHelper.UpdateGenreSeriesComboForCurrentPlatform;
begin
  if not FLoadingComplete or FClosing or (csDestroying in ComponentState) then Exit;

  FillGenreSeriesCombo(TabControl1.Tabs[TabControl1.TabIndex]);
end;

procedure TSGLMainFormHelper.ShowGameByIndex(const ItemIndex: Integer);
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
  PlayModeLabel.Caption := 'Play Mode: ' + FGameData[RealIndex].PlayMode;
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

  if DirectoryExists(ExtractFilePath(ParamStr(0))+'torrents') and
   FileExists(ExtractFilePath(ParamStr(0))+'torrents\torrents.txt') and
   SGLMainForm.FTorrentConfig.SectionExists(FGameData[RealIndex].Platforms) then
  begin
   Download1.Visible := IsExoFirstFolder(FGameData[RealIndex].ApplicationPath);
   DeleteZIP1.Visible := IsExoFirstFolder(FGameData[RealIndex].ApplicationPath);
   N1.Visible := IsExoFirstFolder(FGameData[RealIndex].ApplicationPath);
  end else
  begin
   Download1.Visible := False;
   DeleteZIP1.Visible := False;
   N1.Visible := False;
  end;

  // ===== ЗАПУСКАЕМ ПОТОК ДЛЯ ЗАГРУЗКИ ИЗОБРАЖЕНИЙ =====
  StartImageLoadThread(ItemIndex, RealIndex);

  // ===== EXTRAS =====
  UpdateExtrasMenu(RealIndex);
end;

procedure TSGLMainFormHelper.UpdateMenuItemsForCurrentGame;
var
  RealIndex: Integer;
begin
  if ListView1.ItemIndex < 0 then Exit;
  if ListView1.ItemIndex >= Length(FFilteredIndices) then Exit;

  RealIndex := FFilteredIndices[ListView1.ItemIndex];
  if (RealIndex < 0) or (RealIndex >= Length(FGameData)) then Exit;

  // 1. Обновляем IsInstalled (если нужно – актуальная проверка)
  FGameData[RealIndex].IsInstalled := IsGameInstalled(FGameData[RealIndex], nil);

  // 2. Run / Install
  if FGameData[RealIndex].IsInstalled then
    Run1.Caption := 'Run'
  else
    Run1.Caption := 'Install';

  // 3. Configuration
  if FGameData[RealIndex].ConfigurationPath = '' then
    Configuration1.Enabled := False
  else
    Configuration1.Enabled := FGameData[RealIndex].IsInstalled;

  // 4. Manual
  Manual1.Enabled := FileExists(LaunchBoxDir + '\' + FGameData[RealIndex].Manual);
end;

procedure TSGLMainFormHelper.LoadImageWithRetry(const FileName: string;
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

procedure TSGLMainFormHelper.StartImageLoadThread(ItemIndex, RealIndex: Integer);
begin
  // Увеличиваем поколение и ставим новое задание
  FImageLoadLock.Enter;
  try
    Inc(FImageGeneration);
    FImageLoadPending := True;
    FImageLoadGameIndex := RealIndex;
    FImageLoadItemIndex := ItemIndex;
  finally
    FImageLoadLock.Leave;
  end;

  // Если поток уже работает — не создаём новый
  if Assigned(FImageLoadThread) and not FImageLoadThread.Finished then
    Exit;

  FImageLoadThread := TThread.CreateAnonymousThread(
    procedure
    var
      CapturedGeneration: Integer;
      LocalGameIndex, LocalItemIndex: Integer;
      LocalPlatform, LocalGameName, LocalReleaseDate, LocalID, LocalForceName: string;
      LocalImgList, QueueList: TStringList;
    begin
      while not (TThread.CurrentThread.CheckTerminated or FClosing) do
      begin
        // === 1. Захватываем задание ===
        FImageLoadLock.Enter;
        try
          if not FImageLoadPending or FClosing then
            Break;

          CapturedGeneration := FImageGeneration;
          LocalGameIndex     := FImageLoadGameIndex;
          LocalItemIndex     := FImageLoadItemIndex;

          LocalPlatform    := FGameData[LocalGameIndex].Platforms;
          LocalGameName    := FGameData[LocalGameIndex].GameName;
          LocalReleaseDate := IntToStr(FGameData[LocalGameIndex].ReleaseYear);
          LocalID          := FGameData[LocalGameIndex].ID;

          if NConfig.ValueExists(LocalPlatform, LocalID) then
            LocalForceName := NConfig.ReadString(LocalPlatform, LocalID, '')
          else
            LocalForceName := '';

          FImageLoadPending := False;   // задание принято
        finally
          FImageLoadLock.Leave;
        end;

        // === 2. Выполняем тяжёлую работу ===
        LocalImgList := TStringList.Create;
        try
          LocalImgList.Duplicates := dupIgnore;
          LocalImgList.CaseSensitive := False;

          FindGameImages(LocalPlatform, LocalGameName, LocalReleaseDate,
                         LocalID, LocalForceName, LocalImgList);

          if TThread.CurrentThread.CheckTerminated or FClosing then Break;

          // === 3. Проверяем, не устарело ли задание ===
          FImageLoadLock.Enter;
          try
            if FImageGeneration <> CapturedGeneration then
              Continue;   // новое задание пришло — пропускаем результат
          finally
            FImageLoadLock.Leave;
          end;

          // === 4. Передаём результат в главный поток ===
          QueueList := LocalImgList;
          LocalImgList := nil;

          TThread.Queue(nil,
            procedure
            begin
              if FClosing or (csDestroying in ComponentState) then
              begin
                QueueList.Free;
                Exit;
              end;

              // Финальная проверка поколения
              if FImageGeneration <> CapturedGeneration then
              begin
                QueueList.Free;
                Exit;
              end;

              ImgList.Clear;
              ImgList.Assign(QueueList);
              QueueList.Free;

              if ImgList.Count > 0 then
              begin
                LoadImageWithRetry(ImgList[0], ScreenShotImage);

                if Assigned(FullScreenForm) and FullScreenForm.Showing then
                  LoadImageWithRetry(ImgList[0], FullScreenForm.FullScreenImage);

                ImgCurIndex := 0;

                if EnabledMiniatures then
                  CreateThumbnails;

                NextImgBtn.Enabled := ImgList.Count > 1;
                PrevImgBtn.Enabled := ImgList.Count > 1;
              end
              else
              begin
                ScreenShotImage.Picture := nil;
                ImgCurIndex := -1;
                NextImgBtn.Enabled := False;
                PrevImgBtn.Enabled := False;
              end;
            end);

        finally
          if Assigned(LocalImgList) then
            LocalImgList.Free;
        end;

        Sleep(40);
      end;
    end);

  FImageLoadThread.FreeOnTerminate := False;
  FImageLoadThread.Start;
end;

procedure TSGLMainFormHelper.FindGameImages(const Platforms, GameName, ReleaseDate, ID, ForcedName: string; ImageList: TStringList);
var
  PlatformDir: string;                 // Папка платформы LaunchBox (например Images\PC)
  Year: string;                        // Год игры
  BaseNameNoYear: string;              // Имя игры без года
  BaseNameWithYear: string;            // Имя игры + (год)
  BaseNameWithYearNoSpace: string;     // Имя игры +(год) без пробела
  PriorityFolders: TArray<string>;     // Приоритетные папки поиска
  ExcludedFolders: TArray<string>;     // Исключаемые папки поиска
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
    //'Screenshot - Game Title',
    'Box - Front',
    'Box - Back',
    'Disc'
  ];

  // -------------------------------------------------
  // ИСКЛЮЧАЕМЫЕ ПАПКИ LaunchBox
  // -------------------------------------------------
  ExcludedFolders := [
    'Screenshot - Game Title'
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

      // исключаем ненужные папки
      var IsExcluded := False;
      for Folder in ExcludedFolders do
        if Pos(IncludeTrailingPathDelimiter(Folder), FilePath) > 0 then
        begin
          IsExcluded := True;
          Break;
        end;
      if IsExcluded then Continue;

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

procedure TSGLMainFormHelper.ScanXMLFromDir(const Dir: string);
var
  XMLFiles: TStringDynArray;
  CacheFile: string;
  i: Integer;
  UseBinaryCache: Boolean;
begin
  FActualGameCount := 0;
  SetLength(FGameData, 4096);
  FGameDict.Clear;

  CacheFile := ExtractFilePath(ParamStr(0)) + ExtractFileName(ChangeFileExt(ParamStr(0),'.bin'));

  XMLFiles := TDirectory.GetFiles(Dir, '*.xml', TSearchOption.soTopDirectoryOnly);
  FTotalXMLFiles := Length(XMLFiles);

  if Length(XMLFiles) = 0 then
  begin
    Caption := 'No XML files found in ' + Dir;
    TrayIcon.Hint := Caption;
    Exit;
  end;

  UseBinaryCache := FConfig.ReadBool('SGAllSettings', 'UseBinaryCache', True);

  // ← Пробуем загрузить из кэша
  if UseBinaryCache and IsCacheValid(CacheFile, Dir) and LoadGameCache(CacheFile) then
  begin
    TThread.Queue(nil, procedure begin
      if not FClosing then Caption := 'Loaded from cache...';
    end);
  end
  else
  begin
    LoadXMLFilesMultiThreaded(XMLFiles);
    SetLength(FGameData, FActualGameCount);
    FGameDict.Clear;
    FGameDict.TrimExcess;
    if Length(FGameData) > 1 then
      SortGameData;
    // Сохраняем кэш только если режим бинарного кэша включён
    if UseBinaryCache then
    begin
      SaveGameCache(CacheFile, XMLFiles);
      // Перезапускаемся только при первом создании кэша
      if not FLoadingComplete then
      begin
        TThread.Queue(nil,
          procedure
          begin
           if MessageDlg('The application needs to restart to apply the changes. Restart now?',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
            begin
             RegIni(True);
             RestartApplication(FClosing);
            end;
          end);
      end;
    end;
  end;

  // IsInstalled — всегда проверяем по файловой системе (не кэшируем)
  for i := 0 to FActualGameCount - 1 do
  begin
    if FClosing or (csDestroying in ComponentState) then Exit;
    FGameData[i].IsInstalled := IsGameInstalled(FGameData[i], nil);
  end;

  SetLength(FFilteredIndices, Length(FGameData));
  for i := 0 to High(FGameData) do
    FFilteredIndices[i] := i;
end;

procedure TSGLMainFormHelper.LoadXMLToArrayThreadSafe(const XMLFileName: string);
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
                                  'ManualPath','ConfigurationPath','RootFolder','ID','CommandLine', 'PlayMode', 'Source']) of
          0: G.GameName          := Trim(Child.Text);
          1: G.ApplicationPath   := Child.Text;
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
          13:G.CommandLine       := Trim(Child.Text);
          14:G.PlayMode          := Trim(Child.Text);
          15:G.Source            := Trim(Child.Text);
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

procedure TSGLMainFormHelper.LoadXMLFilesMultiThreaded(const XMLFiles: TStringDynArray);
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

procedure TSGLMainFormHelper.RefreshInstalledStatus;
var
  i: Integer;
  SharedLP: TStringList;
begin
  if not FLoadingComplete then Exit;
  if FActualGameCount = 0 then Exit;

  // Проверяем, не отменена ли операция
  if FClosing or (csDestroying in ComponentState) then Exit;

  for i := 0 to FActualGameCount - 1 do
   begin
    if FClosing or (csDestroying in ComponentState) then Exit;
    FGameData[i].IsInstalled := IsGameInstalled(FGameData[i], nil);
   end;
end;

procedure TSGLMainFormHelper.DoProcessPendingTabChange(Sender: TObject);
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

procedure TSGLMainFormHelper.PerformTabChange(NewTabIndex: Integer);
// Функция для переключение вкладок
var
  SelectedPlatform: string;
  RedrawRestored: Boolean;
  SavedCategory: Integer;
begin
  if not FLoadingComplete or (csDestroying in ComponentState) then Exit;

  SavedCategory := ComboBox1.ItemIndex;  // сохраняем текущую категорию

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
    FImageLoadThread.WaitFor;
    FreeAndNil(FImageLoadThread);
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
    if SameText(SelectedPlatform, 'Installed') or SameText(SelectedPlatform, 'Favorites') then
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
      ComboBox1.ItemIndex := SavedCategory;  // восстанавливаем после обновления
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

procedure TSGLMainFormHelper.SetupListViewColumns;
// управляет колонками All и Installed и Favorites для отображения платформы
var
  SelectedPlatform: string;
  Col: TListColumn;
  NeedPlatformCol: Boolean;
begin
  if TabControl1.Tabs.Count = 0 then Exit;
  SelectedPlatform := TabControl1.Tabs[TabControl1.TabIndex];
  NeedPlatformCol := SameText(SelectedPlatform, 'All') or
                     SameText(SelectedPlatform, 'Installed') or
                     SameText(SelectedPlatform, 'Favorites');

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

procedure TSGLMainFormHelper.AutoSizeListViewColumns;
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

procedure TSGLMainFormHelper.SelectionTimerTimer(Sender: TObject);
begin
  FSelectionTimer.Enabled := False;
  if FClosing then Exit; // ← обязательно добавь

  if (FPendingItemIndex >= 0) and
     (FPendingItemIndex < ListView1.Items.Count) then
  begin
    // НЕ трогай ListView1.ItemIndex — он уже правильный
    if ListView1.Selected <> nil then
      ShowGameByIndex(FPendingItemIndex);
  end;

  FPendingItemIndex := -1;
end;

//----Для миниатюр----
//------------------------------------------------------------------------------
procedure TSGLMainFormHelper.CreateThumbnails;
var
  i: Integer;
begin
  // 1. Останавливаем всё старое
  FThumbnailLock.Enter;
  try
    FThumbnailCancel := True;
  finally
    FThumbnailLock.Leave;
  end;

  if Assigned(FThumbnailLoadThread) then
  begin
    FThumbnailLoadThread.Terminate;
    FThumbnailLoadThread.WaitFor;
    FreeAndNil(FThumbnailLoadThread);
  end;

  // 2. Полная очистка
  while FlowPanel1.ControlCount > 0 do
    FlowPanel1.Controls[0].Free;

  FSelectedPanel := nil;
  FCurrentThumbnailIndex := 0;
  ImgCurIndex := -1;

  ScrollBox2.HorzScrollBar.Position := 0;

  ScrollBox2.HorzScrollBar.Visible := True;
  ScrollBox2.HorzScrollBar.Tracking := True;
  ScrollBox2.VertScrollBar.Visible := False;

  FlowPanel1.Align := alNone;
  FlowPanel1.AutoSize := False;
  FlowPanel1.FlowStyle := fsLeftRightTopBottom;
  FlowPanel1.Left := 0;
  FlowPanel1.Top := 0;
  FlowPanel1.AutoWrap := False;
  FlowPanel1.Height := FThumbWidth + (PADDING2 * 2) + 4; // 4 — это бордер/отступ панели
  FlowPanel1.Width  := 0; // сбросим ширину перед расчётом

  ScrollBox2.VertScrollBar.Visible := False;
  ScrollBox2.HorzScrollBar.Visible := True;

  SetLength(FAllImageFiles, ImgList.Count);
  for i := 0 to ImgList.Count - 1 do
    FAllImageFiles[i] := ImgList[i];

  if Length(FAllImageFiles) = 0 then
  begin
    FlowPanel1.Width := 0;
    ScrollBox2.HorzScrollBar.Range := 0;
    ScreenShotImage.Picture.Assign(nil);
    Exit;
  end;

  // 3. Сразу показываем первое изображение
  Inc(FThumbnailGeneration);
  ShowFirstImageAsync;

  // 4. Запускаем загрузку миниатюр
  StartThumbnailLoadThread;
end;

procedure TSGLMainFormHelper.ThumbnailClick(Sender: TObject);
var
  Pnl: TPanel;
  ClickedIndex: Integer;
  FilePath: string;
  ThumbWidth: Integer;
  ScrollPos: Integer;
begin
  // Определяем панель, по которой кликнули
  if Sender is TPanel then
    Pnl := TPanel(Sender)
  else if Sender is TImage then
    Pnl := TPanel(TImage(Sender).Parent)
  else
    Exit;

  // Проверяем, что индекс валидный
  ClickedIndex := Pnl.Tag;
  if (ClickedIndex < 0) or (ClickedIndex >= Length(FAllImageFiles)) then
    Exit;

  FilePath := FAllImageFiles[ClickedIndex];
  if not TFile.Exists(FilePath) then
    Exit;

  // Сохраняем текущий индекс
  ImgCurIndex := ClickedIndex;

  // Визуальное выделение
  HighlightSelected(Pnl);

  // Загружаем полноразмерное изображение
  LoadFullImageAsync(FilePath);

  // Прокрутка к выбранной миниатюре
  ThumbWidth := FThumbWidth + 8 + (PADDING2 * 2);
  ScrollPos := (ClickedIndex * ThumbWidth) - (ScrollBox2.ClientWidth div 2) + (ThumbWidth div 2);

  if ScrollPos < 0 then
    ScrollPos := 0;
  if ScrollPos > ScrollBox2.HorzScrollBar.Range - ScrollBox2.ClientWidth then
    ScrollPos := ScrollBox2.HorzScrollBar.Range - ScrollBox2.ClientWidth;

  ScrollBox2.HorzScrollBar.Position := ScrollPos;
end;

procedure TSGLMainFormHelper.HighlightSelected(APanel: TPanel);
// Управляет визуальным выделением выбранной миниатюры
// - Убирает рамку с предыдущей выбранной панели (если была)
// - Устанавливает рамку (BevelOuter := bvLowered) на текущей выбранной панели
// - Сохраняет ссылку на текущую выбранную панель в FSelectedPanel
begin
  // Убираем выделение с предыдущей панели
  if Assigned(FSelectedPanel) then
    FSelectedPanel.BevelOuter := bvNone;

  // Сохраняем новую выбранную панель и выделяем её
  FSelectedPanel := APanel;
  FSelectedPanel.BevelOuter := bvLowered; // Рамка для выделения
end;

procedure TSGLMainFormHelper.StartThumbnailLoadThread;
begin
  // Останавливаем старый поток, если ещё работает
  if (FThumbnailLoadThread <> nil) and not FThumbnailLoadThread.Finished then
  begin
    FThumbnailCancel := True;
    FThumbnailLoadThread.Terminate;
    FThumbnailLoadThread.WaitFor;
    FreeAndNil(FThumbnailLoadThread);
  end
  else if FThumbnailLoadThread <> nil then
    FreeAndNil(FThumbnailLoadThread);

  // Сбрасываем флаги под защитой блокировки
  FThumbnailLock.Enter;
  try
    FThumbnailCancel := False;
    FThumbnailPending := True;
    FCurrentThumbnailIndex := 0;
  finally
    FThumbnailLock.Leave;
  end;

  // Всегда создаём свежий поток
  FThumbnailLoadThread := TThread.CreateAnonymousThread(ThumbnailLoadThreadProc);
  FThumbnailLoadThread.FreeOnTerminate := False;
  FThumbnailLoadThread.Start;
end;

procedure TSGLMainFormHelper.ThumbnailLoadThreadProc;
var
  LocalCancel: Boolean;
  BatchSize: Integer;
  i, EndIndex: Integer;
begin
  BatchSize := 6; // можно сделать 8–10, в зависимости от производительности

  while not (TThread.CurrentThread.CheckTerminated or FClosing) do
  begin
    var ShouldBreak := False;
    FThumbnailLock.Enter;
    try
      if not FThumbnailPending or FThumbnailCancel or FClosing then
        ShouldBreak := True
      else
        LocalCancel := FThumbnailCancel;
    finally
      FThumbnailLock.Leave; // вызывается ровно один раз
    end;
    if ShouldBreak then Break;

    if LocalCancel then Break;

    // Вычисляем, сколько грузить в этом батче
    EndIndex := Min(FCurrentThumbnailIndex + BatchSize, Length(FAllImageFiles));

    if FCurrentThumbnailIndex >= EndIndex then Break;

    // Загружаем батч в потоке
    for i := FCurrentThumbnailIndex to EndIndex - 1 do
    begin
      if TThread.CurrentThread.CheckTerminated or FThumbnailCancel or FClosing then
        Break;

      CreateThumbnailSafe(FAllImageFiles[i], i);
    end;

    FCurrentThumbnailIndex := EndIndex;

    // Обновляем UI в главном потоке
    TThread.Queue(nil, UpdateThumbnailsUI);

    if FCurrentThumbnailIndex >= Length(FAllImageFiles) then
      Break; // всё загрузили

    Sleep(10); // небольшая пауза между батчами
  end;

  FThumbnailLock.Enter;
  try
    FThumbnailPending := False;
  finally
    FThumbnailLock.Leave;
  end;
end;

procedure TSGLMainFormHelper.CreateThumbnailSafe(const FilePath: string; Index: Integer);
var
  Gen: Integer;
begin
  if FThumbnailCancel or FClosing then Exit;
  Gen := FThumbnailGeneration;

  TThread.Queue(nil,
    procedure
    var
      Pnl: TPanel;
      Img: TImage;
      WIC: TWICImage;
      ThumbBmp: TBitmap;
      SrcRect, DstRect: TRect;
      ScaleW, ScaleH: Double;
      NewWidth, NewHeight, OffsetX, OffsetY: Integer;
    begin
      if Gen <> FThumbnailGeneration then Exit;
      if FThumbnailCancel or FClosing or (csDestroying in ComponentState) then Exit;
      if not TFile.Exists(FilePath) then Exit;

      ThumbBmp := nil;
      WIC := nil;
      try
        WIC := TWICImage.Create;
        WIC.LoadFromFile(FilePath);

        if WIC.Empty or (WIC.Width <= 0) or (WIC.Height <= 0) then Exit;

        ThumbBmp := TBitmap.Create;
        ThumbBmp.PixelFormat := pf32bit;
        ThumbBmp.SetSize(FThumbWidth, FThumbHeight);
        ThumbBmp.AlphaFormat := afDefined;

        // Фон
        ThumbBmp.Canvas.Brush.Color := RGB(30, 30, 35);
        ThumbBmp.Canvas.FillRect(Rect(0, 0, FThumbWidth, FThumbHeight));

        // === УЛУЧШЕННОЕ СГЛАЖИВАНИЕ ===
        SetStretchBltMode(ThumbBmp.Canvas.Handle, HALFTONE);
        SetBrushOrgEx(ThumbBmp.Canvas.Handle, 0, 0, nil);

        // Дополнительные настройки качества
        SetGraphicsMode(ThumbBmp.Canvas.Handle, GM_ADVANCED);

        // ========== ЛОГИКА РАЗМЕРА (без изменения разрешения миниатюры) ==========
        ScaleW := FThumbWidth / WIC.Width;
        ScaleH := FThumbHeight / WIC.Height;

        if (ScaleW > 1) and (ScaleH > 1) then
        begin
          // Картинка меньше миниатюры — центрируем без растяжения
          NewWidth  := WIC.Width;
          NewHeight := WIC.Height;
        end
        else
        begin
          // Картинка больше — вписываем с сохранением пропорций
          if ScaleW < ScaleH then
          begin
            NewWidth  := FThumbWidth;
            NewHeight := Round(WIC.Height * ScaleW);
          end
          else
          begin
            NewHeight := FThumbHeight;
            NewWidth  := Round(WIC.Width * ScaleH);
          end;
        end;

        OffsetX := (FThumbWidth  - NewWidth)  div 2;
        OffsetY := (FThumbHeight - NewHeight) div 2;

        DstRect := Rect(OffsetX, OffsetY, OffsetX + NewWidth, OffsetY + NewHeight);
        SrcRect := Rect(0, 0, WIC.Width, WIC.Height);

        // Главное улучшение — StretchDraw с HALFTONE + GM_ADVANCED
        ThumbBmp.Canvas.StretchDraw(DstRect, WIC);

        // Создание панели и изображения (остаётся без изменений)
        Pnl := TPanel.Create(Self);
        Pnl.Parent := FlowPanel1;
        Pnl.Width  := FThumbWidth + 4;
        Pnl.Height := FThumbHeight + 4;
        Pnl.BevelOuter := bvNone;
        Pnl.Color := clBtnFace;
        Pnl.Cursor := crHandPoint;
        Pnl.Tag := Index;
        Pnl.OnClick := ThumbnailClick;
        Pnl.AlignWithMargins := True;
        Pnl.Margins.SetBounds(PADDING2, PADDING2, PADDING2, PADDING2);

        Img := TImage.Create(Self);
        Img.Parent := Pnl;
        Img.Align := alClient;
        Img.Stretch := False;
        Img.Proportional := False;
        Img.Center := True;
        Img.Cursor := crHandPoint;
        Img.OnClick := ThumbnailClick;
        Img.Tag := NativeInt(Pnl);

        Img.Picture.Bitmap.Assign(ThumbBmp);

      finally
        WIC.Free;
        ThumbBmp.Free;
      end;
    end);
end;

procedure TSGLMainFormHelper.UpdateThumbnailsUI;
var
  ThumbWidth: Integer;
  i: Integer;
  ValidPanelFound: Boolean;
  TotalWidth: Integer;
begin
  if FClosing or (csDestroying in ComponentState) then Exit;

  if Assigned(FSelectedPanel) and (FSelectedPanel.Parent = nil) then
    FSelectedPanel := nil;

  ThumbWidth := FThumbWidth + 4 + (PADDING2 * 2);

  // Вычисляем общую ширину на основе реального количества панелей
  TotalWidth := FlowPanel1.ControlCount * ThumbWidth + PADDING2;

  // Добавляем небольшой запас (30 пикселей), чтобы последняя миниатюра
  // не прилипала к правому краю и была видна полностью
  FlowPanel1.Width := TotalWidth + 20;

  ScrollBox2.HorzScrollBar.Range := FlowPanel1.Width;

  // Принудительно обновляем положение прокрутки после изменения диапазона
  ScrollBox2.HorzScrollBar.Position := 0;

  // Убеждаемся, что FlowPanel1 не обрезает содержимое
  FlowPanel1.Invalidate;

  // Выделяем и синхронизируем первую миниатюру
  if (FlowPanel1.ControlCount > 0) and (FSelectedPanel = nil) then
  begin
    ValidPanelFound := False;
    for i := 0 to FlowPanel1.ControlCount - 1 do
    begin
      if (FlowPanel1.Controls[i] is TPanel) and
         (TPanel(FlowPanel1.Controls[i]).ControlCount > 0) then
      begin
        ImgCurIndex := i;
        HighlightSelected(TPanel(FlowPanel1.Controls[i]));
        ValidPanelFound := True;
        Break;
      end;
    end;

    if ValidPanelFound then
    begin
      // Добавляем небольшую задержку перед прокруткой к первому элементу
      PostMessage(Handle, WM_USER + 100, 0, 0);
    end;
  end;
end;

procedure TSGLMainFormHelper.SyncThumbnailWithCurrentIndex;
var
  Pnl: TPanel;
  ThumbWidth: Integer;
  TargetPos: Integer;
  VisibleWidth: Integer;
begin
  if (ImgCurIndex < 0) or (ImgCurIndex >= FlowPanel1.ControlCount) then
    Exit;

  if not (FlowPanel1.Controls[ImgCurIndex] is TPanel) then
    Exit;

  Pnl := TPanel(FlowPanel1.Controls[ImgCurIndex]);

  // Выделяем выбранную миниатюру
  HighlightSelected(Pnl);

  // Прокручиваем галерею так, чтобы миниатюра была примерно по центру
  ThumbWidth := FThumbWidth + 8 + (PADDING2 * 2);
  VisibleWidth := ScrollBox2.ClientWidth;

  TargetPos := ImgCurIndex * ThumbWidth - (VisibleWidth div 2) + (ThumbWidth div 2);

  // Ограничиваем позицию прокрутки
  if TargetPos < 0 then
    TargetPos := 0;
  if TargetPos > ScrollBox2.HorzScrollBar.Range - VisibleWidth then
    TargetPos := ScrollBox2.HorzScrollBar.Range - VisibleWidth;

  ScrollBox2.HorzScrollBar.Position := TargetPos;
end;

procedure TSGLMainFormHelper.ShowFirstImageAsync;
begin
  if Length(FAllImageFiles) = 0 then Exit;

  // Отменяем предыдущую загрузку полного фото (если была)
  FFullImageCancel := True;

  TThread.CreateAnonymousThread(
    procedure
    var
      WIC: TWICImage;
      Bmp: TBitmap;
    begin
      // Небольшая задержка чтобы не грузить если сразу кликают дальше
      Sleep(30);
      if FThumbnailCancel or FClosing then Exit;

      Bmp := nil;
      try
        WIC := TWICImage.Create;
        try
          WIC.LoadFromFile(FAllImageFiles[0]);
          Bmp := TBitmap.Create;
          Bmp.Assign(WIC);
        finally
          WIC.Free;
        end;
      except
        FreeAndNil(Bmp);
        Exit;
      end;

      TThread.Queue(nil,
        procedure
        begin
          if FClosing or (csDestroying in ComponentState) then
          begin
            Bmp.Free;
            Exit;
          end;
          ScreenShotImage.Picture.Bitmap.Assign(Bmp);
          Bmp.Free;
          ImgCurIndex := 0;
        end);
    end).Start;
end;

procedure TSGLMainFormHelper.LoadFullImageAsync(const FilePath: string);
begin
  // Отменяем предыдущую загрузку
  FFullImageCancel := True;

  // Ждём завершения предыдущего потока
  if (FFullImageThread <> nil) and not FFullImageThread.Finished then
  begin
    FFullImageThread.Terminate;
    FFullImageThread.WaitFor; // без параметра - ждём бесконечно
    FreeAndNil(FFullImageThread);
  end
  else if FFullImageThread <> nil then
    FreeAndNil(FFullImageThread);

  FFullImageCancel := False;

  FFullImageThread := TThread.CreateAnonymousThread(
    procedure
    var
      WIC: TWICImage;
      Bmp: TBitmap;
      LocalPath: string;
      Generation: Integer;
    begin
      LocalPath := FilePath;
      Bmp := nil;
      Generation := FImageGeneration;

      try
        if FFullImageCancel or FClosing or TThread.CurrentThread.CheckTerminated then
          Exit;

        WIC := TWICImage.Create;
        try
          WIC.LoadFromFile(LocalPath);

          if FFullImageCancel or FClosing or TThread.CurrentThread.CheckTerminated then
            Exit;

          Bmp := TBitmap.Create;
          Bmp.Assign(WIC);
        finally
          WIC.Free;
        end;

        if FFullImageCancel or FClosing or TThread.CurrentThread.CheckTerminated or (Bmp = nil) then
          Exit;

        TThread.Queue(nil,
          procedure
          begin
            if FClosing or (csDestroying in ComponentState) then
            begin
              Bmp.Free;
              Exit;
            end;

            if not FFullImageCancel and (Generation = FImageGeneration) then
            begin
              ScreenShotImage.Picture.Bitmap.Assign(Bmp);
              if Assigned(FullScreenForm) and FullScreenForm.Showing then
                FullScreenForm.FullScreenImage.Picture.Bitmap.Assign(Bmp);
            end;

            Bmp.Free;
          end);
      except
        Bmp.Free;
      end;
    end);

  FFullImageThread.FreeOnTerminate := False;
  FFullImageThread.Start;
end;

procedure TSGLMainFormHelper.SyncThumbnailSelection;
var
  Pnl: TPanel;
begin
  if ImgCurIndex < 0 then Exit;
  if ImgCurIndex >= FlowPanel1.ControlCount then Exit;
  if not (FlowPanel1.Controls[ImgCurIndex] is TPanel) then Exit;

  if FlowPanel1.Controls[ImgCurIndex] is TPanel then
  begin
    Pnl := TPanel(FlowPanel1.Controls[ImgCurIndex]);
    HighlightSelected(Pnl);

    // Прокручиваем к выбранной миниатюре
    var ThumbWidth := FThumbWidth + 8 + (PADDING2 * 2);
    var ScrollPos := (ImgCurIndex * ThumbWidth) - (ScrollBox2.ClientWidth div 2) + (ThumbWidth div 2);

    if ScrollPos < 0 then ScrollPos := 0;
    if ScrollPos > ScrollBox2.HorzScrollBar.Range - ScrollBox2.ClientWidth then
      ScrollPos := ScrollBox2.HorzScrollBar.Range - ScrollBox2.ClientWidth;

    ScrollBox2.HorzScrollBar.Position := ScrollPos;
  end;
end;

procedure TSGLMainFormHelper.ResizeThumbnail(Pnl: TPanel; const FilePath: string);
var
  Img: TImage;
  WIC: TWICImage;
  ThumbBmp: TBitmap;
  ScaleW, ScaleH: Double;
  NewWidth, NewHeight, OffsetX, OffsetY: Integer;
  DstRect: TRect;
begin
  if (Pnl = nil) or (Pnl.ControlCount = 0) then Exit;
  if not (Pnl.Controls[0] is TImage) then Exit;
  if not TFile.Exists(FilePath) then Exit;

  Img := TImage(Pnl.Controls[0]);

  Pnl.Width  := FThumbWidth + 4;
  Pnl.Height := FThumbHeight + 4;

  ThumbBmp := TBitmap.Create;
  WIC := TWICImage.Create;
  try
    WIC.LoadFromFile(FilePath);
    if WIC.Empty then Exit;

    ThumbBmp.PixelFormat := pf32bit;
    ThumbBmp.SetSize(FThumbWidth, FThumbHeight);
    ThumbBmp.AlphaFormat := afDefined;

    ThumbBmp.Canvas.Brush.Color := RGB(30, 30, 35);
    ThumbBmp.Canvas.FillRect(Rect(0, 0, FThumbWidth, FThumbHeight));

    SetStretchBltMode(ThumbBmp.Canvas.Handle, HALFTONE);

    // ========== Та же логика ==========
    ScaleW := FThumbWidth / WIC.Width;
    ScaleH := FThumbHeight / WIC.Height;

    if (ScaleW > 1) and (ScaleH > 1) then
    begin
      NewWidth  := WIC.Width;
      NewHeight := WIC.Height;
    end
    else
    begin
      if ScaleW < ScaleH then
      begin
        NewWidth  := FThumbWidth;
        NewHeight := Round(WIC.Height * ScaleW);
      end
      else
      begin
        NewHeight := FThumbHeight;
        NewWidth  := Round(WIC.Width * ScaleH);
      end;
    end;

    OffsetX := (FThumbWidth  - NewWidth)  div 2;
    OffsetY := (FThumbHeight - NewHeight) div 2;

    DstRect := Rect(OffsetX, OffsetY, OffsetX + NewWidth, OffsetY + NewHeight);

    ThumbBmp.Canvas.StretchDraw(DstRect, WIC);
    Img.Picture.Bitmap.Assign(ThumbBmp);

  finally
    WIC.Free;
    ThumbBmp.Free;
  end;
end;

// Бинарный кэш для спискок игр
// Возвращает True если кэш существует и все XML не изменились с момента его создания
function TSGLMainFormHelper.IsCacheValid(const CacheFile, XMLDir: string): Boolean;
var
  CacheAge: TDateTime;
  XMLFiles: TStringDynArray;
  F: string;
  S: TFileStream;
  Ver: Word;
  SavedCount, i: Integer;
  SavedNames: TStringList;
  function ReadStr: string;
  var B: TBytes; Len: Word;
  begin
    S.ReadBuffer(Len, SizeOf(Len));
    SetLength(B, Len);
    if Len > 0 then S.ReadBuffer(B[0], Len);
    Result := TEncoding.UTF8.GetString(B);
  end;
begin
  Result := False;
  if not FileExists(CacheFile) then Exit;

  XMLFiles := TDirectory.GetFiles(XMLDir, '*.xml', TSearchOption.soTopDirectoryOnly);
  if Length(XMLFiles) = 0 then Exit;

  // 1. Проверка дат — любой XML новее кэша → пересоздаём
  CacheAge := TFile.GetLastWriteTime(CacheFile);
  for F in XMLFiles do
    if TFile.GetLastWriteTime(F) > CacheAge then Exit;

  // 2. Проверка списка файлов — считываем сохранённые имена из кэша
  SavedNames := TStringList.Create;
  try
    try
      S := TFileStream.Create(CacheFile, fmOpenRead or fmShareDenyWrite);
      try
        S.ReadBuffer(Ver, SizeOf(Ver));
        if Ver <> CACHE_VERSION then Exit;

        S.ReadBuffer(SavedCount, SizeOf(SavedCount));
        for i := 0 to SavedCount - 1 do
          SavedNames.Add(LowerCase(ReadStr));
      finally
        S.Free;
      end;
    except
      Exit; // битый кэш
    end;

    // Разное количество → точно изменилось
    if SavedCount <> Length(XMLFiles) then Exit;

    // Проверяем что каждый текущий XML был в кэше
    for F in XMLFiles do
      if SavedNames.IndexOf(LowerCase(ExtractFileName(F))) < 0 then
        Exit;

  finally
    SavedNames.Free;
  end;

  Result := True;
end;

// Сохраняем FGameData (без IsInstalled) в бинарный файл
procedure TSGLMainFormHelper.SaveGameCache(const CacheFile: string;
  const XMLFiles: TStringDynArray);
var
  S: TFileStream;
  Count, i: Integer;
  FileCount: Integer;
  procedure WriteStr(const V: string);
  var B: TBytes; Len: Word;
  begin
    B := TEncoding.UTF8.GetBytes(V);
    Len := Length(B);
    S.WriteBuffer(Len, SizeOf(Len));
    if Len > 0 then S.WriteBuffer(B[0], Len);
  end;
begin
  try
    S := TFileStream.Create(CacheFile, fmCreate);
    try
      S.WriteBuffer(CACHE_VERSION, SizeOf(CACHE_VERSION));

      // Список XML-файлов (только имена, без пути)
      FileCount := Length(XMLFiles);
      S.WriteBuffer(FileCount, SizeOf(FileCount));
      for i := 0 to FileCount - 1 do
        WriteStr(ExtractFileName(XMLFiles[i]));

      // Данные игр
      Count := FActualGameCount;
      S.WriteBuffer(Count, SizeOf(Count));
      for i := 0 to Count - 1 do
      begin
        WriteStr(FGameData[i].GameName);
        WriteStr(FGameData[i].ApplicationPath);
        WriteStr(FGameData[i].Platforms);
        S.WriteBuffer(FGameData[i].ReleaseYear, SizeOf(SmallInt));
        WriteStr(FGameData[i].Developer);
        WriteStr(FGameData[i].Publisher);
        WriteStr(FGameData[i].Genre);
        WriteStr(FGameData[i].Series);
        WriteStr(FGameData[i].Notes);
        WriteStr(FGameData[i].Manual);
        WriteStr(FGameData[i].ConfigurationPath);
        WriteStr(FGameData[i].RootFolder);
        WriteStr(FGameData[i].ID);
        WriteStr(FGameData[i].CommandLine);
        WriteStr(FGameData[i].PlayMode);
        WriteStr(FGameData[i].Source);
      end;
    finally
      S.Free;
    end;
  except
    if FileExists(CacheFile) then
      TFile.Delete(CacheFile);
  end;
end;

// Загружаем FGameData из бинарного файла. Возвращает False если кэш повреждён
function TSGLMainFormHelper.LoadGameCache(const CacheFile: string): Boolean;
var
  S: TFileStream;
  Count, i: Integer;
  Ver: Word;
  SkipCount: Integer;
  function ReadStr: string;
  var B: TBytes; Len: Word;
  begin
    S.ReadBuffer(Len, SizeOf(Len));
    SetLength(B, Len);
    if Len > 0 then S.ReadBuffer(B[0], Len);
    Result := TEncoding.UTF8.GetString(B);
  end;
  procedure SkipStr;
  var B: TBytes; Len: Word;
  begin
    S.ReadBuffer(Len, SizeOf(Len));
    SetLength(B, Len);
    if Len > 0 then S.ReadBuffer(B[0], Len);
  end;
begin
  Result := False;
  try
    S := TFileStream.Create(CacheFile, fmOpenRead or fmShareDenyWrite);
    try
      S.ReadBuffer(Ver, SizeOf(Ver));
      if Ver <> CACHE_VERSION then Exit;

      // Пропускаем блок XML-имён
      S.ReadBuffer(SkipCount, SizeOf(SkipCount));
      for i := 0 to SkipCount - 1 do SkipStr;

      S.ReadBuffer(Count, SizeOf(Count));
      if Count <= 0 then Exit;

      FActualGameCount := 0;
      SetLength(FGameData, Count);

      for i := 0 to Count - 1 do
      begin
        FGameData[i].GameName          := ReadStr;
        FGameData[i].ApplicationPath   := ReadStr;
        FGameData[i].Platforms         := ReadStr;
        S.ReadBuffer(FGameData[i].ReleaseYear, SizeOf(SmallInt));
        FGameData[i].Developer         := ReadStr;
        FGameData[i].Publisher         := ReadStr;
        FGameData[i].Genre             := ReadStr;
        FGameData[i].Series            := ReadStr;
        FGameData[i].Notes             := ReadStr;
        FGameData[i].Manual            := ReadStr;
        FGameData[i].ConfigurationPath := ReadStr;
        FGameData[i].RootFolder        := ReadStr;
        FGameData[i].ID                := ReadStr;
        FGameData[i].CommandLine       := ReadStr;
        FGameData[i].PlayMode          := ReadStr;
        FGameData[i].Source            := ReadStr;
      end;
      FActualGameCount := Count;
      Result := True;
    finally
      S.Free;
    end;
  except
    Result := False;
    if FileExists(CacheFile) then
      TFile.Delete(CacheFile);
  end;
end;

// Для фильтра по платформам
//-----------------------------------------------------------------------------
procedure TSGLMainFormHelper.RefreshPlatformFilterMenu;
var
  i: Integer;
  SL: TStringList;
  MenuItem: TMenuItem;
  CheckItem: TMenuItem;
  CurrentTab: string;
  SelectedPlatforms: TStringList;
begin
  pmPlatformFilter.Items.Clear;

  CurrentTab := TabControl1.Tabs[TabControl1.TabIndex];

  // Разрешаем для All, Installed и Favorites
  if not (SameText(CurrentTab, 'All') or
          SameText(CurrentTab, 'Installed') or
          SameText(CurrentTab, 'Favorites')) then
    Exit;

  // Выбираем правильный список в зависимости от вкладки
  if SameText(CurrentTab, 'All') then
    SelectedPlatforms := FSelectedPlatformsAll
  else if SameText(CurrentTab, 'Installed') then
    SelectedPlatforms := FSelectedPlatformsInstalled
  else if SameText(CurrentTab, 'Favorites') then
    SelectedPlatforms := FSelectedPlatformsFavorites
  else
    Exit; // На вкладках платформ не показываем меню

  SL := TStringList.Create;
  try
    SL.Sorted := True;
    SL.Duplicates := dupIgnore;

    for i := 0 to High(FGameData) do
      if FGameData[i].Platforms <> '' then
        SL.Add(FGameData[i].Platforms);

    // Заголовок с названием вкладки
    MenuItem := TMenuItem.Create(pmPlatformFilter);
    MenuItem.Caption := 'Filter by Platform (' + CurrentTab + ')';
    MenuItem.Enabled := False;
    pmPlatformFilter.Items.Add(MenuItem);

    // Разделитель
    MenuItem := TMenuItem.Create(pmPlatformFilter);
    MenuItem.Caption := '-';
    pmPlatformFilter.Items.Add(MenuItem);

    // Чекбоксы
    for i := 0 to SL.Count - 1 do
    begin
      CheckItem := TMenuItem.Create(pmPlatformFilter);
      CheckItem.Caption := SL[i];
      CheckItem.Hint := SL[i];
      CheckItem.AutoCheck := False;
      CheckItem.Checked := SelectedPlatforms.IndexOf(SL[i]) >= 0;
      CheckItem.OnClick := PlatformFilterMenuClick;
      pmPlatformFilter.Items.Add(CheckItem);
    end;

    // Разделитель
    MenuItem := TMenuItem.Create(pmPlatformFilter);
    MenuItem.Caption := '-';
    pmPlatformFilter.Items.Add(MenuItem);

    // Кнопки внизу
    MenuItem := TMenuItem.Create(pmPlatformFilter);
    MenuItem.Caption := 'Load saved';
    MenuItem.Tag := 1;
    MenuItem.OnClick := PlatformFilterMenuClick;
    pmPlatformFilter.Items.Add(MenuItem);

    MenuItem := TMenuItem.Create(pmPlatformFilter);
    MenuItem.Caption := 'Clear All';
    MenuItem.Tag := 2;
    MenuItem.OnClick := PlatformFilterMenuClick;
    pmPlatformFilter.Items.Add(MenuItem);

  finally
    SL.Free;
  end;
end;

procedure TSGLMainFormHelper.PlatformFilterMenuClick(Sender: TObject);
var
  i: Integer;
  Item: TMenuItem;
  PlatformName: string;
  CurrentTab: string;
  SelectedPlatforms: TStringList;
  ActiveFlag: ^Boolean; // Указатель на флаг активности
begin
  Item := Sender as TMenuItem;
  CurrentTab := TabControl1.Tabs[TabControl1.TabIndex];

  // Выбираем правильный список в зависимости от вкладки
  if SameText(CurrentTab, 'All') then
  begin
    SelectedPlatforms := FSelectedPlatformsAll;
    ActiveFlag := @FPlatformFilterActiveAll;
  end
  else if SameText(CurrentTab, 'Installed') then
  begin
    SelectedPlatforms := FSelectedPlatformsInstalled;
    ActiveFlag := @FPlatformFilterActiveInstalled;
  end
  else if SameText(CurrentTab, 'Favorites') then
  begin
    SelectedPlatforms := FSelectedPlatformsFavorites;
    ActiveFlag := @FPlatformFilterActiveFavorites;
  end
  else
    Exit;

  if Item.Tag = 1 then // Load from INI
  begin
    LoadPlatformFilterSettings; // сама обновит FSelectedPlatformsAll/Installed и Active-флаги

    // Синхронизируем чекбоксы в меню с загруженными данными
    for i := 0 to pmPlatformFilter.Items.Count - 1 do
      if pmPlatformFilter.Items[i].Hint <> '' then
        pmPlatformFilter.Items[i].Checked :=
          SelectedPlatforms.IndexOf(pmPlatformFilter.Items[i].Hint) >= 0;
  end
  else if Item.Tag = 2 then // Clear All
  begin
    SelectedPlatforms.Clear;
    for i := 0 to pmPlatformFilter.Items.Count - 1 do
      if pmPlatformFilter.Items[i].Hint <> '' then
        pmPlatformFilter.Items[i].Checked := False;
    ActiveFlag^ := False;
  end
  else // обычный чекбокс
  begin
    PlatformName := Item.Hint;
    if PlatformName = '' then Exit;

    Item.Checked := not Item.Checked;

    if Item.Checked then
    begin
      if SelectedPlatforms.IndexOf(PlatformName) < 0 then
        SelectedPlatforms.Add(PlatformName);
    end
    else
      SelectedPlatforms.Delete(SelectedPlatforms.IndexOf(PlatformName));

    ActiveFlag^ := SelectedPlatforms.Count > 0;
  end;

  // Сохраняем настройки (кроме Clear All - чтобы можно было восстановить через Load from INI)
  if Item.Tag <> 2 then
  begin
   // Сохраняем настройки
   FConfig.WriteString('SGAllSettings', 'PlatformFilter_All', FSelectedPlatformsAll.CommaText);
   FConfig.WriteString('SGAllSettings', 'PlatformFilter_Installed', FSelectedPlatformsInstalled.CommaText);
   FConfig.WriteString('SGAllSettings', 'PlatformFilter_Favorites', FSelectedPlatformsFavorites.CommaText);
   FConfig.UpdateFile;
  end;

  // Применяем фильтр
  FillFilterValues();
  ApplyFilters;
  UpdateGenreSeriesComboForCurrentPlatform;
  AutoSizeListViewColumns;
end;

procedure TSGLMainFormHelper.LoadPlatformFilterSettings;
var
  PlatformsStr: string;
begin
  if not Assigned(FSelectedPlatformsAll) then Exit;

  // All
  PlatformsStr := FConfig.ReadString('SGAllSettings', 'PlatformFilter_All', '');
  if PlatformsStr <> '' then
  begin
    FSelectedPlatformsAll.CommaText := PlatformsStr;
    FPlatformFilterActiveAll := FSelectedPlatformsAll.Count > 0;
  end
  else
    FPlatformFilterActiveAll := False;

  // Installed
  PlatformsStr := FConfig.ReadString('SGAllSettings', 'PlatformFilter_Installed', '');
  if PlatformsStr <> '' then
  begin
    FSelectedPlatformsInstalled.CommaText := PlatformsStr;
    FPlatformFilterActiveInstalled := FSelectedPlatformsInstalled.Count > 0;
  end
  else
    FPlatformFilterActiveInstalled := False;

  // Favorites — ← НОВОЕ
  PlatformsStr := FConfig.ReadString('SGAllSettings', 'PlatformFilter_Favorites', '');
  if PlatformsStr <> '' then
  begin
    FSelectedPlatformsFavorites.CommaText := PlatformsStr;
    FPlatformFilterActiveFavorites := FSelectedPlatformsFavorites.Count > 0;
  end
  else
    FPlatformFilterActiveFavorites := False;
end;

// Избранные
//-----------------------------------------------------------------------------
function TSGLMainFormHelper.IsFavorite(const GameID: string): Boolean;
begin
  Result := (GameID <> '') and Assigned(FFavoriteIDs) and FFavoriteIDs.ContainsKey(GameID);
end;

procedure TSGLMainFormHelper.ToggleFavorite(const GameID: string);
var
  NewState: Boolean;
begin
  if GameID = '' then Exit;

  NewState := not IsFavorite(GameID);
  FConfig.WriteBool('Favorites', GameID, NewState);
  FConfig.UpdateFile;

  if Assigned(FFavoriteIDs) then
  begin
    if NewState then
      FFavoriteIDs.AddOrSetValue(GameID, True)
    else
      FFavoriteIDs.Remove(GameID);
  end;
end;

procedure TSGLMainFormHelper.UpdateFavoritesMenuItem;
var
  RealIndex: Integer;
begin
  if not Assigned(Favorites1) then Exit;
  if ListView1.ItemIndex < 0 then
  begin
    Favorites1.Visible := False;
    Exit;
  end;

  RealIndex := FFilteredIndices[ListView1.ItemIndex];

  if IsFavorite(FGameData[RealIndex].ID) then
    Favorites1.Caption := 'Remove from Favorites'
  else
    Favorites1.Caption := 'Add to Favorites';

  Favorites1.Visible := True;
end;

// Загружает набор ID избранных игр из FConfig в память (один раз при старте).
// Дальше IsFavorite/ToggleFavorite работают только с этим кэшем, без обращений к INI на чтение.
procedure TSGLMainFormHelper.LoadFavoritesFromConfig;
var
  Keys: TStringList;
  i: Integer;
begin
  if not Assigned(FFavoriteIDs) then Exit;
  FFavoriteIDs.Clear;

  Keys := TStringList.Create;
  try
    FConfig.ReadSection('Favorites', Keys);
    for i := 0 to Keys.Count - 1 do
      if FConfig.ReadBool('Favorites', Keys[i], False) then
        FFavoriteIDs.AddOrSetValue(Keys[i], True);
  finally
    Keys.Free;
  end;
end;

procedure TSGLMainFormHelper.RemoveFilteredIndexFromView(ItemIndex: Integer);
var
  i, NewCount: Integer;
  SelectedPlatform: string;
begin
  if (ItemIndex < 0) or (ItemIndex >= Length(FFilteredIndices)) then Exit;

  SendMessage(ListView1.Handle, WM_SETREDRAW, WPARAM(False), 0);
  try
    for i := ItemIndex to High(FFilteredIndices) - 1 do
      FFilteredIndices[i] := FFilteredIndices[i + 1];

    NewCount := Length(FFilteredIndices) - 1;
    SetLength(FFilteredIndices, NewCount);
    ListView1.Items.Count := NewCount;

    if NewCount > 0 then
    begin
      if ItemIndex >= NewCount then
        ItemIndex := NewCount - 1;
      ListView1.ItemIndex := ItemIndex;
      ListView1.Selected := ListView1.Items[ItemIndex];
      ShowGameByIndex(ItemIndex);
    end
    else
      ClearGameInfo;

    if TabControl1.TabIndex >= 0 then
      SelectedPlatform := TabControl1.Tabs[TabControl1.TabIndex]
    else
      SelectedPlatform := '';

    Caption := Format('%s %d', [SelectedPlatform + ' - ', NewCount]);
    if Length(FGameData) <> NewCount then
      Caption := Caption + Format(' / %d', [Length(FGameData)]);
    TrayIcon.Hint := Caption;
  finally
    SendMessage(ListView1.Handle, WM_SETREDRAW, WPARAM(True), 0);
    ListView1.Invalidate;
  end;
end;

// Загрузка торрентов
//------------------------------------------------------------------------------
//  Функция чтобы узнать первая папка в строке (для загрузки через aria)
function TSGLMainFormHelper.IsExoFirstFolder(const Path: string): Boolean;
var
  P: Integer;
begin
  P := Pos('\', Path);
  if P > 0 then
    Result := SameText(Copy(Path, 1, P - 1), 'eXo')
  else
    Result := SameText(Path, 'eXo');
end;

function TSGLMainFormHelper.GetExoFolderName(const FullPath: string; const Del: Char): string;
var
  PathParts: TStringList;
  i: Integer;
  Found: Boolean;
begin
  Result := '';
  PathParts := TStringList.Create;
  try
    PathParts.Delimiter := Del;
    PathParts.StrictDelimiter := True;
    PathParts.DelimitedText := FullPath;
    Found := False;
    for i := 0 to PathParts.Count - 1 do
    begin
      if SameText(PathParts[i], 'eXo') then
      begin
        Found := True;
        Continue; // пропускаем саму папку 'eXo'
      end;
      if Found then
      begin
        if Result = '' then
          Result := PathParts[i]
        else
          Result := Result + Del + PathParts[i];
      end;
    end;
  finally
    PathParts.Free;
  end;
end;

function TSGLMainFormHelper.GetExoFolderNamewithYear(const FullPath: string; const Del: Char; const Year: string): string;
var
  BasePath: string;
  FirstPart: string;
  DelPos: Integer;
begin
  BasePath := GetExoFolderName(FullPath, Del);
  if BasePath = '' then
    Exit('');

  // Извлекаем первую часть (первую папку после 'eXo')
  DelPos := Pos(Del, BasePath);
  if DelPos > 0 then
    FirstPart := Copy(BasePath, 1, DelPos - 1)
  else
    FirstPart := BasePath;

  if SameText(FirstPart, 'eXoWin9x') then
  begin
    // Для eXoWin9x вставляем год сразу после FirstPart,
    // остаток пути (если есть) переносим за годом.
    if DelPos > 0 then
      Result := FirstPart + Del + Year + Del + Copy(BasePath, DelPos + 1, MaxInt)
    else
      Result := FirstPart + Del + Year;
  end
  else
    Result := BasePath; // Для остальных платформ возвращаем полный путь после eXo
end;

procedure TSGLMainFormHelper.Aria2Download(Language: String);
var
  AppPath, CmdLine, FullPath, ExoFolder, YearStr: string;
  Game: TGameData;
  TorrentFile, SaveDir, FinalDir, FileInTorrent, ZIPFile, isWin9x, isWin9xTorrent: string;
  TorrentIdent, TorrentLine: string;
  TorrentParts: TStringList;
begin
  if ListView1.ItemIndex = -1 then Exit;

  // 1. Данные выбранной игры — берём поля из уже полученной записи, без повторного индексирования
  Game := FGameData[FFilteredIndices[ListView1.ItemIndex]];
  AppPath := Game.ApplicationPath;
  CmdLine := Game.CommandLine;
  FullPath := TPath.Combine(LaunchBoxDir, AppPath);

  // 2. Папка eXo и год вычисляются один раз и переиспользуются
  ExoFolder := GetExoFolderName(FullPath, '\');
  YearStr := IntToStr(Game.ReleaseYear);

  ZIPFile := GetExecPath + IncludeTrailingPathDelimiter('eXo') +
               IncludeTrailingPathDelimiter(ExoFolder) +
               ChangeFileExt(ExtractFileName(FullPath), '') + '.zip';

  TorrentParts := TStringList.Create;
  try
    TorrentParts.Delimiter := '|';
    TorrentParts.StrictDelimiter := True;
    TorrentParts.DelimitedText := FTorrentConfig.ReadString(Game.Platforms, Language, '');

    if TorrentParts.Count > 0 then
      TorrentFile := GetExecPath + 'SGLauncher\torrents\' + TorrentParts[0];

    // Третья часть (SaveDir) — конечная папка установки игры
    if TorrentParts.Count > 2 then
     begin
      isWin9x := GetExoFolderNamewithYear(TorrentParts[2], '\', YearStr);
      isWin9xTorrent := isWin9x;
      FinalDir := GetExecPath + IncludeTrailingPathDelimiter('eXo') + StringReplace(IncludeTrailingPathDelimiter(isWin9x), '/', '\', [rfReplaceAll]);
      FileInTorrent := 'eXo/' + StringReplace(isWin9xTorrent,'\', '/', [rfReplaceAll]) + '/' + ChangeFileExt(ExtractFileName(FullPath), '') + '.zip';
     end;

  finally
    TorrentParts.Free;
  end;

  // 4. Качаем торрентом вместо запуска
  SaveDir := GetExecPath + IncludeTrailingPathDelimiter('SGLauncher\temp') + ChangeFileExt(ExtractFileName(FullPath), '');
  TAria2Thread.Create(TorrentFile, SaveDir, FinalDir, FileInTorrent, Game.RootFolder, '');
end;

// Возвращает полный путь к ZIP‑архиву для указанной игры и языка
function TSGLMainFormHelper.GetZipPathForLanguage(const G: TGameData; const Language: string): string;
var
  TorrentParts: TStringList;
  PathInTorrent, YearStr, isWin9x: string;
begin
  Result := '';
  TorrentParts := TStringList.Create;
  try
    TorrentParts.Delimiter := '|';
    TorrentParts.StrictDelimiter := True;
    TorrentParts.DelimitedText := SGLMainForm.FTorrentConfig.ReadString(G.Platforms, Language, '');
    if TorrentParts.Count < 3 then Exit;

    PathInTorrent := TorrentParts[2];
    YearStr := IntToStr(G.ReleaseYear);
    isWin9x := GetExoFolderNamewithYear(PathInTorrent, '\', YearStr);
    Result := GetExecPath + 'eXo\' +
              StringReplace(isWin9x, '/', '\', [rfReplaceAll]) + '\' +
              ChangeFileExt(ExtractFileName(G.ApplicationPath), '') + '.zip';
  finally
    TorrentParts.Free;
  end;
end;

function TSGLMainFormHelper.TorrentFileExists(const G: TGameData; const Language: string): Boolean;
var
  Line: string;
  TorrentParts: TStringList;
  TorrentPath: string;
begin
  Result := False;
  Line := FTorrentConfig.ReadString(G.Platforms, Language, '');
  if Line = '' then Exit;
  TorrentParts := TStringList.Create;
  try
    TorrentParts.Delimiter := '|';
    TorrentParts.StrictDelimiter := True;
    TorrentParts.DelimitedText := Line;
    if TorrentParts.Count = 0 then Exit;
    TorrentPath := GetExecPath + 'SGLauncher\torrents\' + TorrentParts[0];
    Result := FileExists(TorrentPath);
  finally
  TorrentParts.Free;
  end;
end;

function TSGLMainFormHelper.IsGameFolderExists(const G: TGameData; const Language: string): Boolean;
var
  Line, ReadPath, GameName: string;
  TorrentParts: TStringList;
begin
  Result := False;
  if (G.Platforms = '') or (Language = '') then Exit;

  Line := FTorrentConfig.ReadString(G.Platforms, Language, '');
  if Line = '' then Exit;

  TorrentParts := TStringList.Create;
  try
    TorrentParts.Delimiter := '|';
    TorrentParts.StrictDelimiter := True;
    TorrentParts.DelimitedText := Line;
    if TorrentParts.Count < 2 then Exit; // нужны как минимум два поля

    ReadPath := TorrentParts[1]; // read game location (второе поле)

    // Имя игры (папка) без расширения
    GameName := ExtractFileName(ExcludeTrailingPathDelimiter(ExtractFilePath(G.ApplicationPath)))+'\'+ExtractFileName(G.ApplicationPath);
    if GameName = '' then Exit;

    // Полный путь к папке игры
    var FullPath := GetExecPath + ReadPath + '\' + GameName;
            //DirectoryExists(FullPath) -> without "+'\'+ExtractFileName(G.ApplicationPath)"
    Result := FileExists(FullPath);
  finally
    TorrentParts.Free;
  end;
end;

end.
