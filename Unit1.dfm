object SGLMainForm: TSGLMainForm
  Left = 0
  Top = 0
  Margins.Left = 14
  ClientHeight = 750
  ClientWidth = 957
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  ShowHint = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  TextHeight = 15
  object TabControl1: TTabControl
    AlignWithMargins = True
    Left = 3
    Top = 46
    Width = 951
    Height = 701
    Margins.Top = 6
    Align = alClient
    TabOrder = 0
    OnChange = TabControl1Change
    object Splitter1: TSplitter
      Left = 313
      Top = 6
      Height = 691
      OnAfterResize = FormResize
      ExplicitTop = 22
      ExplicitHeight = 740
    end
    object Panel1: TPanel
      Left = 316
      Top = 6
      Width = 631
      Height = 691
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      object Splitter2: TSplitter
        Left = 0
        Top = 421
        Width = 631
        Height = 3
        Cursor = crVSplit
        Align = alTop
        OnAfterResize = FormResize
        ExplicitLeft = -3
        ExplicitTop = 412
        ExplicitWidth = 637
      end
      object Panel2: TPanel
        Left = 0
        Top = 424
        Width = 631
        Height = 267
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object ScreenShotImage: TImage
          AlignWithMargins = True
          Left = 97
          Top = 3
          Width = 437
          Height = 261
          Margins.Left = 55
          Margins.Right = 55
          Align = alClient
          Center = True
          Proportional = True
          Stretch = True
          OnClick = ScreenShotImageClick
          ExplicitLeft = 14
          ExplicitTop = 0
          ExplicitWidth = 388
          ExplicitHeight = 226
        end
        object NextImgBtn: TSpeedButton
          Left = 589
          Top = 0
          Width = 42
          Height = 267
          Align = alRight
          Caption = '>'
          Enabled = False
          Flat = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          OnClick = NextImgBtnClick
          ExplicitLeft = 595
          ExplicitHeight = 316
        end
        object PrevImgBtn: TSpeedButton
          Left = 0
          Top = 0
          Width = 42
          Height = 267
          Align = alLeft
          Caption = '<'
          Enabled = False
          Flat = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          OnClick = PrevImgBtnClick
          ExplicitHeight = 316
        end
      end
      object ScrollBox1: TScrollBox
        AlignWithMargins = True
        Left = 6
        Top = 6
        Width = 619
        Height = 409
        Margins.Left = 6
        Margins.Top = 6
        Margins.Right = 6
        Margins.Bottom = 6
        HorzScrollBar.Visible = False
        VertScrollBar.Smooth = True
        VertScrollBar.Tracking = True
        Align = alTop
        BorderStyle = bsNone
        Enabled = False
        TabOrder = 1
        UseWheelForScrolling = True
        object Label1: TLabel
          AlignWithMargins = True
          Left = 14
          Top = 206
          Width = 599
          Height = 42
          Margins.Left = 14
          Margins.Top = 6
          Margins.Right = 6
          Margins.Bottom = 6
          Align = alTop
          AutoSize = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          WordWrap = True
          ExplicitTop = 223
          ExplicitWidth = 608
        end
        object InfoPanel: TPanel
          Left = 0
          Top = 0
          Width = 619
          Height = 200
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          object TitleLabel: TLabel
            AlignWithMargins = True
            Left = 14
            Top = 3
            Width = 602
            Height = 32
            Margins.Left = 14
            Align = alTop
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -24
            Font.Name = 'Segoe UI'
            Font.Style = []
            ParentFont = False
            ExplicitWidth = 7
          end
          object DeveloperLabel: TLabel
            AlignWithMargins = True
            Left = 14
            Top = 41
            Width = 602
            Height = 15
            Margins.Left = 14
            Align = alTop
            ExplicitWidth = 3
          end
          object PublisherLabel: TLabel
            AlignWithMargins = True
            Left = 14
            Top = 62
            Width = 602
            Height = 15
            Margins.Left = 14
            Align = alTop
            ExplicitWidth = 3
          end
          object GenreLabel: TLabel
            AlignWithMargins = True
            Left = 14
            Top = 83
            Width = 602
            Height = 15
            Margins.Left = 14
            Align = alTop
            ExplicitWidth = 3
          end
          object SeriesLabel: TLabel
            AlignWithMargins = True
            Left = 14
            Top = 104
            Width = 602
            Height = 15
            Margins.Left = 14
            Align = alTop
            ExplicitWidth = 3
          end
          object PlatformLabel: TLabel
            AlignWithMargins = True
            Left = 14
            Top = 125
            Width = 602
            Height = 15
            Margins.Left = 14
            Align = alTop
            ExplicitWidth = 3
          end
          object ReleaseLabel: TLabel
            AlignWithMargins = True
            Left = 14
            Top = 146
            Width = 602
            Height = 15
            Margins.Left = 14
            Align = alTop
            ExplicitWidth = 3
          end
        end
      end
    end
    object Panel3: TPanel
      Left = 4
      Top = 6
      Width = 309
      Height = 691
      Align = alLeft
      BevelOuter = bvNone
      DoubleBuffered = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentDoubleBuffered = False
      ParentFont = False
      TabOrder = 1
      object ListView1: TListView
        Left = 0
        Top = 34
        Width = 309
        Height = 657
        Align = alClient
        BorderStyle = bsNone
        Columns = <
          item
            Width = 514
          end>
        DoubleBuffered = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Segoe UI'
        Font.Style = []
        FlatScrollBars = True
        OwnerData = True
        ReadOnly = True
        RowSelect = True
        ParentDoubleBuffered = False
        ParentFont = False
        PopupMenu = PopupMenu1
        ShowColumnHeaders = False
        TabOrder = 0
        ViewStyle = vsReport
        OnContextPopup = ListView1ContextPopup
        OnData = ListView1Data
        OnDblClick = ListView1DblClick
        OnKeyDown = ListView1KeyDown
        OnKeyPress = ListView1KeyPress
        OnSelectItem = ListView1SelectItem
      end
      object Panel4: TPanel
        Left = 0
        Top = 0
        Width = 309
        Height = 34
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        object ComboBox1: TComboBox
          Left = 135
          Top = 2
          Width = 174
          Height = 28
          Style = csDropDownList
          DropDownCount = 25
          Enabled = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnChange = ComboBox1Change
        end
        object Edit1: TEdit
          Left = 2
          Top = 2
          Width = 127
          Height = 28
          Enabled = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnChange = Edit1Change
        end
      end
    end
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 957
    Height = 40
    AutoSize = True
    ButtonHeight = 38
    ButtonWidth = 39
    Caption = 'ToolBar1'
    Constraints.MinHeight = 40
    Constraints.MinWidth = 40
    Images = ImageList1
    TabOrder = 1
    OnClick = ToolBar1Click
  end
  object PopupMenu1: TPopupMenu
    Left = 345
    Top = 22
    object Run1: TMenuItem
      Caption = 'Run'
      Default = True
      ShortCut = 13
      OnClick = Run1Click
    end
    object Configuration1: TMenuItem
      Caption = 'Configuration'
      OnClick = Configuration1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Manual1: TMenuItem
      Caption = 'Manual'
      Enabled = False
      OnClick = Manual1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object DesktopShortcut1: TMenuItem
      Caption = 'Create desktop shortcut'
      OnClick = DesktopShortcut1Click
    end
    object N7: TMenuItem
      Caption = '-'
    end
    object Customimagename1: TMenuItem
      Caption = 'Custom image name'
      OnClick = Customimagename1Click
    end
  end
  object TrayIcon: TTrayIcon
    PopupMenu = TrayMenu
    OnClick = TrayIconClick
    Left = 417
    Top = 22
  end
  object TrayMenu: TPopupMenu
    Left = 479
    Top = 20
    object Show1: TMenuItem
      Caption = 'Show'
      Default = True
      OnClick = TrayIconClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object Options1: TMenuItem
      Caption = 'Options'
      object About1: TMenuItem
        Caption = 'About'
        ShortCut = 112
        OnClick = About1Click
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object StyleMenu1: TMenuItem
        Caption = 'Style'
      end
      object Hideonstartup1: TMenuItem
        Caption = 'Hide on startup'
        OnClick = Hideonstartup1Click
      end
      object ToolBarMenu1: TMenuItem
        Caption = 'ToolBar'
        object ShowToolBar: TMenuItem
          Caption = 'Show'
          OnClick = ShowToolBarClick
        end
        object AlignToolBar1: TMenuItem
          Caption = 'Align to'
          object ToolBarTop1: TMenuItem
            Caption = 'Top'
            Hint = 'alTop'
            OnClick = ToolBarTop1Click
          end
          object ToolBarBottom1: TMenuItem
            Caption = 'Bottom'
            Hint = 'alBottom'
            OnClick = ToolBarTop1Click
          end
          object ToolBarLeft1: TMenuItem
            Caption = 'Left'
            Hint = 'alLeft'
            OnClick = ToolBarTop1Click
          end
          object ToolBarRight1: TMenuItem
            Caption = 'Right'
            Hint = 'alRight'
            OnClick = ToolBarTop1Click
          end
        end
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object Specifyfolder1: TMenuItem
        Caption = 'Specify folder'
        OnClick = Specifyfolder1Click
      end
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object Exit1: TMenuItem
      Caption = 'Exit'
      OnClick = Exit1Click
    end
  end
  object ImageList1: TImageList
    ColorDepth = cd32Bit
    DrawingStyle = dsTransparent
    Height = 32
    Width = 32
    Left = 544
    Top = 24
  end
end
