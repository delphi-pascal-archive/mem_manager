unit uInformation;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TfmInformation = class(TForm)
    laRefusals: TLabel;
    laMemoryUsed: TLabel;
  private
  public
  end;

var
  fmInformation: TfmInformation;

implementation

{$R *.DFM}

end.
