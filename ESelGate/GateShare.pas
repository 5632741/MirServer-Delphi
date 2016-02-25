unit GateShare;

interface
uses
  Windows, Messages, Classes, SysUtils, JSocket, WinSock, SyncObjs, Common;
resourcestring
  g_sVersion = '��������:HAPPYM2.NET ��������ɫ����';
  g_sUpDateTime = '��������: 2014.09.09';
  g_sWebSite = '�ٷ���վ: http://WWW.HAPPYM2.NET';

type
  TGList = class(TList)
  private
    GLock: TRTLCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Lock;
    procedure UnLock;
  end;

  TBlockIPMethod = (mDisconnect, mBlock, mBlockList);

  TSockaddr = record
    nIPaddr: Integer;
    dwStartAttackTick: LongWord;
    nAttackCount: Integer;
    nSocketHandle: Integer;
  end;
  pTSockaddr = ^TSockaddr;

procedure LoadBlockIPFile();
procedure SendGameCenterMsg(wIdent: Word; sSendMsg: string);
procedure SaveBlockIPList();
var
  CS_MainLog: TCriticalSection;
  CS_FilterMsg: TCriticalSection;
  MainLogMsgList: TStringList;
  BlockIPList: TGList;
  TempBlockIPList: TGList;
  CurrIPaddrList: TGList;
  AttackIPaddrList: TGList;

  nShowLogLevel: Integer = 3;
  StringList456A14: TStringList;
  GateClass: string = 'SelGate';
  GateName: string = '��ɫ����';

  TitleName: string = '�������';

  ServerPort: Integer = 5100;
  ServerAddr: string = '127.0.0.1';
  GatePort: Integer = 7100;
  GateAddr: string = '0.0.0.0';

  boGateReady: Boolean = False;
  boShowMessage: Boolean;
  boStarted: Boolean = False;
  boClose: Boolean = False;
  boServiceStart: Boolean = False;
  dwKeepAliveTick: LongWord;
  boKeepAliveTimcOut: Boolean = False;
  nSendMsgCount: Integer;
  n456A2C: Integer;
  n456A30: Integer;
  boSendHoldTimeOut: Boolean;
  dwSendHoldTick: LongWord;
  boDecodeLock: Boolean;

  nMaxConnOfIPaddr: Integer = 10;

  BlockMethod: TBlockIPMethod = mBlock;
  dwKeepConnectTimeOut: LongWord = 60 * 1000;
  g_boDynamicIPDisMode: Boolean = False; //���ڶ�̬IP���ֻ����õ�¼�����ã��򿪴�ģʽ�����ؽ�������ӵ�¼��������IP��ַ����Ϊ������IP��������¼���������ͻ��˽�ֱ��ʹ�ô�IP���ӽ�ɫ����

  g_dwGameCenterHandle: THandle;
  g_sNowStartGate: string = '����������ɫ����...';
  g_sNowStartOK: string = '������ɫ�������...';

  UseBlockMethod: TBlockIPMethod;
  nUseAttackLevel: Integer;

  dwAttackTime: LongWord = 200;
  nAttackCount: Integer = 5;
  nReviceMsgLength: Integer = 100; //ÿMS������ܵĳ��ȣ���������Ϊ�ǹ���
  dwReviceTick: LongWord = 500;
  nAttackLevel: Integer = 1;
  nMaxClientMsgCount: Integer = 1;

  m_nAttackCount: Integer = 0;
  m_dwAttackTick: LongWord = 0;
const
  tLoginGate = 6;
implementation
uses Grobal2;

procedure LoadBlockIPFile();
var
  I: Integer;
  sFileName: string;
  LoadList: TStringList;
  sIPaddr: string;
  nIPaddr: Integer;
  IPaddr: pTSockaddr;
begin
  sFileName := '.\BlockIPList.txt';
  if FileExists(sFileName) then begin
    LoadList := TStringList.Create;
    LoadList.LoadFromFile(sFileName);
    for I := 0 to LoadList.Count - 1 do begin
      sIPaddr := Trim(LoadList.Strings[0]);
      if sIPaddr = '' then Continue;
      nIPaddr := inet_addr(PChar(sIPaddr));
      if nIPaddr = INADDR_NONE then Continue;
      New(IPaddr);
      FillChar(IPaddr^, SizeOf(TSockaddr), 0);
      IPaddr.nIPaddr := nIPaddr;
      BlockIPList.Add(IPaddr);
    end;
    LoadList.Free;
  end;
end;
procedure SaveBlockIPList();
var
  I: Integer;
  SaveList: TStringList;
begin
  SaveList := TStringList.Create;
  for I := 0 to BlockIPList.Count - 1 do begin
    SaveList.Add(StrPas(inet_ntoa(TInAddr(pTSockaddr(BlockIPList.Items[I]).nIPaddr))));
  end;
  SaveList.SaveToFile('.\BlockIPList.txt');
  SaveList.Free;
end;
procedure SendGameCenterMsg(wIdent: Word; sSendMsg: string);
var
  SendData: TCopyDataStruct;
  nParam: Integer;
begin
  nParam := MakeLong(Word(tLoginGate), wIdent);
  SendData.cbData := Length(sSendMsg) + 1;
  GetMem(SendData.lpData, SendData.cbData);
  StrCopy(SendData.lpData, PChar(sSendMsg));
  SendMessage(g_dwGameCenterHandle, WM_COPYDATA, nParam, Cardinal(@SendData));
  FreeMem(SendData.lpData);
end;

constructor TGList.Create;
begin
  inherited Create;
  InitializeCriticalSection(GLock);
end;

destructor TGList.Destroy;
begin
  DeleteCriticalSection(GLock);
  inherited;
end;

procedure TGList.Lock;
begin
  EnterCriticalSection(GLock);
end;

procedure TGList.UnLock;
begin
  LeaveCriticalSection(GLock);
end;

initialization
  begin
    CS_MainLog := TCriticalSection.Create;
    CS_FilterMsg := TCriticalSection.Create;
    StringList456A14 := TStringList.Create;
    MainLogMsgList := TStringList.Create;
  end;

finalization
  begin
    StringList456A14.Free;
    MainLogMsgList.Free;
    CS_MainLog.Free;
    CS_FilterMsg.Free;
  end;

end.

