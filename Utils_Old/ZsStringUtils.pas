unit ZsStringUtils;

interface

uses
  Classes;

procedure QSortList(const AList: TStringList);

function FilterNoEffectChar(FileName: String{; CheckOnDiscTempFile: Boolean}): String;

function GetTokenBeforeChar(const Str, FlagToken : String; WantTrim, DefaultEmpty: Boolean) : String;

function GetTokenAfterChar(const Str, FlagToken : String; WantTrim, DefaultEmpty: Boolean) : String;

procedure GetTokenToList(const Str, FlagToken: string; var List: TStringList; DefaultItemCount : integer = -1);
procedure SplitStrToList(const Str: String; ASplit: String; var List: TStringList; DefaultItemCount : integer = -1);

function IsStartWith(const SubStr, Str : String; CaseSensitive : Boolean) : Boolean;

function IsEndWith(const SubStr, Str : String; CaseSensitive : Boolean) : Boolean;

function GetStrFromList(const List : TStringList; FlagToken : string; CaseSensitive : Boolean; const DefaultValue: String=''): string;

//==============================================================================
//��List�зǿյ�������Ϊһ���ַ�������','��Ϊ�ָ��ַ���
function ListToStr(const List: TStringList; const Sep:string = ','): string;

//==============================================================================
//��������ǰ�һ�����ֳɶ���Ӵ�������List�С�
//Sepָ������Щ�ַ���Ϊ�ָ�������
//������Ӵ���Ϊ�գ����Ҿ���Trim��
procedure StrToList(const Str:string; const List: TStringList; const Sep:string);

procedure EmailToList(const InStr:string; var List:TStringList);

function RandomStr(Len: Integer) : string;

function HzPy(sr: String): String;

function IndexOfArray(theValue: Integer; theArray: array of Integer): Integer; overload;
function IndexOfArray(theValue: String; theArray: array of String): Integer; overload;

//fromList��һ��һ�е���Ϣ��ÿ�ж���һ���Ⱥţ� �Ⱥ�ǰ�����ֶ����ƣ� ������ֵ�� �������һ�в�
//�������ڵڶ��п�ͷ��#9��ʼ��
function GetFieldValueFromList(fromList: TStringList; theFieldName: String;
  var sValue: String; const splitChar: String='='): boolean;

function GetGUID: String;

function FormatFileSize(AFileSize: Int64; const ADecimalLenOfM: Integer=1): String;

function IsChineseString(Str:String):boolean;
function IsEnglishString(Str:string):boolean;
function IsBig5String(const Str:string; DefaultValue: Boolean):boolean;

function SafeFormat(const Format: string; const Args: array of const): string;
function StringListTextLength(const AStringList: TStringList): Integer; //����һ��stringlist.text�ĳ��ȣ�����Length(AList.Text)�����ٶȿ�
function IfThen_Bool(AValue: Boolean; const ATrue: Boolean; const AFalse: Boolean ): Boolean ;

function CharPos(achar: Char; source: string; from: Integer): Integer;

implementation

uses
  Windows, SysUtils, JclStrings, FReplace, ZsFileUtils;

const
  CRLF = #13#10;

function SafeFormat(const Format: string; const Args: array of const): string;
begin
  try
    Result := SysUtils.Format(Format, Args);
  except
    Result := Format;
  end;
end;



//------------------------------------------------------------------------------

//ȡ��ĳһ����ǰ�Ĵ�
//WantTrim : ����ֵ�Ƿ�ҪTrimһ��
//DefaultEmpty : ����ƥ���Ƿ񷵻ؿ�ֵ
function GetTokenBeforeChar(const Str, FlagToken : String; WantTrim, DefaultEmpty: Boolean) : String;
var
  i : Integer;
  l_str, l_FlagToken: WideString;
