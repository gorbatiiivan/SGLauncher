object HelpForm: THelpForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'About'
  ClientHeight = 441
  ClientWidth = 635
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  ShowHint = True
  OnClose = FormClose
  TextHeight = 13
  object HELPFORM_PAGECTRL1: TPageControl
    Left = 0
    Top = 0
    Width = 635
    Height = 441
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    TabStop = False
    object TabSheet1: TTabSheet
      Caption = 'About'
      object Label1: TLabel
        Left = 0
        Top = 0
        Width = 627
        Height = 49
        Align = alTop
        Alignment = taCenter
        AutoSize = False
        Caption = 'Start Game Launcher'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -32
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label2: TLabel
        Left = 368
        Top = 78
        Width = 241
        Height = 25
        AutoSize = False
        Caption = 'Release date:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object Label3: TLabel
        Left = 368
        Top = 118
        Width = 241
        Height = 91
        AutoSize = False
        Caption = 
          'Start Game Launcher is a portable open source application for Wi' +
          'ndows that can easily run eXo collections.'
        WordWrap = True
      end
      object PaintBox1: TPaintBox
        Left = 57
        Top = 78
        Width = 260
        Height = 260
        OnClick = PaintBox1Click
        OnPaint = PaintBox1Paint
      end
      object Label4: TLabel
        Left = 57
        Top = 342
        Width = 260
        Height = 51
        AutoSize = False
        Caption = 
          'To control the snake, press WASD.'#13#10'Press the Pause key to pause ' +
          'or resume the game.'#13#10'Space to restart the game after it ends.'
        Visible = False
        WordWrap = True
      end
      object Label5: TLabel
        Left = 368
        Top = 325
        Width = 241
        Height = 13
        Cursor = crHandPoint
        Hint = 'https://sglauncher.sourceforge.io/'
        AutoSize = False
        Caption = 'SGLauncher on the SourceForge.net'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsUnderline]
        ParentFont = False
        OnClick = Label5Click
      end
      object Label6: TLabel
        Left = 368
        Top = 248
        Width = 241
        Height = 71
        AutoSize = False
        Caption = 
          'Copyright '#169' 2026 G. Ivan'#13#10'This application is distributed withou' +
          't any warranties.'
        Layout = tlBottom
        WordWrap = True
      end
    end
    object TabSheet4: TTabSheet
      Caption = 'License'
      ImageIndex = 3
      object Memo1: TMemo
        Left = 0
        Top = 0
        Width = 627
        Height = 413
        Align = alClient
        Alignment = taCenter
        Lines.Strings = (
          'MIT License'
          ''
          'Copyright (c) 2026 G. Ivan'
          ''
          
            'Permission is hereby granted, free of charge, to any person obta' +
            'ining a copy'
          
            'of this software and associated documentation files (the "Softwa' +
            're"), to deal'
          
            'in the Software without restriction, including without limitatio' +
            'n the rights'
          
            'to use, copy, modify, merge, publish, distribute, sublicense, an' +
            'd/or sell'
          
            'copies of the Software, and to permit persons to whom the Softwa' +
            're is'
          'furnished to do so, subject to the following conditions:'
          ''
          
            'The above copyright notice and this permission notice shall be i' +
            'ncluded in all'
          'copies or substantial portions of the Software.'
          ''
          
            'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, ' +
            'EXPRESS OR'
          
            'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANT' +
            'ABILITY,'
          
            'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVEN' +
            'T SHALL THE'
          
            'AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR' +
            ' OTHER'
          
            'LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ' +
            'ARISING FROM,'
          
            'OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DE' +
            'ALINGS IN THE'
          'SOFTWARE.')
        ReadOnly = True
        TabOrder = 0
      end
    end
  end
end
