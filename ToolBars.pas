unit ToolBars;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls,
     Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.Menus, ShellAPI, CommCtrl, IniFiles;

// GENERAL FUNCTIONS
// ---------------------------------------------------------------------------
function OpenDialogEx(const Title: string; const IsFile: Boolean;
                    var sPath: string; const DefaultDir: string = ''): Boolean;
function GetImageListSH(SHIL_FLAG:Cardinal): HIMAGELIST;
procedure GetIconFromFile( aFile: string; var aIcon: TIcon;SHIL_FLAG: Cardinal );
procedure AddIconsToList(IconPath: String; ImageList: TImageList; CurrentIconSize: Integer);
// BUTTONS FUNCTIONS
// ---------------------------------------------------------------------------
procedure AddButtonToToolbar(OnClick: TNotifyEvent; var bar: TToolBar; hint: string;
  caption: string; imageindex: Integer; addafteridx: integer = -1);
function ButtonExists(ToolBar: TToolBar; Hint: string): Boolean;
procedure LoadToolButtons(ToolBar: TToolBar; Config: TMemIniFile; ImageList: TImageList; OnButtonClick: TNotifyEvent);
procedure AddToolButton(ToolBar: TToolBar; Hint, Caption: string; Config: TMemIniFile;
   ImageList: TImageList; OnButtonClick: TNotifyEvent);
procedure RefreshToolBarPopup(ToolBar: TToolBar);
procedure DeleteToolButton(ToolBar: TToolBar; Hint: string;
  Config: TMemIniFile; ImageList: TImageList; OnButtonClick: TNotifyEvent);
procedure AddItemToButtonPopup(ToolBar: TToolBar; Config: TMemIniFile; Form: TForm;
  OnButtonClick: TNotifyEvent);
// ---------------------------------------------------------------------------

implementation

uses Unit1, ToolBtnProperties, SystemUtils;
                             // GENERAL FUNCTIONS
// ---------------------------------------------------------------------------

function OpenDialogEx(const Title: string; const IsFile: Boolean;
                    var sPath: string; const DefaultDir: string = ''): Boolean;
var
  Dlg: TFileOpenDialog;
begin
  Result := False;
  Dlg := TFileOpenDialog.Create(nil);
  try
    Dlg.Title := Title;

    if IsFile then
      Dlg.Options := [fdoPathMustExist, fdoFileMustExist, fdoForceFileSystem]
    else
      Dlg.Options := [fdoPickFolders, fdoPathMustExist, fdoForceFileSystem];

    if DefaultDir <> '' then
      Dlg.DefaultFolder := DefaultDir;

    if Dlg.Execute then
    begin
      sPath := Dlg.FileName;
      Result := True;
    end;

  finally
    Dlg.Free;
  end;
end;

function GetImageListSH(SHIL_FLAG:Cardinal): HIMAGELIST;
const
 IID_IImageList: TGUID = '{46EB5926-582E-4017-9FDF-E8998DAA0950}';
type
  _SHGetImageList = function (iImageList: integer; const riid: TGUID; var ppv: Pointer): hResult; stdcall;
var
  Handle: THandle;
  SHGetImageList: _SHGetImageList;
begin
  Result:= 0;
  Handle:= LoadLibrary('Shell32.dll');
  if Handle <> 0 then
  try
    SHGetImageList:=GetProcAddress(Handle, PChar(727));
    if Assigned(SHGetImageList) and (Win32Platform=VER_PLATFORM_WIN32_NT) then
      SHGetImageList(SHIL_FLAG, IID_IImageList, Pointer(Result));
  finally
    FreeLibrary(Handle);
  end;
end;

procedure GetIconFromFile( aFile: string; var aIcon: TIcon;SHIL_FLAG: Cardinal );
var
  aImgList: HIMAGELIST;
  SFI: TSHFileInfo;
  aIndex: integer;
begin
  FillChar(SFI, SizeOf(SFI), 0); // Инициализация структуры

  SHGetFileInfo( PChar( aFile ), FILE_ATTRIBUTE_NORMAL, SFI, SizeOf( TSHFileInfo ),
    SHGFI_ICON or SHGFI_LARGEICON or SHGFI_SHELLICONSIZE or SHGFI_SYSICONINDEX or SHGFI_TYPENAME or SHGFI_DISPLAYNAME );

  if not Assigned( aIcon ) then
    aIcon := TIcon.Create;
  // get the imagelist
  aImgList := GetImageListSH( SHIL_FLAG );
  // get index
  //aIndex := Pred( ImageList_GetImageCount( aImgList ) );
  aIndex := SFI.iIcon;
  // extract the icon handle
  aIcon.Handle := ImageList_GetIcon( aImgList, aIndex, ILD_NORMAL );
end;

procedure AddIconsToList(IconPath: String; ImageList: TImageList; CurrentIconSize: Integer);
var
 hicon: TIcon;
