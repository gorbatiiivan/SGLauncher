unit ToolBtnProperties;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Menus, ShellAPI, Vcl.Mask;

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
    procedure ToolBarMenuClick(Sender: TObject);
  end;

var
  ToolBtnPropertiesForm: TToolBtnPropertiesForm;

implementation

uses Unit1, SystemUtils, ToolBars;

{$R *.dfm}

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
        StrToList(Button.Caption, '|', TempList);

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
 else DiagDir := ExtractFilePath(LNKPROP_EDIT2.Text);

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
 else DiagDir := ExtractFilePath(LNKPROP_EDIT2.Text);

 if OpenDialogEx('Select file', True, sFile, DiagDir) then
  begin
    LNKPROP_EDIT5.Text := sFile;
    Index := 0;
    Image1.Picture.Icon.Handle := ExtractAssociatedIcon(hInstance,PChar(sFile),Index);
  end;
end;

end.
