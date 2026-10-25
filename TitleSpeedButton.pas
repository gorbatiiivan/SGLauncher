unit TitleSpeedButton;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Buttons, Vcl.Themes, Vcl.Styles,
  Vcl.Forms;

type
  TTitleSpeedButton = class(TSpeedButton)
  private
    FAppIcon: TIcon;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

function ReplaceWithTitleSpeedButton(OldButton: TSpeedButton): TTitleSpeedButton;

implementation

{ TTitleSpeedButton }

constructor TTitleSpeedButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Flat          := True;
  Transparent   := True;
  StyleElements := [];
  ParentFont    := False;
  ParentColor   := False;
  Cursor        := crHandPoint;

  // Загружаем иконку приложения 16×16
  FAppIcon := TIcon.Create;
  FAppIcon.Handle := LoadImage(HInstance, 'MAINICON', IMAGE_ICON, 16, 16, LR_DEFAULTCOLOR);
  if FAppIcon.Handle = 0 then
    FAppIcon.Assign(Application.Icon);   // запасной вариант
end;

destructor TTitleSpeedButton.Destroy;
begin
  FAppIcon.Free;
  inherited;
end;

procedure TTitleSpeedButton.Paint;
var
  R, TextR: TRect;
  TextColor: TColor;
  IconSize: Integer;
begin
  R := ClientRect;
  IconSize := 16;

  // --- Иконка слева ---
  if (FAppIcon <> nil) and (FAppIcon.Handle <> 0) then
  begin
    DrawIconEx(Canvas.Handle,
      R.Left + 2,
      R.Top + (R.Height - IconSize) div 2,
      FAppIcon.Handle,
      IconSize, IconSize,
      0, 0, DI_NORMAL);
  end;

  // --- Цвет текста из стиля ---
  if StyleServices.Enabled and not StyleServices.IsSystemStyle then
    TextColor := StyleServices.GetSystemColor(clCaptionText)
  else
    TextColor := clCaptionText;

  // Текст справа от иконки
  TextR := R;
  TextR.Left := R.Left + IconSize + 6;   // отступ после иконки

  Canvas.Font.Assign(Font);
  Canvas.Font.Color := TextColor;
  Canvas.Brush.Style := bsClear;

  DrawText(Canvas.Handle, PChar(Caption), -1, TextR,
    DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_NOPREFIX);
end;

{ Helper }

function ReplaceWithTitleSpeedButton(OldButton: TSpeedButton): TTitleSpeedButton;
var
  NewBtn: TTitleSpeedButton;
  ParentCtrl: TWinControl;
  OldName: string;
  OldOwner: TComponent;
begin
  if not Assigned(OldButton) then
    Exit(nil);

  ParentCtrl := OldButton.Parent;
  OldOwner   := OldButton.Owner;
  OldName    := OldButton.Name;

  OldButton.Name := '';

  NewBtn := TTitleSpeedButton.Create(OldOwner);
  try
    NewBtn.Parent      := ParentCtrl;
    NewBtn.SetBounds(OldButton.Left, OldButton.Top, OldButton.Width, OldButton.Height);
    NewBtn.Align       := OldButton.Align;
    NewBtn.Anchors     := OldButton.Anchors;
    NewBtn.Caption     := OldButton.Caption;
    NewBtn.Font.Assign(OldButton.Font);
    NewBtn.Hint        := OldButton.Hint;
    NewBtn.ShowHint    := OldButton.ShowHint;
    NewBtn.Visible     := OldButton.Visible;
    NewBtn.Enabled     := OldButton.Enabled;
    NewBtn.OnClick     := OldButton.OnClick;
    NewBtn.OnMouseEnter:= OldButton.OnMouseEnter;
    NewBtn.OnMouseLeave:= OldButton.OnMouseLeave;
    NewBtn.PopupMenu   := OldButton.PopupMenu;
    NewBtn.Tag         := OldButton.Tag;

    NewBtn.Name := OldName;
    NewBtn.Caption := ExtractFileName(ChangeFileExt(ParamStr(0),'')) + '▾';

    OldButton.Free;
  except
    NewBtn.Free;
    raise;
  end;

  Result := NewBtn;
end;

end.
