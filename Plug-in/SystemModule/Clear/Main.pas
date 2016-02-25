unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Registry, EDcode;

type
  TFrmClean = class(TForm)
    ButtonClear: TButton;
    Label1: TLabel;
    EditRegisterName: TEdit;
    Label2: TLabel;
    procedure ButtonClearClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmClean: TFrmClean;
implementation
uses SystemManage;
{$R *.dfm}

procedure TFrmClean.ButtonClearClick(Sender: TObject);
var
  sRegisterName: string;
begin
  sRegisterName := Trim(EditRegisterName.Text);
  if Application.MessageBox('�Ƿ�ȷ��Ҫ���ע����Ϣ���������Ҫ����ע���������ʹ�ã�����',
    'ȷ����Ϣ',
    MB_YESNO + MB_ICONQUESTION) = IDYES then begin
    if sRegisterName <> '' then begin
      InitLicense(240621028, 0, 0, 0, Date, IntToStr(240621028));
      if ClearRegisterInfo(sRegisterName) then Application.MessageBox('����ɹ�������', 'ȷ����Ϣ', MB_ICONQUESTION)
      else Application.MessageBox('���ʧ�ܣ�����', '��ʾ��Ϣ', MB_ICONQUESTION);
      UnInitLicense();
    end else Application.MessageBox('���ʧ�ܣ�����', '��ʾ��Ϣ', MB_ICONQUESTION);
  end;
end;

end.

