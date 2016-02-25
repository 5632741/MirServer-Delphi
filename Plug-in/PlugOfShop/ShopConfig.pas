unit ShopConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, ComCtrls, EngineAPI, EngineType;

type
  TFrmShopItem = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    ListViewItemList: TListView;
    ListBoxItemList: TListBox;
    ButtonChgShopItem: TButton;
    ButtonDelShopItem: TButton;
    ButtonAddShopItem: TButton;
    ButtonLoadShopItemList: TButton;
    ButtonSaveShopItemList: TButton;
    GroupBox3: TGroupBox;
    Label5: TLabel;
    shopitemJobeit: TComboBox;
    Label1: TLabel;
    EditShopItemName: TEdit;
    Label2: TLabel;
    SpinEditPrice: TSpinEdit;
    Label74: TLabel;
    shopitemAnim: TSpinEdit;
    Label6: TLabel;
    Label8: TLabel;
    SpinEdit1: TSpinEdit;
    Label9: TLabel;
    SpinEdit2: TSpinEdit;
    Label7: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Memo1: TEdit;
    Memo2: TEdit;
    procedure ListViewItemListClick(Sender: TObject);
    procedure ButtonChgShopItemClick(Sender: TObject);
    procedure ButtonDelShopItemClick(Sender: TObject);
    procedure ButtonAddShopItemClick(Sender: TObject);
    procedure ListBoxItemListClick(Sender: TObject);
    procedure ButtonSaveShopItemListClick(Sender: TObject);
    procedure ButtonLoadShopItemListClick(Sender: TObject);
  private
    { Private declarations }
    function InListViewItemList(sItemName: string): Boolean;
    procedure RefLoadShopItemList();
  public
    { Public declarations }
    procedure Open();
  end;

var
  FrmShopItem: TFrmShopItem;

implementation
uses PlayShop, HUtil32, PlugShare;
{$R *.dfm}
function TFrmShopItem.InListViewItemList(sItemName: string): Boolean;
var
  I: Integer;
  ListItem: TListItem;
begin
  Result := False;
  ListViewItemList.Items.BeginUpdate;
  try
    for I := 0 to ListViewItemList.Items.Count - 1 do begin
      ListItem := ListViewItemList.Items.Item[I];
      if CompareText(sItemName, ListItem.Caption) = 0 then begin
        Result := True;
        Break;
      end;
    end;
  finally
    ListViewItemList.Items.EndUpdate;
  end;
end;

procedure TFrmShopItem.RefLoadShopItemList();
var
  I: Integer;
  ListItem: TListItem;
  sItemName: string;
  sPrice: string;
  sItemcont: string;
  ShopInfo: pTShopInfo;
  simgid1,simgid2:string;
  sMemo1,sMemo2: string;
  sItemType:string;
  nItemType: Integer;
begin
  ListViewItemList.Clear;
  if g_ShopItemList <> nil then begin
    for I := 0 to g_ShopItemList.Count - 1 do begin
      ShopInfo := pTShopInfo(g_ShopItemList.Items[I]);
     if ShopInfo <> nil then begin
      sItemName := ShopInfo.StdItem.szName;
      sPrice := IntToStr(ShopInfo.Money);
      simgid1 := IntToStr(ShopInfo.Opimgid);
      simgid2 := IntToStr(ShopInfo.Eximgid);
      sItemcont := IntToStr(ShopInfo.Itemcont);
      sMemo1 := StrPas(@ShopInfo.sMemo1);
      sMemo2 := StrPas(@ShopInfo.sMemo2);
      nItemType := ShopInfo.btItemType;
      case nItemType of
       0:sItemType := 'װ��';
       1:sItemType := '����';
       2:sItemType := 'ǿ��';
       3:sItemType := '����';
       4:sItemType := '����';
       5:sItemType := '�����';
      end;
     end;
      ListViewItemList.Items.BeginUpdate;
      try
        ListItem := ListViewItemList.Items.Add;
        ListItem.Caption := sItemName;
        ListItem.SubItems.Add(sPrice);
        ListItem.SubItems.Add(sItemType);
        ListItem.SubItems.Add(simgid1);
        ListItem.SubItems.Add(simgid2);        
        ListItem.SubItems.Add(sItemcont);
        ListItem.SubItems.Add(sMemo1);
        ListItem.SubItems.Add(sMemo2);
      finally
        ListViewItemList.Items.EndUpdate;
      end;
    end;
  end;
end;

procedure TFrmShopItem.Open();
var
  I: Integer;
  StdItem: _LPTOSTDITEM;
  List: Classes.TList;
begin
  Application.HintColor := ClLime;
  ButtonChgShopItem.Enabled := False;
  ButtonDelShopItem.Enabled := False;
  ButtonAddShopItem.Enabled := False;
  ButtonSaveShopItemList.Enabled := False;
  ButtonLoadShopItemList.Enabled := False;
  ListBoxItemList.Items.Clear;
  List := Classes.TList(TUserEngine_GetStdItemList);
  if List <> nil then begin
    for I := 0 to List.Count - 1 do begin
      StdItem := List.Items[I];
      ListBoxItemList.Items.AddObject(StdItem.szName, TObject(StdItem));
    end;
  end;
  RefLoadShopItemList();
  ShowModal;
