unit AddressFunc;

interface
uses Windows, Forms, Classes, SysUtils, Controls ;

function NewAddress(AForm: TForm; var AUser, AMobile, AEmail: String): Boolean;
function EditAddress(AForm: TForm; var AUser, AMobile, AEmail: String): Boolean;

implementation
uses AddressProFrm ;


//�½�һ����ַ�����ؽ���������ַ�����ݿ������ID
function NewAddress(AForm: TForm; var AUser, AMobile, AEmail: String): Boolean;
begin
  with TAddressProForm.Create(AForm) do
  begin
    EditType := edtNew ;
    edtName.Text   := AUser;
    edtMobile.Text := AMobile;
    edtEmail.Text  := AEmail;

    Result := ShowModal = mrOK;
    if Result then
    begin
      AUser   := edtName.Text;
      AMobile := edtMobile.Text;
      AEmail  := edtEmail.Text;
    end;

    Free;
  end;
end;

//�༭һ����ַ�����ؽ�����û��Ƿ����ˡ�ȷ����
function EditAddress(AForm: TForm; var AUser, AMobile, AEmail: String): Boolean;
begin
  with TAddressProForm.Create(AForm) do
  begin
    EditType := edtModify;
    edtName.Text   := AUser;
    edtMobile.Text := AMobile;
    edtEmail.Text  := AEmail;

    Result := ShowModal = mrOK;
    if Result then
    begin
      AUser   := edtName.Text;
      AMobile := edtMobile.Text;
      AEmail  := edtEmail.Text;
    end;

    Free;
  end;
end;

end.