begin
  //�����У������ܵ��ڶ��Լ�Ӱ�죬������ת����WideStr��ƥ��
  //�|�lԭ�ϴ����ܱ���20110219(1).xls|32256 �� ��|֮ǰ�ģ� �| �ֵĵڶ��ֽھ���|
  l_str := Str;
  l_FlagToken := FlagToken;

  i := Pos(l_FlagToken, l_str);

  if i <> 0 then
    Result := String( Copy(l_str, 1, i-1) )
  else if DefaultEmpty then
    Result := ''
  else
    Result := Str;

  if WantTrim then
    Result := Trim(Result);
end;

//ȡ��ĳһ����ǰ�Ĵ�
//WantTrim : ����ֵ�Ƿ�ҪTrimһ��
//DefaultEmpty : ����ƥ���Ƿ񷵻ؿ�ֵ
function GetTokenAfterChar(const Str, FlagToken : String; WantTrim, DefaultEmpty: Boolean) : String;
var
   i : Integer;
   l_str, l_FlagToken: WideString;
begin
  l_str := Str;
  l_FlagToken := FlagToken;
  i := Pos(l_FlagToken, l_str);

  if i <> 0 then
    Result := Copy(l_str, i+Length(l_FlagToken), Length(l_str))
  else if DefaultEmpty then
    Result := ''
  else
    Result := Str;

  if WantTrim then
    Result := Trim(Result);
end;

//��DefaultItemCount <> -1 ʱ���Զ�������ָ���ĳ���
procedure GetTokenToList(const Str, FlagToken: string; var List: TStringList; DefaultItemCount : integer);
var
  iCount : integer;
begin
  StrToList(Str, List, FlagToken);

  if DefaultItemCount <> -1 then
  begin
    for iCount := List.Count to DefaultItemCount -1 do
      List.Add('');
  end;
end;

procedure SplitStrToList(const Str: String; ASplit: String; var List: TStringList; DefaultItemCount : integer = -1);
var
  l_Pos, l_Start: Integer;
begin
  List.Clear;

  l_Start := 1;

  repeat
    l_Pos := FastPos(Str, ASplit, Length(Str), length(ASplit), l_Start);
    if l_Pos > 0 then
    begin
      List.Add(Copy(Str, l_Start, l_Pos-l_Start));
      l_Start := l_Pos + Length(ASplit);
    end
    else
      List.Add(Copy(Str, l_Start, Length(Str)));

  until l_Pos<=0;

  if DefaultItemCount > 0 then
    while List.Count < DefaultItemCount do
      List.Add('');

end;


//------------------------------------------------------------------------------
function IsStartWith(const SubStr, Str : String; CaseSensitive : Boolean) : Boolean;
begin
  if (CaseSensitive) then
    Result := 0 = StrCompareRange(SubStr, Str, 1, Length(SubStr))
  else
    Result := 0 = StrCompareRange(UpperCase(SubStr), UpperCase(Str), 1, Length(SubStr));
end;

function IsEndWith(const SubStr, Str : String; CaseSensitive : Boolean) : Boolean;
var
  rightStr : String;
begin
  if ('' = SubStr) or ('' = Str) then
  begin
    Result := False;
    Exit;
  end;

  rightStr := StrRight(Str, Length(SubStr));
  if (CaseSensitive) then
    Result := SubStr = rightStr
  else
    Result := UpperCase(SubStr) = UpperCase(rightStr);
end;


//------------------------------------------------------------------------------
// ��list �б��ж�ȡһ��flagstr�Ժ�Ĵ�������б��������������ַ�������������
// ֻȡ��һ����
function GetStrFromList(const List : TStringList; FlagToken : string;
  CaseSensitive : Boolean; const DefaultValue: String=''): string;
var
  i : integer;
  Buffer : String;
begin
  Result := DefaultValue;
  for i := 0 to List.Count -1 do
  begin
    Buffer := List[i];

    if IsStartWith(FlagToken, Buffer, CaseSensitive) then
    begin
      Result := Trim(Copy(Buffer, Length(FlagToken) + 1, Length(Buffer)) );
      break;
    end;
  end;
end;

