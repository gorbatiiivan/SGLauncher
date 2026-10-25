object SGLMainForm: TSGLMainForm
  Left = 0
  Top = 0
  ClientHeight = 750
  ClientWidth = 934
  Color = clBtnFace
  CustomTitleBar.CaptionAlignment = taCenter
  CustomTitleBar.Control = TitleBarPanel1
  CustomTitleBar.Enabled = True
  CustomTitleBar.Height = 31
  CustomTitleBar.ShowIcon = False
  CustomTitleBar.StyleColors = True
  CustomTitleBar.SystemColors = False
  CustomTitleBar.SystemButtons = False
  CustomTitleBar.BackgroundColor = clWhite
  CustomTitleBar.ForegroundColor = 65793
  CustomTitleBar.InactiveBackgroundColor = clWhite
  CustomTitleBar.InactiveForegroundColor = 10066329
  CustomTitleBar.ButtonForegroundColor = 65793
  CustomTitleBar.ButtonBackgroundColor = clWhite
  CustomTitleBar.ButtonHoverForegroundColor = 65793
  CustomTitleBar.ButtonHoverBackgroundColor = 16053492
  CustomTitleBar.ButtonPressedForegroundColor = 65793
  CustomTitleBar.ButtonPressedBackgroundColor = 15395562
  CustomTitleBar.ButtonInactiveForegroundColor = 10066329
  CustomTitleBar.ButtonInactiveBackgroundColor = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  GlassFrame.Enabled = True
  GlassFrame.Top = 31
  KeyPreview = True
  Position = poDesigned
  ShowHint = True
  StyleElements = [seFont, seClient]
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  TextHeight = 15
  object Splitter1: TSplitter
    Left = 522
    Top = 111
    Width = 7
    Height = 639
    OnAfterResize = FormResize
    ExplicitLeft = 313
    ExplicitTop = 6
    ExplicitHeight = 691
  end
  object Splitter4: TSplitter
    Left = 200
    Top = 111
    Width = 7
    Height = 639
  end
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 33
    Width = 928
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
  object TabView1: TTabView
    AlignWithMargins = True
    Left = 3
    Top = 79
    Width = 928
    Height = 29
    Align = alTop
    ParentColor = False
    ParentDoubleBuffered = False
    Tabs = <>
    TabStop = True
    TabOrder = 0
    ShowTabsMenuButton = True
    OnChangeTab = TabView1ChangeTab
  end
  object Panel1: TPanel
    AlignWithMargins = True
    Left = 532
    Top = 114
    Width = 399
    Height = 633
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object Splitter2: TSplitter
      Left = 0
      Top = 409
      Width = 399
      Height = 7
      Cursor = crVSplit
      Align = alTop
      OnAfterResize = FormResize
      ExplicitTop = 421
      ExplicitWidth = 631
    end
    object Panel2: TPanel
      Left = 0
      Top = 416
      Width = 399
      Height = 217
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      object ScreenShotImage: TImage
        AlignWithMargins = True
        Left = 97
        Top = 3
        Width = 205
        Height = 88
        Margins.Left = 55
        Margins.Right = 55
        Align = alClient
        Center = True
        Proportional = True
        Stretch = True
        OnClick = ScreenShotImageClick
        ExplicitLeft = 100
        ExplicitTop = 19
        ExplicitWidth = 410
        ExplicitHeight = 134
      end
      object NextImgBtn: TSpeedButton
        Left = 357
        Top = 0
        Width = 42
        Height = 94
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
        Height = 94
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
      object Splitter3: TSplitter
        Left = 0
        Top = 94
        Width = 399
        Height = 7
        Cursor = crVSplit
        Align = alBottom
        OnMoved = Splitter3Moved
        ExplicitTop = 144
        ExplicitWidth = 631
      end
      object ScrollBox2: TScrollBox
        AlignWithMargins = True
        Left = 55
        Top = 104
        Width = 289
        Height = 110
        Margins.Left = 55
        Margins.Right = 55
        HorzScrollBar.Style = ssHotTrack
        HorzScrollBar.Tracking = True
        VertScrollBar.Visible = False
        Align = alBottom
        BorderStyle = bsNone
        TabOrder = 0
        UseWheelForScrolling = True
        object FlowPanel1: TFlowPanel
          Left = 6
          Top = 24
          Width = 299
          Height = 65
          AutoSize = True
          BevelOuter = bvNone
          TabOrder = 0
        end
      end
    end
    object ScrollBox1: TScrollBox
      Left = 0
      Top = 0
      Width = 399
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
      DoubleBuffered = True
      Enabled = False
      ParentDoubleBuffered = False
      TabOrder = 1
      UseWheelForScrolling = True
      object Label1: TLabel
        AlignWithMargins = True
        Left = 14
        Top = 206
        Width = 379
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
        ShowAccelChar = False
        WordWrap = True
        ExplicitTop = 209
      end
      object InfoPanel: TPanel
        Left = 0
        Top = 0
        Width = 399
        Height = 200
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object TitleLabel: TLabel
          AlignWithMargins = True
          Left = 14
          Top = 3
          Width = 382
          Height = 32
          Margins.Left = 14
          Align = alTop
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -24
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          ShowAccelChar = False
          ExplicitWidth = 7
        end
        object DeveloperLabel: TLabel
          AlignWithMargins = True
          Left = 14
          Top = 41
          Width = 382
          Height = 15
          Cursor = crHandPoint
          Margins.Left = 14
          Align = alTop
          ShowAccelChar = False
          OnClick = DeveloperLabelClick
          OnMouseEnter = DeveloperLabelMouseEnter
          OnMouseLeave = DeveloperLabelMouseLeave
          ExplicitWidth = 3
        end
        object PublisherLabel: TLabel
          AlignWithMargins = True
          Left = 14
          Top = 62
          Width = 382
          Height = 15
          Cursor = crHandPoint
          Margins.Left = 14
          Align = alTop
          ShowAccelChar = False
          OnClick = DeveloperLabelClick
          OnMouseEnter = DeveloperLabelMouseEnter
          OnMouseLeave = DeveloperLabelMouseLeave
          ExplicitWidth = 3
        end
        object GenreLabel: TLabel
          AlignWithMargins = True
          Left = 14
          Top = 83
          Width = 382
          Height = 15
          Cursor = crHandPoint
          Margins.Left = 14
          Align = alTop
          ShowAccelChar = False
          OnClick = DeveloperLabelClick
          OnMouseEnter = DeveloperLabelMouseEnter
          OnMouseLeave = DeveloperLabelMouseLeave
          ExplicitWidth = 3
        end
        object SeriesLabel: TLabel
          AlignWithMargins = True
          Left = 14
          Top = 104
          Width = 382
          Height = 15
          Cursor = crHandPoint
          Margins.Left = 14
          Align = alTop
          ShowAccelChar = False
          OnClick = DeveloperLabelClick
          OnMouseEnter = DeveloperLabelMouseEnter
          OnMouseLeave = DeveloperLabelMouseLeave
          ExplicitWidth = 3
        end
        object PlatformLabel: TLabel
          AlignWithMargins = True
          Left = 14
          Top = 125
          Width = 382
          Height = 15
          Cursor = crHandPoint
          Margins.Left = 14
          Align = alTop
          ShowAccelChar = False
          OnClick = DeveloperLabelClick
          OnMouseEnter = DeveloperLabelMouseEnter
          OnMouseLeave = DeveloperLabelMouseLeave
          ExplicitWidth = 3
        end
        object ReleaseLabel: TLabel
          AlignWithMargins = True
          Left = 14
          Top = 146
          Width = 382
          Height = 15
          Cursor = crHandPoint
          Margins.Left = 14
          Align = alTop
          ShowAccelChar = False
          OnClick = DeveloperLabelClick
          OnMouseEnter = DeveloperLabelMouseEnter
          OnMouseLeave = DeveloperLabelMouseLeave
          ExplicitWidth = 3
        end
        object PlayModeLabel: TLabel
          AlignWithMargins = True
          Left = 14
          Top = 167
          Width = 382
          Height = 15
          Cursor = crHandPoint
          Margins.Left = 14
          Align = alTop
          OnClick = DeveloperLabelClick
          OnMouseEnter = DeveloperLabelMouseEnter
          OnMouseLeave = DeveloperLabelMouseLeave
          ExplicitWidth = 3
        end
      end
    end
  end
  object Panel3: TPanel
    AlignWithMargins = True
    Left = 210
    Top = 114
    Width = 309
    Height = 633
    Align = alLeft
    BevelOuter = bvNone
    DoubleBuffered = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentDoubleBuffered = False
    ParentFont = False
    TabOrder = 3
    object ListView1: TListView
      AlignWithMargins = True
      Left = 3
      Top = 37
      Width = 303
      Height = 593
      Align = alClient
      BorderStyle = bsNone
      Columns = <
        item
          Width = 514
        end
        item
        end>
      DoubleBuffered = True
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
      PopupMenu = ListViewPopupActionBar
      ShowColumnHeaders = False
      TabOrder = 1
      ViewStyle = vsReport
      OnAdvancedCustomDrawItem = ListView1AdvancedCustomDrawItem
      OnContextPopup = ListView1ContextPopup
      OnData = ListView1Data
      OnDblClick = ListView1DblClick
      OnKeyDown = ListView1KeyDown
      OnKeyPress = ListView1KeyPress
      OnMouseLeave = ListView1MouseLeave
      OnSelectItem = ListView1SelectItem
    end
    object Panel4: TPanel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 303
      Height = 28
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object ComboBox1: TComboBox
        AlignWithMargins = True
        Left = 68
        Top = 0
        Width = 76
        Height = 28
        Margins.Left = 0
        Margins.Top = 0
        Margins.Bottom = 0
        Align = alLeft
        Style = csDropDownList
        DropDownCount = 35
        Enabled = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        OnChange = ComboBox1Change
      end
      object ComboBox2: TComboBox
        AlignWithMargins = True
        Left = 147
        Top = 0
        Width = 108
        Height = 28
        Margins.Left = 0
        Margins.Top = 0
        Margins.Bottom = 0
        Align = alLeft
        Style = csDropDownList
        DropDownCount = 35
        DropDownWidth = 174
        Enabled = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        OnChange = ComboBox2Change
      end
      object PlatformBtn: TButton
        Left = 258
        Top = 0
        Width = 45
        Height = 28
        Hint = 'Filter by Platform'
        Align = alClient
        Caption = #9776
        DropDownMenu = pmPlatformFilter
        Enabled = False
        Style = bsSplitButton
        TabOrder = 3
        OnClick = PlatformBtnClick
      end
      object Edit1: TEdit
        AlignWithMargins = True
        Left = 0
        Top = 0
        Width = 65
        Height = 28
        Margins.Left = 0
        Margins.Top = 0
        Margins.Bottom = 0
        Align = alLeft
        AutoSize = False
        DoubleBuffered = True
        Enabled = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentDoubleBuffered = False
        ParentFont = False
        TabOrder = 0
        OnChange = Edit1Change
      end
    end
  end
  object TitleBarPanel1: TTitleBarPanel
    Left = 0
    Top = 0
    Width = 934
    Height = 30
    CustomButtons = <
      item
        ButtonType = sbCustom
        Hint = 'Hide to Tray'
        Width = 46
        ShowHint = True
        OnPaint = TitleBarPanel1CustomButtons0Paint
        OnClick = TitleBarPanel1CustomButtons0Click
      end>
    DesignSize = (
      934
      30)
    object Image1: TImage
      Left = 0
      Top = 0
      Width = 32
      Height = 30
      Align = alLeft
      Center = True
      Picture.Data = {
        07544269746D617042040000424D420400000000000042000000280000001000
        0000100000000100200003000000000400006F0000006F000000000000000000
        00000000FF0000FF0000FF000000FFFFFF00FFFFFF00FFFFFF001D1A14AF3833
        26F6393327F73C372BFC3C372BFC3C372BFC3A3529FB393327F62C261FE90C0A
        0899FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF001F1F186C2723
        1ACC1D1A15E7433F38FF4B4840FF4B4840FF3A352BFF191611E11C1A14BD0E0B
        0B5BFFFFFF00FFFFFF00FFFFFF00231F199B2F2A21EB332E24EB332E24EB332E
        24EB2F2B22F23E392FFF403B31FF403B31FF3A3529FF2E2A20EF332E24EB332E
        24EB332E24EB242018DC0B0B0879312D21F98B7D60FF8B7D60FF8B7D60FF8B7D
        60FF8B7D60FF8B7D60FF8B7D60FF8B7D60FF8B7D60FF8B7D60FF8B7D60FF8B7D
        60FF8B7D60FF85775CFF1B180FDC1F1C0BFE413A1EFF413A1EFF413A1EFF413A
        1EFF413A1EFF413A1EFF413A1EFF413A1EFF413A1EFF413A1EFF413A1EFF413A
        1EFF413A1EFF403A1DFF161404F5594F00F8D4BC00FFBEA800FFC9B200FFD4BC
        00FFC6AF00FF9C8A00FF9E8C00FF9E8C00FFA08E00FFC8B100FFD4BC00FFD4BC
        00FFD4BC00FFCEB700FF373300DE594F00F8BEA800FF272B0BFF303109FFCAB3
        00FFC8B100FFA39000FFB49F00FFB49F00FF9E8C00FFC6AF00FFD4BC00FFBDA7
        00FFD4BC00FFCEB700FF373300DE594F00F8C9B200FF313209FF444207FFD1B9
        00FFCAB300FF9C8B03FF988700FF988700FF9B8A03FFCAB300FF5A5304FF1B1F
        0AFFAF9B00FFCEB700FF373300DE594F00F8D4BC00FFCAB300FFD1B900FFD4BC
        00FFB9A400FF141417FF9E8D01FF9C8B01FF131316FFB9A400FF5A5304FF1B1F
        0AFFAF9B00FFCEB700FF373300DE594F00F8D4BC00FFD4BC00FFD4BC00FFD4BC
        00FFB9A400FF21244EFF494845FF494845FF21244EFFB9A400FFD4BC00FFBDA7
        00FFD4BC00FFCEB700FF373300DE594F00F8D4BC00FFA08F09FF766B1FFFB9A4
        01FFBAA500FF322D08FF787770FF787770FF322D08FFBAA500FFD4BC00FFD4BC
        00FFD4BC00FFCEB700FF373300DE594F00F87C711BFFB6B5AEFFE4E4E4FF6C6A
        59FFB9A401FFC6AF00FF76735EFF76735EFFC6AF00FFD4BC00FFD4BC00FFD4BC
        00FFC4AE00FFCEB700FF373300DE594F00F86F6A42FFCBCBCBFFF3F3F3FFE5E5
        E5FF766B1FFFD4BC00FF67602CFF67602CFFD4BC00FFD4BC00FFD4BC00FF7669
        01FF171A07FFAA9700FF373300DE594F00F8706829FFF8F8F8FFC9C9C9FFB6B5
        AEFFA08F09FFD4BC00FFB19E06FFB19E06FFD4BC00FFD4BC00FFD4BC00FF5850
        03FF171D0BFF978600FF373300DE524800F7BEA803FF706829FF6F6A42FF7C71
        1BFFD4BC00FFD4BC00FFD4BC00FFD4BC00FFD4BC00FFD4BC00FFD4BC00FFD4BC
        00FFB49F00FFCCB600FF322E00DD373100BB514800F5574F00F6574F00F6574F
        00F6574F00F6574F00F6574F00F6574F00F6574F00F6574F00F6574F00F6574F
        00F6574F00F6423C00EA1C18009D}
      Transparent = True
      OnClick = Image1Click
      OnDblClick = Image1DblClick
      ExplicitLeft = 25
    end
    object BtnMenu: TButton
      Left = 32
      Top = 0
      Width = 25
      Height = 30
      Margins.Left = 30
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alLeft
      Caption = #9776
      DropDownMenu = TrayPopupActionBar
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      TabStop = False
      OnClick = BtnMenuClick
    end
  end
  object NavigationView1: TNavigationView
    Left = 0
    Top = 111
    Width = 200
    Height = 639
    Align = alLeft
    CompactMode = False
    ParentColor = False
    ParentDoubleBuffered = False
    Items = <>
    ItemHeight = 40
    TabStop = True
    TabOrder = 5
    Transparent = True
    NormalWidth = 200
    OnChangeItem = NavigationView1ChangeItem
  end
  object TrayIcon: TTrayIcon
    PopupMenu = TrayPopupActionBar
    OnClick = TrayIconClick
    Left = 489
    Top = 22
  end
  object ImageList1: TImageList
    ColorDepth = cd32Bit
    DrawingStyle = dsTransparent
    Height = 32
    Width = 32
    Left = 680
    Top = 24
  end
  object TrayPopupActionBar: TPopupActionBar
    Left = 584
    Top = 24
    object ShowMenuItem: TMenuItem
      Caption = 'Show'
      Default = True
      OnClick = TrayIconClick
    end
    object N11: TMenuItem
      Caption = '-'
    end
    object Options2: TMenuItem
      Caption = 'Options'
      object AboutMenuItem: TMenuItem
        Caption = 'About'
        ShortCut = 112
        OnClick = AboutMenuItemClick
      end
      object N14: TMenuItem
        Caption = '-'
      end
      object AutostartMenuItem: TMenuItem
        Caption = 'Autostart'
        OnClick = AutostartMenuItemClick
      end
      object HideonstartupMenuItem: TMenuItem
        Caption = 'Hide on startup'
        OnClick = HideonstartupMenuItemClick
      end
      object VerticaltabsMenuItem: TMenuItem
        Caption = 'Vertical tabs'
        OnClick = VerticaltabsMenuItemClick
      end
      object ListView2: TMenuItem
        Caption = 'List View'
        object ViewasThumbnailsMenuItem: TMenuItem
          Caption = 'View as Thumbnails'
          OnClick = ViewasThumbnailsMenuItemClick
        end
        object ViewasListMenuItem: TMenuItem
          Caption = 'View as List'
          OnClick = ViewasListMenuItemClick
        end
        object N13: TMenuItem
          Caption = '-'
        end
        object ShowImagesMenuItem: TMenuItem
          Caption = 'Show Images (beta)'
          OnClick = ShowImagesMenuItemClick
        end
        object ShowImageonHoverMenuItem: TMenuItem
          Caption = 'Show Image on Hover (beta)'
          OnClick = ShowImageonHoverMenuItemClick
        end
      end
      object GameDetails2: TMenuItem
        Caption = 'Game Details'
        object ShowGameDetailsMenuItem: TMenuItem
          Caption = 'Show Game Details'
          OnClick = ShowGameDetailsMenuItemClick
        end
        object EnabledimagegalleryMenuItem: TMenuItem
          Caption = 'Enabled image gallery'
          OnClick = EnabledimagegalleryMenuItemClick
        end
      end
      object StyleMenuItem: TMenuItem
        Caption = 'Style'
      end
      object oolBar1: TMenuItem
        Caption = 'ToolBar'
        object ToolBarShowMenuItem: TMenuItem
          Caption = 'Show'
          OnClick = ToolBarShowMenuItemClick
        end
        object ToolBarAlignMenuItem: TMenuItem
          Caption = 'Align to'
          object ToolBarTopMenuItem: TMenuItem
            Caption = 'Top'
            Hint = 'alTop'
            OnClick = ToolBarTop1Click
          end
          object ToolBarBottomMenuItem: TMenuItem
            Caption = 'Bottom'
            Hint = 'alBottom'
            OnClick = ToolBarTop1Click
          end
          object ToolBarLeftMenuItem: TMenuItem
            Caption = 'Left'
            Hint = 'alLeft'
            OnClick = ToolBarTop1Click
          end
          object ToolBarRightMenuItem: TMenuItem
            Caption = 'Right'
            Hint = 'alRight'
            OnClick = ToolBarTop1Click
          end
        end
      end
      object Core2: TMenuItem
        Caption = 'Core'
        object UseBinaryCacheMenuItem: TMenuItem
          Caption = 'Use Binary Cache'
          OnClick = UseBinaryCacheMenuItemClick
        end
        object EmptyWorkingSetMenuItem: TMenuItem
          Caption = 'EmptyWorkingSet'
          OnClick = EmptyWorkingSetMenuItemClick
        end
      end
      object N12: TMenuItem
        Caption = '-'
      end
      object SpecifyfoldersMenuItem: TMenuItem
        Caption = 'Specify folders'
        OnClick = SpecifyfoldersMenuItemClick
      end
      object SpecifylanguagefoldersMenuItem: TMenuItem
        Caption = 'Specify language folders'
        OnClick = SpecifylanguagefoldersMenuItemClick
      end
    end
    object N15: TMenuItem
      Caption = '-'
    end
    object ExitMenuItem: TMenuItem
      Caption = 'Exit'
      OnClick = ExitMenuItemClick
    end
  end
  object ListViewPopupActionBar: TPopupActionBar
    Left = 384
    Top = 24
    object RunMenuItem: TMenuItem
      Caption = 'Run'
      Default = True
      ShortCut = 13
      OnClick = RunMenuItemClick
    end
    object ConfigurationMenuItem: TMenuItem
      Caption = 'Configuration'
      OnClick = ConfigurationMenuItemClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object DownloadarchiveMenuItem: TMenuItem
      Caption = 'Download archive'
      OnClick = DownloadarchiveMenuItemClick
    end
    object DeletearchiveMenuItem: TMenuItem
      Caption = 'Delete archive'
      OnClick = DeletearchiveMenuItemClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object AddtoFavoritesMenuItem: TMenuItem
      Caption = 'Add to Favorites'
      OnClick = AddtoFavoritesMenuItemClick
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object ManualMenuItem: TMenuItem
      Caption = 'Manual'
      Enabled = False
      OnClick = ManualMenuItemClick
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object CreatedesktopshortcutMenuItem: TMenuItem
      Caption = 'Create desktop shortcut'
      OnClick = CreatedesktopshortcutMenuItemClick
    end
    object N10: TMenuItem
      Caption = '-'
    end
    object CustomimagenameMenuItem: TMenuItem
      Caption = 'Custom image name'
      OnClick = CustomimagenameMenuItemClick
    end
    object sepDynamicStart: TMenuItem
      Caption = '-'
    end
  end
  object pmPlatformFilter: TPopupActionBar
    OnPopup = PopupActionBar1Popup
    Left = 769
    Top = 26
  end
end
