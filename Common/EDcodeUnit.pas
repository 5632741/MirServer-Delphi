unit EDcodeUnit;

interface
uses
  Windows, SysUtils, DESTR, Classes, DES;

type
  TStringInfo = packed record
    btLength: Byte;
    nUniCode: Integer;
    sString: array[0..High(Byte) - 1] of Char;
  end;
  pTStringInfo = ^TStringInfo;

function EncodeString(Str: string): string;
function DecodeString(Str: string): string;
function EncodeBuffer(buf: PChar; bufsize: Integer): string;
procedure DecodeBuffer(Src: string; buf: PChar; bufsize: Integer);
function EncodeBuffer_(buf: PChar; bufsize: Integer): string;
procedure DecodeBuffer_(Src: string; buf: PChar; bufsize: Integer);

procedure Decode6BitBuf(sSource: PChar; pBuf: PChar; nSrcLen, nBufLen: Integer);
procedure Encode6BitBuf(pSrc, pDest: PChar; nSrcLen, nDestLen: Integer);
function Decry(Src, Key: string): string;
function Encry(Src, Key: string): string;

function Encrypt_Decrypt(m: Int64; e: Int64 = $2C86F9; n: Int64 = $69AAA0E3): Integer;
function Chinese2UniCode(AiChinese: string): Integer;
function GetUniCode(Msg: string): Integer;
function Str_ToInt(Str: string; Def: LongInt): LongInt;
function Encode(Src: string; var Dest: string): Boolean;
function Decode(Src: string; var Dest: string): Boolean;
function Base64EncodeStr(const Value: string): string;
{ Encode a string into Base64 format }
function Base64DecodeStr(const Value: string): string;
{ Decode a Base64 format string }
function Base64Encode(pInput: Pointer; pOutput: Pointer; Size: LongInt): LongInt;
{ Encode a lump of raw data (output is (4/3) times bigger than input) }
function Base64Decode(pInput: Pointer; pOutput: Pointer; Size: LongInt): LongInt;
{ Decode a lump of raw data }


function EncodeString_3des(Source, Key: string): string;
function DecodeString_3des(Source, Key: string): string;
function CalcFileCRC(sFileName: string): Integer;
function CalcBufferCRC(Buffer: PChar; nSize: Integer): Integer;
implementation
const
  BUFFERSIZE = 10000;
  B64: array[0..63] of Byte = (65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80,
    81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108,
    109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 48, 49, 50, 51, 52, 53,
    54, 55, 56, 57, 43, 47);
  Key: array[0..2, 0..7] of Byte = (($FF, $FE, $FF, $FE, $FF, $FE, $FF, $FF), ($FF, $FE, $FF, $FE, $FF, $FE, $FF, $FF), ($FF, $FE, $FF, $FE, $FF, $FE, $FF, $FF));
var
  CSEncode: TRTLCriticalSection;
function CalcFileCRC(sFileName: string): Integer;
var
  i: Integer;
  nFileHandle: Integer;
  nFileSize, nBuffSize: Integer;
  Buffer: PChar;
  INT: ^Integer;
  nCrc: Integer;
begin
  Result := 0;
  if not FileExists(sFileName) then Exit;
  nFileHandle := FileOpen(sFileName, fmOpenRead or fmShareDenyNone);
  if nFileHandle = 0 then
    Exit;
  nFileSize := FileSeek(nFileHandle, 0, 2);
  nBuffSize := (nFileSize div 4) * 4;
  GetMem(Buffer, nBuffSize);
  FillChar(Buffer^, nBuffSize, 0);
  FileSeek(nFileHandle, 0, 0);
  FileRead(nFileHandle, Buffer^, nBuffSize);
  FileClose(nFileHandle);
  INT := Pointer(Buffer);
  nCrc := 0;
  Exception.Create(IntToStr(SizeOf(Integer)));
  for i := 0 to nBuffSize div 4 - 1 do begin
    nCrc := nCrc xor INT^;
    INT := Pointer(Integer(INT) + 4);
  end;
  FreeMem(Buffer);
  Result := nCrc;
end;

