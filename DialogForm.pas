unit DialogForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TDiagForm = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Label2: TLabel;
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    DialogDir: String;
    ifFile: Boolean;
  end;

var
  DiagForm: TDiagForm;

implementation

{$R *.dfm}

uses ToolBars, SystemUtils;

procedure TDiagForm.Button3Click(Sender: TObject);
var
  sFile: String;
begin
if ifFile = True then
 begin
  if OpenDialogEx('Select an image', True, sFile, DialogDir) then
    Edit1.Text := ExtractBaseTitle(sFile);
 end else
 begin
  if OpenDialogEx('Select a dir', False, sFile, DialogDir) then
   if Edit1.Text = '' then
    begin //if Edit3 is empty
     Edit1.Text := GetLastFolderName(sFile);
    end else
    begin
     //if Exists symbol ';' then not create
     if Edit1.Text[Length(Edit1.Text)] = ';' then
       Edit1.Text := Edit1.Text + GetLastFolderName(sFile)
     else
       Edit1.Text := Edit1.Text + ';' + GetLastFolderName(sFile);
    end;
 end;
end;

end.
