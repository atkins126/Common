unit fcWindows;

interface

uses
  Classes, SysUtils, Windows, StrUtils, ShellAPI, ShlObj, CommCtrl, ActiveX,
  Forms, TLHelp32, Messages;

type
  {
    GetVersionEx �����Ѿ���������ʹwin10��Ҳֻ�ܻ��6.2
  }
  // Windows functions
  TSystemFolderType = (spAppData, spStartUp, spDesktop, spSendTo, spPrograms, spStartMenu,
    spQuickLanuch, spSystem32, spMyDocument, spProgramFiles, spSkin, spDmResource);

  Win = record
  type
    TWinVersion = (wvUnknown, wvWin95, wvWin98, wvWin98SE, wvWinNT, wvWinME, wvWin2000, wvWinXP,
      wvVista, wvWin7, wvWin8OrLater);

    class function GetInstanceFileName: string; static;
    class function GetInstancePath: string; static;
    class function GetLastErrorText: string; static;

    /// <summary>
    /// ��ȡWindows����ʱĿ¼�����û�зָ�����
    /// </summary>
    class function GetTempDirectory: string; static;

    /// <summary>
    /// ��ȡWindows����ʱĿ¼������зָ�����
    /// </summary>
    class function GetTempPath: string; static;

    /// <summary>
    /// ����ʱ���ȡһ������ļ���
    /// </summary>
    /// <param name="ADir">ָ��Ŀ¼</param>
    /// <returns>System.string</returns>
    class function GetRandomFileName(const ADir: String): string;static;

    /// <summary>
    /// ��ȡһ��Windows����ʱĿ¼�µ���ʱ�ļ�·��
    /// </summary>
    class function GetTempFileName: string; overload; static;

    /// <summary>
    /// ��ȡָ��Ŀ¼�µ���ʱ�ļ�·��
    ///
    /// </summary>
    /// <param name="ADir">ָ��Ŀ¼</param>
    /// <returns>string����ʱ�ļ�·��</returns>
    class function GetTempFileName(const ADir: string): string; overload; static;

    /// <summary>
    /// ��ȡָ��Ŀ¼�£�ָ����׺������ʱ�ļ�·��
    /// </summary>
    /// <param name="ADir">ָ��Ŀ¼</param>
    /// <param name="AFileExt">ָ����׺��</param>
    /// <returns>string����ʱ�ļ�·��</returns>
    class function GetTempFileName(const ADir: string; const AFileExt: string): string; overload;
      static;

    /// <summary>
    /// ��ȡWindows·��
    /// </summary>
    class function GetWindowsDirectory: string; static;

    /// <summary>
    /// ��ȡ���߳�ID
    /// </summary>
    /// <returns>DWORD�����߳�ID</returns>
    class function GetMainThreadID: DWORD; static;

    /// <summary>
    /// ����Ϣ�����߳������д��ڽ��й㲥
    /// </summary>
    /// <param name="Msg">��Ϣ</param>
    /// <param name="wParam">����wParam</param>
    /// <param name="lParam">����lParam</param>
    class procedure BroadcastMessage(Msg: UINT; wParam: wParam; lParam: lParam); static;

    class function IsWindow(const AHandle: HWND): Boolean; static;
    class function GetWinVersion: TWinVersion; static;
    class function GetWinVerIsVistaOrLater: Boolean; static;
    class function GetWinVerIsWin8OrLater: Boolean; static;

    class function GetUserIdleTime: DWORD; static;
    class function GetExeNameByProcessID(PID: DWORD): String; static;
    class function InFullScreen: Boolean; static;
    class function GetInputDesktopName: string; static; // ��ȡ��ǰ��������
    class function InLogonDesktop: Boolean; static;   // �Ƿ��ڵ�¼����
    class function InScreenDesktop: Boolean; static;  // �Ƿ�����������
    class function InDefaultDesktop: Boolean; static; // �Ƿ���Ĭ������


    class function ForegroundWindow(const HWND: HWND): Boolean; static;

    /// <summary>
    /// ��ȡϵͳ·��
    /// </summary>
    /// <param name="AFolder">CLIDL���ţ���ʾ�����Ŀ¼��shlObj.pas�ĵ�2017-2152������ض���</param>
    ///  CSIDL_DESKTOP                       = $0000;  ����
    ///  CSIDL_INTERNET                      = $0001;  Internet Explorer (icon on desktop)
    ///  CSIDL_PROGRAMS                      = $0002;  ������(Start Menu\Programs) D:\Documents and Settings\Administrator\����ʼ���˵�\����
    ///  CSIDL_CONTROLS                      = $0003;  �������
    ///  CSIDL_PRINTERS                      = $0004;  ��ӡ��
    ///  CSIDL_PERSONAL                      = $0005;  �ҵ��ĵ�
    ///  CSIDL_FAVORITES                     = $0006;  �ղؼ�
    ///  CSIDL_STARTUP                       = $0007;  ����
    ///  CSIDL_RECENT                        = $0008;  ����ĵ�
    ///  CSIDL_SENDTO                        = $0009;  ���͵�
    ///  CSIDL_BITBUCKET                     = $000a;  ����վ
    ///  CSIDL_STARTMENU                     = $000b;  ��ʼ�˵�
    ///  CSIDL_DESKTOPDIRECTORY              = $0010;  ����Ŀ¼
    ///  CSIDL_DRIVES                        = $0011;  �ҵĵ���
    ///  CSIDL_NETWORK                       = $0012;  �����ھ�
    ///  CSIDL_NETHOOD                       = $0013;  �����ھ�Ŀ¼
    ///  CSIDL_FONTS                         = $0014;  ����
    ///  CSIDL_COMMON_STARTMENU              = $0016;  //���õĿ�ʼ�˵�
    ///  CSIDL_COMMON_PROGRAMS               = $0017;
    ///  CSIDL_COMMON_STARTUP                = $0018;
    ///  CSIDL_COMMON_DESKTOPDIRECTORY       = $0019;
    ///  CSIDL_APPDATA                       = $001a; //D:\Documents and Settings\Administrator\Application Data
    ///  CSIDL_COMMON_FAVORITES          = $001f;
    ///  CSIDL_INTERNET_CACHE            = $0020;  D:\Documents and Settings\Administrator\Local Settings\Temporary Internet Files
    ///  CSIDL_COOKIES                   = $0021;   Cookies�ļ���
    ///  CSIDL_HISTORY                   = $0022;   ��ʷ�ļ���
    ///  CSIDL_COMMON_APPDATA            = $0023;
    ///  CSIDL_WINDOWS                   = $0024;   D:\WINNT
    ///  CSIDL_SYSTEM                    = $0025;   D:\WINNT\system32
    ///  CSIDL_PROGRAM_FILES             = $0026    D:\Program Files
    ///  CSIDL_MYPICTURES                = $0027    D:\Documents and Settings\Administrator\My Documents\My Pictures
    ///  CSIDL_PROFILE                   = $0028    D:\Documents and Settings\Administrator
    /// <returns>�ַ�����ϵͳ·��</returns>
    class function GetSystemFolderDir(AFolder: Integer): string; static;

    /// <summary>
    /// �ӳ�ָ��ʱ��
    /// </summary>
    /// <param name="lMilliSeconds">΢�뼶ʱ��</param>
    class procedure Delay(lMilliSeconds: DWORD); static;

    class function EnableDebugPrivilege: Boolean; static;


    /// <summary>
    /// ��ȡGUID�ַ������������ʧ�ܣ��᷵�ؿ�ֵ
    /// </summary>
    /// <returns>GUID</returns>
    class function GetGUID: string; static;

    /// <summary>
    /// �жϸ���Ŀ¼�Ƿ���ҪUACȨ�ޡ�
    // �жϷ�������������µļ���λ�ã�����ҪUAC��
    // ϵͳ��Ŀ¼��
    // CSIDL_WINDOWS                   = $0024;   C:\WINNT
    // CSIDL_SYSTEM                    = $0025;   C:\WINNT\system32
    // CSIDL_PROGRAM_FILES             = $0026    C:\Program Files
    /// </summary>
    /// <param name="ADir">Ŀ¼·��</param>
    /// <param name="ACheckUACEnabled">�Ƿ���UAC����״̬</param>
    /// <returns>��Ŀ¼�Ƿ���ҪUACȨ��</returns>
    class function DirectoryNeedUAC(ADir: string; const ACheckUACEnabled: Boolean = true): Boolean; static;

    /// <summary>
    /// ��ǰ��������Ŀ¼�Ƿ���ҪUACȨ��
    /// </summary>
    class function InstalledDirNeedUAC: Boolean; static;

    /// <summary>
    /// ��ǰϵͳ��UAC�Ƿ���
    /// </summary>
    class function IsUACEnabled: Boolean; static;

    /// <summary>
    /// ����ָ��Ŀ¼���ͣ���ȡϵͳ·����
    /// </summary>
    /// <param name="AFolderType">ϵͳĿ¼����</param>
    /// <returns>System.string</returns>
    class function GetSystemFolder(AFolderType: TSystemFolderType): string; static;

    class function GetDefaultExploreProgram: String; static;

    /// �ж�һ��dll�Ƿ���Ч
    /// ע�⣺������dll������dll�໥Ӱ�죬�������ܻ᷵����Ч
    class function DllIsValid(ADllFileName: string): Boolean; static;

    class function Vista_HasAdminAccess: Boolean; static;  ////�жϵ�ǰ��windows���û��Ƿ�������������ԱȨ��, ֻ��Vista win7��ʹ�ã� ������ϵͳ����false

    /// ����һ�����̣����ҵȴ����н���
    ///  function: �룬 ��ʱʱ��
    class function CreateProcessAndWaitFinished(ACmdLine: string; const ATimeOut: DWORD=MAXWORD; const AShowWindow : Word = SW_HIDE): Boolean; static;

    /// �жϾ���Ƿ��������,������Ϊ�����ھ��
    class function HandleCanAccess(const AHandle : HWND):Boolean; static;

    //��ϵͳ����Ա��Ȩ������AAppName�� ���Զ��жϵ�ǰ�Ľ����Ƿ���ϵͳ����ԱȨ�ޡ�
    class function ShellExecuteWithAdmin(AAppName: string; AParams: string; const ShowCmd: Integer= SW_SHOW): Boolean; static;

    //VistaȨ���£��Բ�ͬȨ�޽�����Ϣ��ͨ����
    class procedure ChangeWindowMessageFilter_Comm(AMsg: Cardinal); static;
    class procedure ChangeWindowMessageFilter_DragFiles; static;

    // ���IE�İ汾�� ���Ǵ�ע����ȡ������ֱ�Ӵ��ļ���ȡ�汾�š� ��Ϊע����ϲ�׼���ܱ��޸ġ�
    class function  GetIEVersion: string; static;
    class function  GetIEMainVersion: Integer; static;

    //�ж�һ��Ŀ¼�Ƿ���дȨ��
    //��Ϊ�����ܵ�һЩɱ�������Ӱ�죬��ȡĿ¼���Կ��ܲ�׼��ֱ���ô����ļ��ķ������ж�
    class function  DirectoryHasWriteAccess(ADir: string): Boolean; static;

  end;

  {��Ļ��ص�}
  Scrn = class
    class function DPIRatio: Single; static;    //DPI

    {��һ������תΪ��ǰdpi��ʾ�Ĵ�С
     ���磺
      �����ǰdpi��96�� ��1:1����
      �����ǰdpi��150%��96*150%=144�����򷵻�1:1.5
      200%�Ŵ���ʾʱ������2��
     ע�⣺ʹ����������Ļ�׼�ǰ�96dpi�����
    }
    class function ToCurrDpi(AInSize: Integer): Integer; static;
  end;

