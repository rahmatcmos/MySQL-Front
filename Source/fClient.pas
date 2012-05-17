unit fClient;

interface {********************************************************************}

uses
  SysUtils, Classes, XMLDoc, XMLIntf, Windows,
  Graphics,
  DB,
  SQLUtils, MySQLDB,
  fAccount;

type
  TMySQLEventType = (etUnknown, etSingle, etMultiple);
  TMySQLIntervalType = (itUnknown, itYear, itQuarter, itMonth, itDay, itHour,
    itMinute, itWeek, itSecond, itMicrosecond, itYearMonth, itDayHour,
    itDayMinute, itDaySecond, itHourMinute, itHourSecond, itMinuteSecond,
    itDayMicrosecond, itHourMicrosecond, itMinuteMicrosecond, itSecondMicrosecond);
  TMySQLFieldType = (mfUnknown,
    mfBit, mfTinyInt, mfSmallInt, mfMediumInt, mfInt, mfBigInt,
    mfFloat, mfDouble, mfDecimal, mfDate, mfDateTime, mfTimeStamp, mfTime, mfYear,
    mfChar, mfVarChar, mfTinyText, mfText, mfMediumText, mfLongText, mfEnum, mfSet,
    mfBinary, mfVarBinary, mfTinyBlob, mfBlob, mfMediumBlob, mfLongBlob,
    mfGeometry, mfPoint, mfLineString, mfPolygon, mfMultiPoint, mfMultiLineString, mfMultiPolygon, mfGeometryCollection);
  TMySQLPartitionType = (ptUnknown, ptHash, ptKey, ptRange, ptList);
  TMySQLRowType = (mrUnknown, mrFixed, mrDynamic, mrCompressed, mrRedundant, mrCompact);
  TMySQLForeignKeyDeleteType = (dtNoAction, dtCascade, dtSetNull, dtSetDefault, dtRestrict);
  TMySQLForeignKeyUpdateType = (utNoAction, utCascade, utSetNull, utSetDefault, utRestrict);
  TMySQLForeignKeyMatchType = (mtNo, mtFull, mtPartial);

const
  NotQuotedFieldTypes = [mfBit, mfTinyInt, mfSmallInt, mfMediumInt, mfInt, mfBigInt, mfFloat, mfDouble, mfDecimal, mfYear];
  BinaryFieldTypes = [mfBinary, mfVarBinary, mfTinyBlob, mfBlob, mfMediumBlob, mfLongBlob];
  TextFieldTypes = [mfChar, mfVarChar, mfTinyText, mfText, mfMediumText, mfLongText, mfEnum, mfSet];

type
  TCIndexColumns = class;
  TCIndex = class;
  TCTableField = class;
  TCBaseTableField = class;
  TCIndices = class;
  TCTableFields = class;
  TCForeignKey = class;
  TCForeignKeys = class;
  TCTable = class;
  TCBaseTable = class;
  TCTables = class;
  TCRoutine = class;
  TCTrigger = class;
  TCTriggers = class;
  TCEvent = class;
  TCEvents = class;
  TCDatabase = class;
  TCVariable = class;
  TCVariables = class;
  TCUserRight = class;
  TCUser = class;
  TCUsers = class;
  TCHostDatabase = class;
  TCHostDatabases = class;
  TCHost = class;
  TCHosts = class;
  TCPlugin = class;
  TCPlugins = class;
  TCEngine = class;
  TCEngines = class;
  TCFieldType = class;
  TCFieldTypes = class;
  TCCharsets = class;
  TCCollation = class;
  TCCollations = class;
  TCClient = class;

  TCSecurity = (seDefiner, seInvoker);

  TCResultSet = class
  type
    TColumnSettings = record
      Visible: array of Boolean;
      Width: array of Integer;
      Index: array of Integer;
    end;
    TMySQLDataSets = array of TMySQLDataSet;
  private
    FClient: TCClient;
    FDataSets: TMySQLDataSets;
    FSelected: TMySQLDataSet;
    FBeforeOpen: TDataSetNotifyEvent;
    FAfterOpen: TDataSetNotifyEvent;
    FBeforeClose: TDataSetNotifyEvent;
    FAfterClose: TDataSetNotifyEvent;
    FBeforePost: TDataSetNotifyEvent;
    FAfterPost: TDataSetNotifyEvent;
    FBeforeCancel: TDataSetNotifyEvent;
    FAfterCancel: TDataSetNotifyEvent;
    FBeforeScroll: TDataSetNotifyEvent;
    FAfterScroll: TDataSetNotifyEvent;
    FBeforeReceivingRecords: TDataSetNotifyEvent;
    FAfterReceivingRecords: TDataSetNotifyEvent;
    FOnResult: TMySQLConnection.TResultEvent;
    function GetActive(): Boolean;
    function GetCount(): Integer;
    function GetDataSet(AIndex: Integer): TMySQLDataSet;
    function ResultAvailable(const Connection: TMySQLConnection; const Data: Boolean): Boolean;
  public
    Columns: array of TColumnSettings;
    property Active: Boolean read GetActive;
    property Client: TCClient read FClient;
    property Count: Integer read GetCount;
    property DataSets[Index: Integer]: TMySQLDataSet read GetDataSet;
    property RawDataSets: TMySQLDataSets read FDataSets;
    property Selected: TMySQLDataSet read FSelected write FSelected;
    property BeforeOpen: TDataSetNotifyEvent read FBeforeOpen write FBeforeOpen;
    property AfterOpen: TDataSetNotifyEvent read FAfterOpen write FAfterOpen;
    property BeforeClose: TDataSetNotifyEvent read FBeforeClose write FBeforeClose;
    property AfterClose: TDataSetNotifyEvent read FAfterClose write FAfterClose;
    property BeforePost: TDataSetNotifyEvent read FBeforePost write FBeforePost;
    property AfterPost: TDataSetNotifyEvent read FAfterPost write FAfterPost;
    property BeforeCancel: TDataSetNotifyEvent read FBeforeCancel write FBeforeCancel;
    property AfterCancel: TDataSetNotifyEvent read FAfterCancel write FAfterCancel;
    property BeforeScroll: TDataSetNotifyEvent read FBeforeScroll write FBeforeScroll;
    property AfterScroll: TDataSetNotifyEvent read FAfterScroll write FAfterScroll;
    property BeforeReceivingRecords: TDataSetNotifyEvent read FBeforeReceivingRecords write FBeforeReceivingRecords;
    property AfterReceivingRecords: TDataSetNotifyEvent read FAfterReceivingRecords write FAfterReceivingRecords;
    procedure Cleanup(); virtual;
    procedure Clear(); virtual;
    constructor Create(const AClient: TCClient); virtual;
    destructor Destroy(); override;
    function IndexOf(const DataSet: TDataSet): Integer; virtual;
    procedure SendSQL(const SQL: string; const OnResult: TMySQLConnection.TResultEvent = nil); virtual;
  end;

  TCItem = class(TObject)
  private
    FName: string;
  protected
    procedure SetName(const AName: string); virtual;
  public
    property Name: string read FName write SetName;
    procedure Assign(const Source: TCItem); virtual;
    function Equal(const Second: TCItem): Boolean; virtual;
    constructor Create(const AName: string = ''); virtual;
  end;

  TCItems = class(TList)
  private
    function GetItem(Index: Integer): TCItem;
  protected
    function GetCount(): Integer; virtual;
  public
    property Count: Integer read GetCount;
    property Item[Index: Integer]: TCItem read GetItem; default;
    procedure Clear(); override;
    destructor Destroy(); override;
    function IndexByName(const Name: string): Integer; virtual;
    function NameCmp(const Name1, Name2: string): Integer; virtual;
  end;

  TCObject = class(TCItem)
  protected
    FActualSource: Boolean;
    FClient: TCClient;
    FSource: string;
    function GetActualSource(): Boolean; virtual;
    function GetSource(): string; virtual;
    procedure SetName(const AName: string); override;
    procedure SetSource(const AField: TField); overload; virtual;
    procedure SetSource(const ADataSet: TMySQLQuery); overload; virtual; abstract;
    procedure SetSource(const ASource: string); overload; virtual;
  public
    property ActualSource: Boolean read GetActualSource;
    property Client: TCClient read FClient;
    property Source: string read GetSource;
    procedure Assign(const Source: TCObject); reintroduce; virtual;
    procedure Clear(); virtual;
    constructor Create(const AClient: TCClient; const AName: string = ''); reintroduce; virtual;
    function Initialize(): Boolean; overload; virtual; abstract;
  end;

  TCObjects = class(TCItems)
  private
    FClient: TCClient;
  protected
    FActual: Boolean;
    function Add(const AObject: TCObject; const ExecuteEvent: Boolean = False): Integer; overload; virtual;
    function Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean; virtual;
    procedure Delete(const AObject: TCObject); overload; virtual;
    function GetActual(): Boolean; virtual;
    function SQLGetItems(const Name: string = ''): string; virtual; abstract;
  public
    property Actual: Boolean read GetActual;
    property Client: TCClient read FClient;
    procedure Clear(); override;
    constructor Create(const AClient: TCClient); reintroduce; virtual;
    destructor Destroy(); override;
    procedure Refresh(); virtual;
  end;

  TCDBObject = class(TCObject)
  private
    FDatabase: TCDatabase;
  protected
    procedure SetSource(const ASource: string); override;
    function SQLGetSource(): string; virtual; abstract;
  public
    property Database: TCDatabase read FDatabase;
    constructor Create(const ADatabase: TCDatabase; const AName: string = ''); reintroduce; virtual;
    function GetSourceEx(const DropBeforeCreate: Boolean = False; const EncloseDefiner: Boolean = True; const ForeignKeysSource: PString = nil): string; virtual; abstract;
    function InitializeSource(): Boolean; virtual;
  end;

  TCDBObjects = class(TCObjects)
  private
    FDatabase: TCDatabase;
  protected
    function Add(const AObject: TCObject; const Event: Boolean = False): Integer; override;
    procedure Delete(const AObject: TCObject); override;
    function GetCount(): Integer; override;
  public
    property Database: TCDatabase read FDatabase;
    constructor Create(const ADatabase: TCDatabase); reintroduce; virtual;
    procedure Refresh(); override;
  end;

  TCIndexColumn = class
  private
    FIndexColumns: TCIndexColumns;
  public
    Ascending: Boolean;
    Field: TCBaseTableField;
    Length: Integer;
    property IndexColumns: TCIndexColumns read FIndexColumns;
    procedure Assign(const Source: TCIndexColumn); virtual;
    procedure Clear(); virtual;
    constructor Create(const AIndexColumns: TCIndexColumns); virtual;
    function Equal(const Second: TCIndexColumn): Boolean; virtual;
  end;

  TCIndexColumns = class(TCItems)
  private
    FIndex: TCIndex;
    function GetColumn(Index: Integer): TCIndexColumn;
  public
    property Column[Index: Integer]: TCIndexColumn read GetColumn; default;
    property Count: Integer read GetCount;
    property Index: TCIndex read FIndex;
    procedure AddColumn(const NewColumn: TCIndexColumn); virtual;
    constructor Create(const AIndex: TCIndex); virtual;
    procedure DeleteColumn(const AColumn: TCIndexColumn); virtual;
    function IndexByField(const AField: TCTableField): Integer; virtual;
  end;

  TCIndex = class(TCItem)
  protected
    Created: Boolean;
    FColumns: TCIndexColumns;
    FIndices: TCIndices;
    OriginalName: string;
    FTable: TCBaseTable;
    function GetCaption(): string;
    function GetIndex(): Integer;
    function GetKey(): Integer;
    function GetTable(): TCBaseTable;
  protected
    property Indices: TCIndices read FIndices;
  public
    Fulltext: Boolean;
    IndexType: string;
    Primary: Boolean;
    Unique: Boolean;
    property Columns: TCIndexColumns read FColumns;
    property Caption: string read GetCaption;
    property Index: Integer read GetIndex;
    property Table: TCBaseTable read GetTable;
    property Key: Integer read GetKey;
    procedure Assign(const Source: TCIndex); reintroduce; virtual;
    procedure Clear(); virtual;
    function ColumnByField(const AField: TCBaseTableField): TCIndexColumn; virtual;
    function ColumnByFieldName(const AFieldName: string): TCIndexColumn; virtual;
    constructor Create(const AIndices: TCIndices); reintroduce; virtual;
    destructor Destroy(); override;
    function Equal(const Second: TCIndex): Boolean; reintroduce; virtual;
    procedure GetSortDef(var SortDef: TIndexDef);
  end;

  TCIndices = class(TCItems)
  private
    FTable: TCBaseTable;
    function GetIndex(Index: Integer): TCIndex;
    function GetPrimary(): TCIndex;
  public
    property Index[Index: Integer]: TCIndex read GetIndex; default;
    property Primary: TCIndex read GetPrimary;
    property Table: TCBaseTable read FTable;
    procedure AddIndex(const NewIndex: TCIndex); virtual;
    procedure Assign(const Source: TCIndices); virtual;
    constructor Create(const ATable: TCBaseTable); reintroduce; virtual;
    procedure DeleteIndex(const AIndex: TCIndex); virtual;
  end;

  TCField = class(TCItem)
  private
    FCharset: string;
    FFieldTypes: TCFieldTypes;
  protected
    procedure ParseFieldType(var Parse: TSQLParse); virtual;
  public
    Charset: string;
    Decimals: Integer;
    FieldType: TMySQLFieldType;
    Items: array of string;
    National: Boolean;
    Size: Integer;
    Unsigned: Boolean;
    property FieldTypes: TCFieldTypes read FFieldTypes;
    procedure Assign(const Source: TCField); reintroduce; virtual;
    procedure Clear(); virtual;
    constructor Create(const AFieldTypes: TCFieldTypes); reintroduce; virtual;
    function DBTypeStr(): string; virtual;
    function Equal(const Second: TCField): Boolean; reintroduce; virtual;
    function EscapeValue(const Value: string): string; virtual;
  end;

  TCTableField = class(TCField)
  private
    FCollation: string;
    FDesktopXML: IXMLNode;
    FFields: TCTableFields;
    FInPrimaryIndex: Boolean;
    FInUniqueIndex: Boolean;
    function GetDesktopXML(): IXMLNode;
    function GetTable(): TCTable;
  protected
    property DesktopXML: IXMLNode read GetDesktopXML;
    property Fields: TCTableFields read FFields;
    function GetIndex(): Integer; virtual;
    procedure ParseFieldType(var Parse: TSQLParse); override;
  public
    Ascii: Boolean;
    AutoIncrement: Boolean;
    Binary: Boolean;
    Comment: string;
    Default: string;
    FieldBefore: TCTableField;
    NullAllowed: Boolean;
    Unicode: Boolean;
    Zerofill: Boolean;
    property Collation: string read FCollation write FCollation;
    property InPrimaryIndex: Boolean read FInPrimaryIndex;
    property InUniqueIndex: Boolean read FInUniqueIndex;
    property Index: Integer read GetIndex;
    property Table: TCTable read GetTable;
    procedure Assign(const Source: TCField); override;
    procedure Clear(); override;
    constructor Create(const AFields: TCTableFields); reintroduce; virtual;
    function DBTypeStr(): string; override;
    destructor Destroy(); override;
    function Equal(const Second: TCTableField): Boolean; reintroduce; virtual;
    function UnescapeValue(const Value: string): string; virtual;
  end;

  TCBaseTableField = class(TCTableField)
  private
    function GetTable(): TCBaseTable;
  public
    Moved: Boolean;
    OnUpdate: string;
    OriginalName: string;
    property Table: TCBaseTable read GetTable;
    procedure Assign(const Source: TCField); override;
    procedure Clear(); override;
  end;

  TCViewField = class(TCTableField)
  public
  end;

  TCTableFields = class(TCItems)
  private
    FDesktopXML: IXMLNode;
    FTable: TCTable;
    function GetDesktopXML(): IXMLNode;
    function GetField(Index: Integer): TCTableField;
  protected
    property DesktopXML: IXMLNode read GetDesktopXML;
    function FieldByName(const FieldName: string): TCTableField; virtual;
  public
    property Field[Index: Integer]: TCTableField read GetField; default;
    property Table: TCTable read FTable;
    procedure AddField(const NewField: TCTableField); virtual;
    procedure Assign(const Source: TCTableFields); virtual;
    constructor Create(const ATable: TCTable); reintroduce; virtual;
    procedure DeleteField(const AField: TCTableField); virtual;
    function IndexOf(const AField: TCTableField): Integer; virtual;
  end;

  TCBaseTableFields = class(TCTableFields)
  public
    procedure MoveField(const AField: TCTableField; const NewFieldBefore: TCTableField); virtual;
  end;

  TCForeignKey = class(TCItem)
  private
    FForeignKeys: TCForeignKeys;
    function GetIndex(): Integer;
    function GetTable(): TCBaseTable;
  protected
    Created: Boolean;
    OriginalName: string;
    property ForeignKeys: TCForeignKeys read FForeignKeys;
  public
    Fields: array of TCTableField;
    Match: TMySQLForeignKeyMatchType;
    OnDelete: TMySQLForeignKeyDeleteType;
    OnUpdate: TMySQLForeignKeyUpdateType;
    Parent : record
      DatabaseName: string;
      TableName: string;
      FieldNames: array of string;
    end;
    property Index: Integer read GetIndex;
    property Table: TCBaseTable read GetTable;
    procedure Assign(const Source: TCForeignKey); reintroduce; virtual;
    procedure Clear(); virtual;
    constructor Create(const AForeignKeys: TCForeignKeys); reintroduce; virtual;
    function DBTypeStr(): string; virtual;
    function Equal(const Second: TCForeignKey): Boolean; reintroduce; virtual;
    destructor Destroy(); override;
  end;

  TCForeignKeys = class(TCItems)
  private
    FTable: TCBaseTable;
    function GetClient(): TCClient; inline;
    function GetForeignKey(Index: Integer): TCForeignKey;
  protected
    Actual: Boolean;
    function GetCount(): Integer; override;
    procedure ParseCreateTable(const SQL: string); virtual;
  public
    procedure AddForeignKey(const NewForeignKey: TCForeignKey); virtual;
    procedure Assign(const Source: TCForeignKeys); virtual;
    procedure Clear(); override;
    constructor Create(const ATable: TCBaseTable); reintroduce; virtual;
    procedure DeleteForeignKey(const AForeignKey: TCForeignKey); virtual;
    procedure InsertForeignKey(const Index: Integer; const NewForeignKey: TCForeignKey); virtual;
    property Client: TCClient read GetClient;
    property ForeignKey[Index: Integer]: TCForeignKey read GetForeignKey; default;
    property Table: TCBaseTable read FTable;
  end;

  TCTableDesktop = class
  private
    FColumnIndices: array of Integer;
    FTable: TCTable;
    function GetColumnIndex(Index: Integer): Integer;
    function GetColunns(): Integer;
    function GetFilter(Index: Integer): string;
    function GetFilterCount(): Integer;
    function GetGridVisible(FieldName: string): Boolean;
    function GetGridWidth(FieldName: string): Integer;
    function GetLimit(): Integer;
    function GetLimited(): Boolean;
    procedure SetColumnIndex(Index: Integer; const Value: Integer);
    procedure SetGridVisible(FieldName: string; const Visible: Boolean);
    procedure SetGridWidth(FieldName: string; const GridWidth: Integer);
    procedure SetLimit(const Limit: Integer);
    procedure SetLimited(const ALimited: Boolean);
  protected
    property Table: TCTable read FTable;
    procedure Clear(); virtual;
    procedure AddFilter(const AFilter: string); virtual;
  public
    property Columns: Integer read GetColunns;
    property ColumnIndices[Index: Integer]: Integer read GetColumnIndex write SetColumnIndex;
    property Filters[Index: Integer]: string read GetFilter;
    property FilterCount: Integer read GetFilterCount;
    property Limit: Integer read GetLimit write SetLimit;
    property Limited: Boolean read GetLimited write SetLimited;
    property GridVisible[FieldName: string]: Boolean read GetGridVisible write SetGridVisible;
    property GridWidths[FieldName: string]: Integer read GetGridWidth write SetGridWidth;
    constructor Create(const ATable: TCTable); virtual;
    destructor Destroy(); override;
  end;

  TCTableDataSet = class(TMySQLTable)
  private
    FQuickSearch: string;
    FTable: TCTable;
  protected
    function SQLSelect(const IgnoreLimit: Boolean = False): string; override;
  public
    property QuickSearch: string read FQuickSearch;
    property Table: TCTable read FTable;
    constructor Create(const ATable: TCTable); reintroduce; virtual;
  end;

  TCTable = class(TCDBObject)
  private
    FActual: Boolean;
    FDesktopXML: IXMLNode;
    FDataSet: TCTableDataSet;
    FDesktop: TCTableDesktop;
    FFields: TCTableFields;
    FFilterSQL: string;
    procedure AfterCancel(DataSet: TDataSet);
    procedure AfterClose(DataSet: TDataSet);
    procedure AfterOpen(DataSet: TDataSet);
    procedure AfterScroll(DataSet: TDataSet);
    procedure AfterPost(DataSet: TDataSet);
    procedure AfterReceivingRecords(DataSet: TDataSet);
    procedure BeforeCancel(DataSet: TDataSet);
    procedure BeforeClose(DataSet: TDataSet);
    procedure BeforeOpen(DataSet: TDataSet);
    procedure BeforePost(DataSet: TDataSet);
    procedure BeforeReceivingRecords(DataSet: TDataSet);
    procedure BeforeScroll(DataSet: TDataSet);
    function GetDataSet(): TCTableDataSet;
    function GetDesktopXML(): IXMLNode;
    function GetIndex(): Integer;
  protected
    function GetFields(): TCTableFields; virtual;
    procedure SetName(const AName: string); override;
    property Actual: Boolean read FActual;
    property DesktopXML: IXMLNode read GetDesktopXML;
  public
    procedure Assign(const Source: TCTable); reintroduce; virtual;
    procedure Clear(); override;
    function CountRecords(): Integer; virtual;
    constructor Create(const ADatabase: TCDatabase = nil; const AName: string = ''); reintroduce; virtual;
    function DeleteRecords(const Field: TCTableField; const Values: TStringList): Boolean; virtual;
    destructor Destroy(); override;
    function FieldByName(const FieldName: string): TCTableField; virtual;
    function GetSourceEx(const DropBeforeCreate: Boolean = False; const EncloseDefiner: Boolean = True; const ForeignKeysSource: PString = nil): string; override;
    function Initialize(): Boolean; override;
    function Open(const FilterSQL, QuickSearch: string; const ASortDef: TIndexDef; const Offset: Integer; const Limit: Integer): Boolean; virtual;
    property DataSet: TCTableDataSet read GetDataSet;
    property Desktop: TCTableDesktop read FDesktop;
    property Fields: TCTableFields read GetFields;
    property Index: Integer read GetIndex;
  end;

  TCPartition = class(TCItem)
  private
    FTable: TCBaseTable;
  protected
    OriginalName: string;
    function DBTypeStr(): string; virtual;
  public
    Comment: string;
    Engine: TCEngine;
    MaxRows: Integer;
    MinRows: Integer;
    ValuesExpr: string;
    property Table: TCBaseTable read FTable;
    procedure Assign(const Source: TCPartition); reintroduce; virtual;
    procedure Clear(); virtual;
    constructor Create(const ATable: TCBaseTable); reintroduce; virtual;
    function Equal(const Second: TCPartition): Boolean; reintroduce; virtual;
  end;

  TCPartitions = class(TCItems)
  private
    FCount: Integer;
    FTable: TCBaseTable;
    function GetPartition(Index: Integer): TCPartition;
  protected
    function GetCount(): Integer; override;
  public
    Expression: string;
    Linear: Boolean;
    PartitionType: TMySQLPartitionType;
    property Table: TCBaseTable read FTable;
    property Partition[Index: Integer]: TCPartition read GetPartition; default;
    procedure AddPartition(const NewPartition: TCPartition); virtual;
    procedure Assign(const Source: TCPartitions); virtual;
    procedure Clear(); override;
    constructor Create(const ATable: TCBaseTable); reintroduce; virtual;
    procedure DeletePartition(const APartition: TCPartition); virtual;
    function IndexOf(const APartition: TCPartition): Integer; virtual;
    procedure MovePartition(const APartition: TCPartition; const NewIndex: Integer); virtual;
    function UpdatePartition(const Partition, NewPartition: TCPartition): Boolean; virtual;
  end;

  TCPackIndices = (piUnpacked, piPacked, piDefault);

  TCBaseTable = class(TCTable)
  private
    FAutoIncrement: LargeInt; // 0 -> unknown
    FChecked: TDateTime;
    FCollation: string;
    FComment: string;
    FCreated: TDateTime;
    FDataSize: Int64;
    FDefaultCharset: string;
    FDefaultCodePage: Cardinal;
    FEngine: TCEngine;
    FForeignKeys: TCForeignKeys;
    FIndexSize: Int64;
    FIndices: TCIndices;
    FMaxDataSize: Int64;
    FPackIndices: TCPackIndices;
    FPartitions: TCPartitions;
    FRows: Int64;
    FRowType: TMySQLRowType;
    FTemporary: Boolean;
    FUnusedSize: Int64;
    FUpdated: TDateTime;
    function GetAutoIncrementField(): TCBaseTableField;
    function GetCollation(): string;
    function GetComment(): string;
    function GetDefaultCharset(): string;
    function GetDefaultCodePage(): Cardinal;
    function GetEngine(): TCEngine;
    function GetForeignKeys(): TCForeignKeys;
    function GetIndexSize(): Int64;
    function GetIndices(): TCIndices;
    function GetPartitions(): TCPartitions;
    function GetPrimaryIndex(): TCIndex;
    procedure SetDefaultCharset(const ADefaultCharset: string);
  protected
    FActualStatus: Boolean;
    procedure BuildStatus(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean); virtual;
    function GetBaseTableFields(): TCBaseTableFields; virtual;
    function GetFields(): TCTableFields; override;
    procedure ParseCreateTable(const SQL: string); virtual;
    procedure SetSource(const ADataSet: TMySQLQuery); overload; override;
    function SQLGetSource(): string; override;
  public
    property ActualStatus: Boolean read FActualStatus;
    property AutoIncrement: LargeInt read FAutoIncrement write FAutoIncrement;
    property AutoIncrementField: TCBaseTableField read GetAutoIncrementField;
    property Checked: TDateTime read FChecked write FChecked;
    property Collation: string read GetCollation write FCollation;
    property Comment: string read GetComment write FComment;
    property Created: TDateTime read FCreated;
    property DataSize: Int64 read FDataSize;
    property DefaultCharset: string read GetDefaultCharset write SetDefaultCharset;
    property DefaultCodePage: Cardinal read GetDefaultCodePage;
    property Engine: TCEngine read GetEngine write FEngine;
    property Fields: TCBaseTableFields read GetBaseTableFields;
    property IndexSize: Int64 read GetIndexSize;
    property ForeignKeys: TCForeignKeys read GetForeignKeys;
    property Indices: TCIndices read GetIndices;
    property MaxDataSize: Int64 read FMaxDataSize;
    property PackIndices: TCPackIndices read FPackIndices write FPackIndices;
    property Partitions: TCPartitions read GetPartitions;
    property PrimaryIndex: TCIndex read GetPrimaryIndex;
    property Rows: Int64 read FRows;
    property RowType: TMySQLRowType read FRowType write FRowType;
    property Temporary: Boolean read FTemporary write FTemporary;
    property UnusedSize: Int64 read FUnusedSize write FUnusedSize;
    property Updated: TDateTime read FUpdated;
    procedure Assign(const Source: TCTable); override;
    function Check(): Boolean; virtual;
    procedure Clear(); override;
    procedure ClearBySource(const ASource: string); virtual;
    function FieldByName(const FieldName: string): TCBaseTableField; reintroduce; virtual;
    function ForeignKeyByName(const ForeignKeyName: string): TCForeignKey; virtual;
    function CountRecords(): Integer; override;
    constructor Create(const ADatabase: TCDatabase = nil; const AName: string = ''; const ASystemTable: Boolean = False); reintroduce; virtual;
    destructor Destroy(); override;
    function DBRowTypeStr(): string; virtual;
    function Empty(): Boolean; virtual;
    function EmptyFields(const Names: array of string): Boolean; virtual;
    function Flush(): Boolean; virtual;
    function GetSourceEx(const DropBeforeCreate: Boolean = False; const EncloseDefiner: Boolean = True; const ForeignKeysSource: PString = nil): string; override;
    function IndexByCaption(const Caption: string): TCIndex; virtual;
    function IndexByName(const IndexName: string): TCIndex; virtual;
    function IndexByDataSet(const DataSet: TCTableDataSet): TCIndex; virtual;
    function Open(const Filter, QuickSearch: string; const ASortDef: TIndexDef; const Offset: Integer; const Limit: Integer): Boolean; override;
    function Optimize(): Boolean; virtual;
    function PartitionByName(const PartitionName: string): TCPartition; virtual;
    function Repair(): Boolean; virtual;
  end;

  TCSystemView = class(TCBaseTable)
  end;

  TCView = class(TCTable)
  type
    TAlgorithm = (vaUndefined, vaMerge, vaTemptable);
    TCheckOption = (voNone, voDefault, voCascaded, voLocal);
  private
    FAlgorithm: TAlgorithm;
    FCheckOption: TCheckOption;
    FComment: string;
    FDefiner: string;
    FSecurity: TCSecurity;
    FStatement: string;
    FSynMemo: TComponent;
    function ParseCreateView(const SQL: string; const RemoveDefiner: Boolean = False; const RemoveDatabaseName: Boolean = False): string;
  protected
    function GetActualSource(): Boolean; override;
    procedure SetSource(const ADataSet: TMySQLQuery); overload; override;
    procedure SetSource(const ASource: string); override;
    function SQLGetSource(): string; override;
  public
    property Algorithm: TAlgorithm read FAlgorithm write FAlgorithm;
    property CheckOption: TCheckOption read FCheckOption write FCheckOption;
    property Comment: string read FComment write FComment;
    property Definer: string read FDefiner;
    property Security: TCSecurity read FSecurity write FSecurity;
    property Statement: string read FStatement write FStatement;
    property SynMemo: TComponent read FSynMemo write FSynMemo;
    procedure Assign(const Source: TCTable); override;
    procedure Clear(); override;
    constructor Create(const ADatabase: TCDatabase = nil; const AName: string = ''); override;
    destructor Destroy(); override;
    function GetSourceEx(const DropBeforeCreate: Boolean = False; const EncloseDefiner: Boolean = True; const ForeignKeysSource: PString = nil): string; overload; override;
  end;

  TCTables = class(TCDBObjects)
  private
    FActualNames: Boolean;
    FDesktopXML: IXMLNode;
    function GetBaseTable(Index: Integer): TCBaseTable;
    function GetDesktopXML(): IXMLNode;
    function GetTable(Index: Integer): TCTable;
  protected
    property DesktopXML: IXMLNode read GetDesktopXML;
    function Add(const AObject: TCObject; const Event: Boolean = False): Integer; override;
    function Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean; override;
    procedure BuildViewFields(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean); virtual;
    procedure Delete(const AObject: TCObject); override;
    function GetCount(): Integer; override;
    function SQLGetItems(const Name: string = ''): string; override;
    function SQLGetNames(): string; virtual;
  public
    property ActualNames: Boolean read FActualNames;
    property BaseTable[Index: Integer]: TCBaseTable read GetBaseTable;
    property Table[Index: Integer]: TCTable read GetTable; default;
    procedure AddTable(const NewTable: TCTable); virtual;
    function ApplyMySQLTableName(const ATableName: string): string; virtual;
    procedure Assign(const Source: TCTables); virtual;
    procedure Clear(); override;
    constructor Create(const ADatabase: TCDatabase); override;
    function IndexByName(const Name: string): Integer; override;
  end;

  TCRoutineParameter = class(TCField)
  type
    TParameterType = (ptIn, ptOut, ptInOut);
  private
    FRoutine: TCRoutine;
    FParameterType: TParameterType;
  public
    property Routine: TCRoutine read FRoutine;
    property ParameterType: TParameterType read FParameterType;
    procedure Assign(const Source: TCField); override;
    constructor Create(ARoutine: TCRoutine); reintroduce; virtual;
  end;

  TCRoutine = class(TCDBObject)
  type
    TRoutineType = (rtUnknown, rtProcedure, rtFunction);
    TMySQLDataSets = array of TMySQLDataSet;
  private
    FComment: string;
    FCreated: TDateTime;
    FDefiner: string;
    FFunctionResult: TCField;
    FIDEResult: TCResultSet;
    FInputDataSet: TMySQLDataSet;
    FModified: TDateTime;
    FParameters: array of TCRoutineParameter;
    FRoutineType: TRoutineType;
    FSecurity: TCSecurity;
    FSynMemo: TComponent;
    OldSource: string;
    function GetIDEResult(): TCResultSet;
    function GetInputDataSet(): TMySQLDataSet;
    function GetParameter(Index: Integer): TCRoutineParameter;
    function GetParameterCount(): Integer;
    procedure ParseCreateRoutine(const SQL: string);
  protected
    function SQLGetSource(): string; override;
    procedure SetSource(const ADataSet: TMySQLQuery); overload; override;
    procedure SetSource(const ASource: string); override;
  public
    procedure Assign(const Source: TCRoutine); reintroduce; virtual;
    procedure Clear(); override;
    constructor Create(const ADatabase: TCDatabase; const AName: string = ''); override;
    destructor Destroy(); override;
    function GetSourceEx(const DropBeforeCreate: Boolean = False; const EncloseDefiner: Boolean = True; const ForeignKeysSource: PString = nil): string; override;
    function Initialize(): Boolean; override;
    function SQLRun(): string; virtual;
    property Comment: string read FComment write FComment;
    property Created: TDateTime read FCreated;
    property Definer: string read FDefiner;
    property FunctionResult: TCField read FFunctionResult;
    property IDEResult: TCResultSet read GetIDEResult;
    property InputDataSet: TMySQLDataSet read GetInputDataSet;
    property Modified: TDateTime read FModified;
    property Security: TCSecurity read FSecurity write FSecurity;
    property Source: string read GetSource write SetSource;
    property SynMemo: TComponent read FSynMemo write FSynMemo;
    property Parameter[Index: Integer]: TCRoutineParameter read GetParameter;
    property ParameterCount: Integer read GetParameterCount;
    property RoutineType: TRoutineType read FRoutineType;
  end;

  TCProcedure = class(TCRoutine)
  protected
    procedure SetSource(const ADataSet: TMySQLQuery); overload; override;
    function SQLGetSource(): string; override;
  public
    function SQLRun(): string; override;
  end;

  TCFunction = class(TCRoutine)
  protected
    procedure SetSource(const ADataSet: TMySQLQuery); overload; override;
    function SQLGetSource(): string; override;
  public
    function SQLRun(): string; override;
  end;

  TCRoutines = class(TCDBObjects)
  private
    function GetRoutine(Index: Integer): TCRoutine;
  protected
    function Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean; override;
    function SQLGetItems(const Name: string = ''): string; override;
  public
    property Routine[Index: Integer]: TCRoutine read GetRoutine; default;
    procedure AddRoutine(const NewRoutine: TCRoutine); virtual;
    procedure Assign(const Source: TCRoutines); virtual;
    constructor Create(const ADatabase: TCDatabase); reintroduce; virtual;
  end;

  TCTrigger = class(TCDBObject)
  type
    TEvent = (teInsert, teUpdate, teDelete);
    TTiming = (ttBefore, ttAfter);
  private
    FInputDataSet: TMySQLDataSet;
    OldSource: string;
    function GetInputDataSet(): TMySQLDataSet;
    function GetTable(): TCBaseTable;
  protected
    FActual: Boolean;
    FCreated: TDateTime;
    FDefiner: string;
    FEvent: TEvent;
    FStatement: string;
    FSynMemo: TComponent;
    FTableName: string;
    FTiming: TTiming;
    procedure SetSource(const ADataSet: TMySQLQuery); overload; override;
    function SQLGetSource(): string; override;
    property Actual: Boolean read FActual;
  public
    procedure Assign(const Source: TCTrigger); reintroduce; virtual;
    procedure Clear(); override;
    constructor Create(const ADatabase: TCDatabase; const AName: string = ''); override;
    destructor Destroy(); override;
    function GetSourceEx(const DropBeforeCreate: Boolean = False; const EncloseDefiner: Boolean = True; const ForeignKeysSource: PString = nil): string; override;
    function Initialize(): Boolean; override;
    function SQLDelete(): string; virtual;
    function SQLInsert(): string; virtual;
    function SQLReplace(): string; virtual;
    function SQLUpdate(): string; virtual;
    property Created: TDateTime read FCreated;
    property Definer: string read FDefiner;
    property Event: TEvent read FEvent write FEvent;
    property InputDataSet: TMySQLDataSet read GetInputDataSet;
    property Source: string read GetSource;
    property Statement: string read FStatement write FStatement;
    property SynMemo: TComponent read FSynMemo write FSynMemo;
    property Table: TCBaseTable read GetTable;
    property TableName: string read FTableName write FTableName;
    property Timing: TTiming read FTiming write FTiming;
  end;

  TCTriggers = class(TCDBObjects)
  private
    function GetTrigger(Index: Integer): TCTrigger;
  protected
    function Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean; override;
    function SQLGetItems(const Name: string = ''): string; override;
  public
    property Trigger[Index: Integer]: TCTrigger read GetTrigger; default;
    constructor Create(const ADatabase: TCDatabase); reintroduce; virtual;
  end;

  TCEvent = class(TCDBObject)
  private
    FCreated: TDateTime;
    FComment: string;
    FDefiner: string;
    FEnabled: Boolean;
    FEndDateTime: TDateTime;
    FEventType: TMySQLEventType;
    FExecute: TDateTime;
    FIntervalType: TMySQLIntervalType;
    FIntervalValue: string;
    FPreserve: Boolean;
    FStartDateTime: TDateTime;
    FStatement: string;
    FSynMemo: TComponent;
    FUpdated: TDateTime;
  protected
    procedure ParseCreateEvent(const SQL: string); virtual;
    procedure SetSource(const ADataSet: TMySQLQuery); overload; override;
    procedure SetSource(const ASource: string); override;
    function SQLGetSource(): string; override;
  public
    procedure Assign(const Source: TCEvent); reintroduce; virtual;
    procedure Clear(); override;
    constructor Create(const ADatabase: TCDatabase; const AName: string = ''); override;
    function GetSourceEx(const DropBeforeCreate: Boolean = False; const EncloseDefiner: Boolean = True; const ForeignKeysSource: PString = nil): string; override;
    function Initialize(): Boolean; override;
    function SQLRun(): string; virtual;
    property Created: TDateTime read FCreated write FCreated;
    property Comment: string read FComment write FComment;
    property Definer: string read FDefiner write FDefiner;
    property Enabled: Boolean read FEnabled write FEnabled;
    property EndDateTime: TDateTime read FEndDateTime write FEndDateTime;
    property EventType: TMySQLEventType read FEventType write FEventType;
    property Execute: TDateTime read FExecute write FExecute;
    property IntervalType: TMySQLIntervalType read FIntervalType write FIntervalType;
    property IntervalValue: string read FIntervalValue write FIntervalValue;
    property Preserve: Boolean read FPreserve write FPreserve;
    property Source: string read GetSource;
    property StartDateTime: TDateTime read FStartDateTime write FStartDateTime;
    property Statement: string read FStatement write FStatement;
    property SynMemo: TComponent read FSynMemo write FSynMemo;
    property Updated: TDateTime read FUpdated;
  end;

  TCEvents = class(TCDBObjects)
  private
    function GetEvent(Index: Integer): TCEvent;
  protected
    function Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean; override;
    function SQLGetItems(const Name: string = ''): string; override;
  public
    property Event[Index: Integer]: TCEvent read GetEvent; default;
    constructor Create(const ADatabase: TCDatabase); reintroduce; virtual;
  end;

  TCDatabase = class(TCObject)
  private
    FDefaultCharset: string;
    FDefaultCodePage: Cardinal;
    FDesktopXML: IXMLNode;
    FCollation: string;
    FEvents: TCEvents;
    FRoutines: TCRoutines;
    FTables: TCTables;
    FTriggers: TCTriggers;
    FWorkbench: TComponent;
    function GetActual(): Boolean;
    function GetActualSources(): Boolean;
    function GetDefaultCharset(): string;
    function GetCollation(): string;
    function GetCount(): Integer;
    function GetCreated(): TDateTime;
    function GetDesktopXML(): IXMLNode;
    function GetPrefetchObjects(): Boolean;
    function GetSize(): Int64;
    function GetUpdated(): TDateTime;
    procedure ParseCreateDatabase(const SQL: string);
    procedure SetDefaultCharset(const ADefaultCharset: string);
  protected
    function GetActualSource(): Boolean; override;
    function Build(const DataSet: TMySQLQuery): Boolean; virtual;
    function GetSource(): string; override;
    procedure SetName(const AName: string); override;
    procedure SetSource(const ADataSet: TMySQLQuery); override;
    function SQLAlterTable(const Table, NewTable: TCBaseTable; const EncloseFields: Boolean = True): string; virtual;
    function SQLGetSource(): string; virtual;
    function SQLTruncateTable(const Table: TCBaseTable): string; virtual;
    property DesktopXML: IXMLNode read GetDesktopXML;
    property PrefetchObjects: Boolean read GetPrefetchObjects;
  public
    function AddEvent(const NewEvent: TCEvent): Boolean; virtual;
    function AddRoutine(const NewRoutine: TCRoutine): Boolean; virtual;
    function AddTable(const NewTable: TCBaseTable): Boolean; virtual;
    function AddTrigger(const NewTrigger: TCTrigger): Boolean; virtual;
    function AddView(const NewView: TCView): Boolean; virtual;
    procedure Assign(const Source: TCDatabase); reintroduce; virtual;
    function BaseTableByName(const TableName: string): TCBaseTable; overload; virtual;
    procedure Clear(); override;
    function CloneRoutine(const Routine: TCRoutine; const NewRoutineName: string): Boolean; overload; virtual;
    function CloneTable(const Table: TCBaseTable; const NewTableName: string; const Data: Boolean): Boolean; overload; virtual;
    function CloneView(const View: TCView; const NewViewName: string): Boolean; virtual;
    constructor Create(const AClient: TCClient = nil; const AName: string = ''); reintroduce; virtual;
    function DeleteObjects(const Objects: array of TCDBObject): Boolean; virtual;
    destructor Destroy(); override;
    function EmptyTables(const TableNames: array of string): Boolean; virtual;
    function EventByName(const EventName: string): TCEvent; virtual;
    function Initialize(): Boolean; overload; override;
    function Initialize(const Param: TObject): Boolean; overload; virtual;
    function InitializeSources(const Param: TObject = nil): Boolean; virtual;
    function FlushTables(const TableNames: array of string): Boolean; virtual;
    function FunctionByName(const FunctionName: string): TCFunction; virtual;
    function GetSourceEx(const DropBeforeCreate: Boolean = False): string; virtual;
    function OptimizeTables(const TableNames: array of string): Boolean; virtual;
    function RenameTable(const Table: TCTable; const NewTableName: string): Boolean; virtual;
    function TableByName(const TableName: string): TCTable; overload; virtual;
    function TriggerByName(const TriggerName: string): TCTrigger; virtual;
    function ProcedureByName(const ProcedureName: string): TCProcedure;
    procedure Refresh(); virtual;
    function SQLUse(): string; virtual;
    function Unlock(): Boolean; virtual;
    function UpdateEvent(const Event, NewEvent: TCEvent): Boolean; virtual;
    function UpdateRoutine(const Routine, NewRoutine: TCRoutine): Boolean; virtual;
    function UpdateTable(const Table, NewTable: TCBaseTable): Boolean; virtual;
    function UpdateTables(const TableNames: TStringList; const ACharset, ACollation, AEngine: string; const ARowType: TMySQLRowType): Boolean; virtual;
    function UpdateTrigger(const Trigger, NewTrigger: TCTrigger): Boolean; virtual;
    function UpdateView(const View, NewView: TCView): Boolean; virtual;
    function ViewByName(const TableName: string): TCView; overload; virtual;
    property Actual: Boolean read GetActual;
    property ActualSources: Boolean read GetActualSources;
    property DefaultCharset: string read GetDefaultCharset write SetDefaultCharset;
    property DefaultCodePage: Cardinal read FDefaultCodePage;
    property Count: Integer read GetCount;
    property Collation: string read GetCollation write FCollation;
    property Created: TDateTime read GetCreated;
    property Events: TCEvents read FEvents;
    property Routines: TCRoutines read FRoutines;
    property Size: Int64 read GetSize;
    property Tables: TCTables read FTables;
    property Triggers: TCTriggers read FTriggers;
    property Updated: TDateTime read GetUpdated;
    property Workbench: TComponent read FWorkbench write FWorkbench;
  end;

  TCSystemDatabase = class(TCDatabase)
  end;

  TCDatabases = class(TCObjects)
  private
    FDesktopXML: IXMLNode;
    function GetDatabase(Index: Integer): TCDatabase;
    function GetDesktopXML(): IXMLNode;
  protected
    property DesktopXML: IXMLNode read GetDesktopXML;
    function Add(const AObject: TCObject; const Event: Boolean = False): Integer; override;
    function Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean; override;
    procedure Delete(const AObject: TCObject); override;
    function GetCount(): Integer; override;
    function SQLGetItems(const Name: string = ''): string; override;
  public
    property Database[Index: Integer]: TCDatabase read GetDatabase; default;
    procedure Clear(); override;
    constructor Create(AClient: TCClient); reintroduce; virtual;
    function IndexByName(const Name: string): Integer; override;
  end;

  TCVariable = class(TCItem)
  type
    TUpdateMode = (vuGlobal, vuSession);
    TUpdateModes = set of TUpdateMode;
  private
    FValue: string;
    FVariables: TCVariables;
    function GetAsBoolean(): Boolean;
    function GetAsFloat(): Double;
    function GetAsInteger(): Integer;
    procedure SetAsBoolean(const AAsBoolean: Boolean);
    procedure SetAsFloat(const AAsFloat: Double);
    procedure SetAsInteger(const AAsInteger: Integer);
  public
    property AsBoolean: Boolean read GetAsBoolean write SetAsBoolean;
    property AsFloat: Double read GetAsFloat write SetAsFloat;
    property AsInteger: Integer read GetAsInteger write SetAsInteger;
    property Value: string read FValue write FValue;
    property Variables: TCVariables read FVariables;
    procedure Assign(const Source: TCVariable); reintroduce; virtual;
    constructor Create(const AVariables: TCVariables; const AName: string = ''); reintroduce; virtual;
  end;

  TCVariables = class(TCObjects)
  private
    function GetVariable(Index: Integer): TCVariable;
  protected
    function Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean; override;
    function SQLGetItems(const Name: string = ''): string; override;
  public
    property Variable[Index: Integer]: TCVariable read GetVariable; default;
  end;

  TCStatus = class(TCItem)
  public
    Value: string;
  end;

  TCStati = class(TCObjects)
  private
    function GetStatus(Index: Integer): TCStatus;
  protected
    function Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean; override;
    function SQLGetItems(const Name: string = ''): string; override;
  public
    property Status[Index: Integer]: TCStatus read GetStatus; default;
  end;

  TCEngine = class(TCItem)
  private
    FComment: string;
    FDefault: Boolean;
    FEngines: TCEngines;
    function GetForeignKeyAllowed(): Boolean;
    function GetIsMerge(): Boolean;
  public
    property Comment: string read FComment write FComment;
    property Default: Boolean read FDefault;
    property Engines: TCEngines read FEngines;
    property ForeignKeyAllowed: Boolean read GetForeignKeyAllowed;
    property IsMerge: Boolean read GetIsMerge;
    constructor Create(const AEngines: TCEngines; const AName: string = ''); reintroduce; virtual;
    function FieldAvailable(const MySQLFieldType: TMySQLFieldType): Boolean; virtual;
    function ApplyMySQLFieldType(const MySQLFieldType: TMySQLFieldType; const MySQLFieldSize: Integer): TMySQLFieldType; virtual;
  end;

  TCSystemEngine = class(TCEngine);

  TCEngines = class(TCObjects)
  private
    function GetDefaultEngine(): TCEngine;
    function GetEngine(Index: Integer): TCEngine;
  protected
    function Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean; override;
    function GetActual(): Boolean; override;
    function SQLGetItems(const Name: string = ''): string; override;
  public
    property DefaultEngine: TCEngine read GetDefaultEngine;
    property Engine[Index: Integer]: TCEngine read GetEngine; default;
  end;

  TCPlugin = class(TCItem)
  protected
    FComment: string;
    FPlugins: TCPlugins;
  public
    property Comment: string read FComment;
    property Plugins: TCPlugins read FPlugins;
    constructor Create(const APlugins: TCPlugins; const AName: string = ''); reintroduce; virtual;
  end;

  TCPlugins = class(TCObjects)
  private
    function GetPlugin(Index: Integer): TCPlugin;
  protected
    function Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean; override;
    function SQLGetItems(const Name: string = ''): string; override;
  public
    property Plugin[Index: Integer]: TCPlugin read GetPlugin; default;
  end;

  TCFieldType = class
  private
    FCaption: string;
    FHighlighted: Boolean;
    FieldTypes: TCFieldTypes;
    FMySQLFieldType: TMySQLFieldType;
  public
    property Caption: string read FCaption;
    property Highlighted: Boolean read FHighlighted;
    property MySQLFieldType: TMySQLFieldType read FMySQLFieldType;
    function DBTypeStr(): string; virtual;
    constructor Create(const AFieldTypes: TCFieldTypes; const AMySQLFieldType: TMySQLFieldType; const ACaption: string; const AHighlighted: Boolean); virtual;
  end;

  TCFieldTypes = class(TCItems)
  private
    FClient: TCClient;
    procedure Add(const AMySQLFieldType: TMySQLFieldType; const ACaption: string; const AHighlighted: Boolean);
    function GetFieldType(Index: Integer): TCFieldType;
  protected
    function FieldAvailable(const Engine: TCEngine; const MySQLFieldType: TMySQLFieldType): Boolean; virtual;
  public
    property Client: TCClient read FClient;
    property FieldType[Index: Integer]: TCFieldType read GetFieldType; default;
    function ApplyMySQLFieldType(const Engine: TCEngine; const MySQLFieldType: TMySQLFieldType): TMySQLFieldType; virtual;
    constructor Create(const AClient: TCClient); reintroduce; virtual;
  end;

  TCCharset = class(TCItem)
  private
    FCharsets: TCCharsets;
    FHint: string;
    FCollation: string;
    FMaxLength: Integer;
    function GetDefaultCollation(): TCCollation;
  public
    property Charsets: TCCharsets read FCharsets;
    property Collation: string read FCollation;
    property DefaultCollation: TCCollation read GetDefaultCollation;
    property Hint: string read FHint;
    property MaxLength: Integer read FMaxLength;
    constructor Create(const ACharsets: TCCharsets; const AName: string = ''); reintroduce; virtual;
  end;

  TCCharsets = class(TCObjects)
  private
    function GetCharset(Index: Integer): TCCharset;
  protected
    function Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean; override;
    function GetActual(): Boolean; override;
    function SQLGetItems(const Name: string = ''): string; override;
  public
    property Charset[Index: Integer]: TCCharset read GetCharset; default;
  end;

  TCCollation = class(TCItem)
  private
    FCharset: TCCharset;
    FCollations: TCCollations;
    FCompiled: Boolean;
    FDefault: Boolean;
    FHint: string;
    FId: Word;
    FSortLength: Byte;
  public
    property Charset: TCCharset read FCharset;
    property Compiled: Boolean read FCompiled;
    property Default: Boolean read FDefault;
    property Hint: string read FHint;
    property Id: Word read FId;
    property SortLength: Byte read FSortLength;
    property Collations: TCCollations read FCollations;
    constructor Create(const ACollations: TCCollations; const AName: string = ''); reintroduce; virtual;
  end;

  TCCollations = class(TCObjects)
  private
    function GetCollation(Index: Integer): TCCollation;
  protected
    function Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean; override;
    function SQLGetItems(const Name: string = ''): string; override;
  public
    property Collation[Index: Integer]: TCCollation read GetCollation; default;
  end;

  TCProcess = class(TCItem)
  private
    FCommand: string;
    FDatabaseName: string;
    FHost: string;
    FUserName: string;
    FTime: TDateTime;
    FState: string;
    FSQL: string;
    function GetId(): Integer;
    procedure SetId(AId: Integer);
  public
    property Command: string read FCommand;
    property DatabaseName: string read FDatabaseName;
    property Host: string read FHost;
    property UserName: string read FUserName;
    property Time: TDateTime read FTime;
    property State: string read FState;
    property SQL: string read FSQL;
    property Id: Integer read GetId write SetId;
  end;

  TCProcesses = class(TCObjects)
  private
    function GetProcess(Index: Integer): TCProcess;
  protected
    function Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean; override;
    function GetActual(): Boolean; override;
    function SQLGetItems(const Name: string = ''): string; override;
  public
    property Process[Index: Integer]: TCProcess read GetProcess; default;
  end;

  TCUserRight = class
  private
    FRawPassword: string;
    function GetCaption(): string;
  public
    DatabaseName: string;
    FieldName: string;
    FunctionName: string;
    NewPassword: string;
    ProcedureName: string;
    TableName: string;
    RAlter, RAlterRoutine, RCreate, RCreateTempTable, RCreateRoutine: Boolean;
    RCreateUser, RCreateView, RDelete, RDrop, REvent, RExecute, RFile: Boolean;
    RGrant, RIndex, RInsert, RLockTables, RProcess, RReferences: Boolean;
    RReload, RReplClient, RReplSlave, RSelect: Boolean;
    RShowDatabases, RShowView, RShutdown, RSuper, RTrigger, RUpdate: Boolean;
    property Caption: string read GetCaption;
    property RawPassword: string read FRawPassword;
    constructor Create(); virtual;
    procedure Assign(const Source: TCUserRight);
  end;

  TCUser = class(TCObject)
  private
    FConnectionsPerHour: Integer;
    FNewPassword: string;
    FQueriesPerHour: Integer;
    FRawPassword: string;
    FRights: TList;
    FUserConnections: Integer;
    FUsers: TCUsers;
    FUpdatesPerHour: Integer;
    function GetCaption(): string;
    function GetConnectionsPerHour(): Integer;
    function GetHost(): string;
    function GetLogin(): string;
    function GetQueriesPerHour(): Integer;
    function GetRawPassword(): string;
    function GetRight(Index: Integer): TCUserRight;
    function GetRightCount(): Integer;
    function GetSlowSQLLog(): string;
    function GetSQLLog(): string;
    function GetUpdatesPerHour(): Integer;
    function GetUserConnections(): Integer;
    procedure ParseGrant(const SQL: string);
  protected
    Actual: Boolean;
    procedure SetName(const AName: string); override;
  public
    property Caption: string read GetCaption;
    property ConnectionsPerHour: Integer read GetConnectionsPerHour write FConnectionsPerHour;
    property Host: string read GetHost;
    property Login: string read GetLogin;
    property NewPassword: string read FNewPassword write FNewPassword;
    property QueriesPerHour: Integer read GetQueriesPerHour write FQueriesPerHour;
    property RawPassword: string read GetRawPassword write FRawPassword;
    property Right[Index: Integer]: TCUserRight read GetRight;
    property RightCount: Integer read GetRightCount;
    property SlowSQLLog: string read GetSlowSQLLog;
    property SQLLog: string read GetSQLLog;
    property UpdatesPerHour: Integer read GetUpdatesPerHour write FUpdatesPerHour;
    property UserConnections: Integer read GetUserConnections write FUserConnections;
    property Users: TCUsers read FUsers;
    function AddRight(const NewUserRight: TCUserRight): Boolean; virtual;
    procedure Assign(const Source: TCUser); reintroduce; virtual;
    procedure Clear(); override;
    constructor Create(const AUsers: TCUsers; const AName: string = ''); reintroduce; virtual;
    procedure DeleteRight(const UserRight: TCUserRight); virtual;
    destructor Destroy(); override;
    function IndexOf(const UserRight: TCUserRight): Integer; virtual;
    function Initialize(): Boolean; override;
    function RightByCaption(const Caption: string): TCUserRight; virtual;
    function UpdateRight(const UserRight,  NewUserRight: TCUserRight): Boolean; virtual;
  end;

  TCUsers = class(TCObjects)
  private
    function GetUser(Index: Integer): TCUser;
  protected
    function Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean; override;
    function GetActual(): Boolean; override;
    function SQLGetItems(const Name: string = ''): string; override;
  public
    property User[Index: Integer]: TCUser read GetUser; default;
  end;

  TCHostDatabase = class(TCItem)
  protected
    OriginalName: string;
  public
    RAlter, RCreate, RCreateTempTable, RCreateView, RDelete, RDrop, RGrant, RIndex, RInsert: Boolean;
    RLockTables, RReferences, RSelect, RShowView, RUpdate: Boolean;
    procedure Assign(const Source: TCHostDatabase); reintroduce; virtual;
    procedure Clear(); virtual;
  end;

  TCHostDatabases = class(TCItems)
  private
    FHost: TCHost;
    function GetDatabase(Index: Integer): TCHostDatabase;
  protected
    procedure Assign(const Source: TCHostDatabases); virtual;
  public
    property Database[Index: Integer]: TCHostDatabase read GetDatabase; default;
    property Host: TCHost read FHost;
    function AddDatabase(const NewDatabase: TCHostDatabase): Boolean; virtual;
    constructor Create(const AHost: TCHost); reintroduce; virtual;
    procedure DeleteDatabase(const Database: TCHostDatabase); virtual;
    function UpdateDatabase(const Database, NewDatabase: TCHostDatabase): Boolean; virtual;
  end;

  TCHost = class(TCObject)
  private
    FDatabases: TCHostDatabases;
    FHosts: TCHosts;
    function GetCaption(): string;
  protected
    OriginalHost: string;
    function GetSource(): string; override;
  public
    property Caption: string read GetCaption;
    property Databases: TCHostDatabases read FDatabases;
    property Hosts: TCHosts read FHosts;
    procedure Assign(const Source: TCHost); reintroduce; virtual;
    procedure Clear(); override;
    constructor Create(const AHosts: TCHosts; const AHost: string = ''); reintroduce; virtual;
    function DatabaseByName(const DatabaseName: string): TCHostDatabase; virtual;
    destructor Destroy(); override;
    function Initialize(): Boolean; override;
  end;

  TCHosts = class(TCObjects)
  private
    function GetHost(Index: Integer): TCHost;
  protected
    function Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean; override;
    function GetActual(): Boolean; override;
    function SQLGetItems(const Name: string = ''): string; override;
  public
    property Host[Index: Integer]: TCHost read GetHost; default;
  end;

  TCClient = class(TMySQLConnection)
  type
    TEventType = (ceBuild, ceUpdated, ceCreated, ceDroped, ceInitialize, ceBeforeExecuteSQL, ceBeforeCancel, ceBeforeClose, ceBeforeOpen, ceAfterOpen, ceAfterReceivingRecords, ceBeforeReceivingRecords, ceBeforeScroll, ceAfterExecuteSQL, ceAfterScroll, ceAfterCancel, ceAfterClose, ceAfterPost, ceBeforePost, ceMonitor);
    TInitialize = function (): Boolean of object;
    TEvent = record
      EventType: TEventType;
      Sender: TObject;
      CItem: TCItem;
      Database: TCDatabase;
      Initialize: TInitialize;
    end;
    TEventProc = procedure (const AEvent: TEvent) of object;
  private
    AutoCommitBeforeTransaction: Boolean;
    EventProcs: TList;
    FCharsets: TCCharsets;
    FCollations: TCCollations;
    FCurrentUser: string;
    FDatabases: TCDatabases;
    FEngines: TCEngines;
    FFieldTypes: TCFieldTypes;
    FHosts: TCHosts;
    FInformationSchema: TCDatabase;
    FPerformanceSchema: TCDatabase;
    FPlugins: TCPlugins;
    FProcesses: TCProcesses;
    FPrefetch: Integer;
    FQueryBuilderResult: TCResultSet;
    FAccount: TSAccount;
    FStati: TCStati;
    FSQLEditorResult: TCResultSet;
    FSQLMonitor: TMySQLMonitor;
    FUser: TCUser;
    FUsers: TCUsers;
    FVariables: TCVariables;
    StmtMonitor: TMySQLMonitor;
    procedure ConnectChange(Sender: TObject; Connecting: Boolean);
    procedure DoExecuteEvent(const AEvent: TEvent);
    function GetActual(): Boolean;
    function GetCaption(): string;
    function GetCollation(): string;
    function GetDefaultCharset(): string;
    function GetLogActive(): Boolean;
    function GetQueryBuilderResult(): TCResultSet;
    function GetSlowLogActive(): Boolean;
    function GetSQLEditorResult(): TCResultSet;
    function GetUseInformationSchema(): Boolean;
    function GetUserRights(): TCUserRight;
  protected
    CachedTables: array of TCTable;
    FLowerCaseTableNames: Byte;
    FMaxAllowedPacket: Integer;
    procedure DoAfterExecuteSQL(); override;
    procedure DoBeforeExecuteSQL(); override;
    procedure BuildUser(const DataSet: TMySQLQuery); virtual;
    function ClientResult(const Connection: TMySQLConnection; const Data: Boolean): Boolean; virtual;
    procedure ExecuteEvent(const EventType: TEventType); overload; virtual;
    procedure ExecuteEvent(const EventType: TEventType; const Sender: TObject; const CItem: TCItem;  const Database: TCDatabase = nil); overload; virtual;
    procedure ExecuteEvent(const Initialize: TInitialize); overload; virtual;
    function GetAutoCommit(): Boolean; override;
    function GetLoadDataFile(): Boolean; override;
    function GetLog(): string; virtual;
    function GetMaxAllowedPacket(): Integer; override;
    function GetSlowLog(): string; virtual;
    function GetSlowSQLLog(const User: TCUser = nil): string; virtual;
    function GetSQLLog(const User: TCUser = nil): string; virtual;
    procedure MonitorLog(const Sender: TObject; const Text: PChar; const Len: Integer; const ATraceType: TMySQLMonitor.TTraceType); virtual;
    procedure MonitorExecutedStmts(const Sender: TObject; const Text: PChar; const Len: Integer; const ATraceType: TMySQLMonitor.TTraceType); virtual;
    procedure SetAutoCommit(const AAutoCommit: Boolean); override;
    procedure SetCharset(const ACharset: string); override;
    property InformationSchema: TCDatabase read FInformationSchema;
    property PerformanceSchema: TCDatabase read FPerformanceSchema;
    property Prefetch: Integer read FPrefetch;
    property UseInformationSchema: Boolean read GetUseInformationSchema;
  public
    function AddDatabase(const NewDatabase: TCDatabase): Boolean; virtual;
    function AddHost(const NewHost: TCHost): Boolean; virtual;
    function AddUser(const ANewUser: TCUser): Boolean; virtual;
    procedure GridCanEditShow(Sender: TObject); virtual;
    function CharsetByName(const CharsetName: string): TCCharset; virtual;
    function CharsetByCollation(const Collation: string): TCCharset; virtual;
    procedure Clear(); virtual;
    function CloneDatabase(const SourceDatabase, TargetDatabase: TCDatabase; const Data: Boolean): Boolean; virtual;
    function CloneHost(const Host: TCHost; const NewHostHost: string): Boolean; virtual;
    function CloneUser(const User: TCUser; const NewUserName: string): Boolean; virtual;
    function CollationByName(const CollationName: string): TCCollation; virtual;
    procedure CommitTransaction(); override;
    procedure FirstConnect(); overload; virtual;
    procedure FirstConnect(const AConnectionType: Integer; const ALibraryName: string; const AHost, AUser, APassword, ADatabase: string; const APort: Integer; const ACompression, AMultiThreading: Boolean); overload; virtual;
    constructor CreateConnection(); overload; virtual;
    constructor CreateConnection(const AAccount: TSAccount); overload; virtual;
    function DatabaseByName(const DatabaseName: string): TCDatabase; virtual;
    procedure DecodeInterval(const Value: string; const IntervalType: TMySQLIntervalType; var Year, Month, Day, Quarter, Week, Hour, Minute, Second, MSec: Word); virtual;
    function DeleteDatabase(const Database: TCDatabase): Boolean; virtual;
    function DeleteDatabases(const DatabaseNames: array of string): Boolean; virtual;
    function DeleteHost(const Host: TCHost): Boolean; virtual;
    function DeleteHosts(const HostHosts: array of string): Boolean; virtual;
    function DeletePlugin(const Plugin: TCPlugin): Boolean; virtual;
    function DeleteProcess(const Process: TCProcess): Boolean; virtual;
    function DeleteProcesses(const Ids: array of string): Boolean; virtual;
    function DeleteUser(const User: TCUser): Boolean; virtual;
    function DeleteUsers(const UserNames: array of string): Boolean; virtual;
    destructor Destroy(); override;
    function EmptyDatabases(const DatabaseNames: array of string): Boolean; virtual;
    function EncodeInterval(const Year, Month, Day, Quarter, Week, Hour, Minute, Second, MSec: Word; var Value: string; var IntervalType: TMySQLIntervalType): Boolean; virtual;
    function EngineByName(const EngineName: string): TCEngine; virtual;
    function EscapeRightIdentifier(const Identifier: string; const IdentifierQuoting: Boolean = False): string; virtual;
    function EscapeUser(const User: string; const IdentifierQuoting: Boolean = False): string; virtual;
    function FieldTypeByCaption(const Caption: string): TCFieldType; virtual;
    function FieldTypeByMySQLFieldType(const MySQLFieldType: TMySQLFieldType): TCFieldType; virtual;
    function FlushHosts(): Boolean; virtual;
    procedure UpdateIndexDefs(const DataSet: TMySQLQuery; const IndexDefs: TIndexDefs); virtual;
    function HostByCaption(const Caption: string): TCHost; virtual;
    function HostByName(const HostName: string): TCHost; virtual;
    function Initialize(): Boolean; virtual;
    function PluginByName(const PluginName: string): TCPlugin; virtual;
    function ProcessById(const ProcessId: Integer): TCProcess; virtual;
    procedure Refresh(); virtual;
    procedure RegisterEventProc(const AEventProc: TEventProc); virtual;
    procedure RollbackTransaction(); override;
    procedure StartTransaction(); override;
    function StatusByName(const StatusName: string): TCStatus; virtual;
    function TableName(const Name: string): string; virtual;
    function TableNameCmp(const Name1, Name2: string): Integer; virtual;
    function UnescapeValue(const Value: string; const FieldType: TMySQLFieldType = mfVarChar): string; overload; virtual;
    function UnecapeRightIdentifier(const Identifier: string): string; virtual;
    function UpdateDatabase(const Database, NewDatabase: TCDatabase): Boolean; virtual;
    function UpdateHost(const Host, NewHost: TCHost): Boolean; virtual;
    function UpdateUser(const User, NewUser: TCUser): Boolean; virtual;
    function UpdateVariable(const Variable, NewVariable: TCVariable; const UpdateModes: TCVariable.TUpdateModes): Boolean; virtual;
    procedure UnRegisterEventProc(const AEventProc: TEventProc); virtual;
    function UserByCaption(const Caption: string): TCUser; virtual;
    function UserByName(const UserName: string): TCUser; virtual;
    function VariableByName(const VariableName: string): TCVariable; virtual;
    property Actual: Boolean read GetActual;
    property Caption: string read GetCaption;
    property Charsets: TCCharsets read FCharsets;
    property Collation: string read GetCollation;
    property Collations: TCCollations read FCollations;
    property CurrentUser: string read FCurrentUser;
    property Databases: TCDatabases read FDatabases;
    property DefaultCharset: string read GetDefaultCharset;
    property Engines: TCEngines read FEngines;
    property FieldTypes: TCFieldTypes read FFieldTypes;
    property Hosts: TCHosts read FHosts;
    property Log: string read GetLog;
    property LogActive: Boolean read GetLogActive;
    property LowerCaseTableNames: Byte read FLowerCaseTableNames;
    property Plugins: TCPlugins read FPlugins;
    property Processes: TCProcesses read FProcesses;
    property QueryBuilderResult: TCResultSet read GetQueryBuilderResult;
    property Account: TSAccount read FAccount;
    property SlowLog: string read GetSlowLog;
    property SlowLogActive: Boolean read GetSlowLogActive;
    property Stati: TCStati read FStati;
    property SQLEditorResult: TCResultSet read GetSQLEditorResult;
    property SQLMonitor: TMySQLMonitor read FSQLMonitor;
    property User: TCUser read FUser;
    property UserRights: TCUserRight read GetUserRights;
    property Users: TCUsers read FUsers;
    property Variables: TCVariables read FVariables;
  end;

  TCClients = class(TList)
  type
    TOpenConnectionEvent = procedure(const AClient: TCClient; out UserAbort: Boolean) of object;
  private
    FOnOpenConnection: TOpenConnectionEvent;
    function GetClient(Index: Integer): TCClient;
  public
    property Client[Index: Integer]: TCClient read GetClient; default;
    property OnOpenConnection: TOpenConnectionEvent read FOnOpenConnection write FOnOpenConnection;
    constructor Create(); virtual;
    function ClientByAccount(const Account: TSAccount; const DatabaseName: string): TCClient; virtual;
    function CreateClient(const AAccount: TSAccount; out UserAbort: Boolean): TCClient;
    procedure ReleaseClient(var AClient: TCClient);
  end;

const
  DefaultLimit = 100;
  PrefetchTableCount = 50;

var
  Clients: TCClients;

implementation {***************************************************************}

uses
  Variants, SysConst, WinInet, StrUtils, WinSock, DBConsts, RTLConsts, Math,
  Consts, DBCommon,
  Forms, DBGrids,
  MySQLConsts, CSVUtils, HTTPTunnel, MySQLDBGrid,
  fURI, fPreferences;

const
  information_schema = 'information_schema';
  performance_schema = 'performance_schema';
  OutParameterCaption = '<OUT>';
  InParameterCaption = '<IN>';

resourcestring
  SDesktopAlreadyRegistered = 'Desktop already registered';
  SUnknownRoutineType = 'Unknown Routine Type (%s)';
  SUnknownSQLStmt = 'Unknow SQL Statement (%s)';
  SSourceParseError = 'Source code of "%s" cannot be analyzed (%d):' + #10#10 + '%s';

type
  TMCharsetTranslation = record
    OldCharset: PChar;
    NewCharset: PChar;
    NewCollation: PChar;
  end;
const
  CharsetTranslations: array[0..29] of TMCharsetTranslation = (
    (OldCharset: 'big5';       NewCharset: 'big5';   NewCollation: 'big5_chinese_ci'),
    (OldCharset: 'czech';      NewCharset: 'latin2'; NewCollation: 'latin2_czech_ci'),
    (OldCharset: 'dec8';       NewCharset: 'dec8';   NewCollation: 'dec8_swedish_ci'),
    (OldCharset: 'dos';        NewCharset: 'cp850';  NewCollation: 'cp850_general_ci'),
    (OldCharset: 'german1';    NewCharset: 'latin1'; NewCollation: 'latin1_german1_ci'),
    (OldCharset: 'hp8';        NewCharset: 'hp8';    NewCollation: 'hp8_english_ci'),
    (OldCharset: 'koi8_ru';    NewCharset: 'koi8r';  NewCollation: 'koi8r_general_ci'),
    (OldCharset: 'latin1';     NewCharset: 'latin1'; NewCollation: 'latin1_swedish_ci'),
    (OldCharset: 'latin2';     NewCharset: 'latin2'; NewCollation: 'latin2_general_ci'),
    (OldCharset: 'swe7';       NewCharset: 'swe7';   NewCollation: 'swe7_swedish_ci'),
    (OldCharset: 'usa7';       NewCharset: 'ascii';  NewCollation: 'ascii_general_ci'),
    (OldCharset: 'ujis';       NewCharset: 'ujis';   NewCollation: 'ujis_japanese_ci'),
    (OldCharset: 'sjis';       NewCharset: 'sjis';   NewCollation: 'sjis_japanese_ci'),
    (OldCharset: 'cp1251';     NewCharset: 'cp1251'; NewCollation: 'cp1251_bulgarian_ci'),
    (OldCharset: 'danish';     NewCharset: 'latin1'; NewCollation: 'latin1_danish_ci'),
    (OldCharset: 'hebrew';     NewCharset: 'hebrew'; NewCollation: 'hebrew_general_ci'),
    (OldCharset: 'cp1251';     NewCharset: 'cp1251'; NewCollation: 'cp1251_bulgarian_ci'),
    (OldCharset: 'euc_kr';     NewCharset: 'euckr';  NewCollation: 'euckr_korean_ci'),
    (OldCharset: 'estonia';    NewCharset: 'latin7'; NewCollation: 'latin7_estonian_ci'),
    (OldCharset: 'hungarian';  NewCharset: 'latin2'; NewCollation: 'latin2_hungarian_ci'),
    (OldCharset: 'koi8_ukr';   NewCharset: 'koi8u';  NewCollation: 'koi8u_ukrainian_ci'),
    (OldCharset: 'win1251ukr'; NewCharset: 'cp1251'; NewCollation: 'cp1251_ukrainian_ci'),
    (OldCharset: 'gb2312';     NewCharset: 'gb2312'; NewCollation: 'gb2312_chinese_ci'),
    (OldCharset: 'greek';      NewCharset: 'greek';  NewCollation: 'greek_general_ci'),
    (OldCharset: 'win1250';    NewCharset: 'cp1250'; NewCollation: 'cp1250_general_ci'),
    (OldCharset: 'croat';      NewCharset: 'latin2'; NewCollation: 'latin2_croatian_ci'),
    (OldCharset: 'gbk';        NewCharset: 'gbk';    NewCollation: 'gbk_chinese_ci'),
    (OldCharset: 'cp1257';     NewCharset: 'cp1257'; NewCollation: 'cp1257_lithuanian_ci'),
    (OldCharset: 'latin5';     NewCharset: 'latin5'; NewCollation: 'latin5_turkish_ci'),
    (OldCharset: 'latin1_de';  NewCharset: 'latin1'; NewCollation: 'latin1_german2_ci')
  );

function StrToMySQLRowType(const Str: string): TMySQLRowType;
begin
  if (UpperCase(Str) = 'FIXED') then Result := mrFixed
  else if (UpperCase(Str) = 'DYNAMIC') then Result := mrDynamic
  else if (UpperCase(Str) = 'COMPRESSED') then Result := mrCompressed
  else if (UpperCase(Str) = 'REDUNDANT') then Result := mrRedundant
  else if (UpperCase(Str) = 'COMPACT') then Result := mrCompact
  else Result := mrUnknown;
end;

function StrToPartitionType(const Str: string): TMySQLPartitionType;
begin
  if (UpperCase(Str) = 'HASH') then Result := ptHash
  else if (UpperCase(Str) = 'KEY') then Result := ptKey
  else if (UpperCase(Str) = 'RANGE') then Result := ptRange
  else if (UpperCase(Str) = 'LIST') then Result := ptList
  else Result := ptUnknown;
end;

function StrToEventType(const Str: string): TMySQLEventType;
begin
  if (UpperCase(Str) = 'ONE TIME') then Result := etSingle
  else if (UpperCase(Str) = 'RECURRING') then Result := etMultiple
  else Result := etUnknown;
end;

function StrToIntervalType(const Str: string): TMySQLIntervalType;
begin
  if (UpperCase(Str) = 'YEAR') then Result := itYear
  else if (UpperCase(Str) = 'QUARTER') then Result := itQuarter
  else if (UpperCase(Str) = 'MONTH') then Result := itMonth
  else if (UpperCase(Str) = 'DAY') then Result := itDay
  else if (UpperCase(Str) = 'HOUR') then Result := itHour
  else if (UpperCase(Str) = 'MINUTE') then Result := itMinute
  else if (UpperCase(Str) = 'WEEK') then Result := itWeek
  else if (UpperCase(Str) = 'SECOND') then Result := itSecond
  else if (UpperCase(Str) = 'MICROSECOND') then Result := itMicrosecond
  else if (UpperCase(Str) = 'YEAR_MONTH') then Result := itYearMonth
  else if (UpperCase(Str) = 'DAY_HOUR') then Result := itDayMinute
  else if (UpperCase(Str) = 'DAY_MINUTE') then Result := itDayMinute
  else if (UpperCase(Str) = 'DAY_SECOND') then Result := itDaySecond
  else if (UpperCase(Str) = 'HOUR_MINUTE') then Result := itHourMinute
  else if (UpperCase(Str) = 'HOUR_SECOND') then Result := itHourSecond
  else if (UpperCase(Str) = 'MINUTE_SECOND') then Result := itMinuteSecond
  else if (UpperCase(Str) = 'DAY_MICROSECOND') then Result := itDayMicrosecond
  else if (UpperCase(Str) = 'HOUR_MICROSECOND') then Result := itHourMicrosecond
  else if (UpperCase(Str) = 'MINUTE_MICROSECOND') then Result := itMinuteMicrosecond
  else if (UpperCase(Str) = 'SECOND_MICROSECOND') then Result := itSecondMicrosecond
  else Result := itUnknown;
end;

function IntervalToStr(const IntervalValue: string; const IntervalType: TMySQLIntervalType): string;
begin
  case (IntervalType) of
    itYear: Result := 'YEAR';
    itQuarter: Result := 'QUARTER';
    itMonth: Result := 'MONTH';
    itDay: Result := 'DAY';
    itHour: Result := 'HOUR';
    itMinute: Result := 'MINUTE';
    itWeek: Result := 'WEEK';
    itSecond: Result := 'SECOND';
    itMicrosecond: Result := 'MICROSECOND';
    itYearMonth: Result := 'YEAR_MONTH';
    itDayHour: Result := 'DAY_HOUR';
    itDayMinute: Result := 'DAY_MINUTE';
    itDaySecond: Result := 'DAY_SECOND';
    itHourMinute: Result := 'HOUR_MINUTE';
    itHourSecond: Result := 'HOUR_SECOND';
    itMinuteSecond: Result := 'MINUTE_SECOND';
    itDayMicrosecond: Result := 'DAY_MICROSECOND';
    itHourMicrosecond: Result := 'HOUR_MICROSECOND';
    itMinuteMicrosecond: Result := 'MINUTE_MICROSECOND';
    itSecondMicrosecond: Result := 'SECOND_MICROSECOND';
    else Result := '';
  end;
  if (Result <> '') then
    Result := '''' + IntervalValue + ''' ' + Result;
end;

{ TCResultSet *****************************************************************}

procedure TCResultSet.Cleanup();
var
  I: Integer;
  J: Integer;
begin
  for I := Length(FDataSets) - 1 downto 0 do
    if (FDataSets[I].FieldCount = 0) then
    begin
      if (FSelected = FDataSets[I]) then
        FSelected := nil;
      FDataSets[I].Free();
      for J := I to Length(FDataSets) - 2 do
        FDataSets[J] := FDataSets[J + 1];
      SetLength(FDataSets, Length(FDataSets) - 1);
    end;
end;

procedure TCResultSet.Clear();
var
  I: Integer;
begin
  for I := 0 to Length(FDataSets) - 1 do
    FDataSets[I].Free();
  SetLength(FDataSets, 0);

  SetLength(Columns, 0);
end;

constructor TCResultSet.Create(const AClient: TCClient);
begin
  FClient := AClient;

  FBeforeOpen := nil;
  FAfterOpen := nil;
  FBeforeClose := nil;
  FAfterClose := nil;
  FBeforePost := nil;
  FAfterPost := nil;
  FBeforeCancel := nil;
  FAfterCancel := nil;
  FBeforeScroll := nil;
  FAfterScroll := nil;

  Clear();
end;

destructor TCResultSet.Destroy();
begin
  Clear();

  inherited;
end;

function TCResultSet.GetActive(): Boolean;
begin
  Result := (Count > 0);
end;

function TCResultSet.GetCount(): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Length(FDataSets) - 1 do
    if (FDataSets[I].FieldCount > 0) then
      Inc(Result);
end;

function TCResultSet.GetDataSet(AIndex: Integer): TMySQLDataSet;
var
  I: Integer;
  Index: Integer;
begin
  Result := nil;

  Index := 0;
  for I := 0 to Length(FDataSets) - 1 do
    if (FDataSets[I].FieldCount > 0) then
    begin
      if (Index = AIndex) then
        Result := FDataSets[I];
      Inc(Index);
    end;
end;

function TCResultSet.IndexOf(const DataSet: TDataSet): Integer;
var
  I: Integer;
  Index: Integer;
begin
  Result := -1;

  Index := 0;
  for I := 0 to Length(FDataSets) - 1 do
    if (FDataSets[I].FieldCount > 0) then
    begin
      if (FDataSets[I] = DataSet) then
        Result := Index;
      Inc(Index);
    end;
end;

function TCResultSet.ResultAvailable(const Connection: TMySQLConnection; const Data: Boolean): Boolean;
var
  Index: Integer;
begin
  if (Assigned(FOnResult)) then
    Result := FOnResult(Connection, Data)
  else
    Result := False;

  if (Data) then
  begin
    Index := Length(FDataSets);
    SetLength(FDataSets, Index + 1);
    FDataSets[Index] := TMySQLDataSet.Create(nil);
    FDataSets[Index].Connection := Client;
    FDataSets[Index].BeforeOpen := BeforeOpen;
    FDataSets[Index].AfterOpen := AfterOpen;
    FDataSets[Index].BeforeClose := BeforeClose;
    FDataSets[Index].AfterClose := AfterClose;
    FDataSets[Index].AfterScroll := AfterScroll;
    FDataSets[Index].BeforePost := BeforePost;
    FDataSets[Index].AfterPost := AfterPost;
    FDataSets[Index].BeforeCancel := BeforeCancel;
    FDataSets[Index].AfterCancel := AfterCancel;
    FDataSets[Index].BeforeReceivingRecords := BeforeReceivingRecords;
    FDataSets[Index].AfterReceivingRecords := AfterReceivingRecords;
    FDataSets[Index].Tag := Integer(Self);

    FDataSets[Index].Open();
  end;
end;

procedure TCResultSet.SendSQL(const SQL: string; const OnResult: TMySQLConnection.TResultEvent = nil);
begin
  Clear();

  FOnResult := OnResult;
  Client.SendSQL(SQL, ResultAvailable);
end;

{ TCItem **********************************************************************}

procedure TCItem.Assign(const Source: TCItem);
begin
  Assert(Assigned(Source) and (Source.ClassType = ClassType));

  
  FName := Source.Name;
end;

constructor TCItem.Create(const AName: string = '');
begin
  inherited Create();

  FName := AName;
end;

function TCItem.Equal(const Second: TCItem): Boolean;
begin
  Result := Assigned(Second) and (Second.ClassType = ClassType);
end;

procedure TCItem.SetName(const AName: string);
begin
  FName := AName;
end;

{ TCDBItems *******************************************************************}

procedure TCItems.Clear();
var
  I: Integer;
begin
  for I := 0 to TList(Self).Count - 1 do
    TCItem(Items[I]).Free();

  inherited;
end;

function TCItems.GetItem(Index: Integer): TCItem;
begin
  Result := TCItem(Items[Index]);
end;

function TCItems.GetCount(): Integer;
begin
  Result := TList(Self).Count;
end;

destructor TCItems.Destroy();
begin
  Clear();

  inherited;
end;

function TCItems.IndexByName(const Name: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
    if (lstrcmpi(PChar(Name), PChar(TCItem(Items[I]).Name)) = 0) then
      Result := I;
end;

function TCItems.NameCmp(const Name1, Name2: string): Integer;
begin
  Result := lstrcmpi(PChar(Name1), PChar(Name2));
end;

{ TCObject ********************************************************************}

procedure TCObject.Assign(const Source: TCObject);
begin
  inherited Assign(Source);

  FActualSource := Source.ActualSource;
  FSource := Source.FSource;
end;

procedure TCObject.Clear();
begin
  FActualSource := False;
  FSource := '';
end;

constructor TCObject.Create(const AClient: TCClient; const AName: string = '');
begin
  inherited Create(AName);

  Clear();

  FClient := AClient;
end;

function TCObject.GetActualSource(): Boolean;
begin
  Result := FActualSource;
end;

function TCObject.GetSource(): string;
begin
  Result := FSource;
end;

procedure TCObject.SetName(const AName: string);
begin
  inherited;

  FActualSource := False;
  FSource := '';
end;

procedure TCObject.SetSource(const AField: TField);
var
  S: string;
begin
  if (AField.DataType <> ftBlob) then
    S := AField.AsString
  else if (Length(AField.AsBytes) = 0) then
    S := ''
  else
    S := Client.LibDecode(my_char(@AField.AsBytes[0]));
  if (S <> '') then
    S := S + ';';
  SetSource(S);
end;

procedure TCObject.SetSource(const ASource: string);
begin
  FActualSource := True;
  FSource := ASource;
end;

{ TCObjects *******************************************************************}

function TCObjects.Add(const AObject: TCObject; const ExecuteEvent: Boolean = False): Integer;
begin
  Result := 0;
  while ((Result < TList(Self).Count) and (lstrcmpi(PChar(Item[Result].Name), PChar(AObject.Name)) < 0)) do
    Inc(Result);

  if (Result < TList(Self).Count) then
    TList(Self).Insert(Result, AObject)
  else
    TList(Self).Add(AObject);

  if (ExecuteEvent) then
    Client.ExecuteEvent(ceCreated, Self, AObject);
end;

function TCObjects.Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean;
begin
  FActual := True;

  Result := False;
end;

procedure TCObjects.Clear();
begin
  inherited;

  FActual := False;
end;

constructor TCObjects.Create(const AClient: TCClient);
begin
  inherited Create();

  FClient := AClient;

  Clear();
end;

procedure TCObjects.Delete(const AObject: TCObject);
begin
  Client.ExecuteEvent(ceDroped, Self, AObject);

  inherited Delete(IndexOf(AObject));

  AObject.Free();
end;

destructor TCObjects.Destroy();
begin
  Clear();

  inherited;
end;

function TCObjects.GetActual(): Boolean;
begin
  Result := FActual;
end;

procedure TCObjects.Refresh();
begin
  Clear();

  Client.ExecuteEvent(Client.Initialize);
end;

{ TCDBObject ******************************************************************}

constructor TCDBObject.Create(const ADatabase: TCDatabase; const AName: string = '');
begin
  inherited Create(ADatabase.Client, AName);

  FDatabase := ADatabase;
end;

function TCDBObject.InitializeSource(): Boolean;
begin
  Result := Database.InitializeSources(Self);
end;

procedure TCDBObject.SetSource(const ASource: string);
begin
  FActualSource := True;
  FSource := ASource;
end;

{ TCDBObjects *****************************************************************}

function TCDBObjects.Add(const AObject: TCObject; const Event: Boolean = False): Integer;
begin
  Result := 0;
  while ((Result < TList(Self).Count) and (lstrcmpi(PChar(Item[Result].Name), PChar(AObject.Name)) < 0)) do
    Inc(Result);

  if (Result < TList(Self).Count) then
    TList(Self).Insert(Result, AObject)
  else
    TList(Self).Add(AObject);

  if (Event) then
    Client.ExecuteEvent(ceCreated, Self, AObject, Database);
end;

constructor TCDBObjects.Create(const ADatabase: TCDatabase);
begin
  inherited Create(ADatabase.Client);

  FActual := False;
  FDatabase := ADatabase;
end;

procedure TCDBObjects.Delete(const AObject: TCObject);
var
  Index: Integer;
begin
  Index := IndexOf(AObject);

  if (Index >= 0) then
  begin
    inherited Delete(Index);

    Client.ExecuteEvent(ceDroped, Self, AObject, Database);

    AObject.Free();
  end;
end;

function TCDBObjects.GetCount(): Integer;
begin
  if (not Actual) then
    Result := -1
  else
    Result := TList(Self).Count;
end;

procedure TCDBObjects.Refresh();
begin
  Clear();

  Client.ExecuteEvent(Database.Initialize);
end;

{ TCIndexColumn ***************************************************************}

procedure TCIndexColumn.Assign(const Source: TCIndexColumn);
begin
  Field := IndexColumns.Index.Table.FieldByName(Source.Field.Name);
  Length := Source.Length;
end;

procedure TCIndexColumn.Clear();
begin
  Ascending := True;
  Field := nil;
  Length := 0;
end;

constructor TCIndexColumn.Create(const AIndexColumns: TCIndexColumns);
begin
  FIndexColumns := AIndexColumns;

  Clear();
end;

function TCIndexColumn.Equal(const Second: TCIndexColumn): Boolean;
begin
  Result := Assigned(Second) and (ClassType = Second.ClassType);

  Result := Result and (lstrcmpi(PChar(Field.Name), PChar(Second.Field.Name)) = 0);
  Result := Result and (Length = Second.Length);
end;

{ TCIndexColumns **************************************************************}

procedure TCIndexColumns.AddColumn(const NewColumn: TCIndexColumn);
begin
  Add(TCIndexColumn.Create(Self));
  Column[TList(Self).Count - 1].Assign(NewColumn);
end;

constructor TCIndexColumns.Create(const AIndex: TCIndex);
begin
  FIndex := AIndex;
end;

procedure TCIndexColumns.DeleteColumn(const AColumn: TCIndexColumn);
begin
  Delete(IndexOf(AColumn));
end;

function TCIndexColumns.IndexByField(const AField: TCTableField): Integer;
var
  I: Integer;
begin
  Result := -1;

  for I := 0 to Count - 1 do
    if (AField = Column[I].Field) then
      Result := I;
end;

function TCIndexColumns.GetColumn(Index: Integer): TCIndexColumn;
begin
  Result := TCIndexColumn(Items[Index]);
end;

{ TCIndex *********************************************************************}

procedure TCIndex.Assign(const Source: TCIndex);
var
  I: Integer;
begin
  inherited Assign(Source);

  if (not Assigned(Indices) and Assigned(Source.Indices)) then FIndices := Source.Indices;

  OriginalName := Source.OriginalName;
  Created := Source.Created;
  if (Assigned(FColumns)) then
    FColumns.Clear();
  for I := 0 to Source.Columns.Count - 1 do
    Columns.AddColumn(Source.Columns[I]);
  Primary := Source.Primary;
  Unique := Source.Unique;
  Fulltext := Source.Fulltext;
end;

function TCIndex.ColumnByField(const AField: TCBaseTableField): TCIndexColumn;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Columns.Count - 1 do
    if (Columns.Column[I].Field = AField) then
      Result := Columns.Column[I];
end;

function TCIndex.ColumnByFieldName(const AFieldName: string): TCIndexColumn;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Columns.Count - 1 do
    if (lstrcmpi(PChar(Columns[I].Field.Name), PChar(AFieldName)) = 0) then
      Result := Columns.Column[I];
end;

constructor TCIndex.Create(const AIndices: TCIndices);
begin
  inherited Create();

  FColumns := TCIndexColumns.Create(Self);
  Clear();

  FIndices := AIndices;
end;

procedure TCIndex.Clear();
begin
  Created := False;

  OriginalName := '';
  if (Assigned(FColumns)) then
    FColumns.Clear();
  Primary := False;
  Unique := False;
  Fulltext := False;
end;

function TCIndex.GetCaption(): string;
begin
  if (Primary) then
    Result := ReplaceStr(Preferences.LoadStr(154), '&', '')
  else
    Result := Name;
end;

function TCIndex.GetIndex(): Integer;
begin
  Result := Indices.IndexOf(Self);
end;

function TCIndex.GetKey(): Integer;
begin
  Result := Index + 1;
end;

procedure TCIndex.GetSortDef(var SortDef: TIndexDef);
var
  I: Integer;
begin
  SortDef.Name := Name;
  SortDef.Fields := '';
  SortDef.DescFields := '';
  SortDef.Options := [];

  for I := 0 to Columns.Count - 1 do
  begin
    if (SortDef.Fields <> '') then SortDef.Fields := SortDef.Fields + ';';
    SortDef.Fields := SortDef.Fields + Columns[I].Field.Name;
    if (not Columns[I].Ascending) then
    begin
      if (SortDef.Fields <> '') then SortDef.DescFields := SortDef.DescFields + ';';
      SortDef.DescFields := SortDef.DescFields + Columns[I].Field.Name;
    end;
  end;
end;

function TCIndex.GetTable(): TCBaseTable;
begin
  Result := Indices.Table;
end;

function TCIndex.Equal(const Second: TCIndex): Boolean;
var
  I: Integer;
begin
  Result := inherited Equal(Second);

  Result := Result and (lstrcmpi(PChar(Name), PChar(Second.Name)) = 0);
  Result := Result and (Columns.Count = Second.Columns.Count);
  for I := 0 to Columns.Count - 1 do
  begin
    Result := Result and (lstrcmpi(PChar(Columns[I].Field.OriginalName), PChar(Second.Columns[I].Field.OriginalName)) = 0);
    Result := Result and (Columns[I].Length = Second.Columns[I].Length);
  end;

  Result := Result and (Primary = Second.Primary);
  Result := Result and (Unique = Second.Unique);
  Result := Result and (Fulltext = Second.Fulltext);
end;

destructor TCIndex.Destroy();
begin
  Clear();

  FColumns.Free();

  inherited;
end;

{ TIndices ********************************************************************}

procedure TCIndices.Assign(const Source: TCIndices);
var
  I: Integer;
begin
  Clear();

  for I := 0 to Source.Count - 1 do
  begin
    AddIndex(Source.Index[I]);
    Index[I].Created := False;
  end;
end;

procedure TCIndices.AddIndex(const NewIndex: TCIndex);
var
  Index: Integer;
begin
  if (NewIndex.Primary) then
    Index := 0
  else
    Index := Count;

  Insert(Index, TCIndex.Create(Self));
  Self.Index[Index].Assign(NewIndex);
  Self.Index[Index].Created := True;
end;

constructor TCIndices.Create(const ATable: TCBaseTable);
begin
  inherited Create();

  FTable := ATable;
end;

procedure TCIndices.DeleteIndex(const AIndex: TCIndex);
var
  I: Integer;
begin
  if (AIndex.Primary) then
    for I := 0 to Table.Fields.Count - 1 do
      if (Table.Fields[I] is TCBaseTableField) then
        TCBaseTableField(Table.Fields[I]).AutoIncrement := False;

  Index[IndexOf(AIndex)].Free();

  Delete(IndexOf(AIndex));
end;

function TCIndices.GetIndex(Index: Integer): TCIndex;
begin
  Result := TCIndex(Items[Index]);
end;

function TCIndices.GetPrimary(): TCIndex;
begin
  if ((Count >= 1) and (Index[0].Name = '')) then
    Result := Index[0]
  else
    Result := nil;
end;

{ TCField *********************************************************************}

procedure TCField.Assign(const Source: TCField);
begin
  inherited Assign(Source);

  FCharset := Source.FCharset;
  Decimals := Source.Decimals;
  FieldType := Source.FieldType;
  Items := TCTableField(Source).Items;
  National := TCTableField(Source).National;
  Size := Source.Size;
  Unsigned := TCTableField(Source).Unsigned;
end;

procedure TCField.Clear();
begin
  FCharset := '';
  Decimals := 0;
  FieldType := mfUnknown;
  SetLength(Items, 0);
  Name := '';
  National := False;
  Size := 0;
  Unsigned := False;
end;

constructor TCField.Create(const AFieldTypes: TCFieldTypes);
begin
  inherited Create();

  FFieldTypes := AFieldTypes;
end;

function TCField.DBTypeStr(): string;
var
  I: Integer;
  S: string;
begin
  Result := '';

  if (National and (FieldTypes.Client.ServerVersion < 40101)) then
    Result := Result + 'national ';

  Result := Result + FFieldTypes.Client.FieldTypeByMySQLFieldType(FieldType).DBTypeStr();

  if (FieldType in [mfEnum, mfSet]) then
  begin
    S := '';
    for I := 0 to Length(Items) - 1 do
    begin
      if (S <> '') then S := S + ',';
      S := S + EscapeValue(Items[I]);
    end;
    Result := Result + '(' + S + ')';
  end
  else if ((FieldType in [mfFloat, mfDouble, mfDecimal]) and ((Size <> 0) or (Decimals <> 0))) then
  begin
    S := '';
    if (Size >= 0) then S := S + IntToStr(Size);
    if (Decimals >= 0) then S := S + ',' + IntToStr(Decimals);
    if (S <> '') then Result := Result + '(' + S + ')';
  end
  else if (FieldType in [mfChar, mfVarChar, mfBinary, mfVarBinary]) then
    Result := Result + '(' + IntToStr(Size) + ')'
  else if (FieldType in [mfTinyText, mfText, mfMediumText, mfLongText, mfTinyBlob, mfBlob, mfMediumBlob, mfLongBlob]) then
  else if (FieldType in [mfGeometry, mfPoint, mfLineString, mfPolygon, mfMultiPoint,  mfMultiLineString, mfMultiPolygon, mfGeometryCollection]) then
  else if (FieldType in [mfDate, mfDateTime, mfTime]) then
  else
    if (Size > 0)then Result := Result + '(' + IntToStr(Size) + ')';

  if (FieldType in [mfTinyInt, mfSmallInt, mfMediumInt, mfInt, mfBigInt, mfFloat, mfDouble, mfDecimal]) then
    if (Unsigned) then Result := Result + ' unsigned';
end;

function TCField.Equal(const Second: TCField): Boolean;
begin
  Result := inherited Equal(Second);

  Result := Result and (National = Second.National);
end;

function TCField.EscapeValue(const Value: string): string;
begin
  if (FieldType = mfBit) then
    if (Value = '') then Result := 'NULL' else Result := 'b''' + Value + ''''
  else if (FieldType in NotQuotedFieldTypes) then
    if (Value = '') then Result := 'NULL' else Result := Value
  else if (FieldType in BinaryFieldTypes) then
    Result := SQLEscape(Value, FieldTypes.Client.ServerVersion <= 40000)
  else
    Result := SQLEscape(Value);
end;

procedure TCField.ParseFieldType(var Parse: TSQLParse);
var
  Identifier: string;
  S: string;
begin
  National := SQLParseKeyword(Parse, 'NATIONAL');

  Identifier := SQLParseValue(Parse);
  FieldType := FFieldTypes.Client.FieldTypeByCaption(Identifier).MySQLFieldType;

  Size := -1;
  Decimals := -1;
  if (SQLParseChar(Parse, '(')) then
  begin
    if (FieldType in [mfEnum, mfSet]) then
    begin
      SetLength(Items, 0);
      repeat
        SetLength(Items, Length(Items) + 1);
        Items[Length(Items) - 1] := SQLParseValue(Parse);

        SQLParseChar(Parse, ',');
      until (SQLParseChar(Parse, ')', False));
    end
    else if (FieldType in [mfFloat, mfDouble, mfDecimal]) then
    begin
      Size := StrToInt(SQLParseValue(Parse));

      if (not SQLParseChar(Parse, ',') and not SQLParseChar(Parse, '.')) then
        Decimals := 0
      else
        Decimals := StrToInt(SQLParseValue(Parse));
    end
    else if (FieldType in [mfTinyText, mfText, mfMediumText, mfLongText]) then
    begin
      S := SQLParseValue(Parse);
      if (not TryStrToInt(S, Size)) then
        Size := -1;
    end
    else if (FieldType in [mfDateTime]) then
      Size := -1
    else if (FieldType in [mfGeometry, mfPoint, mfLineString, mfPolygon, mfMultiPoint, mfMultiLineString, mfMultiPolygon, mfGeometryCollection]) then
      Size := -1
    else
      Size := StrToInt(SQLParseValue(Parse));

    if (not SQLParseChar(Parse, ')')) then
      raise EConvertError.CreateFmt(SSourceParseError, [Name, 1, string(Parse.Start)]);
  end
  else if ((FieldType = mfTinyInt) and ((UpperCase(Identifier) = 'BOOL') or (UpperCase(Identifier) = 'BOOLEAN'))) then
    Size := 1
  else if (FieldType in [mfTinyText, mfTinyBlob]) then
    Size := (1 shl 8) - 1
  else if (FieldType in [mfText, mfBlob]) then
    Size := (1 shl 16) - 1
  else if (FieldType in [mfMediumText, mfMediumBlob]) then
    Size := (1 shl 24) - 1
  else if (FieldType in [mfLongText, mfLongBlob]) then
    Size := (1 shl 32) - 1;

  if (SQLParseKeyword(Parse, 'CHARACTER')) then
  begin
    SQLParseKeyword(Parse, 'SET');
    Charset := SQLParseValue(Parse);
  end;

  Unsigned := SQLParseKeyword(Parse, 'UNSIGNED');
end;

{ TCTableField ****************************************************************}

procedure TCTableField.Assign(const Source: TCField);
begin
  inherited Assign(Source);

  if (not Assigned(Fields)) then FFields := TCTableField(Source).Fields;

  Ascii := TCTableField(Source).Ascii;
  AutoIncrement := TCTableField(Source).AutoIncrement;
  Binary := TCTableField(Source).Binary;
  Comment := TCTableField(Source).Comment;
  FCollation := TCTableField(Source).FCollation;
  Default := TCTableField(Source).Default;
  FieldBefore := nil;
  if (Assigned(Fields) and Assigned(TCTableField(Source).Fields) and Assigned(TCTableField(Source).FieldBefore)) then
    FieldBefore := Fields.FieldByName(TCTableField(Source).FieldBefore.Name);
  NullAllowed := TCTableField(Source).NullAllowed or ((Default = 'NULL') and not TCTableField(Source).AutoIncrement and not (FieldType in [mfTinyText, mfText, mfMediumText, mfLongText, mfTinyBlob, mfBlob, mfMediumBlob, mfLongBlob]));
  Unicode := TCTableField(Source).Unicode;
  Zerofill := TCTableField(Source).Zerofill;
end;

procedure TCTableField.Clear();
begin
  inherited;

  Ascii := False;
  AutoIncrement := False;
  Binary := False;
  if (Table is TCBaseTable) then
    Collation := TCBaseTable(Table).FCollation;
  Comment := '';
  Default := '';
  FieldBefore := nil;
  NullAllowed := True;
  Unicode := False;
  Zerofill := False;
end;

constructor TCTableField.Create(const AFields: TCTableFields);
begin
  inherited Create(AFields.Table.Database.Client.FieldTypes);

  FDesktopXML := nil;

  FFields := AFields;

  Clear();
end;

function TCTableField.DBTypeStr(): string;
begin
  Result := '';

  Result := Result + inherited DBTypeStr();

  if ((FieldType in [mfTinyInt, mfSmallInt, mfMediumInt, mfInt, mfBigInt, mfFloat, mfDouble, mfDecimal]) and Zerofill) then
    Result := Result + ' zerofill';
  if (Binary and (Fields.Table.Database.Client.ServerVersion < 40101)) then
    Result := Result + ' binary';
end;

destructor TCTableField.Destroy();
begin
  Clear();

  inherited;
end;

function TCTableField.Equal(const Second: TCTableField): Boolean;
var
  I: Integer;
begin
  Result := inherited Equal(Second);

  Result := Result and (Ascii = Second.Ascii);
  Result := Result and (AutoIncrement = Second.AutoIncrement);
  Result := Result and (Binary = Second.Binary);
  Result := Result and (Collation = Second.Collation);
  Result := Result and (Comment = Second.Comment);
  Result := Result and (Decimals = Second.Decimals);
  Result := Result and (Default = Second.Default);
  Result := Result and (Charset = Second.Charset);
  Result := Result and (FieldType = Second.FieldType);
  Result := Result and (Name = Second.Name);
  Result := Result and (NullAllowed = Second.NullAllowed);
  Result := Result and (Length(Items) = Length(Second.Items));
  if (Result) then
    for I := 0 to Length(Items) - 1 do
      Result := Result and (Items[I] = Second.Items[I]);
  Result := Result and (Size = Second.Size);
  Result := Result and (Unicode = Second.Unicode);
  Result := Result and (Unsigned = Second.Unsigned);
  Result := Result and (Zerofill = Second.Zerofill);
end;

function TCTableField.GetDesktopXML(): IXMLNode;
var
  I: Integer;
begin
  if (not Assigned(FDesktopXML) and Assigned(Fields.DesktopXML)) then
  begin
    for I := 0 to Fields.DesktopXML.ChildNodes.Count - 1 do
      if (lstrcmpi(PChar(string(Fields.DesktopXML.ChildNodes[I].Attributes['name'])), PChar(Name)) = 0) then
        FDesktopXML := Fields.DesktopXML.ChildNodes[I];

    if (not Assigned(FDesktopXML)) then
    begin
      FDesktopXML := Fields.DesktopXML.AddChild('field');
      try
        FDesktopXML.Attributes['name'] := Name;
      except
        Fields.DesktopXML.ChildNodes.Delete(Fields.DesktopXML.ChildNodes.IndexOf(FDesktopXML));
        FDesktopXML := nil;
      end;
    end;
  end;

  Result := FDesktopXML;
end;

function TCTableField.GetTable(): TCTable;
begin
  Result := Fields.Table;
end;

function TCTableField.GetIndex(): Integer;
begin
  Result := Fields.IndexOf(Self);
end;

procedure TCTableField.ParseFieldType(var Parse: TSQLParse);
begin
  inherited ParseFieldType(Parse);

  Zerofill := SQLParseKeyword(Parse, 'ZEROFILL');

  Binary := SQLParseKeyword(Parse, 'BINARY');

  Ascii := SQLParseKeyword(Parse, 'ASCII');

  Unicode := SQLParseKeyword(Parse, 'UNICODE');
end;

function TCTableField.UnescapeValue(const Value: string): string;
begin
  Result := SQLUnescape(Value);

  case (FieldType) of
    mfBit:
      if (Value = 'NULL') then
        Result := ''
      else if (Pos('b', Value) = 1) then
        Result := Fields.Table.Database.Client.UnescapeValue(Copy(Value, 2, Length(Value) - 1), FieldType)
      else
        Result := Fields.Table.Database.Client.UnescapeValue(Value, FieldType);
    mfTinyInt, mfSmallInt, mfMediumInt, mfInt, mfBigInt:
      if (Value = 'NULL') then
        Result := ''
      else
        Result := Fields.Table.Database.Client.UnescapeValue(Value, FieldType);
    mfFloat, mfDouble, mfDecimal:
      begin
        Result := ReplaceStr(Fields.Table.Database.Client.UnescapeValue(Value, FieldType), '.', DecimalSeparator);
        if (Result = '') then Result := 'NULL';
      end;
    mfEnum, mfSet:
      Result := ReplaceStr(Fields.Table.Database.Client.UnescapeValue(Value, FieldType), '''''', '''');
    else
      try
        Result := Fields.Table.Database.Client.UnescapeValue(Value, FieldType);
      except
        on E: EConvertError do
          Fields.Table.Database.Client.DoConvertError(Self, Value, E);
      end;
  end;
end;

{ TCBaseTableField ************************************************************}

procedure TCBaseTableField.Assign(const Source: TCField);
begin
  inherited Assign(Source);

  if (Assigned(TCBaseTable(TCTableField(Source).Fields.Table).FEngine)) then
    FieldType := TCBaseTable(TCTableField(Source).Fields.Table).Engine.ApplyMySQLFieldType(TCTableField(Source).FieldType, TCTableField(Source).Size);
  if (Fields.Table.Database.Client.ServerVersion < 40102) then
    OnUpdate := ''
  else
    OnUpdate := TCBaseTableField(TCTableField(Source)).OnUpdate;

  OriginalName := TCBaseTableField(TCTableField(Source)).OriginalName;
  Moved := TCBaseTableField(TCTableField(Source)).Moved;
end;

procedure TCBaseTableField.Clear();
begin
  inherited;

  FCharset := '';
  FCollation := '';

  OnUpdate := '';
  OriginalName := '';
  Moved := False;
end;

function TCBaseTableField.GetTable(): TCBaseTable;
begin
  if (not Assigned(Fields) or not (Fields.Table is TCBaseTable)) then
    Result := nil
  else
    Result := TCBaseTable(Fields.Table);
end;

{ TCTableFields ***************************************************************}

procedure TCTableFields.AddField(const NewField: TCTableField);
var
  Index: Integer;
begin
  if (not Assigned(NewField.FieldBefore)) then
    Index := 0
  else if (Assigned(FieldByName(NewField.FieldBefore.Name))) then
    Index := FieldByName(NewField.FieldBefore.Name).Index + 1
  else
    Index := TList(Self).Count;

  if (NewField is TCBaseTableField) then
    Insert(Index, TCBaseTableField.Create(Self))
  else if (NewField is TCViewField) then
    Insert(Index, TCViewField.Create(Self))
  else
    Exception.Create(sUnknownToType);
  Field[Index].Assign(NewField);
  if (Index > 0) then
    Field[Index].FieldBefore := Field[Index - 1];
  if (Index + 1 <= Count - 1) then
    Field[Index + 1].FieldBefore := Field[Index];
end;

procedure TCTableFields.Assign(const Source: TCTableFields);
var
  I: Integer;
begin
  Clear();

  for I := 0 to Source.Count - 1 do
    AddField(Source.Field[I]);
end;

constructor TCTableFields.Create(const ATable: TCTable);
begin
  inherited Create();

  FTable := ATable;
end;

procedure TCTableFields.DeleteField(const AField: TCTableField);
var
  I: Integer;
  Index: Integer;
  J: Integer;
begin
  Index := IndexOf(AField);

  if (Assigned(DesktopXML)) then
    DesktopXML.ChildNodes.Remove(AField.DesktopXML);

  if (Assigned(Table) and (Table is TCBaseTable)) then
    for I := TCBaseTable(Table).Indices.Count - 1 downto 0 do
    begin
      for J := TCBaseTable(Table).Indices[I].Columns.Count - 1 downto 0 do
        if (TCBaseTable(Table).Indices[I].Columns[J].Field = AField) then
          TCBaseTable(Table).Indices[I].Columns.DeleteColumn(TCBaseTable(Table).Indices[I].Columns[J]);
      if (TCBaseTable(Table).Indices[I].Columns.Count = 0) then
        TCBaseTable(Table).Indices.DeleteIndex(TCBaseTable(Table).Indices[I]);
    end;

  if (Index + 1 < Count) then
    if (Index <= 0) then
      Field[Index + 1].FieldBefore := nil
    else
      Field[Index + 1].FieldBefore := Field[Index - 1];

  Field[Index].Free();
  Delete(Index);
end;

function TCTableFields.FieldByName(const FieldName: string): TCTableField;
var
  Index: Integer;
begin
  Index := IndexByName(FieldName);
  if (Index < 0) then
    Result := nil
  else
    Result := Field[Index];
end;

function TCTableFields.GetDesktopXML(): IXMLNode;
begin
  if (not Assigned(FDesktopXML) and Assigned(Table) and Assigned(Table.DesktopXML)) then
    FDesktopXML := XMLNode(Table.DesktopXML, 'grid', True);

  Result := FDesktopXML;
end;

function TCTableFields.GetField(Index: Integer): TCTableField;
begin
  Result := TCTableField(Items[Index]);
end;

function TCTableFields.IndexOf(const AField: TCTableField): Integer;
var
  I: Integer;
begin
  Result := -1;

  if (Assigned(AField)) then
    for I := 0 to Count - 1 do
      if (Field[I].Name = AField.Name) then
        Result := I;
end;

{ TCBaseTableFields ***********************************************************}

procedure TCBaseTableFields.MoveField(const AField: TCTableField; const NewFieldBefore: TCTableField);
var
  I: Integer;
  Index: Integer;
  NewIndex: Integer;
begin
  if (NewFieldBefore <> AField.FieldBefore) then
  begin
    Index := IndexOf(AField);

    if (not Assigned(NewFieldBefore)) then
      NewIndex := 0
    else
      NewIndex := IndexOf(NewFieldBefore) + 1;

    Move(Index, NewIndex);

    TCBaseTableField(Field[NewIndex]).Moved := True;

    Field[0].FieldBefore := nil;
    for I := 1 to Count - 1 do
      Field[I].FieldBefore := Field[I - 1];
  end;
end;

{ TCForeignKey ****************************************************************}

procedure TCForeignKey.Assign(const Source: TCForeignKey);
var
  I: Integer;
begin
  inherited Assign(Source);

  if (not Assigned(FForeignKeys) and Assigned(Source.ForeignKeys)) then
    FForeignKeys := Source.ForeignKeys;

  OriginalName := Source.OriginalName;

  Created := Source.Created;
  SetLength(Fields, Length(Source.Fields));
  for I := 0 to Length(Source.Fields) - 1 do
    Fields[I] := Source.Fields[I];
  Match := Source.Match;
  OnDelete := Source.OnDelete;
  OnUpdate := Source.OnUpdate;
  Parent.DatabaseName := Source.Parent.DatabaseName;
  Parent.TableName := Source.Parent.TableName;
  SetLength(Parent.FieldNames, Length(Source.Parent.FieldNames));
  for I := 0 to Length(Source.Parent.FieldNames) - 1 do
    Parent.FieldNames[I] := Source.Parent.FieldNames[I];
end;

procedure TCForeignKey.Clear();
begin
  Created := False;

  SetLength(Fields, 0);
  Match := mtNo;
  OnDelete := dtRestrict;
  OnUpdate := utRestrict;
  Parent.DatabaseName := '';
  Parent.TableName := '';
  SetLength(Parent.FieldNames, 0);
end;

constructor TCForeignKey.Create(const AForeignKeys: TCForeignKeys);
begin
  inherited Create();

  FForeignKeys := AForeignKeys;

  Clear();
end;

function TCForeignKey.DBTypeStr(): string;
var
  J: Integer;
begin
  Result := '';
  if (Length(Fields) > 1) then Result := Result + '(';
  for J := 0 to Length(Fields) - 1 do
  begin
    if (J > 0) then Result := Result + ', ';
    if (not Assigned(Fields[J])) then
      Result := '???'
    else
      Result := Result + Fields[J].Name;
  end;
  if (Length(Fields) > 1) then Result := Result + ')';

  Result := Result + ' -> ';

  if (Parent.DatabaseName <> ForeignKeys.Table.Database.Name) then
    Result := Result + ForeignKeys.Table.Database.Name + '.';
  Result := Result + Parent.TableName + '.';
  if (Length(Parent.FieldNames) = 1) then
    Result := Result + Parent.FieldNames[0]
  else
  begin
    Result := Result + '(';
    for J := 0 to Length(Parent.FieldNames) - 1 do
    begin
      if (J > 0) then Result := Result + ', ';
      Result := Result + Parent.FieldNames[J];
    end;
    Result := Result + ')';
  end;
end;

destructor TCForeignKey.Destroy();
begin
  SetLength(Fields, 0);
  SetLength(Parent.FieldNames, 0);

  inherited;
end;

function TCForeignKey.Equal(const Second: TCForeignKey): Boolean;
var
  I: Integer;
begin
  Result := inherited Equal(Second);

  Result := Result and (Length(Fields) = Length(Second.Fields));
  for I := 0 to Length(Fields) - 1 do
    Result := Result and (lstrcmpi(PChar(Fields[I].Name), PChar(Second.Fields[I].Name)) = 0);
  Result := Result and (Match = Second.Match);
  Result := Result and (lstrcmpi(PChar(Name), PChar(Second.Name)) = 0);
  Result := Result and (OnDelete = Second.OnDelete);
  Result := Result and (OnUpdate = Second.OnUpdate);
  Result := Result and (Table.Database.Client.TableNameCmp(Parent.DatabaseName, Second.Parent.DatabaseName) = 0);
  Result := Result and ((Table.Database.Client.TableNameCmp(Parent.TableName, Second.Parent.TableName) = 0)
                     or (Table.Database.Client.TableNameCmp(Parent.TableName, Second.Parent.TableName) = 0));
  Result := Result and (Length(Parent.FieldNames) = Length(Second.Parent.FieldNames));
  for I := 0 to Length(Parent.FieldNames) - 1 do
    Result := Result
      and (Table.Fields.NameCmp(Parent.FieldNames[I], Second.Parent.FieldNames[I]) = 0);
end;

function TCForeignKey.GetIndex(): Integer;
begin
  Result := ForeignKeys.IndexOf(Self);
end;

function TCForeignKey.GetTable(): TCBaseTable;
begin
  Result := ForeignKeys.Table;
end;

{ TCForeignKeys ***************************************************************}

procedure TCForeignKeys.AddForeignKey(const NewForeignKey: TCForeignKey);
begin
  InsertForeignKey(TList(Self).Count, NewForeignKey);
end;

procedure TCForeignKeys.Assign(const Source: TCForeignKeys);
var
  I: Integer;
begin
  Clear();

  for I := 0 to Source.Count - 1 do
  begin
    AddForeignKey(Source.ForeignKey[I]);
    ForeignKey[I].Created := Source.ForeignKey[I].Created;
  end;
  Actual := Source.Actual;
end;

procedure TCForeignKeys.Clear();
begin
  inherited;

  Actual := False;
end;

constructor TCForeignKeys.Create(const ATable: TCBaseTable);
begin
  inherited Create;

  Actual := False;

  FTable := ATable;
end;

procedure TCForeignKeys.DeleteForeignKey(const AForeignKey: TCForeignKey);
var
  Index: Integer;
begin
  Index := IndexOf(AForeignKey);

  ForeignKey[Index].Free();
  Delete(Index);
end;

function TCForeignKeys.GetClient(): TCClient;
begin
  Result := Table.Client;
end;

function TCForeignKeys.GetCount(): Integer;
begin
  if (not Actual and (Table.Source <> '')) then
    ParseCreateTable(Table.Source);

  Result := inherited GetCount();
end;

function TCForeignKeys.GetForeignKey(Index: Integer): TCForeignKey;
begin
  Result := TCForeignKey(Items[Index]);
end;

procedure TCForeignKeys.InsertForeignKey(const Index: Integer; const NewForeignKey: TCForeignKey);
begin
  Insert(Index, TCForeignKey.Create(Self));
  ForeignKey[Index].Assign(NewForeignKey);
  ForeignKey[Index].Created := True;
end;

procedure TCForeignKeys.ParseCreateTable(const SQL: string);
var
  DatabaseName: string;
  FieldName: string;
  NewForeignKey: TCForeignKey;
  Parse: TSQLParse;
  TableName: string;
begin
  if (SQLCreateParse(Parse, PChar(SQL), Length(SQL), Table.Database.Client.ServerVersion)) then
  begin
    while (not SQLParseChar(Parse, '(')) do SQLParseValue(Parse);

    while (not SQLParseChar(Parse, ')')) do
      if (not SQLParseKeyword(Parse, 'CONSTRAINT', False) and not SQLParseKeyword(Parse, 'FOREIGN KEY', False)) then
        while (not SQLParseChar(Parse, ',') and not SQLParseChar(Parse, ')', False)) do SQLParseValue(Parse)
      else
      begin
        NewForeignKey := TCForeignKey.Create(Self);

        if (SQLParseKeyword(Parse, 'CONSTRAINT')) then
        begin
          NewForeignKey.FName := SQLParseValue(Parse);
          NewForeignKey.OriginalName := NewForeignKey.Name;
        end;

        if (not SQLParseKeyword(Parse, 'FOREIGN KEY')) then raise EConvertError.CreateFmt(SSourceParseError, [Table.Database.Name + '.' + Table.Name, 2, SQL]);

        if (not SQLParseChar(Parse, '(', False)) then
          SQLParseValue(Parse); // Index Name

        if (not SQLParseChar(Parse, '(')) then raise EConvertError.CreateFmt(SSourceParseError, [Table.Database.Name + '.' + Table.Name, 3, SQL]);
        repeat
          SetLength(NewForeignKey.Fields, Length(NewForeignKey.Fields) + 1);
          NewForeignKey.Fields[Length(NewForeignKey.Fields) - 1] := Table.FieldByName(SQLParseValue(Parse));

          SQLParseChar(Parse, ',');
        until (SQLParseChar(Parse, ')'));

        if (not SQLParseKeyword(Parse, 'REFERENCES')) then raise EConvertError.CreateFmt(SSourceParseError, [Table.Database.Name + '.' + Table.Name, 4, SQL]);

        DatabaseName := Table.Database.Name;
        SQLParseObjectName(Parse, DatabaseName, TableName);

        NewForeignKey.Parent.DatabaseName := DatabaseName;
        NewForeignKey.Parent.TableName := Client.TableName(TableName); // Sometimes MySQL reports parent table name in wrong case sensitive

        if (not SQLParseChar(Parse, '(')) then raise EConvertError.CreateFmt(SSourceParseError, [Table.Database.Name + '.' + Table.Name, 5, SQL]);
        repeat
          FieldName := SQLParseValue(Parse);
          SetLength(NewForeignKey.Parent.FieldNames, Length(NewForeignKey.Parent.FieldNames) + 1);
          NewForeignKey.Parent.FieldNames[Length(NewForeignKey.Parent.FieldNames) - 1] := FieldName;

          SQLParseChar(Parse, ',');
        until (SQLParseChar(Parse, ')'));

        if (not SQLParseKeyword(Parse, 'MATCH')) then
          if (not SQLParseKeyword(Parse, 'FULL')) then
            NewForeignKey.Match := mtFull
          else if (not SQLParseKeyword(Parse, 'PARTIAL')) then
            NewForeignKey.Match := mtPartial;

        if (SQLParseKeyword(Parse, 'ON DELETE')) then
          if (SQLParseKeyword(Parse, 'RESTRICT')) then
            NewForeignKey.OnDelete := dtRestrict
          else if (SQLParseKeyword(Parse, 'CASCADE')) then
            NewForeignKey.OnDelete := dtCascade
          else if (SQLParseKeyword(Parse, 'SET NULL')) then
            NewForeignKey.OnDelete := dtSetNull
          else if (SQLParseKeyword(Parse, 'SET DEFAULT')) then
            NewForeignKey.OnDelete := dtSetDefault
          else if (SQLParseKeyword(Parse, 'NO ACTION')) then
            NewForeignKey.OnDelete := dtNoAction;

        if (SQLParseKeyword(Parse, 'ON UPDATE')) then
          if (SQLParseKeyword(Parse, 'RESTRICT')) then
            NewForeignKey.OnUpdate := utRestrict
          else if (SQLParseKeyword(Parse, 'CASCADE')) then
            NewForeignKey.OnUpdate := utCascade
          else if (SQLParseKeyword(Parse, 'SET NULL')) then
            NewForeignKey.OnUpdate := utSetNull
          else if (SQLParseKeyword(Parse, 'SET DEFAULT')) then
            NewForeignKey.OnUpdate := utSetDefault
          else if (SQLParseKeyword(Parse, 'NO ACTION')) then
            NewForeignKey.OnUpdate := utNoAction;

        AddForeignKey(NewForeignKey);
        ForeignKey[TList(Self).Count - 1].Created := False;
        FreeAndNil(NewForeignKey);
      end;

    Actual := True;
  end;
end;

{ TCTableDesktop **************************************************************}

procedure TCTableDesktop.AddFilter(const AFilter: string);
var
  FiltersXML: IXMLNode;
  I: Integer;
begin
  if (AFilter <> '') then
  begin
    FiltersXML := XMLNode(Table.DesktopXML, 'filters', True);
    for I := FiltersXML.ChildNodes.Count - 1 downto 0 do
      if (FiltersXML.ChildNodes[I].Text = AFilter) then
        FiltersXML.ChildNodes.Delete(I);
    try
      FiltersXML.AddChild('filter').NodeValue := AFilter;
    except
      // Some characters are not storable inside XML - so just ignore them
    end;
  end;

  while (FiltersXML.ChildNodes.Count > 10) do
    FiltersXML.ChildNodes.Delete(0);
end;

procedure TCTableDesktop.Clear();
begin
  SetLength(FColumnIndices, 0);
end;

constructor TCTableDesktop.Create(const ATable: TCTable);
begin
  inherited Create();

  FTable := ATable;
end;

destructor TCTableDesktop.Destroy();
begin
  Clear();

  inherited;
end;

function TCTableDesktop.GetColumnIndex(Index: Integer): Integer;
begin
  Result := FColumnIndices[Index];
end;

function TCTableDesktop.GetColunns(): Integer;
begin
  Result := Length(FColumnIndices);
end;

function TCTableDesktop.GetFilter(Index: Integer): string;
var
  FiltersXML: IXMLNode;
begin
  Result := '';

  if (Assigned(Table.DesktopXML)) then
  begin
    FiltersXML := XMLNode(Table.DesktopXML, 'filters', True);
    if (Assigned(FiltersXML) and (Index < FiltersXML.ChildNodes.Count)) then
      Result := XMLNode(Table.DesktopXML, 'filters').ChildNodes[FiltersXML.ChildNodes.Count - Index - 1].Text;
  end;
end;

function TCTableDesktop.GetFilterCount(): Integer;
begin
  Result := 0;

  if (Assigned(Table.DesktopXML)) then
    if (Assigned(XMLNode(Table.DesktopXML, 'filters'))) then
      Result := XMLNode(Table.DesktopXML, 'filters').ChildNodes.Count;
end;

function TCTableDesktop.GetGridVisible(FieldName: string): Boolean;
begin
  Result := True;

  if (Assigned(Table.DesktopXML) and Assigned(XMLNode(Table.FieldByName(FieldName).DesktopXML, 'visible'))) then
    TryStrToBool(XMLNode(Table.FieldByName(FieldName).DesktopXML, 'visible').Text, Result);
end;

function TCTableDesktop.GetGridWidth(FieldName: string): Integer;
begin
  Result := -1;

  if (Assigned(Table.FDesktopXML) and Assigned(XMLNode(Table.FieldByName(FieldName).DesktopXML, 'width'))) then
    TryStrToInt(XMLNode(Table.FieldByName(FieldName).DesktopXML, 'width').Text, Result);
end;

function TCTableDesktop.GetLimit(): Integer;
begin
  Result := DefaultLimit;

  if (Assigned(Table.DesktopXML) and Assigned(XMLNode(Table.DesktopXML, 'limit'))) then
    TryStrToInt(XMLNode(Table.DesktopXML, 'limit').Text, Result);

  if (Result < 1) then
    Result := DefaultLimit;
end;

function TCTableDesktop.GetLimited(): Boolean;
begin
  case (Table.Database.Client.Account.DefaultLimit) of
    dlOff: Result := False;
    dlRemember:
      begin
        Result := True;
        if (Assigned(Table.DesktopXML) and Assigned(XMLNode(Table.DesktopXML, 'limit'))) then
          TryStrToBool(XMLNode(Table.DesktopXML, 'limit').Attributes['used'], Result);
      end;
    else // dlOn
      Result := True;
  end;
end;

procedure TCTableDesktop.SetColumnIndex(Index: Integer; const Value: Integer);
begin
  if (Length(FColumnIndices) < Index + 1) then
    SetLength(FColumnIndices, Index + 1);

  FColumnIndices[Index] := Value;
end;

procedure TCTableDesktop.SetGridVisible(FieldName: string; const Visible: Boolean);
begin
  XMLNode(Table.FieldByName(FieldName).DesktopXML, 'visible', True).Text := BoolToStr(Visible, True);
end;

procedure TCTableDesktop.SetGridWidth(FieldName: string; const GridWidth: Integer);
begin
  if (GridWidth > 0) then
    XMLNode(Table.FieldByName(FieldName).DesktopXML, 'width', True).Text := IntToStr(GridWidth);
end;

procedure TCTableDesktop.SetLimit(const Limit: Integer);
begin
  if (Limit > 0) then
    XMLNode(Table.DesktopXML, 'limit', True).Text := IntToStr(Limit);
end;

procedure TCTableDesktop.SetLimited(const ALimited: Boolean);
begin
  if (Table.Database.Client.Account.DefaultLimit = dlRemember) then
    XMLNode(Table.DesktopXML, 'limit', True).Attributes['used'] := BoolToStr(ALimited, True);
end;

{ TCTableDataSet **************************************************************}

constructor TCTableDataSet.Create(const ATable: TCTable);
begin
  inherited Create(nil);

  FTable := ATable;
  Connection := ATable.Database.Client;
end;

function TCTableDataSet.SQLSelect(const IgnoreLimit: Boolean = False): string;
var
  DescFieldName: string;
  DescPos: Integer;
  FieldName: string;
  FirstField: Boolean;
  I: Integer;
  Pos: Integer;
begin
  FCommandText := TableName;

  Result := 'SELECT * FROM ';
  if (DatabaseName <> '') then
    Result := Result + Connection.EscapeIdentifier(FDatabaseName) + '.';
  Result := Result + Connection.EscapeIdentifier(TableName);
  if ((FilterSQL <> '') or (QuickSearch <> '')) then
  begin
    Result := Result + ' WHERE ';
    if ((FilterSQL <> '') and (QuickSearch <> '')) then
      Result := Result + '(';
    if (FilterSQL <> '') then
      Result := Result + FilterSQL;
    if ((FilterSQL <> '') and (QuickSearch <> '')) then
      Result := Result + ') AND (';
    if (QuickSearch <> '') then
      for I := 0 to Table.Fields.Count - 1 do
      begin
        if (I > 0) then Result := Result + ' OR ';
        Result := Result + Connection.EscapeIdentifier(Table.Fields[I].Name) + ' LIKE ' + SQLEscape('%' + QuickSearch + '%');
      end;
    if ((FilterSQL <> '') and (QuickSearch <> '')) then
      Result := Result + ')';
  end;
  if (SortDef.Fields <> '') then
  begin
    Result := Result + ' ORDER BY ';
    Pos := 1; FirstField := True;
    repeat
      FieldName := ExtractFieldName(SortDef.Fields, Pos);
      if (FieldName <> '') then
      begin
        if (not FirstField) then Result := Result + ',';
        Result := Result + Connection.EscapeIdentifier(FieldName);

        DescPos := 1;
        repeat
          DescFieldName := ExtractFieldName(SortDef.DescFields, DescPos);
          if (DescFieldName = FieldName) then
            Result := Result + ' DESC';
        until (DescFieldName = '');
      end;
      FirstField := False;
    until (FieldName = '');
  end;
  if (Limit > 0) then
  begin
    Result := Result + ' LIMIT ';
    if (Offset + RecordCount > 0) then
      Result := Result + IntToStr(Offset + RecordCount) + ',';
    if (IgnoreLimit) then
      RequestedRecordCount := $7fffffff - (Offset + RecordCount)
    else if (RecordCount = 0) then
      RequestedRecordCount := Limit
    else
      RequestedRecordCount := RecordCount;
    Result := Result + IntToStr(RequestedRecordCount);
  end;
  Result := Result + ';';
end;

{ TCTable *********************************************************************}

procedure TCTable.AfterCancel(DataSet: TDataSet);
begin
  Client.ExecuteEvent(ceAfterCancel, Database.Tables, Self, Database);
end;

procedure TCTable.AfterClose(DataSet: TDataSet);
begin
  Client.ExecuteEvent(ceAfterClose, Database.Tables, Self, Database);
end;

procedure TCTable.AfterOpen(DataSet: TDataSet);
begin
  if ((DataSet is TCTableDataSet) and (DataSet.FieldCount > 0)) then
  begin
    TCTableDataSet(DataSet).FFilterSQL := FFilterSQL;
    if (TCTableDataSet(DataSet).FilterSQL <> '') then
      Desktop.AddFilter(TCTableDataSet(DataSet).FilterSQL);
    if (((TCTableDataSet(DataSet).Limit > 0) <> Desktop.Limited) or (TCTableDataSet(DataSet).Limit <> Desktop.Limit)) then
    begin
      Desktop.Limited := TCTableDataSet(DataSet).Limit > 0;
      Desktop.Limit := TCTableDataSet(DataSet).Limit;
    end;


    Client.ExecuteEvent(ceAfterOpen, Database.Tables, Self, Database);
  end;
end;

procedure TCTable.AfterPost(DataSet: TDataSet);
begin
  Client.ExecuteEvent(ceAfterPost, Database.Tables, Self, Database);
end;

procedure TCTable.AfterReceivingRecords(DataSet: TDataSet);
begin
  Client.ExecuteEvent(ceAfterReceivingRecords, Database.Tables, Self, Database);
end;

procedure TCTable.AfterScroll(DataSet: TDataSet);
begin
  Client.ExecuteEvent(ceAfterScroll, Database.Tables, Self, Database);
end;

procedure TCTable.Assign(const Source: TCTable);
var
  I: Integer;
begin
  Assert(Assigned(Source.Fields));


  inherited Assign(Source);

  if (not Assigned(FDatabase)) then FDatabase := Source.Database;

  FActual := Source.Actual;

  if (Assigned(FDataSet)) then
    FreeAndNil(FDataSet);

  if (Assigned(Desktop)) then
    Desktop.Clear();

  FFields.Clear();
  for I := 0 to Source.Fields.Count - 1 do
    FFields.AddField(Source.Fields[I]);
end;

procedure TCTable.BeforeCancel(DataSet: TDataSet);
begin
  Client.ExecuteEvent(ceBeforeCancel, Database.Tables, Self, Database);
end;

procedure TCTable.BeforeClose(DataSet: TDataSet);
begin
  Client.ExecuteEvent(ceBeforeClose, Database.Tables, Self, Database);
end;

procedure TCTable.BeforeOpen(DataSet: TDataSet);
begin
  Client.ExecuteEvent(ceBeforeOpen, Database.Tables, Self, Database);
end;

procedure TCTable.BeforePost(DataSet: TDataSet);
begin
  Client.ExecuteEvent(ceBeforePost, Database.Tables, Self, Database);
end;

procedure TCTable.BeforeReceivingRecords(DataSet: TDataSet);
begin
  Client.ExecuteEvent(ceBeforeReceivingRecords, Database.Tables, Self, Database);
end;

procedure TCTable.BeforeScroll(DataSet: TDataSet);
begin
  Client.ExecuteEvent(ceBeforeScroll, Database.Tables, Self, Database);
end;

procedure TCTable.Clear();
begin
  inherited;

  if (Assigned(FDataSet)) then
    FreeAndNil(FDataSet);

  if (Assigned(Desktop)) then
    Desktop.Clear();

  if (Assigned(FFields)) then
    FFields.Clear();

  FActual := False;
end;

function TCTable.CountRecords(): Integer;
var
  DataSet: TMySQLQuery;
begin
  Result := -1;

  DataSet := TMySQLQuery.Create(nil);
  DataSet.CommandText := 'SELECT COUNT(*) FROM '+ Database.Client.EscapeIdentifier(Database.Name) +'.' + Database.Client.EscapeIdentifier(Name);
  DataSet.Open();
  if (DataSet.Active and not DataSet.IsEmpty()) then
    Result := DataSet.Fields[0].AsInteger;
  DataSet.Free();
end;

constructor TCTable.Create(const ADatabase: TCDatabase = nil; const AName: string = '');
begin
  inherited Create(ADatabase);

  FDesktopXML := nil;
  FDesktop := nil;
  FDataSet := nil;
  if (Self is TCBaseTable) then
    FFields := TCBaseTableFields.Create(Self)
  else
    FFields := TCTableFields.Create(Self);

  FName := AName;

  if (Name <> '') then
    FDesktop := TCTableDesktop.Create(Self);
end;

function TCTable.DeleteRecords(const Field: TCTableField; const Values: TStringList): Boolean;
var
  I: Integer;
  SQL: string;
begin
  SQL := 'DELETE FROM ' + Database.Client.EscapeIdentifier(Database.Name) + '.' + Database.Client.EscapeIdentifier(Name) + #13#10;
  SQL := SQL + '  WHERE ' + Database.Client.EscapeIdentifier(Field.Name) + ' IN (';
  for I := 0 to Values.Count - 1 do
  begin
    if (I > 0) then SQL := SQL + ',';
    SQL := SQL + Field.EscapeValue(Values.Strings[I]);
  end;
  SQL := SQL + ');';

  Result := Database.Client.ExecuteSQL(SQL);

  if (Assigned(DataSet)) then
    FreeAndNil(FDataSet);
end;

destructor TCTable.Destroy();
var
  I: Integer;
  J: Integer;
begin
  for I := Length(Database.Client.CachedTables) - 1 downto 0 do
    if (Database.Client.CachedTables[I] = Self) then
    begin
      for J := I to Length(Database.Client.CachedTables) - 2 do
        Database.Client.CachedTables[J] := Database.Client.CachedTables[J + 1];
      SetLength(Database.Client.CachedTables, Length(Database.Client.CachedTables) - 1);
    end;

  if (Assigned(FDataSet)) then
    FDataSet.Free();
  if (Assigned(FDesktop)) then
    FDesktop.Free();
  if (Assigned(FFields)) then
    FFields.Free();

  inherited;
end;

function TCTable.FieldByName(const FieldName: string): TCTableField;
begin
  Result := Fields.FieldByName(FieldName);
end;

function TCTable.GetDataSet(): TCTableDataSet;
begin
  Assert(Assigned(Database));

  
  if (not Assigned(FDataSet)) then
  begin
    FDataSet := TCTableDataSet.Create(Self);
    FDataSet.AutomaticLoadNextRecords := True;
    FDataSet.FDatabaseName := Database.Name;
    FDataSet.TableName := Name;

    FDataSet.BeforeCancel := BeforeCancel;
    FDataSet.BeforeClose := BeforeClose;
    FDataSet.BeforeOpen := BeforeOpen;
    FDataSet.BeforePost := BeforePost;
    FDataSet.BeforeReceivingRecords := BeforeReceivingRecords;
    FDataSet.BeforeScroll := BeforeScroll;
    FDataSet.AfterCancel := AfterCancel;
    FDataSet.AfterClose := AfterClose;
    FDataSet.AfterOpen := AfterOpen;
    FDataSet.AfterPost := AfterPost;
    FDataSet.AfterReceivingRecords := AfterReceivingRecords;
    FDataSet.AfterScroll := AfterScroll;
  end;

  Result := FDataSet;
end;

function TCTable.GetDesktopXML(): IXMLNode;
var
  I: Integer;
begin
  if (not Assigned(FDesktopXML) and Assigned(Database.Tables.DesktopXML)) then
  begin
    for I := 0 to Database.Tables.DesktopXML.ChildNodes.Count - 1 do
      if (lstrcmpi(PChar(string(Database.Tables.DesktopXML.ChildNodes[I].Attributes['name'])), PChar(Name)) = 0) then
        FDesktopXML := Database.Tables.DesktopXML.ChildNodes[I];

    if (not Assigned(FDesktopXML)) then
    begin
      FDesktopXML := Database.Tables.DesktopXML.AddChild('table');
      try
        FDesktopXML.Attributes['name'] := Name;
      except
        Database.Tables.DesktopXML.ChildNodes.Delete(Database.Tables.DesktopXML.ChildNodes.IndexOf(FDesktopXML));
        FDesktopXML := nil;
      end;
    end;
  end;

  Result := FDesktopXML;
end;

function TCTable.GetFields(): TCTableFields;
begin
  Result := FFields;
end;

function TCTable.GetIndex(): Integer;
var
  I: Integer;
begin
  Result := -1;

  if (Assigned(Database) and Assigned(Database.Tables)) then
    for I := 0 to Database.Tables.Count - 1 do
      if (Database.Tables[I] = Self) then
        Result := I;
end;

function TCTable.Initialize(): Boolean;
begin
  Result := Database.Initialize(Self);
end;

function TCTable.Open(const FilterSQL, QuickSearch: string; const ASortDef: TIndexDef; const Offset: Integer; const Limit: Integer): Boolean;
var
  CacheSize: Int64;
  I: Integer;
  J: Integer;
begin
  CacheSize := 0;
  for I := Length(Database.Client.CachedTables) - 1 downto 0 do
    if (Database.Client.CachedTables[I] <> Self) then
      Inc(CacheSize, Database.Client.CachedTables[I].DataSet.DataSize)
    else
    begin
      for J := I to Length(Database.Client.CachedTables) - 2 do
        Database.Client.CachedTables[J] := Database.Client.CachedTables[J + 1];
      SetLength(Database.Client.CachedTables, Length(Database.Client.CachedTables) - 1);
    end;
  while ((CacheSize div (1024 * 1024) >= Database.Client.Account.CacheSize) and (Length(Database.Client.CachedTables) > 0)) do
  begin
    CacheSize := 0;
    FreeAndNil(Database.Client.CachedTables[0].FDataSet);
    for J := 1 to Length(Database.Client.CachedTables) - 2 do
    begin
      Database.Client.CachedTables[J] := Database.Client.CachedTables[J + 1];
      Inc(CacheSize, Database.Client.CachedTables[J].DataSet.DataSize);
    end;
    SetLength(Database.Client.CachedTables, Length(Database.Client.CachedTables) - 1);
  end;

  FFilterSQL := FilterSQL;

  Result := False;
  DataSet.Active := False;

  DataSet.Limit := Limit;
  DataSet.Offset := Offset;
  DataSet.FilterSQL := FilterSQL;
  DataSet.FQuickSearch := QuickSearch;
  DataSet.SortDef.Assign(ASortDef);

  DataSet.Connection := Database.Client;
  DataSet.CommandText := Name;
  DataSet.Open();

  if (Result) then
  begin
    SetLength(Database.Client.CachedTables, Length(Database.Client.CachedTables) + 1);
    Database.Client.CachedTables[Length(Database.Client.CachedTables) - 1] := Self;
  end;
end;

function TCTable.GetSourceEx(const DropBeforeCreate: Boolean = False; const EncloseDefiner: Boolean = True; const ForeignKeysSource: PString = nil): string;
begin
  raise EAbstractError.Create(SAbstractError);
end;

procedure TCTable.SetName(const AName: string);
begin
  if (Database.Client.LowerCaseTableNames = 1) then
    inherited SetName(LowerCase(AName))
  else
    inherited SetName(AName);
end;

{ TCPartition *****************************************************************}

procedure TCPartition.Assign(const Source: TCPartition);
begin
  inherited Assign(Source);

  if (Assigned(Source.Table)) then FTable := Source.Table;

  Comment := Source.Comment;
  Engine := Source.Engine;
  OriginalName := Source.OriginalName;
  MaxRows := Source.MaxRows;
  MinRows := Source.MinRows;
  ValuesExpr := Source.ValuesExpr;
end;

procedure TCPartition.Clear();
begin
  Comment := '';
  Engine := nil;
  OriginalName := '';
  MaxRows := -1;
  MinRows := -1;
  ValuesExpr := '';
end;

constructor TCPartition.Create(const ATable: TCBaseTable);
begin
  inherited Create();

  Clear();

  FTable := ATable;
end;

function TCPartition.DBTypeStr(): string;
begin
  if (not (Table.Partitions.PartitionType in [ptRange, ptList])) then
    Result := ''
  else
  begin
    Result := 'PARTITION ';
    if (Name <> '') then
      Result := Result + Table.Database.Client.EscapeIdentifier(Name) + ' ';
    case (Table.Partitions.PartitionType) of
      ptRange: Result := Result + 'VALUES LESS THAN (' + ValuesExpr + ')';
      ptList: Result := Result + 'VALUES IN (' + ValuesExpr + ')';
    end;
    if (Comment <> '') then
      Result := Result + ' COMMENT=' + SQLEscape(Comment);
    if (MaxRows >= 0) then
      Result := Result + ' MAX_ROWS=' + IntToStr(MaxRows);
    if (MinRows >= 0) then
      Result := Result + ' MIN_ROWS=' + IntToStr(MinRows);
  end;
end;

function TCPartition.Equal(const Second: TCPartition): Boolean;
begin
  Result := inherited Equal(Second)
    and (Comment = Second.Comment)
    and (Engine = Second.Engine)
    and (Name = Second.Name)
    and (MaxRows = Second.MaxRows)
    and (MinRows = Second.MinRows)
    and (ValuesExpr = Second.ValuesExpr);
end;

{ TCPartitions ****************************************************************}

procedure TCPartitions.AddPartition(const NewPartition: TCPartition);
begin
  Add(TCPartition.Create(TCBaseTable(Table)));
  Partition[Count - 1].Assign(NewPartition);
end;

procedure TCPartitions.Assign(const Source: TCPartitions);
var
  I: Integer;
begin
  Clear();

  if (Assigned(Source.FTable)) then FTable := Source.FTable;

  Expression := Source.Expression;
  FCount := Source.FCount;
  Linear := Source.Linear;
  PartitionType := Source.PartitionType;

  for I := 0 to Source.Count - 1 do
    AddPartition(Source.Partition[I]);
end;

procedure TCPartitions.Clear();
begin
  Expression := '';
  FCount := -1;
  Linear := False;
  PartitionType := ptUnknown;

  inherited;
end;

constructor TCPartitions.Create(const ATable: TCBaseTable);
begin
  inherited Create();

  FTable := ATable;
end;

procedure TCPartitions.DeletePartition(const APartition: TCPartition);
var
  Index: Integer;
begin
  Index := IndexOf(APartition);

  Partition[Index].Free();
  Delete(Index);
end;

function TCPartitions.GetCount(): Integer;
begin
  Result := Max(FCount, TList(Self).Count);
end;

function TCPartitions.GetPartition(Index: Integer): TCPartition;
begin
  Result := TCPartition(Items[Index]);
end;

function TCPartitions.IndexOf(const APartition: TCPartition): Integer;
var
  I: Integer;
begin
  Result := -1;

  if (Assigned(APartition)) then
    for I := 0 to Count - 1 do
      if (Partition[I].Name = APartition.Name) then
        Result := I;
end;

procedure TCPartitions.MovePartition(const APartition: TCPartition; const NewIndex: Integer);
begin
  Move(IndexOf(APartition), NewIndex);
end;

function TCPartitions.UpdatePartition(const Partition, NewPartition: TCPartition): Boolean;
begin
  Result := Assigned(Partition) and not Assigned(Table.PartitionByName(NewPartition.Name)) or (Table.PartitionByName(NewPartition.Name) = Partition);

  if (Result) then
    Partition.Assign(NewPartition);
end;

{ TCBaseTable *****************************************************************}

procedure TCBaseTable.Assign(const Source: TCTable);
var
  I: Integer;
begin
  inherited;

  FActualStatus := TCBaseTable(Source).ActualStatus;
  FAutoIncrement := TCBaseTable(Source).AutoIncrement;
  FChecked := TCBaseTable(Source).Checked;
  FCollation := TCBaseTable(Source).FCollation;
  FComment := TCBaseTable(Source).Comment;
  FCreated := TCBaseTable(Source).Created;
  FDataSize := TCBaseTable(Source).DataSize;
  FDefaultCharset := TCBaseTable(Source).FDefaultCharset;
  FDefaultCodePage := TCBaseTable(Source).FDefaultCodePage;
  FEngine := TCBaseTable(Source).Engine;
  FIndexSize := TCBaseTable(Source).IndexSize;
  FMaxDataSize := TCBaseTable(Source).MaxDataSize;
  FRows := TCBaseTable(Source).Rows;
  FRowType := TCBaseTable(Source).RowType;
  FUnusedSize := TCBaseTable(Source).UnusedSize;
  FUpdated := TCBaseTable(Source).Updated;

  if (Actual) then
  begin
    FIndices.Assign(TCBaseTable(Source).Indices);

    FForeignKeys.Actual := True; // Do not allow GetSource!
    FForeignKeys.Assign(TCBaseTable(Source).ForeignKeys);

    if (Assigned(FPartitions) and (not Assigned(Database) or (Database.Client.ServerVersion < 50107))) then
      FreeAndNil(FPartitions)
    else if (not Assigned(FPartitions) and Assigned(Database) and (Database.Client.ServerVersion >= 50107)) then
      FPartitions := TCPartitions.Create(Self);
    if (Assigned(FPartitions) and Assigned(TCBaseTable(Source).Partitions)) then FPartitions.Assign(TCBaseTable(Source).Partitions);
  end;

  if (Assigned(Source.Database) and Assigned(Database)) then
    if ((Source.Database.Client.ServerVersion < 40101) and (Database.Client.ServerVersion < 40101) or (Source.Database.Client.ServerVersion >= 40101) and (Database.Client.ServerVersion >= 40101)) then
    begin
      DefaultCharset := TCBaseTable(Source).DefaultCharset;
      Collation := TCBaseTable(Source).Collation;
    end
    else if ((Source.Database.Client.ServerVersion < 40101) and (Database.Client.ServerVersion >= 40101)) then
    begin
      for I := 0 to Length(CharsetTranslations) - 1 do
        if (TCBaseTable(Source).DefaultCharset = CharsetTranslations[I].OldCharset) then
        begin
          DefaultCharset := string(CharsetTranslations[I].NewCharset);
          Collation := string(CharsetTranslations[I].NewCollation);
        end;
    end
    else if ((Source.Database.Client.ServerVersion > 40101) and (Database.Client.ServerVersion < 40101)) then
    begin
      for I := 0 to Length(CharsetTranslations) - 1 do
        if ((TCBaseTable(Source).DefaultCharset = CharsetTranslations[I].NewCharset) and (TCBaseTable(Source).Collation = string(CharsetTranslations[I].NewCollation))) then
          DefaultCharset := CharsetTranslations[I].OldCharset;
      if (DefaultCharset = '') then
        for I := 0 to Length(CharsetTranslations) - 1 do
          if (TCBaseTable(Source).DefaultCharset = CharsetTranslations[I].OldCharset) then
            DefaultCharset := CharsetTranslations[I].OldCharset;
      if (DefaultCharset = '') then
        for I := 0 to Length(CharsetTranslations) - 1 do
          if (TCBaseTable(Source).DefaultCharset = CharsetTranslations[I].NewCharset) then
            DefaultCharset := CharsetTranslations[I].NewCharset;
    end;

  FPackIndices := TCBaseTable(Source).PackIndices;
end;

procedure TCBaseTable.BuildStatus(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean);
begin
  if (not UseInformationSchema) then
  begin
    if (Assigned(DataSet.FindField('Type'))) then // MySQL < 4.1.2 and 5.0.0???
      FEngine := Database.Client.EngineByName(DataSet.FieldByName('Type').AsString)
    else
      FEngine := Database.Client.EngineByName(DataSet.FieldByName('Engine').AsString);
    FRowType := StrToMySQLRowType(DataSet.FieldByName('Row_format').AsString);
    if (Self is TCSystemView) then
      FRows := -1
    else
      FRows := DataSet.FieldByName('Rows').AsLargeInt;
    FDataSize := DataSet.FieldByName('Data_length').AsLargeInt;
    FIndexSize := DataSet.FieldByName('Index_length').AsLargeInt;
    FMaxDataSize := DataSet.FieldByName('Max_data_length').AsLargeInt;
    FUnusedSize := DataSet.FieldByName('Data_free').AsLargeInt;
    FAutoIncrement := DataSet.FieldByName('Auto_increment').AsLargeInt;
    FCreated := DataSet.FieldByName('Create_time').AsDateTime;
    FUpdated := DataSet.FieldByName('Update_time').AsDateTime;
    FChecked := DataSet.FieldByName('Check_time').AsDateTime;
    FComment := DataSet.FieldByName('Comment').AsString;
  end
  else
  begin
    Engine := Database.Client.EngineByName(DataSet.FieldByName('ENGINE').AsString);
    RowType := StrToMySQLRowType(DataSet.FieldByName('ROW_FORMAT').AsString);
    if (Self is TCSystemView) then
      FRows := -1
    else
      FRows := DataSet.FieldByName('TABLE_ROWS').AsLargeInt;
    FDataSize := DataSet.FieldByName('DATA_LENGTH').AsLargeInt;
    FMaxDataSize := DataSet.FieldByName('MAX_DATA_LENGTH').AsLargeInt;
    FIndexSize := DataSet.FieldByName('INDEX_LENGTH').AsLargeInt;
    FUnusedSize := DataSet.FieldByName('DATA_FREE').AsLargeInt;
    FAutoIncrement := DataSet.FieldByName('AUTO_INCREMENT').AsLargeInt;
    FCreated := DataSet.FieldByName('CREATE_TIME').AsDateTime;
    FUpdated := DataSet.FieldByName('UPDATE_TIME').AsDateTime;
    FChecked := DataSet.FieldByName('CHECK_TIME').AsDateTime;
    if (Assigned(DataSet.FindField('TABLE_COLLATION'))) then
      Collation := LowerCase(DataSet.FieldByName('TABLE_COLLATION').AsString);
    FComment := DataSet.FieldByName('TABLE_COMMENT').AsString;

    if (not Assigned(Database.Client.CharsetByCollation(FCollation))) then
      DefaultCharset := ''
    else
      DefaultCharset := Database.Client.CharsetByCollation(FCollation).Name;
  end;

  if (Pos('InnoDB free: ', FComment) > 0) then
  begin
    Delete(FComment, Pos('InnoDB free: ', FComment), Length(FComment) - Pos('InnoDB free: ', FComment) + 1);
    FComment := Trim(FComment);
    if (Copy(FComment, Length(FComment), 1) = ';') then Delete(FComment, Length(FComment), 1);
  end;

  FActualStatus := True;
end;

function TCBaseTable.Check(): Boolean;
begin
  Result := Database.Client.ExecuteSQL('CHECK TABLE ' + Database.Client.EscapeIdentifier(Database.Name) + '.' + Database.Client.EscapeIdentifier(Name) + ';');

  if (Result) then
    FChecked := Database.Client.DateTime;
end;

procedure TCBaseTable.Clear();
begin
  FAutoIncrement := -1;
  FChecked := -1;
  FCollation := '';
  FComment := '';
  FCreated := -1;
  FDataSize := -1;
  FDefaultCharset := '';
  FDefaultCodePage := CP_ACP;
  FEngine := nil;
  FIndexSize := -1;
  FMaxDataSize := -1;
  FRows := -1;
  FRowType := mrUnknown;
  FUnusedSize := -1;
  FUpdated := -1;

  FIndices.Clear();
  FForeignKeys.Clear();
  if (Assigned(FPartitions)) then FPartitions.Clear();

  inherited;

  FActualStatus := False;
  FPackIndices := piDefault;
end;

procedure TCBaseTable.ClearBySource(const ASource: string);
begin
  Clear();
  ParseCreateTable(ASource);
end;

function TCBaseTable.CountRecords(): Integer;
begin
  if (Assigned(Engine) and (UpperCase(Engine.Name) <> 'INNODB')) then
    Result := Rows
  else
    Result := inherited CountRecords();
end;

constructor TCBaseTable.Create(const ADatabase: TCDatabase = nil; const AName: string = ''; const ASystemTable: Boolean = False);
begin
  FIndices := TCIndices.Create(Self);
  FForeignKeys := TCForeignKeys.Create(Self);
  if (not Assigned(ADatabase) or (ADatabase.Client.ServerVersion < 50107)) then
    FPartitions := nil
  else
    FPartitions := TCPartitions.Create(Self);

  inherited Create(ADatabase, AName);

  if (Assigned(ADatabase)) then
    FDefaultCharset := ADatabase.DefaultCharset;
end;

function TCBaseTable.DBRowTypeStr(): string;
begin
  Result := '';
  case (RowType) of
    mrFixed: Result := 'FIXED';
    mrDynamic: Result := 'DYNAMIC';
    mrCompressed: Result := 'COMPRESSED';
    mrRedundant: Result := 'REDUNDANT';
    mrCompact: if (Database.Client.ServerVersion >= 50003) then Result := 'COMPACT';
  end;
end;

destructor TCBaseTable.Destroy();
begin
  FIndices.Free();
  FForeignKeys.Free();
  if (Assigned(FPartitions)) then
    FPartitions.Free();

  inherited;
end;

function TCBaseTable.Empty(): Boolean;
begin
  Result := Database.EmptyTables([Name]);
end;

function TCBaseTable.EmptyFields(const Names: array of string): Boolean;
var
  I: Integer;
  SQL: string;
begin
  Result := True;

  SQL := '';
  for I := 0 to Length(Names) - 1 do
  begin
    if (SQL <> '') then SQL := SQL + ',';
    if (FieldByName(Names[I]).NullAllowed) then
      SQL := SQL + Database.Client.EscapeIdentifier(Names[I]) + '=NULL';
  end;
  if (Result and (SQL <> '')) then
  begin
    SQL := 'UPDATE ' + Database.Client.EscapeIdentifier(Database.Name) + '.' + Database.Client.EscapeIdentifier(Name) + ' SET ' + SQL + ';';

    Result := Database.Client.ExecuteSQL(SQL);

    if (Result and Assigned(FDataSet)) then
      FreeAndNil(FDataSet);
  end;
end;

function TCBaseTable.FieldByName(const FieldName: string): TCBaseTableField;
var
  Field: TCField;
begin
  Field := inherited FieldByName(FieldName);
  if (not (Field is TCBaseTableField)) then
    Result := nil
  else
    Result := TCBaseTableField(Field);
end;

function TCBaseTable.Flush(): Boolean;
begin
  Result := Database.Client.ExecuteSQL('FLUSH TABLE ' + Database.Client.EscapeIdentifier(Database.Name) + '.' + Database.Client.EscapeIdentifier(Name) + ';');
end;

function TCBaseTable.ForeignKeyByName(const ForeignKeyName: string): TCForeignKey;
var
  Index: Integer;
begin
  Index := ForeignKeys.IndexByName(ForeignKeyName);
  if (Index < 0) then
    Result := nil
  else
    Result := ForeignKeys[Index];
end;

function TCBaseTable.GetAutoIncrementField(): TCBaseTableField;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Fields.Count - 1 do
    if (Fields[I].AutoIncrement) then
      Result := TCBaseTableField(Fields[I]);
end;

function TCBaseTable.GetBaseTableFields(): TCBaseTableFields;
var
  BaseTableFields: TCTableFields;
begin
  BaseTableFields := GetFields();
  if (not (BaseTableFields is TCBaseTableFields)) then
    Result := nil
  else
    Result := TCBaseTableFields(BaseTableFields);
end;

function TCBaseTable.GetCollation(): string;
begin
  if ((FCollation = '') and (FDataSize < 0) and (Source <> '')) then
    ParseCreateTable(Source);

  Result := FCollation;
end;

function TCBaseTable.GetComment(): string;
begin
  if ((FComment = '') and (FDataSize < 0) and (Source <> '')) then
    ParseCreateTable(Source);

  Result := FComment;
end;

function TCBaseTable.GetDefaultCharset(): string;
begin
  if ((FDefaultCharset = '') and (FDataSize < 0) and (Source <> '')) then
    ParseCreateTable(Source);

  Result := FDefaultCharset;
end;

function TCBaseTable.GetDefaultCodePage(): Cardinal;
begin
  if (FDefaultCodePage = CP_ACP) then
    GetDefaultCharset();

  Result := FDefaultCodePage;
end;

function TCBaseTable.GetEngine(): TCEngine;
begin
  if (not Assigned(FEngine) and (FDataSize < 0) and (Source <> '')) then
    ParseCreateTable(Source);

  Result := FEngine;
end;

function TCBaseTable.GetForeignKeys(): TCForeignKeys;
begin
  if ((Name <> '') and not FForeignKeys.Actual and (Source <> '')) then
    FForeignKeys.ParseCreateTable(Source);

  Result := FForeignKeys;
end;

function TCBaseTable.GetFields(): TCTableFields;
begin
  if (not Actual and (TList(FFields).Count = 0) and (Name <> '') and (Source <> '')) then
    ParseCreateTable(Source);

  Result := inherited GetFields();
end;

function TCBaseTable.GetIndexSize(): Int64;
begin
  Result := FIndexSize;
end;

function TCBaseTable.GetIndices(): TCIndices;
begin
  if (not Actual and (TList(FFields).Count = 0) and (Name <> '') and (Source <> '')) then
    ParseCreateTable(Source);

  Result := FIndices;
end;

function TCBaseTable.GetPartitions(): TCPartitions;
begin
  if (not Actual and (TList(FFields).Count = 0) and (Name <> '')) then
    ParseCreateTable(Source);

  Result := FPartitions;
end;

function TCBaseTable.GetPrimaryIndex(): TCIndex;
begin
  Result := IndexByName('');
end;

function TCBaseTable.GetSourceEx(const DropBeforeCreate: Boolean = False; const EncloseDefiner: Boolean = True; const ForeignKeysSource: PString = nil): string;
var
  I: Integer;
  S: string;
  StringList: TStringList;
begin
  Result := '';

  if (Name <> '') then
    if ((FSource <> '') and not DropBeforeCreate and not Assigned(ForeignKeysSource)) then
      Result := FSource
    else
    begin
      Result := ReplaceStr(ReplaceStr(ReplaceStr(Source, #13, #10), #10#10, #10), #10, #13#10);

      if (Assigned(ForeignKeysSource)) then
      begin
        ForeignKeysSource^ := '';
        StringList := TStringList.Create();
        StringList.Text := Result;
        for I := StringList.Count - 1 downto 0 do
          if (Pos('CONSTRAINT', UpperCase(Trim(StringList.Strings[I]))) = 1) then
          begin
            S := Trim(StringList.Strings[I]);
            Insert('ADD ', S, Pos('CONSTRAINT', S));
            if (ForeignKeysSource^ <> '') then
              S := S + ',';
            ForeignKeysSource^ := S + #13#10 + ForeignKeysSource^;
            if ((I > 0) and (RightStr(TrimRight(StringList[I - 1]), 1) = ',') and (RightStr(TrimRight(StringList[I]), 1) <> ',')) then
              StringList[I - 1] := Copy(TrimRight(StringList[I - 1]), 1, Length(TrimRight(StringList[I - 1])) - 1);
            StringList.Delete(I);
          end;
        Result := SQLTrimStmt(StringList.Text);
        FreeAndNil(StringList);
        ForeignKeysSource^ := Trim(ForeignKeysSource^);

        if (ForeignKeysSource^ <> '') then
        begin
          if (ForeignKeysSource^[Length(ForeignKeysSource^) - 1] = ',') then Delete(ForeignKeysSource^, Length(ForeignKeysSource^) - 1, 1);
          ForeignKeysSource^ := SQLTrimStmt('ALTER TABLE ' + Database.Client.EscapeIdentifier(Name) + #13#10 + ForeignKeysSource^) + ';';
        end;
      end;

      if (DropBeforeCreate) then
        Result := 'DROP TABLE IF EXISTS ' + Database.Client.EscapeIdentifier(Name) + ';' + #13#10 + Result;
    end;
end;

function TCBaseTable.IndexByCaption(const Caption: string): TCIndex;
var
  IndexName: string;
begin
  IndexName := Caption;

  Delete(IndexName, Pos(' (' + Preferences.LoadStr(377), IndexName), Length(IndexName) - Pos(' (' + Preferences.LoadStr(377), IndexName) + 2);
  if (IndexName = ReplaceStr(Preferences.LoadStr(154), '&', '')) then IndexName := '';

  Result := IndexByName(IndexName);
end;

function TCBaseTable.IndexByName(const IndexName: string): TCIndex;
var
  I: Integer;
begin
  Result := nil;

  if (FIndices.Count > 0) then
    if (IndexName = 'PRIMARY') and (Indices[0].Name = '') then
      Result := Indices[0]
    else
      for I := 0 to Indices.Count - 1 do
        if (lstrcmpi(PChar(Indices[I].Name), PChar(IndexName)) = 0) then
          Result := Indices[I];
end;

function TCBaseTable.IndexByDataSet(const DataSet: TCTableDataSet): TCIndex;
var
  DescPos: Integer;
  FieldName: string;
  Found: Boolean;
  I: Integer;
  J: Integer;
  Pos: Integer;
begin
  Result := nil;

  for I := 0 to Indices.Count - 1 do
    if (not Assigned(Result)) then
    begin
      Pos := 1; Found := True;
      for J := 0 to Indices[I].Columns.Count - 1 do
        if (Found) then
        begin
          FieldName := ExtractFieldName(DataSet.SortDef.Fields, Pos);
          Found := Found and (FieldName = Indices[I].Columns[J].Field.Name);
          if (Found and not Indices[I].Columns[J].Ascending) then
          begin
            DescPos := 1;
            repeat
              FieldName := ExtractFieldName(DataSet.SortDef.DescFields, DescPos);
              Found := FieldName = Indices[I].Columns[J].Field.Name;
            until (Found or (FieldName = ''));
          end;
        end;
      if (Found) then
        Result := Indices[I];
    end;
end;

function TCBaseTable.Optimize(): Boolean;
begin
  Result := Database.Client.ExecuteSQL('OPTIMIZE TABLE ' + Database.Client.EscapeIdentifier(Database.Name) + '.' + Database.Client.EscapeIdentifier(Name) + ';');
end;

function TCBaseTable.Open(const Filter, QuickSearch: string; const ASortDef: TIndexDef; const Offset: Integer; const Limit: Integer): Boolean;
begin
  Fields.Count; // Fetch fields BEFORE open the table

  Result := inherited Open(Filter, QuickSearch, ASortDef, Offset, Limit);
end;

function TCBaseTable.PartitionByName(const PartitionName: string): TCPartition;
var
  Index: Integer;
begin
  Index := Partitions.IndexByName(PartitionName);
  if (Index < 0) then
    Result := nil
  else
    Result := Partitions[Index];
end;

procedure TCBaseTable.ParseCreateTable(const SQL: string);
var
  I: Integer;
  J: Integer;
  K: Integer;
  L: Largeint;
  NewField: TCBaseTableField;
  NewIndex: TCIndex;
  NewIndexColumn: TCIndexColumn;
  NewPartition: TCPartition;
  Parse: TSQLParse;
  Pos: Integer;
  S: string;
begin
  if (Assigned(FFields) and (FFields.Count = 0) and SQLCreateParse(Parse, PChar(SQL), Length(SQL), Database.Client.ServerVersion)) then
  begin
    FActual := True;

    Pos := 1;

    if (not SQLParseKeyword(Parse, 'CREATE')) then
      raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 6, SQL]);

    Temporary := SQLParseKeyword(Parse, 'TEMPORARY');

    if (not SQLParseKeyword(Parse, 'TABLE')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 7, SQL]);

    FName := SQLParseValue(Parse);
    if (SQLParseChar(Parse, '.')) then
    begin
      if (Database.Client.TableNameCmp(Database.Name, FName) <> 0) then
        raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + FName, 8, SQL]);
      FName := SQLParseValue(Parse);
    end;

    if (not SQLParseChar(Parse, '(')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 9, SQL]);

    if (not Assigned(Database.Client.VariableByName('sql_quote_show_create'))) then
    begin
      Database.Client.IdentifierQuoted := CharInSet(SQL[Pos], ['`', '"']);
      if (not Assigned(Database.Client.VariableByName('sql_mode')) and Database.Client.IdentifierQuoted) then
        Database.Client.IdentifierQuoter := SQL[Pos];
    end;

    while (Database.Client.IdentifierQuoted and SQLParseChar(Parse, Char(Database.Client.IdentifierQuoter), False))
      or (not SQLParseChar(Parse, ')', False)
      and not SQLParseKeyword(Parse, 'PRIMARY', False)
      and not SQLParseKeyword(Parse, 'SPATIAL', False)
      and not SQLParseKeyword(Parse, 'KEY', False)
      and not SQLParseKeyword(Parse, 'INDEX', False)
      and not SQLParseKeyword(Parse, 'UNIQUE', False)
      and not SQLParseKeyword(Parse, 'FULLTEXT', False)
      and not SQLParseKeyword(Parse, 'CONSTRAINT', False)
      and not SQLParseKeyword(Parse, 'FOREIGN KEY', False)) do
    begin
      NewField := TCBaseTableField.Create(FFields);
      if (FFields.Count > 0) then
        NewField.FieldBefore := FFields.Field[FFields.Count - 1]
      else
        NewField.FieldBefore := nil;

      try
        NewField.FName := SQLParseValue(Parse);
        NewField.OriginalName := NewField.Name;

        NewField.ParseFieldType(Parse);

        while (not SQLParseChar(Parse, ',', False) and not SQLParseChar(Parse, ')', False)) do
        begin
          if (SQLParseKeyword(Parse, 'CHARACTER SET')) then
            NewField.Charset := SQLParseValue(Parse)
          else if (SQLParseKeyword(Parse, 'COLLATE')) then
            NewField.Collation := LowerCase(SQLParseValue(Parse))
          else if (SQLParseKeyword(Parse, 'NOT NULL')) then
            NewField.NullAllowed := False
          else if (SQLParseKeyword(Parse, 'NULL')) then
            NewField.NullAllowed := True
          else if (SQLParseKeyword(Parse, 'DEFAULT')) then
          begin
            if (SQLParseKeyword(Parse, 'NULL')) then
              NewField.Default := 'NULL'
            else if (SQLParseKeyword(Parse, 'CURRENT_TIMESTAMP')) then
              NewField.Default := 'CURRENT_TIMESTAMP'
            else if (NewField.FieldType = mfBit) then
            begin
              S := SQLParseValue(Parse);
              if (LowerCase(Copy(S, 1, 1)) <> 'b') then
              begin
                MoveMemory(@L, PAnsiChar(RawByteString(S)), Length(S));
                NewField.Default := IntToBitString(L, NewField.Size);
              end
              else
              begin
                Delete(S, 1, 1);
                NewField.Default := SQLUnescape(S);
              end;
            end
            else
              NewField.Default := SQLEscape(SQLParseValue(Parse));
            if (SQLParseKeyword(Parse, 'ON UPDATE')) then
              NewField.OnUpdate := SQLParseValue(Parse);
          end
          else if (SQLParseKeyword(Parse, 'AUTO_INCREMENT')) then
            NewField.AutoIncrement := True
          else if (SQLParseKeyword(Parse, 'COMMENT')) then
            NewField.Comment := SQLParseValue(Parse)
          else
            SQLParseValue(Parse);
        end;

        FFields.AddField(NewField);
      finally
        FreeAndNil(NewField);
      end;

      SQLParseChar(Parse, ',');
    end;

    while (SQLParseKeyword(Parse, 'PRIMARY', False)
      or SQLParseKeyword(Parse, 'SPATIAL', False)
      or SQLParseKeyword(Parse, 'KEY', False)
      or SQLParseKeyword(Parse, 'INDEX', False)
      or SQLParseKeyword(Parse, 'UNIQUE', False)
      or SQLParseKeyword(Parse, 'FULLTEXT', False)) do
    begin
      NewIndex := TCIndex.Create(FIndices);

      NewIndex.Primary := SQLParseKeyword(Parse, 'PRIMARY');

      NewIndex.Unique := SQLParseKeyword(Parse, 'UNIQUE');

      SQLParseKeyword(Parse, 'SPATIAL');

      NewIndex.Fulltext := SQLParseKeyword(Parse, 'FULLTEXT');

      SQLParseKeyword(Parse, 'KEY');
      SQLParseKeyword(Parse, 'INDEX');

      if (not SQLParseKeyword(Parse, 'TYPE', False) and not SQLParseKeyword(Parse, 'USING', False) and not SQLParseChar(Parse, '(', False)) then
      begin
        NewIndex.FName := SQLParseValue(Parse);
        NewIndex.OriginalName := NewIndex.Name;
      end;

      if (SQLParseKeyword(Parse, 'TYPE') or SQLParseKeyword(Parse, 'USING')) then
        NewIndex.IndexType := SQLParseValue(Parse);

      if (SQLParseChar(Parse, '(')) then
        while (not SQLParseChar(Parse, ')')) do
        begin
          NewIndexColumn := TCIndexColumn.Create(NewIndex.Columns);

          NewIndexColumn.Field := FieldByName(SQLParseValue(Parse));
          if (SQLParseChar(Parse, '(')) then
          begin
            NewIndexColumn.Length := StrToInt(SQLParseValue(Parse));
            SQLParseChar(Parse, ')')
          end;
          NewIndex.Columns.AddColumn(NewIndexColumn);
          FreeAndNil(NewIndexColumn);

          SQLParseChar(Parse, ',');
        end;

      if (SQLParseKeyword(Parse, 'USING')) then // MySQL >= 5.01.xx
        NewIndex.IndexType := SQLParseValue(Parse);

      NewIndex.Unique := NewIndex.Unique or NewIndex.Primary;
      FIndices.AddIndex(NewIndex);
      FIndices.Index[FIndices.Count - 1].Created := False;
      FreeAndNil(NewIndex);

      SQLParseChar(Parse, ',');
    end;

    while (SQLParseKeyword(Parse, 'CONSTRAINT') or SQLParseKeyword(Parse, 'FOREIGN KEY')) do
      // ForeignKeys will be parsed separately to not go into a loopback
      while (not SQLParseChar(Parse, ',') and not SQLParseChar(Parse, ')', False)) do
        SQLParseValue(Parse);

    if (not SQLParseChar(Parse, ')')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 10, SQL]);

    while ((Pos <= Length(SQL)) and not SQLParseChar(Parse, ';')) do
    begin
      if (SQLParseKeyword(Parse, 'TYPE') or SQLParseKeyword(Parse, 'ENGINE')) then
      begin
        if (not SQLParseChar(Parse, '=')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 11, SQL]);
        FEngine := Database.Client.EngineByName(SQLParseValue(Parse));
      end
      else if (SQLParseKeyword(Parse, 'AUTO_INCREMENT')) then
      begin
        if (not SQLParseChar(Parse, '=')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 12, SQL]);
        FAutoIncrement := StrToInt64(SQLParseValue(Parse));
      end
      else if (SQLParseKeyword(Parse, 'DEFAULT CHARSET') or SQLParseKeyword(Parse, 'CHARSET')) then
      begin
        if (not SQLParseChar(Parse, '=')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 13, SQL]);
        DefaultCharset := SQLParseValue(Parse);
      end
      else if (SQLParseKeyword(Parse, 'COLLATE')) then
      begin
        if (not SQLParseChar(Parse, '=')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 14, SQL]);
        Collation := LowerCase(SQLParseValue(Parse));
      end
      else if (SQLParseKeyword(Parse, 'PACK_KEYS')) then
      begin
        if (not SQLParseChar(Parse, '=')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 15, SQL]);
        S := SQLParseValue(Parse);
        if (S = '0') then
          FPackIndices := piUnpacked
        else if (S = '1') then
          FPackIndices := piPacked
        else
          FPackIndices := piDefault;
      end
      else if (SQLParseKeyword(Parse, 'COMMENT')) then
      begin
        if (not SQLParseChar(Parse, '=')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 16, SQL]);
        FComment := SQLParseValue(Parse);
      end
      else if (SQLParseKeyword(Parse, 'ROW_FORMAT')) then
      begin
        if (not SQLParseChar(Parse, '=')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 17, SQL]);
        FRowType := StrToMySQLRowType(SQLParseValue(Parse));
      end
      else if (SQLParseKeyword(Parse, 'PARTITION')) then
      begin
        SQLParseKeyword(Parse, 'BY');

        if (not Assigned(FPartitions)) then
          Pos := Length(SQL) // ServerVersion < 50107
        else
        begin
          FPartitions.Linear := SQLParseKeyword(Parse, 'LINEAR');

          FPartitions.PartitionType := StrToPartitionType(SQLParseValue(Parse));
          if (SQLParseChar(Parse, '(')) then
          begin
            FPartitions.Expression := Trim(SQLParseValue(Parse));
            SQLParseChar(Parse, ')');
          end;

          if (SQLParseKeyword(Parse, 'PARTITIONS')) then
            FPartitions.FCount := StrToInt(SQLParseValue(Parse));

          if (SQLParseChar(Parse, '(')) then
          begin
            while ((Pos <= Length(SQL)) and not SQLParseChar(Parse, ')')) do
            begin
              NewPartition := TCPartition.Create(Self);

              while ((Pos <= Length(SQL)) and not SQLParseChar(Parse, ',') and not SQLParseChar(Parse, ')')) do
              begin
                if (SQLParseKeyword(Parse, 'PARTITION')) then
                begin
                  NewPartition.FName := SQLParseValue(Parse);
                  NewPartition.OriginalName := NewPartition.Name;
                end
                else if (SQLParseKeyword(Parse, 'VALUES')) then
                begin
                  SQLParseKeyword(Parse, 'IN');
                  SQLParseKeyword(Parse, 'LESS THAN');

                  NewPartition.ValuesExpr := SQLParseValue(Parse);
                end
                else if (SQLParseKeyword(Parse, 'ENGINE')) then
                begin
                  if (not SQLParseChar(Parse, '=')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 18, SQL]);
                  NewPartition.Engine := Database.Client.EngineByName(SQLParseValue(Parse));
                end
                else if (SQLParseKeyword(Parse, 'COMMENT')) then
                begin
                  if (not SQLParseChar(Parse, '=')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 19, SQL]);
                  NewPartition.Comment := SQLParseValue(Parse);
                end
                else if (SQLParseKeyword(Parse, 'MAX_ROWS')) then
                begin
                  if (not SQLParseChar(Parse, '=')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 20, SQL]);
                  NewPartition.MaxRows := StrToInt(SQLParseValue(Parse));
                end
                else if (SQLParseKeyword(Parse, 'MIN_ROWS')) then
                begin
                  if (not SQLParseChar(Parse, '=')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 21, SQL]);
                  NewPartition.MinRows := StrToInt(SQLParseValue(Parse));
                end
                else
                begin
                  SQLParseValue(Parse);
                  if (SQLParseChar(Parse, '=')) then;
                    SQLParseValue(Parse);
                end;
              end;

              FPartitions.AddPartition(NewPartition);
              FreeAndNil(NewPartition);

              SQLParseChar(Parse, ',');
            end;
          end;
        end;
      end
      else
      begin
        SQLParseValue(Parse);
        if (SQLParseChar(Parse, '=')) then;
          SQLParseValue(Parse);
      end;

      // subpartitioning is not supported now
    end;

    for I := 0 to FFields.Count - 1 do
      if (FFields.Field[I] is TCBaseTableField) then
      begin
        TCBaseTableField(FFields.Field[I]).FInPrimaryIndex := False;
        TCBaseTableField(FFields.Field[I]).FInUniqueIndex := False;
        for J := 0 to FIndices.Count - 1 do
          if (J = 0) or (FIndices.Index[J].Unique) then
            for K := 0 to FIndices.Index[J].Columns.Count - 1 do
              if (TCBaseTableField(FFields.Field[I]) = FIndices.Index[J].Columns.Column[K].Field) then
                TCBaseTableField(FFields.Field[I]).FInUniqueIndex := True;
      end;

    if ((FIndices.Count >= 1) and (FIndices[0].Primary)) then
      for J := 0 to FIndices.Index[0].Columns.Count - 1 do
        FIndices.Index[0].Columns.Column[J].Field.FInPrimaryIndex := True;
  end;
end;

function TCBaseTable.Repair(): Boolean;
begin
  Result := Database.Client.ExecuteSQL('REPAIR TABLE ' + Database.Client.EscapeIdentifier(Database.Name) + '.' + Database.Client.EscapeIdentifier(Name) + ';');
end;

procedure TCBaseTable.SetDefaultCharset(const ADefaultCharset: string);
begin
  FDefaultCharset := LowerCase(ADefaultCharset);

  if (not Assigned(Database) or not Assigned(Database.Client)) then
    FDefaultCodePage := CP_ACP
  else if (FDefaultCharset <> '') then
    FDefaultCodePage := Database.Client.CharsetToCodePage(FDefaultCharset)
  else if (Database.FDefaultCharset <> '') then
    FDefaultCodePage := Database.Client.CharsetToCodePage(Database.FDefaultCharset)
  else
    FDefaultCodePage := Database.Client.CharsetToCodePage(Database.Client.DefaultCharset)
end;

procedure TCBaseTable.SetSource(const ADataSet: TMySQLQuery);
begin
  SetSource(ADataSet.FieldByName('Create Table'));

  Client.ExecuteEvent(ceUpdated, Self, Self, Database);
end;

function TCBaseTable.SQLGetSource(): string;
begin
  Result := 'SHOW CREATE TABLE ' + Database.Client.EscapeIdentifier(Database.Name) + '.' + Database.Client.EscapeIdentifier(Name) + ';' + #13#10
end;

{ TCSystemView ****************************************************************}

{ TCViewField *****************************************************************}

{ TCView **********************************************************************}

procedure TCView.Assign(const Source: TCTable);
begin
  inherited;

  FAlgorithm := TCView(Source).Algorithm;
  FDefiner := TCView(Source).Definer;
  FCheckOption := TCView(Source).CheckOption;
  FSecurity := TCView(Source).Security;
  FStatement := TCView(Source).Statement;
end;

procedure TCView.Clear();
begin
  FAlgorithm := vaUndefined;
  FDefiner := '';
  FCheckOption := voNone;
  FSecurity := seDefiner;
  FStatement := '';

  inherited;
end;

constructor TCView.Create(const ADatabase: TCDatabase = nil; const AName: string = '');
begin
  FSynMemo := nil;

  inherited Create(ADatabase, AName);

  FAlgorithm := vaUndefined;
  FDefiner := '';
  FCheckOption := voNone;
  FSecurity := seDefiner;
  FStatement := '';
end;

destructor TCView.Destroy();
begin
  if (Assigned(FSynMemo)) then
    FreeAndNil(FSynMemo);

  inherited;
end;

function TCView.GetActualSource(): Boolean;
begin
  Result := inherited and (Fields.Count > 0);
end;

function TCView.GetSourceEx(const DropBeforeCreate: Boolean = False; const EncloseDefiner: Boolean = True; const ForeignKeysSource: PString = nil): string;
begin
  Result := ParseCreateView(Source, not EncloseDefiner, True);

  if (DropBeforeCreate) then
    Result := 'DROP VIEW IF EXISTS ' + Database.Client.EscapeIdentifier(Name) + ';' + #13#10 + Result;
end;

function TCView.ParseCreateView(const SQL: string; const RemoveDefiner: Boolean = False; const RemoveDatabaseName: Boolean = False): string;
var
  EndingCommentLen: Integer;
  Index: Integer;
  Len: Integer;
  Parse: TSQLParse;
  StartingCommentLen: Integer;
begin
  if (not SQLCreateParse(Parse, PChar(SQL), Length(SQL), Database.Client.ServerVersion)) then
    Result := ''
  else
  begin
    FActual := True;

    Result := SQL;

    if (not SQLParseKeyword(Parse, 'CREATE')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 22, SQL]);

    if (not SQLParseKeyword(Parse, 'ALGORITHM')) then
      Algorithm := vaUndefined
    else
    begin
      if (not SQLParseChar(Parse, '=')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 23, SQL]);

      if (SQLParseKeyword(Parse, 'MERGE')) then
        FAlgorithm := vaMerge
      else if (SQLParseKeyword(Parse, 'TEMPTABLE')) then
        FAlgorithm := vaTemptable
      else if (SQLParseKeyword(Parse, 'UNDEFINED')) then
        FAlgorithm := vaUndefined
      else
        FAlgorithm := vaUndefined;
    end;

    Index := SQLParseGetIndex(Parse);
    if (SQLParseKeyword(Parse, 'DEFINER')) then
    begin
      if (not SQLParseChar(Parse, '=')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 24, SQL]);
      FDefiner := SQLParseValue(Parse);
      if (RemoveDefiner) then
        Delete(Result, Index, SQLParseGetIndex(Parse) - Index);
    end;

    if (SQLParseKeyword(Parse, 'SQL SECURITY DEFINER')) then
      FSecurity := seDefiner
    else if (SQLParseKeyword(Parse, 'SQL SECURITY INVOKER')) then
      FSecurity := seInvoker;

    if (not SQLParseKeyword(Parse, 'VIEW')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 25, SQL]);

    Index := SQLParseGetIndex(Parse);
    FName := SQLParseValue(Parse);
    if (SQLParseChar(Parse, '.')) then
    begin
      if (Database.Client.TableNameCmp(Database.Name, FName) <> 0) then
        raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + FName, 26, SQL]);
      FName := SQLParseValue(Parse);
      if (RemoveDatabaseName) then
        Delete(Result, Index, SQLParseGetIndex(Parse) - Index);
    end;

    if (not SQLParseKeyword(Parse, 'AS')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 27, SQL]);

    Len := SQLTrimStmt(SQL, SQLParseGetIndex(Parse), Length(SQL) - (SQLParseGetIndex(Parse) - 1), StartingCommentLen, EndingCommentLen);
    if (Copy(SQL, Length(SQL) - EndingCommentLen, 1) = ';') then
    begin
      Dec(Len);
      Inc(EndingCommentLen);
    end;

    if (UpperCase(Copy(SQL, Length(SQL) - EndingCommentLen - 18 + 1, 18)) = ' WITH CHECK OPTION') then
    begin
      FCheckOption := voDefault;
      Dec(Len, 18); Inc(EndingCommentLen, 18);
    end
    else if (UpperCase(Copy(SQL, Length(SQL) - EndingCommentLen - 27 + 1, 27)) = ' WITH CASCADED CHECK OPTION') then
    begin
      FCheckOption := voCascaded;
      Dec(Len, 27); Inc(EndingCommentLen, 27);
    end
    else if (UpperCase(Copy(SQL, Length(SQL) - EndingCommentLen - 24 + 1, 24)) = ' WITH LOCAL CHECK OPTION') then
    begin
      FCheckOption := voLocal;
      Dec(Len, 24); Inc(EndingCommentLen, 24);
    end
    else
      FCheckOption := voNone;

    FStatement := Copy(SQL, SQLParseGetIndex(Parse), Len) + ';';
  end;
end;

procedure TCView.SetSource(const ADataSet: TMySQLQuery);
begin
  SetSource(ADataSet.FieldByName('Create View'));

  Client.ExecuteEvent(ceUpdated, Self, Self, Database);
end;

procedure TCView.SetSource(const ASource: string);
begin
  inherited;

  ParseCreateView(FSource);
end;

function TCView.SQLGetSource(): string;
begin
  Result := 'SHOW CREATE VIEW ' + Database.Client.EscapeIdentifier(Database.Name) + '.' + Database.Client.EscapeIdentifier(Name) + ';' + #13#10
end;

{ TCTables ********************************************************************}

function TCTables.Add(const AObject: TCObject; const Event: Boolean = False): Integer;
begin
  Result := 0;
  while ((Result < TList(Self).Count) and (Client.TableNameCmp(Table[Result].Name, AObject.Name) < 0)) do
    Inc(Result);

  if (Result < TList(Self).Count) then
    TList(Self).Insert(Result, AObject)
  else
    TList(Self).Add(AObject);

  if (Event) then
    Client.ExecuteEvent(ceCreated, Self, AObject, Database);
end;

procedure TCTables.AddTable(const NewTable: TCTable);
var
  I: Integer;
  Index: Integer;
  TableName: string;
begin
  TableName := NewTable.Name;

  Index := TList(Self).Count - 1;
  for I := TList(Self).Count - 1 downto 0 do
    if (Database.Client.TableNameCmp(TableName, Table[I].Name) <= 0) then
      Index := I;

  if (NewTable is TCBaseTable) then
  begin
    Insert(Index, TCBaseTable.Create(Database));
    Table[Index].Assign(TCBaseTable(NewTable));
  end
  else
  begin
    Insert(Index, TCView.Create(Database));
    Table[Index].Assign(TCView(NewTable));
  end;
end;

function TCTables.ApplyMySQLTableName(const ATableName: string): string;
begin
  Result := ATableName;

  Result := ReplaceStr(Result, #0, '_');
  Result := ReplaceStr(Result, '/', '_');
  Result := ReplaceStr(Result, '\', '_');
  Result := ReplaceStr(Result, '.', '_');

  if (Database.Client.LowerCaseTableNames = 1) then
    Result := LowerCase(Result);
end;

procedure TCTables.Assign(const Source: TCTables);
var
  I: Integer;
begin
  for I := 0 to TList(Self).Count - 1 do
    Table[I].Free();
  Clear();

  for I := 0 to Source.Count - 1 do
    AddTable(Source.Table[I]);
end;

function TCTables.Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean;
var
  BaseTable: TCBaseTable;
  Index: Integer;
  TableName: string;
  Update: Boolean;
  View: TCView;
begin
  Update := False; Index := -1;

  if (DataSet.FieldCount <= 2) then
  begin
    if (not DataSet.IsEmpty()) then
      repeat
        TableName := DataSet.Fields[0].AsString;

        Index := IndexByName(TableName);
        Update := Index >= 0;

        if (not Update) then
          if (Database = Database.Client.PerformanceSchema) then
            Index := Add(TCSystemView.Create(Database, TableName, True))
          else if ((Database.Client.ServerVersion < 50002) or (UpperCase(DataSet.FieldByName('Table_Type').AsString) = 'BASE TABLE') or (UpperCase(DataSet.FieldByName('Table_Type').AsString) = 'ERROR')) then
            Index := Add(TCBaseTable.Create(Database, TableName))
          else if ((UpperCase(DataSet.FieldByName('Table_Type').AsString) = 'SYSTEM VIEW') or ((50000 <= Database.Client.ServerVersion) and (Database.Client.ServerVersion < 50012) and (Database = Database.Client.InformationSchema)) or (Database = Database.Client.PerformanceSchema)) then
            Index := Add(TCSystemView.Create(Database, TableName, True))
          else if (UpperCase(DataSet.FieldByName('Table_Type').AsString) = 'VIEW') then
            Index := Add(TCView.Create(Database, TableName))
          else
            raise EDatabaseError.CreateFmt('Unknown TABLE_TYPE "%s" for Table "%S". Table will be ignored.  (%s)', [DataSet.FieldByName('TABLE_TYPE').AsString, TableName, DataSet.CommandText]);
      until (not DataSet.FindNext());
    FActualNames := True;

    Result := True;
  end
  else
  begin
    if (not DataSet.IsEmpty()) then
      repeat
        if ((not UseInformationSchema
          and not DataSet.FieldByName('Name').IsNull
          and (Assigned(DataSet.FindField('Type')) and (DataSet.FindField('Type').AsString <> '')
            or Assigned(DataSet.FindField('Engine')) and (DataSet.FindField('Engine').AsString <> '')))
          or (UseInformationSchema and (DataSet.FieldByName('TABLE_SCHEMA').AsString = Database.Name))) then
        begin
          if (not UseInformationSchema) then
            TableName := DataSet.FieldByName('Name').AsString
          else
            TableName := DataSet.FieldByName('TABLE_NAME').AsString;

          Index := IndexByName(TableName);
          Update := Index >= 0;

          if (not Update) then
            if (Database = Database.Client.PerformanceSchema) then
              Index := Add(TCSystemView.Create(Database, TableName, True))
            else if (not UseInformationSchema or (UpperCase(DataSet.FieldByName('TABLE_TYPE').AsString) = 'BASE TABLE')) then
              Index := Add(TCBaseTable.Create(Database, TableName))
            else if ((UpperCase(DataSet.FieldByName('TABLE_TYPE').AsString) = 'SYSTEM VIEW') or ((50000 <= Database.Client.ServerVersion) and (Database.Client.ServerVersion < 50012) and (Database = Database.Client.InformationSchema))) then
              Index := Add(TCSystemView.Create(Database, TableName, True))
            else if (UpperCase(DataSet.FieldByName('TABLE_TYPE').AsString) = 'VIEW') then
              Index := Add(TCView.Create(Database, TableName))
            else
              raise EDatabaseError.CreateFmt('Unknown TABLE_TYPE "%s" for Table "%S". Table will be ignored.', [DataSet.FieldByName('TABLE_TYPE').AsString, DataSet.FieldByName('TABLE_NAME').AsString]);

          if (Table[Index] is TCBaseTable) then
          begin
            BaseTable := TCBaseTable(Table[Index]);
            BaseTable.BuildStatus(DataSet, UseInformationSchema);
          end
          else if (Table[Index] is TCView) then
          begin
            View := TCView(Table[Index]);
            if (UpperCase(DataSet.FieldByName('TABLE_COMMENT').AsString) <> 'VIEW') then
              View.Comment := DataSet.FieldByName('TABLE_COMMENT').AsString;
          end;
        end;
      until (not DataSet.FindNext());

    Result := inherited;
  end;

  if ((DataSet.RecordCount = 1) and Update) then
    Client.ExecuteEvent(ceUpdated, Self, Table[Index], Database)
  else
    Client.ExecuteEvent(ceBuild, Self, nil, Database);
end;

procedure TCTables.BuildViewFields(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean);
var
  Found: Boolean;
  NewField: TCViewField;
  Parse: TSQLParse;
  Update: Boolean;
  View: TCView;
begin
  Found := False; Update := False; View := nil;

  if (not DataSet.IsEmpty()) then
    repeat
      View := Database.ViewByName(DataSet.FieldByName('TABLE_NAME').AsString);

      if (Assigned(View) and (DataSet.FieldByName('COLUMN_NAME').AsString <> '')) then
      begin
        if (not Found) then
        begin
          Update := View.Fields.Count > 0;
          View.Fields.Clear();
          Found := True;
        end;

        NewField := TCViewField.Create(View.Fields);
        NewField.FName := DataSet.FieldByName('COLUMN_NAME').AsString;

        if (TList(View.Fields).Count > 0) then
          NewField.FieldBefore := View.Fields[TList(View.Fields).Count - 1];

        NewField.AutoIncrement := Pos('AUTO_INCREMENT', UpperCase(DataSet.FieldByName('EXTRA').AsString)) > 0;
        NewField.FCollation := LowerCase(DataSet.FieldByName('COLLATION_NAME').AsString);
        NewField.Comment := DataSet.FieldByName('COLUMN_COMMENT').AsString;
        NewField.Default := DataSet.FieldByName('COLUMN_DEFAULT').AsString;
        NewField.FCharset := DataSet.FieldByName('CHARACTER_SET_NAME').AsString;
        if (DataSet.FieldByName('COLUMN_TYPE').IsNull or (DataSet.FieldByName('COLUMN_TYPE').AsString = 'null') or not SQLCreateParse(Parse, PChar(DataSet.FieldByName('COLUMN_TYPE').AsString), Length(DataSet.FieldByName('COLUMN_TYPE').AsString), Client.ServerVersion)) then
          NewField.FieldType := mfUnknown
        else
          NewField.ParseFieldType(Parse);
        NewField.FInPrimaryIndex := UpperCase(DataSet.FieldByName('EXTRA').AsString) = 'PRI';
        NewField.FInUniqueIndex := NewField.InPrimaryIndex or (UpperCase(DataSet.FieldByName('EXTRA').AsString) = 'UNI');
        NewField.NullAllowed := DataSet.FieldByName('IS_NULLABLE').AsBoolean;

        View.Fields.AddField(NewField);
        FreeAndNil(NewField);
      end;
    until (not DataSet.FindNext());

  if (Found) then
    if ((DataSet.RecordCount = 1) and Update) then
      Client.ExecuteEvent(ceUpdated, Self, View, Database)
    else
      Client.ExecuteEvent(ceBuild, Self, nil, Database);
end;

procedure TCTables.Clear();
begin
  if (Actual and Assigned(DesktopXML)) then
    DesktopXML.Attributes['count'] := Count;

  inherited;

  FActualNames := False;
end;

constructor TCTables.Create(const ADatabase: TCDatabase);
begin
  inherited;

  FDesktopXML := nil;
  Clear();
end;

procedure TCTables.Delete(const AObject: TCObject);
begin
  Assert(AObject is TCTable);


  if (Assigned(DesktopXML)) then
    DesktopXML.ChildNodes.Remove(TCTable(AObject).DesktopXML);

  inherited;
end;

function TCTables.GetBaseTable(Index: Integer): TCBaseTable;
var
  Table: TCTable;
begin
  Table := GetTable(Index);

  if (Table is TCBaseTable) then
    Result := TCBaseTable(Table)
  else
    Result := nil;
end;

function TCTables.GetCount(): Integer;
begin
  if (not Actual and not ActualNames) then
    Result := -1
  else
    Result := TList(Self).Count;
end;

function TCTables.GetDesktopXML(): IXMLNode;
begin
  if (not Assigned(FDesktopXML) and Assigned(Database) and Assigned(Database.DesktopXML)) then
    FDesktopXML := XMLNode(Database.DesktopXML, 'tables', True);

  Result := FDesktopXML;
end;

function TCTables.GetTable(Index: Integer): TCTable;
begin
  Result := TCTable(Items[Index]);
end;

function TCTables.IndexByName(const Name: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to TList(Self).Count - 1 do
    if (Database.Client.TableNameCmp(Name, Table[I].Name) = 0) then
      Result := I;
end;

function TCTables.SQLGetItems(const Name: string = ''): string;
begin
  if (not Database.Client.UseInformationSchema or (Database.Client.ServerVersion < 50002)) then
  begin
    Result := 'SHOW TABLE STATUS FROM ' + Database.Client.EscapeIdentifier(Database.Name);
    if (Name <> '') then
      Result := Result + ' LIKE ' + SQLEscape(Name);
    Result := Result + ';' + #13#10;
  end
  else
  begin
    Result := 'SELECT * FROM ' + Database.Client.EscapeIdentifier(information_schema) + '.' + Database.Client.EscapeIdentifier('TABLES');
    Result := Result + ' WHERE ' + Database.Client.EscapeIdentifier('TABLE_SCHEMA') + '=' + SQLEscape(Database.Name);
    if (Name <> '') then
      Result := Result + ' AND ' + Database.Client.EscapeIdentifier('TABLE_NAME') + '=' + SQLEscape(Name);
    Result := Result + ';' + #13#10;
  end;
end;

function TCTables.SQLGetNames(): string;
begin
  if (Database.Client.ServerVersion < 50002) then
    Result := 'SHOW TABLES FROM ' + Database.Client.EscapeIdentifier(Database.Name) + ';' + #13#10
  else
    Result := 'SHOW FULL TABLES FROM ' + Database.Client.EscapeIdentifier(Database.Name) + ';' + #13#10;
end;

{ TCRoutineParameter **********************************************************}

procedure TCRoutineParameter.Assign(const Source: TCField);
begin
  Assert(Source is TCRoutineParameter);

  inherited;

  FParameterType := TCRoutineParameter(Source).FParameterType;
end;

constructor TCRoutineParameter.Create(ARoutine: TCRoutine);
begin
  inherited Create(ARoutine.Database.Client.FieldTypes);

  FRoutine := ARoutine;

  FParameterType := ptIn;
end;

{ TCRoutine *******************************************************************}

procedure TCRoutine.Assign(const Source: TCRoutine);
var
  I: Integer;
begin
  inherited Assign(Source);

  if (not Assigned(FDatabase)) then FDatabase := Source.FDatabase;

  FActualSource := Source.ActualSource;
  Comment := Source.Comment;
  FCreated := Source.Created;
  FDatabase := Source.Database;
  FDefiner := Source.Definer;
  if (Assigned(Source.FFunctionResult)) then
  begin
    FFunctionResult := TCField.Create(Database.Client.FieldTypes);
    FFunctionResult.Assign(Source.FFunctionResult);
  end;
  FModified := Source.Modified;
  SetLength(FParameters, Length(Source.FParameters));
  for I := 0 to Length(FParameters) - 1 do
  begin
    FParameters[I] := TCRoutineParameter.Create(Self);
    FParameters[I].Assign(Source.FParameters[I]);
  end;
  FRoutineType := Source.RoutineType;
  FSecurity := Source.Security;
  OldSource := Source.OldSource;
end;

procedure TCRoutine.Clear();
begin
  inherited;

  FActualSource := False;
  FComment := '';
  FCreated := 0;
  FDefiner := '';
  if (Assigned(FFunctionResult)) then
    FreeAndNil(FFunctionResult);
  FModified := 0;
  FRoutineType := rtUnknown;
  FSecurity := seDefiner;
  while (Length(FParameters) > 0) do
  begin
    FParameters[Length(FParameters) - 1].Free();
    SetLength(FParameters, Length(FParameters) - 1);
  end;
  OldSource := '';
  if (Assigned(FFunctionResult)) then
    FreeAndNil(FFunctionResult);
end;

constructor TCRoutine.Create(const ADatabase: TCDatabase; const AName: string = '');
begin
  FFunctionResult := nil;
  FIDEResult := nil;
  SetLength(FParameters, 0);
  FSynMemo := nil;

  inherited Create(ADatabase, AName);
end;

destructor TCRoutine.Destroy();
begin
  while (Length(FParameters) > 0) do
  begin
    FParameters[Length(FParameters) - 1].Free();
    SetLength(FParameters, Length(FParameters) - 1);
  end;

  if (Assigned(FInputDataSet)) then
  begin
    FInputDataSet.Cancel();
    FreeAndNil(FInputDataSet);
  end;
  if (Assigned(FIDEResult)) then
    FIDEResult.Free();
  if (Assigned(FSynMemo)) then
    FSynMemo.Free();
  if (Assigned(FFunctionResult)) then
    FFunctionResult.Free();

  inherited;
end;

function TCRoutine.GetParameter(Index: Integer): TCRoutineParameter;
begin
  Source; // ParseCreateRoutine

  Result := FParameters[Index];
end;

function TCRoutine.GetParameterCount(): Integer;
begin
  Source; // ParseCreateRoutine

  Result := Length(FParameters);
end;

function TCRoutine.GetIDEResult(): TCResultSet;
begin
  if (not Assigned(FIDEResult)) then
    FIDEResult := TCResultSet.Create(Database.Client);

  Result := FIDEResult;
end;

function TCRoutine.GetInputDataSet(): TMySQLDataSet;
var
  Field: TField;
  I: Integer;
begin
  if (Assigned(FInputDataSet) and (FInputDataSet.FieldCount <> ParameterCount)) then
    FreeAndNil(FInputDataSet);
  if (not Assigned(FInputDataSet) and (ParameterCount > 0)) then
  begin
    FInputDataSet := TMySQLDataSet.Create(nil);
    FInputDataSet.CachedUpdates := True;
    FInputDataSet.Connection := Database.Client;
    for I := 0 to ParameterCount - 1 do
    begin
      if (not (Parameter[I].ParameterType in [ptIn, ptInOut])) then
      begin
        Field := TStringField.Create(nil);
        Field.Size := Length(OutParameterCaption);
      end
      else
        case (Parameter[I].FieldType) of
          mfBit:
            begin
              Field := TMySQLBlobField.Create(nil);
              if ((50020 <= Database.Client.ServerVersion) and (Database.Client.ServerVersion < 50100) or (Database.Client.ServerVersion >= 50110)) then
                Field.Size := Parameter[I].Size div 8
              else
                Field.Size := Parameter[I].Size;
              Field.Tag := ftBitField;
            end;
          mfTinyInt,
          mfSmallInt: if (not Parameter[I].Unsigned) then Field := TSmallIntField.Create(nil) else Field := TWordField.Create(nil);
          mfMediumInt,
          mfInt: if (not Parameter[I].Unsigned) then Field := TIntegerField.Create(nil) else Field := TLargeintField.Create(nil);
          mfBigInt: Field := TLargeintField.Create(nil);
          mfFloat,
          mfDouble,
          mfDecimal: Field := TFloatField.Create(nil);
          mfDate: Field := TMySQLDateField.Create(nil);
          mfDateTime: Field := TMySQLDateTimeField.Create(nil);
          mfTime: Field := TMySQLTimeField.Create(nil);
          mfYear: Field := TSmallIntField.Create(nil);
          mfChar,
          mfVarChar:
            begin
              if ((Parameter[I].Size < 256) and ((Parameter[I].Size < 65535) or (Database.Client.ServerVersion < 50000))) then
                Field := TMySQLWideStringField.Create(nil)
              else
                Field := TMySQLWideMemoField.Create(nil);
              if (Parameter[I].Size > 0) then Field.Size := Parameter[I].Size;
              Field.Tag := Database.DefaultCodePage;
            end;
          mfBinary,
          mfVarBinary:
            begin
              Field := TMySQLBlobField.Create(nil);
              if (Parameter[I].Size > 0) then Field.Size := Parameter[I].Size and $7FFFFFFF;
            end;
          mfTinyText,
          mfText,
          mfMediumText,
          mfLongText:
            begin
                Field := TMySQLWideMemoField.Create(nil);
              if (Parameter[I].Size > 0) then Field.Size := Parameter[I].Size;
              Field.Tag := Database.DefaultCodePage;
            end;
          mfTinyBlob,
          mfBlob,
          mfMediumBlob,
          mfLongBlob:
            begin
              Field := TMySQLBlobField.Create(nil);
              if (Parameter[I].Size > 0) then Field.Size := Parameter[I].Size and $7FFFFFFF;
            end;
          mfEnum,
          mfSet:
            begin
              Field := TMySQLWideStringField.Create(nil);
              if (Parameter[I].Size > 0) then Field.Size := Parameter[I].Size;
              Field.Tag := Database.DefaultCodePage;
            end;
          mfGeometry,
          mfPoint,
          mfLineString,
          mfPolygon,
          mfMultiPoint,
          mfMultiLineString,
          mfMultiPolygon,
          mfGeometryCollection:
            begin
              Field := TMySQLBlobField.Create(nil);
              Field.Size := Parameter[I].Size and $7FFFFFFF;
              Field.Tag := ftGeometryField;
            end;
          else raise EDatabaseError.CreateFMT(SUnknownFieldType + '(%s)', [Parameter[I].Name, Database.Client.FieldTypeByMySQLFieldType(Parameter[I].FieldType).Caption]);
        end;
      Field.FieldName := Parameter[I].Name;
      Field.DataSet := FInputDataSet;
    end;

    FInputDataSet.Open();
    FInputDataSet.Append();
    for I := 0 to ParameterCount - 1 do
      if (not (Parameter[I].ParameterType in [ptIn, ptInOut])) then
      begin
        FInputDataSet.Fields[I].AsString := OutParameterCaption;
        FInputDataSet.Fields[I].ReadOnly := True;
      end;
    FInputDataSet.Post();
    FInputDataSet.Edit();
  end;

  Result := FInputDataSet;
end;

function TCRoutine.GetSourceEx(const DropBeforeCreate: Boolean = False; const EncloseDefiner: Boolean = True; const ForeignKeysSource: PString = nil): string;
var
  Parse: TSQLParse;
  Pos: Integer;
  SQL: string;
  Start: Integer;
begin
  Result := '';

  if (SQLCreateParse(Parse, PChar(Source), Length(Source), Database.Client.ServerVersion)) then
  begin
    SQL := Trim(Source);

    if (not EncloseDefiner) then
    begin
      Pos := 1;

      if (not SQLParseKeyword(Parse, 'CREATE')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 28, SQL]);

      if (SQLParseKeyword(Parse, 'DEFINER')) then
      begin
        if (not SQLParseChar(Parse, '=')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 29, SQL]);
        Start := Pos;
        SQLParseValue(Parse);
        Delete(SQL, Start, Pos - Start);
      end;
    end;

    SQL := SQL + #13#10;

    if (DropBeforeCreate) then
      case (RoutineType) of
        rtProcedure:
          SQL := 'DROP PROCEDURE IF EXISTS ' + Database.Client.EscapeIdentifier(Name) + ';' + #13#10 + SQL;
        rtFunction:
          SQL := 'DROP FUNCTION IF EXISTS ' + Database.Client.EscapeIdentifier(Name) + ';' + #13#10 + SQL;
        else
          raise Exception.CreateFMT(SUnknownRoutineType, [Name]);
      end;

    Result := SQL;
  end;
end;

function TCRoutine.Initialize(): Boolean;
begin
  Result := Database.InitializeSources(Self);
end;

procedure TCRoutine.ParseCreateRoutine(const SQL: string);
var
  Parameter: TCRoutineParameter;
  Parse: TSQLParse;
begin
  if (SQLCreateParse(Parse, PChar(SQL), Length(SQL), Database.Client.ServerVersion)) then
  begin
    while (Length(FParameters) > 0) do
    begin
      FParameters[Length(FParameters) - 1].Free();
      SetLength(FParameters, Length(FParameters) - 1);
    end;
    if (Assigned(FFunctionResult)) then
      FreeAndNil(FFunctionResult);

    if (not SQLParseKeyword(Parse, 'CREATE')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 30, SQL]);

    if (SQLParseKeyword(Parse, 'DEFINER')) then
    begin
      if (not SQLParseChar(Parse, '=')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 31, SQL]);
      FDefiner := SQLParseValue(Parse);
    end;

    if (SQLParseKeyword(Parse, 'PROCEDURE')) then
      FRoutineType := rtProcedure
    else if (SQLParseKeyword(Parse, 'FUNCTION')) then
      FRoutineType := rtFunction
    else
      raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 32, SQL]);

    FName := SQLParseValue(Parse);
    if (SQLParseChar(Parse, '.')) then
    begin
      if (Database.Client.TableNameCmp(Database.Name, FName) <> 0) then
        raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + FName, 33, SQL]);
      FName := SQLParseValue(Parse);
    end;

    if (SQLParseChar(Parse, '(')) then
      while (not SQLParseChar(Parse, ')')) do
      begin
        SetLength(FParameters, Length(FParameters) + 1);
        FParameters[Length(FParameters) - 1] := TCRoutineParameter.Create(Self);
        Parameter := FParameters[Length(FParameters) - 1];

        if (SQLParseKeyword(Parse, 'OUT')) then
          Parameter.FParameterType := ptOut
        else if (SQLParseKeyword(Parse, 'INOUT')) then
          Parameter.FParameterType := ptInOut
        else if (SQLParseKeyword(Parse, 'IN')) then
          Parameter.FParameterType := ptIn;

        Parameter.FName := SQLParseValue(Parse);

        Parameter.ParseFieldType(Parse);

        if (SQLParseKeyword(Parse, 'CHARSET')) then
          Parameter.Charset := SQLParseValue(Parse);

        SQLParseChar(Parse, ',');
      end;

    if (SQLParseKeyword(Parse, 'RETURNS')) then
    begin
      FFunctionResult := TCField.Create(Database.Client.FieldTypes);
      FFunctionResult.ParseFieldType(Parse);

      if (SQLParseKeyword(Parse, 'CHARSET')) then
        FFunctionResult.Charset := SQLParseValue(Parse);
    end;
  end;
end;

procedure TCRoutine.SetSource(const ADataSet: TMySQLQuery);
begin
  SetSource(ADataSet.FieldByName('Create Table'));

  OldSource := FSource;

  Client.ExecuteEvent(ceUpdated, Self, Self, Database);
end;

procedure TCRoutine.SetSource(const ASource: string);
begin
  inherited;

  ParseCreateRoutine(FSource);
end;

function TCRoutine.SQLGetSource(): string;
begin
  Result := '';
end;

function TCRoutine.SQLRun(): string;
begin
  Result := '';
end;

{ TCProcedure *****************************************************************}

procedure TCProcedure.SetSource(const ADataSet: TMySQLQuery);
begin
  SetSource(ADataSet.FieldByName('Create Procedure'));

  Client.ExecuteEvent(ceUpdated, Self, Self, Database);
end;

function TCProcedure.SQLGetSource(): string;
begin
  Result := 'SHOW CREATE PROCEDURE ' + Database.Client.EscapeIdentifier(Database.Name) + '.' + Database.Client.EscapeIdentifier(Name) + ';' + #13#10
end;

function TCProcedure.SQLRun(): string;
const
  ObjectIDEParameterName = 'MySQL_Front_Object_IDE_';
var
  I: Integer;
  InParameters: Boolean;
  OutParameters: Boolean;
begin
  InParameters := False; OutParameters := False;
  for I := 0 to ParameterCount - 1 do
  begin
    InParameters := InParameters or (Parameter[I].ParameterType in [ptIn, ptInOut]);
    OutParameters := OutParameters or (Parameter[I].ParameterType in [ptInOut, ptOut]);
  end;

  for I := 0 to ParameterCount - 1 do
    if (Parameter[I].ParameterType in [ptInOut]) then
    begin
      if (Result <> '') then Result := Result + ',';
      if (InputDataSet.Fields[I].Value = Null) then
        Result := '@' + ObjectIDEParameterName + Parameter[I].Name + '=NULL'
      else
        Result := '@' + ObjectIDEParameterName + Parameter[I].Name + '=' + Parameter[I].EscapeValue(InputDataSet.Fields[I].Value);
    end;
  if (Result <> '') then
    Result := 'SET ' + Result + ';' + #13#10;

  Result := Result + 'CALL ' + Database.Client.EscapeIdentifier(Database.Name) + '.' + Database.Client.EscapeIdentifier(Name) + '(';
  for I := 0 to ParameterCount - 1 do
  begin
    if (I > 0) then Result := Result + ',';
    if (Parameter[I].ParameterType <> ptIn) then
      Result := Result + '@' + ObjectIDEParameterName + Parameter[I].Name
    else if (InputDataSet.Fields[I].Value = Null) then
      Result := Result + 'NULL'
    else
      Result := Result + Parameter[I].EscapeValue(InputDataSet.Fields[I].Value);
  end;
  Result := Result + ');' + #13#10;

  if (OutParameters) then
  begin
    Result := Result + 'SELECT ';
    for I := 0 to ParameterCount - 1 do
    begin
      if (I > 0) then Result := Result + ',';
      if (Parameter[I].ParameterType = ptIn) then
        Result := Result + SQLEscape(InParameterCaption)
      else
        Result := Result + '@' + ObjectIDEParameterName + Parameter[I].Name;
      Result := Result + ' AS ' + Database.Client.EscapeIdentifier(Parameter[I].Name);
    end;
    Result := Result + ';' + #13#10;
  end;
end;

{ TCFunction ******************************************************************}

procedure TCFunction.SetSource(const ADataSet: TMySQLQuery);
begin
  SetSource(ADataSet.FieldByName('Create Function'));

  Client.ExecuteEvent(ceUpdated, Self, Self, Database);
end;

function TCFunction.SQLGetSource(): string;
begin
  Result := 'SHOW CREATE FUNCTION ' + Database.Client.EscapeIdentifier(Database.Name) + '.' + Database.Client.EscapeIdentifier(Name) + ';' + #13#10
end;

function TCFunction.SQLRun(): string;
var
  I: Integer;
begin
  Result := 'SELECT ' + Database.Client.EscapeIdentifier(Database.Name) + '.' + Database.Client.EscapeIdentifier(Name) + '(';
  for I := 0 to ParameterCount - 1 do
  begin
    if (I > 0) then Result := Result + ',';
    if (InputDataSet.Fields[I].Value = Null) then
      Result := Result + 'NULL'
    else
      Result := Result + Parameter[I].EscapeValue(InputDataSet.Fields[I].Value);
  end;
  Result := Result + ');';
end;

{ TCRoutines ******************************************************************}

procedure TCRoutines.AddRoutine(const NewRoutine: TCRoutine);
begin
  if (NewRoutine is TCProcedure) then
  begin
    Add(TCProcedure.Create(Database));
    TCProcedure(Items[TList(Self).Count - 1]).Assign(TCProcedure(NewRoutine));
  end
  else
  begin
    Add(TCFunction.Create(Database));
    TCFunction(Items[TList(Self).Count - 1]).Assign(TCFunction(NewRoutine));
  end;
end;

procedure TCRoutines.Assign(const Source: TCRoutines);
var
  I: Integer;
begin
  Clear();

  for I := 0 to Source.Count - 1 do
    AddRoutine(Source.Routine[I]);
  FActual := Source.Actual;
end;

function TCRoutines.Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean;
var
  Index: Integer;
  RoutineName: string;
  RoutineType: TCRoutine.TRoutineType;
  Update: Boolean;
begin
  Update := False; Index := -1;

  if (not DataSet.IsEmpty()) then
    repeat
      RoutineType := rtUnknown;
      if (not UseInformationSchema) then
      begin
        RoutineName := DataSet.FieldByName('Name').AsString;
        if (UpperCase(DataSet.FieldByName('Type').AsString) = 'PROCEDURE') then
          RoutineType := rtProcedure
        else if (UpperCase(DataSet.FieldByName('Type').AsString) = 'FUNCTION') then
          RoutineType := rtFunction;
      end
      else if (DataSet.FieldByName('ROUTINE_SCHEMA').AsString = Database.Name) then
      begin
        RoutineName := DataSet.FieldByName('ROUTINE_NAME').AsString;
        if (UpperCase(DataSet.FieldByName('ROUTINE_TYPE').AsString) = 'PROCEDURE') then
          RoutineType := rtProcedure
        else if (UpperCase(DataSet.FieldByName('ROUTINE_TYPE').AsString) = 'FUNCTION') then
          RoutineType := rtFunction;
      end;

      if (RoutineType <> rtUnknown) then
      begin
        Index := IndexByName(RoutineName);
        Update := Index >= 0;

        if (not Update) then
          if (RoutineType = rtProcedure) then
            Index := Add(TCProcedure.Create(Database, RoutineName))
          else
            Index := Add(TCFunction.Create(Database, RoutineName));

        if (not UseInformationSchema) then
        begin
          Routine[Index].FComment := DataSet.FieldByName('Comment').AsString;
          if (DataSet.FieldByName('Security_type').AsString = 'INVOKER') then
            Routine[Index].FSecurity := seInvoker
          else
            Routine[Index].FSecurity := seDefiner;
          Routine[Index].FCreated := DataSet.FieldByName('Created').AsDateTime;
          Routine[Index].FDefiner := DataSet.FieldByName('Definer').AsString;
          Routine[Index].FModified := DataSet.FieldByName('Modified').AsDateTime;
          Routine[Index].FRoutineType := RoutineType;
        end
        else
        begin
          Routine[Index].FComment := DataSet.FieldByName('ROUTINE_COMMENT').AsString;
          if (DataSet.FieldByName('SECURITY_TYPE').AsString = 'INVOKER') then
            Routine[Index].FSecurity := seInvoker
          else
            Routine[Index].FSecurity := seDefiner;
          Routine[Index].FCreated := DataSet.FieldByName('CREATED').AsDateTime;
          Routine[Index].FDefiner := DataSet.FieldByName('DEFINER').AsString;
          Routine[Index].FModified := DataSet.FieldByName('LAST_ALTERED').AsDateTime;
          Routine[Index].FRoutineType := RoutineType;
        end;
      end;
    until (not DataSet.FindNext());

  Result := inherited;

  if ((DataSet.RecordCount = 1) and Update) then
    Client.ExecuteEvent(ceUpdated, Self, Routine[Index], Database)
  else
    Client.ExecuteEvent(ceBuild, Self, nil, Database);
end;

constructor TCRoutines.Create(const ADatabase: TCDatabase);
begin
  inherited Create(ADatabase);

  Clear();
end;

function TCRoutines.GetRoutine(Index: Integer): TCRoutine;
begin
  Result := TCRoutine(Items[Index]);
end;

function TCRoutines.SQLGetItems(const Name: string = ''): string;
begin
  if (not Client.UseInformationSchema) then
  begin
    Result := 'SHOW PROCEDURE STATUS WHERE Db=' + SQLEscape(Database.Name) + ';' + #13#10;
    Result := Result + 'SHOW FUNCTION STATUS WHERE Db=' + SQLEscape(Database.Name) + ';' + #13#10;
  end
  else
  begin
    Result := 'SELECT * FROM ' + Database.Client.EscapeIdentifier(information_schema) + '.' + Database.Client.EscapeIdentifier('ROUTINES');
    Result := Result + ' WHERE ' + Database.Client.EscapeIdentifier('ROUTINE_SCHEMA') + '=' + SQLEscape(Database.Name);
    Result := Result + ';' + #13#10;
  end;
end;

{ TCTrigger *******************************************************************}

procedure TCTrigger.Assign(const Source: TCTrigger);
begin
  inherited Assign(Source);

  if (Assigned(Source.FDatabase)) then FDatabase := Source.FDatabase;

  FEvent := Source.Event;
  FDatabase := Source.Database;
  FDefiner := Source.Definer;
  FStatement := Source.Statement;
  OldSource := Source.OldSource;
  FTableName := Source.FTableName;
  FTiming := Source.Timing;
end;

procedure TCTrigger.Clear();
begin
  inherited;

  FActual := False;
  FEvent := teInsert;
  FCreated := 0;
  FDefiner := '';
  OldSource := '';
  FStatement := '';
  FTiming := ttAfter;
end;

constructor TCTrigger.Create(const ADatabase: TCDatabase; const AName: string = '');
begin
  inherited Create(ADatabase, AName);

  FSynMemo := nil;
end;

destructor TCTrigger.Destroy();
begin
  if (Assigned(FInputDataSet)) then
  begin
    FInputDataSet.Cancel();
    FreeAndNil(FInputDataSet);
  end;
  if (Assigned(FSynMemo)) then
    FreeAndNil(FSynMemo);

  inherited;
end;

function TCTrigger.GetInputDataSet(): TMySQLDataSet;
begin
  if (not Assigned(FInputDataSet)) then
  begin
    FInputDataSet := TMySQLDataSet.Create(nil);
    FInputDataSet.Connection := Database.Client;
    FInputDataSet.CommandText := 'SELECT * FROM ' + Database.Client.EscapeIdentifier(Database.Name) + '.' + Database.Client.EscapeIdentifier(FTableName) + ' LIMIT 0';
    FInputDataSet.Open();
    if (FInputDataSet.Active) then
      FreeAndNil(FInputDataSet)
    else
      FInputDataSet.CachedUpdates := True;
  end;

  Result := FInputDataSet;
end;

function TCTrigger.GetSourceEx(const DropBeforeCreate: Boolean = False; const EncloseDefiner: Boolean = True; const ForeignKeysSource: PString = nil): string;
begin
  Result := '';

  if (DropBeforeCreate) then
    Result := Result + 'DROP TRIGGER IF EXISTS ' + Database.Client.EscapeIdentifier(Database.Name) + '.' + Database.Client.EscapeIdentifier(Name) + ';' + #13#10;

  Result := Result + 'CREATE';
  if (Definer <> '') then
    Result := Result + ' DEFINER=' + Database.Client.EscapeUser(Definer, True);
  Result := Result + ' TRIGGER ' + Database.Client.EscapeIdentifier(Database.Name) + '.' + Database.Client.EscapeIdentifier(Name) + ' ';
  case (Timing) of
    ttBefore: Result := Result + 'BEFORE';
    ttAfter: Result := Result + 'AFTER';
  end;
  Result := Result + ' ';
  case (Event) of
    teInsert: Result := Result + 'INSERT';
    teUpdate: Result := Result + 'UPDATE';
    teDelete: Result := Result + 'DELETE';
  end;
  Result := Result + ' ON ';
  Result := Result + Database.Client.EscapeIdentifier(Database.Name) + '.' + Database.Client.EscapeIdentifier(FTableName) + #13#10;
  Result := Result + '  FOR EACH ROW ' + Statement;
  if (RightStr(Result, 1) <> ';') then Result := Result + ';';
  Result := Result + #13#10;
end;

function TCTrigger.GetTable(): TCBaseTable;
begin
  Result := Database.BaseTableByName(FTableName);
end;

function TCTrigger.Initialize(): Boolean;
begin
  Result := Database.Initialize(Self);
end;

procedure TCTrigger.SetSource(const ADataSet: TMySQLQuery);
begin
  SetSource(ADataSet.FieldByName('SQL Original Statement'));

  Client.ExecuteEvent(ceUpdated, Self, Self, Database);
end;

function TCTrigger.SQLDelete(): string;
begin
  InputDataSet.SQLDelete();
end;

function TCTrigger.SQLGetSource(): string;
begin
  Result := 'SHOW CREATE TRIGGER ' + Database.Client.EscapeIdentifier(Database.Name) + '.' + Database.Client.EscapeIdentifier(Name) + ';' + #13#10
end;

function TCTrigger.SQLInsert(): string;
begin
  Result := InputDataSet.SQLInsert();
end;

function TCTrigger.SQLReplace(): string;
begin
  Result := SQLInsert();
  Result := 'REPLACE ' + RightStr(Result, Length(Result) - Length('INSERT'));
end;

function TCTrigger.SQLUpdate(): string;
var
  I: Integer;
begin
  Result := 'UPDATE ' + Database.Client.EscapeIdentifier(Database.Name) + '.' + Database.Client.EscapeIdentifier(FTableName);
  Result := Result + ' SET ';
  for I := 0 to InputDataSet.FieldCount - 1 do
  begin
    if (I > 0) then Result := Result + ',';
    Result := Result + Database.Client.EscapeIdentifier(InputDataSet.Fields[I].FieldName);
    Result := Result + '=' + InputDataSet.SQLFieldValue(InputDataSet.Fields[I]);
  end;
  Result := Result + ' WHERE ';
  for I := 0 to InputDataSet.FieldCount - 1 do
  begin
    if (I > 0) then Result := Result + ' AND ';
    Result := Result + Database.Client.EscapeIdentifier(InputDataSet.Fields[I].FieldName);
    Result := Result + '=' + InputDataSet.SQLFieldValue(InputDataSet.Fields[I]);
  end;
  Result := Result + ';' + #13#10;
end;

{ TCTriggers ******************************************************************}

function TCTriggers.Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean;
var
  Index: Integer;
  TriggerName: string;
  Update: Boolean;
begin
  Update := False; Index := -1;

  if (not DataSet.IsEmpty()) then
    repeat
      if (not UseInformationSchema) then
        TriggerName := DataSet.FieldByName('Name').AsString
      else if (DataSet.FieldByName('TRIGGER_SCHEMA').AsString = Database.Name) then
        TriggerName := DataSet.FieldByName('TRIGGER_NAME').AsString
      else
        raise ERangeError.CreateFmt(SPropertyOutOfRange, ['TriggerName']);

      Index := IndexByName(TriggerName);
      Update := Index >= 0;

      if (not Update) then
        Index := Add(TCTrigger.Create(Database, TriggerName));

      if (not UseInformationSchema) then
      begin
        if (UpperCase(DataSet.FieldByName('Event').AsString) = 'INSERT') then
          Trigger[Index].FEvent := teInsert
        else if (UpperCase(DataSet.FieldByName('Event').AsString) = 'UPDATE') then
          Trigger[Index].FEvent := teUpdate
        else if (UpperCase(DataSet.FieldByName('Event').AsString) = 'DELETE') then
          Trigger[Index].FEvent := teDelete;
        if (not Assigned(DataSet.FindField('Definer'))) then
          Trigger[Index].FDefiner := ''
        else
          Trigger[Index].FDefiner := DataSet.FieldByName('Definer').AsString;
        Trigger[Index].FStatement := DataSet.FieldByName('Statement').AsString + ';';
        Trigger[Index].FTableName := DataSet.FieldByName('Table').AsString;
        if (UpperCase(DataSet.FieldByName('Timing').AsString) = 'BEFORE') then
          Trigger[Index].FTiming := ttBefore
        else if (UpperCase(DataSet.FieldByName('Timing').AsString) = 'AFTER') then
          Trigger[Index].FTiming := ttAfter;
      end
      else
      begin
        if (UpperCase(DataSet.FieldByName('EVENT_MANIPULATION').AsString) = 'INSERT') then
          Trigger[Index].FEvent := teInsert
        else if (UpperCase(DataSet.FieldByName('EVENT_MANIPULATION').AsString) = 'UPDATE') then
          Trigger[Index].FEvent := teUpdate
        else if (UpperCase(DataSet.FieldByName('EVENT_MANIPULATION').AsString) = 'DELETE') then
          Trigger[Index].FEvent := teDelete;
        Trigger[Index].FName := DataSet.FieldByName('TRIGGER_NAME').AsString;
        if (not Assigned(DataSet.FindField('DEFINER'))) then
          Trigger[Index].FDefiner := ''
        else
          Trigger[Index].FDefiner := DataSet.FieldByName('DEFINER').AsString;
        Trigger[Index].FStatement := DataSet.FieldByName('ACTION_STATEMENT').AsString + ';';
        Trigger[Index].FTableName := DataSet.FieldByName('EVENT_OBJECT_TABLE').AsString;
        if (UpperCase(DataSet.FieldByName('ACTION_TIMING').AsString) = 'BEFORE') then
          Trigger[Index].FTiming := ttBefore
        else if (UpperCase(DataSet.FieldByName('ACTION_TIMING').AsString) = 'AFTER') then
          Trigger[Index].FTiming := ttAfter;
      end;
      Trigger[Index].FActual := True;

      if (Database.Client.ServerVersion < 50121) then
        Trigger[Index].FSource := Trigger[Index].GetSourceEx();
    until (not DataSet.FindNext());

  Result := inherited;

  if ((DataSet.RecordCount = 1) and Update) then
    Client.ExecuteEvent(ceUpdated, Self, Trigger[Index], Database)
  else
    Client.ExecuteEvent(ceBuild, Self, nil, Database);
end;

constructor TCTriggers.Create(const ADatabase: TCDatabase);
begin
  inherited Create(ADatabase);

  Clear();
end;

function TCTriggers.GetTrigger(Index: Integer): TCTrigger;
begin
  Result := TCTrigger(Items[Index]);
end;

function TCTriggers.SQLGetItems(const Name: string = ''): string;
begin
  if (not Client.UseInformationSchema) then
  begin
    Result := 'SHOW TRIGGERS FROM ' + Database.Client.EscapeIdentifier(Database.Name);
    if (Name <> '') then
      Result := Result + ' AND ' + Client.EscapeIdentifier('Name') + '=' + SQLEscape(Name);
    Result := Result + ';' + #13#10;
  end
  else
  begin
    Result := 'SELECT * FROM ' + Database.Client.EscapeIdentifier(information_schema) + '.' + Database.Client.EscapeIdentifier('TRIGGERS');
    Result := Result + ' WHERE ' + Database.Client.EscapeIdentifier('EVENT_OBJECT_SCHEMA') + '=' + SQLEscape(Database.Name);
    if (Name <> '') then
      Result := Result + ' AND ' + Client.EscapeIdentifier('TRIGGER_NAME') + '=' + SQLEscape(Name);
    Result := Result + ';' + #13#10;
  end;
end;

{ TCEvent *********************************************************************}

procedure TCEvent.Assign(const Source: TCEvent);
begin
  inherited Assign(Source);

  if (Assigned(Source.FDatabase)) then FDatabase := Source.FDatabase;

  FCreated := Source.Created;
  FComment := Source.Comment;
  FDefiner := Source.Definer;
  FEnabled := Source.Enabled;
  FEndDateTime := Source.EndDateTime;
  FEventType := Source.EventType;
  FExecute := Source.Execute;
  FIntervalType := Source.IntervalType;
  FIntervalValue := Source.IntervalValue;
  FPreserve := Source.Preserve;
  FStartDateTime := Source.StartDateTime;
  FStatement := Source.Statement;
  FUpdated := Source.Updated;
end;

procedure TCEvent.Clear();
begin
  FCreated := 0;
  FComment := '';
  FDefiner := '';
  FEnabled := True;
  FEndDateTime := 0;
  FEventType := etUnknown;
  FExecute := 0;
  FIntervalType := itUnknown;
  FIntervalValue := '';
  FPreserve := False;
  FStartDateTime := 0;
  FStatement := '';
  FUpdated := 0;

  inherited;
end;

constructor TCEvent.Create(const ADatabase: TCDatabase; const AName: string = '');
begin
  inherited;

  FCreated := 0;
  FComment := '';
  FDefiner := '';
  FEnabled := True;
  FEndDateTime := 0;
  FEventType := etUnknown;
  FExecute := 0;
  FIntervalType := itUnknown;
  FIntervalValue := '';
  FPreserve := False;
  FStartDateTime := 0;
  FStatement := '';
  FUpdated := 0;
end;

function TCEvent.GetSourceEx(const DropBeforeCreate: Boolean = False; const EncloseDefiner: Boolean = True; const ForeignKeysSource: PString = nil): string;
begin
  Result := '';

  if (DropBeforeCreate) then
    Result := Result + 'DROP EVENT IF EXISTS ' + Database.Client.EscapeIdentifier(Database.Name) + '.' + Database.Client.EscapeIdentifier(Name) + ';' + #13#10;

  Result := Result + Source + #13#10;
end;

function TCEvent.Initialize(): Boolean;
begin
  Result := Database.InitializeSources(Self);
end;

procedure TCEvent.ParseCreateEvent(const SQL: string);
var
  Parse: TSQLParse;
begin
  if (not SQLCreateParse(Parse, PChar(SQL), Length(SQL), Database.Client.ServerVersion)) then
    raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 34, SQL])
  else
  begin
    if (not SQLParseKeyword(Parse, 'CREATE')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 35, SQL]);

    if (SQLParseKeyword(Parse, 'DEFINER')) then
    begin
      if (not SQLParseChar(Parse, '=')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 36, SQL]);
      FDefiner := SQLParseValue(Parse);
    end;

    if (not SQLParseKeyword(Parse, 'EVENT')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 37, SQL]);

    FName := SQLParseValue(Parse);
    if (SQLParseChar(Parse, '.')) then
    begin
      if (Database.Client.TableNameCmp(Database.Name, FName) = 0) then
        raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + FName, 38, SQL]);
      FName := SQLParseValue(Parse);
    end;

    if (not SQLParseKeyword(Parse, 'ON SCHEDULE')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 39, SQL]);

    if (SQLParseKeyword(Parse, 'AT')) then
    begin
      FExecute := MySQLDB.StrToDateTime(SQLParseValue(Parse), Database.Client.FormatSettings);
      if (SQLParseChar(Parse, '+') and SQLParseKeyword(Parse, 'INTERVAL')) then
      begin
        FIntervalValue := SQLParseValue(Parse);
        FIntervalType := StrToIntervalType(SQLParseValue(Parse));
      end;
    end
    else if (SQLParseKeyword(Parse, 'EVERY')) then
    begin
      FIntervalValue := SQLParseValue(Parse);
      FIntervalType := StrToIntervalType(SQLParseValue(Parse));
      if (SQLParseKeyword(Parse, 'STARTS')) then
        FStartDateTime := MySQLDB.StrToDateTime(SQLParseValue(Parse), Database.Client.FormatSettings);
      if (SQLParseKeyword(Parse, 'ENDS')) then
        FEndDateTime := MySQLDB.StrToDateTime(SQLParseValue(Parse), Database.Client.FormatSettings);
    end
    else
      raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 40, SQL]);

    FPreserve := SQLParseKeyword(Parse, 'ON COMPLETION PRESERVE') or not SQLParseKeyword(Parse, 'ON COMPLETION NOT PRESERVE');

    FEnabled := SQLParseKeyword(Parse, 'ENABLE');
    if (not FEnabled and SQLParseKeyword(Parse, 'DISABLE')) then
      SQLParseKeyword(Parse, 'ON SLAVE');

    if (SQLParseKeyword(Parse, 'COMMENT')) then
      FComment := SQLParseValue(Parse);

    if (not SQLParseKeyword(Parse, 'DO')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, 41, SQL]);

    FStatement := RightStr(SQL, Length(SQL) - SQLParseGetIndex(Parse));
  end;
end;

procedure TCEvent.SetSource(const ADataSet: TMySQLQuery);
begin
  SetSource(ADataSet.FieldByName('Create Event'));

  Client.ExecuteEvent(ceUpdated, Self, Self, Database);
end;

procedure TCEvent.SetSource(const ASource: string);
begin
  inherited;

  ParseCreateEvent(FSource);
end;

function TCEvent.SQLGetSource(): string;
begin
  Result := 'SHOW CREATE EVENT ' + Database.Client.EscapeIdentifier(Database.Name) + '.' + Database.Client.EscapeIdentifier(Name) + ';' + #13#10
end;

function TCEvent.SQLRun(): string;
const
  ObjectIDEEventProcedureName = 'MySQL_Front_Object_IDE_Event';
begin
  Result := 'DROP PROCEDURE IF EXISTS ' + Database.Client.EscapeIdentifier(Database.Name) + '.' + Database.Client.EscapeIdentifier(ObjectIDEEventProcedureName) + ';' + #13#10;
  Result := Result + 'CREATE PROCEDURE ' + Database.Client.EscapeIdentifier(Database.Name) + '.' + Database.Client.EscapeIdentifier(ObjectIDEEventProcedureName) + '()' + #13#10;
  Result := Result + Statement + #13#10;
  Result := Result + 'CALL ' + Database.Client.EscapeIdentifier(Database.Name) + '.' + Database.Client.EscapeIdentifier(ObjectIDEEventProcedureName) + '();' + #13#10;
  Result := Result + 'DROP PROCEDURE ' + Database.Client.EscapeIdentifier(Database.Name) + '.' + Database.Client.EscapeIdentifier(ObjectIDEEventProcedureName) + ';' + #13#10;
end;

{ TCEvents ********************************************************************}

function TCEvents.Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean;
var
  EventName: string;
  Index: Integer;
  Update: Boolean;
begin
  Update := False; Index := -1;

  if (not DataSet.IsEmpty()) then
    repeat
      if ((not UseInformationSchema and (DataSet.FieldByName('Db').AsString = Database.Name))
        or (UseInformationSchema and (DataSet.FieldByName('EVENT_SCHEMA').AsString = Database.Name))) then
      begin
        if (not UseInformationSchema) then
          EventName := DataSet.FieldByName('Name').AsString
        else
          EventName := DataSet.FieldByName('EVENT_NAME').AsString;

        Index := IndexByName(EventName);
        Update := Index >= 0;

        if (not Update) then
          Index := Add(TCEvent.Create(Database, EventName));

        if (not UseInformationSchema) then
        begin
//          Event[Index].FCreated := DataSet.FieldByName('CREATED').AsDateTime;
//          Event[Index].FComment := DataSet.FieldByName('EVENT_COMMENT').AsString;
          Event[Index].FDefiner := DataSet.FieldByName('Definer').AsString;
          Event[Index].FEnabled := DataSet.FieldByName('Status').AsString = 'ENABLED';
          Event[Index].FEndDateTime := DataSet.FieldByName('Ends').AsDateTime;
          Event[Index].FEventType := StrToEventType(DataSet.FieldByName('Type').AsString);
          Event[Index].FExecute := DataSet.FieldByName('Execute at').AsDateTime;
          Event[Index].FIntervalType := StrToIntervalType(DataSet.FieldByName('Interval field').AsString);
          Event[Index].FIntervalValue := DataSet.FieldByName('Interval value').AsString;
//          Event[Index].FPreserve := DataSet.FieldByName('ON_COMPLETION').AsString = 'PRESERVE';
          Event[Index].FStartDateTime := DataSet.FieldByName('Starts').AsDateTime;
//          Event[Index].FStatement := Trim(SQLTrim(DataSet.FieldByName('EVENT_DEFINITION').AsString));
//          Event[Index].FUpdated := DataSet.FieldByName('LAST_ALTERED').AsDateTime;
        end
        else
        begin
          Event[Index].FCreated := DataSet.FieldByName('CREATED').AsDateTime;
          Event[Index].FComment := DataSet.FieldByName('EVENT_COMMENT').AsString;
          Event[Index].FDefiner := DataSet.FieldByName('DEFINER').AsString;
          Event[Index].FEnabled := DataSet.FieldByName('STATUS').AsString = 'ENABLED';
          Event[Index].FEndDateTime := DataSet.FieldByName('ENDS').AsDateTime;
          Event[Index].FEventType := StrToEventType(DataSet.FieldByName('EVENT_TYPE').AsString);
          Event[Index].FExecute := DataSet.FieldByName('EXECUTE_AT').AsDateTime;
          Event[Index].FIntervalType := StrToIntervalType(DataSet.FieldByName('INTERVAL_FIELD').AsString);
          Event[Index].FIntervalValue := DataSet.FieldByName('INTERVAL_VALUE').AsString;
          Event[Index].FPreserve := DataSet.FieldByName('ON_COMPLETION').AsString = 'PRESERVE';
          Event[Index].FStartDateTime := DataSet.FieldByName('STARTS').AsDateTime;
          Event[Index].FStatement := SQLTrimStmt(DataSet.FieldByName('EVENT_DEFINITION').AsString);
          Event[Index].FUpdated := DataSet.FieldByName('LAST_ALTERED').AsDateTime;
        end;

        if (Copy(Event[Index].Statement, Length(Event[Index].Statement), 1) <> ';') then Event[Index].Statement := Event[Index].Statement + ';';
      end;
    until (not DataSet.FindNext());

  Result := inherited;

  if ((DataSet.RecordCount = 1) and Update) then
    Client.ExecuteEvent(ceUpdated, Self, Event[Index], Database)
  else
    Client.ExecuteEvent(ceBuild, Self, nil, Database);
end;

constructor TCEvents.Create(const ADatabase: TCDatabase);
begin
  inherited Create(ADatabase);

  FActual := False;
end;

function TCEvents.GetEvent(Index: Integer): TCEvent;
begin
  Result := TCEvent(Items[Index]);
end;

function TCEvents.SQLGetItems(const Name: string = ''): string;
begin
  if (not Client.UseInformationSchema) then
  begin
    Result := 'SHOW EVENTS FROM ' + Database.Client.EscapeIdentifier(Database.Name) + ';' + #13#10
  end
  else
  begin
    Result := 'SELECT * FROM ' + Database.Client.EscapeIdentifier(information_schema) + '.' + Database.Client.EscapeIdentifier('EVENTS');
    Result := Result + ' WHERE ' + Database.Client.EscapeIdentifier('EVENT_SCHEMA') + '=' + SQLEscape(Database.Name);
    Result := Result + ';' + #13#10;
  end;
end;

{ TCDatabase ******************************************************************}

function TCDatabase.AddEvent(const NewEvent: TCEvent): Boolean;
begin
  Result := UpdateEvent(nil, NewEvent);
end;

function TCDatabase.AddRoutine(const NewRoutine: TCRoutine): Boolean;
begin
  Result := UpdateRoutine(nil, NewRoutine);
end;

function TCDatabase.AddTable(const NewTable: TCBaseTable): Boolean;
begin
  NewTable.FForeignKeys.Actual := True;
  NewTable.FActual := True;
  Result := UpdateTable(nil, NewTable);
end;

function TCDatabase.AddView(const NewView: TCView): Boolean;
begin
  Result := UpdateView(nil, NewView);
end;

function TCDatabase.AddTrigger(const NewTrigger: TCTrigger): Boolean;
begin
  NewTrigger.FDatabase := Self;
  Result := UpdateTrigger(nil, NewTrigger);
end;

procedure TCDatabase.Assign(const Source: TCDatabase);
begin
  inherited Assign(Source);

  if (Assigned(Tables)) then
    Tables.Clear();
  if (Assigned(Routines)) then
    Routines.Clear();
  if (Assigned(Triggers)) then
    Triggers.Clear();
  if (Assigned(Events)) then
    Events.Clear();

  if (Assigned(Source.FClient)) then FClient := Source.FClient;

  DefaultCharset := Source.DefaultCharset;
  FCollation := Source.FCollation;
end;

function TCDatabase.BaseTableByName(const TableName: string): TCBaseTable;
var
  Index: Integer;
begin
  Index := Tables.IndexByName(TableName);
  if ((Index < 0) or not (Tables[Index] is TCBaseTable)) then
    Result := nil
  else
    Result := TCBaseTable(Tables[Index]);
end;

function TCDatabase.Build(const DataSet: TMySQLQuery): Boolean;
var
  Field: TField;
begin
  if (not DataSet.IsEmpty()) then
  begin
    Field := DataSet.FieldByName('Create Database');
    if (Field.DataType <> ftBlob) then
      FSource := Field.AsString
    else if (Length(Field.AsBytes) = 0) then
      FSource := ''
    else
      FSource := Client.LibDecode(my_char(@Field.AsBytes[0]));
    FSource := Trim(ReplaceStr(ReplaceStr(FSource, #10, #13#10), #13#13#10, #13#10));
    if (FSource <> '') then
      FSource := FSource + ';';
  end;

  Result := False;
end;

procedure TCDatabase.Clear();
begin
  inherited;

  FDefaultCharset := '';
  FDefaultCodePage := CP_ACP;
  FCollation := '';

  if (Assigned(Tables)) then
    Tables.Clear();
  if (Assigned(Routines)) then
    Routines.Clear();
  if (Assigned(Triggers)) then
    Triggers.Clear();
  if (Assigned(Events)) then
    Events.Clear();
end;

function TCDatabase.CloneRoutine(const Routine: TCRoutine; const NewRoutineName: string): Boolean;
var
  DatabaseName: string;
  Parse: TSQLParse;
  RoutineName: string;
  SQL: string;
begin
  Result := SQLCreateParse(Parse, PChar(Routine.Source), Length(Routine.Source), Client.ServerVersion);
  if (Result) then
  begin
    if (not SQLParseKeyword(Parse, 'CREATE')) then raise EConvertError.CreateFmt(SSourceParseError, [Name + '.' + Routine.Name, 42, SQL]);

    if (SQLParseKeyword(Parse, 'DEFINER')) then
    begin
      if (not SQLParseChar(Parse, '=')) then raise EConvertError.CreateFmt(SSourceParseError, [Name, 43, SQL]);
      SQLParseValue(Parse);
    end;

    if (not SQLParseKeyword(Parse, 'PROCEDURE') and not SQLParseKeyword(Parse, 'FUNCTION')) then
      raise EConvertError.CreateFmt(SSourceParseError, [Name + '.' + Routine.Name, 44, SQL]);

    SQL := LeftStr(Routine.Source, SQLParseGetIndex(Parse));

    RoutineName := SQLParseValue(Parse);
    if (not SQLParseChar(Parse, '.')) then
      DatabaseName := Name
    else
    begin
      DatabaseName := RoutineName;
      RoutineName := SQLParseValue(Parse);
    end;

    SQL := SQL + Client.EscapeIdentifier(Name) + '.' + Client.EscapeIdentifier(NewRoutineName);
    SQL := SQL + RightStr(Routine.Source, Length(Routine.Source) - SQLParseGetIndex(Parse));
    SQL := SQL + #13#10;

    case (Routine.RoutineType) of
      rtProcedure:
        if (Assigned(ProcedureByName(NewRoutineName))) then
          SQL := 'DROP PROCEDURE ' + Client.EscapeIdentifier(Name) + '.' + Client.EscapeIdentifier(Routine.Name) + ';' + #13#10;
      rtFunction:
        if (Assigned(FunctionByName(NewRoutineName))) then
          SQL := 'DROP FUNCTION ' + Client.EscapeIdentifier(Name) + '.' + Client.EscapeIdentifier(Routine.Name) + ';' + #13#10;
      else
        raise Exception.CreateFMT(SUnknownRoutineType, [Name]);
    end;

    Result := Client.ExecuteSQL(SQL);

    if (Result) then
      Routines.Clear();
  end;
end;

function TCDatabase.CloneTable(const Table: TCBaseTable; const NewTableName: string; const Data: Boolean): Boolean;
var
  NewTable: TCBaseTable;
  SQL: string;
begin
  Result := Assigned(Table);

  if (Result) then
  begin
    NewTable := TCBaseTable.Create(Self);
    NewTable.Assign(Table);
    NewTable.Name := NewTableName;
    if (not Data) then
      NewTable.AutoIncrement := 0;
    SQL := Trim(SQLAlterTable(nil, NewTable, not Data or (Client.ServerVersion >= 40100)));
    NewTable.Free();

    if (Data) then
      Insert(' SELECT * FROM ' + Client.EscapeIdentifier(Table.Database.Name) + '.' + Client.EscapeIdentifier(Table.Name), SQL, Length(SQL));

    if (Assigned(TableByName(NewTableName))) then
      if (TableByName(NewTableName) is TCBaseTable) then
        SQL := 'DROP TABLE ' + Client.EscapeIdentifier(NewTableName) + ';' + #13#10 + SQL
      else
        SQL := 'DROP VIEW ' + Client.EscapeIdentifier(NewTableName) + ';' + #13#10 + SQL;

    Result := Client.ExecuteSQL(SQL);
  end;

  if (Result) then
    if ((Client.ServerVersion < 40100) and Assigned(Table.AutoIncrementField)) then
    begin
      NewTable := TCBaseTable.Create(Self);
      NewTable.Assign(BaseTableByName(NewTableName));
      NewTable.FieldByName(Table.AutoIncrementField.Name).AutoIncrement := True;
      Result := UpdateTable(BaseTableByName(NewTableName), NewTable);
      NewTable.Free();
    end;
end;

function TCDatabase.CloneView(const View: TCView; const NewViewName: string): Boolean;
var
  SQL: string;
begin
  SQL := ReplaceStr(View.GetSourceEx(), 'VIEW ' + Client.EscapeIdentifier(View.Name), 'VIEW ' + Client.EscapeIdentifier(Name) + '.' + Client.EscapeIdentifier(NewViewName));

  if (Assigned(TableByName(NewViewName))) then
    if (TableByName(NewViewName) is TCBaseTable) then
      SQL := 'DROP TABLE ' + Client.EscapeIdentifier(NewViewName) + ';' + #13#10 + SQL
    else
      SQL := 'DROP VIEW ' + Client.EscapeIdentifier(NewViewName) + ';' + #13#10 + SQL;

  if (Client.DatabaseName <> Name) then
    SQL := SQLUse() + SQL;

  Result := Client.ExecuteSQL(SQL);
end;

constructor TCDatabase.Create(const AClient: TCClient = nil; const AName: string = '');
begin
  inherited Create(AClient);

  FDesktopXML := nil;
  FWorkbench := nil;
  FName := AName;

  if ((Client.ServerVersion < 50004) or (Self is TCSystemDatabase)) then FRoutines := nil else FRoutines := TCRoutines.Create(Self);
  FTables := TCTables.Create(Self);
  if ((Client.ServerVersion < 50010) or (Self is TCSystemDatabase)) then FTriggers := nil else FTriggers := TCTriggers.Create(Self);
  if ((Client.ServerVersion < 50106) or (Self is TCSystemDatabase)) then FEvents := nil else FEvents := TCEvents.Create(Self);
end;

function TCDatabase.DeleteObjects(const Objects: array of TCDBObject): Boolean;
var
  I: Integer;
  Identifiers: string;
  SQL: string;
begin
  SQL := '';

  Identifiers := '';
  for I := 0 to Length(Objects) - 1 do
    if (Objects[I] is TCBaseTable) then
    begin
      if (Identifiers <> '') then Identifiers := Identifiers + ',';
      Identifiers := Identifiers + Client.EscapeIdentifier(Name) + '.' + Client.EscapeIdentifier(Objects[I].Name);
    end;
  if (Identifiers <> '') then
    SQL := SQL + 'DROP TABLE ' + Identifiers + ';' + #13#10;

  Identifiers := '';
  for I := 0 to Length(Objects) - 1 do
    if (Objects[I] is TCView) then
    begin
      if (Identifiers <> '') then Identifiers := Identifiers + ',';
      Identifiers := Identifiers + Client.EscapeIdentifier(Name) + '.' + Client.EscapeIdentifier(Objects[I].Name);
    end;
  if (Identifiers <> '') then
    SQL := SQL + 'DROP VIEW ' + Identifiers + ';' + #13#10;

  for I := 0 to Length(Objects) - 1 do
    if (Objects[I] is TCProcedure) then
      SQL := SQL + 'DROP PROCEDURE ' + Client.EscapeIdentifier(Name) + '.' + Client.EscapeIdentifier(Objects[I].Name) + ';' + #13#10
    else if (Objects[I] is TCFunction) then
      SQL := SQL + 'DROP FUNCTION ' + Client.EscapeIdentifier(Name) + '.' + Client.EscapeIdentifier(Objects[I].Name) + ';' + #13#10
    else if (Objects[I] is TCTrigger) then
      SQL := SQL + 'DROP TRIGGER ' + Client.EscapeIdentifier(Name) + '.' + Client.EscapeIdentifier(Objects[I].Name) + ';' + #13#10
    else if (Objects[I] is TCEvent) then
      SQL := SQL + 'DROP EVENT ' + Client.EscapeIdentifier(Name) + '.' + Client.EscapeIdentifier(Objects[I].Name) + ';' + #13#10;

  if (Name <> Client.DatabaseName) then
    SQL := SQLUse() + SQL;

  Result := Client.ExecuteSQL(SQL);
end;

destructor TCDatabase.Destroy();
begin
  if (Assigned(FRoutines)) then FRoutines.Free();
  FTables.Free();
  if (Assigned(FTriggers)) then FTriggers.Free();
  if (Assigned(FEvents)) then FEvents.Free();

  if (Assigned(FWorkbench)) then FWorkbench.Free();

  inherited;
end;

function TCDatabase.EventByName(const EventName: string): TCEvent;
var
  Index: Integer;
begin
  Index := Events.IndexByName(EventName);
  if (Index < 0) then
    Result := nil
  else
    Result := Events[Index];
end;

function TCDatabase.EmptyTables(const TableNames: array of string): Boolean;
var
  I: Integer;
  SQL: string;
begin
  SQL := '';
  if (Length(TableNames) = 0) then
  begin
    for I := 0 to Tables.Count - 1 do
      if (Tables[I] is TCBaseTable) then
        SQL := SQL + SQLTruncateTable(TCBaseTable(Tables[I]));
  end
  else
    for I := 0 to Length(TableNames) - 1 do
      if (Assigned(BaseTableByName(TableNames[I]))) then
        SQL := SQL + SQLTruncateTable(BaseTableByName(TableNames[I]));

  Result := (SQL = '') or Client.ExecuteSQL(SQL);

  if (Result and (SQL <> '')) then
    FTables.Clear();
end;

function TCDatabase.FlushTables(const TableNames: array of string): Boolean;
var
  I: Integer;
  SQL: string;
begin
  Result := True;

  SQL := '';
  for I := 0 to Length(TableNames) - 1 do
  begin                                           
    Result := Result and Assigned(TableByName(TableNames[I]));
    if (Result) then
    begin
      if (SQL <> '') then SQL := SQL + ',';
      SQL := SQL + Client.EscapeIdentifier(Name) + '.' + Client.EscapeIdentifier(TableByName(TableNames[I]).Name);
    end;
  end;
  SQL := 'FLUSH TABLE ' + SQL + ';' + #13#10;

  if (Client.DatabaseName <> Name) then
    Result := Client.ExecuteSQL(SQLUse());

  if (Result) then
    Result := Client.ExecuteSQL(SQL);

  Tables.Clear();
end;

function TCDatabase.FunctionByName(const FunctionName: string): TCFunction;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Routines.Count - 1 do
    if ((lstrcmpi(PChar(Routines[I].Name), PChar(FunctionName)) = 0) and (Routines[I] is TCFunction)) then
      Result := TCFunction(Routines[I]);
end;

function TCDatabase.GetActual(): Boolean;
begin
  Result := Assigned(Tables) and Tables.ActualNames
    and (not Assigned(Routines) or Routines.Actual)
    and (not Assigned(Triggers) or Triggers.Actual)
    and (not Assigned(Events) or Events.Actual);
end;

function TCDatabase.GetActualSource(): Boolean;
begin
  if (Self is TCSystemDatabase) then
    Result := True
  else if (Client.ServerVersion < 40101) then
  begin
    if (FSource = '') then
      FSource := 'CREATE DATABASE ' + Client.EscapeIdentifier(Name) + ';' + #13#10;
    Result := True;
  end
  else
    Result := inherited;
end;

function TCDatabase.GetActualSources(): Boolean;
var
  I: Integer;
begin
  Result := ActualSource;
  for I := 0 to Tables.Count - 1 do
    Result := Result and Tables[I].ActualSource;
  if (Assigned(Routines)) then
  begin
    Result := Result and Routines.Actual;
    for I := 0 to Routines.Count - 1 do
      Result := Result and Routines[I].ActualSource;
  end;
  if (Assigned(Triggers)) then
  begin
    Result := Result and Triggers.Actual;
    for I := 0 to Triggers.Count - 1 do
      Result := Result and Triggers[I].ActualSource;
  end;
  if (Assigned(Events)) then
  begin
    Result := Result and Routines.Actual;
    for I := 0 to Events.Count - 1 do
      Result := Result and Events[I].ActualSource;
  end;
end;

function TCDatabase.GetCollation(): string;
begin
  if ((FCollation = '') and (Source <> '')) then
    ParseCreateDatabase(Source);

  Result := FCollation;
end;

function TCDatabase.GetCount(): Integer;
begin
  Result := Tables.Count;
  if (Assigned(Routines)) then Inc(Result, Routines.Count);
  if (Assigned(Events)) then Inc(Result, Events.Count);
end;

function TCDatabase.GetCreated(): TDateTime;
var
  I: Integer;
begin
  Result := 0;

  for I := 0 to Tables.Count - 1 do
    if ((Tables[I] is TCBaseTable) and (TCBaseTable(Tables[I]).Created >= 0) and ((Result = 0) or (Result > TCBaseTable(Tables[I]).Created))) then
      Result := TCBaseTable(Tables[I]).Created;
end;

function TCDatabase.GetDefaultCharset(): string;
begin
  if ((FDefaultCharset = '') and (Source <> '')) then
    ParseCreateDatabase(Source);

  Result := FDefaultCharset;
end;

function TCDatabase.GetDesktopXML(): IXMLNode;
var
  I: Integer;
begin
  if (not Assigned(FDesktopXML) and Assigned(Client.Databases.DesktopXML)) then
  begin
    for I := 0 to Client.Databases.DesktopXML.ChildNodes.Count - 1 do
      if (lstrcmpi(PChar(string(Client.Databases.DesktopXML.ChildNodes[I].Attributes['name'])), PChar(Name)) = 0) then
        FDesktopXML := Client.Databases.DesktopXML.ChildNodes[I];

    if (not Assigned(FDesktopXML)) then
    begin
      FDesktopXML := Client.Databases.DesktopXML.AddChild('database');
      try
        FDesktopXML.Attributes['name'] := Name;
      except
        Client.Databases.DesktopXML.ChildNodes.Delete(Client.Databases.DesktopXML.ChildNodes.IndexOf(FDesktopXML));
        FDesktopXML := nil;
      end;
    end;
  end;

  Result := FDesktopXML;
end;

function TCDatabase.GetPrefetchObjects(): Boolean;
begin
  case (Client.Prefetch) of
    0: Result := False;
    2: Result := True;
    else Result := ((Tables.Actual and (Tables.Count <= PrefetchTableCount))
           or (Assigned(Tables.DesktopXML) and (Tables.DesktopXML.Attributes['count'] <> '') and (0 < Tables.DesktopXML.Attributes['count']) and (Tables.DesktopXML.Attributes['count'] <= PrefetchTableCount)))
           and Client.MultiStatements;
  end;
end;

function TCDatabase.GetSize(): Int64;
// Result in Byte
var
  I: Integer;
  Size: Int64;
begin
  Result := 0;
  Size := 0;

  for I := 0 to Tables.Count - 1 do
    if ((Tables[I] is TCBaseTable)) then
      Inc(Result, Tables.BaseTable[I].DataSize + Tables.BaseTable[I].IndexSize + Tables.BaseTable[I].UnusedSize)
    else if (Tables[I] is TCView) then
      Inc(Size, SizeOf(TCView(Tables[I]).Source));
  if (Assigned(Routines)) then
    for I := 0 to Routines.Count - 1 do
      Inc(Size, SizeOf(Routines[I].Source));
  if (Assigned(Triggers)) then
    for I := 0 to Triggers.Count - 1 do
      Inc(Size, SizeOf(Triggers[I].Source));
  if (Assigned(Events)) then
    for I := 0 to Triggers.Count - 1 do
      Inc(Size, SizeOf(Events[I].Source));

  Inc(Result, Size);
end;

function TCDatabase.GetSource(): string;
begin
  if (FSource = '') then
    FSource := GetSourceEx();

  Result := FSource;
end;

function TCDatabase.GetSourceEx(const DropBeforeCreate: Boolean = False): string;
begin
  Result := FSource;

  if ((Result <> '') and DropBeforeCreate) then
    Result := 'DROP DATABASE IF EXISTS ' + Client.EscapeIdentifier(Name) + ';' + #13#10 + Result;
end;

function TCDatabase.GetUpdated(): TDateTime;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Tables.Count - 1 do
    if ((Tables[I] is TCBaseTable) and ((Result = 0) or (Result < TCBaseTable(Tables[I]).Updated))) then
      Result := TCBaseTable(Tables[I]).Updated;
end;

function TCDatabase.Initialize(): Boolean;
begin
  Result := Initialize(nil);
end;

function TCDatabase.Initialize(const Param: TObject): Boolean;
var
  SQL: string;
begin
  SQL := '';

  if (Param is TCTable) then
  begin
    if (not TCDBObject(Param).ActualSource) then
      SQL := SQL + TCDBObject(Param).SQLGetSource();
    if (not TCTable(Param).Actual) then
      SQL := SQL + Tables.SQLGetItems(TCTable(Param).Name);
  end
  else if (Param is TCTrigger) then
  begin
    if (not TCTrigger(Param).Actual) then
      SQL := SQL + Triggers.SQLGetItems(TCTrigger(Param).Name);
  end
  else
  begin
    if (not Tables.ActualNames) then
      SQL := SQL + Tables.SQLGetNames();
    if (Assigned(Routines) and not Routines.Actual) then
      SQL := SQL + Routines.SQLGetItems();
    if (Assigned(Triggers) and not Triggers.Actual) then
      SQL := SQL + Triggers.SQLGetItems();
    if (Assigned(Events) and not Events.Actual) then
      SQL := SQL + Events.SQLGetItems();
    if (not Tables.Actual) then
      SQL := SQL + Tables.SQLGetItems();
  end;

  Result := SQL <> '';
  if (Result) then
    Client.SendSQL(SQL, Client.ClientResult);
end;

function TCDatabase.InitializeSources(const Param: TObject = nil): Boolean;
var
  FetchAllViews: Boolean;
  FetchViewFields: Boolean;
  I: Integer;
  SQL: string;
  ViewNames: string;
begin
  SQL := ''; FetchViewFields := False;

  if ((Client.DatabaseName = '') and (50006 <= Client.ServerVersion) and (Client.ServerVersion <= 50031)) then
    // ... is needed, since without selected database a
    // "SHOW CREATE PROCEDURE DatabaseName.ProcedureName"
    // gives an Access Denied error
    SQL := SQL + Client.SQLUse(information_schema);

  if (Param is TCDBObject) then
  begin
    if (not TCDBObject(Param).ActualSource) then
      SQL := SQL + TCDBObject(Param).SQLGetSource();
  end
  else if (Param is TList) then
  begin
    for I := 0 to TList(Param).Count - 1 do
      if (not TCDBObject(TList(Param)[I]).ActualSource) then
        if (not (TCDBObject(TList(Param)[I]) is TCView)) then
          SQL := SQL + TCDBObject(TList(Param)[I]).SQLGetSource()
        else
        begin
          if (not TCView(TList(Param)[I]).FActualSource) then
            SQL := SQL + TCDBObject(TList(Param)[I]).SQLGetSource();
          if (TCDBObject(TList(Param)[I]) is TCView) then
            FetchViewFields := True;
        end;
  end;

  if (not Assigned(Param) or (Param is TCDBObject) or PrefetchObjects) then
  begin
    if (not ActualSource and not Assigned(Param) and PrefetchObjects) then
      SQL := SQL + SQLGetSource();
    for I := 0 to Tables.Count - 1 do
      if (not Tables[I].ActualSource and (not Assigned(Param) or (TCDBObject(Param) <> Tables[I])) and PrefetchObjects) then
      begin
        if (not (Tables[I] is TCView)) then
          SQL := SQL + Tables[I].SQLGetSource()
        else
        begin
          if (not TCView(Tables[I]).FActualSource) then
            SQL := SQL + Tables[I].SQLGetSource();
          FetchViewFields := True;
        end;
      end;
    if (Assigned(Routines)) then
      for I := 0 to Routines.Count - 1 do
        if (not Routines[I].ActualSource and (not Assigned(Param) or (TCDBObject(Param) <> Routines[I])) and PrefetchObjects) then
          SQL := SQL + Routines[I].SQLGetSource();
    if (Assigned(Triggers)) then
      for I := 0 to Triggers.Count - 1 do
        if (not Triggers[I].ActualSource and (not Assigned(Param) or (TCDBObject(Param) <> Triggers[I])) and PrefetchObjects) then
          SQL := SQL + Triggers[I].SQLGetSource();
    if (Assigned(Events)) then
      for I := 0 to Events.Count - 1 do
        if (not Events[I].ActualSource and (not Assigned(Param) or (TCDBObject(Param) <> Events[I])) and PrefetchObjects) then
          SQL := SQL + Events[I].SQLGetSource();
  end;


  if (FetchViewFields) then
  begin
    ViewNames := ''; FetchAllViews := True;
    if ((Param is TList)) then
    begin
      for I := 0 to TList(Param).Count - 1 do
        if (FetchAllViews and (TCDBObject(TList(Param)[I]) is TCView)) then
          if (TList(TCView(TList(Param)[I]).FFields).Count <> 0) then
            FetchAllViews := False
          else
          begin
            if (ViewNames <> '') then ViewNames := ViewNames + ',';
            ViewNames := ViewNames + SQLEscape(TCView(TList(Param)[I]).Name);
          end;
    end
    else
    begin
      for I := 0 to Tables.Count - 1 do
        if (FetchAllViews and (Tables[I] is TCView)) then
          if (TList(Tables[I].FFields).Count <> 0) then
            FetchAllViews := False
          else
          begin
            if (ViewNames <> '') then ViewNames := ViewNames + ',';
            ViewNames := ViewNames + SQLEscape(Tables[I].Name);
          end;
    end;
    if (FetchAllViews) then
      SQL := SQL + 'SELECT * FROM ' + Client.EscapeIdentifier(information_schema) + '.' + Client.EscapeIdentifier('COLUMNS') + ' WHERE ' + Client.EscapeIdentifier('TABLE_SCHEMA') + '=' + SQLEscape(Name) + ' ORDER BY ' + Client.EscapeIdentifier('TABLE_NAME') + ',' + Client.EscapeIdentifier('ORDINAL_POSITION') + ';' + #13#10
    else if (ViewNames <> '') then
      SQL := SQL + 'SELECT * FROM ' + Client.EscapeIdentifier(information_schema) + '.' + Client.EscapeIdentifier('COLUMNS') + ' WHERE ' + Client.EscapeIdentifier('TABLE_SCHEMA') + '=' + SQLEscape(Name) + ' AND ' + Client.EscapeIdentifier('TABLE_NAME') + ' IN (' + ViewNames + ') ORDER BY ' + Client.EscapeIdentifier('TABLE_NAME') + ',' + Client.EscapeIdentifier('ORDINAL_POSITION') + ';' + #13#10;
  end;

  Result := SQL <> '';
  if (Result) then
    Client.SendSQL(SQL, Client.ClientResult);
end;

function TCDatabase.OptimizeTables(const TableNames: array of string): Boolean;
var
  I: Integer;
  SQL: string;
begin
  Result := True;

  SQL := '';
  for I := 0 to Length(TableNames) - 1 do
  begin
    Result := Result and Assigned(TableByName(TableNames[I]));
    if (Result) then
    begin
      if (SQL <> '') then SQL := SQL + ',';
      SQL := SQL + Client.EscapeIdentifier(Name) + '.' + Client.EscapeIdentifier(TableByName(TableNames[I]).Name);
    end;
  end;
  SQL := 'OPTIMIZE TABLE ' + SQL + ';' + #13#10;

  if (Client.DatabaseName <> Name) then
    Result := Client.ExecuteSQL(SQLUse());

  if (Result) then
  begin
    Result := Client.ExecuteSQL(SQL);

    for I := 0 to Length(TableNames) - 1 do
      TableByName(TableNames[I]).Clear();
  end;
end;

procedure TCDatabase.ParseCreateDatabase(const SQL: string);
var
  Parse: TSQLParse;
begin
  if (SQLCreateParse(Parse, PChar(SQL), Length(SQL), Client.ServerVersion)) then
  begin
    if (not SQLParseKeyword(Parse, 'CREATE DATABASE')) then raise EConvertError.CreateFmt(SSourceParseError, [Name, 45, SQL]);

    FName := SQLParseValue(Parse);

    if (SQLParseKeyword(Parse, 'DEFAULT CHARACTER SET') or SQLParseKeyword(Parse, 'CHARACTER SET')) then
      FDefaultCharset := LowerCase(SQLParseValue(Parse));

    if (SQLParseKeyword(Parse, 'DEFAULT COLLATION') or SQLParseKeyword(Parse, 'COLLATION')) then
      Collation := LowerCase(SQLParseValue(Parse));
  end;
end;

function TCDatabase.ProcedureByName(const ProcedureName: string): TCProcedure;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Routines.Count - 1 do
    if ((lstrcmpi(PChar(Routines[I].Name), PChar(ProcedureName)) = 0) and (Routines[I] is TCProcedure)) then
      Result := TCProcedure(Routines[I]);
end;

procedure TCDatabase.Refresh();
begin
  Clear();

  Client.ExecuteEvent(Initialize);
end;

function TCDatabase.RenameTable(const Table: TCTable; const NewTableName: string): Boolean;
var
  NewView: TCView;
begin
  if (NewTableName = Table.Name) then
    Result := True
  else
  begin
    if (Assigned(Table.FDataSet)) then
      Table.FDataSet.TableName := NewTableName;

    if ((Table is TCView) and (Client.ServerVersion < 50014)) then
    begin
      NewView := TCView.Create(Self);
      NewView.Assign(TCView(Table));
      NewView.FName := NewTableName;
      Result := UpdateView(TCView(Table), NewView);
      NewView.Free();
    end
    else
      Result := Client.ExecuteSQL('RENAME TABLE ' + Client.EscapeIdentifier(Table.Database.Name) + '.' + Client.EscapeIdentifier(Table.Name) + ' TO ' + Client.EscapeIdentifier(Name) + '.' + Client.EscapeIdentifier(NewTableName) + ';');
  end;
end;

procedure TCDatabase.SetDefaultCharset(const ADefaultCharset: string);
begin
  FDefaultCharset := LowerCase(ADefaultCharset);

  if (not Assigned(Client)) then
    FDefaultCodePage := CP_ACP
  else
    FDefaultCodePage := Client.CharsetToCodePage(FDefaultCharset);
end;

procedure TCDatabase.SetName(const AName: string);
begin
  if (Client.LowerCaseTableNames = 1) then
    inherited SetName(LowerCase(AName))
  else
    inherited SetName(AName);
end;

procedure TCDatabase.SetSource(const ADataSet: TMySQLQuery);
begin
  SetSource(ADataSet.FieldByName('Create Database'));

  Client.ExecuteEvent(ceUpdated, Self, Self, nil);
end;

function TCDatabase.SQLAlterTable(const Table, NewTable: TCBaseTable; const EncloseFields: Boolean): string;
var
  AutoIncrementField: TCBaseTableField;
  FieldNames: string;
  ForeignKeyAdded: Boolean;
  ForeignKeyDropClausel: string;
  Found: Boolean;
  I: Integer;
  J: Integer;
  Modified: Boolean;
  NewColumn: TCIndexColumn;
  NewField: TCBaseTableField;
  NewForeignKey: TCForeignKey;
  NewIndex: TCIndex;
  NewPartition: TCPartition;
  OldField: TCBaseTableField;
  OldForeignKey: TCForeignKey;
  OldIndex: TCIndex;
  OldPartition: TCPartition;
  SQL: string;
  SQLPart: string;
begin
  AutoIncrementField := nil;
  for I := 0 to NewTable.Fields.Count - 1 do
    if (NewTable.Fields[I].AutoIncrement) then
      AutoIncrementField := TCBaseTableField(NewTable.Fields[I]);
  Found := False;
  for I := 0 to NewTable.Indices.Count - 1 do
    if (NewTable.Indices[I].Primary) then
      for J := 0 to NewTable.Indices[I].Columns.Count - 1 do
        if (NewTable.Indices[I].Columns[J].Field = AutoIncrementField) then
          Found := True;
  if (not Found and Assigned(AutoIncrementField)) then
    if (not Assigned(NewTable.PrimaryIndex)) then
    begin
      NewIndex := TCIndex.Create(NewTable.Indices);
      NewIndex.Primary := True;
      NewColumn := TCIndexColumn.Create(NewIndex.Columns);
      NewColumn.Field := AutoIncrementField;
      NewIndex.Columns.AddColumn(NewColumn);
      NewTable.Indices.AddIndex(NewIndex);
      FreeAndNil(NewColumn);
      FreeAndNil(NewIndex);
    end
    else
      AutoIncrementField.AutoIncrement := False;

  if (EncloseFields) then
    for I := 0 to NewTable.Fields.Count - 1 do
    begin
      NewField := TCBaseTableField(NewTable.Fields.Field[I]);
      if (not Assigned(Table) or (NewField.OriginalName = '')) then
        OldField := nil
      else
        OldField := Table.FieldByName(NewField.OriginalName);
      if (not Assigned(OldField) or (not NewField.Equal(OldField) or NewField.Moved)) then
      begin
        SQLPart := '';
        if (SQL <> '') then SQLPart := SQLPart + ',' + #13#10; SQLPart := SQLPart + '  ';
        if (not Assigned(Table)) then
          SQLPart := SQLPart + Client.EscapeIdentifier(NewField.Name)
        else if (not Assigned(OldField)) then
          SQLPart := SQLPart + 'ADD COLUMN ' + Client.EscapeIdentifier(NewField.Name)
        else
          SQLPart := SQLPart + 'CHANGE COLUMN ' + Client.EscapeIdentifier(OldField.Name) + ' ' + Client.EscapeIdentifier(NewField.Name);
        SQLPart := SQLPart + ' ' + NewField.DBTypeStr();
        if ((NewField.FieldType in [mfChar, mfVarChar, mfTinyText, mfText, mfMediumText, mfLongText, mfSet, mfEnum]) and (Client.ServerVersion >= 40101)) then
        begin
          if ((NewField.Charset <> '')
            and (not Assigned(OldField) and (NewField.Charset <> '') and (NewField.Charset <> NewTable.DefaultCharset) or Assigned(OldField) and (NewField.Charset <> OldField.Charset))) then
            SQLPart := SQLPart + ' CHARACTER SET ' + NewField.Charset;
          if ((NewField.Collation <> '')
            and (not Assigned(OldField) and (NewField.Collation <> '') and (NewField.Collation <> NewTable.FCollation) or Assigned(OldField) and (NewField.Collation <> OldField.Collation))) then
            SQLPart := SQLPart + ' COLLATE ' + NewField.Collation;
        end;
        if (not NewField.NullAllowed) then SQLPart := SQLPart + ' NOT'; SQLPart := SQLPart + ' NULL';
        if (NewField.AutoIncrement) then
          SQLPart := SQLPart + ' AUTO_INCREMENT'
        else if ((NewField.Default <> '') and not (NewField.FieldType in [mfTinyText, mfText, mfMediumText, mfLongText, mfTinyBlob, mfBlob, mfMediumBlob, mfLongBlob])) then
          SQLPart := SQLPart + ' DEFAULT ' + NewField.Default;
        if ((NewField.OnUpdate <> '') and (NewField.FieldType = mfTimeStamp)) then
          SQLPart := SQLPart + ' ON UPDATE ' + NewField.OnUpdate;
        if ((Client.ServerVersion >= 40100) and (NewField.Comment <> '')) then
          SQLPart := SQLPart + ' COMMENT ' + SQLEscape(NewField.Comment);
        if (Assigned(Table) and (not Assigned(OldField) or (Client.ServerVersion >= 40001))) then
          if (not Assigned(NewField.FieldBefore) and (not Assigned(OldField) or Assigned(OldField.FieldBefore))) then
            SQLPart := SQLPart + ' FIRST'
          else if (Assigned(NewField.FieldBefore) and ((not Assigned(OldField) and Assigned(NewField.FieldBefore) and (NewField.FieldBefore.Index <> NewTable.Fields.Count - 2)) or (Assigned(OldField) and (not Assigned(OldField.FieldBefore) or (lstrcmpi(PChar(OldField.FieldBefore.Name), PChar(NewField.FieldBefore.Name)) <> 0) or (TCBaseTableField(NewField.FieldBefore).Moved))))) then
            SQLPart := SQLPart + ' AFTER ' + Client.EscapeIdentifier(NewField.FieldBefore.Name);

        SQL := SQL + SQLPart;
      end;
    end;

  for I := 0 to NewTable.Indices.Count - 1 do
  begin
    Modified := False;
    if (Assigned(Table)) then
      for J := 0 to Table.Indices.Count - 1 do
        if (not NewTable.Indices[I].Created and (lstrcmpi(PChar(NewTable.Indices[I].OriginalName), PChar(Table.Indices[J].OriginalName)) = 0)) then
          Modified := not NewTable.Indices[I].Equal(Table.Indices[J]);

    if (not Assigned(Table) or Modified or NewTable.Indices[I].Created) then
    begin
      NewIndex := NewTable.Indices[I];

      SQLPart := '';
      SQLPart := SQLPart + '  ';
      if (Table <> nil) then SQLPart := SQLPart + 'ADD ';
      if (NewIndex.Primary) then
        SQLPart := SQLPart + 'PRIMARY KEY'
      else if (NewIndex.Unique) then
        SQLPart := SQLPart + 'UNIQUE INDEX'
      else if (NewIndex.Fulltext) then
        SQLPart := SQLPart + 'FULLTEXT INDEX'
      else
        SQLPart := SQLPart + 'INDEX';
      if (NewIndex.Name <> '') then SQLPart := SQLPart + ' ' + Client.EscapeIdentifier(NewIndex.Name);
      FieldNames := '';
      for J := 0 to NewIndex.Columns.Count - 1 do
      begin
        if (FieldNames <> '') then FieldNames := FieldNames + ',';
        FieldNames := FieldNames + Client.EscapeIdentifier(NewIndex.Columns.Column[J].Field.Name);
        if ((NewIndex.Columns.Column[J].Field.FieldType in [mfChar, mfVarChar, mfTinyText, mfText, mfMediumText, mfLongText]) and (NewIndex.Columns.Column[J].Length > 0)) then
          FieldNames := FieldNames + '(' + IntToStr(NewIndex.Columns.Column[J].Length) + ')';
      end;
      SQLPart := SQLPart + ' (' + FieldNames + ')';

      if (SQL <> '') then SQL := SQL + ',' + #13#10;
      SQL := SQL + SQLPart;
    end;
  end;

  ForeignKeyAdded := False;
  for I := 0 to NewTable.ForeignKeys.Count - 1 do
  begin
    Modified := False;
    if (Assigned(Table)) then
      for J := 0 to Table.ForeignKeys.Count - 1 do
        if (not NewTable.ForeignKeys.ForeignKey[I].Created and (lstrcmpi(PChar(NewTable.ForeignKeys.ForeignKey[I].OriginalName), PChar(Table.ForeignKeys.ForeignKey[J].OriginalName)) = 0)) then
          Modified := not NewTable.ForeignKeys.ForeignKey[I].Equal(Table.ForeignKeys.ForeignKey[J]);

    if (not Assigned(Table) or Modified or NewTable.ForeignKeys[I].Created and (NewTable.ForeignKeys[I].Parent.TableName <> '')) then
    begin
      NewForeignKey := NewTable.ForeignKeys[I];

      SQLPart := '';
      if (SQL <> '') then SQLPart := SQLPart + ',' + #13#10; SQLPart := SQLPart + '  ';
      if (Assigned(Table)) then
      begin
        SQLPart := SQLPart + 'ADD ';
        ForeignKeyAdded := True;
      end;
      if (NewForeignKey.Name <> '') then
        SQLPart := SQLPart + 'CONSTRAINT ' + Client.EscapeIdentifier(NewForeignKey.Name) + ' ';
      SQLPart := SQLPart + 'FOREIGN KEY (';
      for J := 0 to Length(NewForeignKey.Fields) - 1 do
      if (Assigned(NewForeignKey.Fields[J])) then
        begin
          if (J > 0) then SQLPart := SQLPart + ',';
          SQLPart := SQLPart + Client.EscapeIdentifier(NewForeignKey.Fields[J].Name);
        end;
      SQLPart := SQLPart + ') REFERENCES ' + Client.EscapeIdentifier(NewForeignKey.Parent.DatabaseName) + '.' + Client.EscapeIdentifier(NewForeignKey.Parent.TableName) + ' (';
      for J := 0 to Length(NewForeignKey.Parent.FieldNames) - 1 do
      begin
        if (J > 0) then SQLPart := SQLPart + ',';
        SQLPart := SQLPart + Client.EscapeIdentifier(NewForeignKey.Parent.FieldNames[J]);
      end;
      SQLPart := SQLPart + ')';

      if (NewForeignKey.Match = mtFull) then
        SQLPart := SQLPart + ' MATCH FULL'
      else if (NewForeignKey.Match = mtPartial) then
        SQLPart := SQLPart + ' MATCH Partial';

      if (NewForeignKey.OnDelete = dtNoAction) then SQLPart := SQLPart + ' ON DELETE NO ACTION';
      if (NewForeignKey.OnDelete = dtCascade) then SQLPart := SQLPart + ' ON DELETE CASCADE';
      if (NewForeignKey.OnDelete = dtSetNull) then SQLPart := SQLPart + ' ON DELETE SET NULL';
      if (NewForeignKey.OnDelete = dtSetDefault) then SQLPart := SQLPart + ' ON DELETE SET DEFAULT';
      if (NewForeignKey.OnUpdate = utNoAction) then SQLPart := SQLPart + ' ON UPDATE NO ACTION';
      if (NewForeignKey.OnUpdate = utCascade) then SQLPart := SQLPart + ' ON UPDATE CASCADE';
      if (NewForeignKey.OnUpdate = utSetNull) then SQLPart := SQLPart + ' ON UPDATE SET NULL';
      if (NewForeignKey.OnUpdate = utSetDefault) then SQLPart := SQLPart + ' ON UPDATE SET DEFAULT';

      SQL := SQL + SQLPart;
    end;
  end;

  if (Assigned(Table)) then
    for I := 0 to Table.Fields.Count - 1 do
    begin
      OldField := TCBaseTableField(Table.Fields[I]);
      Found := False;
      for J := 0 to NewTable.Fields.Count - 1 do
      begin
        NewField := TCBaseTableField(NewTable.Fields[J]);
        if (lstrcmpi(PChar(NewField.OriginalName), PChar(OldField.Name)) = 0) then
          Found := True;
      end;
      if (not Found) then
      begin
        if (SQL <> '') then SQL := SQL + ',' + #13#10;
        SQL := SQL + '  DROP COLUMN ' + Client.EscapeIdentifier(OldField.Name);
      end;
    end;

  if (Assigned(Table)) then
    for I := 0 to Table.Indices.Count - 1 do
    begin
      OldIndex := Table.Indices[I];
      Modified := False;
      for J := 0 to NewTable.Indices.Count - 1 do
        if (not NewTable.Indices[J].Created and (lstrcmpi(PChar(NewTable.Indices[J].OriginalName), PChar(OldIndex.Name)) = 0)) then
          Modified := NewTable.Indices[J].Equal(OldIndex);
      if (not Modified) then
      begin
        if (SQL <> '') then SQL := SQL + ',' + #13#10;
        if (OldIndex.Name = '') then
          SQL := SQL + '  DROP PRIMARY KEY'
        else
          SQL := SQL + '  DROP INDEX ' + Client.EscapeIdentifier(OldIndex.Name);
      end;
    end;

  ForeignKeyDropClausel := '';
  if (Assigned(Table)) then
  begin
    for I := 0 to Table.ForeignKeys.Count - 1 do
    begin
      OldForeignKey := Table.ForeignKeys[I];
      Found := False;
      for J := 0 to NewTable.ForeignKeys.Count - 1 do
        if (lstrcmpi(PChar(NewTable.ForeignKeys[J].OriginalName), PChar(OldForeignKey.Name)) = 0) then
          Found := NewTable.ForeignKeys[J].Equal(OldForeignKey);
      if (not Found) then
      begin
        if (ForeignKeyDropClausel <> '') then ForeignKeyDropClausel := ForeignKeyDropClausel + ',' + #13#10;
        ForeignKeyDropClausel := ForeignKeyDropClausel + '  DROP FOREIGN KEY ' + Client.EscapeIdentifier(OldForeignKey.Name);
      end;
    end;
    if (not ForeignKeyAdded and (ForeignKeyDropClausel <> '')) then
    begin
      if (SQL <> '') then SQL := SQL + ',' + #13#10;
      SQL := SQL + ForeignKeyDropClausel;
    end;
  end;

  if (not Assigned(Table)) then
    SQL := SQL + #13#10 + ')'
  else if (NewTable.FName <> Table.Name) then
    begin
      if (Assigned(Table)) and (SQL <> '') then SQL := SQL + ',' + #13#10;
      SQL := SQL + '  RENAME TO ' + Client.EscapeIdentifier(NewTable.Database.Name) + '.' + Client.EscapeIdentifier(NewTable.FName);
    end;

  if (Assigned(NewTable.FEngine) and (not Assigned(Table) and (NewTable.FEngine <> Client.Engines.DefaultEngine) or Assigned(Table) and (NewTable.FEngine <> Table.Engine))) then
  begin
    if (Assigned(Table) and (SQL <> '')) then SQL := SQL + ',' + #13#10;
    if ((Client.ServerVersion < 40102) and Assigned(NewTable.FEngine)) then
      SQL := SQL + ' TYPE=' + NewTable.FEngine.Name
    else
      SQL := SQL + ' ENGINE=' + NewTable.FEngine.Name;
  end;
  if (Client.ServerVersion >= 40100) then
  begin
    if ((NewTable.FDefaultCharset <> '') and (not Assigned(Table) and (NewTable.FDefaultCharset <> DefaultCharset) or Assigned(Table) and (NewTable.FDefaultCharset <> Table.DefaultCharset))) then
    begin
      if (Assigned(Table) and (SQL <> '')) then SQL := SQL + ',' + #13#10;
      SQL := SQL + ' DEFAULT CHARSET=' + NewTable.FDefaultCharset;
    end;
    if ((NewTable.FCollation <> '') and (not Assigned(Table) and (NewTable.FCollation <> Collation) or Assigned(Table) and (NewTable.FCollation <> Table.Collation))) then
    begin
      if (Assigned(Table) and (SQL <> '')) then SQL := SQL + ',' + #13#10;
      SQL := SQL + ' COLLATE ' + NewTable.FCollation;
    end;
  end;
  if ((Client.ServerVersion >= 40100) and not Assigned(Table) and (NewTable.FComment <> '') or Assigned(Table) and (NewTable.FComment <> Table.Comment)) then
  begin
    if (Assigned(Table) and (SQL <> '')) then SQL := SQL + ',' + #13#10;
    SQL := SQL + ' COMMENT=' + SQLEscape(NewTable.FComment);
  end;
  if (not Assigned(Table) and (NewTable.FPackIndices <> piDefault) or Assigned(Table) and (NewTable.FPackIndices <> Table.PackIndices)) then
  begin
    if (Assigned(Table) and (SQL <> '')) then SQL := SQL + ',' + #13#10;
    if (NewTable.FPackIndices = piUnpacked) then
      SQL := SQL + ' PACK_KEYS=0'
    else if (NewTable.FPackIndices = piPacked) then
      SQL := SQL + ' PACK_KEYS=1'
    else
      SQL := SQL + ' PACK_KEYS=DEFAULT';
  end;
  if ((not Assigned(Table) and (NewTable.FRowType <> mrUnknown) or Assigned(Table) and (NewTable.FRowType <> Table.RowType)) and (NewTable.DBRowTypeStr() <> '')) then
  begin
    if (Assigned(Table) and (SQL <> '')) then SQL := SQL + ',' + #13#10;
    SQL := SQL + ' ROW_FORMAT=' + NewTable.DBRowTypeStr();
  end;
  if ((not Assigned(Table) or Assigned(Table) and (NewTable.FAutoIncrement <> Table.AutoIncrement)) and (NewTable.FAutoIncrement > 0)) then
  begin
    if (Assigned(Table) and (SQL <> '')) then SQL := SQL + ',' + #13#10;
    SQL := SQL + ' AUTO_INCREMENT=' + IntToStr(NewTable.FAutoIncrement);
  end;

  if (Assigned(Table) and Assigned(Table.Partitions) and (Table.Partitions.Count > 0) and Assigned(NewTable.Partitions) and (NewTable.Partitions.Count = 0)) then
    SQL := SQL + ' REMOVE PARTITIONING'
  else if (Assigned(NewTable.Partitions) and (NewTable.Partitions.Count > 0)) then
  begin
    if (not Assigned(Table) or (NewTable.Partitions.PartitionType <> Table.Partitions.PartitionType) or (NewTable.Partitions.Expression <> Table.Partitions.Expression)) then
    begin
      if (Assigned(Table) and (SQL <> '')) then SQL := SQL + #13#10;
      SQL := SQL + ' PARTITION BY ';
      if (NewTable.Partitions.Linear) then
        SQL := SQL + 'LINEAR ';
      case (NewTable.Partitions.PartitionType) of
        ptHash: SQL := SQL + 'HASH(' + NewTable.Partitions.Expression + ')';
        ptKey: SQL := SQL + 'KEY(' + NewTable.Partitions.Expression + ')';
        ptRange: SQL := SQL + 'RANGE(' + NewTable.Partitions.Expression + ')';
        ptList: SQL := SQL + 'LIST(' + NewTable.Partitions.Expression + ')';
      end;
    end;

    if (NewTable.Partitions.PartitionType in [ptHash, ptKey]) then
    begin
      if (not Assigned(Table) or (NewTable.Partitions.Count <> Table.Partitions.Count) and (NewTable.Partitions.Count > 0)) then
      begin
        if (Assigned(Table) and (SQL <> '')) then SQL := SQL + #13#10;
        if (not Assigned(Table)) then
          SQL := SQL + ' PARTITIONS ' + IntToStr(NewTable.Partitions.Count)
        else
          SQL := SQL + ' COALESCE PARTITION ' + IntToStr(NewTable.Partitions.Count);
      end;
    end
    else if (NewTable.Partitions.PartitionType in [ptRange, ptList]) then
    begin
      if (not Assigned(Table) or (Table.Partitions.Count = 0)) then
      begin
        SQL := SQL + ' (' + #13#10;
        for I := 0 to NewTable.Partitions.Count - 1 do
        begin
          if (I > 0) then SQL := SQL + ',' + #13#10;
          SQL := SQL + '  ' + NewTable.Partitions[I].DBTypeStr();
        end;
        SQL := SQL + #13#10 + ') ' + #13#10;
      end
      else
      begin
        Found := False;
        for I := 0 to NewTable.Partitions.Count - 1 do
        begin
          NewPartition := NewTable.Partitions.Partition[I];
          if (not Assigned(Table) or (NewPartition.OriginalName = '')) then
            OldPartition := nil
          else
            OldPartition := Table.PartitionByName(NewPartition.OriginalName);
          Found := Found or not Assigned(OldPartition);
          if (Assigned(OldPartition) and not NewPartition.Equal(OldPartition)) then
            SQL := SQL + ' REORGANIZE PARTITION ' + Client.EscapeIdentifier(OldPartition.Name) + ' INTO ' + NewPartition.DBTypeStr() + #13#10;
        end;

        if (Found) then
        begin
          Found := False;
          SQL := SQL + ' ADD PARTITION (';
          for I := 0 to NewTable.Partitions.Count - 1 do
          begin
            NewPartition := NewTable.Partitions.Partition[I];
            if (not Assigned(Table) or (NewPartition.OriginalName = '')) then
              OldPartition := nil
            else
              OldPartition := Table.PartitionByName(NewPartition.OriginalName);
            if (not Assigned(OldPartition)) then
            begin
              if (Found) then SQL := SQL + ', ';
              SQL := SQL + NewPartition.DBTypeStr();
              Found := True;
            end;
          end;
          SQL := SQL + ')' + #13#10;
        end;
      end;

      if (Assigned(Table)) then
      begin
        SQLPart := '';
        for I := 0 to Table.Partitions.Count - 1 do
        begin
          OldPartition := Table.Partitions.Partition[I];
          Found := False;
          for J := 0 to NewTable.Partitions.Count - 1 do
          begin
            NewPartition := NewTable.Partitions.Partition[J];
            if (lstrcmpi(PChar(NewPartition.OriginalName), PChar(OldPartition.Name)) = 0) then
              Found := True;
          end;
          if (not Found) then
          begin
            if (SQLPart <> '') then SQLPart := SQLPart + ', ';
            SQLPart := SQLPart + Client.EscapeIdentifier(OldPartition.Name);
          end;
        end;
        if (SQLPart <> '') then
          SQL := ' DROP PARTITION ' + SQLPart;
      end;
    end;
  end;

  if (Trim(SQL) = '') then
    Result := ''
  else if (not Assigned(Table)) then
    Result := 'CREATE TABLE ' + Client.EscapeIdentifier(Name) + '.' + Client.EscapeIdentifier(NewTable.Name) + ' (' + #13#10 + TrimRight(SQL) + ';' + #13#10
  else
  begin
    Result := '';

    if (ForeignKeyAdded and (ForeignKeyDropClausel <> '')) then
      Result := Result + 'ALTER TABLE ' + Client.EscapeIdentifier(Name) + '.' + Client.EscapeIdentifier(Table.Name) + #13#10 + TrimRight(ForeignKeyDropClausel) + ';' + #13#10;

    Result := Result + 'ALTER TABLE ' + Client.EscapeIdentifier(Name) + '.' + Client.EscapeIdentifier(Table.Name) + #13#10 + TrimRight(SQL) + ';' + #13#10;
  end;

  if ((Result <> '') and (Name <> Client.DatabaseName)) then
    Result := SQLUse() + Result;
end;

function TCDatabase.SQLGetSource(): string;
begin
  if ((Client.ServerVersion < 40101) or (Self is TCSystemDatabase)) then
    Result := ''
  else
    Result := 'SHOW CREATE DATABASE ' + Client.EscapeIdentifier(Name) + ';' + #13#10;
end;

function TCDatabase.SQLTruncateTable(const Table: TCBaseTable): string;
begin
  if (Client.ServerVersion < 32328) then
    Result := 'DELETE FROM ' + Client.EscapeIdentifier(Name) + '.' + Client.EscapeIdentifier(Table.Name) + ';' + #13#10
  else
    Result := 'TRUNCATE ' + Client.EscapeIdentifier(Name) + '.' + Client.EscapeIdentifier(Table.Name) + ';' + #13#10;

  if ((Client.ServerVersion < 32328) or ((Client.ServerVersion < 50013) and Assigned(Table.Engine) and (UpperCase(Table.Engine.Name) = 'INNODB'))) then
    Result := Result + 'ALTER TABLE ' + Client.EscapeIdentifier(Name) + '.' + Client.EscapeIdentifier(Table.Name) + ' AUTO_INCREMENT=0;' + #13#10;

  if (Name <> Client.DatabaseName) then
    Result := SQLUse() + Result;
end;

function TCDatabase.SQLUse(): string;
begin
  Result := Client.SQLUse(Name);
end;

function TCDatabase.TableByName(const TableName: string): TCTable;
var
  Index: Integer;
begin
  Index := Tables.IndexByName(TableName);
  if (Index < 0) then
    Result := nil
  else
    Result := Tables[Index];
end;

function TCDatabase.TriggerByName(const TriggerName: string): TCTrigger;
var
  Index: Integer;
begin
  Index := Triggers.IndexByName(TriggerName);
  if (Index < 0) then
    Result := nil
  else
    Result := Triggers[Index];
end;

function TCDatabase.Unlock(): Boolean;
var
  SQL: string;
begin
  SQL := '';
  if (Client.DatabaseName <> Name) then
    SQL := SQL + SQLUse();
  SQL := SQL + 'UNLOCK TABLES;' + #13#10;

  Result := Client.ExecuteSQL(SQL);
end;

function TCDatabase.UpdateEvent(const Event, NewEvent: TCEvent): Boolean;
var
  SQL: string;
begin
  SQL := '';

  if (not Assigned(Event) or (NewEvent.EventType <> Event.EventType) or (NewEvent.Execute <> Event.Execute) or (NewEvent.IntervalValue <> Event.IntervalValue) or (NewEvent.IntervalType <> Event.IntervalType)) then
  begin
    SQL := SQL + '  ON SCHEDULE ';
    case (NewEvent.EventType) of
      etSingle:
        SQL := SQL + 'AT ' + SQLEscape(MySQLDB.DateTimeToStr(NewEvent.Execute, Client.FormatSettings));
      etMultiple:
        begin
          SQL := SQL + 'EVERY ' + IntervalToStr(NewEvent.IntervalValue, NewEvent.IntervalType);
          if (NewEvent.StartDateTime > 0) then
            SQL := SQL + ' STARTS ' + SQLEscape(MySQLDB.DateTimeToStr(NewEvent.StartDateTime, Client.FormatSettings));
          if (NewEvent.EndDateTime > 0) then
            SQL := SQL + ' ENDS ' + SQLEscape(MySQLDB.DateTimeToStr(NewEvent.EndDateTime, Client.FormatSettings));
        end;
    end;
    SQL := SQL + #13#10;
  end;

  if (Assigned(Event) and (NewEvent.Name <> Event.Name))then
    SQL := SQL + '  RENAME TO ' + Client.EscapeIdentifier(Name) + '.' + Client.EscapeIdentifier(NewEvent.Name);

  if (not Assigned(Event) or (NewEvent.Preserve <> Event.Preserve)) then
    if (not NewEvent.Preserve) then
      SQL := SQL + '  ON COMPLETION NOT PRESERVE' + #13#10
    else
      SQL := SQL + '  ON COMPLETION PRESERVE' + #13#10;

  if ((not Assigned(Event) or (NewEvent.Enabled <> Event.Enabled)) and not NewEvent.Enabled) then
    SQL := SQL + '  DISABLE' + #13#10
  else if (Assigned(Event) and (NewEvent.Enabled <> Event.Enabled)) then
    SQL := SQL + '  ENABLE' + #13#10;

  if (not Assigned(Event) and (NewEvent.Comment <> '') or Assigned(Event) and (NewEvent.Comment <> Event.Comment))then
    SQL := SQL + '  COMMENT ' + SQLEscape(NewEvent.Comment) + #13#10;

  if (not Assigned(Event) and (SQLTrimStmt(NewEvent.Statement) <> '') or Assigned(Event) and (SQLTrimStmt(NewEvent.Statement) <> SQLTrimStmt(Event.Statement)))then
  begin
    SQL := SQL + '  DO ' + SQLTrimStmt(NewEvent.Statement);
    if (SQL[Length(SQL)] = ';') then Delete(SQL, Length(SQL), 1);
  end;

  if (SQL = '') then
    Result := False
  else
  begin
    if (not Assigned(Event)) then
      SQL := 'CREATE EVENT ' + Client.EscapeIdentifier(Name) + '.' + Client.EscapeIdentifier(NewEvent.Name) + #13#10 + TrimRight(SQL) + ';' + #13#10
    else
      SQL := 'ALTER EVENT ' + Client.EscapeIdentifier(Name) + '.' + Client.EscapeIdentifier(Event.Name) + #13#10 + TrimRight(SQL) + ';' + #13#10;

    Result := Client.ExecuteSQL(SQL);
  end;
end;

function TCDatabase.UpdateRoutine(const Routine, NewRoutine: TCRoutine): Boolean;
var
  SQL: string;
begin
  if (not Assigned(Routine)) then
  begin
    if (NewRoutine.FSource = '') then
      Result := False
    else
    begin
      SQL := NewRoutine.FSource;

      if (Client.DatabaseName <> Name) then
        SQL := SQLUse() + SQL;

      Result := Client.ExecuteSQL(SQL);

      if (not Result and Client.MultiStatements and Assigned(Client.Lib.mysql_set_server_option)) then
        // Warum verliert die MySQL Datenbank den Multi Statement Status ??? (Fixed in 5.0.67 - auch schon vorher?)
        Client.Lib.mysql_set_server_option(Client.Handle, MYSQL_OPTION_MULTI_STATEMENTS_ON);
    end;
  end
  else
  begin
    if (NewRoutine.Source <> Routine.Source) then
    begin
      case (Routine.RoutineType) of
        rtProcedure: SQL := 'DROP PROCEDURE IF EXISTS ' + Client.EscapeIdentifier(Name) + '.' + Client.EscapeIdentifier(Routine.Name) + ';' + #13#10;
        rtFunction: SQL := 'DROP FUNCTION IF EXISTS ' + Client.EscapeIdentifier(Name) + '.' + Client.EscapeIdentifier(Routine.Name) + ';' + #13#10;
        else raise Exception.CreateFMT(SUnknownRoutineType, [Routine.Name]);
      end;
      SQL := SQL + NewRoutine.Source + #13#10;
    end
    else
    begin
      SQL := '';

      if (NewRoutine.Security <> Routine.Security) then
        case (NewRoutine.Security) of
          seDefiner: SQL := SQL + ' SQL SECURITY DEFINER';
          seInvoker: SQL := SQL + ' SQL SECURITY INVOKER';
        end;
      if (Routine.Comment <> NewRoutine.Comment) then
        SQL := SQL + ' COMMENT ' + SQLEscape(NewRoutine.Comment);

      if (SQL <> '') then
        case (Routine.RoutineType) of
          rtProcedure: SQL := 'ALTER PROCEDURE ' + Client.EscapeIdentifier(Name) + '.' + Client.EscapeIdentifier(NewRoutine.Name) + SQL +  ';' + #13#10;
          rtFunction: SQL := 'ALTER FUNCTION ' + Client.EscapeIdentifier(Name) + '.' + Client.EscapeIdentifier(NewRoutine.Name) + SQL +  ';' + #13#10;
        end;
    end;

    Result := SQL <> '';

    if (Result) then
    begin
      if (Client.DatabaseName <> Name) then
        SQL := SQLUse() + SQL;

      Result := Client.ExecuteSQL(SQL);
    end;
  end;

  if (Result and Assigned(Routine)) then
  begin
    Routine.FName := NewRoutine.Name;
    Routine.FSource := '';
    Routine.FActualSource := False;
    Routine.OldSource := Routine.Source; // Refetch Source
  end
  else if (not Result) then
  begin
    // Warum verliert die MySQL Datenbank den Multi Statement Status ???
    if (Client.MultiStatements and Assigned(Client.Lib.mysql_set_server_option)) then
      Client.Lib.mysql_set_server_option(Client.Handle, MYSQL_OPTION_MULTI_STATEMENTS_ON);

    if (Assigned(Routine)) then
      Client.ExecuteSQL(Routine.Source);
  end;
end;

function TCDatabase.UpdateTable(const Table, NewTable: TCBaseTable): Boolean;
var
  I: Integer;
  SQL: string;
begin
  if (Assigned(Table)) then
    for I := 0 to NewTable.Fields.Count - 1 do
      if (NewTable.Fields[I].FieldType in TextFieldTypes) then
      begin
        if ((NewTable.Fields[I].Charset = Table.DefaultCharset) or (NewTable.Fields[I].Charset = '') and (NewTable.DefaultCharset <> Table.DefaultCharset)) then
          NewTable.Fields[I].Charset := NewTable.DefaultCharset;
        if ((NewTable.Fields[I].Collation = Table.Collation) or (NewTable.Fields[I].Collation = '') and (NewTable.Collation <> Table.Collation)) then
          NewTable.Fields[I].Collation := NewTable.Collation;
      end;

  SQL := SQLAlterTable(Table, NewTable);
  Result := (SQL = '') or Client.ExecuteSQL(SQL);
end;

function TCDatabase.UpdateTables(const TableNames: TStringList; const ACharset, ACollation, AEngine: string; const ARowType: TMySQLRowType): Boolean;
var
  I: Integer;
  J: Integer;
  NewTable: TCBaseTable;
  SQL: string;
  Table: TCBaseTable;
begin
  Result := True; SQL := '';

  NewTable := TCBaseTable.Create(Self);

  for I := 0 to TableNames.Count - 1 do
  begin
    Result := Result and (TableByName(TableNames.Strings[I]) is TCBaseTable);
    if (Result) then
    begin
      Table := BaseTableByName(TableNames.Strings[I]);

      if (Assigned(Table) and ((lstrcmpi(PChar(ACharset), PChar(Table.DefaultCharset)) = 0) or (lstrcmpi(PChar(ACollation), PChar(Table.Collation)) <> 0) or (Client.EngineByName(AEngine) <> Table.Engine) or (ARowType <> Table.RowType))) then
      begin
        NewTable.Assign(Table);
        if (ACharset <> '') then
        begin
          NewTable.DefaultCharset := ACharset;

          for J := 0 to NewTable.Fields.Count - 1 do
            if (NewTable.Fields[J].FieldType in TextFieldTypes) then
            begin
              if ((NewTable.DefaultCharset <> Table.DefaultCharset) and ((NewTable.Fields[J].Charset = Table.DefaultCharset) or (NewTable.Fields[J].Charset = ''))) then
                NewTable.Fields[J].Charset := NewTable.DefaultCharset;
              if ((NewTable.Collation <> Table.Collation) and ((NewTable.Fields[J].Collation = Table.Collation) or (NewTable.Fields[J].Collation = ''))) then
                NewTable.Fields[J].Collation := NewTable.Collation;
            end;
        end;
        if (ACollation <> '') then NewTable.Collation := LowerCase(ACollation);
        if (AEngine <> '') then NewTable.Engine := Client.EngineByName(AEngine);
        if (ARowType <> mrUnknown) then NewTable.RowType := ARowType;

        SQL := SQL + SQLAlterTable(Table, NewTable);
      end;
    end;
  end;

  NewTable.Free();

  Result := Result and (SQL = '') or Client.ExecuteSQL(SQL);

  if (Result) then
    Tables.Clear();
end;

function TCDatabase.UpdateTrigger(const Trigger, NewTrigger: TCTrigger): Boolean;
var
  SQL: string;
begin
  SQL := '';

  if (Client.DatabaseName <> Name) then
    SQL := SQL + SQLUse();

  if (Assigned(Trigger)) then
    SQL := SQL + 'DROP TRIGGER IF EXISTS ' + Client.EscapeIdentifier(Name) + '.' + Client.EscapeIdentifier(Trigger.Name) + ';' + #13#10;

  SQL := SQL + NewTrigger.GetSourceEx();

  Result := Client.ExecuteSQL(SQL);

  if (Client.Connected and Client.MultiStatements and Assigned(Client.Lib.mysql_set_server_option)) then
    // Why does the MySQL database loose the Multi Statement state ???
    Client.Lib.mysql_set_server_option(Client.Handle, MYSQL_OPTION_MULTI_STATEMENTS_ON);

  if (not Result and Assigned(Trigger)) then
    Client.ExecuteSQL(Trigger.Source)
  else if (Result) then
    if (Assigned(Trigger)) then
      Result := Client.ExecuteSQL(Triggers.SQLGetItems(NewTrigger.Name), Client.ClientResult);
end;

function TCDatabase.UpdateView(const View, NewView: TCView): Boolean;
var
  SQL: string;
begin
  SQL := '';
  case (NewView.Algorithm) of
    vaUndefined: SQL := SQL + 'ALGORITHM=UNDEFINED ';
    vaMerge: SQL := SQL + 'ALGORITHM=MERGE ';
    vaTemptable: SQL := SQL + 'ALGORITHM=TEMPTABLE ';
  end;
  if (Client.ServerVersion >= 50016) then
  begin
    if (not Assigned(View) and (NewView.Definer <> '') or Assigned(View) and (View.Definer <> NewView.Definer)) then
      SQL := SQL + 'DEFINER=' + Client.EscapeUser(NewView.Definer, True) + ' ';
    case (NewView.Security) of
      seDefiner: SQL := SQL + 'SQL SECURITY DEFINER ';
      seInvoker: SQL := SQL + 'SQL SECURITY INVOKER ';
    end;
  end;
  SQL := SQL + 'VIEW ' + Client.EscapeIdentifier(Name) + '.' + Client.EscapeIdentifier(NewView.Name);
  SQL := SQL + ' AS ' + SQLTrimStmt(NewView.Statement);
  if (SQL[Length(SQL)] = ';') then
    Delete(SQL, Length(SQL), 1);
  case (NewView.CheckOption) of
    voDefault: SQL := SQL + ' WITH CHECK OPTION';
    voCascaded: SQL := SQL + ' WITH CASCADED CHECK OPTION';
    voLocal: SQL := SQL + ' WITH LOCAL CHECK OPTION';
  end;

  if (not Assigned(View)) then
    SQL := 'CREATE ' + SQL
  else if (View.Name = NewView.Name) then
    SQL := 'ALTER ' + SQL
  else
  begin
    SQL := 'DROP VIEW ' + Client.EscapeIdentifier(Name) + '.' + Client.EscapeIdentifier(View.Name) + ';' + #13#10;
    SQL := SQL + 'CREATE ' + SQL;
  end;
  SQL := Trim(SQL);
  if (SQL[Length(SQL)] <> ';') then
    SQL := SQL + ';';
  SQL := SQL + #13#10;

  if (Client.DatabaseName <> Name) then
    SQL := SQLUse() + SQL;

  Result := Client.ExecuteSQL(SQL);

  if (Result) then
    if (Assigned(View)) then
      View.Name := NewView.Name;
end;

function TCDatabase.ViewByName(const TableName: string): TCView;
var
  Index: Integer;
begin
  Index := Tables.IndexByName(TableName);
  if ((Index < 0) or not (Tables[Index] is TCView)) then
    Result := nil
  else
    Result := TCView(Tables[Index]);
end;

{ TCDatabases *****************************************************************}

function TCDatabases.Add(const AObject: TCObject; const Event: Boolean = False): Integer;
begin
  Result := 0;
  while ((Result < TList(Self).Count) and (Client.TableNameCmp(Database[Result].Name, AObject.Name) < 0)) do
    Inc(Result);

  if (Result < TList(Self).Count) then
    inherited Insert(Result, AObject)
  else
    inherited Add(AObject);
end;

function TCDatabases.Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean;
var
  DatabaseName: string;
  DatabaseNames: TCSVStrings;
  Found: Boolean;
  I: Integer;
  Index: Integer;
  Update: Boolean;
begin
  Update := False; Index := -1;

  if (not DataSet.IsEmpty()) then
  begin
    SetLength(DatabaseNames, 0);
    if (Assigned(Client.Account)) then
      CSVSplitValues(Client.Account.Connection.Database, ',', '"', DatabaseNames);

    repeat
      if (not UseInformationSchema) then
        DatabaseName := DataSet.Fields[0].AsString
      else
        DatabaseName := DataSet.FieldByName('SCHEMA_NAME').AsString;

      Found := ((Client.TableNameCmp(DatabaseName, information_schema) = 0)
        or (Client.TableNameCmp(DatabaseName, performance_schema) = 0));
      for I := 0 to Length(DatabaseNames) - 1 do
        if (Client.TableNameCmp(DatabaseName, DatabaseNames[I]) = 0) then
          Found := True;

      if (Found or (Length(DatabaseNames) = 0)) then
      begin
        Index := IndexByName(DatabaseName);
        Update := Index >= 0;

        if (not Update) then
          if (Client.TableNameCmp(DatabaseName, information_schema) = 0) then
          begin
            Index := Add(TCSystemDatabase.Create(Client, DatabaseName));
            Client.FInformationSchema := Database[Index];
          end
          else if (Client.TableNameCmp(DatabaseName, performance_schema) = 0) then
          begin
            Index := Add(TCSystemDatabase.Create(Client, DatabaseName));
            Client.FInformationSchema := Database[Index];
          end
          else
            Index := Add(TCDatabase.Create(Client, DatabaseName));

        if (UseInformationSchema) then
        begin
          Database[Index].DefaultCharset := DataSet.FieldByName('DEFAULT_CHARACTER_SET_NAME').AsString;
          Database[Index].Collation := LowerCase(DataSet.FieldByName('DEFAULT_COLLATION_NAME').AsString);
        end;
      end;
    until (not DataSet.FindNext());
  end
  else if (Assigned(Client.Account) and (Client.Account.Connection.Database <> '')) then
  begin
    CSVSplitValues(Client.Account.Connection.Database, ',', '"', DatabaseNames);
    for I := 0 to Length(DatabaseNames) - 1 do
    begin
      DatabaseName := DatabaseNames[I];

      if (Client.TableNameCmp(DatabaseName, information_schema) = 0) then
      begin
        Index := Add(TCSystemDatabase.Create(Client, DatabaseName));
        Client.FInformationSchema := Database[Index];
      end
      else if (Client.TableNameCmp(DatabaseName, performance_schema) = 0) then
      begin
        Index := Add(TCSystemDatabase.Create(Client, DatabaseName));
        Client.FInformationSchema := Database[Index];
      end
      else
        Add(TCDatabase.Create(Client, DatabaseName));
    end;
  end;

  Result := inherited;

  if ((DataSet.RecordCount = 1) and Update) then
    Client.ExecuteEvent(ceUpdated, Self, Database[Index])
  else
    Client.ExecuteEvent(ceBuild, Self, nil);
end;

procedure TCDatabases.Clear();
begin
  Client.FInformationSchema := nil;
  Client.FPerformanceSchema := nil;

  inherited;
end;

constructor TCDatabases.Create(AClient: TCClient);
begin
  inherited Create(AClient);

  FDesktopXML := nil;

  Clear();
end;

procedure TCDatabases.Delete(const AObject: TCObject);
var
  I: Integer;
  J: Integer;
  Names: TCSVStrings;
begin
  Assert(AObject is TCDatabase);


  Client.ExecuteEvent(ceDroped, Self, AObject);

  DesktopXML.ChildNodes.Remove(TCDatabase(AObject).DesktopXML);

  if (Client.Account.Connection.Database <> '') then
  begin
    SetLength(Names, 0);
    CSVSplitValues(Client.Account.Connection.Database, ',', '"', Names);
    for I := Length(Names) - 1 downto 0 do
      if (Names[I] = AObject.Name) then
      begin
        for J := I to Length(Names) - 2 do
          Names[I] := Names[I + 1];
        SetLength(Names, Length(Names) - 1);
      end;
    Client.Account.Connection.Database := '';
    for I := 0 to Length(Names) - 1 do
    begin
      if (I > 0) then Client.Account.Connection.Database := Client.Account.Connection.Database + ',';
      Client.Account.Connection.Database := Client.Account.Connection.Database + CSVEscape(Names[I]);
    end;
  end;

  inherited;
end;

function TCDatabases.GetCount(): Integer;
begin
  if (not Actual) then
    Result := -1
  else
    Result := TList(Self).Count;
end;

function TCDatabases.GetDatabase(Index: Integer): TCDatabase;
begin
  Result := TCDatabase(Items[Index]);
end;

function TCDatabases.GetDesktopXML(): IXMLNode;
begin
  if (not Assigned(FDesktopXML) and Assigned(Client.Account.DesktopXML)) then
    FDesktopXML := XMLNode(Client.Account.DesktopXML, 'browser/databases', True);

  Result := FDesktopXML;
end;

function TCDatabases.IndexByName(const Name: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  if (Name <> '') then
    for I := 0 to Count - 1 do
      if (Client.TableNameCmp(Name, Database[I].Name) = 0) then
        Result := I;
end;

function TCDatabases.SQLGetItems(const Name: string = ''): string;
var
  DatabaseNames: TCSVStrings;
  I: Integer;
begin
  if (not Client.UseInformationSchema or (Client.ServerVersion < 50006)) then
    Result := 'SHOW DATABASES;' + #13#10
  else
  begin
    Result := 'SELECT * FROM ' + Client.EscapeIdentifier(information_schema) + '.' + Client.EscapeIdentifier('SCHEMATA');
    if (Assigned(Client.Account) and (Client.Account.Connection.Database <> '')) then
    begin
      Result := Result + ' WHERE ' + Client.EscapeIdentifier('SCHEMA_NAME') + ' IN (';

      SetLength(DatabaseNames, 0);
      CSVSplitValues(Client.Account.Connection.Database, ',', '"', DatabaseNames);
      for I := 0 to Length(DatabaseNames) - 1 do
      begin
        if (I > 0) then Result := Result + ',';
        Result := Result + SQLEscape(DatabaseNames[I]);
      end;
      Result := Result + ',' + SQLEscape(information_schema) + ')';

      SetLength(DatabaseNames, 0);
    end;
    Result := Result + ';' + #13#10;
  end;
end;

{ TCVariable ******************************************************************}

procedure TCVariable.Assign(const Source: TCVariable);
begin
  inherited Assign(Source);

  Value := Source.Value;
end;

constructor TCVariable.Create(const AVariables: TCVariables; const AName: string = '');
begin
  inherited Create(AName);

  FVariables := AVariables;
end;

function TCVariable.GetAsBoolean(): Boolean;
begin
  Result := (Value = '1') or (UpperCase(Value) = 'TRUE') or (UpperCase(Value) = 'YES') or (UpperCase(Value) = 'ON');
end;

function TCVariable.GetAsFloat(): Double;
begin
  if (not Assigned(Variables)) then
    Result := StrToFloat(ReplaceStr(Value, ',', ''))
  else
    Result := StrToFloat(Value, Variables.Client.FormatSettings);
end;

function TCVariable.GetAsInteger(): Integer;
begin
  if (not TryStrToInt(ReplaceStr(Value, '.', ''), Result)) then
    if (UpperCase(Value) = 'OFF') then
      Result := 0
    else if (UpperCase(Value) = 'ON') then
      Result := 1
    else
      EConvertError.CreateFmt(SConvStrParseError + '(' + Value + ')', ['"' + Name + '"']);
end;

procedure TCVariable.SetAsBoolean(const AAsBoolean: Boolean);
begin
  if (AAsBoolean <> AsBoolean) then
    if ((UpperCase(Value) = 'YES') or (UpperCase(Value) = 'NO')) then
      if (AAsBoolean) then Value := 'YES' else Value := 'NO'
    else if ((UpperCase(Value) = '1') or (UpperCase(Value) = '0')) then
      if (AAsBoolean) then Value := '1' else Value := '0'
    else if ((UpperCase(Value) = 'ON') or (UpperCase(Value) = 'OFF')) then
      if (AAsBoolean) then Value := 'ON' else Value := 'OFF'
    else
      if (AAsBoolean) then Value := 'TRUE' else Value := 'FALSE'
end;

procedure TCVariable.SetAsFloat(const AAsFloat: Double);
begin
  if (Assigned(Variables)) then
    Value := FloatToStr(AAsFloat)
  else
    Value := FloatToStr(AAsFloat, Variables.Client.FormatSettings);
end;

procedure TCVariable.SetAsInteger(const AAsInteger: Integer);
begin
  Value := IntToStr(AAsInteger);
end;

{ TCVariables *****************************************************************}

function TCVariables.Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean;
var
  Index: Integer;
  Update: Boolean;
  VariableName: string;
begin
  Update := False; Index := -1;

  if (not DataSet.IsEmpty()) then
    repeat
      if (not UseInformationSchema) then
        VariableName := DataSet.FieldByName('Variable_name').AsString
      else
        VariableName := DataSet.FieldByName('VARIABLE_NAME').AsString;

      Index := IndexByName(VariableName);
      Update := Index >= 0;

      if (not Update) then
        Index := Add(TCVariable.Create(Self, VariableName));

      if (not UseInformationSchema) then
        Variable[Index].Value := DataSet.FieldByName('Value').AsString
      else
        Variable[Index].Value := DataSet.FieldByName('VARIABLE_VALUE').AsString;
    until (not DataSet.FindNext());

  if (Count > 0) then
  begin
    if (Client.ServerVersion < 40101) then
    begin
      if (Assigned(Client.Account) and (Client.Account.Connection.Charset = '')) then
        Client.Charset := Client.VariableByName('character_set').Value;
    end;

    if (Assigned(Client.VariableByName('max_allowed_packet'))) then
      Client.FMaxAllowedPacket := Client.VariableByName('max_allowed_packet').AsInteger - 1; // 1 Byte for COM_QUERY

    Client.FLowerCaseTableNames := Client.VariableByName('lower_case_table_names').AsInteger;

    if (Assigned(Client.VariableByName('sql_mode')) and (POS('ANSI_QUOTES', Client.VariableByName('sql_mode').Value) > 0)) then
      Client.IdentifierQuoter := '"';
    if (Assigned(Client.VariableByName('sql_quote_show_create'))) then
      Client.IdentifierQuoted := Client.VariableByName('sql_quote_show_create').AsBoolean;

    if (Assigned(Client.VariableByName('wait_timeout'))) then
      if (Client.VariableByName('wait_timeout').AsInteger >= 4) then
        Client.ServerTimeout := Client.VariableByName('wait_timeout').AsInteger - 3
      else if (Client.VariableByName('wait_timeout').AsInteger >= 2) then
        Client.ServerTimeout := Client.VariableByName('wait_timeout').AsInteger - 1;
  end;

  Result := inherited;

  if ((DataSet.RecordCount = 1) and Update) then
    Client.ExecuteEvent(ceUpdated, Self, Variable[Index])
  else
    Client.ExecuteEvent(ceBuild, Self, nil);
end;

function TCVariables.GetVariable(Index: Integer): TCVariable;
begin
  Result := TCVariable(Items[Index]);
end;

function TCVariables.SQLGetItems(const Name: string = ''): string;
begin
  if (not Client.UseInformationSchema or (Client.ServerVersion < 50112)) then
    if (Client.ServerVersion < 40003) then
      Result := 'SHOW VARIABLES;' + #13#10
    else
      Result := 'SHOW SESSION VARIABLES;' + #13#10
  else
    Result := 'SELECT * FROM ' + Client.EscapeIdentifier(information_schema) + '.' + Client.EscapeIdentifier('SESSION_VARIABLES') + ';' + #13#10;
end;

{ TCStati *********************************************************************}

function TCStati.Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean;
var
  Index: Integer;
  StatusName: string;
  Update: Boolean;
begin
  if (not DataSet.IsEmpty()) then
    repeat
      if (not UseInformationSchema) then
        StatusName := DataSet.FieldByName('Variable_name').AsString
      else
        StatusName := DataSet.FieldByName('VARIABLE_NAME').AsString;

      Update := IndexByName(StatusName) >= 0;

      if (Update) then
        Index := IndexByName(StatusName)
      else
        Index := Add(TCStatus.Create(StatusName));

      if (not UseInformationSchema) then
        Status[Index].Value := DataSet.FieldByName('Value').AsString
      else
        Status[Index].Value := DataSet.FieldByName('VARIABLE_VALUE').AsString;
    until (not DataSet.FindNext());

  Result := inherited;
end;

function TCStati.GetStatus(Index: Integer): TCStatus;
begin
  Result := TCStatus(Items[Index]);
end;

function TCStati.SQLGetItems(const Name: string = ''): string;
begin
  if (not Client.UseInformationSchema or (Client.ServerVersion < 50112)) then
    if (Client.ServerVersion < 50002) then
      Result := 'SHOW STATUS;' + #13#10
    else
      Result := 'SHOW SESSION STATUS;' + #13#10
  else
    Result := 'SELECT * FROM ' + Client.EscapeIdentifier(information_schema) + '.' + Client.EscapeIdentifier('SESSION_STATUS') + ';' + #13#10;
end;

{ TCEngine ********************************************************************}

constructor TCEngine.Create(const AEngines: TCEngines; const AName: string = '');
begin
  inherited Create(AName);

  FEngines := AEngines;
end;

function TCEngine.FieldAvailable(const MySQLFieldType: TMySQLFieldType): Boolean;
begin
  Result := Engines.Client.FieldTypes.FieldAvailable(Self, MySQLFieldType);
end;

function TCEngine.GetForeignKeyAllowed(): Boolean;
begin
  Result := (UpperCase(Name) = 'INNODB');
end;

function TCEngine.GetIsMerge(): Boolean;
begin
  Result := (UpperCase(Name) = 'MERGE') or (UpperCase(Name) = 'MRG_ISAM') or (UpperCase(Name) = 'MRG_MYISAM');
end;

function TCEngine.ApplyMySQLFieldType(const MySQLFieldType: TMySQLFieldType; const MySQLFieldSize: Integer): TMySQLFieldType;
begin
  Result := Engines.Client.FieldTypes.ApplyMySQLFieldType(Self, MySQLFieldType);

  if (((Result in [mfChar, mfVarChar]) and (Engines.Client.ServerVersion < 50003) or (Result in [mfTinyText])) and (MySQLFieldSize >= 1 shl 8)) then
    Result := mfText;
  if (((Result in [mfChar, mfVarChar]) and (Engines.Client.ServerVersion >= 50003) or (Result in [mfText])) and (MySQLFieldSize >= 1 shl 16)) then
    Result := mfMediumText;
  if ((Result in [mfMediumText]) and (MySQLFieldSize >= 1 shl 24)) then
    Result := mfLongText;

  if (((Result in [mfBinary, mfVarBinary]) and (Engines.Client.ServerVersion < 50003) or (Result in [mfTinyBlob])) and (MySQLFieldSize >= 1 shl 8)) then
    Result := mfBlob;
  if (((Result in [mfBinary, mfVarBinary]) and (Engines.Client.ServerVersion >= 50003) or (Result in [mfBlob])) and (MySQLFieldSize >= 1 shl 16)) then
    Result := mfMediumBlob;
  if ((Result in [mfMediumBlob]) and (MySQLFieldSize >= 1 shl 24)) then
    Result := mfLongBlob;
end;

{ TCEngines *******************************************************************}

function TCEngines.Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean;
var
  EngineName: string;
  Index: Integer;
  Update: Boolean;
begin
  if (not DataSet.IsEmpty()) then
    repeat
      if ((not UseInformationSchema and (UpperCase(DataSet.FieldByName('Support').AsString) <> 'NO') and (UpperCase(DataSet.FieldByName('Support').AsString) <> 'DISABLED'))
        or (UseInformationSchema and (UpperCase(DataSet.FieldByName('SUPPORT').AsString) <> 'NO') and (UpperCase(DataSet.FieldByName('SUPPORT').AsString) <> 'DISABLED'))) then
      begin
        if (not UseInformationSchema) then
          EngineName := DataSet.FieldByName('Engine').AsString
        else
          EngineName := DataSet.FieldByName('ENGINE').AsString;

        Update := IndexByName(EngineName) >= 0;

        if (Update) then
          Index := IndexByName(EngineName)
        else if (UpperCase(EngineName) = 'PERFORMANCE_SCHEMA') then
          Index := Add(TCSystemEngine.Create(Self, EngineName))
        else
          Index := Add(TCEngine.Create(Self, EngineName));

        if (not UseInformationSchema) then
        begin
          Engine[Index].FComment := DataSet.FieldByName('Comment').AsString;
          Engine[Index].FDefault := UpperCase(DataSet.FieldByName('Support').AsString) = 'DEFAULT';
        end
        else
        begin
          Engine[Index].FComment := DataSet.FieldByName('COMMENT').AsString;
          Engine[Index].FDefault := UpperCase(DataSet.FieldByName('SUPPORT').AsString) = 'DEFAULT';
        end;
      end;
    until (not DataSet.FindNext());

  Result := inherited;
end;

function TCEngines.GetActual(): Boolean;
var
  I: Integer;
begin
  if ((TList(Self).Count = 0) and (Client.ServerVersion < 40102)) then
  begin
    if ((Client.ServerVersion >= 32334) and Assigned(Client.VariableByName('have_bdb')) and Client.VariableByName('have_bdb').AsBoolean) then
    begin
      Add(TCEngine.Create(Self));
      Engine[TList(Self).Count - 1].FName := 'BDB';
    end;

    Add(TCEngine.Create(Self));
    Engine[TList(Self).Count - 1].FName := 'HEAP';

    if (Assigned(Client.VariableByName('have_innodb')) and Client.VariableByName('have_innodb').AsBoolean) then
    begin
      Add(TCEngine.Create(Self));
      Engine[TList(Self).Count - 1].FName := 'InnoDB';
    end;

    if (Assigned(Client.VariableByName('have_isam')) and Client.VariableByName('have_isam').AsBoolean) then
    begin
      Add(TCEngine.Create(Self));
      Engine[TList(Self).Count - 1].FName := 'ISAM';
    end;

    if (Client.ServerVersion >= 32325) then
    begin
      Add(TCEngine.Create(Self));
      Engine[TList(Self).Count - 1].FName := 'MERGE';
    end;

    Add(TCEngine.Create(Self));
    Engine[TList(Self).Count - 1].FName := 'MyISAM';
    Engine[TList(Self).Count - 1].FDefault := not Assigned(Client.VariableByName('table_type'));

    Add(TCEngine.Create(Self));
    Engine[TList(Self).Count - 1].FName := 'MRG_MyISAM';

    if (Assigned(Client.VariableByName('table_type'))) then
      for I := 0 to TList(Self).Count - 1 do
        Engine[I].FDefault := UpperCase(Engine[I].Name) = UpperCase(Client.VariableByName('table_type').Value);
    if (Assigned(Client.VariableByName('storage_engine'))) then
      for I := 0 to TList(Self).Count - 1 do
        Engine[I].FDefault := UpperCase(Engine[I].Name) = UpperCase(Client.VariableByName('storage_engine').Value);

    FActual := True;
  end;

  Result := inherited;
end;

function TCEngines.GetDefaultEngine(): TCEngine;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Count - 1 do
    if (Engine[I].Default) then
      Result := Engine[I];
end;

function TCEngines.GetEngine(Index: Integer): TCEngine;
begin
  Result := TCEngine(Items[Index]);
end;

function TCEngines.SQLGetItems(const Name: string = ''): string;
begin
  if (not Client.UseInformationSchema or (Client.ServerVersion < 50105)) then
    Result := 'SHOW ENGINES;' + #13#10
  else
    Result := 'SELECT * FROM ' + Client.EscapeIdentifier(information_schema) + '.' + Client.EscapeIdentifier('ENGINES') + ';' + #13#10;
end;

{ TCPlugin ********************************************************************}

constructor TCPlugin.Create(const APlugins: TCPlugins; const AName: string = '');
begin
  inherited Create(AName);

  FPlugins := APlugins;
end;

{ TCPlugins *******************************************************************}

function TCPlugins.Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean;
var
  Index: Integer;
  PluginName: string;
  Update: Boolean;
begin
  if (not DataSet.IsEmpty()) then
    repeat
      if (not UseInformationSchema) then
        PluginName := DataSet.FieldByName('Name').AsString
      else
        PluginName := DataSet.FieldByName('PLUGIN_NAME').AsString;

      Update := IndexByName(PluginName) >= 0;

      if (Update) then
        Index := IndexByName(PluginName)
      else
        Index := Add(TCPlugin.Create(Self, PluginName));

      if (UseInformationSchema) then
        Plugin[Index].FComment := DataSet.FieldByName('PLUGIN_DESCRIPTION').AsString;
    until (not DataSet.FindNext());

  Result := inherited;
end;

function TCPlugins.GetPlugin(Index: Integer): TCPlugin;
begin
  Result := TCPlugin(Items[Index]);
end;

function TCPlugins.SQLGetItems(const Name: string = ''): string;
begin
  if (not Client.UseInformationSchema and (Client.ServerVersion < 50109)) then
    Result := 'SHOW PLUGIN;' + #13#10
  else if (not Client.UseInformationSchema or (Client.ServerVersion < 50105)) then
    Result := 'SHOW PLUGINS;' + #13#10
  else
    Result := 'SELECT * FROM ' + Client.EscapeIdentifier(information_schema) + '.' + Client.EscapeIdentifier('PLUGINS') + ';' + #13#10;
end;

{ TCFieldType *****************************************************************}

constructor TCFieldType.Create(const AFieldTypes: TCFieldTypes; const AMySQLFieldType: TMySQLFieldType; const ACaption: string; const AHighlighted: Boolean);
begin
  FieldTypes := AFieldTypes;

  FCaption := ACaption;
  FHighlighted := AHighlighted;
  FMySQLFieldType := AMySQLFieldType;
end;

function TCFieldType.DBTypeStr(): string;
begin
  Result := LowerCase(Caption);
end;

{ TCFieldTypes ****************************************************************}

procedure TCFieldTypes.Add(const AMySQLFieldType: TMySQLFieldType; const ACaption: string; const AHighlighted: Boolean);
begin
  inherited Add(TCFieldType.Create(Self, AMySQLFieldType, ACaption, AHighlighted));
end;

function TCFieldTypes.ApplyMySQLFieldType(const Engine: TCEngine; const MySQLFieldType: TMySQLFieldType): TMySQLFieldType;
begin
  if (FieldAvailable(Engine, MySQLFieldType)) then
    Result := MySQLFieldType
  else
    case (MySQLFieldType) of
      mfBit: Result := mfBigInt;
      mfGeometry,
      mfPoint,
      mfLineString,
      mfPolygon,
      mfMultiPoint,
      mfMultiLineString,
      mfMultiPolygon,
      mfGeometryCollection: Result := mfBlob;
      else Result := MySQLFieldType;
    end;
end;

constructor TCFieldTypes.Create(const AClient: TCClient);
begin
  inherited Create();

  FClient := AClient;

  Add(mfBit, 'Bit', False);
  Add(mfTinyInt, 'TinyInt', False);
  Add(mfSmallInt, 'SmallInt', False);
  Add(mfMediumInt, 'MediumInt', False);
  Add(mfInt, 'Int', True);
  Add(mfBigInt, 'BigInt', False);
  Add(mfFloat, 'Float', False);
  Add(mfDouble, 'Double', False);
  Add(mfDecimal, 'Decimal', False);
  Add(mfDate, 'Date', False);
  Add(mfDateTime, 'DateTime', True);
  Add(mfTimeStamp, 'TimeStamp', False);
  Add(mfTime, 'Time', False);
  Add(mfYear, 'Year', False);
  Add(mfChar, 'Char', False);
  Add(mfVarChar, 'VarChar', True);
  Add(mfBinary, 'Binary', False);
  Add(mfVarBinary, 'VarBinary', False);
  Add(mfTinyText, 'TinyText', False);
  Add(mfText, 'Text', True);
  Add(mfMediumText, 'MediumText', False);
  Add(mfLongText, 'LongText', False);
  Add(mfTinyBlob, 'TinyBlob', False);
  Add(mfBlob, 'Blob', True);
  Add(mfMediumBlob, 'MediumBlob', False);
  Add(mfLongBlob, 'LongBlob', False);
  Add(mfEnum, 'Enum', False);
  Add(mfSet, 'Set', False);
  Add(mfGeometry, 'Geometry', False);
  Add(mfPoint, 'Point', False);
  Add(mfLineString, 'LineString', False);
  Add(mfPolygon, 'Polygon', False);
  Add(mfMultiPoint, 'MultiPoint', False);
  Add(mfMultiLineString, 'MultiLineString', False);
  Add(mfMultiPolygon, 'MultiPolygon', False);
  Add(mfGeometryCollection, 'GeometryCollection', False);
end;

function TCFieldTypes.FieldAvailable(const Engine: TCEngine; const MySQLFieldType: TMySQLFieldType): Boolean;
begin
  case (MySQLFieldType) of
    mfUnknown: Result := False;
    mfBit: Result := Assigned(Engine) and ((Client.ServerVersion >= 50003) and (Engine.Name = 'MyISAM') or (Client.ServerVersion >= 50005) and ((Engine.Name = 'MEMORY') or (Engine.Name = 'InnoDB') or (Engine.Name = 'BDB')));
    mfBinary,
    mfVarBinary: Result := Client.ServerVersion >= 40102;
    mfGeometry,
    mfPoint,
    mfLineString,
    mfPolygon,
    mfMultiPoint,
    mfMultiLineString,
    mfMultiPolygon,
    mfGeometryCollection: Result := Assigned(Engine) and (Assigned(Client.VariableByName('have_geometry')) and Client.VariableByName('have_geometry').AsBoolean and ((Engine.Name = 'MyISAM') or (Client.ServerVersion >= 50016) and ((Engine.Name = 'InnoDB') or (Engine.Name = 'NDB') or (Engine.Name = 'BDB') or (Engine.Name = 'ARCHIVE'))));
    else Result := True;
  end;
end;

function TCFieldTypes.GetFieldType(Index: Integer): TCFieldType;
begin
  Result := TCFieldType(Items[Index]);
end;

{ TCCharset *******************************************************************}

constructor TCCharset.Create(const ACharsets: TCCharsets; const AName: string = '');
begin
  inherited Create(AName);

  FCharsets := ACharsets;
end;

function TCCharset.GetDefaultCollation(): TCCollation;
var
  I: Integer;
begin
  Result := nil;

  if (Assigned(Charsets.Client.Collations)) then
    for I := 0 to Charsets.Client.Collations.Count - 1 do
      if ((Charsets.Client.Collations[I].Charset = Self) and Charsets.Client.Collations[I].Default) then
        Result := Charsets.Client.Collations[I];
end;

{ TCCharsets ******************************************************************}

function TCCharsets.Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean;
var
  CharsetName: string;
  Index: Integer;
  Update: Boolean;
begin
  if (not DataSet.IsEmpty()) then
    repeat
      if (not UseInformationSchema) then
        CharsetName := DataSet.FieldByName('Charset').AsString
      else
        CharsetName := DataSet.FieldByName('CHARACTER_SET_NAME').AsString;

      Update := IndexByName(CharsetName) >= 0;

      if (Update) then
        Index := IndexByName(CharsetName)
      else
        Index := Add(TCCharset.Create(Self, CharsetName));

      if (not UseInformationSchema) then
      begin
        Charset[Index].FHint := DataSet.FieldByName('Description').AsString;
        Charset[Index].FCollation := LowerCase(DataSet.FieldByName('Default collation').AsString);
        Charset[Index].FMaxLength := DataSet.FieldByName('Maxlen').AsInteger;
      end
      else
      begin
        Charset[Index].FHint := DataSet.FieldByName('DESCRIPTION').AsString;
        Charset[Index].FCollation := LowerCase(DataSet.FieldByName('DEFAULT_COLLATE_NAME').AsString);
        Charset[Index].FMaxLength := DataSet.FieldByName('MAXLEN').AsInteger;
      end;
    until (not DataSet.FindNext());

  Result := inherited;
end;

function TCCharsets.GetCharset(Index: Integer): TCCharset;
begin
  Result := TCCharset(Items[Index]);
end;

function TCCharsets.GetActual(): Boolean;
var
  I: Integer;
  Index: Integer;
  Value: string;
  Values: string;
begin
  if ((TList(Self).Count = 0) and (Client.ServerVersion < 40100)) then
  begin
    if (Assigned(Client.VariableByName('character_sets'))) then
    begin
      Values := Client.VariableByName('character_sets').Value;

      while (Values <> '') do
      begin
        if (Pos(' ', Values) > 0) then
          Value := Copy(Values, 1, Pos(' ', Values) - 1)
        else
          Value := Values;

        Index := 0;
        for I := 0 to TList(Self).Count - 1 do
          if (lstrcmpi(PChar(Value), PChar(Charset[I].Name)) > 0) then
            Index := I + 1;

        Insert(Index, TCCharset.Create(Self));

        Charset[Index].FName := Value;

        System.Delete(Values, 1, Length(Value)); Values := Trim(Values);
      end;
    end;

    FActual := True;
  end;

  Result := inherited;
end;

function TCCharsets.SQLGetItems(const Name: string = ''): string;
begin
  if (not Client.UseInformationSchema or (Client.ServerVersion < 50006)) then
    Result := 'SHOW CHARACTER SET;' + #13#10
  else
    Result := 'SELECT * FROM ' + Client.EscapeIdentifier(information_schema) + '.' + Client.EscapeIdentifier('CHARACTER_SETS') + ';' + #13#10;
end;

{ TCCollation *****************************************************************}

constructor TCCollation.Create(const ACollations: TCCollations; const AName: string = '');
begin
  inherited Create(AName);

  FCollations := ACollations;
end;

{ TCCollations ****************************************************************}

function TCCollations.Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean;
var
  CollationName: string;
  Index: Integer;
  Update: Boolean;
begin
  if (not DataSet.IsEmpty()) then
    repeat
      if (not UseInformationSchema) then
        CollationName := DataSet.FieldByName('Collation').AsString
      else
        CollationName := DataSet.FieldByName('COLLATION_NAME').AsString;

      Update := IndexByName(CollationName) >= 0;

      if (Update) then
        Index := IndexByName(CollationName)
      else
        Index := Add(TCCollation.Create(Self, CollationName));

      if (not UseInformationSchema) then
      begin
        Collation[Index].FCharset := Client.CharsetByName(DataSet.FieldByName('Charset').AsString);
        Collation[Index].FId := DataSet.FieldByName('Id').AsInteger;
        Collation[Index].FDefault := UpperCase(DataSet.FieldByName('Default').AsString) = 'YES';
        Collation[Index].FCompiled := UpperCase(DataSet.FieldByName('Compiled').AsString) = 'YES';
        Collation[Index].FSortLength := DataSet.FieldByName('Sortlen').AsInteger;
      end
      else
      begin
        Collation[Index].FCharset := Client.CharsetByName(DataSet.FieldByName('CHARACTER_SET_NAME').AsString);
        Collation[Index].FId := DataSet.FieldByName('ID').AsInteger;
        Collation[Index].FDefault := UpperCase(DataSet.FieldByName('IS_DEFAULT').AsString) = 'YES';
        Collation[Index].FCompiled := UpperCase(DataSet.FieldByName('IS_COMPILED').AsString) = 'YES';
        Collation[Index].FSortLength := DataSet.FieldByName('SORTLEN').AsInteger;
      end;
    until (not DataSet.FindNext());

  Result := inherited;
end;

function TCCollations.GetCollation(Index: Integer): TCCollation;
begin
  Result := TCCollation(Items[Index]);
end;

function TCCollations.SQLGetItems(const Name: string = ''): string;
begin
  if (not Client.UseInformationSchema or (Client.ServerVersion < 50006)) then
    Result := 'SHOW COLLATION;' + #13#10
  else
    Result := 'SELECT * FROM ' + Client.EscapeIdentifier(information_schema) + '.' + Client.EscapeIdentifier('COLLATIONS') + ';' + #13#10;
end;

{ TCProcesse ******************************************************************}

function TCProcess.GetId(): Integer;
begin
  Result := StrToInt(Name);
end;

procedure TCProcess.SetId(AId: Integer);
begin
  Name := IntToStr(AId);
end;

{ TCProcesses *****************************************************************}

function TCProcesses.Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean;
var
  Days: Integer;
  Hours: Integer;
  Index: Integer;
  Minutes: Integer;
  Seconds: Integer;
begin
  if (not DataSet.IsEmpty()) then
    repeat
      Add(TCProcess.Create());
      Index := TList(Self).Count - 1;
      if (not UseInformationSchema) then
      begin
        Process[Index].FName := DataSet.FieldByName('Id').AsString;
        Process[Index].FUserName := DataSet.FieldByName('User').AsString;
        Process[Index].FHost := DataSet.FieldByName('Host').AsString;
        Process[Index].FDatabaseName := DataSet.FieldByName('db').AsString;
        Process[Index].FCommand := DataSet.FieldByName('Command').AsString;
        if (not TryStrToInt(DataSet.FieldByName('Time').AsString, Seconds) or (Seconds < 0)) then
          Process[Index].FTime := 0
        else
        begin
          Minutes := Seconds div SecsPerMin; Seconds := Seconds mod SecsPerMin;
          Hours := Minutes div MinsPerHour; Minutes := Minutes mod MinsPerHour;
          Days := Hours div HoursPerDay; Hours := Hours mod HoursPerDay;
          Process[Index].FTime := Days + EncodeTime(Hours, Minutes, Seconds, 0);
        end;
        Process[Index].FState := DataSet.FieldByName('State').AsString;
        Process[Index].FSQL := DataSet.FieldByName('Info').AsString;
      end
      else
      begin
        Process[Index].FName := DataSet.FieldByName('ID').AsString;
        Process[Index].FUserName := DataSet.FieldByName('USER').AsString;
        Process[Index].FHost := DataSet.FieldByName('HOST').AsString;
        Process[Index].FDatabaseName := DataSet.FieldByName('DB').AsString;
        Process[Index].FCommand := DataSet.FieldByName('COMMAND').AsString;
        if (not TryStrToInt(DataSet.FieldByName('TIME').AsString, Seconds) or (Seconds < 0)) then
          Process[Index].FTime := 0
        else
        begin
          Minutes := Seconds div SecsPerMin; Seconds := Seconds mod SecsPerMin;
          Hours := Minutes div MinsPerHour; Minutes := Minutes mod MinsPerHour;
          Days := Hours div HoursPerDay; Hours := Hours mod HoursPerDay;
          Process[Index].FTime := Days + EncodeTime(Hours, Minutes, Seconds, 0);
        end;
        Process[Index].FState := DataSet.FieldByName('STATE').AsString;
        Process[Index].FSQL := DataSet.FieldByName('INFO').AsString;
      end;
    until (not DataSet.FindNext());

  Result := inherited;
end;

function TCProcesses.GetActual(): Boolean;
begin
  if ((Client.ServerVersion >= 50000) and (not Assigned(Client.UserRights) or not Client.UserRights.RProcess)) then
    Result := False
  else
    Result := inherited;
end;

function TCProcesses.GetProcess(Index: Integer): TCProcess;
begin
  Result := TCProcess(Items[Index]);
end;

function TCProcesses.SQLGetItems(const Name: string = ''): string;
begin
  if (not Client.UseInformationSchema or (Client.ServerVersion < 50107)) then
    Result := 'SHOW FULL PROCESSLIST;' + #13#10
  else
    Result := 'SELECT * FROM ' + Client.EscapeIdentifier(information_schema) + '.' + Client.EscapeIdentifier('PROCESSLIST') + ';' + #13#10;
end;

{ TCUserRight *****************************************************************}

procedure TCUserRight.Assign(const Source: TCUserRight);
begin
  DatabaseName := Source.DatabaseName;
  TableName := Source.TableName;
  ProcedureName := Source.ProcedureName;
  FunctionName := Source.FunctionName;
  FieldName := Source.FieldName;

  RAlter := Source.RAlter;
  RAlterRoutine := Source.RAlterRoutine;
  RCreate := Source.RCreate;
  RCreateTempTable := Source.RCreateTempTable;
  RCreateRoutine := Source.RCreateRoutine;
  RCreateUser := Source.RCreateUser;
  RCreateView := Source.RCreateView;
  RDelete := Source.RDelete;
  RDrop := Source.RDrop;
  REvent := Source.REvent;
  RExecute := Source.RExecute;
  RFile := Source.RFile;
  RGrant := Source.RGrant;
  RIndex := Source.RIndex;
  RInsert := Source.RInsert;
  RLockTables := Source.RLockTables;
  RProcess := Source.RProcess;
  RReferences := Source.RReferences;
  RReload := Source.RReload;
  RReplClient := Source.RReplClient;
  RReplSlave := Source.RReplSlave;
  RSelect := Source.RSelect;
  RShowDatabases := Source.RShowDatabases;
  RShowView := Source.RShowView;
  RShutdown := Source.RShutdown;
  RSuper := Source.RSuper;
  RTrigger := Source.RTrigger;
  RUpdate := Source.RUpdate;
end;

constructor TCUserRight.Create();
begin
  inherited Create();

  DatabaseName := '';
  TableName := '';
  ProcedureName := '';
  FunctionName := '';
  FieldName := '';

  RAlter := False;
  RAlterRoutine := False;
  RCreate := False;
  RCreateTempTable := False;
  RCreateRoutine := False;
  RCreateUser := False;
  RCreateView := False;
  RDelete := False;
  RDrop := False;
  REvent := False;
  RExecute := False;
  RFile := False;
  RGrant := False;
  RIndex := False;
  RInsert := False;
  RLockTables := False;
  RProcess := False;
  RReferences := False;
  RReload := False;
  RReplClient := False;
  RReplSlave := False;
  RSelect := False;
  RShowDatabases := False;
  RShowView := False;
  RShutdown := False;
  RTrigger := False;
  RSuper := False;
  RUpdate := False;
end;

function TCUserRight.GetCaption(): string;
begin
  Result := '';
  if (DatabaseName <> '') then
    Result := Result + DatabaseName;
  if (TableName <> '') then
  begin
    Result := Result + '.' + TableName;
    if (FieldName <> '') then
      Result := Result + '.' + FieldName;
  end
  else if (ProcedureName <> '') then
    Result := Result + '.' + ProcedureName
  else if (FunctionName <> '') then
    Result := Result + '.' + FunctionName;
  if (Result = '') then
    Result := '<' + Preferences.LoadStr(214) + '>';
end;

{ TCUser **********************************************************************}

function TCUser.AddRight(const NewUserRight: TCUserRight): Boolean;
var
  I: Integer;
  Index: Integer;
begin
  Index := FRights.Count;
  for I := FRights.Count - 1 downto 0 do
    if (lstrcmpi(PChar(NewUserRight.DatabaseName), PChar(Right[I].DatabaseName)) < 0) then
      Index := I
    else if (lstrcmpi(PChar(NewUserRight.DatabaseName), PChar(Right[I].DatabaseName)) = 0) then
      if ((lstrcmpi(PChar(NewUserRight.TableName), PChar(Right[I].TableName)) < 0) and (NewUserRight.ProcedureName = '') and (NewUserRight.FunctionName = '')) then
        Index := I
      else if ((lstrcmpi(PChar(NewUserRight.TableName), PChar(Right[I].TableName)) = 0) and (NewUserRight.ProcedureName = '') and (NewUserRight.FunctionName = '')) then
        if ((lstrcmpi(PChar(NewUserRight.FieldName), PChar(Right[I].FieldName)) < 0) and (NewUserRight.ProcedureName = '') and (NewUserRight.FunctionName = '')) then
          Index := I
        else if (lstrcmpi(PChar(NewUserRight.ProcedureName), PChar(Right[I].ProcedureName)) < 0) then
          Index := I
        else if (lstrcmpi(PChar(NewUserRight.FunctionName), PChar(Right[I].FunctionName)) < 0) then
          Index := I;

  FRights.Insert(Index, TCUserRight.Create());
  Right[Index].Assign(NewUserRight);

  Result := True;
end;

procedure TCUser.Assign(const Source: TCUser);
var
  I: Integer;
begin
  inherited Assign(Source);

  if (not Assigned(FUsers)) then FUsers := Source.Users;

  FConnectionsPerHour := Source.ConnectionsPerHour;
  FRawPassword := Source.RawPassword;
  FNewPassword := Source.NewPassword;
  FQueriesPerHour := Source.QueriesPerHour;
  for I := 0 to Source.FRights.Count - 1 do
  begin
    FRights.Add(TCUserRight.Create());
    TCUserRight(FRights[I]).Assign(Source.FRights[I]);
  end;
  FUpdatesPerHour := Source.UpdatesPerHour;
  FUserConnections := Source.UserConnections;

  Actual := Source.Actual;
end;

procedure TCUser.Clear();
begin
  inherited;

  ConnectionsPerHour := 0;
  RawPassword := '';
  NewPassword := '';
  QueriesPerHour := 0;
  UpdatesPerHour := 0;
  UserConnections := 0;

  while (FRights.Count > 0) do
  begin
    Right[0].Free();
    FRights.Delete(0);
  end;
end;

constructor TCUser.Create(const AUsers: TCUsers; const AName: string = '');
begin
  FUsers := AUsers;
  FRights := TList.Create();

  inherited Create(AUsers.Client, AName);
end;

procedure TCUser.DeleteRight(const UserRight: TCUserRight);
var
  Index: Integer;
begin
  if (UserRight <> nil) then
  begin
    Index := IndexOf(UserRight);

    Right[Index].Free();
    FRights.Delete(Index);
  end;
end;

destructor TCUser.Destroy();
begin
  Clear();
  FRights.Free();

  inherited;
end;

function TCUser.GetCaption(): string;
begin
  if (Name <> '') then
    Result := Name
  else
    Result := '<' + Preferences.LoadStr(287) + '>';
end;

function TCUser.GetConnectionsPerHour(): Integer;
begin
  if (not Actual) then
    ParseGrant(Source);

  Result := FConnectionsPerHour;
end;

function TCUser.GetHost(): string;
begin
  if (Pos('@', Name) = 0) then
    Result := ''
  else
  begin
    Result := Name;
    Delete(Result, 1, Pos('@', Name));
  end;
end;

function TCUser.GetLogin(): string;
begin
  if (Pos('@', Name) = 0) then
    Result := Name
  else
    Result := Copy(Name, 1, Pos('@', Name) - 1);
end;

function TCUser.GetQueriesPerHour(): Integer;
begin
  if (not Actual) then
    ParseGrant(Source);

  Result := FQueriesPerHour;
end;

function TCUser.GetRawPassword(): string;
begin
  if (not Actual) then
    ParseGrant(Source);

  Result := FRawPassword;
end;

function TCUser.GetRight(Index: Integer): TCUserRight;
begin
  if (not Actual) then
    ParseGrant(Source);

  Result := FRights[Index];
end;

function TCUser.GetRightCount(): Integer;
begin
  if (not Actual and ActualSource) then
    ParseGrant(Source);

  Result := FRights.Count;
end;

function TCUser.GetSlowSQLLog(): string;
begin
  if (not Assigned(Users) or not Assigned(Users.Client)) then
    Result := ''
  else
    Result := Users.Client.GetSlowSQLLog(Self);
end;

function TCUser.GetSQLLog(): string;
begin
  if (not Assigned(Users) or not Assigned(Users.Client)) then
    Result := ''
  else
    Result := Users.Client.GetSQLLog(Self);
end;

function TCUser.GetUpdatesPerHour(): Integer;
begin
  if (not Actual) then
    ParseGrant(Source);

  Result := FUpdatesPerHour;
end;

function TCUser.GetUserConnections(): Integer;
begin
  if (not Actual) then
    ParseGrant(Source);

  Result := FUserConnections;
end;

function TCUser.IndexOf(const UserRight: TCUserRight): Integer;
var
  I: Integer;
begin
  Result := - 1;

  for I := 0 to FRights.Count - 1 do
    if (Right[I] = UserRight) then
      Result := I;
end;

function TCUser.Initialize(): Boolean;
begin
  Result := Client.Initialize();
end;

procedure TCUser.ParseGrant(const SQL: string);

  procedure AddPrivileg(const Right: TCUserRight; const Privileg: string);
  begin
    with Right do
      begin
        RAlter           := (RAlter           or (Privileg = 'ALTER')                   or (Privileg = 'ALL PRIVILEGES'));
        RAlterRoutine    := (RAlterRoutine    or (Privileg = 'ALTER ROUTINE')           or (Privileg = 'ALL PRIVILEGES')) and (Users.Client.ServerVersion >= 50003);
        RCreate          := (RCreate          or (Privileg = 'CREATE')                  or (Privileg = 'ALL PRIVILEGES'));
        RCreateRoutine   := (RCreateRoutine   or (Privileg = 'CREATE ROUTINE')          or (Privileg = 'ALL PRIVILEGES')) and (Users.Client.ServerVersion >= 50003);
        RCreateTempTable := (RCreateTempTable or (Privileg = 'CREATE TEMPORARY TABLES') or (Privileg = 'ALL PRIVILEGES')) and (Users.Client.ServerVersion >= 40002);
        RCreateUser      := (RCreateUser      or (Privileg = 'CREATE USER')             or (Privileg = 'ALL PRIVILEGES')) and (Users.Client.ServerVersion >= 50003);
        RCreateView      := (RCreateView      or (Privileg = 'CREATE VIEW')             or (Privileg = 'ALL PRIVILEGES')) and (Users.Client.ServerVersion >= 50001);
        RDelete          := (RDelete          or (Privileg = 'DELETE')                  or (Privileg = 'ALL PRIVILEGES'));
        RDrop            := (RDrop            or (Privileg = 'DROP')                    or (Privileg = 'ALL PRIVILEGES'));
        REvent           := (REvent           or (Privileg = 'EVENT')                   or (Privileg = 'ALL PRIVILEGES')) and (Users.Client.ServerVersion >= 50106);
        RExecute         := (RExecute         or (Privileg = 'EXECUTE')                 or (Privileg = 'ALL PRIVILEGES')) and (Users.Client.ServerVersion >= 50003);
        RFile            := (RFile            or (Privileg = 'FILE')                    or (Privileg = 'ALL PRIVILEGES'));
        RGrant           := (RGrant           or (Privileg = 'GRANT OPTION')            or (Privileg = 'ALL PRIVILEGES'));
        RIndex           := (RIndex           or (Privileg = 'INDEX')                   or (Privileg = 'ALL PRIVILEGES'));
        RInsert          := (RInsert          or (Privileg = 'INSERT')                  or (Privileg = 'ALL PRIVILEGES'));
        RLockTables      := (RLockTables      or (Privileg = 'LOCK TABLES')             or (Privileg = 'ALL PRIVILEGES')) and (Users.Client.ServerVersion >= 40002);
        RProcess         := (RProcess         or (Privileg = 'PROCESS')                 or (Privileg = 'ALL PRIVILEGES'));
        RReferences      := (RReferences      or (Privileg = 'REFERENCES')              or (Privileg = 'ALL PRIVILEGES'));
        RReload          := (RReload          or (Privileg = 'RELOAD')                  or (Privileg = 'ALL PRIVILEGES'));
        RReplClient      := (RReplClient      or (Privileg = 'REPLICATION CLIENT')      or (Privileg = 'ALL PRIVILEGES')) and (Users.Client.ServerVersion >= 40002);
        RReplSlave       := (RReplSlave       or (Privileg = 'REPLICATION SLAVE')       or (Privileg = 'ALL PRIVILEGES')) and (Users.Client.ServerVersion >= 40002);
        RSelect          := (RSelect          or (Privileg = 'SELECT')                  or (Privileg = 'ALL PRIVILEGES'));
        RShowDatabases   := (RShowDatabases   or (Privileg = 'SHOW DATABASES')          or (Privileg = 'ALL PRIVILEGES')) and (Users.Client.ServerVersion >= 40002);
        RShowView        := (RShowView        or (Privileg = 'SHOW VIEW')               or (Privileg = 'ALL PRIVILEGES')) and (Users.Client.ServerVersion >= 50001);
        RShutdown        := (RShutdown        or (Privileg = 'SHUTDOWN')                or (Privileg = 'ALL PRIVILEGES'));
        RSuper           := (RSuper           or (Privileg = 'SUPER')                   or (Privileg = 'ALL PRIVILEGES')) and (Users.Client.ServerVersion >= 40002);
        RTrigger         := (RTrigger         or (Privileg = 'TRIGGER')                 or (Privileg = 'ALL PRIVILEGES')) and (Users.Client.ServerVersion >= 50106);
        RUpdate          := (RUpdate          or (Privileg = 'UPDATE')                  or (Privileg = 'ALL PRIVILEGES'));
      end;
  end;

var
  DatabaseName: string;
  FieldName: string;
  FunctionName: string;
  Grant: Boolean;
  I: Integer;
  Index: Integer;
  NewRights: array of TCUserRight;
  Parse: TSQLParse;
  Privileg: string;
  ProcedureName: string;
  ProxyName: string;
  RawPassword: string;
  TableName: string;
begin
  Actual := True;

  if (SQLCreateParse(Parse, PChar(SQL), Length(SQL), Users.Client.ServerVersion)) then
    while (not SQLParseEnd(Parse)) do
    begin
      if (not SQLParseKeyword(Parse, 'GRANT')) then raise EConvertError.CreateFmt(SSourceParseError, [Name, 46, SQL]);

      repeat
        Privileg := '';
        while (not SQLParseChar(Parse, '(', False) and not SQLParseChar(Parse, ',') and not SQLParseKeyword(Parse, 'ON', False)) do
        begin
          if (Privileg <> '') then Privileg := Privileg + ' ';
          Privileg := Privileg + SQLParseValue(Parse);
        end;

        if (Privileg = 'PROXY') then
        else if (not SQLParseChar(Parse, '(')) then
        begin
          Index := -1;
          for I := 0 to Length(NewRights) - 1 do
            if (NewRights[I].FieldName = '') then
              Index := I;

          if (Index < 0) then
          begin
            SetLength(NewRights, Length(NewRights) + 1);
            Index := Length(NewRights) - 1;
            NewRights[Index] := TCUserRight.Create();
          end;

          AddPrivileg(NewRights[Index], Privileg);
        end
        else
        begin
          repeat
            FieldName := SQLParseValue(Parse);

            Index := -1;
            for I := 0 to Length(NewRights) - 1 do
              if (lstrcmpi(PChar(NewRights[I].FieldName), PChar(FieldName)) = 0) then
                Index := I;

            if (Index < 0) then
            begin
              SetLength(NewRights, Length(NewRights) + 1);
              Index := Length(NewRights) - 1;
              NewRights[Index] := TCUserRight.Create();
              NewRights[Index].FieldName := FieldName;
            end;

            AddPrivileg(NewRights[Index], Privileg);
          until (not SQLParseChar(Parse, ','));
          if (not SQLParseChar(Parse, ')')) then raise EConvertError.CreateFmt(SSourceParseError, [Name, 48, SQL]);
        end;
      until (SQLParseKeyword(Parse, 'ON'));

      DatabaseName := ''; TableName := ''; ProcedureName := ''; FunctionName := ''; RawPassword := '';

      if (Privileg = 'PROXY') then
        ProxyName := SQLParseValue(Parse)
      else if (SQLParseKeyword(Parse, 'PROCEDURE')) then
      begin
        ProcedureName := SQLParseValue(Parse);
        if (SQLParseChar(Parse, '.')) then
        begin
          DatabaseName := ProcedureName;
          ProcedureName := SQLParseValue(Parse);
        end;
      end
      else if (SQLParseKeyword(Parse, 'FUNCTION')) then
      begin
        FunctionName := SQLParseValue(Parse);
        if (SQLParseChar(Parse, '.')) then
        begin
          DatabaseName := FunctionName;
          FunctionName := SQLParseValue(Parse);
        end;
      end
      else
      begin
        SQLParseKeyword(Parse, 'TABLE');

        TableName := SQLParseValue(Parse);
        if (SQLParseChar(Parse, '.')) then
        begin
          DatabaseName := TableName;
          TableName := SQLParseValue(Parse);
        end;
      end;

      if (DatabaseName = '*') then DatabaseName := '';
      if (TableName = '*') then TableName := '';

      if (not SQLParseKeyword(Parse, 'TO')) then raise EConvertError.CreateFmt(SSourceParseError, [Name, 49, SQL]);

      FName := SQLParseValue(Parse);

      if (SQLParseKeyword(Parse, 'IDENTIFIED BY')) then
      begin
        SQLParseKeyword(Parse, 'PASSWORD');
        RawPassword := SQLParseValue(Parse);
      end;

      if (SQLParseKeyword(Parse, 'REQUIRE')) then
        repeat SQLParseValue(Parse); until (SQLParseChar(Parse, ';') or SQLParseKeyword(Parse, 'WITH', False));

      Grant := False;
      if (SQLParseKeyword(Parse, 'WITH')) then
        repeat
          if (SQLParseKeyword(Parse, 'GRANT OPTION')) then
            Grant := True
          else if (SQLParseKeyword(Parse, 'MAX_QUERIES_PER_HOUR')) then
            QueriesPerHour := StrToInt(SQLParseValue(Parse))
          else if (SQLParseKeyword(Parse, 'MAX_UPDATES_PER_HOUR')) then
            UpdatesPerHour := StrToInt(SQLParseValue(Parse))
          else if (SQLParseKeyword(Parse, 'MAX_CONNECTIONS_PER_HOUR')) then
            ConnectionsPerHour := StrToInt(SQLParseValue(Parse))
          else if (SQLParseKeyword(Parse, 'MAX_USER_CONNECTIONS')) then
            UserConnections := StrToInt(SQLParseValue(Parse))
          else
            SQLParseValue(Parse);
        until (SQLParseChar(Parse, ';', False) or SQLParseEnd(Parse));

      if (not SQLParseChar(Parse, ';')) then raise EConvertError.CreateFmt(SSourceParseError, [Name, 50, SQL]);

      for I := 0 to Length(NewRights) - 1 do
        if (Privileg <> 'PROXY') then
        begin
          NewRights[I].DatabaseName := DatabaseName;
          NewRights[I].TableName := TableName;
          NewRights[I].ProcedureName := ProcedureName;
          NewRights[I].FunctionName := FunctionName;
          NewRights[I].FRawPassword := RawPassword;
          NewRights[I].RGrant := NewRights[I].RGrant or Grant;
          AddRight(NewRights[I]);
        end;

      for I := 0 to Length(NewRights) - 1 do
        FreeAndNil(NewRights[I]);
      SetLength(NewRights, 0);
    end;
end;

function TCUser.RightByCaption(const Caption: string): TCUserRight;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to FRights.Count - 1 do
    if (Right[I].Caption = Caption) then
      Result := Right[I];
end;

procedure TCUser.SetName(const AName: string);
begin
  inherited;

  if ((Pos('@', FName) = 0) and (FName <> '')) then
    Name := FName + '@%';
end;

function TCUser.UpdateRight(const UserRight,  NewUserRight: TCUserRight): Boolean;
var
  Index: Integer;
begin
  Index := IndexOf(UserRight);

  Result := Index >= 0;
  if (Result) then
    Right[Index].Assign(NewUserRight);
end;

{ TCUsers *********************************************************************}

function TCUsers.Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean;
var
  Index: Integer;
  Parse: TSQLParse;
  Update: Boolean;
  UserName: string;
begin
  Update := False; Index := -1;

  if (not DataSet.IsEmpty()) then
    repeat
      if (not UseInformationSchema) then
        UserName := DataSet.FieldByName('User').AsString + '@' + DataSet.FieldByName('Host').AsString
      else if (SQLCreateParse(Parse, PChar(DataSet.FieldByName('GRANTEE').AsString), Length(DataSet.FieldByName('GRANTEE').AsString), Client.ServerVersion)) then
        UserName := SQLParseValue(Parse);

      Index := IndexByName(UserName);
      Update := Index >= 0;

      if (not Update) then
        Index := Add(TCUser.Create(Self, UserName));
    until (not DataSet.FindNext());

  Result := inherited;

  if ((DataSet.RecordCount = 1) and Update) then
    Client.ExecuteEvent(ceUpdated, Self, User[Index])
  else
    Client.ExecuteEvent(ceBuild, Self, nil);
end;

function TCUsers.GetActual(): Boolean;
begin
  Result := (Assigned(Client.UserRights) and not Client.UserRights.RGrant) or inherited;
end;

function TCUsers.GetUser(Index: Integer): TCUser;
begin
  Result := TCUser(Items[Index]);
end;

function TCUsers.SQLGetItems(const Name: string = ''): string;
begin
  if (not Client.UseInformationSchema or (Client.ServerVersion < 50002)) then
    Result := 'SELECT * FROM ' + Client.EscapeIdentifier('mysql') + '.' + Client.EscapeIdentifier('user') + ';' + #13#10
  else
    Result := 'SELECT * FROM ' + Client.EscapeIdentifier(information_schema) + '.' + Client.EscapeIdentifier('USER_PRIVILEGES') + ' GROUP BY ' + Client.EscapeIdentifier('GRANTEE') + ';' + #13#10;
end;

{ TCHostDatabase **************************************************************}

procedure TCHostDatabase.Assign(const Source: TCHostDatabase);
begin
  inherited Assign(Source);

  OriginalName := Source.OriginalName;
  RAlter := Source.RAlter;
  RCreate := Source.RCreate;
  RCreateTempTable := Source.RCreateTempTable;
  RCreateView := Source.RCreateView;
  RDelete := Source.RDelete;
  RDrop := Source.RDrop;
  RGrant := Source.RGrant;
  RIndex := Source.RIndex;
  RInsert := Source.RInsert;
  RLockTables := Source.RLockTables;
  RReferences := Source.RReferences;
  RSelect := Source.RSelect;
  RShowView := Source.RShowView;
  RUpdate := Source.RUpdate;
end;

procedure TCHostDatabase.Clear();
begin
  Name := '';
  RAlter := False;
  RCreate := False;
  RCreateTempTable := False;
  RCreateView := False;
  RDelete := False;
  RDrop := False;
  RGrant := False;
  RIndex := False;
  RInsert := False;
  RLockTables := False;
  RReferences := False;
  RSelect := False;
  RShowView := False;
  RUpdate := False;
end;

{ TCHostDatabases *************************************************************}

function TCHostDatabases.AddDatabase(const NewDatabase: TCHostDatabase): Boolean;
var
  I: Integer;
  Index: Integer;
begin
  Result := not Assigned(Host.DatabaseByName(NewDatabase.Name));

  if (Result) then
  begin
    Index := TList(Self).Count;
    for I := TList(Self).Count - 1 downto 0 do
      if (Host.Hosts.Client.TableNameCmp(NewDatabase.Name, Database[I].Name) < 0) then
        Index := I;

    Insert(Index, TCHostDatabase.Create());
    Database[Index].Assign(NewDatabase);
    Database[Index].OriginalName := Database[Index].Name;
  end;
end;

procedure TCHostDatabases.Assign(const Source: TCHostDatabases);
var
  I: Integer;
begin
  if (not Assigned(FHost)) then FHost := Source.Host;

  for I := 0 to Count - 1 do
  begin
    inherited Add(TCHostDatabase.Create());
    Database[I].Assign(Source.Database[I]);
  end;
end;

constructor TCHostDatabases.Create(const AHost: TCHost);
begin
  inherited Create();

  FHost := AHost;
end;

procedure TCHostDatabases.DeleteDatabase(const Database: TCHostDatabase);
var
  Index: Integer;
begin
  Index := IndexOf(Database);

  Self.Database[Index].Free();
  Delete(Index);
end;

function TCHostDatabases.GetDatabase(Index: Integer): TCHostDatabase;
begin
  Result := TCHostDatabase(Items[Index]);
end;

function TCHostDatabases.UpdateDatabase(const Database, NewDatabase: TCHostDatabase): Boolean;
begin
  Result := Assigned(Database) and not Assigned(Host.DatabaseByName(NewDatabase.Name)) or (Host.DatabaseByName(NewDatabase.Name) = Database);

  if (Result) then
    Database.Assign(NewDatabase);
end;

{ TCHost **********************************************************************}

procedure TCHost.Assign(const Source: TCHost);
begin
  inherited Assign(Source);

  if (Assigned(Source.Hosts)) then FHosts := Source.Hosts;

  OriginalHost := Source.OriginalHost;

  Databases.Assign(Source.Databases);
end;

procedure TCHost.Clear();
begin
  inherited;

  FDatabases.Clear();
end;

constructor TCHost.Create(const AHosts: TCHosts; const AHost: string = '');
begin
  FDatabases := TCHostDatabases.Create(Self);

  inherited Create(AHosts.Client);

  FHosts := AHosts;
end;

function TCHost.DatabaseByName(const DatabaseName: string): TCHostDatabase;
var
  Index: Integer;
begin
  Index := Databases.IndexByName(DatabaseName);
  if (Index < 0) then
    Result := nil
  else
    Result := Databases[Index];
end;

destructor TCHost.Destroy();
begin
  FDatabases.Free();

  inherited;
end;

function TCHost.GetCaption(): string;
begin
  if (Name = '') then
    Result := '<' + Preferences.LoadStr(327) + '>'
  else
    Result := Name;
end;

function TCHost.GetSource(): string;
var
  DataSet: TMySQLQuery;
  I: Integer;
begin
  if (FSource = '') then
  begin
    DataSet := TMySQLQuery.Create(nil);
    DataSet.Connection := Hosts.Client;
    DataSet.CommandText := 'SELECT * FROM ' + Hosts.Client.EscapeIdentifier('mysql') + '.' + Hosts.Client.EscapeIdentifier('host') + ' WHERE ' + Hosts.Client.EscapeIdentifier('Host') + '=' + SQLEscape(Name);
    DataSet.Open();
    if (DataSet.Active and not DataSet.IsEmpty()) then
      repeat
        FSource := FSource + 'INSERT INTO ' + Hosts.Client.EscapeIdentifier('mysql') + '.' + Hosts.Client.EscapeIdentifier('host') + ' SET ';
        for I := 0 to DataSet.FieldCount - 1 do
        begin
          if (I > 0) then FSource := FSource + ',';
          FSource := FSource + Hosts.Client.EscapeIdentifier(DataSet.Fields[I].FieldName) + '=' + SQLEscape(DataSet.Fields[I].AsString);
        end;
        FSource := FSource + ';' + #13#10;
      until (not DataSet.FindNext());
    DataSet.Free();
  end;

  Result := inherited GetSource();
end;

function TCHost.Initialize(): Boolean;
begin
  Result := Client.Initialize();
end;

{ TCHosts *********************************************************************}

function TCHosts.Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean;
var
  HostName: string;
  Index: Integer;
  NewHostDatabase: TCHostDatabase;
  Update: Boolean;
begin
  Update := False; Index := -1;

  if (not DataSet.IsEmpty()) then
    repeat
      HostName := DataSet.FieldByName('Host').AsString;

      Index := IndexByName(HostName);
      Update := Index >= 0;

      if (not Update) then
        Index := Add(TCHost.Create(Self, HostName));

      Host[Index].OriginalHost := Host[Index].Name;

      NewHostDatabase := TCHostDatabase.Create();
      NewHostDatabase.Name := DataSet.FieldByName('Db').AsString;
      NewHostDatabase.RAlter := DataSet.FieldByName('Alter_priv').AsBoolean;
      NewHostDatabase.RCreate := DataSet.FieldByName('Create_priv').AsBoolean;
      if (Assigned(DataSet.FindField('Create_tmp_table_priv'))) then
        NewHostDatabase.RCreateTempTable := DataSet.FieldByName('Create_tmp_table_priv').AsBoolean;
      if (Assigned(DataSet.FindField('Create_view_priv'))) then
        NewHostDatabase.RCreateView := DataSet.FieldByName('Create_view_priv').AsBoolean;
      NewHostDatabase.RDelete := DataSet.FieldByName('Delete_priv').AsBoolean;
      NewHostDatabase.RDrop := DataSet.FieldByName('Drop_priv').AsBoolean;
      NewHostDatabase.RGrant := DataSet.FieldByName('Grant_priv').AsBoolean;
      NewHostDatabase.RIndex := DataSet.FieldByName('Index_priv').AsBoolean;
      NewHostDatabase.RInsert := DataSet.FieldByName('Insert_priv').AsBoolean;
      if (Assigned(DataSet.FindField('Lock_tables_priv'))) then
        NewHostDatabase.RLockTables := DataSet.FieldByName('Lock_tables_priv').AsBoolean;
      NewHostDatabase.RReferences := DataSet.FieldByName('References_priv').AsBoolean;
      NewHostDatabase.RSelect := DataSet.FieldByName('Select_priv').AsBoolean;
      if (Assigned(DataSet.FindField('Show_view_priv'))) then
        NewHostDatabase.RShowView := DataSet.FieldByName('Show_view_priv').AsBoolean;
      NewHostDatabase.RUpdate := DataSet.FieldByName('Update_priv').AsBoolean;

      Host[Index].Databases.AddDatabase(NewHostDatabase);

      FreeAndNil(NewHostDatabase);
    until (not DataSet.FindNext());

  Result := inherited;

  if ((DataSet.RecordCount = 1) and Update) then
    Client.ExecuteEvent(ceUpdated, Self, Host[Index])
  else
    Client.ExecuteEvent(ceBuild, Self, nil);
end;

function TCHosts.GetActual(): Boolean;
begin
  Result := (Assigned(Client.UserRights) and not Client.UserRights.RGrant) or inherited;
end;

function TCHosts.GetHost(Index: Integer): TCHost;
begin
  Result := TCHost(Items[Index]);
end;

function TCHosts.SQLGetItems(const Name: string = ''): string;
begin
  Result := 'SELECT * FROM ' + Client.EscapeIdentifier('mysql') + '.' + Client.EscapeIdentifier('host') + ';' + #13#10;
end;

{ TCClient ****************************************************************}

function TCClient.AddDatabase(const NewDatabase: TCDatabase): Boolean;
begin
  Result := UpdateDatabase(nil, NewDatabase);

  if (Result and (Account.Connection.Database <> '')) then
    Account.Connection.Database := Account.Connection.Database + ',' + CSVEscape(NewDatabase.Name);
end;

function TCClient.AddHost(const NewHost: TCHost): Boolean;
begin
  Result := UpdateHost(nil, NewHost);
end;

function TCClient.AddUser(const ANewUser: TCUser): Boolean;
begin
  Result := UpdateUser(nil, ANewUser);
end;

procedure TCClient.DoAfterExecuteSQL();
begin
  inherited;

  ExecuteEvent(ceAfterExecuteSQL);
end;

procedure TCClient.DoBeforeExecuteSQL();
begin
  ExecuteEvent(ceBeforeExecuteSQL);

  inherited;
end;

procedure TCClient.BuildUser(const DataSet: TMySQLQuery);
var
  S: string;
  Update: Boolean;
begin
  Update := Assigned(FUser);
  if (Update) then
    FUser.Free();

  FUser := TCUser.Create(Users);
  S :='';
  if (not DataSet.IsEmpty()) then
    repeat
      S := S + DataSet.Fields[0].AsString + ';' + #13#10;
    until (not DataSet.FindNext());
  FUser.SetSource(S);
  if (FUser.Name = '') then
    if (FCurrentUser <> '') then
      FUser.FName := FCurrentUser
    else
      FUser.FName := Username;

  if (not Assigned(Hosts) and (not Assigned(UserRights) or UserRights.RGrant)) then
    FHosts := TCHosts.Create(Self);
  if (not Assigned(Processes) and ((ServerVersion < 50000) or not Assigned(UserRights) or UserRights.RProcess)) then
    FProcesses := TCProcesses.Create(Self);

  if ((DataSet.RecordCount = 1) and Update) then
    ExecuteEvent(ceUpdated, Self, User)
  else
    ExecuteEvent(ceBuild, Self, User);
end;

procedure TCClient.ConnectChange(Sender: TObject; Connecting: Boolean);
const
  BufferSize = 10240;
var
  Buffer: Pointer;
  DataSet: TMySQLQuery;
  Equal: Integer;
  I: Integer;
  Icon: TIcon;
  Index: Cardinal;
  Internet: HInternet;
  L: Longint;
  Request: HInternet;
  Size: Cardinal;
  StatusCode: array [0..4] of Char;
  Stream: TStringStream;
  Success: Boolean;
  URL1: string;
  URL2: string;
begin
  if (not Assigned(FEngines) and Connecting) then
  begin
    if (not Assigned(FCollations) and (ServerVersion >= 40100)) then FCollations := TCCollations.Create(Self);
    if (not Assigned(FFieldTypes)) then FFieldTypes := TCFieldTypes.Create(Self);
    if (not Assigned(FEngines)) then FEngines := TCEngines.Create(Self);
    if (not Assigned(FPlugins) and (ServerVersion >= 50105)) then FPlugins := TCPlugins.Create(Self);
    if (not Assigned(FStati)) then FStati := TCStati.Create(Self);
    if (not Assigned(FUsers)) then FUsers := TCUsers.Create(Self);

    if (Assigned(Account) and not Account.IconFetched and not FileExists(Account.IconFilename) and not HostIsLocalHost(Host)) then
    begin
      Internet := InternetOpen(PChar(Application.Title), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);

      if (Assigned(Internet)) then
      begin
        L := 3 * 1000;
        InternetSetOption(Internet, INTERNET_OPTION_CONNECT_TIMEOUT, @L, SizeOf(L));
        InternetSetOption(Internet, INTERNET_OPTION_SEND_TIMEOUT, @L, SizeOf(L));
        InternetSetOption(Internet, INTERNET_OPTION_RECEIVE_TIMEOUT, @L, SizeOf(L));

        if (LibraryType <> ltHTTP) then
        begin
          Request := InternetOpenURL(Internet, PChar('http://' + Host + '/favicon.ico'), nil, 0, 0, 0);
          if (not Assigned(Request) and (Pos('www.', LowerCase(Host)) = 0)) then
            Request := InternetOpenURL(Internet, PChar('http://' + 'www.' + Host + '/favicon.ico'), nil, 0, 0, 0);
        end
        else
        begin
          Request := InternetOpenURL(Internet, PChar('http://' + ExtractURIHost(LibraryName) + '/favicon.ico'), nil, 0, INTERNET_FLAG_NO_AUTO_REDIRECT, 0);
          if (not Assigned(Request) and (Pos('www.', LowerCase(Host)) = 0)) then
            Request := InternetOpenURL(Internet, PChar('http://' + string('www.' + ExtractURIHost(LibraryName)) + '/favicon.ico'), nil, 0, INTERNET_FLAG_NO_AUTO_REDIRECT, 0);
        end;

        if (Assigned(Request)) then
        begin
          GetMem(Buffer, BufferSize);
          Stream := TStringStream.Create('');

          repeat
            Success := InternetReadFile(Request, Buffer, BufferSize, Size);
            if (Success and (Size > 0)) then
              Stream.Write(Buffer^, Size);
          until (Success and (Size = 0));

          try
            Size := SizeOf(StatusCode); Index := 0;
            if (HttpQueryInfo(Request, HTTP_QUERY_STATUS_CODE, @StatusCode, Size, Index) and (StrToInt(StatusCode) = HTTP_STATUS_OK)) then
            begin
              Icon := TIcon.Create();
              Stream.Seek(0, soFromBeginning);
              Icon.LoadFromStream(Stream);
              Preferences.SmallImages.AddIcon(Icon);
              Account.ImageIndex := Preferences.SmallImages.Count - 1;

              if (ForceDirectories(ExtractFilePath(Account.IconFilename))) then
                Icon.SaveToFile(Account.IconFilename);
              Icon.Free();
            end;
          except
          end;

          FreeAndNil(Stream);
          FreeMem(Buffer);

          InternetCloseHandle(Request);
        end;

        InternetCloseHandle(Internet);

        Account.IconFetched := True;
      end;
    end;

    if (Assigned(Account)) then
    begin
      Account.LastLogin := Now();

      if ((ServerVersion > 40100) and not Account.ManualURLFetched) then
      begin
        BeginSilent();

        DataSet := TMySQLQuery.Create(nil);
        DataSet.Connection := Self;

        DataSet.CommandText := 'HELP ' + SQLEscape('SELECT');
        DataSet.Open();
        if (not DataSet.Active or not Assigned(DataSet.FindField('name')) or DataSet.IsEmpty()) then
          URL1 := ''
        else
        begin
          URL1 := DataSet.FieldByName('description').AsString;
          while (Pos('URL:', URL1) > 1) do Delete(URL1, 1, Pos('URL:', URL1) - 1);
          if (Pos('URL:', URL1) = 1) then Delete(URL1, 1, Length('URL:'));
          URL1 := Trim(URL1);
        end;
        DataSet.Close();

        DataSet.CommandText := 'HELP ' + SQLEscape('VERSION');
        DataSet.Open();
        if (not DataSet.Active or not Assigned(DataSet.FindField('name')) or DataSet.IsEmpty()) then
          URL2 := ''
        else
        begin
          URL2 := DataSet.FieldByName('description').AsString;
          while (Pos('URL:', URL2) > 1) do Delete(URL2, 1, Pos('URL:', URL2) - 1);
          if (Pos('URL:', URL2) = 1) then Delete(URL2, 1, Length('URL:'));
          URL2 := Trim(URL2);
        end;

        DataSet.Free();

        EndSilent();

        Equal := 0;
        for I := 1 to Min(Length(URL1), Length(URL2)) - 1 do
          if ((URL1[I] = URL2[I]) and (Equal = I - 1)) then
            Equal := I + 1;

        if (Copy(URL1, 1, 7) = 'http://') then
          Account.ManualURL := Copy(URL1, 1, Equal - 1);
        Account.ManualURLFetched := True;
      end;
    end;
  end;
end;

function TCClient.CharsetByName(const CharsetName: string): TCCharset;
var
  Index: Integer;
begin
  Index := Charsets.IndexByName(CharsetName);
  if (Index < 0) then
    Result := nil
  else
    Result := Charsets[Index];
end;

function TCClient.CharsetByCollation(const Collation: string): TCCharset;
var
  I: Integer;
begin
  Result := nil;

  if (Assigned(Collations)) then
    for I := 0 to Collations.Count - 1 do
      if (Collations[I].Name = Collation) then
        Result := Collations[I].Charset;
end;

procedure TCClient.Clear();
begin
  FDatabases.Clear();
  if (Assigned(FHosts)) then FHosts.Clear();
  if (Assigned(FPlugins)) then FPlugins.Clear();
  if (Assigned(FProcesses)) then FProcesses.Clear();
  if (Assigned(FStati)) then FStati.Clear();
  if (Assigned(FUsers)) then FUsers.Clear();
  FVariables.Clear();

  FCurrentUser := '';
  if (Assigned(FUser)) then
    FreeAndNil(FUser);
end;

function TCClient.ClientResult(const Connection: TMySQLConnection; const Data: Boolean): Boolean;
var
  DatabaseName: string;
  DataSet: TMySQLQuery;
  Field: Integer;
  FunctionName: string;
  I: Integer;
  Name: string;
  Parse: TSQLParse;
begin
  Result := False;

  DataSet := TMySQLQuery.Create(nil);
  DataSet.Connection := Connection;
  DataSet.Open();

  if (SQLCreateParse(Parse, PChar(DataSet.CommandText), Length(DataSet.CommandText), ServerVersion)) then
    if (SQLParseKeyword(Parse, 'SELECT')) then
    begin
      DatabaseName := DataSet.DatabaseName;
      if (SQLParseChar(Parse, '*') and SQLParseKeyword(Parse, 'FROM') and SQLParseObjectName(Parse, DatabaseName, Name)) then
      begin
        if (TableNameCmp(DatabaseName, information_schema) = 0) then
        begin
          if (TableNameCmp(Name, 'CHARACTER_SETS') = 0) then
            Result := Charsets.Build(DataSet, True)
          else if (TableNameCmp(Name, 'COLLATIONS') = 0) then
            Result := Collations.Build(DataSet, True)
          else if ((TableNameCmp(Name, 'COLUMNS') = 0) and SQLParseKeyword(Parse, 'WHERE') and (UpperCase(SQLParseValue(Parse)) = 'TABLE_SCHEMA') and SQLParseChar(Parse, '=')) then
            DatabaseByName(SQLParseValue(Parse)).Tables.BuildViewFields(DataSet, True)
          else if (TableNameCmp(Name, 'ENGINES') = 0) then
            Result := Engines.Build(DataSet, True)
          else if (TableNameCmp(Name, 'EVENTS') = 0) then
          begin
            if (SQLParseKeyword(Parse, 'WHERE') and (UpperCase(SQLParseValue(Parse)) = 'EVENT_SCHEMA') and SQLParseChar(Parse, '=')) then
              Result := DatabaseByName(SQLParseValue(Parse)).Events.Build(DataSet, True)
            else
              for I := 0 to Databases.Count - 1 do
                Result := Databases[I].Events.Build(DataSet, True);
          end
          else if (TableNameCmp(Name, 'PLUGINS') = 0) then
            Result := Plugins.Build(DataSet, True)
          else if (TableNameCmp(Name, 'PROCESSLIST') = 0) then
            Result := Processes.Build(DataSet, True)
          else if (TableNameCmp(Name, 'ROUTINES') = 0) then
          begin
            if (SQLParseKeyword(Parse, 'WHERE') and (UpperCase(SQLParseValue(Parse)) = 'ROUTINE_SCHEMA') and SQLParseChar(Parse, '=')) then
              Result := DatabaseByName(SQLParseValue(Parse)).Routines.Build(DataSet, True)
            else
              for I := 0 to Databases.Count - 1 do
                Result := Databases[I].Routines.Build(DataSet, True);
          end
          else if (TableNameCmp(Name, 'SESSION_STATUS') = 0) then
            Result := Stati.Build(DataSet, True)
          else if (TableNameCmp(Name, 'SESSION_VARIABLES') = 0) then
            Result := Variables.Build(DataSet, True)
          else if (TableNameCmp(Name, 'SCHEMATA') = 0) then
            Result := Databases.Build(DataSet, True)
          else if (TableNameCmp(Name, 'TABLES') = 0) then
          begin
            if (SQLParseKeyword(Parse, 'WHERE') and (UpperCase(SQLParseValue(Parse)) = 'TABLE_SCHEMA') and SQLParseChar(Parse, '=')) then
              Result := DatabaseByName(SQLParseValue(Parse)).Tables.Build(DataSet, True)
            else
              for I := 0 to Databases.Count - 1 do
                Result := Databases[I].Tables.Build(DataSet, True);
          end
          else if (TableNameCmp(Name, 'TRIGGERS') = 0) then
          begin
            if (SQLParseKeyword(Parse, 'WHERE') and (UpperCase(SQLParseValue(Parse)) = 'EVENT_OBJECT_SCHEMA') and SQLParseChar(Parse, '=')) then
              Result := DatabaseByName(SQLParseValue(Parse)).Triggers.Build(DataSet, True)
            else
              for I := 0 to Databases.Count - 1 do
                Result := Databases[I].Triggers.Build(DataSet, True);
          end
          else if ((TableNameCmp(Name, 'USER_PRIVILEGES') = 0)) then
            Result := Users.Build(DataSet, True)
          else
            raise EConvertError.CreateFmt(SUnknownSQLStmt, [DataSet.CommandText]);
        end
        else if (TableNameCmp(DatabaseName, 'mysql') = 0) then
        begin
          if (TableNameCmp(Name, 'host') = 0) then
            Result := Hosts.Build(DataSet, False)
          else if (TableNameCmp(Name, 'user') = 0) then
            Result := Users.Build(DataSet, False);
        end;
      end
      else if (FCurrentUser = '') then
      begin
        Field := 0;
        repeat
          FunctionName := SQLParseValue(Parse);
          if (SQLParseChar(Parse, '(', False)) then
            FunctionName := FunctionName + SQLParseValue(Parse);
          if (lstrcmpi(PChar(FunctionName), 'CURRENT_USER()') = 0) then
            FCurrentUser := DataSet.Fields[Field].AsString
          else if (lstrcmpi(PChar(FunctionName), 'SYSDATE()') = 0) then
          begin
            if (TryStrToDateTime(DataSet.Fields[0].AsString, TimeDiff, FormatSettings)) then
              TimeDiff := TimeDiff - Now();
          end
          else if (lstrcmpi(PChar(FunctionName), 'USER()') = 0) then
            FCurrentUser := DataSet.Fields[Field].AsString;
          Inc(Field);
        until (not SQLParseChar(Parse, ','));
      end;
    end
    else if (SQLParseKeyword(Parse, 'SHOW')) then
    begin
      DatabaseName := DataSet.DatabaseName;
      if (SQLParseKeyword(Parse, 'CHARACTER SET')) then
        Result := Charsets.Build(DataSet, False)
      else if (SQLParseKeyword(Parse, 'COLLATION')) then
        Result := Collations.Build(DataSet, False)
      else if (SQLParseKeyword(Parse, 'CREATE')) then
      begin
        if (SQLParseKeyword(Parse, 'DATABASE')) then
          DatabaseByName(SQLParseValue(Parse)).SetSource(DataSet)
        else if (SQLParseKeyword(Parse, 'EVENT')) then
          begin if (SQLParseObjectName(Parse, DatabaseName, Name)) then DatabaseByName(DatabaseName).EventByName(Name).SetSource(DataSet); end
        else if (SQLParseKeyword(Parse, 'FUNCTION')) then
          begin if (SQLParseObjectName(Parse, DatabaseName, Name)) then DatabaseByName(DatabaseName).FunctionByName(Name).SetSource(DataSet); end
        else if (SQLParseKeyword(Parse, 'PROCEDURE')) then
          begin if (SQLParseObjectName(Parse, DatabaseName, Name)) then DatabaseByName(DatabaseName).ProcedureByName(Name).SetSource(DataSet); end
        else if (SQLParseKeyword(Parse, 'TABLE')) then
          begin if (SQLParseObjectName(Parse, DatabaseName, Name)) then DatabaseByName(DatabaseName).TableByName(Name).SetSource(DataSet); end
        else if (SQLParseKeyword(Parse, 'TRIGGER')) then
          begin if (SQLParseObjectName(Parse, DatabaseName, Name)) then DatabaseByName(DatabaseName).TriggerByName(Name).SetSource(DataSet); end
        else if (SQLParseKeyword(Parse, 'VIEW')) then
          begin if (SQLParseObjectName(Parse, DatabaseName, Name)) then DatabaseByName(DatabaseName).TableByName(Name).SetSource(DataSet); end;
      end
      else if (SQLParseKeyword(Parse, 'DATABASES')) then
        Result := Databases.Build(DataSet, False)
      else if (SQLParseKeyword(Parse, 'ENGINES')) then
        Result := Engines.Build(DataSet, False)
      else if (SQLParseKeyword(Parse, 'GRANTS')) then
      begin
        if ((SQLParseKeyword(Parse, 'FOR') and (SQLParseKeyword(Parse, 'CURRENT_USER') or (lstrcmpi(PChar(SQLParseValue(Parse)), PChar(CurrentUser)) = 0)))) then
          BuildUser(DataSet);
      end
      else if (SQLParseKeyword(Parse, 'PLUGINS')) then
        Result := Plugins.Build(DataSet, False)
      else if (SQLParseKeyword(Parse, 'FULL PROCESSLIST')
        or SQLParseKeyword(Parse, 'PROCESSLIST')) then
        Result := Processes.Build(DataSet, False)
      else if (SQLParseKeyword(Parse, 'STATUS')
        or SQLParseKeyword(Parse, 'SESSION STATUS')) then
        Result := Stati.Build(DataSet, False)
      else if (SQLParseKeyword(Parse, 'VARIABLES')
        or SQLParseKeyword(Parse, 'SESSION VARIABLES')) then
        Result := Variables.Build(DataSet, False)
      else if (SQLParseKeyword(Parse, 'FULL TABLES')
        or SQLParseKeyword(Parse, 'TABLES')) then
      begin
        if (not SQLParseKeyword(Parse, 'FROM') or SQLParseKeyword(Parse, 'IN')) then
          DatabaseName := Self.DatabaseName
        else
          DatabaseName := SQLParseValue(Parse);
        Result := DatabaseByName(DatabaseName).Tables.Build(DataSet, False);
      end
      else if (SQLParseKeyword(Parse, 'TABLE STATUS')) then
      begin
        if (not SQLParseKeyword(Parse, 'FROM') or SQLParseKeyword(Parse, 'IN')) then
          DatabaseName := Self.DatabaseName
        else
          DatabaseName := SQLParseValue(Parse);
        Result := DatabaseByName(DatabaseName).Tables.Build(DataSet, False);
      end
      else
        raise EConvertError.CreateFmt(SUnknownSQLStmt, [DataSet.CommandText]);
    end;

  DataSet.Free();
end;

function TCClient.CloneDatabase(const SourceDatabase, TargetDatabase: TCDatabase; const Data: Boolean): Boolean;
var
  I: Integer;
begin
  Result := True;

  for I := 0 to SourceDatabase.Tables.Count - 1 do
    if (Result) then
      if (SourceDatabase.Tables[I] is TCBaseTable) then
        Result := TargetDatabase.CloneTable(SourceDatabase.Tables.BaseTable[I], SourceDatabase.Tables[I].Name, Data);
  TargetDatabase.Clear();
end;

function TCClient.CloneHost(const Host: TCHost; const NewHostHost: string): Boolean;
var
  Index: Integer;
  SQL: string;
begin
  SQL := Host.Source;

  while (Pos(SQLEscape(Host.Name), SQL) > 0) do
  begin
    Index := Pos(SQLEscape(Host.Name), SQL);
    Delete(SQL, Index, Length(SQLEscape(Host.Name)));
    Insert(SQLEscape(NewHostHost), SQL, Index);
  end;

  Result := ExecuteSQL(SQL);

  if (Result) then
  begin
    ExecuteSQL('FLUSH PRIVILEGES;');
    Hosts.Clear();
  end;
end;

function TCClient.CloneUser(const User: TCUser; const NewUserName: string): Boolean;
var
  Index: Integer;
  SQL: string;
begin
  SQL := User.Source;

  while (Pos(SQLEscape(User.Name), SQL) > 0) do
  begin
    Index := Pos(SQLEscape(User.Name), SQL);
    Delete(SQL, Index, Length(SQLEscape(User.Name)));
    Insert(SQLEscape(NewUserName), SQL, Index);
  end;

  Result := ExecuteSQL(SQL);

  if (Result) then
  begin
    ExecuteSQL('FLUSH PRIVILEGES;');
    Users.Clear();
  end;
end;

function TCClient.CollationByName(const CollationName: string): TCCollation;
var
  Index: Integer;
begin
  Index := Collations.IndexByName(CollationName);
  if (Index < 0) then
    Result := nil
  else
    Result := Collations[Index];
end;

procedure TCClient.CommitTransaction();
begin
  inherited;
  AutoCommit := AutoCommitBeforeTransaction;
end;

constructor TCClient.CreateConnection();
begin
  inherited Create(nil);

  EventProcs := TList.Create();
  FCurrentUser := '';
  FInformationSchema := nil;
  FMaxAllowedPacket := 0;
  FPerformanceSchema := nil;
  FAccount := nil;
  SetLength(CachedTables, 0);

  FSQLMonitor := nil;
  StmtMonitor := nil;

  FCharsets := TCCharsets.Create(Self);
  FCollations := nil;
  FDatabases :=  TCDatabases.Create(Self);
  FFieldTypes := nil;
  FEngines := nil;
  FHosts := nil;
  FPlugins := nil;
  FProcesses := nil;
  FStati := nil;
  FUsers := nil;
  FVariables := TCVariables.Create(Self);

  RegisterClient(Self, ConnectChange);
end;

constructor TCClient.CreateConnection(const AAccount: TSAccount);
begin
  inherited Create(nil);

  EventProcs := TList.Create();
  FCurrentUser := '';
  FInformationSchema := nil;
  FMaxAllowedPacket := 0;
  FPerformanceSchema := nil;
  FAccount := AAccount;
  SetLength(CachedTables, 0);

  FSQLMonitor := TMySQLMonitor.Create(nil);
  FSQLMonitor.Connection := Self;
  FSQLMonitor.CacheSize := Preferences.LogSize;
  FSQLMonitor.Enabled := True;
  FSQLMonitor.TraceTypes := [ttRequest];
  if (Preferences.LogResult) then FSQLMonitor.TraceTypes := FSQLMonitor.TraceTypes + [ttInfo];
  if (Preferences.LogTime) then FSQLMonitor.TraceTypes := FSQLMonitor.TraceTypes + [ttTime];
  FSQLMonitor.OnMonitor := MonitorLog;
  StmtMonitor := TMySQLMonitor.Create(nil);
  StmtMonitor.Connection := Self;
  StmtMonitor.Enabled := True;
  StmtMonitor.TraceTypes := [ttResult];
  StmtMonitor.OnMonitor := MonitorExecutedStmts;

  FCharsets := TCCharsets.Create(Self);
  FCollations := nil;
  FDatabases :=  TCDatabases.Create(Self);
  FFieldTypes := nil;
  FEngines := nil;
  FHosts := nil;
  FPlugins := nil;
  FProcesses := nil;
  FStati := nil;
  FUsers := nil;
  FVariables := TCVariables.Create(Self);

  RegisterClient(Self, ConnectChange);
end;

function TCClient.DatabaseByName(const DatabaseName: string): TCDatabase;
var
  Index: Integer;
begin
  Index := Databases.IndexByName(DatabaseName);
  if (Index < 0) then
    Result := nil
  else
    Result := Databases[Index];
end;

procedure TCClient.DecodeInterval(const Value: string; const IntervalType: TMySQLIntervalType; var Year, Month, Day, Quarter, Week, Hour, Minute, Second, MSec: Word);
var
  S: string;
begin
  S := UnescapeValue(Value);

  Year := 0;
  Month := 0;
  Day := 0;
  Quarter := 0;
  Week := 0;
  Hour := 0;
  Minute := 0;
  Second := 0;
  MSec := 0;

  case (IntervalType) of
    itYear: Year := StrToInt(S);
    itQuarter: Quarter := StrToInt(S);
    itMonth: Month := StrToInt(S);
    itDay: Day := StrToInt(S);
    itHour: Hour := StrToInt(S);
    itMinute: Minute := StrToInt(S);
    itWeek: Week := StrToInt(S);
    itSecond: Second := StrToInt(S);
    itMicrosecond: MSec := StrToInt(S);
    itYearMonth: begin Year := StrToInt(Copy(S, 1, Pos('-', S) - 1)); Month := StrToInt(Copy(S, Pos('-', S) - 1, Length(S) - Pos('-', S))); end;
    itDayHour: begin Day := StrToInt(Copy(S, 1, Pos(' ', S) - 1)); Hour := StrToInt(Copy(S, Pos(' ', S) - 1, Length(S) - Pos(' ', S))); end;
    itDayMinute: begin Day := StrToInt(Copy(S, 1, Pos(' ', S) - 1)); DecodeTime(StrToTime(Copy(S, Pos(' ', S) - 1, Length(S) - Pos(' ', S)) + ':00'), Hour, Minute, Second, MSec); end;
    itDaySecond: begin Day := StrToInt(Copy(S, 1, Pos(' ', S) - 1)); DecodeTime(StrToTime(Copy(S, Pos(' ', S) - 1, Length(S) - Pos(' ', S))), Hour, Minute, Second, MSec); end;
    itHourMinute: begin Hour := StrToInt(Copy(S, 1, Pos(':', S) - 1)); Minute := StrToInt(Copy(S, Pos(':', S) - 1, Length(S) - Pos(':', S))); end;
    itHourSecond: DecodeTime(StrToTime(S), Hour, Minute, Second, MSec);
    itMinuteSecond: begin Minute := StrToInt(Copy(S, 1, Pos(':', S) - 1)); Second := StrToInt(Copy(S, Pos(':', S) - 1, Length(S) - Pos(':', S))); end;
    itDayMicrosecond: begin Day := StrToInt(Copy(S, 1, Pos(' ', S) - 1)); DecodeTime(StrToTime(Copy(S, Pos(' ', S) - 1, Length(S) - Pos(' ', S))), Hour, Minute, Second, MSec); end;
    itHourMicrosecond: DecodeTime(StrToTime(S), Hour, Minute, Second, MSec);
    itMinuteMicrosecond: DecodeTime(StrToTime('00:' + S), Hour, Minute, Second, MSec);
    itSecondMicrosecond: begin Second := StrToInt(Copy(S, 1, Pos('.', S) - 1)); MSec := StrToInt(Copy(S, Pos('.', S) - 1, Length(S) - Pos('.', S))); end;
  end;
end;

function TCClient.DeleteDatabase(const Database: TCDatabase): Boolean;
begin
  if (not Assigned(Database)) then
    Result := False
  else
    Result := DeleteDatabases([Database.Name]);
end;

function TCClient.DeleteDatabases(const DatabaseNames: array of string): Boolean;
var
  I: Integer;
  SQL: String;
begin
  SQL := '';
  for I := 0 to Length(DatabaseNames) - 1 do
    SQL := SQL + 'DROP DATABASE ' + EscapeIdentifier(DatabaseNames[I]) + ';' + #13#10;

  Result := ExecuteSQL(SQL);
end;

function TCClient.DeleteHost(const Host: TCHost): Boolean;
begin
  Result := DeleteHosts(Host.Name);
end;

function TCClient.DeleteHosts(Const HostHosts: array of string): Boolean;
var
  I: Integer;
  SQL: string;
begin
  SQL := '';
  for I := 0 to Length(HostHosts) - 1 do
    SQL := SQL + 'DELETE FROM ' + EscapeIdentifier('mysql') + '.' + EscapeIdentifier('host') + ' WHERE ' + EscapeIdentifier('Host') + '=' + SQLEscape(HostHosts[I]) + ';' + #13#10;
  if (SQL <> '') then
    SQL := SQL + 'FLUSH PRIVILEGES;' + #13#10;

  Result := ExecuteSQL(SQL);

  if (Result) then
    Hosts.Clear();
end;

function TCClient.DeletePlugin(const Plugin: TCPlugin): Boolean;
begin
  Result := Assigned(Plugin) and ExecuteSQL('UNINSTALL PLUGIN ' + EscapeIdentifier(Plugin.Name) + ';');

  if (Result) then
    Plugins.Clear();
end;

function TCClient.DeleteProcess(const Process: TCProcess): Boolean;
var
  Ids: string;
begin
  Ids := IntToStr(Process.Id);
  Result := DeleteProcesses(Ids);
end;

function TCClient.DeleteProcesses(const Ids: array of string): Boolean;
var
  I: Byte;
  SQL: string;
begin
  SQL := '';
  for I := 0 to Length(Ids) - 1 do
    if (ServerVersion < 50000) then
      SQL := SQL + 'KILL ' + Ids[I] + ';' + #13#10
    else
      SQL := SQL + 'KILL CONNECTION ' + Ids[I] + ';' + #13#10;

  Result := ExecuteSQL(SQL);

  if (Result) then
    Processes.Clear();
end;

function TCClient.DeleteUser(const User: TCUser): Boolean;
var
  UserNames: string;
begin
  UserNames := User.Name;
  Result := DeleteUsers(UserNames);

  SetLength(UserNames, 0);
end;

function TCClient.DeleteUsers(const UserNames: array of string): Boolean;
var
  I: Integer;
  SQL: string;
  User: TCUser;
begin
  for I := 0 to Length(UserNames) - 1 do
  begin
    User := UserByName(UserNames[I]);

    if (ServerVersion < 40101) then
    begin
      SQL := SQL + 'DELETE FROM ' + EscapeIdentifier('mysql') + '.' + EscapeIdentifier('user')         + ' WHERE ' + EscapeIdentifier('User') + '=' + SQLEscape(User.Name) + ';' + #13#10;
      SQL := SQL + 'DELETE FROM ' + EscapeIdentifier('mysql') + '.' + EscapeIdentifier('db')           + ' WHERE ' + EscapeIdentifier('User') + '=' + SQLEscape(User.Name) + ';' + #13#10;
      SQL := SQL + 'DELETE FROM ' + EscapeIdentifier('mysql') + '.' + EscapeIdentifier('tables_priv')  + ' WHERE ' + EscapeIdentifier('User') + '=' + SQLEscape(User.Name) + ';' + #13#10;
      SQL := SQL + 'DELETE FROM ' + EscapeIdentifier('mysql') + '.' + EscapeIdentifier('columns_priv') + ' WHERE ' + EscapeIdentifier('User') + '=' + SQLEscape(User.Name) + ';' + #13#10;
    end
    else
      SQL := SQL + 'DROP USER ' + EscapeUser(User.Name) + ';' + #13#10;
  end;

  Result := SQL <> '';
  if (Result) then
  begin
    SQL := SQL + 'FLUSH PRIVILEGES;' + #13#10;
    Result := ExecuteSQL(SQL);

    if (Result) then
      Users.Clear();
  end;
end;

destructor TCClient.Destroy();
begin
  UnRegisterClient(Self);

  EventProcs.Free();

  if (Assigned(FSQLEditorResult)) then FSQLEditorResult.Free();
  if (Assigned(FQueryBuilderResult)) then FQueryBuilderResult.Free();

  if (Assigned(FUser)) then FUser.Free();
  if (Assigned(FCharsets)) then FCharsets.Free();
  if (Assigned(FCollations)) then FCollations.Free();
  if (Assigned(FDatabases)) then FDatabases.Free();
  if (Assigned(FEngines)) then FEngines.Free();
  if (Assigned(FFieldTypes)) then FFieldTypes.Free();
  if (Assigned(FHosts)) then FHosts.Free();
  if (Assigned(FPlugins)) then FPlugins.Free();
  if (Assigned(FProcesses)) then FProcesses.Free();
  if (Assigned(FStati)) then FStati.Free();
  if (Assigned(FUsers)) then FUsers.Free();
  if (Assigned(FVariables)) then FVariables.Free();

  if (Assigned(FSQLMonitor)) then
    FSQLMonitor.Free();
  if (Assigned(StmtMonitor)) then
    StmtMonitor.Free();

  inherited;
end;

procedure TCClient.DoExecuteEvent(const AEvent: TEvent);
var
  I: Integer;
  EventProc: TEventProc;
begin
  for I := 0 to EventProcs.Count - 1 do
  begin
    MoveMemory(@TMethod(EventProc), EventProcs[I], SizeOf(TMethod));
    EventProc(AEvent);
  end;
end;

function TCClient.EmptyDatabases(const DatabaseNames: array of string): Boolean;
var
  I: Integer;
begin
  Result := True;

  for I := 0 to Length(DatabaseNames) - 1 do
    Result := Result and Assigned(DatabaseByName(DatabaseNames[I])) and DatabaseByName(DatabaseNames[I]).EmptyTables([]);
end;

function TCClient.EncodeInterval(const Year, Month, Day, Quarter, Week, Hour, Minute, Second, MSec: Word; var Value: string; var IntervalType: TMySQLIntervalType): Boolean;
begin
  if ((Year <> 0) and (Month = 0) and (Day = 0) and (Quarter = 0) and (Week = 0) and (Hour = 0) and (Minute = 0) and (Second = 0) and (MSec = 0)) then
    begin Value := IntToStr(Year); IntervalType := itYear; end
  else if ((Year = 0) and (Month = 0) and (Day = 0) and (Quarter <> 0) and (Week = 0) and (Hour = 0) and (Minute = 0) and (Second = 0) and (MSec = 0)) then
    begin Value := IntToStr(Quarter); IntervalType := itQuarter; end
  else if ((Year = 0) and (Month <> 0) and (Day = 0) and (Quarter = 0) and (Week = 0) and (Hour = 0) and (Minute = 0) and (Second = 0) and (MSec = 0)) then
    begin Value := IntToStr(Month); IntervalType := itMonth; end
  else if ((Year = 0) and (Month = 0) and (Day <> 0) and (Quarter = 0) and (Week = 0) and (Hour = 0) and (Minute = 0) and (Second = 0) and (MSec = 0)) then
    begin Value := IntToStr(Day); IntervalType := itDay; end
  else if ((Year = 0) and (Month = 0) and (Day = 0) and (Quarter = 0) and (Week = 0) and (Hour <> 0) and (Minute = 0) and (Second = 0) and (MSec = 0)) then
    begin Value := IntToStr(Hour); IntervalType := itHour; end
  else if ((Year = 0) and (Month = 0) and (Day = 0) and (Quarter = 0) and (Week = 0) and (Hour = 0) and (Minute <> 0) and (Second = 0) and (MSec = 0)) then
    begin Value := IntToStr(Minute); IntervalType := itMinute; end
  else if ((Year = 0) and (Month = 0) and (Day = 0) and (Quarter = 0) and (Week <> 0) and (Hour = 0) and (Minute = 0) and (Second = 0) and (MSec = 0)) then
    begin Value := IntToStr(Week); IntervalType := itWeek; end
  else if ((Year = 0) and (Month = 0) and (Day = 0) and (Quarter = 0) and (Week = 0) and (Hour = 0) and (Minute = 0) and (Second <> 0) and (MSec = 0)) then
    begin Value := IntToStr(Second); IntervalType := itSecond; end
  else if ((Year = 0) and (Month = 0) and (Day = 0) and (Quarter = 0) and (Week = 0) and (Hour = 0) and (Minute = 0) and (Second = 0) and (MSec <> 0)) then
    begin Value := IntToStr(MSec); IntervalType := itMicrosecond; end
  else if ((Year <> 0) and (Month <> 0) and (Day = 0) and (Quarter = 0) and (Week = 0) and (Hour = 0) and (Minute = 0) and (Second = 0) and (MSec = 0)) then
    begin Value := SQLEscape(IntToStr(Year) + '-' + IntToStr(Month)); IntervalType := itYearMonth; end
  else if ((Year = 0) and (Month = 0) and (Day <> 0) and (Quarter = 0) and (Week = 0) and (Hour <> 0) and (Minute = 0) and (Second = 0) and (MSec = 0)) then
    begin Value := SQLEscape(IntToStr(Day) + ' ' + IntToStr(Hour)); IntervalType := itDayHour; end
  else if ((Year = 0) and (Month = 0) and (Day <> 0) and (Quarter = 0) and (Week = 0)                 and (Minute <> 0) and (Second = 0) and (MSec = 0)) then
    begin Value := SQLEscape(IntToStr(Day) + ' ' + IntToStr(Hour) + ':' + IntToStr(Minute)); IntervalType := itDayMinute; end
  else if ((Year = 0) and (Month = 0) and (Day <> 0) and (Quarter = 0) and (Week = 0)                                 and (Second <> 0) and (MSec = 0)) then
    begin Value := SQLEscape(IntToStr(Day) + ' ' + IntToStr(Hour) + ':' + IntToStr(Minute) + ':' + IntToStr(Second)); IntervalType := itDaySecond; end
  else if ((Year = 0) and (Month = 0) and (Day = 0) and (Quarter = 0) and (Week = 0) and (Hour <> 0) and (Minute <> 0) and (Second = 0) and (MSec = 0)) then
    begin Value := SQLEscape(IntToStr(Hour) + ':' + IntToStr(Minute)); IntervalType := itHourMinute; end
  else if ((Year = 0) and (Month = 0) and (Day = 0) and (Quarter = 0) and (Week = 0) and (Hour <> 0)                  and (Second <> 0) and (MSec = 0)) then
    begin Value := SQLEscape(IntToStr(Hour) + ':' + IntToStr(Minute) + ':' + IntToStr(Second)); IntervalType := itHourSecond; end
  else if ((Year = 0) and (Month = 0) and (Day = 0) and (Quarter = 0) and (Week = 0) and (Hour = 0) and (Minute <> 0) and (Second <> 0) and (MSec = 0)) then
    begin Value := SQLEscape(IntToStr(Minute) + ':' + IntToStr(Second)); IntervalType := itMinuteSecond; end
  else if ((Year = 0) and (Month = 0) and (Day <> 0)                                                                                   and (MSec <> 0)) then
    begin Value := SQLEscape(IntToStr(Day) + ' ' + IntToStr(Hour) + ':' + IntToStr(Minute) + IntToStr(Second) + '.' + IntToStr(MSec)); IntervalType := itDayMicrosecond; end
  else if ((Year = 0) and (Month = 0) and (Day = 0) and (Quarter = 0) and (Week = 0) and (Hour <> 0)                                   and (MSec <> 0)) then
    begin Value := SQLEscape(IntToStr(Hour) + ':' + IntToStr(Minute) + IntToStr(Second) + '.' + IntToStr(MSec)); IntervalType := itHourMicrosecond; end
  else if ((Year = 0) and (Month = 0) and (Day = 0) and (Quarter = 0) and (Week = 0) and (Hour = 0) and (Minute <> 0)                  and (MSec <> 0)) then
    begin Value := SQLEscape(IntToStr(Minute) + IntToStr(Second) + '.' + IntToStr(MSec)); IntervalType := itMinuteMicrosecond; end
  else if ((Year = 0) and (Month = 0) and (Day = 0) and (Quarter = 0) and (Week = 0) and (Hour = 0) and (Minute = 0) and (Second <> 0) and (MSec <> 0)) then
    begin Value := SQLEscape(IntToStr(Hour) + ':' + IntToStr(Minute)); IntervalType := itSecondMicrosecond; end
  else
    begin Value := ''; IntervalType := itUnknown; end;

  Result := IntervalType <> itUnknown;
end;

function TCClient.EngineByName(const EngineName: string): TCEngine;
var
  Index: Integer;
begin
  Index := Engines.IndexByName(EngineName);
  if (Index < 0) then
    Result := nil
  else
    Result := Engines[Index];
end;

function TCClient.EscapeRightIdentifier(const Identifier: string; const IdentifierQuoting: Boolean = False): string;
begin
  if (IdentifierQuoting) then
    Result := SQLEscape(Identifier)
  else
    Result := EscapeIdentifier(Identifier);
end;

function TCClient.EscapeUser(const User: string; const IdentifierQuoting: Boolean = False): string;
var
  Count: Integer;
  Host: string;
  I: Integer;
  Username: string;
begin
  Count := Length(User);
  for I := 1 to Length(User) do
    if (User[I] = '@') then
      Count := I - 1;
  Username := Copy(User, 1, Count);
  if (Count < Length(User)) then
    Host := Copy(User, Count + 2, Length(User) - Count)
  else
    Host := '';

  if (IdentifierQuoting) then
    if (Host = '') then
      Result := SQLEscape(Username)
    else
      Result := SQLEscape(Username) + '@' + SQLEscape(Host)
  else
    if (Host = '') then
      Result := EscapeIdentifier(Username)
    else
      Result := EscapeIdentifier(Username) + '@' + EscapeIdentifier(Host);
end;

procedure TCClient.ExecuteEvent(const EventType: TEventType);
var
  Event: TEvent;
begin
  Event.EventType := EventType;
  Event.Sender := nil;
  Event.CItem := nil;
  Event.Database := nil;
  Event.Initialize := nil;

  DoExecuteEvent(Event);
end;

procedure TCClient.ExecuteEvent(const EventType: TEventType; const Sender: TObject; const CItem: TCItem;  const Database: TCDatabase = nil);
var
  Event: TEvent;
begin
  Event.EventType := EventType;
  Event.Sender := Sender;
  Event.CItem := CItem;
  Event.Database := Database;
  Event.Initialize := nil;

  DoExecuteEvent(Event);
end;

procedure TCClient.ExecuteEvent(const Initialize: TInitialize);
var
  Event: TEvent;
begin
  Event.EventType := ceInitialize;
  Event.Sender := nil;
  Event.Database := nil;
  Event.CItem := nil;
  Event.Initialize := Initialize;

  DoExecuteEvent(Event);
end;

function TCClient.FieldTypeByCaption(const Caption: string): TCFieldType;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to FieldTypes.Count - 1 do
    if (lstrcmpi(PChar(FieldTypes[I].Caption), PChar(Caption)) = 0) then
      Result := FieldTypes[I];

  if (not Assigned(Result)) then
    if ((UpperCase(Caption) = 'BOOL') or (UpperCase(Caption) = 'BOOLEAN')) then
      Result := FieldTypeByMySQLFieldType(mfTinyInt)
    else if (UpperCase(Caption) = 'INTEGER') then
      Result := FieldTypeByMySQLFieldType(mfInt)
    else if (UpperCase(Caption) = 'DEC') then
      Result := FieldTypeByMySQLFieldType(mfDecimal)
    else if (UpperCase(Caption) = 'NVARCHAR') then
      Result := FieldTypeByMySQLFieldType(mfVarChar);

  if (not Assigned(Result)) then
    raise Exception.CreateFMT(SUnknownFieldType, [Caption]);
end;

function TCClient.FieldTypeByMySQLFieldType(const MySQLFieldType: TMySQLFieldType): TCFieldType;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to FieldTypes.Count - 1 do
    if (FieldTypes[I].MySQLFieldType = MySQLFieldType) then
      Result := FieldTypes[I];
end;

procedure TCClient.FirstConnect(const AConnectionType: Integer; const ALibraryName: string; const AHost, AUser, APassword, ADatabase: string; const APort: Integer; const ACompression, AMultiThreading: Boolean);
begin
  Close();

  Compression := ACompression;
  FDatabaseName := ADatabase;
  Host := AHost;
  LibraryName := ALibraryName;
  case (AConnectionType) of
    0: LibraryType := ltBuiltIn;
    1: LibraryType := ltDLL;
    2: LibraryType := ltHTTP;
  end;
  LoginPrompt := False;
  FMultiStatements := True;
  Asynchron := AMultiThreading;
  Password := APassword;
  Port := APort;
  FPrefetch := 1;
  Username := AUser;

  Open();
end;

procedure TCClient.FirstConnect();
begin
  Connected := False;

  Asynchron := Account.Connection.ASynchron;
  if (Account.Connection.Charset <> '') then
    Charset := Account.Connection.Charset;
  Compression := Account.Connection.Compression;
  FDatabaseName := Account.GetDefaultDatabase();
  case (Account.Connection.LibraryType) of
    ltBuiltIn: LibraryName := '';
    ltDLL: LibraryName := Account.Connection.LibraryFilename;
    ltHTTP: LibraryName := Account.Connection.HTTPTunnelURI;
  end;
  Host := Account.Connection.Host;
  LibraryType := Account.Connection.LibraryType;
  LoginPrompt := False;
  FMultiStatements := Account.Connection.MultiStatements;
  OnUpdateIndexDefs := UpdateIndexDefs;
  Password := Account.Connection.Password;
  Port := Account.Connection.Port;
  FPrefetch := Account.Connection.Prefetch;
  Startup := Account.Startup;
  Username := Account.Connection.User;

  try
    Open();
  except
    on E: EMySQLError do
      DoError(E.ErrorCode, E.Message);
  end;
end;

function TCClient.FlushHosts(): Boolean;
begin
  Result := ExecuteSQL('FLUSH HOSTS;');
end;

function TCClient.GetAutoCommit(): Boolean;
begin
  if (Assigned(Lib.mysql_get_server_status) or not Variables.Actual or not Assigned(VariableByName('autocommit'))) then
    Result := inherited GetAutoCommit()
  else
    Result := VariableByName('autocommit').AsBoolean;
end;

function TCClient.GetActual(): Boolean;
begin
  Result := (FCurrentUser <> '') and Assigned(FUser);
end;

function TCClient.GetCaption(): string;
begin
  if (Host = LOCAL_HOST_NAMEDPIPE) then
    Result := LOCAL_HOST
  else
  begin
    Result := Host;
    if (Port <> MYSQL_PORT) then
      Result := Result + ':' + IntToStr(Port);
  end;
end;

function TCClient.GetCollation(): string;
begin
  if (not Assigned(VariableByName('collation_server'))) then
    Result := ''
  else
    Result := VariableByName('collation_server').Value;
end;

function TCClient.GetDefaultCharset(): string;
begin
  if (ServerVersion < 40101) then
    Result := VariableByName('character_set').Value
  else
    Result := VariableByName('character_set_server').Value;
end;

function TCClient.GetLoadDataFile(): Boolean;
begin
  Result := inherited GetLoadDataFile() and ((ServerVersion < 40003) or VariableByName('local_infile').AsBoolean);
end;

function TCClient.GetLogActive(): Boolean;
begin
  Result := (ServerVersion >= 50111) and Assigned(VariableByName('log')) and VariableByName('log').AsBoolean;
end;

function TCClient.GetSlowLogActive(): Boolean;
begin
  Result := (ServerVersion >= 50111) and Assigned(VariableByName('log_slow_queries')) and VariableByName('log_slow_queries').AsBoolean;
end;

function TCClient.GetSlowLog(): string;
begin
  Result := GetSlowSQLLog();
end;

function TCClient.GetSlowSQLLog(const User: TCUser = nil): string;
var
  DataSet: TMySQLQuery;
  Hour: Word;
  Min: Word;
  MSec: Word;
  Sec: Word;
  Seconds: Integer;
  SQL: string;
begin
  Result := '';

  SQL := 'SELECT ' + EscapeIdentifier('start_time') + ',' + EscapeIdentifier('query_time') + ',';
  if (not Assigned(User)) then
    SQL := SQL + EscapeIdentifier('user_host') + ',';
  SQL := SQL + EscapeIdentifier('sql_text');
  SQL := SQL + ' FROM ' + EscapeIdentifier('mysql') + '.' + EscapeIdentifier('slow_log');
  if (Assigned(User)) then
    SQL := SQL + ' WHERE ' + EscapeIdentifier('user_host') + ' LIKE ' + EscapeRightIdentifier(User.Name + '@%');
  SQL := SQL + ' ORDER BY ' + EscapeIdentifier('start_time') + ' DESC';
  SQL := SQL + ' LIMIT 100';

  DataSet := TMySQLQuery.Create(nil);
  DataSet.Connection := Self;
  DataSet.CommandText := SQL;
  DataSet.Open();
  if (DataSet.Active and not DataSet.IsEmpty()) then
    repeat
      DecodeTime(StrToTime(DataSet.FieldByName('query_time').AsString), Hour, Min, Sec, MSec);
      Seconds := SecsPerMin * MinsPerHour * Hour + SecsPerMin * Min + Sec;

      SQL := DataSet.FieldByName('sql_text').AsString;
      if (Copy(SQL, 1, Length(SQL))) <> ';' then
        Result := SQL + ';' + #13#10 + Result
      else
        Result := SQL + #13#10 + Result;
      if (not Assigned(User)) then
        Result := '# ' + MySQLDB.DateTimeToStr(DataSet.FieldByName('start_time').AsDateTime, FormatSettings) + ', ' + Preferences.LoadStr(829) + ': ' + IntToStr(Seconds) + ', ' + ReplaceStr(Preferences.LoadStr(561), '&', '') + ': ' + Copy(DataSet.FieldByName('user_host').AsString, 1, Pos('[', DataSet.FieldByName('user_host').AsString) - 1) + #13#10 + Result
      else
        Result := '# ' + MySQLDB.DateTimeToStr(DataSet.FieldByName('start_time').AsDateTime, FormatSettings) + ', ' + Preferences.LoadStr(829) + ': ' + IntToStr(Seconds) + #13#10 + Result;
    until (not DataSet.FindNext());
  DataSet.Free();
end;

function TCClient.GetLog(): string;
begin
  Result := GetSQLLog();
end;

function TCClient.GetMaxAllowedPacket(): Integer;
begin
  if (FMaxAllowedPacket = 0) then
    Result := inherited GetMaxAllowedPacket()
  else
    Result := FMaxAllowedPacket;
end;

function TCClient.GetQueryBuilderResult(): TCResultSet;
begin
  if (not Assigned(FQueryBuilderResult)) then
    FQueryBuilderResult := TCResultSet.Create(Self);

  Result := FQueryBuilderResult;
end;

function TCClient.GetSQLEditorResult(): TCResultSet;
begin
  if (not Assigned(FSQLEditorResult)) then
    FSQLEditorResult := TCResultSet.Create(Self);

  Result := FSQLEditorResult;
end;

function TCClient.GetSQLLog(const User: TCUser = nil): string;
var
  DataSet: TMySQLQuery;
  SQL: string;
begin
  Result := '';

  SQL := 'SELECT ' + EscapeIdentifier('event_time') + ',';
  if (not Assigned(User)) then
    SQL := SQL + EscapeIdentifier('user_host') + ',';
  SQL := SQL + EscapeIdentifier('argument');
  SQL := SQL + ' FROM ' + EscapeIdentifier('mysql') + '.' + EscapeIdentifier('general_log');
  SQL := SQL + ' WHERE UPPER(' + EscapeIdentifier('command_type') + ')=''SQL''';
  if (Assigned(User)) then
    SQL := SQL + ' AND' + EscapeIdentifier('user_host') + ' LIKE ' + EscapeRightIdentifier(User.Name + '@%');
  SQL := SQL + ' ORDER BY ' + EscapeIdentifier('event_time') + ' DESC';
  SQL := SQL + ' LIMIT 100';

  DataSet := TMySQLQuery.Create(nil);
  DataSet.Connection := Self;
  DataSet.CommandText := SQL;
  if (DataSet.Active and not DataSet.IsEmpty()) then
    repeat
      SQL := DataSet.FieldByName('argument').AsString;
      if (Copy(SQL, 1, Length(SQL))) <> ';' then
        Result := SQL + ';' + #13#10 + Result
      else
        Result := SQL + #13#10 + Result;
      if (not Assigned(User)) then
        Result := '# ' + MySQLDB.DateTimeToStr(DataSet.FieldByName('event_time').AsDateTime, FormatSettings) + ', ' + ReplaceStr(Preferences.LoadStr(561), '&', '') + ': ' + Copy(DataSet.FieldByName('user_host').AsString, 1, Pos('[', DataSet.FieldByName('user_host').AsString) - 1) + #13#10 + Result
      else if (Assigned(SQLMonitor) and (ttTime in SQLMonitor.TraceTypes)) then
        Result := '# ' + MySQLDB.DateTimeToStr(DataSet.FieldByName('event_time').AsDateTime, FormatSettings) + #13#10 + Result;
    until (not DataSet.FindNext());
  DataSet.Free();
end;

function TCClient.GetUseInformationSchema(): Boolean;
begin
  Result := Assigned(Account) and Account.Connection.UseInformationSchema;
end;

function TCClient.GetUserRights(): TCUserRight;
begin
  if (not Assigned(User) or (User.RightCount = 0)) then
    Result := nil
  else
    Result := User.Right[0];
end;

procedure TCClient.GridCanEditShow(Sender: TObject);
var
  Database: TCDatabase;
  Field: TCTableField;
  FieldInfo: TFieldInfo;
  Grid: TMySQLDBGrid;
  I: Integer;
  J: Integer;
  K: Integer;
  Table: TCTable;
begin
  if ((Sender is TMySQLDBGrid) and (TMySQLDBGrid(Sender).DataSource.DataSet is TMySQLDataSet)) then
  begin
    Grid := TMySQLDBGrid(Sender);

    for I := 0 to Grid.Columns.Count - 1 do
    begin
      if (GetFieldInfo(Grid.Columns[I].Field.Origin, FieldInfo)) then
      begin
        Database := DatabaseByName(FieldInfo.DatabaseName);
        if (Assigned(Database)) then
        begin
          Table := Database.TableByName(FieldInfo.TableName);
          if (Assigned(Table)) then
          begin
            Field := Table.FieldByName(FieldInfo.OriginalFieldName);
            if (Assigned(Field)) then
            begin
              Grid.Columns[I].PickList.Clear();
              if (Field.FieldType = mfEnum) then
                for J := 0 to Length(Field.Items) - 1 do
                  Grid.Columns[I].PickList.Add(Field.Items[J]);

              Grid.Columns[I].ButtonStyle := cbsAuto;
              if ((Table is TCBaseTable) and Grid.DataSource.DataSet.CanModify and not Grid.SelectedField.ReadOnly) then
                for J := 0 to TCBaseTable(Table).ForeignKeys.Count - 1 do
                  for K := 0 to Length(TCBaseTable(Table).ForeignKeys[J].Fields) - 1 do
                    if (TCBaseTable(Table).ForeignKeys[J].Fields[K] = Field) then
                      Grid.Columns[I].ButtonStyle := cbsEllipsis;
            end;
          end;
        end;
      end;
    end;
  end;
end;

function TCClient.HostByCaption(const Caption: string): TCHost;
begin
  if (Caption = '<' + Preferences.LoadStr(327) + '>') then
    Result := HostByName('')
  else
    Result := HostByName(Caption);
end;

function TCClient.HostByName(const HostName: string): TCHost;
var
  I: Integer;
begin
  Result := nil;

  if (Hosts.Count = 1) and (HostName = '') then
    Result := Hosts[0]
  else
    for I := 0 to Hosts.Count - 1 do
      if (lstrcmpi(PChar(Hosts[I].Name), PChar(HostName)) = 0) then
        Result := Hosts[I];
end;

function TCClient.Initialize(): Boolean;
var
  SQL: string;
begin
  SQL := '';

  if (FCurrentUser = '') then
    if (ServerVersion < 40006) then
      SQL := SQL + 'SELECT SYSDATE(),USER();' + #13#10
    else
      SQL := SQL + 'SELECT SYSDATE(),CURRENT_USER();' + #13#10;

  if (not Assigned(FUser) and ((ServerVersion >= 40102) or (FCurrentUser <> ''))) then
    if (ServerVersion < 40102) then
      SQL := SQL + 'SHOW GRANTS FOR ' + EscapeUser(FCurrentUser) + ';' + #13#10
    else
      SQL := SQL + 'SHOW GRANTS FOR CURRENT_USER();' + #13#10;

  if (Assigned(Variables) and not Variables.Actual) then
    SQL := SQL + Variables.SQLGetItems();
  if (Assigned(Stati) and not Stati.Actual) then
    SQL := SQL + Stati.SQLGetItems();
  if (Assigned(Engines) and not Engines.Actual) then
    SQL := SQL + Engines.SQLGetItems();
  if (Assigned(Charsets) and not Charsets.Actual) then
    SQL := SQL + Charsets.SQLGetItems();
  if (Assigned(Collations) and not Collations.Actual) then
    SQL := SQL + Collations.SQLGetItems();
  if (Assigned(Databases) and not Databases.Actual) then
    SQL := SQL + Databases.SQLGetItems();
  if (Assigned(Plugins) and not Plugins.Actual) then
    SQL := SQL + Plugins.SQLGetItems();
  if (Assigned(Processes) and not Processes.Actual) then
    SQL := SQL + Processes.SQLGetItems();
  if (Assigned(Hosts) and not Hosts.Actual) then
    SQL := SQL + Hosts.SQLGetItems();
  if (Assigned(Users) and not Users.Actual) then
    SQL := SQL + Users.SQLGetItems();

  Result := SQL <> '';
  if (Result) then
    SendSQL(SQL, ClientResult);
end;

procedure TCClient.MonitorLog(const Sender: TObject; const Text: PChar; const Len: Integer; const ATraceType: TMySQLMonitor.TTraceType);
begin
  ExecuteEvent(ceMonitor);
end;

procedure TCClient.MonitorExecutedStmts(const Sender: TObject; const Text: PChar; const Len: Integer; const ATraceType: TMySQLMonitor.TTraceType);
var
  Database: TCDatabase;
  DatabaseName: string;
  DDLStmt: TSQLDDLStmt;
  DMLStmt: TSQLDMLStmt;
  Parse: TSQLParse;
  Table: TCTable;
  TableName: string;
begin
  if (SQLParseDDLStmt(DDLStmt, Text, Len, ServerVersion)) then
  begin
    if ((LowerCaseTableNames = 1) and (DDLStmt.ObjectType in [otDatabase, otTable, otView])) then
    begin
      DDLStmt.DatabaseName := LowerCase(DDLStmt.DatabaseName);
      DDLStmt.ObjectName := LowerCase(DDLStmt.ObjectName);
    end;

    if (DDLStmt.ObjectType = otDatabase) then
      case (DDLStmt.DefinitionType) of
        dtCreate:
          Databases.Add(TCDatabase.Create(Self, DDLStmt.ObjectName), True);
        dtRename,
        dtAlter:
          Databases.Refresh();
        dtDrop:
          Databases.Delete(DatabaseByName(DDLStmt.ObjectName));
      end
    else
    begin
      if (DDLStmt.DatabaseName = '') then
        Database := DatabaseByName(Self.DatabaseName)
      else
        Database := DatabaseByName(DDLStmt.DatabaseName);
      if (Assigned(Database)) then
        case (DDLStmt.ObjectType) of
          otTable,
          otView:
            case (DDLStmt.DefinitionType) of
              dtCreate:
                if (DDLStmt.ObjectType = otTable) then
                  Database.Tables.Add(TCBaseTable.Create(Database, DDLStmt.ObjectName), True)
                else
                  Database.Tables.Add(TCView.Create(Database, DDLStmt.ObjectName), True);
              dtRename:
                if (SQLCreateParse(Parse, Text, Len, ServerVersion)
                  and SQLParseKeyword(Parse, 'RENAME')
                  and (SQLParseKeyword(Parse, 'TABLE') or SQLParseKeyword(Parse, 'VIEW'))) then
                repeat
                  DatabaseName := Self.DatabaseName;
                  if (SQLParseObjectName(Parse, DatabaseName, TableName)) then
                  begin
                    Database := DatabaseByName(DatabaseName);
                    if (SQLParseKeyword(Parse, 'TO') and SQLParseObjectName(Parse, DatabaseName, TableName)) then
                    begin
                      Table := Database.TableByName(TableName);
                      if (Assigned(Table)) then
                      begin
                        ExecuteEvent(ceDroped, Database.Tables, Table);
                        Database.Tables.Delete(Table.Index);

                        Table.FDatabase := DatabaseByName(DatabaseName);
                        Table.Name := TableName;

                        Table.Database.Tables.Add(Table, True);
                      end;
                    end;
                  end;
                until (not SQLParseChar(Parse, ','));
              dtAlter,
              dtAlterRename:
                begin
                  Table := Database.TableByName(DDLStmt.ObjectName);
                  if (Assigned(Table)) then
                  begin
                    if (DDLStmt.DefinitionType = dtAlterRename) then
                    begin
                      ExecuteEvent(ceDroped, Database.Tables, Table);
                      Database.Tables.Delete(Table.Index);

                      Table.FDatabase := DatabaseByName(DDLStmt.NewDatabaseName);
                      Table.Name := DDLStmt.NewObjectName;

                      Table.Database.Tables.Add(Table, True);
                    end;

                    Table.Clear();
                    ExecuteEvent(Table.Initialize);
                  end;
                end;
              dtDrop:
                if (SQLCreateParse(Parse, Text, Len, ServerVersion)
                  and SQLParseKeyword(Parse, 'DROP')
                  and (SQLParseKeyword(Parse, 'TABLE') or SQLParseKeyword(Parse, 'VIEW'))) then
                begin
                  SQLParseKeyword(Parse, 'IF EXISTS');
                  repeat
                    DatabaseName := Self.DatabaseName;
                    if (SQLParseObjectName(Parse, DatabaseName, TableName)) then
                    begin
                      Database := DatabaseByName(DatabaseName);
                      Database.Tables.Delete(Database.TableByName(TableName));
                    end;
                  until (not SQLParseChar(Parse, ','));
                end;
            end;
          otFunction,
          otProcedure:
            case (DDLStmt.DefinitionType) of
              dtCreate:
                if (DDLStmt.ObjectType = otProcedure) then
                  Database.Routines.Add(TCProcedure.Create(Database, DDLStmt.ObjectName), True)
                else
                  Database.Routines.Add(TCFunction.Create(Database, DDLStmt.ObjectName), True);
              dtAlter,
              dtAlterRename:
                Database.Routines.Refresh();
              dtDrop:
                if (DDLStmt.ObjectType = otProcedure) then
                  Database.Routines.Delete(Database.ProcedureByName(DDLStmt.ObjectName))
                else
                  Database.Routines.Delete(Database.FunctionByName(DDLStmt.ObjectName));
            end;
          otTrigger:
            case (DDLStmt.DefinitionType) of
              dtCreate:
                Database.Triggers.Add(TCTrigger.Create(Database, DDLStmt.ObjectName), True);
              dtDrop:
                Database.Triggers.Delete(Database.TriggerByName(DDLStmt.ObjectName));
            end;
          otEvent:
            case (DDLStmt.DefinitionType) of
              dtCreate:
                Database.Events.Add(TCEvent.Create(Database, DDLStmt.ObjectName), True);
              dtDrop:
                Database.Events.Delete(Database.EventByName(DDLStmt.ObjectName));
            end;
      end;
    end;
  end
  else if (SQLParseDMLStmt(DMLStmt, Text, Len, ServerVersion)) then
  begin
    if ((Length(DMLStmt.DatabaseNames) = 1) and (Length(DMLStmt.TableNames) = 1)
      and (TableNameCmp(DMLStmt.DatabaseNames[0], 'mysql') = 0)) then
      if (TableNameCmp(DMLStmt.TableNames[0], 'host') = 0) then
        Hosts.Refresh()
      else if (TableNameCmp(DMLStmt.TableNames[0], 'user') = 0) then
        Users.Refresh();
  end
  else if (SQLCreateParse(Parse, Text, Len, ServerVersion)) then
    if (SQLParseKeyword(Parse, 'DROP USER')) then
      Users.Refresh()
    else if (SQLParseKeyword(Parse, 'CREATE USER')) then
      Users.Refresh()
    else if (SQLParseKeyword(Parse, 'RENAME USER')) then
      Users.Refresh();
end;

function TCClient.PluginByName(const PluginName: string): TCPlugin;
var
  Index: Integer;
begin
  Index := Plugins.IndexByName(PluginName);
  if (Index < 0) then
    Result := nil
  else
    Result := Plugins[Index];
end;

function TCClient.ProcessById(const ProcessId: Integer): TCProcess;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Processes.Count - 1 do
    if (Processes[I].Id = ProcessId) then
      Result := Processes[I];
end;

procedure TCClient.Refresh();
begin
  Clear();

  ExecuteEvent(Initialize);
end;

procedure TCClient.RegisterEventProc(const AEventProc: TEventProc);
var
  I: Integer;
  Index: Integer;
  ListEntry: Pointer;
begin
  Index := -1;
  for I := 0 to EventProcs.Count - 1 do
    if (CompareMem(EventProcs[I], @TMethod(AEventProc), SizeOf(TMethod))) then
      Index := I;

  if (Index < 0) then
  begin
    GetMem(ListEntry, SizeOf(TMethod));
    MoveMemory(ListEntry, @TMethod(AEventProc), SizeOf(TMethod));
    EventProcs.Add(ListEntry);
  end;
end;

procedure TCClient.RollbackTransaction();
begin
  inherited;
  AutoCommit := AutoCommitBeforeTransaction;

//  Clear(); DImport.Table soll nicht undefiniert werden
end;

procedure TCClient.SetAutoCommit(const AAutoCommit: Boolean);
var
  DataSet: TMySQLQuery;
  Index: Integer;
  SQL: string;
begin
  if (AAutoCommit <> AutoCommit) then
  begin
    Index := Variables.IndexByName('autocommit');
    if (Index >= 0) then
    begin
      if (AAutoCommit) then
        SQL := 'SET AUTOCOMMIT=1'
      else
        SQL := 'SET AUTOCOMMIT=0';

      BeginSilent();
      if (ExecuteSQL(SQL)) then
      begin
        DataSet := TMySQLQuery.Create(nil);
        DataSet.Connection := Self;
        DataSet.CommandText := 'SELECT @@AUTOCOMMIT';
        DataSet.Open();
        if (DataSet.Active and (DataSet.FieldCount = 1)) then
        begin
          Variables[Index].Value := DataSet.Fields[0].AsString;
          inherited SetAutoCommit(Variables[Index].AsBoolean);
        end;
        DataSet.Free();
      end;
      EndSilent();
    end;
  end;
end;

procedure TCClient.SetCharset(const ACharset: string);
begin
  inherited;

  if (Assigned(Variables) and Variables.Actual) then
    if (ServerVersion < 40101) then
      VariableByName('character_set').Value := Charset
    else
    begin
      VariableByName('character_set_client').Value := Charset;
      VariableByName('character_set_connection').Value := Charset;
      VariableByName('character_set_results').Value := Charset;
    end;
end;

procedure TCClient.StartTransaction();
begin
  AutoCommitBeforeTransaction := AutoCommit;

  AutoCommit := False;

  inherited;
end;

function TCClient.StatusByName(const StatusName: string): TCStatus;
var
  Index: Integer;
begin
  Index := Stati.IndexByName(StatusName);
  if (Index < 0) then
    Result := nil
  else
    Result := Stati[Index];
end;

function TCClient.TableName(const Name: string): string;
begin
  if (LowerCaseTableNames = 0) then
    Result := Name
  else
    Result := LowerCase(Name);
end;

function TCClient.TableNameCmp(const Name1, Name2: string): Integer;
begin
  if (LowerCaseTableNames = 0) then
    Result := lstrcmp(PChar(Name1), PChar(Name2))
  else
    Result := lstrcmpi(PChar(Name1), PChar(Name2));
end;

function TCClient.UnescapeValue(const Value: string; const FieldType: TMySQLFieldType = mfVarChar): string;
var
  DateTime: TDateTime;
  Len: Byte;
  S: string;
begin
  Len := Length(Result);
  Result := SQLUnescape(Value);

  if (FieldType in [mfFloat, mfDouble, mfDecimal]) then
    Result := ReplaceStr(Result, '.', DecimalSeparator)
  else if ((FieldType = mfTimeStamp) and (UpperCase(Value) = 'CURRENT_TIMESTAMP')) then
    Result := Value
  else if (FieldType in [mfTimeStamp]) then
    Result := Result
  else if (FieldType in [mfDate, mfTime, mfDateTime]) then
  begin
    if (FieldType = mfTimeStamp) then
      case (Len) of
        2: if (Result = '00') then Result := '0000-00-00 00:00:00' else Result := Copy(Result, 1, 2) + '-01-01 00:00:00';
        4: if (Result = '0000') then Result := '0000-00-00 00:00:00' else Result := Copy(Result, 1, 2) + '-' + Copy(Result, 3, 2) + '-01 00:00:00';
        6: if (Result = '000000') then Result := '0000-00-00 00:00:00' else Result := Copy(Result, 1, 2) + '-' + Copy(Result, 3, 2) + '-' + Copy(Result, 5, 2) + ' 00:00:00';
        10: Result := Copy(Result, 1, 2) + '-' + Copy(Result, 3, 2) + '-' + Copy(Result, 5, 2) + ' ' + Copy(Result, 7, 2) + ':' + Copy(Result, 9, 2);
        12: Result := Copy(Result, 1, 2) + '-' + Copy(Result, 3, 2) + '-' + Copy(Result, 5, 2) + ' ' + Copy(Result, 7, 2) + ':' + Copy(Result, 9, 2) + ':' + Copy(Result, 11, 2);
        14: Result := Copy(Result, 1, 4) + '-' + Copy(Result, 5, 2) + '-' + Copy(Result, 7, 2) + ' ' + Copy(Result, 9, 2) + ':' + Copy(Result, 11, 2) + ':' + Copy(Result, 13, 2);
      end;
    if (FieldType = mfDate) then Result := Result + ' 00:00:00';
    if (FieldType = mfTime) then Result := '0000-00-00 ' + Result;
    if (Pos('-', Result) = 3) then
      if (StrToInt(Copy(Result, 1, 2)) <= 69) then
        Result := '19' + Result
      else
        Result := '20' + Result;
    if (Length(Result) = 16) then Result := Result + ':00';

    if (Result <> '') then
    begin
      if ((Copy(Result, 1, 10) = '0000-00-00') or (Length(Result) < 10)) then
        DateTime := MySQLZeroDate
      else
        DateTime := EncodeDate(StrToInt(Copy(Result, 1, 4)), StrToInt(Copy(Result, 6, 2)), StrToInt(Copy(Result, 9, 2)));
      if (Length(Result) = 19) then
        DateTime := DateTime + Sign(DateTime) * EncodeTime(StrToInt(Copy(Result, 12, 2)), StrToInt(Copy(Result, 15, 2)), StrToInt(Copy(Result, 18, 2)), 0);

      case (FieldType) of
        mfDate: Result := MySQLDB.DateToStr(DateTime, FormatSettings);
        mfTime: Result := TimeToStr(DateTime);
        mfDateTime: Result := MySQLDB.DateTimeToStr(DateTime, FormatSettings);
        mfTimeStamp:
          if (DateTime = 0) then
            Result := StringOfChar('0', Len)
          else
          begin
            case (Len) of
              2: DateTimeToString(S, 'yy', DateTime, FormatSettings);
              4: DateTimeToString(S, 'yymm', DateTime, FormatSettings);
              6: DateTimeToString(S, 'yymmdd', DateTime, FormatSettings);
              10: DateTimeToString(S, 'yymmddhhmm', DateTime, FormatSettings);
              12: DateTimeToString(S, 'yymmddhhmmss', DateTime, FormatSettings);
              14: DateTimeToString(S, 'yyyymmddhhmmss', DateTime, FormatSettings);
              else S := Value;
            end;
            Result := S;
          end;
      end;
    end;
  end;
end;

function TCClient.UnecapeRightIdentifier(const Identifier: string): string;
var
  DBIdentifier: string;
begin
  DBIdentifier := UnescapeValue(Identifier);

  if (DBIdentifier = '%') then Result := '' else Result := DBIdentifier;
end;

procedure TCClient.UnRegisterEventProc(const AEventProc: TEventProc);
var
  I: Integer;
  Index: Integer;
begin
  Index := -1;
  for I := 0 to EventProcs.Count - 1 do
    if (CompareMem(EventProcs[I], @TMethod(AEventProc), SizeOf(TMethod))) then
      Index := I;

  if (Index >= 0) then
  begin
    FreeMem(EventProcs[Index]);
    EventProcs.Delete(Index);
  end;
end;

function TCClient.UpdateDatabase(const Database, NewDatabase: TCDatabase): Boolean;
var
  SQL: string;
begin
  SQL := '';
  if (ServerVersion >= 40101) then
  begin
    if ((NewDatabase.FDefaultCharset <> '') and (not Assigned(Database) and (NewDatabase.FDefaultCharset <> DefaultCharset) or Assigned(Database) and (NewDatabase.FDefaultCharset <> Database.DefaultCharset))) then
      SQL := SQL + ' DEFAULT CHARACTER SET ' + NewDatabase.FDefaultCharset;
    if ((NewDatabase.FCollation <> '') and (not Assigned(Database) and (NewDatabase.FCollation <> Collation) or Assigned(Database) and (NewDatabase.FCollation <> Database.Collation))) then
      SQL := SQL + ' DEFAULT COLLATE ' + NewDatabase.FCollation;
  end;

  if (not Assigned(Database)) then
    SQL := 'CREATE DATABASE ' + EscapeIdentifier(NewDatabase.Name) + SQL + ';' + #13#10
  else if (SQL <> '') then
    if (ServerVersion < 40108) then
    begin
      SQL := 'ALTER DATABASE ' + SQL + ';' + #13#10;
      if (DatabaseName <> Database.Name) then
        SQL := Database.SQLUse() + SQL;
    end
    else
      SQL := 'ALTER DATABASE ' + EscapeIdentifier(Database.Name) + SQL + ';' + #13#10;

  if (SQL = '') then
    Result := True
  else
    Result := ExecuteSQL(SQL);
end;

function TCClient.UpdateHost(const Host, NewHost: TCHost): Boolean;

  function GetRightString(const Right: Boolean): string;
  begin
    if (Right) then
      Result := SQLEscape('Y')
    else
      Result := SQLEscape('N');
  end;

var
  Found: Boolean;
  I: Integer;
  J: Integer;
  OldDatabase: TCHostDatabase;
  SQL: string;
  Updates: string;
begin
  SQL := '';

  if (Assigned(Host)) then
  begin
    for I := 0 to Host.Databases.Count - 1 do
    begin
      Found := False;
      for J := 0 to NewHost.Databases.Count - 1 do
        if (NewHost.Databases[J].OriginalName = Host.Databases[I].OriginalName) then
          Found := True;

      if (not Found) then
        SQL := SQL + 'DELETE FROM ' + EscapeIdentifier('mysql') + '.' + EscapeIdentifier('host') + ' WHERE ' + EscapeIdentifier('Host') + '=' + SQLEscape(Host.Name) + ' AND ' + EscapeIdentifier('Db') + '=' + SQLEscape(Host.Databases[I].Name) + ';' + #13#10;
    end;
  end;

  for I := 0 to NewHost.Databases.Count - 1 do
  begin
    OldDatabase := nil;
    if (Assigned(Host)) then
      for J := 0 to Host.Databases.Count - 1 do
        if (Host.Databases[J].OriginalName = NewHost.Databases[I].OriginalName) then
          OldDatabase := Host.Databases[J];

    Updates := '';
    if (not Assigned(Host) or not Assigned(OldDatabase) or (NewHost.Name                          <> Host.Name                   )                       ) then Updates := Updates + ',' + EscapeIdentifier('Host') + '='                  + SQLEscape(NewHost.Name);
    if (not Assigned(Host) or not Assigned(OldDatabase) or (NewHost.Databases[I].Name             <> OldDatabase.Name            )                       ) then Updates := Updates + ',' + EscapeIdentifier('Db') + '='                    + SQLEscape(NewHost.Databases[I].Name);

    if (not Assigned(Host) or not Assigned(OldDatabase) or (NewHost.Databases[I].RAlter           <> OldDatabase.RAlter          )                       ) then Updates := Updates + ',' + EscapeIdentifier('Alter_priv') + '='            + GetRightString(NewHost.Databases[I].RAlter          );
    if (not Assigned(Host) or not Assigned(OldDatabase) or (NewHost.Databases[I].RCreate          <> OldDatabase.RCreate         )                       ) then Updates := Updates + ',' + EscapeIdentifier('Create_priv') + '='           + GetRightString(NewHost.Databases[I].RCreate         );
    if (not Assigned(Host) or not Assigned(OldDatabase) or (NewHost.Databases[I].RCreateTempTable <> OldDatabase.RCreateTempTable)                       ) then Updates := Updates + ',' + EscapeIdentifier('Create_tmp_table_priv') + '=' + GetRightString(NewHost.Databases[I].RCreateTempTable);
    if (not Assigned(Host) or not Assigned(OldDatabase) or (NewHost.Databases[I].RCreateView      <> OldDatabase.RCreateView     ) and (ServerVersion >= 50001)) then Updates := Updates + ',' + EscapeIdentifier('Create_view_priv') + '='      + GetRightString(NewHost.Databases[I].RCreateView     );
    if (not Assigned(Host) or not Assigned(OldDatabase) or (NewHost.Databases[I].RDelete          <> OldDatabase.RDelete         )                       ) then Updates := Updates + ',' + EscapeIdentifier('Delete_priv') + '='           + GetRightString(NewHost.Databases[I].RDelete         );
    if (not Assigned(Host) or not Assigned(OldDatabase) or (NewHost.Databases[I].RDrop            <> OldDatabase.RDrop           )                       ) then Updates := Updates + ',' + EscapeIdentifier('Drop_priv') + '='             + GetRightString(NewHost.Databases[I].RDrop           );
    if (not Assigned(Host) or not Assigned(OldDatabase) or (NewHost.Databases[I].RGrant           <> OldDatabase.RGrant          )                       ) then Updates := Updates + ',' + EscapeIdentifier('Grant_priv') + '='            + GetRightString(NewHost.Databases[I].RGrant          );
    if (not Assigned(Host) or not Assigned(OldDatabase) or (NewHost.Databases[I].RIndex           <> OldDatabase.RIndex          )                       ) then Updates := Updates + ',' + EscapeIdentifier('Index_priv') + '='            + GetRightString(NewHost.Databases[I].RIndex          );
    if (not Assigned(Host) or not Assigned(OldDatabase) or (NewHost.Databases[I].RInsert          <> OldDatabase.RInsert         )                       ) then Updates := Updates + ',' + EscapeIdentifier('Insert_priv') + '='           + GetRightString(NewHost.Databases[I].RInsert         );
    if (not Assigned(Host) or not Assigned(OldDatabase) or (NewHost.Databases[I].RLockTables      <> OldDatabase.RLockTables     )                       ) then Updates := Updates + ',' + EscapeIdentifier('Lock_tables_priv') + '='      + GetRightString(NewHost.Databases[I].RLockTables     );
    if (not Assigned(Host) or not Assigned(OldDatabase) or (NewHost.Databases[I].RReferences      <> OldDatabase.RReferences     )                       ) then Updates := Updates + ',' + EscapeIdentifier('References_priv') + '='       + GetRightString(NewHost.Databases[I].RReferences     );
    if (not Assigned(Host) or not Assigned(OldDatabase) or (NewHost.Databases[I].RSelect          <> OldDatabase.RSelect         )                       ) then Updates := Updates + ',' + EscapeIdentifier('Select_priv') + '='           + GetRightString(NewHost.Databases[I].RSelect         );
    if (not Assigned(Host) or not Assigned(OldDatabase) or (NewHost.Databases[I].RShowView        <> OldDatabase.RShowView       ) and (ServerVersion >= 50001)) then Updates := Updates + ',' + EscapeIdentifier('Show_view_priv') + '='        + GetRightString(NewHost.Databases[I].RShowView       );
    if (not Assigned(Host) or not Assigned(OldDatabase) or (NewHost.Databases[I].RUpdate          <> OldDatabase.RUpdate         )                       ) then Updates := Updates + ',' + EscapeIdentifier('Update_priv') + '='           + GetRightString(NewHost.Databases[I].RUpdate         );
    if (Copy(Updates, 1, 1) = ',') then Delete(Updates, 1, 1);

    if (not Assigned(Host) or not Assigned(OldDatabase)) then
      SQL := SQL + 'INSERT INTO ' + EscapeIdentifier('mysql') + '.' + EscapeIdentifier('host') + ' SET ' + Updates + ';' + #13#10
    else if (Updates <> '') then
      SQL := SQL + 'UPDATE ' + EscapeIdentifier('mysql') + '.' + EscapeIdentifier('host') + ' SET ' + Updates + ' WHERE ' + EscapeIdentifier('Host') + '=' + SQLEscape(Host.Name) + ' AND ' + EscapeIdentifier('Db') + '=' + SQLEscape(OldDatabase.Name) + ';' + #13#10;
  end;

  if (SQL = '') then
    Result := False
  else
  begin
    if (DatabaseName <> 'mysql') then
      SQL := SQLUse('mysql') + SQL;

    SQL := SQL + 'FLUSH PRIVILEGES;' + #13#10;

    Result := ExecuteSQL(SQL);
  end;

  if (Result) then
    Hosts.Clear();
end;

procedure TCClient.UpdateIndexDefs(const DataSet: TMySQLQuery; const IndexDefs: TIndexDefs);
var
  Database: TCDatabase;
  Field: TCBaseTableField;
  FieldInfo: TFieldInfo;
  Found: Boolean;
  I: Integer;
  IndexDef: TIndexDef;
  J: Integer;
  K: Integer;
  OriginalDatabaseName: string;
  OriginalTableName: string;
  Table: TCBaseTable;
  UniqueTable: Boolean;
begin
  if (not (DataSet is TCTableDataSet) or Assigned(DatabaseByName(DataSet.DatabaseName).ViewByName(DataSet.TableName))) then
  begin
    OriginalTableName := ''; UniqueTable := True;
    for I := 0 to DataSet.FieldCount - 1 do
      if (GetFieldInfo(DataSet.Fields[I].Origin, FieldInfo) and (FieldInfo.DatabaseName <> '') and (FieldInfo.TableName <> '')) then
      begin
        if (OriginalDatabaseName = '') then
          OriginalDatabaseName := FieldInfo.DatabaseName
        else
          UniqueTable := UniqueTable and (TableNameCmp(FieldInfo.DatabaseName, OriginalDatabaseName) = 0);
        if (OriginalTableName = '') then
          OriginalTableName := FieldInfo.TableName
        else
          UniqueTable := UniqueTable and (TableNameCmp(FieldInfo.TableName, OriginalTableName) = 0);
      end;
    if (not UniqueTable) then
    begin
      OriginalDatabaseName := '';
      OriginalTableName := '';
    end;
  end
  else
  begin
    OriginalDatabaseName := DataSet.DatabaseName;
    OriginalTableName := DataSet.CommandText;
  end;

  if (Assigned(DatabaseByName(OriginalDatabaseName)) and (OriginalTableName <> '')) then
  begin
    Table := DatabaseByName(OriginalDatabaseName).BaseTableByName(OriginalTableName);
    if (Assigned(Table)) then
    begin
      IndexDefs.Clear();
      for I := 0 to Table.Indices.Count - 1 do
      begin
        Found := True;
        for J := 0 to Table.Indices[I].Columns.Count - 1 do
          if (Found) then
          begin
            Found := False;
            for K := 0 to DataSet.FieldCount - 1 do
              if (GetFieldInfo(DataSet.Fields[K].Origin, FieldInfo) and (FieldInfo.OriginalFieldName = Table.Indices[I].Columns[J].Field.Name)) then
                Found := True;
          end;

        if (Found) then
        begin
          IndexDef := IndexDefs.AddIndexDef();
          IndexDef.Name := Table.Indices[I].Name;
          if (Table.Indices[I].Primary) then
            IndexDef.Options := [ixPrimary, ixUnique]
          else if (Table.Indices[I].Unique) then
            IndexDef.Options := [ixUnique];
          for J := 0 to Table.Indices[I].Columns.Count - 1 do
          begin
            if (IndexDef.Fields <> '') then IndexDef.Fields := IndexDef.Fields + ';';
            for K := 0 to DataSet.FieldCount - 1 do
              if (GetFieldInfo(DataSet.Fields[K].Origin, FieldInfo) and (FieldInfo.OriginalFieldName = Table.Indices[I].Columns[J].Field.Name)) then
              begin
                IndexDef.Fields := IndexDef.Fields + DataSet.Fields[K].FieldName;
                if (not Table.Indices[I].Columns[J].Ascending) then
                begin
                  if (IndexDef.DescFields <> '') then IndexDef.DescFields := IndexDef.DescFields + ';';
                  IndexDef.Fields := IndexDef.Fields + DataSet.Fields[K].FieldName;
                end;
              end;
          end;
        end;
      end;
    end;
  end;

  for I := 0 to DataSet.FieldCount - 1 do
    if (GetFieldInfo(DataSet.Fields[I].Origin, FieldInfo)) then
    begin
      if (FieldInfo.DatabaseName = '') then
        Database := DatabaseByName(DataSet.DatabaseName)
      else
        Database := DatabaseByName(FieldInfo.DatabaseName);
      if (Assigned(Database)) then
      begin
        Table := Database.BaseTableByName(FieldInfo.TableName);
        if (Assigned(Table)) then
        begin
          Field := Table.FieldByName(FieldInfo.OriginalFieldName);
          if (Assigned(Field) and not Field.AutoIncrement and (Field.Default <> 'NULL') and (Copy(Field.Default, 1, 17) <> 'CURRENT_TIMESTAMP')) then
            DataSet.Fields[I].DefaultExpression := Field.UnescapeValue(Field.Default);
        end;
      end;
    end;
end;

function TCClient.UpdateUser(const User, NewUser: TCUser): Boolean;

  function GetPrivileges(const Grant: Boolean; const OldRight, NewRight: TCUserRight): string;
  begin
    Result := '';

    if ((not Grant xor NewRight.RAlter          ) and (Grant xor (Assigned(OldRight) and OldRight.RAlter          ))                       ) then       Result := Result + ',ALTER';
    if ((not Grant xor NewRight.RAlterRoutine   ) and (Grant xor (Assigned(OldRight) and OldRight.RAlterRoutine   )) and (ServerVersion >= 50003)) then       Result := Result + ',ALTER ROUTINE';
    if ((not Grant xor NewRight.RCreate         ) and (Grant xor (Assigned(OldRight) and OldRight.RCreate         ))                       ) then       Result := Result + ',CREATE';
    if ((not Grant xor NewRight.RCreateRoutine  ) and (Grant xor (Assigned(OldRight) and OldRight.RCreateRoutine  )) and (ServerVersion >= 50003)) then       Result := Result + ',CREATE ROUTINE';
    if ((not Grant xor NewRight.RCreateTempTable) and (Grant xor (Assigned(OldRight) and OldRight.RCreateTempTable)) and (ServerVersion >= 40002)) then       Result := Result + ',CREATE TEMPORARY TABLES';
    if ((not Grant xor NewRight.RCreateUser     ) and (Grant xor (Assigned(OldRight) and OldRight.RCreateUser     )) and (ServerVersion >= 50003)) then       Result := Result + ',CREATE USER';
    if ((not Grant xor NewRight.RCreateView     ) and (Grant xor (Assigned(OldRight) and OldRight.RCreateView     )) and (ServerVersion >= 50001)) then       Result := Result + ',CREATE VIEW';
    if ((not Grant xor NewRight.RDelete         ) and (Grant xor (Assigned(OldRight) and OldRight.RDelete         ))                       ) then       Result := Result + ',DELETE';
    if ((not Grant xor NewRight.RDrop           ) and (Grant xor (Assigned(OldRight) and OldRight.RDrop           ))                       ) then       Result := Result + ',DROP';
    if ((not Grant xor NewRight.REvent          ) and (Grant xor (Assigned(OldRight) and OldRight.REvent          )) and (ServerVersion >= 50106)) then       Result := Result + ',EVENT';
    if ((not Grant xor NewRight.RExecute        ) and (Grant xor (Assigned(OldRight) and OldRight.RExecute        )) and (ServerVersion >= 50003)) then       Result := Result + ',EXECUTE';
    if ((not Grant xor NewRight.RFile           ) and (Grant xor (Assigned(OldRight) and OldRight.RFile           ))                       ) then       Result := Result + ',FILE';
    if ((not Grant xor NewRight.RGrant          ) and (Grant xor (Assigned(OldRight) and OldRight.RGrant          ))                       ) then       Result := Result + ',GRANT OPTION';
    if ((not Grant xor NewRight.RIndex          ) and (Grant xor (Assigned(OldRight) and OldRight.RIndex          ))                       ) then       Result := Result + ',INDEX';
    if ((not Grant xor NewRight.RInsert         ) and (Grant xor (Assigned(OldRight) and OldRight.RInsert         ))                       ) then begin Result := Result + ',INSERT';                  if (not Grant and (OldRight.FieldName <> '')) then Result := Result + '(' + EscapeIdentifier(OldRight.FieldName) + ')' else if (Grant and (NewRight.FieldName <> '')) then Result := Result + '(' + EscapeIdentifier(NewRight.FieldName) + ')'; end;
    if ((not Grant xor NewRight.RLockTables     ) and (Grant xor (Assigned(OldRight) and OldRight.RLockTables     )) and (ServerVersion >= 40002)) then       Result := Result + ',LOCK TABLES';
    if ((not Grant xor NewRight.RProcess        ) and (Grant xor (Assigned(OldRight) and OldRight.RProcess        ))                       ) then       Result := Result + ',PROCESS';
    if ((not Grant xor NewRight.RReferences     ) and (Grant xor (Assigned(OldRight) and OldRight.RReferences     ))                       ) then begin Result := Result + ',REFERENCES';              if (not Grant and (OldRight.FieldName <> '')) then Result := Result + '(' + EscapeIdentifier(OldRight.FieldName) + ')' else if (Grant and (NewRight.FieldName <> '')) then Result := Result + '(' + EscapeIdentifier(NewRight.FieldName) + ')'; end;
    if ((not Grant xor NewRight.RReload         ) and (Grant xor (Assigned(OldRight) and OldRight.RReload         ))                       ) then       Result := Result + ',RELOAD';
    if ((not Grant xor NewRight.RReplClient     ) and (Grant xor (Assigned(OldRight) and OldRight.RReplClient     )) and (ServerVersion >= 40002)) then       Result := Result + ',REPLICATION CLIENT';
    if ((not Grant xor NewRight.RReplSlave      ) and (Grant xor (Assigned(OldRight) and OldRight.RReplSlave      )) and (ServerVersion >= 40002)) then       Result := Result + ',REPLICATION SLAVE';
    if ((not Grant xor NewRight.RSelect         ) and (Grant xor (Assigned(OldRight) and OldRight.RSelect         ))                       ) then begin Result := Result + ',SELECT';                  if (not Grant and (OldRight.FieldName <> '')) then Result := Result + '(' + EscapeIdentifier(OldRight.FieldName) + ')' else if (Grant and (NewRight.FieldName <> '')) then Result := Result + '(' + EscapeIdentifier(NewRight.FieldName) + ')'; end;
    if ((not Grant xor NewRight.RShowDatabases  ) and (Grant xor (Assigned(OldRight) and OldRight.RShowDatabases  )) and (ServerVersion >= 40002)) then       Result := Result + ',SHOW DATABASES';
    if ((not Grant xor NewRight.RShowView       ) and (Grant xor (Assigned(OldRight) and OldRight.RShowView       )) and (ServerVersion >= 50001)) then       Result := Result + ',SHOW VIEW';
    if ((not Grant xor NewRight.RShutdown       ) and (Grant xor (Assigned(OldRight) and OldRight.RShutdown       ))                       ) then       Result := Result + ',SHUTDOWN';
    if ((not Grant xor NewRight.RSuper          ) and (Grant xor (Assigned(OldRight) and OldRight.RSuper          )) and (ServerVersion >= 40002)) then       Result := Result + ',SUPER';
    if ((not Grant xor NewRight.RTrigger        ) and (Grant xor (Assigned(OldRight) and OldRight.RTrigger        )) and (ServerVersion >= 50106)) then       Result := Result + ',TRIGGER';
    if ((not Grant xor NewRight.RUpdate         ) and (Grant xor (Assigned(OldRight) and OldRight.RUpdate         ))                       ) then begin Result := Result + ',UPDATE';                  if (not Grant and (OldRight.FieldName <> '')) then Result := Result + '(' + EscapeIdentifier(OldRight.FieldName) + ')' else if (Grant and (NewRight.FieldName <> '')) then Result := Result + '(' + EscapeIdentifier(NewRight.FieldName) + ')'; end;

    Delete(Result, 1, 1);
  end;

var
  EmptyRight: TCUserRight;
  I: Integer;
  J: Integer;
  NewRight: TCUserRight;
  OldRight: TCUserRight;
  Options: string;
  Privileges: string;
  RemovedUserRights: array of Boolean;
  SingleSQL: string;
  SQL: string;
begin
  SQL := '';

  if (Assigned(User) and (NewUser.Name <> User.Name)) then
    if (ServerVersion < 50002) then
    begin
      SQL := SQL + 'UPDATE ' + EscapeIdentifier('mysql') + '.' + EscapeIdentifier('user'        ) + ' SET ' + EscapeIdentifier('User') + '=' + SQLEscape(NewUser.Login) + ',' + EscapeIdentifier('Host') + '=' + SQLEscape(NewUser.Host) + ' WHERE ' + EscapeIdentifier('User') + '=' + SQLEscape(User.Login) + ' AND ' + EscapeIdentifier('Host') + '=' + SQLEscape(User.Host) + ';' + #13#10;
      SQL := SQL + 'UPDATE ' + EscapeIdentifier('mysql') + '.' + EscapeIdentifier('db'          ) + ' SET ' + EscapeIdentifier('User') + '=' + SQLEscape(NewUser.Login) + ',' + EscapeIdentifier('Host') + '=' + SQLEscape(NewUser.Host) + ' WHERE ' + EscapeIdentifier('User') + '=' + SQLEscape(User.Login) + ' AND ' + EscapeIdentifier('Host') + '=' + SQLEscape(User.Host) + ';' + #13#10;
      SQL := SQL + 'UPDATE ' + EscapeIdentifier('mysql') + '.' + EscapeIdentifier('tables_priv' ) + ' SET ' + EscapeIdentifier('User') + '=' + SQLEscape(NewUser.Login) + ',' + EscapeIdentifier('Host') + '=' + SQLEscape(NewUser.Host) + ' WHERE ' + EscapeIdentifier('User') + '=' + SQLEscape(User.Login) + ' AND ' + EscapeIdentifier('Host') + '=' + SQLEscape(User.Host) + ';' + #13#10;
      SQL := SQL + 'UPDATE ' + EscapeIdentifier('mysql') + '.' + EscapeIdentifier('columns_priv') + ' SET ' + EscapeIdentifier('User') + '=' + SQLEscape(NewUser.Login) + ',' + EscapeIdentifier('Host') + '=' + SQLEscape(NewUser.Host) + ' WHERE ' + EscapeIdentifier('User') + '=' + SQLEscape(User.Login) + ' AND ' + EscapeIdentifier('Host') + '=' + SQLEscape(User.Host) + ';' + #13#10;
    end
    else
      SQL := SQL + 'RENAME USER ' + EscapeUser(User.Name) + ' TO ' + EscapeUser(NewUser.Name) + ';' + #13#10;

  if (not Assigned(User) and (ServerVersion > 50002)) then
    SQL := SQL + 'CREATE USER ' + EscapeUser(NewUser.Name) + ';' + #13#10;

  if (not Assigned(User)) then
    SetLength(RemovedUserRights, 0)
  else
  begin
    SetLength(RemovedUserRights, User.RightCount);
    for I := 0 to Length(RemovedUserRights) - 1 do
      RemovedUserRights[I] := False;
  end;

  for I := 0 to NewUser.RightCount - 1 do
  begin
    NewRight := NewUser.Right[I];
    OldRight := nil;
    if (Assigned(User)) then
      for J := 0 to User.RightCount - 1 do
        if   ((TableNameCmp(User.Right[J].DatabaseName , NewRight.DatabaseName ) = 0)
          and (TableNameCmp(User.Right[J].TableName    , NewRight.TableName    ) = 0)
          and (lstrcmpi(PChar(User.Right[J].ProcedureName), PChar(NewRight.ProcedureName)) = 0)
          and (lstrcmpi(PChar(User.Right[J].FunctionName ), PChar(NewRight.FunctionName )) = 0)
          and (lstrcmpi(PChar(User.Right[J].FieldName    ), PChar(NewRight.FieldName    )) = 0)) then
          OldRight := User.Right[J];


    if (Assigned(OldRight)) then
    begin
      Privileges := GetPrivileges(False, OldRight, NewRight);

      if (Privileges <> '') then
      begin
        SingleSQL := 'REVOKE ' + Privileges + ' ON ';
        if (NewRight.TableName <> '') then
          SingleSQL := SingleSQL + EscapeIdentifier(NewRight.DatabaseName) + '.' + EscapeIdentifier(NewRight.TableName)
        else if (NewRight.ProcedureName <> '') then
          SingleSQL := SingleSQL + 'PROCEDURE ' + EscapeIdentifier(NewRight.DatabaseName) + '.' + EscapeIdentifier(NewRight.ProcedureName)
        else if (NewRight.FunctionName <> '') then
          SingleSQL := SingleSQL + 'FUNCTION ' + EscapeIdentifier(NewRight.DatabaseName) + '.' + EscapeIdentifier(NewRight.FunctionName)
        else if (NewRight.DatabaseName <> '') then
          SingleSQL := SingleSQL + EscapeIdentifier(NewRight.DatabaseName) + '.*'
        else
          SingleSQL := SingleSQL + '*.*';
        SingleSQL := SingleSQL + ' FROM ' + EscapeUser(NewUser.Name);
      SQL := SQL + SingleSQL + ';' + #13#10;
      end;
    end;

    Privileges := GetPrivileges(True, OldRight, NewRight);

    Options := '';
    if (NewRight.RGrant and not (Assigned(OldRight) and OldRight.RGrant)) then Options := Options + ' GRANT OPTION';
    if (NewRight.DatabaseName = '') then
    begin
      if (not Assigned(User) and (NewUser.ConnectionsPerHour > 0) or Assigned(User) and (User.ConnectionsPerHour <> NewUser.ConnectionsPerHour)) then Options := Options + ' MAX_CONNECTIONS_PER_HOUR ' + IntToStr(NewUser.ConnectionsPerHour);
      if (not Assigned(User) and (NewUser.QueriesPerHour     > 0) or Assigned(User) and (User.QueriesPerHour     <> NewUser.QueriesPerHour    )) then Options := Options + ' MAX_QUERIES_PER_HOUR '     + IntToStr(NewUser.QueriesPerHour);
      if (not Assigned(User) and (NewUser.UpdatesPerHour     > 0) or Assigned(User) and (User.UpdatesPerHour     <> NewUser.UpdatesPerHour    )) then Options := Options + ' MAX_UPDATES_PER_HOUR '     + IntToStr(NewUser.UpdatesPerHour);
      if (ServerVersion >= 50003) then
        if (not Assigned(User) and (NewUser.UserConnections    > 0) or Assigned(User) and (User.UserConnections    <> NewUser.UserConnections   )) then Options := Options + ' MAX_USER_CONNECTIONS '     + IntToStr(NewUser.UserConnections);
    end;
    Options := Trim(Options);

    if ((Privileges = '') and ((Options <> '') or (not Assigned(User) and (ServerVersion <= 50002)))) then
      Privileges := 'USAGE';

    if (Privileges <> '') then
    begin
      SingleSQL := 'GRANT ' + Privileges + ' ON ';

      if (NewRight.TableName <> '') then
        if (ServerVersion < 50006) then
          SingleSQL := SingleSQL + EscapeIdentifier(NewRight.DatabaseName) + '.' + EscapeIdentifier(NewRight.TableName)
        else
          SingleSQL := SingleSQL + 'TABLE ' + EscapeIdentifier(NewRight.DatabaseName) + '.' + EscapeIdentifier(NewRight.TableName)
      else if (NewRight.ProcedureName <> '') then
        SingleSQL := SingleSQL + 'PROCEDURE ' + EscapeIdentifier(NewRight.DatabaseName) + '.' + EscapeIdentifier(NewRight.ProcedureName)
      else if (NewRight.FunctionName <> '') then
        SingleSQL := SingleSQL + 'FUNCTION ' + EscapeIdentifier(NewRight.DatabaseName) + '.' + EscapeIdentifier(NewRight.FunctionName)
      else if (NewRight.DatabaseName <> '') then
        SingleSQL := SingleSQL + EscapeIdentifier(NewRight.DatabaseName) + '.*'
      else
        SingleSQL := SingleSQL + '*.*';

      SingleSQL := SingleSQL + ' TO ' + EscapeUser(NewUser.Name);
      if (Options <> '') then
        SingleSQL := SingleSQL + ' WITH ' + Options;
      SQL := SQL + SingleSQL + ';' + #13#10;
    end;
  end;

  if (Assigned(User)) then
  begin
    for I := 0 to User.RightCount - 1 do
    begin
      OldRight := User.Right[I];
      NewRight := nil;
      if (Assigned(NewUser)) then
        for J := 0 to NewUser.RightCount - 1 do
          if   ((TableNameCmp(NewUser.Right[J].DatabaseName , OldRight.DatabaseName ) = 0)
            and (TableNameCmp(NewUser.Right[J].TableName    , OldRight.TableName    ) = 0)
            and (TableNameCmp(NewUser.Right[J].ProcedureName, OldRight.ProcedureName) = 0)
            and (TableNameCmp(NewUser.Right[J].FunctionName , OldRight.FunctionName ) = 0)
            and (lstrcmpi(PChar(NewUser.Right[J].FieldName), PChar(OldRight.FieldName)) = 0)) then
            NewRight := NewUser.Right[J];


      if (not Assigned(NewRight)) then
      begin
        RemovedUserRights[User.IndexOf(OldRight)] := True;

        EmptyRight := TCUserRight.Create();
        Privileges := GetPrivileges(False, OldRight, EmptyRight);
        EmptyRight.Free();

        if (Privileges <> '') then
        begin
          SingleSQL := 'REVOKE ' + Privileges + ' ON ';
          if (OldRight.TableName <> '') then
            SingleSQL := SingleSQL + EscapeIdentifier(OldRight.DatabaseName) + '.' + EscapeIdentifier(OldRight.TableName)
          else if (OldRight.ProcedureName <> '') then
            SingleSQL := SingleSQL + 'PROCEDURE ' + EscapeIdentifier(OldRight.DatabaseName) + '.' + EscapeIdentifier(OldRight.ProcedureName)
          else if (OldRight.FunctionName <> '') then
            SingleSQL := SingleSQL + 'FUNCTION ' + EscapeIdentifier(OldRight.DatabaseName) + '.' + EscapeIdentifier(OldRight.FunctionName)
          else if (OldRight.DatabaseName <> '') then
            SingleSQL := SingleSQL + EscapeIdentifier(OldRight.DatabaseName) + '.*'
          else
            SingleSQL := SingleSQL + '*.*';
          SingleSQL := SingleSQL + ' FROM ' + EscapeUser(NewUser.Name);
          SQL := SQL + SingleSQL + ';' + #13#10;
        end;
      end;
    end;
  end;

  if (SQL <> '') then
    SQL := SQL + 'FLUSH PRIVILEGES;' + #13#10;

  if (not Assigned(User) and (NewUser.NewPassword <> '') or Assigned(User) and (NewUser.NewPassword <> User.RawPassword) and (NewUser.RightCount > 0)) then
    SQL := SQL + 'SET PASSWORD FOR ' + EscapeUser(NewUser.Name) + '=PASSWORD(' + SQLEscape(NewUser.NewPassword) + ');' + #13#10;

  Result := ExecuteSQL(SQL);
end;

function TCClient.UpdateVariable(const Variable, NewVariable: TCVariable; const UpdateModes: TCVariable.TUpdateModes): Boolean;
var
  I: Integer;
  SQL: string;
begin
  SQL := 'SET ';
  if (vuGlobal in UpdateModes) then
    SQL := SQL + 'GLOBAL '
  else if (vuSession in UpdateModes) then
    SQL := SQL + 'SESSION ';
  if (TryStrToInt(NewVariable.Value, I)) then
    SQL := SQL + Variable.Name + '=' + NewVariable.Value + ';'
  else
    SQL := SQL + Variable.Name + '=' + SQLEscape(NewVariable.Value) + ';';

  Result := ExecuteSQL(SQL);

  if (Result) then
    Variables.Clear();
end;

function TCClient.UserByCaption(const Caption: string): TCUser;
begin
  if (Caption = '<' + Preferences.LoadStr(287) + '>') then
    Result := UserByName('')
  else
    Result := UserByName(Caption);
end;

function TCClient.UserByName(const UserName: string): TCUser;
var
  Index: Integer;
begin
  Index := Users.IndexByName(UserName);
  if (Index < 0) then
    Result := nil
  else
    Result := Users[Index];
end;

function TCClient.VariableByName(const VariableName: string): TCVariable;
var
  Index: Integer;
begin
  Index := Variables.IndexByName(VariableName);
  if (Index < 0) then
    Result := nil
  else
    Result := Variables[Index];
end;

{ TCClients ***************************************************************}

function TCClients.ClientByAccount(const Account: TSAccount; const DatabaseName: string): TCClient;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Count - 1 do
    if (Clients[I].Account = Account) and (Clients[I].DatabaseName = DatabaseName) then
      Result := Clients[I];

  if (not Assigned(Result)) then
    for I := 0 to Count - 1 do
      if (Clients[I].Account = Account) then
        Result := Clients[I];
end;

constructor TCClients.Create();
begin
  inherited;

  FOnOpenConnection := nil;
end;

function TCClients.CreateClient(const AAccount: TSAccount; out UserAbort: Boolean): TCClient;
var
  Client: TCClient;
begin
  UserAbort := False;

  Client := TCClient.CreateConnection(AAccount);

  if (Assigned(Client)) then
  begin
    Client.OnSQLError := Accounts.OnSQLError;

    if (Assigned(OnOpenConnection)) then
      OnOpenConnection(Client, UserAbort)
    else
      Client.FirstConnect();

    if (not Client.Connected) then
      FreeAndNil(Client)
    else
    begin
      Add(Client);

      AAccount.DesktopCount := AAccount.DesktopCount + 1;
    end;
  end;

  Result := Client;
end;

function TCClients.GetClient(Index: Integer): TCClient;
begin
  Result := TCClient(Items[Index]);
end;

procedure TCClients.ReleaseClient(var AClient: TCClient);
var
  Index: Integer;
begin
  AClient.Account.DesktopCount := AClient.Account.DesktopCount - 1;

  Index := IndexOf(AClient);

  Clients[Index].Free();
  Delete(Index);
end;

initialization
  Clients := TCClients.Create();
finalization
  FreeAndNil(Clients);
end.
