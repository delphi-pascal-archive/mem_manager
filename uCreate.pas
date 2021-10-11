unit uCreate;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask;

type
  TfmCreate = class(TForm)
    meMinAddress: TMaskEdit;
    laMinAddress: TLabel;
    meMaxAddress: TMaskEdit;
    laMaxAddress: TLabel;
    btOK: TButton;
    btCancel: TButton;
    procedure btOKClick(Sender: TObject);
  private
  public
  end;

var
  fmCreate: TfmCreate;

implementation

{$R *.DFM}

uses
  uFuncs, uMsgs;

procedure InformationMaxCanNotBeLessThatMin;
begin
  MessageBox(0, 'Максимальный адрес не может'#13#10'быть меньше минимального.', PChar(sInformationName), MB_ICONASTERISK or MB_TASKMODAL or MB_OK);
end;

procedure TfmCreate.btOKClick(Sender: TObject);
var
  Value1, Value2: LongWord;
begin
  Value1:=StrToInt(ProcessMaskEditString(meMinAddress.Text));
  Value2:=StrToInt(ProcessMaskEditString(meMaxAddress.Text));
  if Value2 < Value1 then
    begin
      InformationMaxCanNotBeLessThatMin;
      fmCreate.ModalResult:=mrNone;
    end;
end;

end.
