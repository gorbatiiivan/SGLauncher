unit XMLLiteCore;

{$IFDEF FPC}{$mode delphi}{$H+}{$ENDIF}

// ============================================================================
// Лёгкий построчный XML-парсер для плоских файлов вида
// <Root><Record>...</Record><Record>...</Record></Root> (LaunchBox и т.п.).
// Всё в одном файле:
//   - "Ядро" (SafeFindPos, DecodeXMLText, FindOpenTag, ExtractTag,
//     FindNextBlock) — чистые функции без внешних зависимостей, кроме
//     стандартных SysUtils/StrUtils. Покрыты модульными тестами
//     (test_xmllitecore.pas) — реально прогнаны компилятором (fpc).
//   - Высокоуровневый ParseXMLRecords — читает файл, находит записи,
//     на каждую вызывает переданный колбэк. НЕ ЗНАЕТ ничего про TGameData
//     или конкретный проект — это забота вызывающего кода (см. пример
//     использования в GamesCore.pas ниже, в комментарии перед ParseXMLRecords).
//
// Логика ParseXMLRecords проверена отдельно (test_parser_logic.pas, вариант
// на "of object" методах вместо "reference to" — FPC 3.2.2 в песочнице не
// поддерживает reference to/анонимные функции, это фича Delphi, которой там
// ещё нет). ReadXMLFileSmart использует System.IOUtils.TFile и
// System.SysUtils.TEncoding — это чистый Delphi RTL, которого в FPC вообще
// нет, поэтому под FPC ({$IFDEF FPC}) она заменена на упрощённое чтение
// через TStringList — ТОЛЬКО чтобы можно было тестировать остальную логику
// в песочнице. В реальной Delphi-сборке используется полная версия с
// автоопределением кодировки.
// ============================================================================

interface

uses
  SysUtils, StrUtils, Classes
  {$IFNDEF FPC}, IOUtils{$ENDIF};

// ---------------------------------------------------------------------------
// Ядро: чистые функции работы со строками, без файлового ввода-вывода
// ---------------------------------------------------------------------------

// Ищет первое вхождение SubStr в Text начиная с позиции From, пропуская
// ЦЕЛИКОМ любые CDATA-секции (<![CDATA[...]]>) и XML-комментарии (<!--...-->),
// встреченные по пути. Без этого литеральный текст "</Game>" или "<Title>"
// внутри чужой CDATA/комментария мог бы сдвинуть границу блока/тега.
function SafeFindPos(const Text, SubStr: string; From: Integer): Integer;

// Декодирует текстовое содержимое XML-узла: CDATA как есть, встроенные
// XML-комментарии вырезаются, числовые сущности (&#160;, &#xA0;) и
// 5 стандартных именованных сущностей — за один проход, без двойного
// декодирования (&#38;amp; остаётся текстом "&amp;", а не схлопывается до "&").
function DecodeXMLText(const S: string): string;

// Ищет открывающий тег TagName в Block начиная с позиции From.
// Возвращает позицию начала тега ('<'), либо 0, если не найдено.
// TagCloseBracketPos — позиция символа '>' этого тега.
// IsSelfClosing — True для <Tag/> и <Tag attr="x"/>.
// Устойчив к атрибутам в теге и не путает "<ID>" с "<IDx>".
function FindOpenTag(const Block, TagName: string; From: Integer;
  out TagCloseBracketPos: Integer; out IsSelfClosing: Boolean): Integer;

// Извлекает декодированный текст ПОСЛЕДНЕГО вхождения тега TagName в Block
// (при нескольких одноимённых тегах побеждает последний — как при DOM-обходе
// ChildNodes, где значение поля просто перезаписывается на каждом узле).
// Для self-closing тега и для отсутствующего тега возвращает ''.
function ExtractTag(const Block, TagName: string): string;

