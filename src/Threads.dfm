object fThreads: TfThreads
  Left = 0
  Top = 0
  Caption = 'fThreads'
  ClientHeight = 298
  ClientWidth = 529
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 69
    Top = 11
    Width = 149
    Height = 13
    Caption = 'N'#186' de threads a serem criadas:'
  end
  object Label2: TLabel
    Left = 11
    Top = 38
    Width = 207
    Height = 13
    Caption = 'Tempo m'#225'x de espera entre cada itera'#231#227'o:'
  end
  object Label3: TLabel
    Left = 351
    Top = 38
    Width = 65
    Height = 13
    Caption = 'milissegundos'
  end
  object ProgressBar: TProgressBar
    AlignWithMargins = True
    Left = 3
    Top = 278
    Width = 523
    Height = 17
    Align = alBottom
    TabOrder = 3
  end
  object btStart: TButton
    Left = 8
    Top = 65
    Width = 513
    Height = 25
    Caption = 'Start'
    TabOrder = 2
    OnClick = btStartClick
  end
  object Edit_numThreads: TEdit
    Left = 224
    Top = 8
    Width = 121
    Height = 21
    TabOrder = 0
    OnExit = Edit_numThreadsExit
  end
  object Memo: TMemo
    Left = 8
    Top = 96
    Width = 513
    Height = 175
    Lines.Strings = (
      'Memo')
    ReadOnly = True
    TabOrder = 4
  end
  object Edit_tempoEspera: TEdit
    Left = 224
    Top = 35
    Width = 121
    Height = 21
    TabOrder = 1
    OnExit = Edit_tempoEsperaExit
  end
end