implementation

uses
  Registry, fcStr, fcRegistry, fcFile;

var
  HLib_PSAPI: HWND;
  EnumProcessModules: function(hProcess: THandle; lphModule: LPDWORD; cb: DWORD; var lpcbNeeded: DWORD): bool; StdCall;
  GetModuleFileNameEx : function(hProcess: HINST; hModule: HINST; lpFilename: PChar; nSize: DWORD): DWORD; stdcall;
  GetProcessImageFileName : function(hProcess: THandle; lpFilename: PChar; nSize: DWORD): DWORD; stdcall;
  ChangeWindowMessageFilter: function (msg: Cardinal; dwFlag : Word): BOOL; stdcall ;

{ Win }

function __BroadcastMessageEnumProc(AHandle: HWND; AParam: lParam): Boolean; stdcall;
var
  lpMsg: PMessage;
begin
  if (AParam <> 0) and Win.IsWindow(AHandle) then
  begin
    lpMsg := Pointer(AParam);
    PostMessage(AHandle, lpMsg.Msg, lpMsg.wParam, lpMsg.lParam);
  end;
  Result := True;
end;

class procedure Win.BroadcastMessage(Msg: UINT; wParam: wParam; lParam: lParam);
var
  mtid: DWORD;
  lpMsg: PMessage;
