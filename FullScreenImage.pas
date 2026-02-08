unit FullScreenImage;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TFullScreenForm = class(TForm)
    FullScreenImage: TImage;
    Label1: TLabel;
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FullScreenForm: TFullScreenForm;

implementation

{$R *.dfm}

uses Unit1;

procedure TFullScreenForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  idx: Integer;
begin
  // Проверяем, что главная форма жива и список не пустой
  if (MainForm = nil) or (MainForm.ListView1.Items.Count = 0) then
  begin
    Key := 0;
    Exit;
  end;

  idx := MainForm.ListView1.ItemIndex;
  if idx < 0 then idx := 0;

  case Key of
    VK_UP:
      if idx > 0 then Dec(idx);

    VK_DOWN:
      if idx < MainForm.ListView1.Items.Count - 1 then Inc(idx);

    VK_LEFT:
      MainForm.PrevImgBtnClick(Sender);   // ? предыдущее

    VK_RIGHT:
      MainForm.NextImgBtnClick(Sender);   // ? следующее

    VK_RETURN:
     begin
      MainForm.ListView1DblClick(Sender);
      Close;
     end;

    VK_ESCAPE:
      Close;

  else
    Exit;  // оставляем Key как есть ? другие обработчики получат клавишу
  end;

  // Применяем выбор
  MainForm.ListView1.ItemIndex := idx;
  MainForm.ListView1.Items[idx].MakeVisible(False);
  Label1.Caption := MainForm.ListView1.Selected.Caption;

  // Самое важное — делаем КОПИЮ изображения
  FullScreenImage.Picture.Assign(MainForm.ScreenShotImage.Picture);

  Key := 0;  // глотаем клавишу
end;

procedure TFullScreenForm.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 case Button of
   mbLeft :
    begin
     MainForm.NextImgBtnClick(Sender);
     FullScreenImage.Picture.WICImage := MainForm.ScreenShotImage.Picture.WICImage;
    end;
   mbRight:  Close;
   mbMiddle: Close;
 end;
end;

end.
