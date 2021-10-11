object fmAddTask: TfmAddTask
  Left = 296
  Top = 215
  BorderStyle = bsDialog
  Caption = 'Добавить задачу'
  ClientHeight = 143
  ClientWidth = 313
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object laName: TLabel
    Left = 12
    Top = 8
    Width = 53
    Height = 13
    Caption = 'На&звание:'
    FocusControl = edName
  end
  object laSize: TLabel
    Left = 216
    Top = 8
    Width = 42
    Height = 13
    Caption = 'Раз&мер:'
    FocusControl = meSize
  end
  object laBeginning: TLabel
    Left = 12
    Top = 56
    Width = 40
    Height = 13
    Caption = 'Н&ачало:'
    FocusControl = meBeginning
  end
  object laDuration: TLabel
    Left = 124
    Top = 56
    Width = 76
    Height = 13
    Caption = 'Д&лительность:'
    FocusControl = meDuration
  end
  object edName: TEdit
    Left = 20
    Top = 28
    Width = 181
    Height = 21
    TabOrder = 0
  end
  object meSize: TMaskEdit
    Left = 224
    Top = 28
    Width = 69
    Height = 21
    EditMask = '9999;0;_'
    MaxLength = 4
    TabOrder = 1
    Text = '1'
  end
  object meBeginning: TMaskEdit
    Left = 20
    Top = 76
    Width = 69
    Height = 21
    EditMask = '9999;0;_'
    MaxLength = 4
    TabOrder = 2
    Text = '0'
  end
  object meDuration: TMaskEdit
    Left = 132
    Top = 76
    Width = 69
    Height = 21
    EditMask = '9999;0;_'
    MaxLength = 4
    TabOrder = 3
    Text = '1'
  end
  object btOK: TButton
    Left = 77
    Top = 112
    Width = 73
    Height = 23
    Caption = 'ОК'
    Default = True
    ModalResult = 1
    TabOrder = 4
    OnClick = btOKClick
  end
  object btCancel: TButton
    Left = 163
    Top = 112
    Width = 73
    Height = 23
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 5
  end
end