begin
 if not FileExists(IconPath) and (ExtractFileExt(IconPath) <> '') then
    Exit;

 hicon:= TIcon.Create;
  try
   if SameText(ExtractFileExt(IconPath), '.ICO') then
      hIcon.LoadFromFile(IconPath)
    else
      GetIconFromFile(IconPath, hIcon, CurrentIconSize);

   ImageList.AddIcon(hicon);
  finally
   hicon.Free;
  end;
end;

                             // BUTTONS FUNCTIONS
// ---------------------------------------------------------------------------
procedure AddButtonToToolbar(OnClick: TNotifyEvent; var bar: TToolBar; hint: string;
  caption: string; imageindex: Integer; addafteridx: integer = -1);
var
  newbtn: TToolButton;
  prevBtnIdx: integer;
begin
  newbtn := TToolButton.Create(bar);
  newbtn.Caption := caption;
  newbtn.Hint := hint;
  newbtn.ImageIndex := imageindex;
  newbtn.OnClick := OnClick;

  //if they asked us to add it after a specific location, then do so
  //otherwise, just add it to the end (after the last existing button)
  if addafteridx = -1 then begin
    prevBtnIdx := bar.ButtonCount - 1;
  end
  else begin
    if bar.ButtonCount <= addafteridx then begin
      //if the index they want to be *after* does not exist,
      //just add to the end
      prevBtnIdx := bar.ButtonCount - 1;
    end
    else begin
      prevBtnIdx := addafteridx;
    end;
  end;

  if prevBtnIdx > -1 then
    newbtn.Left := bar.Buttons[prevBtnIdx].Left + bar.Buttons[prevBtnIdx].Width
  else
    newbtn.Left := 0;

  newbtn.Parent := bar;
end;

function ButtonExists(ToolBar: TToolBar; Hint: string): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to ToolBar.ButtonCount - 1 do
  begin
    if SameText(ToolBar.Buttons[i].Hint, Hint) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

procedure LoadToolButtons(ToolBar: TToolBar; Config: TMemIniFile; ImageList: TImageList; OnButtonClick: TNotifyEvent);

 procedure ClearToolbarButtons(Toolbar: TToolBar; ImageList: TImageList);
 var
  i: Integer;
  SavedPopup: TPopupMenu;
 begin
  // СОХРАНЯЕМ PopupMenu перед удалением кнопок
  SavedPopup := nil;
  if (Toolbar.ButtonCount > 0) and (Toolbar.Buttons[0].PopupMenu <> nil) then
    SavedPopup := Toolbar.Buttons[0].PopupMenu;

  // Удаляем кнопки, но НЕ удаляем PopupMenu
  for i := Toolbar.ButtonCount - 1 downto 0 do
  begin
    Toolbar.Buttons[i].PopupMenu := nil; // ← отвязываем меню перед удалением кнопки
    Toolbar.Buttons[i].Free;
  end;

  ImageList.Clear;

  // ВОССТАНАВЛИВАЕМ PopupMenu для тулбара
  if SavedPopup <> nil then
    Toolbar.PopupMenu := SavedPopup;
 end;

var
  ButtonList: TStringList;
  NewButton: TToolButton;
  i: Integer;
  TempList: TStringList;
  SharedPopup: TPopupMenu;
begin
  // ← СОХРАНЯЕМ ссылку на существующий PopupMenu
  SharedPopup := ToolBar.PopupMenu;

  ClearToolbarButtons(ToolBar, ImageList);

  ButtonList := TStringList.Create;
  TempList   := TStringList.Create;
  try
    Config.ReadSectionValues('Toolbar', ButtonList);

    ButtonList.Sort;
    for i := 0 to ButtonList.Count div 2 - 1 do
      ButtonList.Exchange(i, ButtonList.Count - 1 - i);
    ButtonList.Duplicates := dupIgnore;

    for i := 0 to ButtonList.Count - 1 do
     begin
      if not ButtonExists(ToolBar, ButtonList.Names[i]) then
       begin
        NewButton := TToolButton.Create(ToolBar);
        NewButton.Parent    := ToolBar;
        NewButton.Hint      := ButtonList.Names[i];
        NewButton.Caption   := ButtonList.ValueFromIndex[i];
        NewButton.ShowHint  := True;
        NewButton.OnClick   := OnButtonClick;

       if Assigned(SharedPopup) then
        NewButton.PopupMenu := SharedPopup;

       TempList.Clear;
       StrToList(ButtonList.ValueFromIndex[i], '|', TempList);

       // проверка индексов
       if TempList.Count >= 1 then // Есть хотя бы путь к файлу
        begin
         if (TempList.Count >= 4) and (TempList[3] <> '') then
          AddIconsToList(TempList[3], ImageList, SHIL_LARGE)
         else
          AddIconsToList(TempList[0], ImageList, SHIL_LARGE);

         NewButton.ImageIndex := ImageList.Count - 1;
        end;
       end;
     end;
  finally
    ButtonList.Free;
    TempList.Free;
  end;

  //Не показывать если нет ни одной кнопки
  //ToolBar.Visible := (ToolBar.ButtonCount > 0);