// Ищет следующий блок <BlockTagName ...> ... </BlockTagName> в Text начиная
// с позиции From. Возвращает True, если блок найден; BlockText — содержимое
// ВКЛЮЧАЯ открывающий и закрывающий тег; NextSearchPos — откуда продолжать
// поиск следующего блока. Тег может содержать атрибуты (<Game id="1">).
function FindNextBlock(const Text, BlockTagName: string; From: Integer;
  out BlockText: string; out NextSearchPos: Integer): Boolean;

// ---------------------------------------------------------------------------
// Высокий уровень: чтение файла и разбор по записям через колбэк
// ---------------------------------------------------------------------------

type
  {$IFDEF FPC}
  // FPC 3.2.2 не поддерживает reference to/анонимные функции (это фича
  // Delphi, которой в FPC ещё нет) — здесь только чтобы можно было
  // компилировать и тестировать остальную логику в песочнице.
  // В реальной Delphi-сборке используется ветка {$ELSE} ниже.
  TGetXMLFieldFunc = function(const TagName: string): string of object;
  TOnXMLRecordParsed = function(const GetField: TGetXMLFieldFunc): Boolean of object;
  TXMLLogProc = procedure(const Msg: string) of object;
  {$ELSE}
  // Даёт вызывающему коду доступ к полю текущей записи по имени тега.
  // Валиден ТОЛЬКО во время самого вызова OnRecord — сохранять его
  // для использования позже нельзя (данные под ним не переживают итерацию).
  TGetXMLFieldFunc = reference to function(const TagName: string): string;

  // Колбэк на каждую найденную запись. Result = True, если запись принята
  // (использована вызывающим кодом), False — если отклонена (например,
  // не оказалось обязательного поля). Парсер сам не решает, что валидно —
  // это знает только вызывающий код; Result нужен исключительно для
  // статистики и логирования ниже.
  TOnXMLRecordParsed = reference to function(const GetField: TGetXMLFieldFunc): Boolean;

  TXMLLogProc = reference to procedure(const Msg: string);
  {$ENDIF}

  TXMLParseStats = record
    RecordsFound: Integer;     // сколько блоков <RecordTagName>...</...> реально разобрано
    RecordsAccepted: Integer;  // OnRecord вернул True
    RecordsRejected: Integer;  // OnRecord вернул False
    RecordsFailed: Integer;    // OnRecord бросил исключение — запись пропущена (не Accepted, не Rejected)
    Truncated: Boolean;        // разбор оборвался на незакрытом блоке (файл обрезан/битый)
    TruncatedAtPos: Integer;   // позиция обрыва в файле (0, если Truncated = False)
    RawTagCountHint: Integer;  // грубая оценка числа "<RecordTagName" в файле; -1, если не считали
                                // (см. VerifyRawCount) — это эвристика для лога, не точное число:
                                // считает и вхождения вида "<RecordTagNameExtra"
    ReadFailed: Boolean;       // не удалось прочитать/декодировать файл вообще (см. ReadErrorMessage)
    ReadErrorMessage: string;  // текст исключения, если ReadFailed = True; иначе ''
  end;

// Читает XML-файл, определяя кодировку автоматически:
//   1) по BOM (UTF-8/UTF-16LE/UTF-16BE/UTF-32) — если есть, доверяем ему;
//   2) иначе ищем encoding="..." в самой XML-декларации — она по стандарту
//      всегда в ASCII-совместимой части файла;
//   3) если и этого нет — UTF-8 без BOM.
function ReadXMLFileSmart(const FileName: string): string;

