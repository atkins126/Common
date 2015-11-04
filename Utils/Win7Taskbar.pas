(* ******************************************************************************
  * �ļ���: Win7Taskbar.pas                                                     *
  * ��������: 2011-05-01                                                        *
  * ʵ��win7������api�ļ򵥷�װ                                                 *
  * by: bahamut                                                                 *
  ****************************************************************************** *)
unit Win7Taskbar;

interface

uses
  Windows,
  Messages,
  ActiveX { , CommCtrl } ;

(* ��ض��� *)
const
  SID_ITaskbarList = '{56FDF342-FD6D-11D0-958A-006097C9A090}';
  SID_ITaskbarList2 = '{602D4995-B13A-429B-A66E-1935E44F4317}';
  SID_ITaskbarList3 = '{EA1AFB91-9E28-4B86-90E9-9E9F8A5EEFAF}';
  SID_ITaskbarList4 = '{C43DC798-95D1-4BEA-9030-BB99E2983A1A}';

const
  IID_ITaskbarList: TGUID = SID_ITaskbarList;
  IID_ITaskbarList2: TGUID = SID_ITaskbarList2;
  IID_ITaskbarList3: TGUID = SID_ITaskbarList3;
  IID_ITaskbarList4: TGUID = SID_ITaskbarList4;
  CLSID_TaskbarList: TGUID = '{56FDF344-FD6D-11D0-958A-006097C9A090}';

const
  TBPF_NOPROGRESS = $00000000;
  TBPF_INDETERMINATE = $00000001;
  TBPF_NORMAL = $00000002;
  TBPF_ERROR = $00000004;
  TBPF_PAUSED = $00000008;
  TBATF_USEMDITHUMBNAIL = $00000001;
  TBATF_USEMDILIVEPREVIEW = $00000002;
  // THUMBBUTTON mask
  THB_BITMAP = $00000001;
  THB_ICON = $00000002;
  THB_TOOLTIP = $00000004;
  THB_FLAGS = $00000008;
  THBN_CLICKED = $00001800;
  // THUMBBUTTON flags
  THBF_ENABLED = $00000000;
  THBF_DISABLED = $00000001;
  THBF_DISMISSONCLICK = $00000002;
  THBF_NOBACKGROUND = $00000004;
  THBF_HIDDEN = $00000008;
  THBF_NONINTERACTIVE = $00000010;
  STPF_NONE = $00000000;
  STPF_USEAPPTHUMBNAILALWAYS = $00000001;
  STPF_USEAPPTHUMBNAILWHENACTIVE = $00000002;
  STPF_USEAPPPEEKALWAYS = $00000004;
  STPF_USEAPPPEEKWHENACTIVE = $00000008;

type
  ULONGLONG = UINT64;
  HIMAGELIST = HWND;
  STPFLAG = UINT;

type
  { interface ITaskbarList3 }
  PThumbButton = ^TThumbButton;

  _THUMBBUTTON = packed record
    dwMask: DWORD;
    iId: UINT;
    iBitmap: UINT;
    hIcon: hIcon;
    szTip: array [0 .. 259] of WideChar;
    dwFlags: DWORD;
  end;

  THUMBBUTTON = _THUMBBUTTON;
  TThumbButton = _THUMBBUTTON;

type
  { interface ITaskbarList }
  ITaskbarList = interface(IUnknown)
    [SID_ITaskbarList]
    function HrInit: HRESULT; stdcall;
    function AddTab(HWND: HWND): HRESULT; stdcall;
    function DeleteTab(HWND: HWND): HRESULT; stdcall;
    function ActivateTab(HWND: HWND): HRESULT; stdcall;
    function SetActiveAlt(HWND: HWND): HRESULT; stdcall;
  end;

type
  { interface ITaskbarList2 }
  ITaskbarList2 = interface(ITaskbarList)
    [SID_ITaskbarList2]
    function MarkFullscreenWindow(HWND: HWND; fFullscreen: BOOL): HRESULT;
      stdcall;
  end;