begin
  mtid := GetMainThreadID;
  new(lpMsg);
  try
    lpMsg.Msg := Msg;
    lpMsg.wParam := wParam;
    lpMsg.lParam := lParam;
    EnumThreadWindows(mtid, @__BroadcastMessageEnumProc, Integer(lpMsg));
  finally
    Dispose(lpMsg);
  end;
end;

class function Win.IsWindow(const AHandle: HWND): Boolean;
var
  Style: DWORD;
begin
  if not Windows.IsWindow(AHandle) then
    Exit(False);
  Style := GetWindowLong(AHandle, GWL_STYLE);
  Result := (Style and WS_SYSMENU = WS_SYSMENU) or (Style and WS_POPUP = WS_POPUP);
end;

class function Win.ShellExecuteWithAdmin(AAppName, AParams: string;
  const ShowCmd: Integer): Boolean;
var
  si : SHELLEXECUTEINFO;
begin
  if GetWinVerIsVistaOrLater and (not Vista_HasAdminAccess) then
  begin
    zeromemory(@si, sizeof(SHELLEXECUTEINFO));
    si.cbSize :=  sizeof(SHELLEXECUTEINFO);
    si.lpVerb :=  'runas';
    si.lpFile :=  pchar(AAppName);
    si.nShow  :=  ShowCmd;
    si.lpParameters := pchar(AParams);
    si.fMask  :=  SEE_MASK_NOCLOSEPROCESS;
    Result := ShellExecuteEx(@si);
  end
  else
    Result := ShellExecute(0, 'open', PChar(AAppName), PChar(AParams), nil, ShowCmd)>=32