function CalcBufferCRC(Buffer: PChar; nSize: Integer): Integer;
var
  i: Integer;
  INT: ^Integer;
  nCrc: Integer;
begin
  INT := Pointer(Buffer);
  nCrc := 0;
  for i := 0 to nSize div 4 - 1 do begin
    nCrc := nCrc xor INT^;
    INT := Pointer(Integer(INT) + 4);
  end;
  Result := nCrc;
end;
function Base64Encode(pInput: Pointer; pOutput: Pointer; Size: LongInt): LongInt;
var
  i, iptr, optr: Integer;
  Input, Output: PByteArray;
begin
  Input := PByteArray(pInput); Output := PByteArray(pOutput);
  iptr := 0; optr := 0;
  for i := 1 to (Size div 3) do begin
    Output^[optr + 0] := B64[Input^[iptr] shr 2];
    Output^[optr + 1] := B64[((Input^[iptr] and 3) shl 4) + (Input^[iptr + 1] shr 4)];
    Output^[optr + 2] := B64[((Input^[iptr + 1] and 15) shl 2) + (Input^[iptr + 2] shr 6)];
    Output^[optr + 3] := B64[Input^[iptr + 2] and 63];
    Inc(optr, 4); Inc(iptr, 3);
  end;
  case (Size mod 3) of
    1: begin
        Output^[optr + 0] := B64[Input^[iptr] shr 2];
        Output^[optr + 1] := B64[(Input^[iptr] and 3) shl 4];
        Output^[optr + 2] := Byte('=');
        Output^[optr + 3] := Byte('=');
      end;
    2: begin
        Output^[optr + 0] := B64[Input^[iptr] shr 2];
        Output^[optr + 1] := B64[((Input^[iptr] and 3) shl 4) + (Input^[iptr + 1] shr 4)];
        Output^[optr + 2] := B64[(Input^[iptr + 1] and 15) shl 2];
        Output^[optr + 3] := Byte('=');
      end;
  end;
  Result := ((Size + 2) div 3) * 4;
end;

function Base64EncodeStr(const Value: string): string;
begin
  SetLength(Result, ((Length(Value) + 2) div 3) * 4);
  Base64Encode(@Value[1], @Result[1], Length(Value));
end;

function Base64Decode(pInput: Pointer; pOutput: Pointer; Size: LongInt): LongInt;
var
  i, j, iptr, optr: Integer;
  temp: array[0..3] of Byte;
  Input, Output: PByteArray;
begin
  Input := PByteArray(pInput); Output := PByteArray(pOutput);
  iptr := 0; optr := 0;
  Result := 0;
  for i := 1 to (Size div 4) do begin
    for j := 0 to 3 do begin
      case Input^[iptr] of
        65..90: temp[j] := Input^[iptr] - Ord('A');
        97..122: temp[j] := Input^[iptr] - Ord('a') + 26;
        48..57: temp[j] := Input^[iptr] - Ord('0') + 52;
        43: temp[j] := 62;
        47: temp[j] := 63;
        61: temp[j] := $FF;
      end;
      Inc(iptr);
    end;
    Output^[optr] := (temp[0] shl 2) or (temp[1] shr 4);
    Result := optr + 1;
    if (temp[2] <> $FF) and (temp[3] = $FF) then begin
      Output^[optr + 1] := (temp[1] shl 4) or (temp[2] shr 2);
      Result := optr + 2;
      Inc(optr)
    end
    else if (temp[2] <> $FF) then begin
      Output^[optr + 1] := (temp[1] shl 4) or (temp[2] shr 2);
      Output^[optr + 2] := (temp[2] shl 6) or temp[3];
      Result := optr + 3;
      Inc(optr, 2);
    end;
    Inc(optr);
  end;
end;

function Base64DecodeStr(const Value: string): string;
begin
  SetLength(Result, (Length(Value) div 4) * 3);
  SetLength(Result, Base64Decode(@Value[1], @Result[1], Length(Value)));
end;

function Str_ToInt(Str: string; Def: LongInt): LongInt;
begin
  Result := Def;
  if Str <> '' then begin
    if ((Word(Str[1]) >= Word('0')) and (Word(Str[1]) <= Word('9'))) or
      (Str[1] = '+') or (Str[1] = '-') then try
      Result := StrToInt64(Str);
    except
    end;
  end;
