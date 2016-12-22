unit fcNetwork;

interface

uses
  Forms, ShellAPI, Controls, Windows, Generics.Collections, SysUtils, Classes, winsock ;

type
  Network = record
    /// <summary>
    /// �����������ָ����ַ��
    /// </summary>
    /// <seealso>GetOpenHttpURLHandle</seealso>
    /// <param name="sURL"></param>
    /// <returns></returns>
    class function OpenHttpURL(sURL: String): Boolean; static;

    //��ȡĬ��������ĳ�������
    class function GetDefaultBrowerFileName: string; static;

    /// <summary>
    /// ����Ĭ���������ָ����ַ�����ʧ��������IE�򿪡�
    /// </summary>
    /// <param name="AUrl"></param>
    /// <returns></returns>
    class function GetOpenHttpURLHandle(const AUrl: String): THandle; static;

    /// <summary>
    /// ���ж�һ���ַ����Ƿ�ΪIPV4�ĺϷ���ַ��
    /// </summary>
    /// <param name="AIP"></param>
    /// <returns></returns>
    class function IsIPAddressV4(const AIP: string): Boolean; static;

    /// �ж�IP V4 ��ַ�Ƿ���һ��������ַ
    class function IsLanIPAddress(const AIP: String): Boolean; static;

    class function GetLocalIP(const AList : TStrings):Boolean; static;
  end;

implementation

uses
  fcStr, fcRegistry;

class function Network.OpenHttpURL(sURL: String): Boolean;
var
  l_BrowserFn, l_Cmd: string;
begin
  l_Cmd := fcRegistry.Reg.SH_GetKeyValue(HKEY_CLASSES_ROOT, 'HTTP\shell\open\command', '');
  if Pos('%1', l_Cmd)>0 then
  begin
    l_Cmd := Str.FastReplace(l_Cmd, '%1', sURL);
    if WinExec(PAnsiChar(AnsiString(l_Cmd)), SW_SHOW)>32 then
    begin
      Exit(True);
    end;
  end;

  l_BrowserFn := GetDefaultBrowerFileName;
  Result := ShellExecute(0, 'open', pchar(l_BrowserFn), pchar(sURL), nil, sw_show)>=32;
end;

class function Network.GetDefaultBrowerFileName: string;
begin
  Result := fcRegistry.Reg.SH_GetKeyValue(HKEY_CLASSES_ROOT, 'HTTP\shell\open\command', '');
  if Result<>'' then
  begin
    if Result[1] = '"' then
    begin
      Delete(Result, 1, 1);
      Result := Str.GetTokenBeforeChar(Result, '"');
    end
    else
    begin
      Result := Str.GetTokenBeforeChar(Result, ' ');
    end;
  end;
  if not FileExists(Result) then
    Result := 'IEXPLORE.EXE';
end;

class function Network.GetLocalIP(const AList: TStrings): Boolean;
type
  TaPInAddr = array [0..10] of PInAddr;   //���ڴ洢���ip��ַ�б�
  PaPInAddr = ^TaPInAddr;
var
  phe  : PHostEnt;
  pptr : PaPInAddr;
  Buffer : array [0..63] of ansichar;    //store hostname
  I    : Integer;
  GInitData      : TWSADATA;
  wVersion:word;
begin
  wVersion:=MAKEWORD(1,1);     //winsock dll version
  Result := False;
  if WSAStartup(wVersion, GInitData)=0 then   //��ʼ��windows socket
  begin
    phe := nil;
    if GetHostName(@Buffer[0], SizeOf(Buffer))=0 then  //���������
      phe :=GetHostByName(buffer);
    if phe = nil then
       Exit;
    pptr := PaPInAddr(Phe^.h_addr_list);
    I := 0;
    while pptr^[I] <> nil do
    begin
      AList.Add(string(StrPas(inet_ntoa(pptr^[I]^))));
      Inc(I);
      Result  :=  True;
    end;
    WSACleanup;           //�رա�����windows socket
  end;
end;

class function Network.GetOpenHttpURLHandle(const AUrl: String): THandle;
begin
  Result := ShellExecute(0, 'open', pchar(AUrl), nil, nil, sw_show);
  if Result < 32 then
    Result := ShellExecute(0, 'open', pchar('IEXPLORE.EXE'), pchar(AUrl), nil,
      sw_show);
end;

class function Network.IsIPAddressV4(const AIP: string): Boolean;
var
  l_List: TStringList;
begin
  l_List := TStringList.Create;
  try
    Str.GetTokenToList(AIP, '.', l_List, 4);
    Result := (StrToIntDef(l_List[0], -1) in [1 .. 255]) and
      (StrToIntDef(l_List[1], -1) in [0 .. 255]) and (StrToIntDef(l_List[2], -1) in [0 .. 255])
      and (StrToIntDef(l_List[3], -1) in [0 .. 255]);
  finally
    l_List.Free;
  end;
end;

class function Network.IsLanIPAddress(const AIP: String): Boolean;
const
  LanIPStr : array[0..4] of String = (
    '127.0.0.1',
    '10.',
    '169.',
    '172.',
    '192.168.');
var
  I : Integer;
begin
  Result := false;
  for I := Low(LanIPStr) to High(LanIPStr) do
    if fcStr.Str.IsStartWith(LanIPStr[I], AIP, True) then
      Exit(True);
end;

end.