end;


{$R-}class function Win.Vista_HasAdminAccess: Boolean;
const
  TokenElevationType = 18;
  TokenElevation = 20;
  TokenElevationTypeDefault = 1;
  TokenElevationTypeFull = 2;
  TokenElevationTypeLimited = 3;
var
  token: Cardinal;
  Elevation: DWord;
  dwSize: Cardinal;
begin
  Result  :=  false;
  if OpenProcessToken(GetCurrentProcess, TOKEN_QUERY, token) then
  try
    if GetTokenInformation(token, TTokenInformationClass(TokenElevation), @Elevation, SizeOf(Elevation), dwSize) then
    begin
      result  := Elevation <> 0;
    end;
  finally
    CloseHandle(token);
  end;
end; {$R+}

class function Win.GetIEMainVersion: Integer;
begin
  Result := StrToIntDef(fcStr.Str.GetTokenBeforeChar(Win.GetIEVersion, '.'), 0);
end;

class function Win.GetIEVersion: string;
var
  l_File: string;
begin
  l_File := Win.GetSystemFolder(spProgramFiles) + '\Internet Explorer\iexplore.exe';
  if FileExists(l_File) then
    Exit(fcFile.FileVersion.GetFileVersion(l_File));

  Result := fcRegistry.Reg.SH_GetKeyValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\Internet Explorer', 'svcVersion');
  if Result='' then
    Result := fcRegistry.Reg.SH_GetKeyValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\Internet Explorer', 'Version');
end;

class function Win.GetInputDesktopName: string;
var
  desk: HDESK;
  sname: array [0 .. MAX_PATH - 1] of char;
  len: DWORD;
begin // 'Screen-saver'
  Result := '';
  desk := OpenInputDesktop(DESKTOP_READOBJECTS, False, STANDARD_RIGHTS_READ);
  if desk = 0 then
    Exit
  else
  begin
    ZeroMemory(@sname[0], SizeOf(sname));
    GetUserObjectInformation(desk, UOI_NAME, @sname[0], SizeOf(sname), len);
    if len = 0 then
      Exit;
    Result := WideCharToString(sname);
    CloseDesktop(desk);
  end;
end;

class function Win.GetInstanceFileName: string;
var
  pPath: array [0 .. MAX_PATH] of char;
begin
  GetModuleFileName(HInstance, pPath, MAX_PATH);
  Result := pPath; // ShortNameToLongName(pPath);
end;

class function Win.GetInstancePath: string;
begin
  Result := ExtractFilePath(GetInstanceFileName);
end;

class function Win.GetLastErrorText: string;
begin
  Result := SysErrorMessage(GetLastError);
end;

class function Win.GetMainThreadID: DWORD;
var
  PID: DWORD;
  te32: THREADENTRY32;
  snap: THandle;
begin
  Result := 0;
  PID := GetCurrentProcessId;
  ZeroMemory(@te32, SizeOf(THREADENTRY32));
  te32.dwSize := SizeOf(THREADENTRY32);
  snap := CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, PID);
  if snap <> 0 then
  begin
    if Thread32First(snap, te32) then
    begin
      repeat
        if te32.th32OwnerProcessID = PID then
          Exit(te32.th32ThreadID);
      until not(Thread32Next(snap, te32));
    end;
  end;
end;

class function Win.GetRandomFileName(const ADir: String): String;
var
  sFileName: String;
begin
  ForceDirectories(ADir);
  repeat
    sFileName := ADir + '\' + FormatDateTime('yyyymmddhhnnsszzz', now);
    Sleep(1);
  until not FileExists(sFileName);
  result := sFileName;
end;

class function Win.GetTempPath: string;
begin
  Result := GetTempDirectory + '\';
end;

class function Win.GetTempFileName: string;
begin
  Result := GetTempFileName(GetTempPath);
end;

class function Win.GetTempFileName(const ADir: string): string;
var
  sFile: array [0 .. MAX_PATH] of char;
begin
  SysUtils.ForceDirectories(ADir);
  Windows.GetTempFileName(PChar(ADir), 'tmp', 0, sFile);
  Result := sFile;
  Windows.DeleteFile(sFile);
