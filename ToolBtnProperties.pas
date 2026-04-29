unit ToolBtnProperties;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Menus, Vcl.Mask, ShellAPI;

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
  end;

var
  ToolBtnPropertiesForm: TToolBtnPropertiesForm;

implementation

uses Unit1, ToolBars;

{$R *.dfm}

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
    LNKPROP_EDIT4.Text := '';
    LNKPROP_EDIT5.Text := '';
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