type
  { interface ITaskbarList3 }
  ITaskbarList3 = interface(ITaskbarList2)
    [SID_ITaskbarList3]
    function SetProgressValue(HWND: HWND; ullCompleted: ULONGLONG;
      ullTotal: ULONGLONG): HRESULT; stdcall;
    function SetProgressState(HWND: HWND; tbpFlags: UINT): HRESULT; stdcall;
    function RegisterTab(hwndTab: HWND; hwndMDI: HWND): HRESULT; stdcall;
    function UnregisterTab(hwndTab: HWND): HRESULT; stdcall;
    function SetTabOrder(hwndTab: HWND; hwndInsertBefore: HWND): HRESULT;
      stdcall;
    function SetTabActive(hwndTab: HWND; hwndMDI: HWND;
      tbatFlags: UINT): HRESULT; stdcall;
    function ThumbBarAddButtons(HWND: HWND; cButtons: UINT;
      pButton: PThumbButton): HRESULT; stdcall;
    function ThumbBarUpdateButtons(HWND: HWND; cButtons: UINT;
      pButton: PThumbButton): HRESULT; stdcall;
    function ThumbBarSetImageList(HWND: HWND; himl: HIMAGELIST): HRESULT;
      stdcall;
    function SetOverlayIcon(HWND: HWND; hIcon: hIcon;
      pszDescription: LPCWSTR): HRESULT; stdcall;
    function SetThumbnailTooltip(HWND: HWND; pszTip: LPCWSTR): HRESULT; stdcall;
    function SetThumbnailClip(HWND: HWND; var prcClip: TRect): HRESULT; stdcall;
  end;

type
  { interface ITaskbarList4 }
  ITaskbarList4 = interface(ITaskbarList3)
    [SID_ITaskbarList4]
    function SetTabProperties(hwndTab: HWND; stpFlags: STPFLAG): HRESULT;
      stdcall;
  end;

  (* win7 api ������� *)
const
  MAX_BUTTON = 7;
  // ���ť��, windowsϵͳ�涨��...
type
  TProgressState = (psNoProgress, psIndeterminate, psNormal, psError, psPaused);

type
  TNotifyEvent = procedure(Sender: TObject) of object;
  (* �Զ����࿪ʼ *)
{$M+}

