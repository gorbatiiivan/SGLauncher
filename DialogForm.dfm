object DiagForm: TDiagForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'DiagForm'
  ClientHeight = 140
  ClientWidth = 426
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  ShowHint = True
  TextHeight = 15
  object Label1: TLabel
    Left = 24
    Top = 24
    Width = 77
    Height = 15
    Caption = 'Specify name :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 24
    Top = 72
    Width = 337
    Height = 15
    AutoSize = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Edit1: TEdit
    Left = 24
    Top = 45
    Width = 337
    Height = 23
    TabOrder = 0
  end
  object Button1: TButton
    Left = 135
    Top = 96
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object Button2: TButton
    Left = 216
    Top = 96
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object Button3: TButton
    Left = 367
    Top = 44
    Width = 33
    Height = 25
    Caption = '>>'
    TabOrder = 1
    OnClick = Button3Click
  end
end
