unit fcDatabase;

interface

uses
  SysUtils, ComObj, ADOInt, Variants;

type
  //���ݿ�
  Database = record
    type
      //Access���ݿ�
      Access = record
        class function CreateDatabase(const AFileName : string; const APassword : string = '') : boolean; static;
        class function RefreshCache(const AConnection: _Connection) : Boolean; static;
        class function CompactDatabase(const AFileName, APassWord: string): Boolean; static;
      end;
  end;

implementation

uses
  Windows, fcWindows, fcFile, uCFConsts;

{ Database.Access }

class function Database.Access.CreateDatabase(const AFileName,
  APassword: string): boolean;
var
  sTempFileName : string;
  vCatalog : OleVariant;
begin
  sTempFileName :=  Win.GetTempFileName;
  try
    vCatalog  :=  CreateOleObject('ADOX.Catalog');
    vCatalog.Create(Format(ConnectionString_Access,[sTempFileName, APassword]));
    vCatalog.ActiveConnection.Close;
    result  :=  Files.CopyFile(sTempFileName, AFileName);
    Files.DeleteFile(sTempFileName);
    vCatalog  :=  null;
  except
    result  :=  false;
  end;
end;

class function Database.Access.RefreshCache(
  const AConnection: _Connection): Boolean;
var
  vJE : OleVariant;
begin
  try
    vJE :=  CreateOleObject('JRO.JetEngine');
    OleCheck(vJE.RefreshCache(AConnection));
    Result  :=  True;
    vJE :=  Null;
  except
    Result  :=  False;
  end;
end;

class function Database.Access.CompactDatabase(const AFileName, APassWord: string): Boolean;
var
  sTempFileName: String;
  vJE: OleVariant;
begin
  sTempFileName := Win.GetTempFileName;
  DeleteFile(PWideChar(sTempFileName)); //ɾ��Windows������0�ֽ��ļ�
  try
    vJE := CreateOleObject('JRO.JetEngine'); //����OLE����,��������OLE���󳬹��������Զ��ͷ�
    OleCheck(vJE.CompactDatabase(format(ConnectionString_Access,[AFileName,APassWord]),
    Format(ConnectionString_Access,[sTempFileName,APassWord]))); //ѹ�����ݿ�
    //���Ʋ�����Դ���ݿ��ļ�,�������ʧ���������ؼ�,ѹ���ɹ���û�дﵽ�����Ĺ���
    result := Files.CopyFile(sTempFileName, AFileName);
    Files.DeleteFile(sTempFileName); //ɾ����ʱ�ļ�
    vJE :=  Null;
  except
    result:=false; //ѹ��ʧ��
  end;
end;

end.