// Основная функция разбора. Один раз читает файл, затем для каждого
// найденного блока <RecordTagName>...</RecordTagName> вызывает OnRecord.
// LogProc — необязательный колбэк для диагностики (обрезанный файл,
// расхождение грубого подсчёта тегов и т.д.); можно передать nil.
// VerifyRawCount включает дополнительный проход по файлу для эвристической
// сверки количества тегов — стоит доп. времени на очень больших файлах,
// поэтому по умолчанию выключено.
//
// Пример использования в GamesCore.pas:
//
//   Stats := ParseXMLRecords(XMLFileName, 'Game',
//     function(const GetField: TGetXMLFieldFunc): Boolean
//     var
//       G: TGameData;
//     begin
//       FillChar(G, SizeOf(G), 0);
//       G.GameName := Trim(GetField('Title'));
//       Result := G.GameName <> '';
//       if not Result then Exit;
//       G.ApplicationPath := GetField('ApplicationPath');
//       G.Platforms       := Trim(GetField('Platform'));
//       ... остальные поля так же ...
//       if G.Platforms = '' then
//         G.Platforms := PlatformFromFile;
//       AddGameToArray(G);
//     end,
//     procedure(const Msg: string) begin Log(Msg); end); // ваш логгер
function ParseXMLRecords(const FileName, RecordTagName: string;
  const OnRecord: TOnXMLRecordParsed; const LogProc: TXMLLogProc = nil;
  VerifyRawCount: Boolean = False): TXMLParseStats;

implementation

// Старый метод на DOM (не работает с большими файлами)
{uses Xml.XMLIntf, Xml.XMLDoc
procedure TSGLMainFormHelper.LoadXMLToArrayThreadSafe(const XMLFileName: string);
var
  XML: IXMLDocument;
  Nodes: IXMLNodeList;
  Node, Child: IXMLNode;
  G: TGameData;
  i, j: Integer;
  NodeName: string;
  PlatformFromFile: string;
begin
  XML := TXMLDocument.Create(nil);
  try
    XML.LoadFromFile(XMLFileName);
    XML.Active := True;

    if (XML.DocumentElement = nil) then Exit;

    Nodes := XML.DocumentElement.ChildNodes;
    PlatformFromFile := ChangeFileExt(ExtractFileName(XMLFileName), '');

    for i := 0 to Nodes.Count - 1 do
    begin
      Node := Nodes[i];
      if Node.NodeName <> 'Game' then Continue;

      FillChar(G, SizeOf(G), 0);

      for j := 0 to Node.ChildNodes.Count - 1 do
      begin
        Child := Node.ChildNodes[j];
        if not Assigned(Child) then Continue;

        NodeName := Child.LocalName;

        case IndexStr(NodeName, ['Title','ApplicationPath','Platform','Developer',
                                  'Publisher','Genre','Series','ReleaseDate','Notes',
                                  'ManualPath','ConfigurationPath','RootFolder','ID','CommandLine', 'PlayMode', 'Source']) of
          0: G.GameName          := Trim(Child.Text);
          1: G.ApplicationPath   := Child.Text;
          2: G.Platforms         := Trim(Child.Text);
          3: G.Developer         := Trim(Child.Text);
          4: G.Publisher         := Trim(Child.Text);
          5: G.Genre             := Trim(Child.Text);
          6: G.Series            := Trim(Child.Text);
          7: G.ReleaseYear       := StrToIntDef(Copy(Trim(Child.Text),1,4), 0);
          8: G.Notes             := Trim(Child.Text);
          9: G.Manual            := Trim(Child.Text);
          10:G.ConfigurationPath := Trim(Child.Text);
          11:G.RootFolder        := Trim(Child.Text);
          12:G.ID                := Trim(Child.Text);
          13:G.CommandLine       := Trim(Child.Text);
          14:G.PlayMode          := Trim(Child.Text);
          15:G.Source            := Trim(Child.Text);
        end;
      end;

      if G.GameName = '' then Continue;

      // Если платформа не указана в XML — берём из имени файла
      if G.Platforms = '' then
        G.Platforms := PlatformFromFile;

      // Добавляем игру (с проверкой на дубликаты по ID)
      AddGameToArray(G);

    end;
  finally
    XML := nil;
  end;
end;}

// ---------------------------------------------------------------------------
// Ядро
// ---------------------------------------------------------------------------

function SafeFindPos(const Text, SubStr: string; From: Integer): Integer;
var
  CandidatePos, CdataStart, CommentStart, SkipTo: Integer;
  ScanRegion: string;
