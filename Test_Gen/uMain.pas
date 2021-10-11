unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TTaskQueueRec = record
    Name, Size, Beginning, Duration: String;
  end;


  TfmMain = class(TForm)
    btGenerateAndSave: TButton;
    sdMain: TSaveDialog;
    procedure btGenerateAndSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
  public
  end;

var
  fmMain: TfmMain;

implementation

{$R *.DFM}

procedure Sort(var A: array of TTaskQueueRec);

  procedure QuickSort(var A: array of TTaskQueueRec; iLo, iHi: Integer);
  var
    Lo, Hi: Integer;
    Mid, T: TTaskQueueRec;
  begin
    Lo := iLo;
    Hi := iHi;
    Mid := A[(Lo + Hi) div 2];
    repeat
      while StrToInt(A[Lo].Beginning) < StrToInt(Mid.Beginning) do Inc(Lo);
      while StrToInt(A[Hi].Beginning) > StrToInt(Mid.Beginning) do Dec(Hi);
      if Lo <= Hi then
      begin
        T := A[Lo];
        A[Lo] := A[Hi];
        A[Hi] := T;
        Inc(Lo);
        Dec(Hi);
      end;
    until Lo > Hi;
    if Hi > iLo then QuickSort(A, iLo, Hi);
    if Lo < iHi then QuickSort(A, Lo, iHi);
  end;

begin
  QuickSort(A, Low(A), High(A));
end;

procedure TfmMain.btGenerateAndSaveClick(Sender: TObject);
var
  TotalTasks, i: Integer;
  TaskQueueArr: array of TTaskQueueRec;
begin
  if sdMain.Execute then
    begin
      AssignFile(Output, sdMain.FileName);
      Rewrite(Output);

      TotalTasks:=Random(20) + 30;

      WriteLn(5, ' ', 132, ' ', TotalTasks + 1);

      SetLength(TaskQueueArr, TotalTasks);

      for i:=0 to TotalTasks - 1 do
        begin
          TaskQueueArr[i].Name:='Задача '+IntToStr(i);
          TaskQueueArr[i].Size:=IntToStr(Random(30)+1);
          TaskQueueArr[i].Beginning:=IntToStr(Random(140)+10);
          TaskQueueArr[i].Duration:=IntToStr(Random(50)+1);
        end;

      Sort(TaskQueueArr);

      for i:=0 to TotalTasks - 1 do
        begin
          WriteLn(TaskQueueArr[i].Name);
          WriteLn(TaskQueueArr[i].Size);
          WriteLn(TaskQueueArr[i].Beginning);
          WriteLn(TaskQueueArr[i].Duration);
        end;


      TaskQueueArr:=nil;

      CloseFile(Output);
    end;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  Randomize;
end;

end.
