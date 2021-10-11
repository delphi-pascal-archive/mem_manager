object fmCreate: TfmCreate
  Left = 266
  Top = 159
  BorderStyle = bsDialog
  Caption = 'Создать проект'
  ClientHeight = 97
  ClientWidth = 301
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
  object laMinAddress: TLabel
    Left = 12
    Top = 8
    Width = 102
    Height = 13
    Caption = 'Наи&меньший адрес:'
    FocusControl = meMinAddress
  end
  object laMaxAddress: TLabel
    Left = 156
    Top = 8
    Width = 100
    Height = 13
    Caption = 'Наи&больший адрес:'
    FocusControl = meMaxAddress
  end
  object meMinAddress: TMaskEdit
    Left = 20
    Top = 28
    Width = 117
    Height = 21
    EditMask = '9999;0;_'
    MaxLength = 4
    TabOrder = 0
    Text = '0'
  end
  object meMaxAddress: TMaskEdit
    Left = 164
    Top = 28
    Width = 117
    Height = 21
    EditMask = '9999;0;_'
    MaxLength = 4
    TabOrder = 1
    Text = '0'
  end
  object btOK: TButton
    Left = 71
    Top = 64
    Width = 73
    Height = 23
    Caption = 'ОК'
    Default = True
    ModalResult = 1
    TabOrder = 2
    OnClick = btOKClick
  end
  object btCancel: TButton
    Left = 157
    Top = 64
    Width = 73
    Height = 23
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 3
  end
end