end;

procedure TFrmShopItem.ListViewItemListClick(Sender: TObject);
var
  nItemIndex: Integer;
  ListItem: TListItem;
  sItemType: string;
  nItemType: Integer;
begin
  try
    nItemIndex := ListViewItemList.ItemIndex;
    ListItem := ListViewItemList.Items.Item[nItemIndex];
    EditShopItemName.Text := ListItem.Caption;
    SpinEditPrice.Value := Str_ToInt(ListItem.SubItems.Strings[0], 0);
    sItemType := ListItem.SubItems.Strings[1];
    if  sItemType = 'װ��' then nItemType := 0;
    if  sItemType = '����' then nItemType := 1;
    if  sItemType = 'ǿ��' then nItemType := 2;
    if  sItemType = '����' then nItemType := 3;
    if  sItemType = '����' then nItemType := 4;
    if  sItemType = '�����' then nItemType := 5;
    shopitemJobeit.itemIndex:= nItemType;
    SpinEdit1.Value := Str_ToInt(ListItem.SubItems.Strings[2], 0);
    SpinEdit2.Value := Str_ToInt(ListItem.SubItems.Strings[3], 0);
    shopitemAnim.Value := Str_ToInt(ListItem.SubItems.Strings[4], 0);
    Memo1.Text := ListItem.SubItems.Strings[5];
    Memo2.Text := ListItem.SubItems.Strings[6];
    ButtonAddShopItem.Enabled := False;
    ButtonChgShopItem.Enabled := True;
    ButtonDelShopItem.Enabled := True;
  except
    ButtonChgShopItem.Enabled := False;
    ButtonDelShopItem.Enabled := False;
  end;
end;

procedure TFrmShopItem.ButtonChgShopItemClick(Sender: TObject);
var
  nItemIndex,nItemType: Integer;
  ListItem: TListItem;
  sItemType: string;
begin
  try
    nItemIndex := ListViewItemList.ItemIndex;
    nItemType := shopitemJobeit.ItemIndex;
  case nItemType of
  0:sItemType := 'װ��';
  1:sItemType := '����';
  2:sItemType := 'ǿ��';
  3:sItemType := '����';
  4:sItemType := '����';
  5:sItemType := '�����';
  end;
    ListItem := ListViewItemList.Items.Item[nItemIndex];
    ListItem.SubItems.Strings[0] := IntToStr(SpinEditPrice.Value);
    ListItem.SubItems.Strings[1] := sItemType;
    ListItem.SubItems.Strings[2] := IntToStr(SpinEdit1.Value);
    ListItem.SubItems.Strings[3] := IntToStr(SpinEdit2.Value);
    ListItem.SubItems.Strings[4] := IntToStr(shopitemAnim.Value);
    ListItem.SubItems.Strings[5] := Trim(Memo1.Text);
    ListItem.SubItems.Strings[6] := Trim(Memo2.Text);
    ButtonChgShopItem.Enabled := FALSE;
    ButtonDelShopItem.Enabled := False;
    ButtonSaveShopItemList.Enabled := TRUE;
  except
  end;
end;

procedure TFrmShopItem.ButtonDelShopItemClick(Sender: TObject);
begin
  ListViewItemList.Items.BeginUpdate;
  try
    ListViewItemList.DeleteSelected;
    ButtonChgShopItem.Enabled := FALSE;
    ButtonDelShopItem.Enabled := False;
    ButtonSaveShopItemList.Enabled := TRUE;
  finally
    ListViewItemList.Items.EndUpdate;
  end;
end;

procedure TFrmShopItem.ButtonAddShopItemClick(Sender: TObject);
var
  ListItem: TListItem;
  sItemName: string;
  sPrice,sItemType,sItemcont: string;
  simgid1,simgid2:string;
  nItemType: Integer;
  sMemo1,sMemo2: string;