end;
procedure Encode6BitBuf(pSrc, pDest: PChar; nSrcLen, nDestLen: Integer);
var
  i, nRestCount, nDestPos: Integer;
  btMade, btCh, btRest: Byte;
begin
  nRestCount := 0;
  btRest := 0;
  nDestPos := 0;
  for i := 0 to nSrcLen - 1 do begin
    if nDestPos >= nDestLen then break;
    btCh := Byte(pSrc[i]);
    btMade := Byte((btRest or (btCh shr (2 + nRestCount))) and $3F);
    btRest := Byte(((btCh shl (8 - (2 + nRestCount))) shr 2) and $3F);
    Inc(nRestCount, 2);

    if nRestCount < 6 then begin
      pDest[nDestPos] := Char(btMade + $3C);
      Inc(nDestPos);
    end else begin
      if nDestPos < nDestLen - 1 then begin
        pDest[nDestPos] := Char(btMade + $3C);
        pDest[nDestPos + 1] := Char(btRest + $3C);
        Inc(nDestPos, 2);
      end else begin
        pDest[nDestPos] := Char(btMade + $3C);
        Inc(nDestPos);
      end;
      nRestCount := 0;
      btRest := 0;
    end;
  end;
  if nRestCount > 0 then begin
    pDest[nDestPos] := Char(btRest + $3C);
    Inc(nDestPos);
  end;
  pDest[nDestPos] := #0;
end;

procedure Decode6BitBuf(sSource: PChar; pBuf: PChar; nSrcLen, nBufLen: Integer);
const
  Masks: array[2..6] of Byte = ($FC, $F8, $F0, $E0, $C0);
  //($FE, $FC, $F8, $F0, $E0, $C0, $80, $00);
var
  i, {nLen,} nBitPos, nMadeBit, nBufPos: Integer;
  btCh, btTmp, btByte: Byte;
begin
  //  nLen:= Length (sSource);
  nBitPos := 2;
  nMadeBit := 0;
  nBufPos := 0;
  btTmp := 0;
  for i := 0 to nSrcLen - 1 do begin
    if Integer(sSource[i]) - $3C >= 0 then
      btCh := Byte(sSource[i]) - $3C
    else begin
      nBufPos := 0;
      break;
    end;
    if nBufPos >= nBufLen then break;
    if (nMadeBit + 6) >= 8 then begin
      btByte := Byte(btTmp or ((btCh and $3F) shr (6 - nBitPos)));
      pBuf[nBufPos] := Char(btByte);
      Inc(nBufPos);
      nMadeBit := 0;
      if nBitPos < 6 then Inc(nBitPos, 2)
      else begin
        nBitPos := 2;
        continue;
      end;
    end;
    btTmp := Byte(Byte(btCh shl nBitPos) and Masks[nBitPos]); // #### ##--
    Inc(nMadeBit, 8 - nBitPos);
  end;
  pBuf[nBufPos] := #0;
end;

function DecodeString(Str: string): string;
var
  EncBuf: array[0..BUFFERSIZE - 1] of Char;
begin
  try
    EnterCriticalSection(CSEncode);
    Decode6BitBuf(PChar(Str), @EncBuf, Length(Str), SizeOf(EncBuf));
    Result := StrPas(EncBuf);
  finally
    LeaveCriticalSection(CSEncode);
  end;
end;

procedure DecodeBuffer(Src: string; buf: PChar; bufsize: Integer);
var
  EncBuf: array[0..BUFFERSIZE - 1] of Char;
begin
  try
    EnterCriticalSection(CSEncode);
    Decode6BitBuf(PChar(Src), @EncBuf, Length(Src), SizeOf(EncBuf));
    Move(EncBuf, buf^, bufsize);
  finally
    LeaveCriticalSection(CSEncode);
  end;
end;

function EncodeString(Str: string): string;
var
  EncBuf: array[0..BUFFERSIZE - 1] of Char;
