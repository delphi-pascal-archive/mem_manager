program TestGen;

uses
  Forms,
  uMain in 'uMain.pas' {fmMain};

{$R *.RES}

begin
  Application.Title:='Генератор тестов';
  Application.Initialize;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
