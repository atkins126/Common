//Common Framework
//�ӿڶ��嵥Ԫ
{$I CommonFramework.inc}
unit uCFIntfDef;

interface

uses
  SysUtils, Classes, Windows
  {$IFDEF FRAMEWORK_INCLUDE_DB}, DB, DBClient, MidasLib{$ENDIF}
  ,uCFConsts, uCFTypedef;

type
  //�����ӿ�
  ICFInterface = interface
    ['{A53141F4-D12F-4C7E-8F67-13672D585D76}']
    function  ImplementObject : TObject;  //ʵ�ֽӿڵĶ���ʵ��
    procedure ReleaseInstance;            //�ͷŽӿ�/����
    procedure OnNotifyMessage(Msg: UINT; wParam: WPARAM; lParam: LPARAM); //�յ�֪ͨ��Ϣ
  end;

  //����ӿ�
  ICFManager = interface
    ['{79938A11-02E3-4E76-B07A-23E7C5ED65D6}']
    procedure RegisterInterface(const AIntf : ICFInterface);   //ע��ӿ�
    procedure UnregisterInterface(const AIntf : ICFInterface); //ע���ӿ�
    procedure NotifyMessage(Msg: UINT; wParam: WPARAM; lParam: LPARAM); //�㲥֪ͨ��Ϣ
  end;

  //��Ϣ�ӿ�
  ICFMessageHandled = interface
    ['{79ADCEF4-A3D1-4940-B24F-505B5F07C5EE}']
    procedure SetMessageEvent(const Value: TWndMethod);
    function  GetMessageEvent : TWndMethod;
    function  GetHandle : HWND;
  end;

  //XML���ӿ�
  ICFPropertiesXMLReader = interface
    ['{747E22B8-DA28-48D3-A84C-34444325C502}']
    function PropertiesReadFromXMLNode(const AIntf : IInterface; const ANodePath : string) : Boolean;
  end;
  ICFPropertiesXMLTextReader = interface
    ['{B2C40D22-675E-418C-B5F3-604B9DBCE273}']
    function PropertiesReadFromXML(const AXML : string; const ANodePath : string) : boolean;
  end;
  ICFPropertiesXMLFileReader = interface
    ['{986BF783-2ECF-47D5-8E47-56D50548ECFD}']
    function PropertiesReadFromXMLFile(const AFileName : string; const ANodePath : string) : Boolean;
  end;

  //XMLд�ӿ�
  ICFPropertiesXMLWriter = interface
    ['{02F46CB9-A562-42BE-8192-79AE85F44D11}']
    function PropertiesWriteToXMLNode(const AIntf : IInterface; const ANodePath : string) : Boolean;
  end;
  ICFPropertiesXMLTextWriter = interface
    ['{FC3DD24B-66C9-4CE5-A063-9A7FF0C506E2}']
    function PropertiesWriteToXML(var AXML : string; const ANodePath : string) : Boolean;
  end;
  ICFPropertiesXMLFileWriter = interface
    ['{8F8B0C41-5BAD-4CA0-829F-FB3EE628FDF6}']
    function PropertiesWriteToXMLFile(const AFileName : string; const ANodePath : string) : Boolean;
  end;

  //JSON���ӿ�
  ICFPropertiesJSONReader = interface
    ['{EDBB1E15-EE0C-47CB-84F0-D07FD0C39803}']
    function PropertiesReadFromJSONObject(const AIntf : IInterface; const APath : string) : Boolean;
  end;
  ICFPropertiesJSONTextReader = interface
    ['{6E0805DC-4A19-40CF-B7B3-A282BBA68BAE}']
    function PropertiesReadFromJSON(const AJSON : string; const APath : string) : boolean;
  end;
  ICFPropertiesJSONFileReader = interface
    ['{7C22767A-227E-4612-B8F4-6D6D6991E476}']
    function PropertiesReadFromJSONFile(const AFileName : string; const APath : string) : Boolean;
  end;

  //JSONд�ӿ�
  ICFPropertiesJSONWriter = interface
    ['{8DDC3A54-2E96-4E4A-B106-BF933C1356E5}']
    function PropertiesWriteToJSONObject(const AIntf : IInterface; const APath : string) : Boolean;
  end;
  ICFPropertiesJSONTextWriter = interface
    ['{2EE1AFB3-20B1-4F14-9F91-E2CDF574A4EC}']
    function PropertiesWriteToJSON(var AJSON : string; const APath : string) : Boolean;
  end;
  ICFPropertiesJSONFileWriter = interface
    ['{CC2E6AAD-CCCC-487D-B5CB-98061B8A5205}']
    function PropertiesWriteToJSONFile(const AFileName : string; const APath : string) : Boolean;
  end;

  //�ļ��洢�ӿ�
  ICFFileStorage = interface
    ['{4AE220F3-06BD-4937-B801-ED0D4D7AF308}']
    function SaveString(const ASection : string; const AKey : string; const AValue : string):boolean;
    function LoadString(const ASection : string; const AKey : string):string;
    function DeleteString(const ASection : string; const AKey : string):boolean;
    function DeleteSection(const ASection : string):boolean;
    function GetSectionKeys(const ASection : string; const AKeyList : TStrings):Integer;
  end;

  {$IFDEF FRAMEWORK_INCLUDE_DB}
  //DataSet���ӿ�
  ICFPropertiesDataSetReader = interface
    ['{CA1B8268-61C0-4916-AA61-178890469B39}']
    function PropertiesReadFromDataSet(const ADataSet : TDataSet) : Boolean;
  end;
  //DataSetд�ӿ�
  ICFPropertiesDataSetWriter = interface
    ['{C894B16B-87BB-4A2A-B437-CD3A4DE5A97E}']
    function PropertiesWriteToDataSet(const ADataSet : TDataSet) : Boolean;
  end;

  //���ݿ�洢�ӿ�
  ICFDataBaseStorage = interface(ICFInterface)
    ['{75143280-CBC8-4D0B-BD3C-08FD1DB47B47}']
    function  GetLastErrorMessage : string;                           //��ȡ���Ĵ�����Ϣ
    function  GetProvider : string;                                   //��ȡProvider
    procedure SetProvider(const AProvider : string);                  //����Provider
    procedure SetConnectionString(const AConnectStr : string);        //���������ַ���
    function  GetConnectionString : string;                           //��ȡ�����ַ���
    function  OpenConnection : Boolean;                               //������
    procedure CloseConnection;                                        //�ر�����
    function  GetConnected : boolean;                                 //��ȡ����״̬
    function  SupportTrans : boolean;                                 //�Ƿ�֧������
    procedure BeginTrans;                                             //��ʼ����
    procedure CommitTrans;                                            //�ύ����
    procedure RollbackTrans;                                          //�ع�����
    function  TableExists(const ATableName : string):boolean;         //���Ƿ����
    function  ExecSQL(const ASQL : string):boolean;                   //ִ��SQL
    function  Query(const ASQL : string; const AKeyField : string) : TClientDataSet;  //��ѯ����
    function  Update(const ADataSet : TClientDataSet):boolean;        //��������
    function  RefreshCache : Boolean;                                 //ˢ�»���
    //
    function  BaseQuery(const ASQL : string) : TDataSet;              //��ѯԭʼ���ݼ�
  end;
  {$ENDIF}

  //�ӿڳؽӿ�
  ICFInterfacePool = interface
    ['{C9780674-665D-4EF5-B5E6-DD96ED58DC0A}']
    //procedure RecycleInterface(const AIntf : ICFInterface);   //���սӿ�
    function  GetClearPoolInterval : Integer;                 //��ȡ����ص�ʱ����
    procedure SetClearPoolInterval(const AValue : Integer);   //��������ص�ʱ����
    procedure Push(Intf: IInterface);                         //ѹջ
    function  Pop: IInterface;                                //��ջ
    function  GetClearType: TPoolsClearType;
    procedure SetClearType(const Value: TPoolsClearType);
  end;

  //����ؽӿ�
  ICFObjectPool = interface
    ['{F13A5FA3-9462-4C2B-B5AF-66626060A36F}']
    //procedure RecycleObject(const AObj : TObject);            //���ն���
    function  GetClearPoolInterval : Integer;                 //��ȡ����ص�ʱ����
    procedure SetClearPoolInterval(const AValue : Integer);   //��������ص�ʱ����
    procedure Push(Obj: TObject);                             //ѹջ
    function  Pop: TObject;                                   //��ջ
    function  GetClearType: TPoolsClearType;
    procedure SetClearType(const Value: TPoolsClearType);
  end;//}

  //�ӿڹ�����
  ICFInterfaceBuilder = interface
    ['{DBA589BD-13EB-48E9-8A6D-AFD1E356328E}']
    function BuiltInterfaceGUID : TGUID;            //�������ӿڵ�GUID
    function BuildInterface : IInterface;           //�����ӿ�
    function SupportPool : Boolean;                 //�Ƿ�֧�ֳ�
    function GetPool : ICFInterfacePool;            //�ӿڳ�
  end;

  //��������
  ICFObjectBuilder = interface
    ['{640C8DCA-7D77-4F12-8B19-F368E2BE87DB}']
    function BuiltClass : TClass;                   //���������������
    function BuildObject : TObject;                 //��������
    function SupportPool : Boolean;                 //�Ƿ�֧�ֳ�
    function GetPool : ICFObjectPool;               //�����
  end;

  //������
  ICFAdapter = interface
    ['{AE1C0848-39E1-416E-BBB1-AF71CCFCCA6A}']
    function  GetCaller : TObject;                  //��ȡ������
    procedure SetCaller(const AObj : TObject);      //���õ�����
    function  GetAdapteeClass : TClass;             //��ȡ��������������
  end;//}

  //�������ӿ�
  ICFBuiltInterface = interface
    ['{49336D08-5FB8-45B1-97F2-7BE1F1C75BD1}']
    function  GetBuilder : ICFInterfaceBuilder;               //��ȡ������
    procedure SetBuilder(const AIntf : ICFInterfaceBuilder);  //���ù�����
  end;

  //�Զ����սӿ�
  ICFAuotRecycle = interface
    ['{32E047AA-8D6A-4D36-81AE-980D3D94822E}']
    function  GetAutoRecycle : boolean;
    procedure SetAutoRecycle(const AValue : Boolean);
    function  GetCanAutoRecycle : Boolean;
  end;

  //�ӿڹ���
  ICFInterfaceFactory = interface
    ['{2BABC34E-5DF9-4C45-B521-8118E5104759}']
    function  CreateInterface(const AIntfGUID : TGUID) :  ICFInterface;
    procedure FreeInterface(const AIntf : ICFInterface);
    procedure RegisterBuilder(const ABuilder : ICFInterfaceBuilder);
    procedure UnregisterBuilder(const ABuilder : ICFInterfaceBuilder);
    procedure ClearBuilders(const AFree : Boolean);
  end;

  //����ӿ�
  ICFCommand  = interface
    ['{26C8EA54-058C-40E5-A7F5-303F4E6B7CEB}']
    function  CanExecute : Boolean;
    procedure Execute;
    function  GetResultCode : Integer;
    function  GetErrorMessage : string;
    function  GetID : Integer;
    procedure SetParameters(const AParameters : array of const);
    function  GetParameterCount : Integer;
    procedure SetParameterCount(const ACount : Integer);
    procedure SetParameter(const AIndex : Integer; const Value: Variant);
    function  GetParameter(const AIndex : Integer) : Variant;
    procedure Terminate;
  end;

  //����ִ�нӿ�
  ICFCommandExecutor = interface
    ['{C6B89AB7-3DB0-48E1-9200-E0A46D872735}']
    function  GetCommand: ICFCommand;
    procedure SetCommand(const Value: ICFCommand);
    function  GetBeforeExecuteCommand : TInterfaceNotifyEvent;
    procedure SetBeforeExecuteCommand(const Value: TInterfaceNotifyEvent);
    function  GetAfterExecuteCommand : TInterfaceNotifyEvent;
    procedure SetAfterExecuteCommand(const Value: TInterfaceNotifyEvent);
    function  GetIsRunning: Boolean;
    function  GetCanExecuteCommand: Boolean;
    function  CommandCanExecute: Boolean;
    function  ExecuteCommand(const ACommand: ICFCommand): Boolean;
    function  Start : Boolean;
    procedure Stop;
  end;

  //�����б�ִ�нӿ�
  ICFCommandListExecutor = interface
    ['{4DAE0DE6-CA36-4DAF-B3C8-0478B174908D}']
    function  GetCurrCommand: ICFCommand;
    function  GetBeforeExecuteCommand : TInterfaceNotifyEvent;
    procedure SetBeforeExecuteCommand(const Value: TInterfaceNotifyEvent);
    function  GetAfterExecuteCommand : TInterfaceNotifyEvent;
    procedure SetAfterExecuteCommand(const Value: TInterfaceNotifyEvent);
    function  GetOnExecuted: TNotifyEvent;
    procedure SetOnExecuted(const Value: TNotifyEvent);
    function  GetIsRunning: Boolean;
    procedure AddCommand(const ACommand: ICFCommand);
    function  CommandExists(const ACommandID : Integer):Boolean;
    procedure Clear;
    function  Start : Boolean;
    procedure Stop;
  end;

  //��־�ӿ�
  ICFLog = interface
    ['{FB886BA2-F480-473F-8C5B-75CA4C74E739}']
    procedure WriteLog(const ALog : string); overload;
    procedure WriteLog(const AType : TCFLogType; const ALog : string); overload;
    procedure SetOnLog(AEvent : TNotifyMessageEvent);
    function  GetOnLog : TNotifyMessageEvent;
  end;

  //�ַ����ֿ�ӿ�
  ICFStringRepository = interface
    ['{4B1C862B-FB89-4F2D-950C-7939FA6DFED0}']
    procedure Clear;
    function  Add(const AStr : string):Integer;
    function  Get(const AID : Integer):string;
    function  Extract(const AID : Integer):string;
  end;

implementation

end.