begin
  try
    EnterCriticalSection(CSEncode);
    Encode6BitBuf(PChar(Str), @EncBuf, Length(Str), SizeOf(EncBuf));
    Result := StrPas(EncBuf);
  finally
    LeaveCriticalSection(CSEncode);
  end;
end;

function EncodeBuffer(buf: PChar; bufsize: Integer): string;
var
  EncBuf, TempBuf: array[0..BUFFERSIZE - 1] of Char;
begin
  try
    EnterCriticalSection(CSEncode);
    if bufsize < BUFFERSIZE then begin
      Move(buf^, TempBuf, bufsize);
      Encode6BitBuf(@TempBuf, @EncBuf, bufsize, SizeOf(EncBuf));
      Result := StrPas(EncBuf);
    end else Result := '';
  finally
    LeaveCriticalSection(CSEncode);
  end;
end;

function EncodeBuffer_(buf: PChar; bufsize: Integer): string;
var
  TempBuf: array[0..BUFFERSIZE - 1] of Char;
  sTemp: string;
begin
  SetLength(sTemp, bufsize);
  Move(buf^, sTemp[1], bufsize);
  Result := sTemp;
end;

procedure DecodeBuffer_(Src: string; buf: PChar; bufsize: Integer);
var
  sTemp: string;
begin
  Move(Src[1], buf^, bufsize);
end;

function ReverseStr(SourceStr: string): string;
var
  Counter: Integer;
begin
  Result := '';
  for Counter := 1 to Length(SourceStr) do
    Result := SourceStr[Counter] + Result;
end;

function Encry(Src, Key: string): string;
var
  sSrc, sKey: string;
begin
  EnterCriticalSection(CSEncode);
  try
    if Key = '' then sKey := IntToStr(240621028)
    else sKey := Key;
    sSrc := EncryStrHex(Src, sKey);
    Result := ReverseStr(sSrc);
  finally
    LeaveCriticalSection(CSEncode);
  end;
end;

function Decry(Src, Key: string): string;
var
  sSrc, sKey: string;
begin
  EnterCriticalSection(CSEncode);
  try
    try
      if Key = '' then sKey := IntToStr(240621028)
      else sKey := Key;
      sSrc := ReverseStr(Src);
      Result := DecryStrHex(sSrc, sKey);
    except
      Result := '';
    end;
  finally
    LeaveCriticalSection(CSEncode);
  end;
end;

function Chinese2UniCode(AiChinese: string): Integer;
var
  ch, cl: string[2];
  a: array[1..2] of Char;
begin
  StringToWideChar(Copy(AiChinese, 1, 2), @(a[1]), 2);
  ch := IntToHex(Integer(a[2]), 2);
  cl := IntToHex(Integer(a[1]), 2);
  Result := StrToInt('$' + ch + cl);
end;