type
  TWin7Taskbar = class; // ����
  TTaskbarThumbButtons = class;
  // ��ť������,��������ť
  TTaskbarThumbButton = class(TObject) // ��ť��,�ֿ������Ŀ���Ǽ򻯲���
  private
    FCommandId: DWORD;
    FParent: TTaskbarThumbButtons;
    FVisible: Boolean;
    FShowHint: Boolean;
    FEnabled: Boolean;
    FIcon: hIcon;
    FImageIndex: Integer;
    FHint: WideString;
    FTransparent: Boolean;
    FOnClick: TNotifyEvent;
    FOnChanged: TNotifyEvent;
    FOnChanging: TNotifyEvent;
    procedure SetEnabled(const Value: Boolean);
    procedure SetHint(const Value: WideString);
    procedure SetIcon(const Value: hIcon);
    procedure SetImageIndex(const Value: Integer);
    procedure SetShowHint(const Value: Boolean);
    procedure SetVisible(const Value: Boolean);
    procedure SetTransparent(const Value: Boolean);
  protected
    procedure DoClick; dynamic;
    procedure DoChanging; dynamic;
    procedure DoChanged; dynamic;
    procedure Click; dynamic;
    procedure Update; virtual;
  public
    constructor Create(AParent: TTaskbarThumbButtons; ACommandId: DWORD);
    destructor Destroy; override;
  published
    // �Ƿ����
    property Enabled: Boolean read FEnabled write SetEnabled;
    // �Ƿ�ɼ�
    property Visible: Boolean read FVisible write SetVisible;
    // �Ƿ���ʾ��ʾ����
    property ShowHint: Boolean read FShowHint write SetShowHint;
    // ��ʾ�����ı�
    property Hint: WideString read FHint write SetHint;
    // ͼ����
    property Icon: hIcon read FIcon write SetIcon;
    // ͼƬ���
    property ImageIndex: Integer read FImageIndex write SetImageIndex;
    // �Ƿ�͸��
    property Transparent: Boolean read FTransparent write SetTransparent;
    // �����¼�
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    // ���ڸı�
    property OnChanging: TNotifyEvent read FOnChanging write FOnChanging;
    // �����ı�
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

  TTaskbarThumbButtons = class(TObject)
  private
    // ��ť����, ����һ�����ʹ���������İ�ť����, ���а�ťĬ��ȫ������ʾ
    FButtons: array [0 .. MAX_BUTTON - 1] of TTaskbarThumbButton;
    FOwner: TWin7Taskbar;
    FImageList: HWND;
    FOnButtonCreated: TNotifyEvent;
    FOnChanging: TNotifyEvent;
    FOnChanged: TNotifyEvent;
    procedure SetImageList(const Value: HWND);
    function GetButton(Index: Integer): TTaskbarThumbButton;
  protected
    procedure DoButtonCreated; dynamic;
    procedure DoChanging; dynamic;
    procedure DoChanged; dynamic;
    procedure Update(Button: TTaskbarThumbButton); virtual;
    procedure UpdateVisible; virtual;
  public
    constructor Create(AOwner: TWin7Taskbar);
    destructor Destroy; override;
    // �ж�һ����ť���б��е����
    function IndexOf(Button: TTaskbarThumbButton): Integer;
    // ����id���Ұ�ť����
    function FindByCommandId(CommandId: DWORD): TTaskbarThumbButton;
    // ��ť��
    property Button[Index: Integer]: TTaskbarThumbButton read GetButton;
    default;
  published
    // ͼ���б���
    property ImageList: HWND read FImageList write SetImageList;
    // ��ť�����¼�
    property OnButtonCreated
      : TNotifyEvent read FOnButtonCreated write FOnButtonCreated;
    // ���ڸı�
    property OnChanging: TNotifyEvent read FOnChanging write FOnChanging;
    // �����ı�
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

  TTaskbarProgress = class(TObject)
  private
    FOwner: TWin7Taskbar;
    FPosition: Int64;
    FMin: Int64;
    FMax: Int64;
    FState: TProgressState;
    FOnPosition: TNotifyEvent;
    FOnChanged: TNotifyEvent;
    FOnChanging: TNotifyEvent;
    procedure SetMax(const Value: Int64);
    procedure SetMin(const Value: Int64);
    procedure SetPosition(const Value: Int64);
    procedure SetState(const Value: TProgressState);
  protected
    procedure DoPosition; dynamic;
    procedure DoChanging; dynamic;
    procedure DoChanged; dynamic;
    procedure Update; virtual;
  public
    constructor Create(AOwner: TWin7Taskbar);
    destructor Destroy; override;
  published
    property State: TProgressState read FState write SetState;
    property Min: Int64 read FMin write SetMin;
    property Max: Int64 read FMax write SetMax;
    property Position: Int64 read FPosition write SetPosition;
    // �ı�����¼�
    property OnPosition: TNotifyEvent read FOnPosition write FOnPosition;
    // ���ڸı�
    property OnChanging: TNotifyEvent read FOnChanging write FOnChanging;
    // �����ı�
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

  TTaskbarOverlayIcon = class(TObject)
  private
    FOwner: TWin7Taskbar;
    FIcon: hIcon;
    FDescription: WideString;
    FOnChanging: TNotifyEvent;
    FOnChanged: TNotifyEvent;
    procedure SetDescription(const Value: WideString);
    procedure SetIcon(const Value: hIcon);
  protected
    procedure DoChanging; dynamic;
    procedure DoChanged; dynamic;
    procedure Update; virtual;
  public
    constructor Create(AOwner: TWin7Taskbar);
    destructor Destroy; override;
  published
    // Сͼ����(ͼ�����ʾ�ڹ�����ͼ������½�)
    property Icon: hIcon read FIcon write SetIcon;
    // ˵��
    property Description: WideString read FDescription write SetDescription;
    // ���ڸı�
    property OnChanging: TNotifyEvent read FOnChanging write FOnChanging;
    // �����ı�
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

  TWin7Taskbar = class(TObject)
  private
    FCanCreate: Boolean;
    FMainWindow: HWND;
    FTaskbarList: ITaskbarList4;
    FButtons: TTaskbarThumbButtons;
    FProgress: TTaskbarProgress;
    FOverlayIcon: TTaskbarOverlayIcon;
    FCreateButtonMessage: UINT; // windows������ť����Ϣ
    FOldWndProc: Pointer;
    FNewWndProc: Pointer;
    function NewWndProc(HWND: HWND; uMsg: UINT; wParam: wParam;
      lParam: lParam): LRESULT; stdcall;
  protected
    // ��Ӱ�ť����, �������ֻ�����һ��,
    // ITaskbarList3��ThumbBarAddButtons�������ظ����õ�ʱ���ƺ���ʧЧ,
    // msdn��û�����˵��, ����ֵҲ����s_ok
    // bug?
    procedure AppendButton; virtual;
    // ���°�ť״̬, �����״δ�����ʱ���һ�������7(���)����ť,
    // �Ժ��޸����������ʵ���ǵ�����������޸Ķ�Ӧ��ť��״̬����.
    procedure UpdateButton(Index: Integer); virtual;
    // �޸İ�ť��ͼƬ�б�
    procedure UpdateImageList; virtual;
    // ���½���������
    procedure UpdateProgress; virtual;
    // ����ͼ��
    procedure UpdateOverlayIcon; virtual;
  public
    constructor Create(AMainWindow: HWND = 0);
    destructor Destroy; override;
    // ˢ������TaskbarList�ӿ�Ч��(����ȫ�����µ���һ��֪ͨ)
    procedure Refresh;
  published
    // ��ť
    property Buttons: TTaskbarThumbButtons read FButtons;
    // ������
    property Progress: TTaskbarProgress read FProgress;
    // Сͼ��
    property OverlayIcon: TTaskbarOverlayIcon read FOverlayIcon;
  end;
{$M-}