function ListToStr(const List: TStringList; const Sep:string): string;
begin
  Result := StringsToStr(List, Sep, False);
end;

procedure StrToList(const Str:string; const List: TStringList; const Sep:string);
var
  curStr, l_Char: string;
  i, l_Pos : integer;
Label 111;
begin
  List.Clear;

  curStr := '';
  i := 1;
  while i <= Length(Str) do
  begin
    l_Char := Str[i];
    if (l_Char='"') and (Trim(CurStr)='') then  //�����ſ�ͷ�ģ����� "woodstock,zeng""" <263.net>, xqzeng@263.net��������Ҫ�����2��������3��
    begin
      111:
      l_Pos := FastPosNoCase(Str, '"', Length(Str), 1, i+1);
      if l_Pos>i then
      begin
        //����ּ�������������������ŵ�....
        if (l_Pos<Length(Str)) and (Str[l_Pos+1]='"') then
        begin
          CurStr := CurStr+ Copy(Str, i, l_Pos-i+2);
          i := l_Pos +2;
          goto 111;
        end
        else
        begin
          CurStr := CurStr + Copy(Str, i, l_Pos-i+1);
          i := l_Pos +1;
          Continue;
        end;
      end;
    end;
    if FastPosNoCase(Sep, l_Char, Length(Sep), 1, 1) >0 then
    begin
      List.Add(Trim(CurStr));
      CurStr := '';
    end
    else
    begin
      CurStr := CurStr + l_Char;
    end;
    Inc(i);
  end;
  List.Add(Trim(CurStr));

  for i := List.Count -1 downto 0 do
  begin
    if List[i] = '' then
      List.Delete(i);
  end;
end;

procedure EmailToList(const InStr:string; var List:TStringList);
begin
  StrToList(InStr, List, ';,');
end;

//------------------------------------------------------------------------------
function RandomStr(Len: Integer) : string;
var
  i : integer;
begin
  Result := '';
  for i := 1 to Len do
    Result := Result + IntToStr(Random(9)) ;
end;

//------------------------------------------------------------------------------
//��ȡһ�����ִ���ƴ��
//�磺 ���й���������-> ZGGCD
//����ַ�������Ӣ����ĸ��������ЩӢ����ĸ
const ChinaCode: array[0..25,0..1] of Integer = ((1601,1636), (1637,1832), (1833,2077),
      (2078,2273),(2274,2301),(2302,2432),(2433,2593),(2594,2786),(9999,0000),
      (2787,3105),(3106,3211),(3212,3471),(3472,3634),(3635,3721),(3722,3729),
      (3730,3857),(3858,4026),(4027,4085),(4086,4389),(4390,4557),(9999,0000),
      (9999,0000),(4558,4683),(4684,4924),(4925,5248),(5249,5589));    
function HzPy(sr: String): String;
var
   C1, Len1, C2: Integer;
   ir : Word;
begin
  Result := '';

  if sr = '' then Exit;
  if ord(sr[1]) < 160 then
  begin
    Result := Uppercase(sr[1]);
    Exit;
  end;

  C1 := 1;
  Len1 := Length(sr);
  while (C1 <= Len1) do
  begin
    if (ord(sr[C1])>=160) then
    begin
      if (ord(sr[C1+1])>=160) then
        ir := (ord(sr[C1])-160)*100 + ord(sr[C1+1])-160
      else //������ܻ������Ŀǰֻ������������Ϊ����ֻ���������ļ����4000���֡�
        ir := (ord(sr[C1])-160)*100 + ord(sr[C1+1]);

      for C2 := 0 to 25 do
      begin
        if (ir >= ChinaCode[C2,0]) and (ir <= ChinaCode[C2,1]) then
        begin
          Result := Result + chr(C2+ord('a'));
          break;
        end;
      end;
      C1 := C1 + 2;
    end
    else
    begin
      Result := Result + sr[C1];
      C1 := C1 + 1;
    end;
  end;
  Result := Uppercase( Result);
end;

