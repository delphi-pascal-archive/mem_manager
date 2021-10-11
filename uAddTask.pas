unit uAddTask;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask;

type
  TfmAddTask = class(TForm)
    laName: TLabel;
    edName: TEdit;
    laSize: TLabel;
    meSize: TMaskEdit;
    laBeginning: TLabel;
    meBeginning: TMaskEdit;
    laDuration: TLabel;
    meDuration: TMaskEdit;
    btOK: TButton;
    btCancel: TButton;
    procedure btOKClick(Sender: TObject);
  private
  public
  end;

var
  fmAddTask: TfmAddTask;

implementation

{$R *.DFM}

uses
  uFuncs, uMsgs, uMain;

procedure InformationTaskSizeCanNotBeZero;
begin
  MessageBox(0, 'Размер занимаемой задачей памяти'#13#10'не может быть равен 0.', PChar(sInformationName), MB_ICONASTERISK or MB_TASKMODAL or MB_OK);
end;

procedure InformationTaskSizeCanNotBeMoreThatTotalMemory;
begin
  MessageBox(0, PChar('Размер занимаемой задачей памяти не может'#13#10'быть больше общего объема памяти ('+IntToStr(TotalMemorySize)+').'), PChar(sInformationName), MB_ICONASTERISK or MB_TASKMODAL or MB_OK);
end;

procedure InformationTaskDurationCanNotBeZero;
begin
  MessageBox(0, 'Время работы задачи не'#13#10'может быть равно 0.', PChar(sInformationName), MB_ICONASTERISK or MB_TASKMODAL or MB_OK);
end;

procedure TfmAddTask.btOKClick(Sender: TObject);
var
  TaskSize, TaskDuration: LongWord;
begin
  TaskSize:=StrToInt(ProcessMaskEditString(meSize.Text));
  if TaskSize = 0 then
    begin
      InformationTaskSizeCanNotBeZero;
      fmAddTask.ModalResult:=mrNone;
    end
  else
    if TaskSize > TotalMemorySize then
      begin
        InformationTaskSizeCanNotBeMoreThatTotalMemory;
        fmAddTask.ModalResult:=mrNone;
      end
    else
      begin
        TaskDuration:=StrToInt(ProcessMaskEditString(meDuration.Text));
        if TaskDuration = 0 then
          begin
            InformationTaskDurationCanNotBeZero;
            fmAddTask.ModalResult:=mrNone;
          end;
      end;
end;

end.
 