end;

class function Win.GetTempDirectory: string;
var
  Dir: array [0 .. MAX_PATH] of char;
begin
  if Boolean(Windows.GetTempPath(MAX_PATH, Dir)) then
    Result := strpas(Dir)
  else
  begin
    Windows.GetWindowsDirectory(Dir, MAX_PATH);
    Result := strpas(Dir) + '\temp';
    ForceDirectories(Result);
  end;

  if Result <> '' then
    if Result[Length(Result)] = '\' then
      Result := copy(Result, 1, Length(Result) - 1);

  if not DirectoryExists(Result) then
    ForceDirectories(Result);
end;

class function Win.GetTempFileName(const ADir, AFileExt: string): string;
begin
  Result := ChangeFileExt(GetTempFileName(ADir), AFileExt);
end;

class function Win.GetWindowsDirectory: string;
var
  sPath: array [0 .. MAX_PATH] of char;
begin
  Windows.GetWindowsDirectory(sPath, MAX_PATH);
  Result := sPath;
end;

class procedure Win.ChangeWindowMessageFilter_Comm(AMsg: Cardinal);
const
  MSGFLT_ADD = 1;
begin
  if GetWinVerIsVistaOrLater then
  begin

    @ChangeWindowMessageFilter :=GetProcAddress(LoadLibrary('user32.dll'),'ChangeWindowMessageFilter');
    if @ChangeWindowMessageFilter<>nil then //je?li mamy adres, oznacza, ?e program uruchomiono pod systemem Widndows 7 lub pod Vist?
    try
      ChangeWindowMessageFilter(AMsg , MSGFLT_ADD);
    except
    end;
  end;
end;

class procedure Win.ChangeWindowMessageFilter_DragFiles;
const
  WM_COPYGLOBALDATA = 73;
begin
  ChangeWindowMessageFilter_Comm(WM_COPYGLOBALDATA);
  ChangeWindowMessageFilter_Comm(WM_DROPFILES);
  ChangeWindowMessageFilter_Comm(WM_COPYDATA);
end;

class function Win.CreateProcessAndWaitFinished(ACmdLine: string;
  const ATimeOut: DWORD; const AShowWindow : Word): Boolean;
var
  SI: TStartupInfo;
  PI: TProcessInformation;
begin
  FillChar(SI, SizeOf(SI), 0);
  SI.cb := SizeOf(SI);
  SI.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
  SI.wShowWindow := AShowWindow;
  Result := CreateProcess(nil,
                          PChar(ACmdLine),
                          nil,
                          nil,
                          True,
                          0,
                          nil,
                          nil,
                          SI,
                          PI);
  try
    WaitForSingleObject(PI.hProcess, ATimeOut * 1000);
  finally
    // Close all remaining handles
    CloseHandle(PI.hThread);
    CloseHandle(PI.hProcess);
  end;
end;

class procedure Win.Delay(lMilliSeconds: DWORD);
var
  l_Event: THandle;
begin
  l_Event := CreateEvent(nil, True, False, nil);
  waitforSingleObject(l_Event, lMilliSeconds);
  CloseHandle(l_Event);
end;

class function Win.EnableDebugPrivilege: Boolean;
var
  hToken: THandle;
  tp: TTokenPrivileges;
  rl: Cardinal;
begin
  Result := False;
  OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken);
  if LookupPrivilegeValue(nil, 'SeDebugPrivilege', tp.Privileges[0].Luid) then
  begin
    tp.PrivilegeCount := 1;
    tp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
    Result := AdjustTokenPrivileges(hToken, False, tp, SizeOf(tp), nil, rl);
  end;
end;

class function Win.ForegroundWindow(const HWND: HWND): Boolean;
var
  ForegroundThreadID: DWORD;
  ThisThreadID: DWORD;
  timeout: DWORD;
begin
  if IsIconic(HWND) then
    ShowWindow(HWND, SW_RESTORE);
  if GetForegroundWindow = HWND then
    Result := True
  else
  begin // �����һ��ҕ�����I�P foucs��Windows 98/2000 ��������һ��ҕ���е�ǰ��
    if ((Win32Platform = VER_PLATFORM_WIN32_NT) and (Win32MajorVersion > 4)) or
      ((Win32Platform = VER_PLATFORM_WIN32_WINDOWS) and
        ((Win32MajorVersion > 4) or ((Win32MajorVersion = 4) and (Win32MinorVersion > 0))))
      then
    begin
      Result := False;
      ForegroundThreadID := GetWindowThreadProcessID(GetForegroundWindow, nil);
      ThisThreadID := GetWindowThreadProcessID(HWND, nil);
      if AttachThreadInput(ThisThreadID, ForegroundThreadID, True) then
      begin
        BringWindowToTop(HWND);
        SetForegroundWindow(HWND);
        AttachThreadInput(ThisThreadID, ForegroundThreadID, False);
        Result := (GetForegroundWindow = HWND);
      end;
      if not Result then
      begin
        SystemParametersInfo(SPI_GETFOREGROUNDLOCKTIMEOUT, 0, @timeout, 0);
        SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, TObject(0), SPIF_SENDCHANGE);
        BringWindowToTop(HWND);
        SetForegroundWindow(HWND);
        SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, TObject(timeout),
          SPIF_SENDCHANGE);
      end;
    end
    else
    begin
      BringWindowToTop(HWND);
      SetForegroundWindow(HWND);
    end;
    Result := (GetForegroundWindow = HWND);
  end;