begin
  sItemName := Trim(EditShopItemName.Text);
  sPrice := IntToStr(SpinEditPrice.Value);
  nItemType := shopitemJobeit.ItemIndex;
  simgid1 := IntToStr(SpinEdit1.Value);
  simgid2 := IntToStr(SpinEdit2.Value);
  sItemcont := IntToStr(shopitemAnim.Value);
  sMemo1 := Trim(Memo1.Text);
  sMemo2 := Trim(Memo2.Text);
  case nItemType of
   0:sItemType := 'װ��';
   1:sItemType := '����';
   2:sItemType := 'ǿ��';
   3:sItemType := '����';
   4:sItemType := '����';
   5:sItemType := '�����';
  end;
  if sItemName = '' then begin
    Application.MessageBox('��ѡ����Ҫ��ӵ���Ʒ������', '��ʾ��Ϣ', MB_ICONQUESTION);
    Exit;
  end;
  if sMemo1 = '' then begin
    Application.MessageBox('��������Ʒ��飡����', '��ʾ��Ϣ', MB_ICONQUESTION);
    Exit;
  end;
  if sMemo2 = '' then begin
    Application.MessageBox('��������Ʒע�ͣ�����', '��ʾ��Ϣ', MB_ICONQUESTION);
    Exit;
  end;
  if InListViewItemList(sItemName) then begin
    Application.MessageBox('��Ҫ��ӵ���Ʒ�Ѿ����ڣ���ѡ��������Ʒ������', '��ʾ��Ϣ', MB_ICONQUESTION);
    Exit;
  end;
  ListViewItemList.Items.BeginUpdate;
  try
    ListItem := ListViewItemList.Items.Add;
    ListItem.Caption := sItemName;
    ListItem.SubItems.Add(sPrice);
    ListItem.SubItems.Add(sItemType);
    ListItem.SubItems.Add(simgid1);
    ListItem.SubItems.Add(simgid2);
    ListItem.SubItems.Add(sItemcont);
    ListItem.SubItems.Add(sMemo1);
    ListItem.SubItems.Add(sMemo2);
    ButtonAddShopItem.Enabled := False;
    ButtonSaveShopItemList.Enabled := TRUE;
  finally
    ListViewItemList.Items.EndUpdate;
  end;
end;

procedure TFrmShopItem.ListBoxItemListClick(Sender: TObject);
var
  nItemIndex: Integer;
begin
  try
    ButtonChgShopItem.Enabled := False;
    ButtonDelShopItem.Enabled := False;
    nItemIndex := ListBoxItemList.ItemIndex;
    EditShopItemName.Text := ListBoxItemList.Items.Strings[nItemIndex];
    Memo1.Text := ListBoxItemList.Items.Strings[nItemIndex];
    ButtonAddShopItem.Enabled := True;
  except
    ButtonAddShopItem.Enabled := False;
  end;
end;

procedure TFrmShopItem.ButtonSaveShopItemListClick(Sender: TObject);
var
  I: Integer;
  ListItem: TListItem;
  SaveList: Classes.TStringList;
  sLineText: string;
  sFileName: string;
  sItemName: string;
  sPrice: string;
  simgid1,simgid2:string;
  sMemo1,sMemo2: string;
  sItemType: string;
  nItemType: Integer;
  sItemcont: string;
begin
  ButtonSaveShopItemList.Enabled := False;
  ButtonDelShopItem.Enabled := False;
  ButtonChgShopItem.Enabled := FALSE;
  ButtonAddShopItem.Enabled := False;
  sFileName := '.\BuyItemList.txt';
  SaveList := Classes.TStringList.Create();
  SaveList.Add(';���������������ļ�');
  SaveList.Add(';��Ʒ����'#9'���ۼ۸�'#9'����'#9'����ID1'#9'����ID2'#9'��������'#9'���'#9'ע��');
  ListViewItemList.Items.BeginUpdate;
  try
    for I := 0 to ListViewItemList.Items.Count - 1 do begin
      ListItem := ListViewItemList.Items.Item[I];
      sItemName := ListItem.Caption;
      sPrice := ListItem.SubItems.Strings[0];
      sItemType := ListItem.SubItems.Strings[1];
    if  sItemType = 'װ��' then
       nItemType := 0;
    if  sItemType = '����' then
       nItemType := 1;
    if  sItemType = 'ǿ��' then
       nItemType := 2;
    if  sItemType = '����' then
       nItemType := 3;
    if  sItemType = '����' then
       nItemType := 4;
    if  sItemType = '�����' then
       nItemType := 5;
      simgid1 := ListItem.SubItems.Strings[2];
      simgid2 := ListItem.SubItems.Strings[3];
      sItemcont := ListItem.SubItems.Strings[4];
      sMemo1 := ListItem.SubItems.Strings[5];
      sMemo2 := ListItem.SubItems.Strings[6];
      sLineText := sItemName + #9 + sPrice + #9 + inttostr(nItemType) + #9 + simgid1 + #9 + simgid2 + #9 + sItemcont + #9 + sMemo1 + #9 + sMemo2;
      SaveList.Add(sLineText);
    end;
  finally
    ListViewItemList.Items.EndUpdate;
  end;
  SaveList.SaveToFile(sFileName);
  SaveList.Free;
  Application.MessageBox('������ɣ�����', '��ʾ��Ϣ', MB_ICONQUESTION);
  ButtonLoadShopItemList.Enabled := True;
end;

procedure TFrmShopItem.ButtonLoadShopItemListClick(Sender: TObject);
begin
  ButtonLoadShopItemList.Enabled := False;
  LoadShopItemList();
  RefLoadShopItemList();
  Application.MessageBox('���¼������б���ɣ�����', '��ʾ��Ϣ', MB_ICONQUESTION);
end;

end.

