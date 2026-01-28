unit DialogForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, ActiveX,
  ShlObj, System.IOUtils;

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

function OpenFileDialog(Title,FileName,OKName: LPCWSTR; const isFile: Boolean; var sFileName: string; const sDefaultDir: String = ''): Boolean;
var
  FileDialog: IFileDialog;
  Item: IShellItem;
  SelectedPath: PWideChar;
  Options: DWORD;
  DefaultFolder: IShellItem;
begin
  Result := False; // Initialize the result
  CoInitialize(nil); // Initialize COM
  try
    // Create the dialog instance
    if Succeeded(CoCreateInstance(CLSID_FileOpenDialog, nil, CLSCTX_INPROC_SERVER, IFileDialog, FileDialog)) then
    begin
      // Set the default folder
      if sDefaultDir <> '' then
       begin
       if Succeeded(SHCreateItemFromParsingName(PChar(sDefaultDir), nil, IShellItem, DefaultFolder)) then
        FileDialog.SetFolder(DefaultFolder);
       end else
       begin
       if Succeeded(SHCreateItemFromParsingName('::{20D04FE0-3AEA-1069-A2D8-08002B30309D}', nil, IShellItem, DefaultFolder)) then
        FileDialog.SetFolder(DefaultFolder);
       end;

      // Set the dialogs captions
      FileDialog.SetTitle(Title);
      FileDialog.SetFileNameLabel(FileName);
      FileDialog.SetOkButtonLabel(OKName);

      // Set dialog options
      if isFile then
        Options := FOS_FORCEFILESYSTEM or FOS_PATHMUSTEXIST or FOS_FORCESHOWHIDDEN
      else
        Options := FOS_PICKFOLDERS or FOS_FORCEFILESYSTEM or FOS_PATHMUSTEXIST or FOS_FORCESHOWHIDDEN;

      FileDialog.SetOptions(Options);

      // Show the dialog
      if Succeeded(FileDialog.Show(0)) then
      begin
        // Get the selected item
        if Succeeded(FileDialog.GetResult(Item)) then
        begin
          if Succeeded(Item.GetDisplayName(SIGDN_FILESYSPATH, SelectedPath)) then
          begin
            try
              sFileName := SelectedPath; // Set the selected path
              Result := True; // Indicate success
            finally
              CoTaskMemFree(SelectedPath); // Free the allocated memory
            end;
          end;
        end;
      end;
    end;
  finally
    CoUninitialize; // Uninitialize COM
  end;
end;

procedure StrToList(const S, Sign: string; SList: TStrings);
var
  CurPos: integer;
  CurStr: string;
begin
  SList.clear;
  SList.BeginUpdate();
  try
    CurStr := S;
    repeat
      CurPos := Pos(Sign, CurStr);
      if (CurPos > 0) then
      begin
        SList.Add(Copy(CurStr, 1, Pred(CurPos)));
        CurStr := Trim(Copy(CurStr, CurPos + Length(Sign),
          Length(CurStr) - CurPos - Length(Sign) + 1));
      end
      else
        SList.Add(CurStr);
    until CurPos = 0;
  finally
    SList.EndUpdate();
  end;
end;

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
  if OpenFileDialog('Select an image','FileName : ','OK', True, sFile, DialogDir) then
    Edit1.Text := ExtractBaseTitle(sFile);
 end else
 begin
  if OpenFileDialog('Select a dir','DirName : ','OK', False, sFile, DialogDir) then
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