begin
  Result := 0;
  while True do
  begin
    CandidatePos := PosEx(SubStr, Text, From);
    if CandidatePos = 0 then Exit; // подстрока больше не встречается

    // Ищем CDATA/комментарий ТОЛЬКО в окне [From, CandidatePos) — то есть
    // ровно там, где они могли бы "спрятать" кандидата. Полный поиск по
    // остатку файла на каждом вызове давал квадратичное время на файлах
    // без единой CDATA/комментария (полное сканирование хвоста файла).
    ScanRegion := Copy(Text, From, CandidatePos - From);
    CdataStart := Pos('<![CDATA[', ScanRegion);
    CommentStart := Pos('<!--', ScanRegion);

    if CdataStart > 0 then
    begin
      CdataStart := From + CdataStart - 1; // абсолютная позиция в Text
      SkipTo := PosEx(']]>', Text, CdataStart + 9);
      if SkipTo = 0 then Exit; // CDATA не закрыта — дальше искать бессмысленно
      From := SkipTo + 3;
      Continue;
    end;

    if CommentStart > 0 then
    begin
      CommentStart := From + CommentStart - 1;
      SkipTo := PosEx('-->', Text, CommentStart + 4);
      if SkipTo = 0 then Exit;
      From := SkipTo + 3;
      Continue;
    end;

    Result := CandidatePos;
    Exit;
  end;
end;

function DecodeXMLText(const S: string): string;
var
  P1, P2: Integer;
  I, Len, PSemi, NumStart, CodeVal: Integer;
  Frag: string;
  SB: string;