function IsVistaLater: Boolean; stdcall;// �жϲ���ϵͳ�Ƿ���vista�Ժ��ϵͳ
function GetMainWindow: HWND; stdcall;// ȡ�����ھ��

implementation

const
  BitmapMask: array [Boolean] of DWORD = (0, THB_BITMAP);
  IconMask: array [Boolean] of DWORD = (0, THB_ICON);
  HintMask: array [Boolean] of DWORD = (0, THB_TOOLTIP);
  VisibleFlag: array [Boolean] of DWORD = (THBF_HIDDEN, 0);
  EnabledFlag: array [Boolean] of DWORD = (THBF_DISABLED, THBF_ENABLED);
  TransparentFlag: array [Boolean] of DWORD = (0, THBF_NOBACKGROUND);

type
  PEnumParam = ^TEnumParam;

  TEnumParam = packed record
    dwProcessId: DWORD;
    hMainWindow: HWND;
  end;

function EnumProc(HWND: HWND; lParam: lParam): BOOL; stdcall;
var
  dwProcessId: DWORD;
  lpParam: PEnumParam;
begin
  Result := True;
  if not IsWindowVisible(HWND) then
    Exit;
  if GetWindowLong(HWND, GWL_EXSTYLE)
    and WS_EX_TOOLWINDOW = WS_EX_TOOLWINDOW then
    Exit;
  if GetWindowLong(HWND, GWL_HWNDPARENT) <> 0 then
    Exit;
  GetWindowThreadProcessId(HWND, dwProcessId);
  lpParam := Pointer(lParam);
  if dwProcessId = lpParam^.dwProcessId then
  begin
    lpParam^.hMainWindow := HWND;
    Result := False;
  end;
end;

// �������ͨ���оٴ��ڵķ�ʽ��ѯӦ�ó���������ھ��
function GetMainWindow: HWND;
var
  dwCurrentProcessId: DWORD;
  lpParam: TEnumParam;
begin
  dwCurrentProcessId := GetCurrentProcessId;
  Result := 0;
  if dwCurrentProcessId <> 0 then
  begin
    lpParam.dwProcessId := dwCurrentProcessId;
    lpParam.hMainWindow := 0;
    EnumWindows(@EnumProc, lParam(@lpParam));
    Result := lpParam.hMainWindow;
  end;
end;

function IsVistaLater: Boolean;
var
  lpVersion: TOSVersionInfo;
begin
  Result := False;
  FillChar(lpVersion, SizeOf(lpVersion), 0);
  lpVersion.dwOSVersionInfoSize := SizeOf(lpVersion);
  if GetVersionEx(lpVersion) then
    Result := lpVersion.dwMajorVersion > 5;
end;

// �����һ��Thunk����
function CreateThunk(lpObject: TObject; lpCallBackProc: Pointer): Pointer;
const
  PageSize = 4096;
  SizeOfJmpCode = 5;
type
  PCode = ^TCode;

  TCode = packed record
    bInt3: Byte; // ����Եĵ�ʱ����Int 3($CC),������Ե�ʱ����nop($90)
    bPopEAX: Byte; // �ѷ��ص�ַ��ջ�е���
    bPush: Byte; // ѹջָ��
    pAddrOfSelf: TObject; // ѹ��Self��ַ,��Self��Ϊ��һ������
    bPushEAX: Byte; // ����ѹ�뷵�ص�ַ
    bJmp: Byte; // �����תָ��
    uAddrOfJmp: Cardinal; // Ҫ��ת���ĵ�ַ,
  end;
var
  lpCode: PCode;