end;

class function Win.GetExeNameByProcessID(PID: DWORD): String;
var
  hProc: HWND;
  hMod: hModule;
  dwSize: DWORD;
  szName: array [0 .. MAX_PATH - 1] of char;
begin
  Result := '';
  hProc := OpenProcess(PROCESS_ALL_ACCESS, False, PID);
  if hProc > 0 then
    try
      if Assigned(GetProcessImageFileName) and (GetProcessImageFileName(hProc, szName,
          MAX_PATH) > 0) then
      begin
        Exit(szName);
      end
      else if Assigned(EnumProcessModules) and Assigned(GetModuleFileNameEx) then
      begin
        if EnumProcessModules(hProc, @hMod, SizeOf(hMod), dwSize) then
        begin
          ZeroMemory(@szName[0], SizeOf(szName));
          GetModuleFileNameEx(hProc, hMod, szName, MAX_PATH);
          Result := szName;
        end;
      end;
    finally
      CloseHandle(hProc);
    end;
end;

class function Win.GetSystemFolderDir(AFolder: Integer): string;
var
  vItemIDList: PItemIDList;
  vBuffer: array [0 .. MAX_PATH] of char;
begin
  SHGetSpecialFolderLocation(0, AFolder, vItemIDList);
  SHGetPathFromIDList(vItemIDList, vBuffer); // ת�����ļ�ϵͳ��·��
  Result := vBuffer;
end;

class function Win.GetUserIdleTime: DWORD;
var
  lii: TLastInputInfo;
begin
  ZeroMemory(@lii, SizeOf(TLastInputInfo));
  lii.cbSize := SizeOf(TLastInputInfo);
  if GetLastInputInfo(lii) then
    Result := GetTickCount - lii.dwTime
  else
    Result := 0;
end;

class function Win.GetWinVerIsVistaOrLater: Boolean;
var
  osVerInfo: TOSVersionInfo;
begin
  osVerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  Result := GetVersionEx(osVerInfo)
    and (osVerInfo.dwPlatformId=VER_PLATFORM_WIN32_NT)
    and (osVerInfo.dwMajorVersion>=6);
end;

class function Win.GetWinVerIsWin8OrLater: Boolean;
var
  osVerInfo: TOSVersionInfo;
begin
  osVerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  Result := GetVersionEx(osVerInfo)
    and (osVerInfo.dwPlatformId=VER_PLATFORM_WIN32_NT)
    and (
         ( (osVerInfo.dwMajorVersion=6) and (osVerInfo.dwMinorVersion>1))
         or (osVerInfo.dwMajorVersion>6)
        ) ;
end;

class function Win.GetWinVersion: TWinVersion;
var
  osVerInfo: TOSVersionInfo;
  majorVersion, minorVersion: Integer;
begin
  Result := wvUnknown;
  osVerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  if GetVersionEx(osVerInfo) then
  begin
    minorVersion := osVerInfo.dwMinorVersion;
    majorVersion := osVerInfo.dwMajorVersion;
    case osVerInfo.dwPlatformId of
      VER_PLATFORM_WIN32_NT:
        begin
          if majorVersion <= 4 then
            Result := wvWinNT
          else if (majorVersion = 5) and (minorVersion = 0) then
            Result := wvWin2000
          else if (majorVersion = 5) and (minorVersion = 1) then
            Result := wvWinXP
          else if (majorVersion = 6) and (minorVersion = 0) then
            Result := wvVista
          else if (majorVersion = 6) and (minorVersion = 1) then
            Result := wvWin7
          else if (majorVersion = 6) and (minorVersion > 1) or (majorVersion>6) then
            Result := wvWin8OrLater;
        end;
      VER_PLATFORM_WIN32_WINDOWS:
        begin
          if (majorVersion = 4) and (minorVersion = 0) then
            Result := wvWin95
          else if (majorVersion = 4) and (minorVersion = 10) then
          begin
            if osVerInfo.szCSDVersion[1] = 'A' then
              Result := wvWin98SE
            else
              Result := wvWin98;
          end
          else if (majorVersion = 4) and (minorVersion = 90) then
            Result := wvWinME
          else
            Result := wvUnknown;
        end;
    end;
  end;