begin
  Result := S;

  // Шаг 1: CDATA-секция — содержимое как есть, без декодирования сущностей
  P1 := Pos('<![CDATA[', Result);
  if P1 > 0 then
  begin
    P2 := Pos(']]>', Result);
    if P2 > P1 then
    begin
      Result := Copy(Result, P1 + 9, P2 - (P1 + 9));
      Exit;
    end;
  end;

  // Шаг 2: вырезаем встроенные XML-комментарии — DOM не включает их в Text узла
  while True do
  begin
    P1 := Pos('<!--', Result);
    if P1 = 0 then Break;
    P2 := PosEx('-->', Result, P1 + 4);
    if P2 = 0 then Break; // не закрыт — оставляем как есть, не наш случай
    Result := Copy(Result, 1, P1 - 1) + Copy(Result, P2 + 3, MaxInt);
  end;

  if Pos('&', Result) = 0 then Exit; // быстрый выход — сущностей нет

  // Шаг 3: единый проход слева направо для числовых И именованных сущностей.
  // Важно делать это ОДНИМ проходом, а не последовательными StringReplace:
  // символ, ПОЛУЧЕННЫЙ декодированием (например, '&' из &#38;), не должен
  // повторно интерпретироваться как начало новой сущности — иначе &#38;amp;
  // (буквальный текст "&amp;") ошибочно схлопнется до одного '&'.
  Len := Length(Result);
  SB := '';
  I := 1;
  while I <= Len do
  begin
    if Result[I] <> '&' then
    begin
      SB := SB + Result[I];
      Inc(I);
      Continue;
    end;

    PSemi := PosEx(';', Result, I);
    if (PSemi = 0) or (PSemi - I > 10) then
    begin
      SB := SB + '&'; // не похоже на сущность — символ как есть
      Inc(I);
      Continue;
    end;

    Frag := Copy(Result, I, PSemi - I + 1); // включая '&' и ';'

    if (Length(Frag) > 2) and (Frag[2] = '#') then
    begin
      NumStart := I + 2;
      if Result[NumStart] in ['x', 'X'] then
        CodeVal := StrToIntDef('$' + Copy(Result, NumStart + 1, PSemi - NumStart - 1), -1)
      else
        CodeVal := StrToIntDef(Copy(Result, NumStart, PSemi - NumStart), -1);

      if CodeVal >= 0 then
      begin
        SB := SB + Char(CodeVal);
        I := PSemi + 1;
        Continue;
      end;
    end
    else if Frag = '&lt;'   then begin SB := SB + '<';  I := PSemi + 1; Continue; end
    else if Frag = '&gt;'   then begin SB := SB + '>';  I := PSemi + 1; Continue; end
    else if Frag = '&quot;' then begin SB := SB + '"';  I := PSemi + 1; Continue; end
    else if Frag = '&apos;' then begin SB := SB + '''';  I := PSemi + 1; Continue; end
    else if Frag = '&amp;'  then begin SB := SB + '&';  I := PSemi + 1; Continue; end;

    // Нераспознанная сущность — оставляем '&' как есть, дальше идём посимвольно
    SB := SB + '&';
    Inc(I);
  end;

  Result := SB;
end;

function FindOpenTag(const Block, TagName: string; From: Integer;
  out TagCloseBracketPos: Integer; out IsSelfClosing: Boolean): Integer;
var
  Prefix: string;
  P, NameEndPos: Integer;
  C: Char;
begin
  Result := 0;
  TagCloseBracketPos := 0;
  IsSelfClosing := False;
  Prefix := '<' + TagName;
  P := From;
  while True do
  begin
    P := SafeFindPos(Block, Prefix, P);
    if P = 0 then Exit;

    // Символ сразу после имени тега должен быть '>', пробел, таб или '/' —
    // иначе это другой тег с совпадающим началом имени (<ID> vs <IDx>)
    NameEndPos := P + Length(Prefix);
    if NameEndPos > Length(Block) then Exit;
    C := Block[NameEndPos];
    if not (C in ['>', ' ', #9, '/']) then
    begin
      P := P + 1;
      Continue;
    end;

    TagCloseBracketPos := PosEx('>', Block, NameEndPos);
    if TagCloseBracketPos = 0 then Exit;

    IsSelfClosing := Block[TagCloseBracketPos - 1] = '/';
    Result := P;
    Exit;
  end;
end;

function ExtractTag(const Block, TagName: string): string;
var
  OpenPos, TagCloseBracketPos, ValStart, ValEnd, SearchFrom: Integer;
  CloseTag: string;
  IsSelfClosing, Found: Boolean;
begin
  Result := '';
  CloseTag := '</' + TagName + '>';
  SearchFrom := 1;
  Found := False;

  while True do
  begin
    OpenPos := FindOpenTag(Block, TagName, SearchFrom, TagCloseBracketPos, IsSelfClosing);
    if OpenPos = 0 then Break;

    if IsSelfClosing then
    begin
      Result := '';
      Found := True;
      SearchFrom := TagCloseBracketPos + 1;
      Continue;
    end;

    ValStart := TagCloseBracketPos + 1;
    ValEnd := SafeFindPos(Block, CloseTag, ValStart);
    if ValEnd = 0 then Break;

    Result := DecodeXMLText(Copy(Block, ValStart, ValEnd - ValStart));
    Found := True;
    SearchFrom := ValEnd + Length(CloseTag);
  end;

  if not Found then Result := '';
end;

function FindNextBlock(const Text, BlockTagName: string; From: Integer;
  out BlockText: string; out NextSearchPos: Integer): Boolean;
var
  BlockStart, TagCloseBracketPos, BlockEnd: Integer;
  IsSelfClosing: Boolean;
  CloseTag: string;
begin
  Result := False;
  BlockText := '';
  NextSearchPos := From;

  BlockStart := FindOpenTag(Text, BlockTagName, From, TagCloseBracketPos, IsSelfClosing);
  if BlockStart = 0 then Exit;
  if IsSelfClosing then
  begin
    // <BlockTagName/> без содержимого — не считаем валидным блоком записи,
    // но не встаём намертво: продолжаем поиск со следующей позиции
    NextSearchPos := TagCloseBracketPos + 1;
    Result := FindNextBlock(Text, BlockTagName, NextSearchPos, BlockText, NextSearchPos);
    Exit;
  end;

  CloseTag := '</' + BlockTagName + '>';
  BlockEnd := SafeFindPos(Text, CloseTag, TagCloseBracketPos + 1);
  if BlockEnd = 0 then Exit; // не закрыт — дальше файл считаем битым/обрезанным

  BlockText := Copy(Text, BlockStart, BlockEnd - BlockStart);
  NextSearchPos := BlockEnd + Length(CloseTag);
  Result := True;
end;

// ---------------------------------------------------------------------------
// Высокий уровень
// ---------------------------------------------------------------------------

function ReadXMLFileSmart(const FileName: string): string;
{$IFDEF FPC}
// Заглушка ТОЛЬКО для тестов в песочнице — TFile/TEncoding это чистый
// Delphi RTL, которого в FPC нет. Автоопределение кодировки здесь не
// проверяется, проверяется только остальная логика ParseXMLRecords.
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    SL.LoadFromFile(FileName);
    Result := SL.Text;
  finally
    SL.Free;
  end;
end;
{$ELSE}
const
  MaxPrologScan = 200; // xml-декларация всегда в самом начале файла
var
  Bytes: TBytes;
  Enc: TEncoding;
  Offset, ScanLen, P1, P2: Integer;
  Prolog, EncName: string;
begin
  Bytes := TFile.ReadAllBytes(FileName);
  if Length(Bytes) = 0 then Exit('');

  // Шаг 1: BOM — самый надёжный признак
  Enc := nil;
  Offset := TEncoding.GetBufferEncoding(Bytes, Enc, TEncoding.UTF8);
  if Offset > 0 then
  begin
    Result := Enc.GetString(Bytes, Offset, Length(Bytes) - Offset);
    Exit;
  end;

  // Шаг 2: BOM нет — ищем encoding="..." в декларации, читая байты как ASCII
  if MaxPrologScan < Length(Bytes) then ScanLen := MaxPrologScan else ScanLen := Length(Bytes);
  SetString(Prolog, PAnsiChar(@Bytes[0]), ScanLen);

  EncName := '';
  P1 := Pos('encoding="', Prolog);
  if P1 = 0 then P1 := Pos('encoding=''', Prolog);
  if P1 > 0 then
  begin
    P1 := P1 + 10;
    P2 := PosEx('"', Prolog, P1);
    if P2 = 0 then P2 := PosEx('''', Prolog, P1);
    if P2 > P1 then
      EncName := Copy(Prolog, P1, P2 - P1);
  end;

  Enc := nil;
  if EncName <> '' then
    try
      Enc := TEncoding.GetEncoding(EncName);
    except
      Enc := nil;
    end;

  // Шаг 3: ничего не нашли/не распознали — UTF-8 без BOM
  if Enc = nil then
    Enc := TEncoding.UTF8;

  Result := Enc.GetString(Bytes, 0, Length(Bytes));
end;
{$ENDIF}

{$IFDEF FPC}
type
  // Только для тестов в песочнице (см. комментарий у TGetXMLFieldFunc выше)
  TFieldGetterHelper = class
  private
    FBlock: string;
  public
    constructor Create(const ABlock: string);
    function GetField(const TagName: string): string;
  end;

constructor TFieldGetterHelper.Create(const ABlock: string);
begin
  inherited Create;
  FBlock := ABlock;
end;

function TFieldGetterHelper.GetField(const TagName: string): string;
begin
  Result := ExtractTag(FBlock, TagName);
end;
{$ENDIF}

function ParseXMLRecords(const FileName, RecordTagName: string;
  const OnRecord: TOnXMLRecordParsed; const LogProc: TXMLLogProc = nil;
  VerifyRawCount: Boolean = False): TXMLParseStats;
var
  FileText, BlockText: string;
  SearchPos, OpenPos, DummyBracket, RawScanPos: Integer;
  DummySelfClosing: Boolean;
  GetField: TGetXMLFieldFunc;

  {$IFNDEF FPC}
  function MakeGetField(const Block: string): TGetXMLFieldFunc;
  begin
    // Отдельная функция-фабрика, чтобы каждая запись захватывала СВОЙ
    // экземпляр Block, а не общую переменную цикла
    Result :=
      function(const TagName: string): string
      begin
        Result := ExtractTag(Block, TagName);
      end;
  end;
  {$ENDIF}

begin
  Result.RecordsFound := 0;
  Result.RecordsAccepted := 0;
  Result.RecordsRejected := 0;
  Result.RecordsFailed := 0;
  Result.Truncated := False;
  Result.TruncatedAtPos := 0;
  Result.RawTagCountHint := -1;
  Result.ReadFailed := False;
  Result.ReadErrorMessage := '';

  try
    FileText := ReadXMLFileSmart(FileName);
  except
    on E: Exception do
    begin
      Result.ReadFailed := True;
      Result.ReadErrorMessage := E.Message;
      if Assigned(LogProc) then
        LogProc(Format('XML: failed to read file "%s": %s', [FileName, E.Message]));
      Exit; // читать/разбирать больше нечего
    end;
  end;

  SearchPos := 1;
  while True do
  begin
    if not FindNextBlock(FileText, RecordTagName, SearchPos, BlockText, SearchPos) then
    begin
      // Различаем "тегов больше нет" (нормальный конец файла) от
      // "тег открылся, но не закрылся" (файл обрезан/повреждён)
      OpenPos := FindOpenTag(FileText, RecordTagName, SearchPos, DummyBracket, DummySelfClosing);
      if OpenPos > 0 then
      begin
        Result.Truncated := True;
        Result.TruncatedAtPos := OpenPos;
        if Assigned(LogProc) then
          LogProc(Format('XML: unclosed <%s> at position %d in file "%s" — parsing stopped, ' +
            'some records may have been lost (the file is truncated or corrupted)',
            [RecordTagName, OpenPos, FileName]));
      end;
      Break;
    end;

    Inc(Result.RecordsFound);
    {$IFDEF FPC}
    GetField := TFieldGetterHelper.Create(BlockText).GetField;
    {$ELSE}
    GetField := MakeGetField(BlockText);
    {$ENDIF}

    try
      if OnRecord(GetField) then
        Inc(Result.RecordsAccepted)
      else
        Inc(Result.RecordsRejected);
    except
      on E: Exception do
      begin
        // Одна битая запись не должна ронять загрузку всей библиотеки —
        // логируем и идём дальше
        Inc(Result.RecordsFailed);
        if Assigned(LogProc) then
          LogProc(Format('XML: record #%d <%s> in file "%s" raised an exception: %s — skipped',
            [Result.RecordsFound, RecordTagName, FileName, E.Message]));
      end;
    end;
  end;

  if VerifyRawCount then
  begin
    Result.RawTagCountHint := 0;
    RawScanPos := 1;
    while True do
    begin
      RawScanPos := SafeFindPos(FileText, '<' + RecordTagName, RawScanPos);
      if RawScanPos = 0 then Break;
      Inc(Result.RawTagCountHint);
      Inc(RawScanPos);
    end;

    if (Result.RawTagCountHint <> Result.RecordsFound) and Assigned(LogProc) then
      LogProc(Format('XML: rough estimate of <%s> tags in the file (%d) does not match the number of parsed blocks ' +
        'possible data loss (%d) — please check the file "%s" manually',
        [RecordTagName, Result.RawTagCountHint, Result.RecordsFound, FileName]));
  end;

  if Assigned(LogProc) and ((Result.RecordsRejected > 0) or (Result.RecordsFailed > 0) or Result.Truncated) then
    LogProc(Format('XML "%s": found %d, accepted %d, rejected %d, errors %d%s',
      [FileName, Result.RecordsFound, Result.RecordsAccepted, Result.RecordsRejected,
       Result.RecordsFailed, IfThen(Result.Truncated, ', FILE IS TRUNCATED', '')]));
end;

end.
