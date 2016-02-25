unit PlugShare;

interface
uses
  Windows, Classes, EngineAPI, EngineType;
type
  TShopInfo = packed record
    btItemType: Byte; //��Ʒ���
    StdItem: _TSTDITEM;  //��Ʒ����
    Money: Integer;  //��Ʒ��ֵ
    Opimgid: Integer; //������ʼͼƬID
    Eximgid: Integer; //��������ͼƬID
    Itemcont: Integer;//��������
    sMemo1: array[0..13] of Char; //˵��1
    sMemo2: array[0..49] of Char;//˵��2
  end;
  pTShopInfo = ^TShopInfo;
var
  PlugHandle: Integer;
  PlugClass: string = 'Config';
  g_ShopItemList: Classes.TList;
implementation

end.