end;

class function Win.HandleCanAccess(const AHandle: HWND): Boolean;
var
  PID: DWORD;
  hProc : THandle;
begin
  Result  :=  IsWindow(AHandle);
  if Result then
    if GetWindowThreadProcessID(AHandle, @PID) > 0 then
    begin
      hProc :=  OpenProcess(PROCESS_ALL_ACCESS, False, PID);
      Result  :=  hProc > 0;
      if Result then
        CloseHandle(hProc);
    end;
end;

class function Win.InDefaultDesktop: Boolean;
var
  sname: string;
begin
  sname := GetInputDesktopName;
  Result := SameText(sname, 'Default');
end;

class function Win.InFullScreen: Boolean;
var
  p: TPoint;
  h1, h2, h3, h4: HWND;
  p1, p2, p3, p4: DWORD;
  sName: string;
begin
  p := Point(1, 1);
  h1 := WindowFromPoint(p);
  p := Point(Screen.Width - 1, 1);
  h2 := WindowFromPoint(p);
  p := Point(1, Screen.Height - 1);
  h3 := WindowFromPoint(p);
  p := Point(Screen.Width - 1, Screen.Height - 1);
  h4 := WindowFromPoint(p);
  GetWindowThreadProcessID(h1, @p1);
  GetWindowThreadProcessID(h2, @p2);
  GetWindowThreadProcessID(h3, @p3);
  GetWindowThreadProcessID(h4, @p4);
  Result := (p1 = p2) and (p1 = p3) and (p1 = p4);
  if Result then
  begin
    sName := ExtractFileName(GetExeNameByProcessID(p1));
    Result := (sName <> '') and not SameText(sName, 'explorer.exe');
  end;
end;

class function Win.InLogonDesktop: Boolean;
var
  sname: string;
begin
  sname := GetInputDesktopName;
  Result := SameText(sname, 'winlogon') or (sname = '') and
    (GetLastError = ERROR_ACCESS_DENIED);
end;

class function Win.InScreenDesktop: Boolean;
var
  sname: string;
begin
  sname := GetInputDesktopName;
  Result := SameText(sname, 'Screen-saver') or SameText(sname, 'Screen saver');
end;

class function Win.GetGUID: string;
var
  id  : TGuid;
begin
  if CoCreateGuid(id) = S_OK then
    result  :=  GuidToString(id)
  else
    result  :=  Str.RandomStr(32);
end;


class function Win.IsUACEnabled: Boolean;
begin
  result := GetWinVerIsVistaOrLater
    and (Reg.ReadKeyValue(HKEY_LOCAL_MACHINE,
        'Software\Microsoft\Windows\CurrentVersion\Policies\System', 'EnableLUA', 0) = 1);
end;

class function Win.DirectoryNeedUAC(ADir: string; const ACheckUACEnabled: Boolean): Boolean;
var
  l_WindowsDir: string;
  l_EspDirs: array [0 .. 2] of string;
  l_Idx: Integer;
begin
  result := False;

  if ACheckUACEnabled then
    if not IsUACEnabled then
      Exit;

  l_EspDirs[0] := UpperCase(GetSystemFolderDir($0024));
  l_EspDirs[1] := UpperCase(GetSystemFolderDir($0025));
  l_EspDirs[2] := UpperCase(GetSystemFolderDir($0026));

  l_WindowsDir := l_EspDirs[0];
  ADir := UpperCase(ADir);

  if (l_WindowsDir = '') or (ADir = '') then
    Exit;

  // �����ϵͳ��Ŀ¼��
  if (Length(ADir) = 3) and (ADir[1] = l_WindowsDir[1]) then
  begin
    result := true;
    Exit;
  end;

  for l_Idx := Low(l_EspDirs) to High(l_EspDirs) do
  begin
    if Pos(l_EspDirs[l_Idx], ADir) = 1 then
    begin
      result := true;
      Exit;
    end;
  end;
end;

class function Win.DllIsValid(ADllFileName: string): Boolean;
begin
  SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    Result  := LoadLibrary(PChar(ADllFileName)) > 0;
  finally
    SetErrorMode(0);
  end;
end;

class function Win.InstalledDirNeedUAC: Boolean;
begin
  result := DirectoryNeedUAC(ExtractFilePath(Application.ExeName));
end;

class function Win.GetSystemFolder(AFolderType: TSystemFolderType): String;
var
  PText: array [0 .. 255] of Char;
  laengde: Integer;
