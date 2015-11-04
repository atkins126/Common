unit StreamZip;

interface
uses Classes, zlib;

procedure ZipStream(const instream, outStream: TStream; ZipType:integer); stdcall;
procedure UnZipStream(const instream: TStream; const outStream: TStream); stdcall;

implementation

uses SysUtils;


//��ѹ��
procedure ZipStream(const instream, outStream: TStream; ZipType:integer);
{
//instream�� ��ѹ�����Ѽ����ļ���
//outStream  ѹ��������ļ���
//ZipType:ѹ����׼
}
var
 ys: TCompressionStream;
begin
  //��ָ��ָ��ͷ��
  inStream.Position := 0;
  //ѹ����׼��ѡ��
  case ZipType of
  1:  ys := TCompressionStream.Create(clnone,OutStream);     //��ѹ��
  2:  ys := TCompressionStream.Create(clFastest,OutStream);  //����ѹ��
  3:  ys := TCompressionStream.Create(cldefault,OutStream);  //��׼ѹ��
  4:  ys := TCompressionStream.Create(clmax,OutStream);      //���ѹ��
  else
    ys := TCompressionStream.Create(clFastest,OutStream);
  end;

  try
    //ѹ����
    ys.CopyFrom(inStream, 0);
  finally
    FreeAndNil(ys);
  end;
end;

//����ѹ
procedure UnZipStream(const instream: TStream; const outStream: TStream);
var
 jyl: TDeCompressionStream;
 buf: array[1..4096] of byte;
 sjread: integer;
begin
  inStream.Position := 0;
  jyl := TDeCompressionStream.Create(inStream);
  try
    repeat
     //����ʵ�ʴ�С
     sjRead := jyl.Read(buf, sizeof(buf));
     if sjread > 0 then
       OutStream.Write(buf, sjRead);
    until (sjRead = 0);
  finally
    FreeAndNil(jyl);
  end;
end;

end.