end;

procedure AddToolButton(ToolBar: TToolBar; Hint, Caption: string; Config: TMemIniFile;
   ImageList: TImageList; OnButtonClick: TNotifyEvent);
begin
 Config.WriteString('Toolbar', Hint, Caption);
 Config.UpdateFile;

 LoadToolButtons(ToolBar, Config, ImageList, OnButtonClick);
end;

procedure RefreshToolBarPopup(ToolBar: TToolBar);
// Нужно чтобы после DeleteToolButton работало меню
var
  i: Integer;
  SharedPopup: TPopupMenu;
begin
  // Находим PopupMenu (берём с первой кнопки или с самого тулбара)
  SharedPopup := nil;
  if ToolBar.PopupMenu <> nil then
    SharedPopup := ToolBar.PopupMenu
  else if (ToolBar.ButtonCount > 0) and (ToolBar.Buttons[0].PopupMenu <> nil) then
    SharedPopup := ToolBar.Buttons[0].PopupMenu;

  if SharedPopup = nil then
    Exit;

  // Привязываем ко всем кнопкам + к самому тулбару
  for i := 0 to ToolBar.ButtonCount - 1 do
    ToolBar.Buttons[i].PopupMenu := SharedPopup;

  ToolBar.PopupMenu := SharedPopup;
end;

procedure DeleteToolButton(ToolBar: TToolBar; Hint: string;
  Config: TMemIniFile; ImageList: TImageList; OnButtonClick: TNotifyEvent);
var
  i: Integer;
  btn: TToolButton;
begin
  btn := nil;
  for i := 0 to ToolBar.ButtonCount - 1 do
  begin
    if SameText(ToolBar.Buttons[i].Hint, Hint) then
    begin
      btn := ToolBar.Buttons[i];
      Break;
    end;
  end;

  if btn = nil then Exit;

  btn.PopupMenu := nil;
  btn.OnClick   := nil;
  btn.Parent    := nil;
  btn.Free;

  Config.DeleteKey('Toolbar', Hint);
  Config.UpdateFile;

  // ← Обновляем PopupMenu на оставшихся кнопках
  RefreshToolBarPopup(ToolBar);
end;

procedure AddItemToButtonPopup(ToolBar: TToolBar; Config: TMemIniFile; Form: TForm;
  OnButtonClick: TNotifyEvent);
var
  NewMenuItem: TMenuItem;
  Popup: TPopupMenu;
  i: Integer;
begin
  // Если у первой кнопки уже есть PopupMenu — используем его
  if (ToolBar.ButtonCount > 0) and (ToolBar.Buttons[0].PopupMenu <> nil) then
  begin
    Popup := ToolBar.Buttons[0].PopupMenu;
    Popup.Items.Clear;               // очищаем старые пункты
  end
  else
  begin
    Popup := TPopupMenu.Create(Form);
    Popup.Name := 'pmToolBarButtons'; // желательно дать имя для отладки
  end;

  // ────────────── Пункт «Добавить» ──────────────
  NewMenuItem := TMenuItem.Create(Popup);
  NewMenuItem.Caption := 'Add...';
  NewMenuItem.Name     := 'miAddButton';
  NewMenuItem.ImageIndex := 0;               // можно позже назначить иконку
  NewMenuItem.OnClick  := OnButtonClick;     // тот же обработчик (потом разделим)
  Popup.Items.Add(NewMenuItem);

  // ────────────── Пункт «Удалить» ──────────────
  NewMenuItem := TMenuItem.Create(Popup);
  NewMenuItem.Caption := 'Delete';
  NewMenuItem.Name     := 'miDelete';
  NewMenuItem.ImageIndex := 2;               // например, крестик / мусорка
  NewMenuItem.OnClick  := OnButtonClick;
  Popup.Items.Add(NewMenuItem);

  // Разделитель (опционально)
  NewMenuItem := TMenuItem.Create(Popup);
  NewMenuItem.Caption := '-';
  Popup.Items.Add(NewMenuItem);

  // ────────────── Пункт «Свойства» ──────────────
  NewMenuItem := TMenuItem.Create(Popup);
  NewMenuItem.Caption := 'Properties...';
  NewMenuItem.Name     := 'miProperties';
  NewMenuItem.ImageIndex := 1;               // например, иконка шестерёнки
  NewMenuItem.OnClick  := OnButtonClick;
  Popup.Items.Add(NewMenuItem);

  // Привязываем одно и то же меню ко всем кнопкам
  for i := 0 to ToolBar.ButtonCount - 1 do
    ToolBar.Buttons[i].PopupMenu := Popup;

  // ← Важно! Привязываем меню также к самому ToolBar
  //   (чтобы можно было кликнуть правой кнопкой по пустому месту тулбара)
  ToolBar.PopupMenu := Popup;
end;

end.
