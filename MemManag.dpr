program MemManag;

uses
  Forms,
  uMain in 'uMain.pas' {fmMain},
  uAbout in 'uAbout.pas' {fmAbout},
  uCreate in 'uCreate.pas' {fmCreate},
  uFuncs in 'uFuncs.pas',
  uAddTask in 'uAddTask.pas' {fmAddTask},
  uMsgs in 'uMsgs.pas',
  uInformation in 'uInformation.pas' {fmInformation};

{$R *.RES}

begin
  Application.Title:='”правление распределением динамической пам€ти (2)';
  Application.Initialize;
  Application.CreateForm(TfmMain, fmMain);
  Application.CreateForm(TfmInformation, fmInformation);
  Application.Run;
end.
