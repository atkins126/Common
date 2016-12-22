unit uSuicideThread;

interface

uses
  Classes, Windows, Messages, SysUtils;

type
  TSuicideAnchorThread = class(TThread)
  protected
    procedure SetToLastestCPU;
    procedure KillSelfApp;
  end;

  {*** ��ɱ�̣߳���һ�����ڷ���Ϣ�������Ϣû����Ӧ�ۼƵ�һ���������ͻ���ɱ��ǰ���̡�
    һ�����ڣ��жϳ���û����Ӧһ��ʱ�����ɱ��
  }
  TSuicide_ByMsgResponse_Thread = class(TSuicideAnchorThread)
  private
    FCheckHandle : HWND;
    FWaitSeconds : Integer;
    FCheckMessage : UINT;
    FMessageResult : UINT;
  protected
    procedure Execute; override;
  public
    property CheckHandle : HWND read FCheckHandle write FCheckHandle;
    property CheckMessage : UINT read FCheckMessage write FCheckMessage;
    property MessageResult : UINT read FMessageresult write FMessageResult;
    property WaitSeconds : Integer read FWaitSeconds write FWaitSeconds;

    constructor Create(
        const ACheckHandle : HWND;
        const ACheckMessage : UINT;
        const AMessageResult :  UINT;
        const AWaitSeconds : Integer = 20
        ); reintroduce;
  end;

  {*** ��ɱ�̣߳��жϴ����Ƿ���ڣ����������ڲ����ڳ���һ���������ͻ���ɱ��ǰ���̡�
  }
  TSuicide_ByWindowExists_Thread = class(TSuicideAnchorThread)
  private
    FCheckHandle : HWND;
    FWaitSeconds : Integer;
  protected
    procedure Execute; override;
  public
    property CheckHandle : HWND read FCheckHandle write FCheckHandle;
    property WaitSeconds : Integer read FWaitSeconds write FWaitSeconds;
    constructor Create(
        const ACheckHandle : HWND;
        const AWaitSeconds : Integer = 3
        ); reintroduce;
  end;


implementation

{ TSuicideAnchorThread }
procedure TSuicideAnchorThread.KillSelfApp;
begin
  TerminateProcess(GetCurrentProcess, 0);
end;

procedure TSuicideAnchorThread.SetToLastestCPU;
var
  Info: SYSTEM_INFO;
begin
  FillChar(Info, Sizeof(SYSTEM_INFO),0);
  GetSystemInfo(Info);
  if Info.dwNumberOfProcessors>1 then          //�����һ��CPU�����������
    SetThreadAffinityMask(Self.Handle, Info.dwNumberOfProcessors);
end;


{ TSuicide_ByMsgResponse_Thread }

constructor TSuicide_ByMsgResponse_Thread.Create(const ACheckHandle: HWND; const ACheckMessage,
  AMessageResult: UINT; const AWaitSeconds: Integer);
begin
  inherited Create(False);
  FCheckHandle  :=  ACheckHandle;
  FCheckMessage :=  ACheckMessage;
  FMessageResult  :=  AMessageResult;
  FWaitSeconds  :=  AWaitSeconds;
  SetToLastestCPU;  //�����һ��CPU�����������
end;

procedure TSuicide_ByMsgResponse_Thread.Execute;
var
  iCount : Integer;
  hr :  Cardinal;
const
  DEF_MSG_TIMEOUT = 1000;
begin
  inherited;
  iCount  :=  0;
  while not Terminated do
  begin
    Sleep(1000);
    if SendMessageTimeOut(FCheckHandle, FCheckMessage, 0, 0, SMTO_BLOCK or SMTO_ABORTIFHUNG, DEF_MSG_TIMEOUT, hr) = 0 then
      Inc(iCount)
    else if hr = FMessageResult then
      iCount  :=  0
    else
      Inc(iCount);
    if iCount > FWaitSeconds then
      KillSelfApp;
  end;
end;

{ TSuicide_ByWindowExists_Thread }

constructor TSuicide_ByWindowExists_Thread.Create(const ACheckHandle: HWND;
  const AWaitSeconds: Integer);
begin
  inherited Create(False);
  FCheckHandle  :=  ACheckHandle;
  FWaitSeconds  :=  AWaitSeconds;
  SetToLastestCPU;  //�����һ��CPU�����������
end;

procedure TSuicide_ByWindowExists_Thread.Execute;
var
  iCount : Integer;
begin
  inherited;
  iCount  :=  0;
  while not Terminated do
  begin
    Sleep(1000);
    if not IsWindow(FCheckHandle)  then
      Inc(iCount)
    else
      iCount  :=  0;

    if iCount > FWaitSeconds then
      KillSelfApp;
  end;
end;

end.