//һ������һ�������е�λ��
function IndexOfArray(theValue: Integer; theArray: array of Integer): Integer;
var
  i: Integer;
begin
  Result := -1;

  if 0 <> SizeOf(theArray) then
  begin
    for i:= Low(theArray) to High(theArray) do
    begin
      if theValue = theArray[i] then
      begin
        Result := i;
        break;
      end;
    end;
  end;
end;

function IndexOfArray(theValue: String; theArray: array of String): Integer;
var
  i: Integer;
begin
  Result := -1;

  if 0 <> SizeOf(theArray) then
  begin
    for i:= Low(theArray) to High(theArray) do
    begin
      if theValue = theArray[i] then
      begin
        Result := i;
        break;
      end;
    end;
  end;
end;

function GetFieldValueFromList(fromList: TStringList; theFieldName: String;
  var sValue: String; const splitChar: String='='): boolean;
var
  name: String;
  j : integer;
  tempList : TStringList;
begin
  name := uppercase( theFieldName ) + splitChar;
  tempList := TStringList.Create;

  try
    Result := false;

    for j := 0 to fromList.Count -1 do
    begin
      if Result then
      begin
        if IsStartWith(#9, fromList[j], true) then
          tempList.Add(Trim(Copy(fromList[j], 2, Length(fromList[j]))))
        else
          break;
      end
      else if IsStartWith(name, uppercase(fromList[j]), true) then
      begin
        Result := true;
        tempList.Add(Trim(Copy(fromList[j], Length(name) + 1, Length(fromList[j]))));
      end;
    end;

    if Result then
      sValue := Trim(tempList.Text);
  finally
    tempList.Free;
  end;
end;

function GetGUID: String;
var gid: TGUID;
begin
  if CreateGUID(gid)=0 then
    Result := GUIDToString(gid)
  else
    Result := FormatDateTime('yyyymmddhhnnsszzz',now)+ RandomStr(8);
end;

function FormatFileSize(AFileSize: Int64; const ADecimalLenOfM: Integer=1): String;
  function GetDecimal: string;
  begin
    case ADecimalLenOfM of
      2: Result := '0.00';
      3: Result := '0.000';
    else
      Result := '0.0';
    end;
  end;
begin
  if AFileSize <= 0 then
    Result := '0.0 K'
  else
  if AFileSize <= 100 then
    Result := '0.1 K'
  else
  if AFileSize < 1024 * 1024 then
    Result := FormatFloat('0.0 K', AFileSize / 1024)
  else
    Result := FormatFloat(GetDecimal+' M', AFileSize / (1024*1024));
end;

function IsChineseString(Str : String):boolean;
var
  I : Integer;
  ansistr:AnsiString;
begin
  Result := false;
  if Str = '' then
    Exit;

  ansistr := AnsiString(Str);
  I := 1;
  while I < Length(ansistr) do
  begin
    if (ansistr[I] >= #$81) then
    begin
      if (ansistr[I+1] >= #$40) then
      begin
        Result := True;
        Exit;
      end;
      Inc(I,2);
    end
    else
    begin
      Inc(I);
    end;
  end;
end;

function IsEnglishString(Str:string):boolean;
begin
  Result := not IsChineseString(Str);
end;

//first byte:0xA1-0XFE
//second byte:0x40-0x7E, 0xA1-0xFE
function IsBig5String(const Str:string; DefaultValue: Boolean):boolean;
  //GB��A840-A895��A940-A996�Ǳ�����
  function IsChineseInterpunction(iByte : byte):boolean;
  begin
    Result := (iByte = $A8) or (iByte = $A9);
  end;
  function IsChineseFirstChar(iByte : byte):boolean;
  begin
    Result := (iByte > $A0) and (iByte < $FF);
  end;
  function IsTypicalBig5SecondChar(iByte : byte):boolean;
  begin
    Result := (iByte > $3F) and (iByte < $7F);
  end;
var
  i:integer;
  iByte:byte;
  bFirstByte,
  bSkipThisChar:boolean;
  iBig5Count, isGBCount:integer;
  iTotal:integer;
begin
  result := DefaultValue;
  bFirstByte := true;
  bSkipThisChar := false;

  iBig5Count := 0;
  isGBCount := 0;
  iTotal:=0;

  for i := 1 to Length(Str) do
  begin
    if bSkipThisChar then
    begin
      bSkipThisChar := false;
      continue;
    end;

    iByte := byte(Str[i]);

    if bFirstByte then
    begin
      if IsChineseInterpunction(iByte) then
        bSkipThisChar := true
      else if IsChineseFirstChar(iByte) then
        bFirstByte := false;
    end
    else
    begin
      bFirstByte := true;
      inc(iTotal);
      if IsTypicalBig5SecondChar(iByte) then
        inc(iBig5Count)
      else
        inc(isGBCount);
    end;
  end;

  if iBig5Count * 5 > itotal then
    result := true
  else
  if isGBCount > 0 then
    Result := false;
end;

// === �������� List
type
  PStringSortItem = ^TStringSortItem;
  TStringSortItem = record
    Str: String;
    Data: Pointer;
  end;
procedure QSortList(const AList: TStringList);
  procedure _QuickSort(var A: array of PStringSortItem; iLo, iHi: Integer);
  var
    Lo, Hi: Integer;
    Mid, T: PStringSortItem;
  begin
    Lo := iLo;
    Hi := iHi;
    Mid := A[(Lo + Hi) div 2];
    repeat
      while A[Lo].Str < Mid.Str do Inc(Lo);
      while A[Hi].Str > Mid.Str do Dec(Hi);
      if Lo <= Hi then
      begin
        T := A[Lo];
        A[Lo] := A[Hi];
        A[Hi] := T;
        Inc(Lo);
        Dec(Hi);
      end;
    until Lo > Hi;
    if Hi > iLo then _QuickSort(A, iLo, Hi);
    if Lo < iHi then _QuickSort(A, Lo, iHi);
  end;
var
  l_Idx: Integer;
  l_Arr1: array of PStringSortItem;
begin
  if AList.Count >1 then
  begin
    SetLength(l_Arr1, AList.Count);
    for l_Idx := 0 to AList.Count -1 do
    begin
      New(l_Arr1[l_Idx]);
      l_Arr1[l_Idx].Str := AList[l_Idx];
      l_Arr1[l_Idx].Data := AList.Objects[l_Idx];
    end;

    _QuickSort(l_Arr1, 0, High(l_Arr1));

    AList.Clear;
    for l_Idx := 0 to High(l_Arr1) do
    begin
      AList.AddObject(l_Arr1[l_Idx].Str, l_Arr1[l_Idx].Data);
    end;
  end; 
end;


//���˵�һЩ�ļ�����֧�ֵ��ַ���
//CheckOnDiscTempFile ָ���Ƿ�Ҫ��Ӳ���Ͻ�����ʱ�ļ���ȷ���ļ����Ƿ���ȷ������
function FilterNoEffectChar(FileName: String{; CheckOnDiscTempFile: Boolean}): String;
  function GetANewFileName(ATempPath: String): String;
  var
    l_Idx: Integer;
    l_Ext, l_LastFileName, l_NewFileName: String;
    l_Handle: Integer;
  begin
    l_Ext := ExtractFileExt(FileName);
    l_LastFileName := ATempPath+ '1'+l_Ext;

    for l_Idx := 1 to Length(FileName)-Length(l_Ext) do
    begin
      if l_Idx > 100 then Break;

      l_NewFileName := ATempPath + Copy(FileName, 1, l_Idx) + l_Ext;
      if FileExists(l_NewFileName) then
        Continue;

      l_Handle := FileCreate(l_NewFileName); 
      if l_Handle=-1 then
      begin
        Break;
      end
      else
      begin
        FileClose(l_Handle); 
        DeleteFile(l_NewFileName);
        l_LastFileName := l_NewFileName;
      end;
    end;

    Result := ExtractFileName(l_LastFileName);

  end;

var i, ii : integer;
  l_TmpFile, l_TempDir: String;
  l_Find: Boolean;
  l_Handle: Integer;
  l_ansifilename:AnsiString;
const NoEffectChar = '\/:*?"<>|';
      C_BasicChars = 'abcdefghijklmnopqrstuvwxyz~!@#$%^&()_+`-={}[];''.,1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ';
begin
  Result := FileName;
  for i:= 1 to Length(NoEffectChar) do
  begin
    ii := FastPosNoCase(FileName, NoEffectChar[i], Length(FileName), 1, 1);
    while ii > 0 do
    begin
      Delete(FileName, ii, 1);
      ii := Pos(NoEffectChar[i], FileName);
    end;
  end;

  //������û�������ַ�
  l_Find := false;
  for i := 1 to Length(FileName) do
  begin
    if FastPosNoCase(C_BasicChars, FileName[i], Length(C_BasicChars), 1, 1) <=0 then
    begin
      l_Find := True;
      Break;
    end;
  end;
  if not l_Find then
  begin
    Result := FileName;
    Exit;
  end;

  //����лس����У���ȡǰ���......
  if FastPosNoCase(FileName, #13, Length(FileName), 1, 1) >1 then
    FileName := GetTokenBeforeChar(FileName, #13, True, True);
  if FastPosNoCase(FileName, #10, Length(FileName), 1, 1) >1 then
    FileName := GetTokenBeforeChar(FileName, #10, True, True);

  try
    l_TempDir := ZsFileUtils.GetWindowsTempDirectory+'\DreamMail\';
    if not ForceDirectories(l_TempDir) then
      Exit;

    l_TmpFile := l_TempDir+FileName;
    if FileExists(l_TmpFile) then
      Exit;

    //������Ӳ���ϴ���һ���ļ�����������ɹ������ʾ����ļ��ǿ����õġ�
    l_Handle := FileCreate(l_TmpFile ); 
    if l_Handle=-1 then
    begin
      //��������charset�������ǣ������ŵ��ַ����������ַ�����ʱ��
      //����jp�����ܸ������������룬�������޷��򿪺ͱ��渽����
      //l_FindLargeChar := false;

      l_ansifilename := AnsiString(FileName);
      I := 1;
      while I < Length(l_ansifilename) do
      begin
        if (l_ansifilename[I] >= #$81) then
        begin
          if l_ansifilename[I+1] <#$40 then   //�ļ����϶������ˡ�����������
          begin
            l_ansifilename[I] := '_';
            Inc(I);
          end
          else
            Inc(I,2);
        end
        else
        begin
          Inc(I);
        end;
      end;
      FileName := string(l_ansifilename);

      //�ٴ���һ�Σ�������ɹ���������һ��Ĭ�ϵ��ļ�
      l_TmpFile := l_TempDir+FileName;
      if FileExists(l_TmpFile) then
        Exit;

      l_Handle := FileCreate(l_TmpFile);
      if l_Handle = -1 then
      begin
        FileName := GetANewFileName(l_TempDir);
      end
      else
      begin
        FileClose(l_Handle);
        DeleteFile(l_TmpFile);
      end;
    end
    else
    begin
      FileClose(l_Handle);
      DeleteFile(l_TmpFile);
    end;
  finally
    Result := FileName;
  end;
end;

function StringListTextLength(const AStringList: TStringList): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to AStringList.Count -1 do
    Result := Result + Length(AStringList[I])+2;
end;

function IfThen_Bool(AValue: Boolean; const ATrue: Boolean; const AFalse: Boolean ): Boolean ;
begin
  if AValue then
    Result := ATrue
  else
    Result := AFalse ;
end;

function CharPos(achar: Char; source: string; from: Integer): Integer;
var
  I: Integer;
begin
  for I := from to Length(source) do
    if source[from] = achar then
    begin
      Result := I;
      Exit;
    end;

  Result := -1;
end;


initialization
  Randomize;

end.
