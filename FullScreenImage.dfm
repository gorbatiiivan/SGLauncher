object FullScreenForm: TFullScreenForm
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'FullScreenForm'
  ClientHeight = 480
  ClientWidth = 640
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  WindowState = wsMaximized
  OnKeyDown = FormKeyDown
  OnMouseUp = FormMouseUp
  TextHeight = 15
  object FullScreenImage: TImage
    AlignWithMargins = True
    Left = 50
    Top = 53
    Width = 540
    Height = 377
    Margins.Left = 50
    Margins.Top = 15
    Margins.Right = 50
    Margins.Bottom = 50
    Align = alClient
    Center = True
    Proportional = True
    Stretch = True
    OnMouseUp = FormMouseUp
    ExplicitLeft = 72
    ExplicitTop = 128
    ExplicitWidth = 504
    ExplicitHeight = 208
  end
  object Label1: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 10
    Width = 634
    Height = 25
    Margins.Top = 10
    Align = alTop
    Alignment = taCenter
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    ExplicitWidth = 5
  end
end