const
  l_Folder1 = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders';
  l_Folder2 = 'Software\Microsoft\Windows\CurrentVersion';
begin
  result := '';

  if AFolderType in [spAppData, spStartUp, spDesktop, spSendTo, spPrograms, spStartMenu,
    spQuickLanuch, spMyDocument] then
  begin
    case AFolderType of
      spAppData:
        result := Reg.ReadKeyValue(HKEY_CURRENT_USER, l_Folder1, 'AppData', '');
      spStartUp:
        result := Reg.ReadKeyValue(HKEY_CURRENT_USER, l_Folder1, 'StartUp', '');
      spDesktop:
        result := Reg.ReadKeyValue(HKEY_CURRENT_USER, l_Folder1, 'DeskTop', '');
      spSendTo:
        result := Reg.ReadKeyValue(HKEY_CURRENT_USER, l_Folder1, 'SendTo', '');
      spPrograms:
        result := Reg.ReadKeyValue(HKEY_CURRENT_USER, l_Folder1, 'Programs', '');
      spStartMenu:
        result := Reg.ReadKeyValue(HKEY_CURRENT_USER, l_Folder1, 'Start Menu', '');
      spMyDocument:
        result := Reg.ReadKeyValue(HKEY_CURRENT_USER, l_Folder1, 'Personal', '');
    end;
  end
  else if AFolderType = spSkin then
    result := ExtractFilePath(Application.ExeName) + 'Sys\Skins'
  else if AFolderType = spDmResource then
    result := ExtractFilePath(Application.ExeName) + 'Sys\Resource'
  else if AFolderType = spSystem32 then
  begin
    laengde := GetSystemDirectory(PText, MAX_PATH);
    result := copy(PText, 1, laengde);
  end
  else if AFolderType in [spProgramFiles] then
  begin
    case AFolderType of
      spProgramFiles:
        result := Reg.ReadKeyValue(HKEY_LOCAL_MACHINE, l_Folder2, 'ProgramFilesDir', '');
    end;
  end;
end;

class function Win.GetDefaultExploreProgram: String;
var
  RegF: TRegistry;
begin
  RegF := TRegistry.Create;
  try
    RegF.RootKey := HKEY_CLASSES_ROOT;
    RegF.OpenKey('HTTP\shell\open\command', true);

    result := Trim(RegF.ReadString('')); // "C:\Program Files\Internet Explorer\iexplore.exe" -nohome
  finally
    RegF.Free;
  end;

  if result <> '' then
  begin
    if result[1] = '"' then
    begin
      Delete(result, 1, 1);
      result := Str.GetTokenBeforeChar(result, '"', true, False);
    end
    else
    begin
      result := Str.GetTokenBeforeChar(result, ' ', true, False);
    end;
  end;

  if not FileExists(result) then
  begin
    result := 'IEXPLORE.EXE';
  end;
end;


class function Win.DirectoryHasWriteAccess(ADir: string): Boolean;
var
  l_FileName: string;
  l_Handle: Integer;
begin
  if not ForceDirectories(ADir) then
    Exit(False);

  if Str.IsEndWith('\', ADir, False) then
    l_FileName := ADir
  else
    l_FileName := ADir + '\';

  l_FileName := l_FileName + '$'+Str.RandomStr(10) + '.tmp';
  if not FileExists(l_FileName) then
  begin
    l_Handle := FileCreate(l_FileName);
    if l_Handle = -1 then
    begin
      Exit(False);
    end
    else
    begin
      Result := True;
      FileClose(l_Handle);
      DeleteFile(PWideChar(l_FileName));
    end;
  end
  else
    Result := DeleteFile(PWideChar(l_FileName));

end;

procedure InitAPI;
begin
  GetModuleFileNameEx := nil;
  HLib_PSAPI := SafeLoadLibrary('psapi.dll');
  if HLib_PSAPI > 0 then
  begin
    @EnumProcessModules := GetProcAddress(HLib_PSAPI, 'EnumProcessModules');
    @GetModuleFileNameEx := GetProcAddress(HLib_PSAPI, 'GetModuleFileNameExW');
    @GetProcessImageFileName := GetProcAddress(HLib_PSAPI, 'GetProcessImageFileNameW');
  end;
end;

procedure FinalAPI;
begin
  if HLib_PSAPI > 0 then
    FreeLibrary(HLib_PSAPI);
end;

{ Scrn }

class function Scrn.DPIRatio: Single;
begin
  Result := Screen.PixelsPerInch / 96;
end;

class function Scrn.ToCurrDpi(AInSize: Integer): Integer;
begin
  Result := AInSize * Screen.PixelsPerInch div 96;
end;

initialization

InitAPI;

finalization

FinalAPI;

end.
