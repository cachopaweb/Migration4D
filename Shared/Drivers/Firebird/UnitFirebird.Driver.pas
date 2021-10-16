unit UnitFirebird.Driver;

interface

uses
  System.Classes,
  System.Generics.Collections,
  UnitMigrations.Model,
  UnitMigration4D.Interfaces;

type
  TFirebirdDriver = class(TInterfacedObject, iDriver)
  private
    function GetNextId(TableName: string; ColumnName: string): integer;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: iDriver;
    function CreateTable(Table: iTable): iDriver;
    function DropTable(Value: string): iDriver;
    function CreateColumn(TableName: string; ColumnName: string; ColumnType: string): iDriver;
    function DropColumn(TableName, ColumnName: string): iDriver;
    procedure InsertMigrationsExecuted(ClassName: string);
    procedure RemoveMigrationsExecuted(ClassName: string);
    function GetAllMigrationsExecuted: TList<TMigrationsModel>;
  end;

implementation

uses
  System.SysUtils,
  UnitDatabase,
  UnitConnection.Model.Interfaces;

{ TDriverFirebird }

function TFirebirdDriver.CreateColumn(TableName: string; ColumnName: string; ColumnType: string): iDriver;
var
  Query: iQuery;
  ScriptSQL: string;
begin
  Result := Self;
  Query  := TDatabase.Query;
  Query.Add('SELECT COUNT(*) QTDE FROM RDB$RELATION_FIELDS A WHERE A.RDB$SYSTEM_FLAG=0 AND A.RDB$FIELD_NAME = :CAMPO AND A.RDB$RELATION_NAME = :TABELA');
  Query.AddParam('CAMPO', ColumnName.ToUpper);
  Query.AddParam('TABELA', TableName.ToUpper);
  Query.Open;
  if Query.DataSet.IsEmpty then
  begin
    Writeln(Format('[INFO] Create Column %s on Table %s', [ColumnName, TableName]));
    ScriptSQL := Format('ALTER TABLE %s ADD %s %s', [TableName, ColumnName, ColumnType]);
    Writeln('[INFO] ' + ScriptSQL);
    Writeln('[INFO]');
    Query.Clear;
    Query.Add(ScriptSQL);
    Query.ExecSQL;
  end;
end;

constructor TFirebirdDriver.Create;
begin

end;

function TFirebirdDriver.CreateTable(Table: iTable): iDriver;
var
  Value: string;
  ScripSQL: TStringList;
  LArray: TArray<string>;
  Query: iQuery;
  line: string;
begin
  Result   := Self;
  ScripSQL := TStringList.Create;
  try
    Query := TDatabase.Query;
    Query.Open(Format('SELECT RDB$RELATION_NAME FROM RDB$RELATIONS WHERE RDB$RELATION_NAME = ''%s''', [Table.Name.ToUpper]));
    if Query.DataSet.IsEmpty then
    begin
      Writeln('[INFO] Creating table ' + Table.Name);
      ScripSQL.Add('CREATE TABLE ' + Table.Name + '(');
      LArray := Table.GetColumns.Keys.ToArray;
      TArray.Sort<string>(LArray);
      for Value in LArray do
      begin
        ScripSQL.Add('  ' + Value + ' ' + Table.GetColumns.Items[Value] + ',');
      end;
      ScripSQL.Text := ScripSQL.Text.Remove(ScripSQL.Text.LastIndexOf(','), 1);
      ScripSQL.Add(');');
      for line in ScripSQL do
      begin
        Writeln('[INFO] ' + line);
      end;
      Writeln('[INFO]');
      Query.Clear;
      Query.Add(ScripSQL.Text);
      Query.ExecSQL;
    end;
  finally
    ScripSQL.Free;
  end;
end;

destructor TFirebirdDriver.Destroy;
begin

  inherited;
end;

function TFirebirdDriver.DropColumn(TableName, ColumnName: string): iDriver;
var
  Query: iQuery;
  ScriptSQL: string;
begin
  Result    := Self;
  ScriptSQL := Format('ALTER TABLE %s DROP %s', [TableName, ColumnName]);
  Writeln('[INFO] ' + ScriptSQL);
  Writeln('[INFO]');
  Query := TDatabase.Query;
  Query.Add(ScriptSQL);
  Query.ExecSQL;
end;

function TFirebirdDriver.DropTable(Value: string): iDriver;
var
  ScripSQL: TStringList;
  Query: iQuery;
begin
  Result   := Self;
  ScripSQL := TStringList.Create;
  try
    Writeln('[INFO] Deleting table ' + Value);
    ScripSQL.Add('DROP TABLE ' + Value + ';');
    Writeln('[INFO] ' + ScripSQL.Text);
    Writeln('[INFO]');
    Query := TDatabase.Query;
    Query.Add(ScripSQL.Text);
    Query.ExecSQL;
  finally
    ScripSQL.Free;
  end;
end;

function TFirebirdDriver.GetAllMigrationsExecuted: TList<TMigrationsModel>;
var
  Query: iQuery;
  Migration: TMigrationsModel;
begin
  Result := TList<TMigrationsModel>.Create;
  Query  := TDatabase.Query;
  Query.Open('SELECT RDB$RELATION_NAME FROM RDB$RELATIONS WHERE RDB$RELATION_NAME = ''MIGRATIONS''');
  if not Query.DataSet.IsEmpty then
  begin
    Query := TDatabase.Query;
    Query.Open('SELECT ID, NAME FROM MIGRATIONS');
    if not Query.DataSet.IsEmpty then
    begin
      Query.DataSet.First;
      while not Query.DataSet.Eof do
      begin
        Migration      := TMigrationsModel.Create;
        Migration.id   := Query.DataSet.FieldByName('ID').AsInteger;
        Migration.Name := Query.DataSet.FieldByName('NAME').AsString;
        Result.Add(Migration);
        Query.DataSet.Next;
      end;
    end;
  end;
end;

function TFirebirdDriver.GetNextId(TableName, ColumnName: string): integer;
var
  Query: iQuery;
begin
  Result := 1;
  Query  := TDatabase.Query;
  Query.Open(Format('SELECT MAX(%s) FROM %s', [ColumnName, TableName]));
  if not Query.DataSet.IsEmpty then
  begin
    Result := Query.DataSet.Fields[0].AsInteger + 1;
  end;
end;

procedure TFirebirdDriver.InsertMigrationsExecuted(ClassName: string);
var
  Query: iQuery;
begin
  Writeln('[INFO] Inserting Register Migration '+ClassName);
  Writeln('[INFO] ');
  Query := TDatabase.Query;
  Query.Add('INSERT INTO MIGRATIONS(ID, CREATED_AT, NAME) VALUES (:ID, :CREATED_AT, :NAME)');
  Query.AddParam('ID', GetNextId('MIGRATIONS', 'ID'));
  Query.AddParam('CREATED_AT', Now);
  Query.AddParam('NAME', ClassName);
  Query.ExecSQL;
end;

class function TFirebirdDriver.New: iDriver;
begin
  Result := Self.Create;
end;

procedure TFirebirdDriver.RemoveMigrationsExecuted(ClassName: string);
var
  Query: iQuery;
begin
  Writeln('[INFO] Removing Register Migration '+ClassName);
  Writeln('[INFO]');
  Query := TDatabase.Query;
  Query.Add(Format('DELETE FROM MIGRATIONS WHERE UPPER(NAME) = ''%s''', [ClassName.ToUpper]));
  Query.ExecSQL;
end;

end.
