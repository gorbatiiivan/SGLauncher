object SGLMainForm: TSGLMainForm
  Left = 0
  Top = 0
  Margins.Left = 14
  ClientHeight = 750
  ClientWidth = 934
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
    Width = 928
    Height = 701
    Margins.Top = 6
    Align = alClient
    RaggedRight = True
    TabHeight = 25
    TabOrder = 0
    OnChange = TabControl1Change
    object Splitter1: TSplitter
      Left = 313
      Top = 6
      Width = 7
      Height = 691
      OnAfterResize = FormResize
    end
    object Panel1: TPanel
      Left = 320
      Top = 6
      Width = 604
      Height = 691
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      object Splitter2: TSplitter
        Left = 0
        Top = 421
        Width = 604
        Height = 7
        Cursor = crVSplit
        Align = alTop
        OnAfterResize = FormResize
        ExplicitWidth = 631
      end
      object Panel2: TPanel
        Left = 0
        Top = 428
        Width = 604
        Height = 263
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object ScreenShotImage: TImage
          AlignWithMargins = True
          Left = 97
          Top = 3
          Width = 410
          Height = 134
          Margins.Left = 55
          Margins.Right = 55
          Align = alClient
          Center = True
          Proportional = True
          Stretch = True
          OnClick = ScreenShotImageClick
          ExplicitLeft = 100
          ExplicitTop = 19
        end
        object NextImgBtn: TSpeedButton
          Left = 562
          Top = 0
          Width = 42
          Height = 140
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
          Height = 140
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
          Top = 140
          Width = 604
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
          Top = 150
          Width = 494
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
        AlignWithMargins = True
        Left = 6
        Top = 6
        Width = 592
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
          Width = 572
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
          ExplicitTop = 223
          ExplicitWidth = 608
        end
        object InfoPanel: TPanel
          Left = 0
          Top = 0
          Width = 592
          Height = 200
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          object TitleLabel: TLabel
            AlignWithMargins = True
            Left = 14
            Top = 3
            Width = 575
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
            Width = 575
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
            Width = 575
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
            Width = 575
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
            Width = 575
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
            Width = 575
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
            Width = 575
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
            Width = 575
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
        Top = 62
        Width = 309
        Height = 629
        Align = alClient
        BorderStyle = bsNone
        Columns = <
          item
            Width = 514
          end
          item
          end>
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Segoe UI'
        Font.Style = []
        FlatScrollBars = True
        OwnerData = True
        ReadOnly = True
        RowSelect = True
        ParentFont = False
        PopupMenu = ListViewPopupActionBar
        ShowColumnHeaders = False
        TabOrder = 2
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
        Left = 0
        Top = 0
        Width = 309
        Height = 34
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object ComboBox1: TComboBox
          Left = 0
          Top = 2
          Width = 154
          Height = 28
          Style = csDropDownList
          DropDownCount = 35
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
        object ComboBox2: TComboBox
          Left = 160
          Top = 2
          Width = 141
          Height = 28
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
          TabOrder = 1
          OnChange = ComboBox2Change
        end
        object PlatformBtn: TButton
          Left = 264
          Top = 2
          Width = 39
          Height = 28
          Hint = 'Filter by Platform'
          Caption = #9776
          DropDownMenu = pmPlatformFilter
          Enabled = False
          Style = bsSplitButton
          TabOrder = 2
          OnClick = PlatformBtnClick
        end
      end
      object Edit1: TEdit
        Left = 0
        Top = 34
        Width = 309
        Height = 28
        Align = alTop
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
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 934
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
      object MultilinetabsMenuItem: TMenuItem
        Caption = 'Multi line tabs'
        OnClick = MultilinetabsMenuItemClick
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
        object ShowImageonHoverMenuItem: TMenuItem
          Caption = 'Show Image on Hover'
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
