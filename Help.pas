unit Help;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls,
  Vcl.ExtCtrls, CommCtrl, ShellAPI;

type
  THelpForm = class(TForm)
    HELPFORM_PAGECTRL1: TPageControl;
    TabSheet1: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    PaintBox1: TPaintBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    TabSheet4: TTabSheet;
    Memo1: TMemo;
    procedure PaintBox1Click(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Label5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HelpForm: THelpForm;
  LaunchSnake: Boolean= False;

implementation

uses Unit1, ABSnake;

{$R *.dfm}

procedure GetAboutInfo;
const
 IID_IImageList: TGUID = '{46EB5926-582E-4017-9FDF-E8998DAA0950}';
var
  Icon: TIcon;
  FileInfo: TSHFileInfo;
  IconIndex: Integer;
  hIconLarge: HICON;
begin
  Icon := TIcon.Create;
  try
    // Получаем индекс иконки
    SHGetFileInfo(PChar(ParamStr(0)), 0, FileInfo, SizeOf(FileInfo),
      SHGFI_SYSICONINDEX);
    IconIndex := FileInfo.iIcon;

    // Извлекаем иконку максимального размера (обычно 256x256)
    SHGetImageList(SHIL_JUMBO, IID_IImageList, Pointer(hIconLarge));
    Icon.Handle := ImageList_GetIcon(hIconLarge, IconIndex, ILD_NORMAL);

    // Рисуем с масштабированием до 512x512
    HelpForm.PaintBox1.Canvas.StretchDraw(
      Rect(2, 2, 514, 514),Icon);
  finally
    Icon.Free;
  end;
end;

procedure THelpForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
if LaunchSnake then
 begin
  DestroySnake;
  LaunchSnake := False;
  Label4.Visible := False;
 end;
end;

procedure THelpForm.PaintBox1Click(Sender: TObject);
begin
CreateSnake(Self, PaintBox1);
LaunchSnake := True;
if LaunchSnake = True then
TThread.CreateAnonymousThread(procedure
  begin
    Label4.Visible := True;

    Sleep(10000);

    TThread.Synchronize(nil, procedure
    begin
      Label4.Visible := False;
    end);
  end).Start;
end;

procedure THelpForm.PaintBox1Paint(Sender: TObject);
begin
if LaunchSnake = True then
  PaintSnake('Score: ', 'Pause')
   else GetAboutInfo;
end;

procedure THelpForm.Label5Click(Sender: TObject);
begin
 ShellExecute(0, 'open', PChar(Label5.Hint), nil, nil, SW_SHOWNORMAL);
end;

end.