begin
  // ����һ�ο���ִ��,�ɶ�д���ڴ�
  Result := VirtualAlloc(nil, PageSize, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
  lpCode := Result;
  lpCode^.bInt3 := $90; // nop
  // lpCode^.bInt3:= $CC; //Int 3
  lpCode^.bPopEAX := $58;
  lpCode^.bPush := $68;
  lpCode^.pAddrOfSelf := lpObject;
  lpCode^.bPushEAX := $50;
  lpCode^.bJmp := $E9;
  lpCode^.uAddrOfJmp := DWORD(lpCallBackProc) -
    (DWORD(@lpCode^.bJmp) + SizeOfJmpCode); // ������Ե�ַ
end;

// ����thunk����
procedure ReleaseThunk(lpThunk: Pointer);
begin
  VirtualFree(lpThunk, 0, MEM_RELEASE);
end;

{ TTaskbarThumbButton }
procedure TTaskbarThumbButton.Click;
begin
  if Visible and Enabled then
    DoClick;
end;

constructor TTaskbarThumbButton.Create(AParent: TTaskbarThumbButtons;
  ACommandId: DWORD);
begin
  inherited Create;
  FParent := AParent;
  FCommandId := ACommandId;
  FVisible := False;
  FShowHint := True;
  FEnabled := True;
  FIcon := 0;
  FImageIndex := -1;
  FHint := '';
  FOnClick := nil;
  FOnChanged := nil;
  FOnChanging := nil;
end;

destructor TTaskbarThumbButton.Destroy;
begin
  FOnChanging := nil;
  FOnChanged := nil;
  FOnClick := nil;
  FParent := nil;
  inherited Destroy;
end;

procedure TTaskbarThumbButton.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TTaskbarThumbButton.DoChanging;
begin
  if Assigned(FOnChanging) then
    FOnChanging(Self);
end;

procedure TTaskbarThumbButton.DoClick;
begin
  if Assigned(FOnClick) then
    FOnClick(Self);
end;

procedure TTaskbarThumbButton.SetEnabled(const Value: Boolean);
begin
  if FEnabled = Value then
    Exit;
  FEnabled := Value;
  Update;
end;

procedure TTaskbarThumbButton.SetHint(const Value: WideString);
var
  Temp: WideString;
  APos: Integer;
begin
  Temp := Value;
  repeat // ȥ���ַ�&
    APos := Pos('&', Temp);
    if APos = 0 then
      Break;
    Delete(Temp, APos, 1);
  until False;
  if FHint = Temp then
    Exit;
  FHint := Temp;
  Update;
end;

procedure TTaskbarThumbButton.SetIcon(const Value: hIcon);
begin
  if FIcon = Value then
    Exit;
  FIcon := Value;
  Update;
end;

procedure TTaskbarThumbButton.SetImageIndex(const Value: Integer);
begin
  if FImageIndex = Value then
    Exit;
  FImageIndex := Value;
  Update;
end;

procedure TTaskbarThumbButton.SetShowHint(const Value: Boolean);
begin
  if FShowHint = Value then
    Exit;
  FShowHint := Value;
  Update;
end;

procedure TTaskbarThumbButton.SetTransparent(const Value: Boolean);
begin
  if FTransparent = Value then
    Exit;
  FTransparent := Value;
  Update;
end;

procedure TTaskbarThumbButton.SetVisible(const Value: Boolean);
begin
  if FVisible = Value then
    Exit;
  FVisible := Value;
  Update;
end;

procedure TTaskbarThumbButton.Update;
begin
  // ֪ͨ������Ҫ�����Լ�...
  FParent.Update(Self);
end;

{ TTaskbarThumbButtons }
constructor TTaskbarThumbButtons.Create(AOwner: TWin7Taskbar);
var
  Loop: Integer;
begin
  inherited Create;
  FOwner := AOwner;
  FOnButtonCreated := nil;
  FOnChanging := nil;
  FOnChanged := nil;
  // Ĭ�ϴ�����ϵͳ��������ť��
  for Loop := Low(FButtons) to High(FButtons) do
    FButtons[Loop] := TTaskbarThumbButton.Create(Self, Loop);
end;

destructor TTaskbarThumbButtons.Destroy;
var
  Loop: Integer;
begin
  for Loop := Low(FButtons) to High(FButtons) do
    FButtons[Loop].Free;
  FOnChanged := nil;
  FOnChanging := nil;
  FOnButtonCreated := nil;
  FOwner := nil;
  inherited Destroy;
end;

procedure TTaskbarThumbButtons.DoButtonCreated;
begin
  if Assigned(FOnButtonCreated) then
    FOnButtonCreated(Self);
end;

procedure TTaskbarThumbButtons.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TTaskbarThumbButtons.DoChanging;
begin
  if Assigned(FOnChanging) then
    FOnChanging(Self);
end;

function TTaskbarThumbButtons.FindByCommandId(CommandId: DWORD)
  : TTaskbarThumbButton;
var
  Loop: Integer;
begin
  for Loop := 0 to MAX_BUTTON - 1 do
  begin
    Result := FButtons[Loop];
    if Result.FCommandId = CommandId then
      Exit;
  end;
  Result := nil;
end;

function TTaskbarThumbButtons.GetButton(Index: Integer): TTaskbarThumbButton;
begin
  if (Index > -1) and (Index < MAX_BUTTON) then
    Result := FButtons[Index]
  else
    Result := nil;
end;

function TTaskbarThumbButtons.IndexOf(Button: TTaskbarThumbButton): Integer;
begin
  Result := 0;
  while Result < MAX_BUTTON do
  begin
    if FButtons[Result] = Button then
      Exit;
    Inc(Result);
  end;
  Result := -1;
end;

procedure TTaskbarThumbButtons.SetImageList(const Value: HWND);
begin
  if FImageList = Value then
    Exit;
  FImageList := Value;
  FOwner.UpdateImageList;
end;

procedure TTaskbarThumbButtons.Update(Button: TTaskbarThumbButton);
begin
  FOwner.UpdateButton(IndexOf(Button));
end;

procedure TTaskbarThumbButtons.UpdateVisible;
var
  Loop: Integer;
begin
  for Loop := 0 to MAX_BUTTON - 1 do
    if FButtons[Loop].FVisible then
      FOwner.UpdateButton(Loop);
end;

{ TTaskbarProgress }
constructor TTaskbarProgress.Create(AOwner: TWin7Taskbar);
begin
  inherited Create;
  FOwner := AOwner;
  FPosition := 0;
  FMin := 0;
  FMax := 100;
  FState := psNoProgress;
  FOnPosition := nil;
  FOnChanged := nil;
  FOnChanging := nil;
end;

destructor TTaskbarProgress.Destroy;
begin
  FOnChanging := nil;
  FOnChanged := nil;
  FOnPosition := nil;
  FOwner := nil;
  inherited Destroy;
end;

procedure TTaskbarProgress.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TTaskbarProgress.DoChanging;
begin
  if Assigned(FOnChanging) then
    FOnChanging(Self);
end;

procedure TTaskbarProgress.DoPosition;
begin
  if Assigned(FOnPosition) then
    FOnPosition(Self);
end;

procedure TTaskbarProgress.SetMax(const Value: Int64);
begin
  if FMax = Value then
    Exit;
  if Value < FMin then
    FMax := FMin
  else
    FMax := Value;
  SetPosition(FPosition);
end;

procedure TTaskbarProgress.SetMin(const Value: Int64);
begin
  if FMin = Value then
    Exit;
  if Value > FMax then
    FMin := FMax
  else
    FMin := Value;
  SetPosition(FPosition);
end;

procedure TTaskbarProgress.SetPosition(const Value: Int64);
begin
  if FPosition = Value then
    Exit;
  if Value < FMin then
    FPosition := FMin
  else
    if Value > FMax then
      FPosition := FMax
    else
      FPosition := Value;
  DoPosition;
  if FState <> psIndeterminate then
    // �����ʽΪTBPF_INDETERMINATE����Ҫ����״̬
    Update;
end;

procedure TTaskbarProgress.SetState(const Value: TProgressState);
begin
  if FState = Value then
    Exit;
  FState := Value;
  Update;
end;

procedure TTaskbarProgress.Update;
begin
  FOwner.UpdateProgress;
end;

{ TTaskbarOverlayIcon }
constructor TTaskbarOverlayIcon.Create(AOwner: TWin7Taskbar);
begin
  inherited Create;
  FOwner := AOwner;
  FIcon := 0;
  FDescription := '';
  FOnChanging := nil;
  FOnChanged := nil;
end;

destructor TTaskbarOverlayIcon.Destroy;
begin
  FOnChanged := nil;
  FOnChanging := nil;
  FOwner := nil;
  inherited Destroy;
end;

procedure TTaskbarOverlayIcon.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TTaskbarOverlayIcon.DoChanging;
begin
  if Assigned(FOnChanging) then
    FOnChanging(Self);
end;

procedure TTaskbarOverlayIcon.SetDescription(const Value: WideString);
begin
  if FDescription = Value then
    Exit;
  FDescription := Value;
  Update;
end;

procedure TTaskbarOverlayIcon.SetIcon(const Value: hIcon);
begin
  if FIcon = Value then
    Exit;
  FIcon := Value;
  Update;
end;

procedure TTaskbarOverlayIcon.Update;
begin
  FOwner.UpdateOverlayIcon;
end;

{ TWin7Taskbar }
procedure TWin7Taskbar.AppendButton;
var
  AButtons: array [0 .. MAX_BUTTON - 1] of TThumbButton;
  AButton: TTaskbarThumbButton;
  Loop: Integer;
begin
  if not(FCanCreate and Assigned(FTaskbarList)) then
    Exit;
  // ��ť���϶����¼�����, ֪ͨ����(��ʼ)�ı�
  FButtons.DoChanging;
  FillChar(AButtons, SizeOf(AButtons), 0);
  for Loop := 0 to MAX_BUTTON - 1 do
  begin
    // ��ѭ����ȡ��ť����, Ȼ��֪ͨÿ������ʼ�ı�(����OnChanging�¼�)
    AButton := FButtons.Button[Loop];
    AButton.DoChanging;
    // Ȼ����ݶ�����������windowsָ�������ݽṹ��ÿ�����ֵ
    AButtons[Loop].dwMask := BitmapMask[AButton.FImageIndex <> -1] or IconMask
      [AButton.FIcon <> 0] or HintMask[AButton.ShowHint] or THB_FLAGS;
    AButtons[Loop].iId := AButton.FCommandId;
    AButtons[Loop].iBitmap := AButton.FImageIndex;
    AButtons[Loop].hIcon := AButton.FIcon;
    CopyMemory(@AButtons[Loop].szTip[0], PWideChar(AButton.FHint),
      Length(AButton.FHint) * SizeOf(WideChar));
    AButtons[Loop].dwFlags := VisibleFlag[AButton.Visible] or EnabledFlag
      [AButton.Enabled] or TransparentFlag[AButton.Transparent];
  end;
  // ͨ��ITaskbarList4�ӿڶ�����Ӱ�ť
  FTaskbarList.ThumbBarAddButtons(FMainWindow, MAX_BUTTON, @AButtons[0]);
  // �����Ϻ�, ѭ��֪ͨ��Ӧ��ť����ı����
  for Loop := MAX_BUTTON - 1 downto 0 do
    FButtons.Button[Loop].DoChanged;
  // ��ť���϶����¼�����, ֪ͨ�ı����
  FButtons.DoChanged;
end;

constructor TWin7Taskbar.Create(AMainWindow: HWND);
begin
  inherited Create;
  FCanCreate := IsVistaLater;
  if not FCanCreate then
    Exit;
  // �Զ��̵߳ķ�ʽ��ʼ��com�����
  CoInitializeEx(nil, COINIT_MULTITHREADED);
  // windowsϵͳ����������ͼ��ʱ���͹�������Ϣ
  // Ӧ�ó�������ڽӵ������Ϣ��, ��ȥ����TaskbarList�ĺ����Ż���Ч��,
  // �������ﲻ��������com����, �Ա����ظ�ִ���Զ��������¼�(OnChanging��OnChanged)
  FCreateButtonMessage := RegisterWindowMessageW('TaskbarButtonCreated');
  // ȡ����������,ע��d2007��ǰһ����application�ľ��,
  if AMainWindow = 0 then
    FMainWindow := GetMainWindow
  else
    FMainWindow := AMainWindow;
  // ��������Ǵ���һ�����з�����ͨ�ûص�thunk, Դ����������(��ϣ�ɵ�blog)
  // ��32bit���������쳣
  FNewWndProc := CreateThunk(Self, @TWin7Taskbar.NewWndProc);
  // ���������������thunk��Ϊ�µĴ�����Ϣ�������ע���Ŀ�괰��, �����滻Ŀ�괰�ڵ���Ϣ����,
  // �������ܴ���������ͼ�걻��������Ϣ, �Լ������ӵİ�ť��ͨ����Ϣ
  FOldWndProc := Pointer(SetWindowLongW(FMainWindow, GWL_WNDPROC,
      DWORD(FNewWndProc)));
  // ������ض���, Ŀǰֻ�а�ť, ������, Сͼ��
  FButtons := TTaskbarThumbButtons.Create(Self);
  FProgress := TTaskbarProgress.Create(Self);
  FOverlayIcon := TTaskbarOverlayIcon.Create(Self);
end;

destructor TWin7Taskbar.Destroy;
begin
  // �ͷ���ض���
  FOverlayIcon.Free;
  FProgress.Free;
  FButtons.Free;
  // ��ԭԭ���ڴ������
  SetWindowLongW(FMainWindow, GWL_WNDPROC, DWORD(FOldWndProc));
  // �ͷŹ��������thunk
  ReleaseThunk(FNewWndProc);
  // �ͷ�com����
  FTaskbarList := nil;
  // ����com�������Դ
  CoUninitialize;
  inherited Destroy;
end;

function TWin7Taskbar.NewWndProc(HWND: HWND; uMsg: UINT; wParam: wParam;
  lParam: lParam): LRESULT;
var
  Button: TTaskbarThumbButton;
begin
  if not FCanCreate then
    // ����win7���Ժ��ϵͳ, �����ԭ���Ĵ��ڹ��̴�����Ϣ
    Result := CallWindowProcW(FOldWndProc, HWND, uMsg, wParam, lParam)
  else
  begin
    Result := 0;
    // ϵͳ������������ťʱ�ᷢ�������Ϣ������, �����������TaskbarList�����Ż���Ч��
    if uMsg = FCreateButtonMessage then
    begin
      Refresh;
      FButtons.DoButtonCreated;
    end
    else // ������Ϣ
    begin
      // ͨ����Ϣ, ����ӵ�Ԥ�������ϵİ�ť��������, �����ڻ�ӵ�һ��ͨ����Ϣ
      if uMsg = WM_COMMAND then
      begin
        // wParam��λΪTHBN_CLICKED��Ϊ�°�ť������,
        if HiWord(wParam) = THBN_CLICKED then
        begin
          // ��λΪ��ťid
          Button := FButtons.FindByCommandId(LoWord(wParam));
          if Button <> nil then
            Button.Click;
        end;
      end;
      // ����ԭ���Ĵ��ڹ��̴���������Ϣ
      Result := CallWindowProcW(FOldWndProc, HWND, uMsg, wParam, lParam);
    end;
  end;
end;

procedure TWin7Taskbar.UpdateButton(Index: Integer);
var
  AButton: TThumbButton;
  Button: TTaskbarThumbButton;
begin
  if not(FCanCreate and Assigned(FTaskbarList)) then
    Exit;
  Button := FButtons.Button[Index];
  if Button = nil then
    Exit;
  // ��ť�����¼�����, ֪ͨҪ�ı�İ�ť����(��ʼ)�ı�
  Button.DoChanging;
  FillChar(AButton, SizeOf(AButton), 0);
  AButton.dwMask := THB_FLAGS or BitmapMask[Button.FImageIndex <> -1]
    or IconMask[Button.FIcon <> 0] or HintMask[Button.FShowHint];
  AButton.iId := Button.FCommandId;
  AButton.iBitmap := Button.FImageIndex;
  AButton.hIcon := Button.FIcon;
  CopyMemory(@AButton.szTip[0], PWideChar(Button.FHint),
    Length(Button.FHint) * SizeOf(WideChar));
  AButton.dwFlags := VisibleFlag[Button.Visible] or EnabledFlag[Button.Enabled]
    or TransparentFlag[Button.Transparent];
  FTaskbarList.ThumbBarUpdateButtons(FMainWindow, Index + 1, @AButton);
  // ��ť�����¼�����, ֪ͨҪ�ı�İ�ť�ı����
  Button.DoChanged;
end;

procedure TWin7Taskbar.UpdateOverlayIcon;
begin
  if not(FCanCreate and Assigned(FTaskbarList)) then
    Exit;
  // ֪ͨ������Сͼ���������(��ʼ)�ı�
  FOverlayIcon.DoChanging;
  FTaskbarList.SetOverlayIcon(FMainWindow, FOverlayIcon.FIcon,
    PWideChar(FOverlayIcon.FDescription));
  // ֪ͨ������Сͼ�����ı����
  FOverlayIcon.DoChanged;
end;

procedure TWin7Taskbar.UpdateProgress;
var
  AMax, APos: UINT64;
  AFlags: UINT;
begin
  if not(FCanCreate and Assigned(FTaskbarList)) then
    Exit;
  // �����������¼�����, ֪ͨ��������(��ʼ)�ı�
  FProgress.DoChanging;
  AMax := FProgress.FMax - FProgress.FMin;
  APos := FProgress.FPosition - FProgress.FMin;
  case FProgress.FState of
    psNoProgress:
      AFlags := TBPF_NOPROGRESS;
    psIndeterminate:
      AFlags := TBPF_INDETERMINATE;
    psNormal:
      AFlags := TBPF_NORMAL;
    psError:
      AFlags := TBPF_ERROR;
    psPaused:
      AFlags := TBPF_PAUSED;
  else
    AFlags := TBPF_NOPROGRESS;
  end;
  FTaskbarList.SetProgressState(FMainWindow, AFlags);
  if FProgress.FState <> psIndeterminate then
    // ����������ʽΪTBPF_INDETERMINATEʱ,����Ҫ���ý���ֵ,����Ч���ͺ�TBPF_NORMALһ����
    FTaskbarList.SetProgressValue(FMainWindow, APos, AMax);
  // �����������¼�����, ֪ͨ����ı����
  FProgress.DoChanged;
end;

procedure TWin7Taskbar.UpdateImageList;
begin
  if not(FCanCreate and Assigned(FTaskbarList)) then
    Exit;
  // ��ť���϶����¼�����, ֪ͨ����(��ʼ)�ı�
  FButtons.DoChanging;
  FTaskbarList.ThumbBarSetImageList(FMainWindow, FButtons.ImageList);
  // ��ť���϶����¼�����, ֪ͨ�ı����
  FButtons.DoChanged;
end;

procedure TWin7Taskbar.Refresh;
begin
  if not FCanCreate then
    Exit;
  if not Assigned(FTaskbarList) then
  // ����com����
  begin
    CoCreateInstance(CLSID_TaskbarList, nil, CLSCTX_ALL, IID_ITaskbarList4,
      FTaskbarList);
    FTaskbarList.HrInit;
  end;
  AppendButton;
  UpdateImageList;
  FButtons.UpdateVisible;
  UpdateProgress;
  UpdateOverlayIcon;
end;

end.


