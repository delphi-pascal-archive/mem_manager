unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ComCtrls, ToolWin, ExtCtrls, StdCtrls, ImgList, ActnList;

type
  TMemUnit = LongWord;

  PFreeMemRec = ^TFreeMemRec;
  TFreeMemRec = record
    Next: PFreeMemRec;
    Address, Size: TMemUnit;
  end;

  TTaskQueueRec = record
    Name, Size, Beginning, Duration: String;
  end;

  TfmMain = class(TForm)
    mmMain: TMainMenu;
    miFile: TMenuItem;
    miExit: TMenuItem;
    stbMain: TStatusBar;
    miHelp: TMenuItem;
    miAbout: TMenuItem;
    cbrMain: TCoolBar;
    tbMain: TToolBar;
    tbtCreate: TToolButton;
    pnMemoryMap: TPanel;
    pnMemoryMapHeader: TPanel;
    scbMemoryMap: TScrollBox;
    Splitter1: TSplitter;
    pnSpeed: TPanel;
    laSpeed: TLabel;
    trbSpeed: TTrackBar;
    pnTopRight: TPanel;
    Splitter2: TSplitter;
    pnTaskQueue: TPanel;
    pnTaskQueueHeader: TPanel;
    lvTaskQueue: TListView;
    pnFreeMemList: TPanel;
    Splitter3: TSplitter;
    pnFreeMemListHeader: TPanel;
    lvFreeMemList: TListView;
    pnWorkingTasks: TPanel;
    pnWorkingTasksHeader: TPanel;
    lvWorkingTasks: TListView;
    imgMemoryMap: TImage;
    ilMain: TImageList;
    alMain: TActionList;
    actCreate: TAction;
    miSeparator1: TMenuItem;
    miCreate: TMenuItem;
    tbtSave: TToolButton;
    tbtSeparator1: TToolButton;
    actOpen: TAction;
    actSave: TAction;
    miEdit: TMenuItem;
    actAddTask: TAction;
    actDeleteTask: TAction;
    miAddTask: TMenuItem;
    miDeleteTask: TMenuItem;
    tbtAddTask: TToolButton;
    tbtDeleteTask: TToolButton;
    tbtSeparator2: TToolButton;
    miRun: TMenuItem;
    actStart: TAction;
    tbtStart: TToolButton;
    actPause: TAction;
    actStop: TAction;
    tbtPause: TToolButton;
    tbtStop: TToolButton;
    miStart: TMenuItem;
    miPause: TMenuItem;
    miStop: TMenuItem;
    sdMain: TSaveDialog;
    odMain: TOpenDialog;
    miSave: TMenuItem;
    miOpen: TMenuItem;
    tbtSeparator3: TToolButton;
    miView: TMenuItem;
    tbtInformation: TToolButton;
    actInformation: TAction;
    miInformation: TMenuItem;
    miTask: TMenuItem;
    procedure FormDestroy(Sender: TObject);
    procedure miExitClick(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure pnTopRightResize(Sender: TObject);
    procedure actCreateExecute(Sender: TObject);
    procedure stbMainResize(Sender: TObject);
    procedure scbMemoryMapResize(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actAddTaskExecute(Sender: TObject);
    procedure actDeleteTaskExecute(Sender: TObject);
    procedure lvTaskQueueSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure actStartExecute(Sender: TObject);
    procedure actPauseExecute(Sender: TObject);
    procedure actStopExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actInformationExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure miTaskClick(Sender: TObject);
  private
    procedure Delay;
    procedure FilllvFreeMemList(FreeMemList: PFreeMemRec);
    procedure ResetControls;
    procedure SetControlsEnabled(bEnabled: boolean);
    procedure SetStatusOnOpenOrCreateProject;
    procedure SetStatusOnStop;
    procedure RefreshInformation;
    procedure SimulationLoop;
    procedure SavelvTaskQueueItems;
    procedure RestorelvTaskQueueItems;
  public
  end;

var
  fmMain: TfmMain;

  MinAddress, MaxAddress, TotalMemorySize: TMemUnit;
  FreeMemList: PFreeMemRec;

  TasksCounter: Integer = 1;

  CurTime: DWORD;
//  DelayInterval: DWORD;
  TotalRefusals: DWORD = 0;
  bWasAccounted: boolean = false;

  bRunning: boolean = false;
  bStopped: boolean = true;

  TaskQueueArr: array of TTaskQueueRec;

implementation

{$R *.DFM}

uses
  uAbout, uCreate, uFuncs, uAddTask, uInformation;

const
  sCurTimeName='Время: %d';

procedure DrawMemoryStatus(FreeMemList: PFreeMemRec; Image: TImage; PaintAreaWidth, PaintAreaHeight: Integer; ScrollBarVisible: boolean; FreeMemColor, AllocatedMemColor: TColor);
var
  Bitmap: TBitmap;
  CellsPerLine: Integer;
  R: TRect;
  P: PFreeMemRec;
  FromAddress, ToAddress: TMemUnit;
  i: Integer;

  procedure DrawMemoryCell(Address: TMemUnit; Color: TColor);
  begin
    Address:=(Address - MinAddress){ + 1};

    Bitmap.Canvas.Brush.Color:=clBlack;
    R.TopLeft.x:=1 + ((Address mod CellsPerLine) * 8);
    R.TopLeft.y:=1 + ((Address div CellsPerLine) * 10);
    R.BottomRight.x:=R.TopLeft.x + 7;
    R.BottomRight.y:=R.TopLeft.y + 9;
    Bitmap.Canvas.FillRect(R);

    Bitmap.Canvas.Brush.Color:=Color;
    Inc(R.TopLeft.x);
    Inc(R.TopLeft.y);
    Dec(R.BottomRight.x);
    Dec(R.BottomRight.y);
    Bitmap.Canvas.FillRect(R);
  end;

begin
  Bitmap:=TBitmap.Create;
  try
    if (PaintAreaWidth div 8) * ((PaintAreaHeight - 1) div 10) < TotalMemorySize then
      if not ScrollBarVisible then
        Dec(PaintAreaWidth, GetSystemMetrics(SM_CYVSCROLL));
    CellsPerLine:=PaintAreaWidth div 8;
    PaintAreaHeight:=(TotalMemorySize div (CellsPerLine)) * 10;
    Inc(PaintAreaHeight);
    if TotalMemorySize mod CellsPerLine <> 0 then
      Inc(PaintAreaHeight, 10);
    Bitmap.Width:=PaintAreaWidth;
    Bitmap.Height:=PaintAreaHeight;

    Bitmap.Canvas.Brush.Color:=clWhite;
    R.TopLeft.x:=0;
    R.TopLeft.y:=0;
    R.BottomRight.x:=PaintAreaWidth;
    R.BottomRight.y:=PaintAreaWidth;
    Bitmap.Canvas.FillRect(R);

    FromAddress:=MinAddress;

    P:=FreeMemList;
    while P <> nil do
      begin
        ToAddress:=P^.Address - 1;
        for i:=FromAddress to ToAddress do
          DrawMemoryCell(i, AllocatedMemColor);
        FromAddress:=P^.Address;
        ToAddress:=P^.Address + P^.Size - 1;
        for i:=FromAddress to ToAddress do
          DrawMemoryCell(i, FreeMemColor);
        FromAddress:=ToAddress + 1;

        P:=P^.Next;
      end;

    for i:=FromAddress to MaxAddress do
      DrawMemoryCell(i, AllocatedMemColor);

    Image.Picture.Assign(Bitmap);
  finally
    Bitmap.Free;
  end;
end;

procedure FreeList(var FirstItem: PFreeMemRec);
var
  NextItem: PFreeMemRec;
begin
  while FirstItem <> nil do
    begin
      NextItem:=FirstItem^.Next;
      Dispose(FirstItem);
      FirstItem:=NextItem;
    end;
end;

procedure ResetFreeMemList(var FreeMemList: PFreeMemRec);
begin
  FreeList(FreeMemList);
  New(FreeMemList);
  FreeMemList^.Address:=MinAddress;
  FreeMemList^.Size:=TotalMemorySize;
  FreeMemList^.Next:=nil;
end;

procedure TfmMain.Delay;
var
  StartTime: DWORD;
begin
  StartTime:=GetTickCount;
  while (GetTickCount - StartTime < 1000 div (trbSpeed.Position + 1)) and (bRunning) do
    Application.ProcessMessages;
end;

function FindAndAllocateBlock(var AvailFreeMemList: PFreeMemRec; Size: TMemUnit; var Address: TMemUnit): boolean;
var
  P, Q, L, QP: PFreeMemRec;

  procedure AllocateBlock(var Q: PFreeMemRec);
  var
    K: TMemUnit;
    P: PFreeMemRec;
  begin
    K:=Q^.Size - Size;

    Address:=Q^.Address;
    if K = 0 then
      begin
        P:=Q^.Next;
        Dispose(Q);
        Q:=P;
      end
    else
      begin
        Q^.Address:=Q^.Address+Size;
        Q^.Size:=K;
      end;

    Result:=true;
  end;

begin
  Q:=nil;

  P:=FreeMemList;
  while (P <> nil) do
    begin
      if (P^.Size >= Size) then
        if Q = nil then
          begin
            Q:=P;
            QP:=L;
          end
        else
          if (P^.Size < Q^.Size) then
            begin
              Q:=P;
              QP:=L;
            end;

      L:=P;
      P:=P^.Next;
    end;

  if Q = nil then
    Result:=false
  else
    if Q = FreeMemList then
      AllocateBlock(FreeMemList)
    else
      AllocateBlock(QP^.Next);
end;

function FreeBlock(var AvailFreeMemList: PFreeMemRec; P0Address, P0Size: TMemUnit): PFreeMemRec;
var
  P, Q: PFreeMemRec;
begin
  New(Result);
  Result^.Address:=P0Address;
  Result^.Size:=P0Size;

  Q:=nil;
  P:=AvailFreeMemList;

  while (P <> nil) and (P^.Address <= Result^.Address) do
    begin
      Q:=P;
      P:=P^.Next;
    end;
  if (P <> nil) and (Result^.Address + Result^.Size = P^.Address) then
    begin
      Result^.Size:=Result^.Size + P^.Size;
      Result^.Next:=P^.Next;
      Dispose(P);
    end
  else
    Result^.Next:=P;

  if (Q <> nil) and (Q^.Address + Q^.Size = Result^.Address) then
    begin
      Q^.Size:=Q^.Size + Result^.Size;
      Q^.Next:=Result^.Next;

      Dispose(Result);
      Result:=Q;
    end
  else
    if Q = nil then
      AvailFreeMemList:=Result
    else
      Q^.Next:=Result;
end;

function GetMemoryUsedPercents: String;
var
  P: PFreeMemRec;
  TotalMemoryUsed: TMemUnit;
begin
  P:=FreeMemList;

  TotalMemoryUsed:=TotalMemorySize;

  while P <> nil do
    begin
      Dec(TotalMemoryUsed, P^.Size);

      P:=P^.Next;
    end;
  Result:=IntToStr(Round(TotalMemoryUsed * 100 / TotalMemorySize))+'%';
end;

procedure TfmMain.FilllvFreeMemList(FreeMemList: PFreeMemRec);
begin
  lvFreeMemList.Items.Clear;
  while FreeMemList <> nil do
    begin
      with lvFreeMemList.Items.Add do
        begin
          Caption:=IntToStr(FreeMemList^.Address);
          SubItems.Add(IntToStr(FreeMemList^.Size));
        end;

      FreeMemList:=FreeMemList^.Next;
    end;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  FreeList(FreeMemList);
end;

procedure TfmMain.miExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfmMain.miAboutClick(Sender: TObject);
begin
  fmAbout:=TfmAbout.Create(Self);
  try
    fmAbout.imgMain.Picture.Icon:=Application.Icon;
    fmAbout.ShowModal;
  finally
    fmAbout.Free;
  end;
end;

procedure TfmMain.pnTopRightResize(Sender: TObject);
begin
  pnFreeMemList.Height:=(pnTopRight.ClientHeight - Splitter3.Height) div 2;
end;

procedure TfmMain.ResetControls;
begin
  imgMemoryMap.Picture.Graphic:=nil;
  imgMemoryMap.Width:=0;
  imgMemoryMap.Height:=0;
  lvTaskQueue.Items.Clear;
  lvWorkingTasks.Items.Clear;
  lvFreeMemList.Items.Clear;
  
  stbMain.Panels[1].Text:=Format(sCurTimeName, [0]);
end;

procedure TfmMain.SetControlsEnabled(bEnabled: boolean);
begin
  actAddTask.Enabled:=bEnabled;
  actOpen.Enabled:=bEnabled;
  actSave.Enabled:=bEnabled;
end;

procedure TfmMain.SetStatusOnOpenOrCreateProject;
begin
  ResetControls;
  SetControlsEnabled(true);
  actStart.Enabled:=true;

  TotalMemorySize:=MaxAddress-MinAddress+1;
  ResetFreeMemList(FreeMemList);

  FilllvFreeMemList(FreeMemList);  
  DrawMemoryStatus(FreeMemList, imgMemoryMap, scbMemoryMap.ClientWidth, scbMemoryMap.ClientHeight, scbMemoryMap.VertScrollBar.IsScrollBarVisible, clWhite, clFuchsia);
end;


procedure TfmMain.actCreateExecute(Sender: TObject);
begin
  fmCreate:=TfmCreate.Create(Self);
  try
    fmCreate.ShowModal;
    if fmCreate.ModalResult=mrOk then
      begin
        sdMain.FileName:='';

        TasksCounter:=1;
        MinAddress:=StrToInt(ProcessMaskEditString(fmCreate.meMinAddress.Text));
        MaxAddress:=StrToInt(ProcessMaskEditString(fmCreate.meMaxAddress.Text));

        SetStatusOnOpenOrCreateProject;
      end;
  finally
    fmCreate.Free;
  end;
end;

procedure TfmMain.stbMainResize(Sender: TObject);
begin
  stbMain.Panels[0].Width:=stbMain.ClientWidth-170;
end;

procedure TfmMain.scbMemoryMapResize(Sender: TObject);
begin
  if imgMemoryMap.Picture.Graphic <> nil then
    DrawMemoryStatus(FreeMemList, imgMemoryMap, scbMemoryMap.ClientWidth, scbMemoryMap.ClientHeight, scbMemoryMap.VertScrollBar.IsScrollBarVisible, clWhite, clFuchsia);
end;

procedure TfmMain.actOpenExecute(Sender: TObject);
var
  s: String;
begin
  if odMain.Execute then
    begin
      sdMain.FileName:=odMain.FileName;

      AssignFile(Input, odMain.FileName);
      Reset(Input);

      ReadLn(MinAddress, MaxAddress, TasksCounter);

      SetStatusOnOpenOrCreateProject;

      while not EOF do
        with lvTaskQueue.Items.Add do
          begin
            ReadLn(s);
            Caption:=s;
            ReadLn(s);
            SubItems.Add(s);
            ReadLn(s);
            SubItems.Add(s);
            ReadLn(s);
            SubItems.Add(s);
          end;

      CloseFile(Input);
    end;
end;

procedure TfmMain.actSaveExecute(Sender: TObject);

  procedure DoSaveProject;
  var
    i: Integer;
  begin
    AssignFile(Output, sdMain.FileName);
    Rewrite(Output);

    WriteLn(MinAddress, ' ', MaxAddress, ' ', TasksCounter);

    for i:=0 to lvTaskQueue.Items.Count - 1 do
      with lvTaskQueue.Items[i] do
        begin
          WriteLn(Caption);
          WriteLn(SubItems[0]);
          WriteLn(SubItems[1]);
          WriteLn(SubItems[2]);
        end;

    CloseFile(Output);
  end;

begin
  if sdMain.FileName <> '' then
    DoSaveProject
  else
    if sdMain.Execute then
      DoSaveProject;
end;

procedure TfmMain.actAddTaskExecute(Sender: TObject);
var
  TaskBeginning: LongWord;
  i: Integer;
begin
  fmAddTask:=TfmAddTask.Create(Self);
  try
    fmAddTask.edName.Text:='Задача '+IntToStr(TasksCounter);
    fmAddTask.ShowModal;
    if fmAddTask.ModalResult=mrOk then
      begin
        TaskBeginning:=StrToInt(ProcessMaskEditString(fmAddTask.meBeginning.Text));

        i:=0;
        while (i <= lvTaskQueue.Items.Count - 1) and (TaskBeginning >= StrToInt(lvTaskQueue.Items[i].SubItems[1])) do
          Inc(i);
        with lvTaskQueue.Items.Insert(i) do
          begin
            Caption:=fmAddTask.edName.Text;
            SubItems.Add(ProcessMaskEditString(fmAddTask.meSize.Text));
            SubItems.Add(ProcessMaskEditString(fmAddTask.meBeginning.Text));
            SubItems.Add(ProcessMaskEditString(fmAddTask.meDuration.Text));
          end;

        Inc(TasksCounter);
      end;
  finally
    fmAddTask.Free;
  end;
end;

procedure TfmMain.actDeleteTaskExecute(Sender: TObject);
begin
  if lvTaskQueue.Selected <> nil then
    lvTaskQueue.Selected.Delete;
end;

procedure TfmMain.lvTaskQueueSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if actAddTask.Enabled then
    actDeleteTask.Enabled:=lvTaskQueue.Selected <> nil;
end;

procedure TfmMain.SetStatusOnStop;
begin
  actCreate.Enabled:=true;
  SetControlsEnabled(true);
  actStart.Enabled:=true;
  actPause.Enabled:=false;
  actStop.Enabled:=false;

  actInformation.Enabled:=false;
  fmInformation.Visible:=false;

  CurTime:=0;
  TotalRefusals:=0;
  bWasAccounted:=false;

  ResetControls;

  ResetFreeMemList(FreeMemList);

  FilllvFreeMemList(FreeMemList);
  DrawMemoryStatus(FreeMemList, imgMemoryMap, scbMemoryMap.ClientWidth, scbMemoryMap.ClientHeight, scbMemoryMap.VertScrollBar.IsScrollBarVisible, clWhite, clFuchsia);

  RestorelvTaskQueueItems;
end;


procedure TfmMain.RefreshInformation;
begin
  fmInformation.laRefusals.Caption:='Отказов: '+IntToStr(TotalRefusals);
  fmInformation.laMemoryUsed.Caption:='Использование памяти: '+GetMemoryUsedPercents;
end;

procedure TfmMain.SimulationLoop;
var
  Address: LongWord;
  i: Integer;
  bWasChanges: boolean;

  procedure MakeTimeStep;
  begin
    Inc(CurTime);
    stbMain.Panels[1].Text:=Format(sCurTimeName, [CurTime]);
  end;

begin
  while bRunning do
    begin
      //Task queue processing code here
      bWasChanges:=false;

      while (lvWorkingTasks.Items.Count > 0) and (StrToInt(lvWorkingTasks.Items[0].SubItems[0]) <= CurTime) do
        begin
          FreeBlock(FreeMemList, StrToInt(lvWorkingTasks.Items[0].SubItems[1]), StrToInt(lvWorkingTasks.Items[0].SubItems[2]));

          lvWorkingTasks.Items[0].Delete;

          bWasChanges:=true;
        end;

      while (lvTaskQueue.Items.Count > 0) and (StrToInt(lvTaskQueue.Items[0].SubItems[1]) <= CurTime) do
        if FindAndAllocateBlock(FreeMemList, StrToInt(lvTaskQueue.Items[0].SubItems[0]), Address) then
          begin
            i:=0;
            while (i <= lvWorkingTasks.Items.Count - 1) and (CurTime+StrToInt(lvTaskQueue.Items[0].SubItems[2]) >= StrToInt(lvWorkingTasks.Items[i].SubItems[0])) do
              Inc(i);

            with lvWorkingTasks.Items.Insert(i) do
              begin
                Caption:=lvTaskQueue.Items[0].Caption;
                SubItems.Add(IntToStr(CurTime+StrToInt(lvTaskQueue.Items[0].SubItems[2])));
                SubItems.Add(IntToStr(Address));
                SubItems.Add(lvTaskQueue.Items[0].SubItems[0]);
              end;
            lvTaskQueue.Items[0].Delete;

            bWasChanges:=true;

            bWasAccounted:=false;
          end
        else
          begin
            if not bWasAccounted then
              begin
                Inc(TotalRefusals);
                bWasAccounted:=true;
              end;
            Break;
          end;

      if bWasChanges then
        begin
          FilllvFreeMemList(FreeMemList);
          DrawMemoryStatus(FreeMemList, imgMemoryMap, scbMemoryMap.ClientWidth, scbMemoryMap.ClientHeight, scbMemoryMap.VertScrollBar.IsScrollBarVisible, clWhite, clFuchsia);
        end;

      if fmInformation.Visible then
        RefreshInformation;

      Delay;

      if bRunning then
        MakeTimeStep
      else
        if bStopped then
          SetStatusOnStop
        else
          begin
            actPause.Enabled:=false;
            actStart.Enabled:=true;

            MakeTimeStep;
          end;
    end;
end;

procedure TfmMain.actStartExecute(Sender: TObject);
begin
  if CurTime = 0 then
    begin
      SavelvTaskQueueItems;

      actCreate.Enabled:=false;
      SetControlsEnabled(false);
      actStop.Enabled:=true;

      actInformation.Enabled:=true;
      actInformation.Execute;

      bStopped:=false;
    end;
  actStart.Enabled:=false;
  actPause.Enabled:=true;

  bRunning:=true;

  SimulationLoop;
end;

procedure TfmMain.actPauseExecute(Sender: TObject);
begin
  bRunning:=false;
end;

procedure TfmMain.actStopExecute(Sender: TObject);
begin
  if bRunning then
    begin
      bRunning:=false;
      bStopped:=true;
    end
  else
    begin
      bStopped:=true;
      SetStatusOnStop;
    end;
end;

procedure TfmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if bRunning then
    actStop.Execute;
end;

procedure TfmMain.SavelvTaskQueueItems;
var
  i: Integer;
begin
  SetLength(TaskQueueArr, lvTaskQueue.Items.Count);
  for i:=0 to lvTaskQueue.Items.Count - 1 do
    with TaskQueueArr[i], lvTaskQueue.Items[i] do
      begin
        Name:=Caption;
        Size:=SubItems[0];
        Beginning:=SubItems[1];
        Duration:=SubItems[2];
      end;
end;

procedure TfmMain.RestorelvTaskQueueItems;
var
  i: Integer;
begin
  for i:=0 to Length(TaskQueueArr) - 1 do
    with lvTaskQueue.Items.Add, TaskQueueArr[i] do
      begin
        Caption:=Name;
        SubItems.Add(Size);
        SubItems.Add(Beginning);
        SubItems.Add(Duration);
      end;
  TaskQueueArr:=nil;
end;

procedure TfmMain.actInformationExecute(Sender: TObject);
begin
  if not fmInformation.Visible then
    begin

    
      RefreshInformation;

      fmInformation.Left:=fmMain.Left + fmMain.Width - fmInformation.Width - 3;
      fmInformation.Top:=fmMain.Top + ((fmMain.Height - fmInformation.Height) div 2);
      fmInformation.Visible:=true;
    end;
end;


procedure TfmMain.FormCreate(Sender: TObject);
begin
  Application.HelpFile:=ChangeFileExt(Application.ExeName, '.hlp');
end;

procedure TfmMain.miTaskClick(Sender: TObject);
begin
  Application.HelpJump('Task');
end;

end.
