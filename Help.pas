unit Help;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls,
  Vcl.ExtCtrls;

type
  THelpForm = class(TForm)
    HELPFORM_PAGECTRL1: TPageControl;
    TabSheet1: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    PaintBox1: TPaintBox;
    Label5: TLabel;
    Label6: TLabel;
    TabSheet4: TTabSheet;
    Memo1: TMemo;
    TabSheet2: TTabSheet;
    Memo2: TMemo;
    procedure PaintBox1Paint(Sender: TObject);
    procedure Label5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HelpForm: THelpForm;

implementation

uses SystemUtils;

{$R *.dfm}

procedure THelpForm.PaintBox1Paint(Sender: TObject);
begin
  DrawAboutImage(PaintBox1);
end;

procedure THelpForm.Label5Click(Sender: TObject);
begin
  ShellOpen(Label5.Hint);
end;

end.
