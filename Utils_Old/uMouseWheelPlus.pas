unit uMouseWheelPlus;
(*******************************************************************************
��깳��,ʵ�ֽ���������Ϣ�������ָ��Ŀؼ�,�����ǻ�ý���Ŀؼ�
ע��,һЩ�ؼ��յ�������Ϣ�������Ϣת�������ĸ�����,�������:
  ���� MouseWheelHandler ����,��ʵ��Ϊ:
  message.result  :=  Perform(CM_MOUSEWHEEL, Message.WParam, Message.lParam);

������DevExpress�Ŀؼ�֧�������Ԫ,��Ҫ�޸�
cxControls��Ԫ,TcxControl��
���� MouseWheelHandler ����
  public
    procedure MouseWheelHandler(var Message: TMessage); override;
ʵ�� MouseWheelHandler, ��Ҫinherited
  procedure TcxControl.MouseWheelHandler(var Message: TMessage);
  begin
    message.result  :=  Perform(CM_MOUSEWHEEL, Message.WParam, Message.lParam);
  end;
�°汾��DevExpress�Ѿ�û�и���MouseWheelHandler������,��Ҫ�ֹ�����
//*****************************************************************************)

interface

uses
  Windows, Messages;

procedure InstallHook;
procedure UninstallHook;

implementation

type
  PMouseHookStructEx = ^TMouseHookStructEx;
  TMouseHookStructEx = record
    Base : TMouseHookStruct;
    mouseData : DWORD;
  end;

var
  hook: HHOOK;

function MouseHook(nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
  pt : TPoint;
  h : HWND;
  ms  : PMouseHookStructEx;
  mw  : TWMMouseWheel;
  pwind : HWND;
begin
  if wParam = WM_MOUSEWHEEL then
  begin
    GetCursorPos(pt);
    h :=  WindowFromPoint(pt);
    ms  :=  Pointer(lParam);
    pwind :=  h;
    while GetParent(pwind) > 0 do
      pwind :=  GetParent(pwind);
    if (ms.Base.hwnd <> h) and (GetActiveWindow = pwind) then
    begin
      mw.WheelDelta :=  HIWORD(ms.mouseData);
      if (mw.WheelDelta mod 120 <> 0) or (mw.WheelDelta > 1000) then
      begin //����64λWIN7�µ�����
        UninstallHook;
        InstallHook;
        Result := -1;
        Exit;
      end;
      mw.Msg  :=  WM_MOUSEWHEEL;
      mw.Keys :=  0;
      mw.XPos :=  ms.Base.pt.X;
      mw.YPos :=  ms.Base.pt.Y;//}
      PostMessage(h, mw.Msg, TMessage(mw).wParam, TMessage(mw).lParam);
      Result  :=  -1;
    end
    else
      Result := CallNextHookEx(hook, nCode, wParam, lParam);
  end
  else
    Result := CallNextHookEx(hook, nCode, wParam, lParam);
end;

procedure InstallHook;
begin
  hook := SetWindowsHookEx(WH_MOUSE, Addr(MouseHook), HInstance, GetCurrentThreadId);
end;

procedure UninstallHook;
begin
  if hook > 0 then
    UnhookWindowsHookEx(hook);
end;

initialization
  InstallHook;

finalization
  UninstallHook;
  
end.
