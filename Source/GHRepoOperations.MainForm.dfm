object FrmMain: TFrmMain
  Left = 0
  Top = 0
  Caption = 'FrmMain'
  ClientHeight = 653
  ClientWidth = 1151
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poMainFormCenter
  WindowState = wsMaximized
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlAll: TPanel
    Left = 0
    Top = 0
    Width = 1151
    Height = 653
    Align = alClient
    TabOrder = 0
    object pnlTop: TPanel
      Left = 1
      Top = 1
      Width = 1149
      Height = 232
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object pnlMainOptions: TPanel
        Left = 0
        Top = 0
        Width = 1149
        Height = 73
        Align = alTop
        TabOrder = 0
        object lblOrganizations: TLabel
          Left = 10
          Top = 13
          Width = 76
          Height = 13
          Caption = 'lblOrganizations'
        end
        object lblTopics: TLabel
          Left = 271
          Top = 13
          Width = 40
          Height = 13
          Caption = 'lblTopics'
        end
        object cbxOrganizations: TComboBox
          Left = 10
          Top = 32
          Width = 255
          Height = 21
          TabOrder = 0
          Text = 'cbxOrganizations'
          Items.Strings = (
            'centrosoftware-dev-custom'
            'centrosoftware-dev')
        end
        object cbxTopics: TComboBox
          Left = 271
          Top = 32
          Width = 255
          Height = 21
          TabOrder = 1
          Text = 'cbxTopics'
          Items.Strings = (
            'tools'
            'addon'
            'clienti'
            'verticali'
            'test')
        end
        object btnRepoList: TButton
          Left = 532
          Top = 30
          Width = 75
          Height = 25
          Caption = 'btnRepoList'
          TabOrder = 2
          OnClick = btnRepoListClick
        end
      end
      object pcFunctions: TPageControl
        Left = 0
        Top = 73
        Width = 1149
        Height = 159
        ActivePage = tbsPushNewTag
        Align = alClient
        TabHeight = 30
        TabOrder = 1
        object tbsPushNewTag: TTabSheet
          Caption = 'tbsPushNewTag'
          object rgNewMainTag: TRadioGroup
            AlignWithMargins = True
            Left = 233
            Top = 3
            Width = 207
            Height = 113
            Margins.Left = 6
            Align = alLeft
            Caption = 'rgNewMainTag'
            Items.Strings = (
              'Increase Minor Number'
              'Increase Fix Number')
            TabOrder = 1
            OnClick = rgNewMainTagClick
            ExplicitLeft = 234
            ExplicitHeight = 105
          end
          object rgOptionNewMainTag: TRadioGroup
            AlignWithMargins = True
            Left = 6
            Top = 3
            Width = 218
            Height = 113
            Margins.Left = 6
            Align = alLeft
            Caption = 'rgOptionNewMainTag'
            Items.Strings = (
              'NewMainTagAllRepo'
              'NewMainTagSelectedNodes')
            TabOrder = 0
            OnClick = rgOptionNewMainTagClick
            ExplicitLeft = 10
          end
          object pnlNewTagButtons: TPanel
            AlignWithMargins = True
            Left = 449
            Top = 3
            Width = 240
            Height = 113
            Margins.Left = 6
            Align = alLeft
            BevelOuter = bvNone
            TabOrder = 2
            object btnNewTagExecute: TButton
              AlignWithMargins = True
              Left = 3
              Top = 34
              Width = 234
              Height = 25
              Align = alTop
              Caption = 'btnNewTagExecute'
              TabOrder = 1
              OnClick = btnNewTagExecuteClick
              ExplicitLeft = 8
              ExplicitTop = 40
              ExplicitWidth = 121
            end
            object btnNewTagClean: TButton
              AlignWithMargins = True
              Left = 3
              Top = 3
              Width = 234
              Height = 25
              Align = alTop
              Caption = 'btnNewTagClean'
              TabOrder = 0
              OnClick = btnNewTagCleanClick
              ExplicitLeft = -3
              ExplicitTop = -3
            end
          end
        end
      end
    end
    object pnlMain: TPanel
      Left = 1
      Top = 233
      Width = 1149
      Height = 419
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object tvMain: TAdvTreeView
        Left = 0
        Top = 0
        Width = 1149
        Height = 376
        Align = alClient
        ParentDoubleBuffered = False
        DoubleBuffered = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        Stroke.Color = 11119017
        Groups = <>
        GroupsAppearance.TopSize = 50.000000000000000000
        GroupsAppearance.BottomSize = 50.000000000000000000
        GroupsAppearance.TopFill.Kind = gfkNone
        GroupsAppearance.BottomFill.Kind = gfkNone
        GroupsAppearance.TopFont.Charset = DEFAULT_CHARSET
        GroupsAppearance.TopFont.Color = 4539717
        GroupsAppearance.TopFont.Height = -11
        GroupsAppearance.TopFont.Name = 'Segoe UI'
        GroupsAppearance.TopFont.Style = []
        GroupsAppearance.BottomFont.Charset = DEFAULT_CHARSET
        GroupsAppearance.BottomFont.Color = 4539717
        GroupsAppearance.BottomFont.Height = -11
        GroupsAppearance.BottomFont.Name = 'Segoe UI'
        GroupsAppearance.BottomFont.Style = []
        Columns = <>
        Nodes = <>
        ColumnsAppearance.StretchColumn = 0
        ColumnsAppearance.TopSize = 36.000000000000000000
        ColumnsAppearance.BottomSize = 25.000000000000000000
        ColumnsAppearance.TopFont.Charset = DEFAULT_CHARSET
        ColumnsAppearance.TopFont.Color = 4539717
        ColumnsAppearance.TopFont.Height = -13
        ColumnsAppearance.TopFont.Name = 'Segoe UI'
        ColumnsAppearance.TopFont.Style = [fsBold]
        ColumnsAppearance.BottomFont.Charset = DEFAULT_CHARSET
        ColumnsAppearance.BottomFont.Color = 4539717
        ColumnsAppearance.BottomFont.Height = -11
        ColumnsAppearance.BottomFont.Name = 'Segoe UI'
        ColumnsAppearance.BottomFont.Style = []
        ColumnsAppearance.TopFill.Color = 16380654
        ColumnsAppearance.BottomFill.Kind = gfkNone
        ColumnsAppearance.BottomFill.Color = 16380654
        ColumnsAppearance.TopStroke.Kind = gskNone
        NodesAppearance.ShowFocus = False
        NodesAppearance.ExpandWidth = 18.000000000000000000
        NodesAppearance.ExpandHeight = 18.000000000000000000
        NodesAppearance.LevelIndent = 20.000000000000000000
        NodesAppearance.FixedHeight = 25.000000000000000000
        NodesAppearance.VariableMinimumHeight = 25.000000000000000000
        NodesAppearance.Font.Charset = DEFAULT_CHARSET
        NodesAppearance.Font.Color = 8026746
        NodesAppearance.Font.Height = -12
        NodesAppearance.Font.Name = 'Segoe UI'
        NodesAppearance.Font.Style = []
        NodesAppearance.TitleFont.Charset = DEFAULT_CHARSET
        NodesAppearance.TitleFont.Color = clBlack
        NodesAppearance.TitleFont.Height = -11
        NodesAppearance.TitleFont.Name = 'Segoe UI'
        NodesAppearance.TitleFont.Style = []
        NodesAppearance.SelectedFontColor = 4539717
        NodesAppearance.ExtendedFontColor = 4539717
        NodesAppearance.SelectedFill.Color = 16578806
        NodesAppearance.SelectedStroke.Color = 15702829
        NodesAppearance.SelectedStroke.Width = 2.000000000000000000
        NodesAppearance.ExtendedFont.Charset = DEFAULT_CHARSET
        NodesAppearance.ExtendedFont.Color = clWindowText
        NodesAppearance.ExtendedFont.Height = -11
        NodesAppearance.ExtendedFont.Name = 'Segoe UI'
        NodesAppearance.ExtendedFont.Style = []
        NodesAppearance.ExpandNodeIcon.Data = {
          0954506E67496D61676589504E470D0A1A0A0000000D494844520000000B0000
          000B080200000026CEE071000000017352474200AECE1CE90000000467414D41
          0000B18F0BFC6105000000097048597300000EC300000EC301C76FA864000000
          1874455874536F667477617265007061696E742E6E657420342E302E36FC8C63
          DF000000334944415478DA63ACAEAD66C00B18812A5A9A5A7049D7D4D5A0ABF0
          F6F3DEBA692B8D540025301D01544A6F7710080FFC610A005ADF3FFDA83755DB
          0000000049454E44AE426082}
        NodesAppearance.CollapseNodeIcon.Data = {
          0954506E67496D61676589504E470D0A1A0A0000000D494844520000000B0000
          000B080200000026CEE071000000017352474200AECE1CE90000000467414D41
          0000B18F0BFC6105000000097048597300000EC300000EC301C76FA864000000
          1874455874536F667477617265007061696E742E6E657420342E302E36FC8C63
          DF0000002C4944415478DA63ACAEAD66C00B18812A5A9A5A7049D7D4D5D05B85
          B79F37B2DCD64D5B07C61DF854E00F53005DBC2DFDD89D52A70000000049454E
          44AE426082}
        NodesAppearance.ExpandNodeIconLarge.Data = {
          0954506E67496D61676589504E470D0A1A0A0000000D49484452000000160000
          001608020000004BD6FB6C000000017352474200AECE1CE90000000467414D41
          0000B18F0BFC6105000000097048597300000EC300000EC301C76FA864000000
          1874455874536F667477617265007061696E742E6E657420342E302E36FC8C63
          DF000000404944415478DA63ACAEAD66A00C3052CD8896A6163234D7D4D5D0C5
          086F3F6F20B975D3D6512306C40888066200C450DA183138C262D488C1535E50
          02A8600400AA8F7FF987EC13380000000049454E44AE426082}
        NodesAppearance.CollapseNodeIconLarge.Data = {
          0954506E67496D61676589504E470D0A1A0A0000000D49484452000000160000
          001608020000004BD6FB6C0000000467414D410000B18F0BFC61050000000970
          48597300000EC200000EC20115284A800000001874455874536F667477617265
          007061696E742E6E657420342E302E36FC8C63DF000000384944415478DA63AC
          AEAD66A00C3052CD8896A6163234D7D4D58C1A31628CF0F6F3C6A36DEBA6AD74
          31627084C5A81183C1084A00158C000071065BF9A44132100000000049454E44
          AE426082}
        GlobalFont.Name = 'Segoe UI'
        OnAfterUnCheckNode = tvMainAfterUnCheckNode
        OnAfterCheckNode = tvMainAfterCheckNode
      end
      object pbLoadData: TProgressBar
        Left = 0
        Top = 376
        Width = 1149
        Height = 24
        Align = alBottom
        TabOrder = 1
        Visible = False
      end
      object sbRepos: TStatusBar
        Left = 0
        Top = 400
        Width = 1149
        Height = 19
        Panels = <
          item
            Width = 50
          end>
      end
    end
  end
end