function GetUniCode(Msg: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 1 to Length(Msg) do begin
    Result := Result + Chinese2UniCode(Msg[i]) * i;
  end;
end;

function GetUniCodeNo(c: Char): Integer;
begin
  case c of
    '0': Result := 48;
    '1': Result := 49;
    '2': Result := 50;
    '3': Result := 51;
    '4': Result := 52;
    '5': Result := 53;
    '6': Result := 54;
    '7': Result := 55;
    '8': Result := 56;
    '9': Result := 57;
    'A': Result := 65;
    'B': Result := 66;
    'C': Result := 67;
    'D': Result := 68;
    'E': Result := 69;
    'F': Result := 70;
    'G': Result := 71;
    'H': Result := 72;
    'I': Result := 73;
    'J': Result := 74;
    'K': Result := 75;
    'L': Result := 76;
    'M': Result := 77;
    'N': Result := 78;
    'O': Result := 79;
    'P': Result := 80;
    'Q': Result := 81;
    'R': Result := 82;
    'S': Result := 83;
    'T': Result := 84;
    'U': Result := 85;
    'V': Result := 86;
    'W': Result := 87;
    'X': Result := 88;
    'Y': Result := 89;
    'Z': Result := 90;
  end;
end;

function PowMod(base: Int64; pow: Int64; n: Int64): Int64;
var
  a, b, c: Int64;
begin
  a := base;
  b := pow;
  c := 1;
  while (b > 0) do begin
    while (not ((b and 1) > 0)) do begin
      b := b shr 1;
      a := a * a mod n;
    end;
    Dec(b);
    c := a * c mod n;
  end;
  Result := c;
end;
//RSA�ļ��ܺͽ��ܺ������ȼ���(m^e) mod n����m��e���ݶ�n���ࣩ
function Encrypt_Decrypt(m: Int64; e: Int64 = $2C86F9; n: Int64 = $69AAA0E3): Integer;
var
  a, b, c: Int64;
  nn: Integer;
const
  nNumber = 100000;
  MaxValue = 1400000000;
  MinValue = 1299999999;
  function GetInteger(n: Int64): Int64;
  var
    d: Int64;
  begin
    d := n;
    while d > MaxValue do d := d - nNumber;
    while d < MinValue do d := d + nNumber;
    if d = MinValue then d := d + m;
    if d = MaxValue then d := d - m;
    Result := d;
  end;
begin
  EnterCriticalSection(CSEncode);
  try
    a := m;
    b := e;
    c := 1;
    while b <> 0 do
      if (b mod 2) = 0
        then begin
        b := b div 2;
        a := (a * a) mod n;
      end
      else begin
        b := b - 1;
        c := (a * c) mod n;
      end;
    while (c < MinValue) or (c > MaxValue) do c := GetInteger(c);
    Result := c;
  finally
    LeaveCriticalSection(CSEncode);
  end;
end;

function DecodeString_3des(Source, Key: string): string;
var
  DesDecode: TDCP_3des;
  Str: string;
begin
  try
    Result := '';
    DesDecode := TDCP_3des.Create(nil);
    DesDecode.InitStr(Key);
    DesDecode.Reset;
    Str := DesDecode.DecryptString(Source);
    DesDecode.Reset;
    Result := Str;
    DesDecode.Free;
  except
    Result := '';
  end;
end;

function EncodeString_3des(Source, Key: string): string;
var
  DesEncode: TDCP_3des;
  Str: string;
begin
  try
    Result := '';
    DesEncode := TDCP_3des.Create(nil);
    DesEncode.InitStr(Key);
    DesEncode.Reset;
    Str := DesEncode.EncryptString(Source);
    DesEncode.Reset;
    Result := Str;
    DesEncode.Free;
  except
    Result := '';
  end;
end;

function Encode(Src: string; var Dest: string): Boolean;
var
  StringInfo: TStringInfo;
  sDest: string;
begin
  Result := False;
  Dest := '';
  FillChar(StringInfo, SizeOf(TStringInfo), 0);
  StringInfo.btLength := Length(Src);
  StringInfo.nUniCode := GetUniCode(Src);
  FillChar(StringInfo.sString, SizeOf(StringInfo.sString), 0);
  Move(Src[1], StringInfo.sString, StringInfo.btLength);
  SetLength(sDest, SizeOf(Byte) + SizeOf(Integer) + StringInfo.btLength);
  Move(StringInfo, sDest[1], SizeOf(Byte) + SizeOf(Integer) + StringInfo.btLength);
  Dest := ReverseStr(EncryStrHex(sDest, IntToStr(240621028)));
  Result := True;
end;

function Decode(Src: string; var Dest: string): Boolean;
var
  StringInfo: TStringInfo;
  sDest: string;
  sSrc: string;
begin
  Result := False;
  Dest := '';
  sDest := ReverseStr(Src);
  try
    sDest := DecryStrHex(sDest, IntToStr(240621028));
  except
    Exit;
  end;
  FillChar(StringInfo, SizeOf(TStringInfo), 0);
  Move(sDest[1], StringInfo, Length(sDest));
  sSrc := StrPas(@StringInfo.sString);
  if (GetUniCode(sSrc) = StringInfo.nUniCode) and (Length(sSrc) = StringInfo.btLength) then begin
    Dest := sSrc;
    Result := True;
  end;
end;

initialization
  begin
    InitializeCriticalSection(CSEncode);
  end;
finalization
  begin
    DeleteCriticalSection(CSEncode);
  end;
end.
