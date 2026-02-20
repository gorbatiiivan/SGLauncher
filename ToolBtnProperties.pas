unit ToolBtnProperties;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Menus, Vcl.Mask, ShellAPI, CommCtrl, IniFiles,
  System.Generics.Collections, System.Generics.Defaults;

type
  TToolBtnPropertiesForm = class(TForm)
    GroupBox1: TGroupBox;
    Image1: TImage;
    LNKPROP_EDIT2: TLabeledEdit;
    LNKPROP_EDIT1: TLabeledEdit;
    LNKPROP_EDIT3: TLabeledEdit;
    LNKPROP_BTN2: TButton;
    LNKPROP_BTN3: TButton;
    LNKPROP_BTN1: TButton;
    LNKPROP_EDIT4: TLabeledEdit;
    LNKPROP_EDIT5: TLabeledEdit;
    LNKPROP_BTN4: TButton;
    LNKPROP_BTN5: TButton;
    procedure LNKPROP_BTN1Click(Sender: TObject);
    procedure LNKPROP_BTN4Click(Sender: TObject);
    procedure LNKPROP_BTN5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function OpenDialogEx(const Title: string; const IsFile: Boolean;
                    var sPath: string; const DefaultDir: string = ''): Boolean;
    procedure ToolBarMenuClick(Sender: TObject);
    procedure LoadToolButtons(ToolBar: TToolBar; Config: TMemIniFile; ImageList: TImageList;
       OnButtonClick: TNotifyEvent);
    procedure AddItemToButtonPopup(ToolBar: TToolBar; Config: TMemIniFile; Form: TForm;
       OnButtonClick: TNotifyEvent);
  end;

var
  ToolBtnPropertiesForm: TToolBtnPropertiesForm;

implementation

uses Unit1;

{$R *.dfm}

function TToolBtnPropertiesForm.OpenDialogEx(const Title: string; const IsFile: Boolean;
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

procedure TToolBtnPropertiesForm.LoadToolButtons(ToolBar: TToolBar; Config: TMemIniFile; ImageList: TImageList;
   OnButtonClick: TNotifyEvent);

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
       SGLMainForm.StrToList(ButtonList.ValueFromIndex[i], '|', TempList);

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

 ToolBtnPropertiesForm.LoadToolButtons(ToolBar, Config, ImageList, OnButtonClick);
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

procedure TToolBtnPropertiesForm.AddItemToButtonPopup(ToolBar: TToolBar; Config: TMemIniFile; Form: TForm;
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

procedure TToolBtnPropertiesForm.ToolBarMenuClick(Sender: TObject);
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
      DeleteToolButton(SGLMainForm.ToolBar1, Button.Hint, SGLMainForm.FConfig, SGLMainForm.ImageList1, SGLMainForm.ToolBar1Click);
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
            SGLMainForm.FConfig.WriteString('Toolbar', LNKPROP_EDIT1.EditText,
              LNKPROP_EDIT2.EditText + '|' + LNKPROP_EDIT3.EditText + '|' +
              LNKPROP_EDIT4.EditText + '|' +LNKPROP_EDIT5.EditText);
            SGLMainForm.FConfig.UpdateFile;

            // ← ПЕРЕЗАГРУЖАЕМ кнопки
            SGLMainForm.ToolBar1.AutoSize := False;
            LoadToolButtons(SGLMainForm.ToolBar1, SGLMainForm.FConfig, SGLMainForm.ImageList1, SGLMainForm.ToolBar1Click);
            SGLMainForm.ToolBar1.AutoSize := True;
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
        SGLMainForm.StrToList(Button.Caption, '|', TempList);

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
              SGLMainForm.FConfig.DeleteKey('Toolbar', OldHint);

            // ← СОХРАНЯЕМ новую запись
            SGLMainForm.FConfig.WriteString('Toolbar', LNKPROP_EDIT1.EditText,
              LNKPROP_EDIT2.EditText + '|' +
              LNKPROP_EDIT3.EditText + '|' +
              LNKPROP_EDIT4.EditText + '|' +
              LNKPROP_EDIT5.EditText);
            SGLMainForm.FConfig.UpdateFile;

            // ← ПЕРЕЗАГРУЖАЕМ кнопки
            SGLMainForm.ToolBar1.AutoSize := False;
            LoadToolButtons(SGLMainForm.ToolBar1, SGLMainForm.FConfig, SGLMainForm.ImageList1, SGLMainForm.ToolBar1Click);
            SGLMainForm.ToolBar1.AutoSize := True;
          end;
        end;
      finally
        TempList.Free;
      end;
    end;
  end;
end;

procedure TToolBtnPropertiesForm.LNKPROP_BTN4Click(Sender: TObject);
var
 sFile, DiagDir: String;
 Index: WORD;
begin
 if LNKPROP_EDIT2.Text <> '' then
  DiagDir := ExtractFilePath(LNKPROP_EDIT2.Text)
 else DiagDir := '';

 if OpenDialogEx('Select the executable file', True, sFile, DiagDir) then
  begin
    LNKPROP_EDIT1.Text := ExtractFileName(ChangeFileExt(sFile,''));
    LNKPROP_EDIT2.Text := sFile;
    LNKPROP_EDIT3.Text := '';
    LNKPROP_EDIT4.Text := ExtractFileDir(sFile);
    LNKPROP_EDIT5.Text := sFile;
    Index := 0;
    Image1.Picture.Icon.Handle := ExtractAssociatedIcon(hInstance,PChar(sFile),Index);
  end;
end;

procedure TToolBtnPropertiesForm.LNKPROP_BTN5Click(Sender: TObject);
var
 sFile, DiagDir: String;
begin
 if LNKPROP_EDIT4.Text <> '' then
  DiagDir := ExtractFilePath(LNKPROP_EDIT4.Text)
 else DiagDir := '';

 if OpenDialogEx('Select dir', False, sFile, DiagDir) then
  begin
    LNKPROP_EDIT4.Text := sFile;
  end;
end;

procedure TToolBtnPropertiesForm.LNKPROP_BTN1Click(Sender: TObject);
var
 sFile, DiagDir: String;
 Index: WORD;
begin
 if LNKPROP_EDIT5.Text <> '' then
  DiagDir := ExtractFilePath(LNKPROP_EDIT5.Text)
 else DiagDir := '';

 if OpenDialogEx('Select file', True, sFile, DiagDir) then
  begin
    LNKPROP_EDIT5.Text := sFile;
    Index := 0;
    Image1.Picture.Icon.Handle := ExtractAssociatedIcon(hInstance,PChar(sFile),Index);
  end;
end;

end.
