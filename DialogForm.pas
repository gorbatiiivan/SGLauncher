unit DialogForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.IOUtils;

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

uses ToolBtnProperties;

function GetLastFolderName(const Path: string): string;
begin
  Result := TPath.GetFileName(ExcludeTrailingPathDelimiter(Path));
end;

function ExtractBaseTitle(const FileName: string): string;
var
  S: string;
  DashPos: Integer;
  NumPart: string;
  N: Integer;
begin
  // 1. Берём только имя файла
  S := ExtractFileName(FileName);

  // 2. Убираем расширение
  S := ChangeFileExt(S, '');

  // 3. Последний дефис
  DashPos := LastDelimiter('-', S);

  if DashPos > 0 then
  begin
    NumPart := Copy(S, DashPos + 1, MaxInt);

    // 4. Если после дефиса ТОЛЬКО число — удаляем
    if TryStrToInt(NumPart, N) then
      Delete(S, DashPos, MaxInt);
  end;

  Result := S;
end;

procedure TDiagForm.Button3Click(Sender: TObject);
var
  sFile: String;
begin
if ifFile = True then
 begin
  if ToolBtnPropertiesForm.OpenDialogEx('Select an image', True, sFile, DialogDir) then
    Edit1.Text := ExtractBaseTitle(sFile);
 end else
 begin
  if ToolBtnPropertiesForm.OpenDialogEx('Select a dir', False, sFile, DialogDir) then
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
