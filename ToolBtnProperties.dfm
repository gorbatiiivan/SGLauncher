object ToolBtnPropertiesForm: TToolBtnPropertiesForm
  Left = 191
  Top = 107
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Properties'
  ClientHeight = 321
  ClientWidth = 495
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesktopCenter
  ShowHint = True
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 9
    Top = 9
    Width = 476
    Height = 256
    TabOrder = 0
    object Image1: TImage
      Left = 18
      Top = 28
      Width = 35
      Height = 35
    end
    object LNKPROP_EDIT2: TLabeledEdit
      Left = 70
      Top = 75
      Width = 363
      Height = 21
      EditLabel.Width = 26
      EditLabel.Height = 13
      EditLabel.Caption = 'Path:'
      TabOrder = 1
      Text = ''
    end
    object LNKPROP_EDIT1: TLabeledEdit
      Left = 70
      Top = 28
      Width = 398
      Height = 21
      EditLabel.Width = 32
      EditLabel.Height = 13
      EditLabel.Caption = 'Name:'
      TabOrder = 0
      Text = ''
    end
    object LNKPROP_EDIT3: TLabeledEdit
      Left = 70
      Top = 123
      Width = 398
      Height = 21
      EditLabel.Width = 59
      EditLabel.Height = 13
      EditLabel.Caption = 'Parameters:'
      TabOrder = 3
      Text = ''
    end
    object LNKPROP_BTN1: TButton
      Left = 440
      Top = 219
      Width = 23
      Height = 23
      Hint = 'Click to change icon'
      Caption = '>>'
      TabOrder = 7
      OnClick = LNKPROP_BTN1Click
    end
    object LNKPROP_EDIT4: TLabeledEdit
      Left = 70
      Top = 173
      Width = 363
      Height = 21
      EditLabel.Width = 65
      EditLabel.Height = 13
      EditLabel.Caption = 'Working dir:'
      TabOrder = 4
      Text = ''
    end
    object LNKPROP_EDIT5: TLabeledEdit
      Left = 70
      Top = 220
      Width = 363
      Height = 21
      EditLabel.Width = 70
      EditLabel.Height = 13
      EditLabel.Caption = 'Icon location:'
      TabOrder = 6
      Text = ''
    end
    object LNKPROP_BTN4: TButton
      Left = 440
      Top = 74
      Width = 23
      Height = 23
      Caption = '>>'
      TabOrder = 2
      OnClick = LNKPROP_BTN4Click
    end
    object LNKPROP_BTN5: TButton
      Left = 440
      Top = 172
      Width = 23
      Height = 23
      Caption = '>>'
      TabOrder = 5
      OnClick = LNKPROP_BTN5Click
    end
  end
  object LNKPROP_BTN2: TButton
    Left = 158
    Top = 281
    Width = 83
    Height = 27
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object LNKPROP_BTN3: TButton
    Left = 255
    Top = 281
    Width = 83
    Height = 27
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
