unit UnitFirebird.Driver;

interface

uses
  System.Classes,
  UnitMigration4D.Interfaces;

type
  TFirebirdDriver = class(TInterfacedObject, iDriver)
  private
  public
    constructor Create;
    destructor Destroy; override;
    class function New: iDriver;
    function CreateTable(Table: iTable): iDriver;
    function DropTable(Value: string): iDriver;
    function CreateColumn(TableName: string; ColumnName: string; ColumnType: string): iDriver;
    function DropColumn(TableName, ColumnName: string): iDriver;
  end;

implementation
uses
  System.SysUtils,
  System.Generics.Collections,
  UnitDatabase,
  UnitConnection.Model.Interfaces;

{ TDriverFirebird }

function TFirebirdDriver.CreateColumn(TableName: string; ColumnName: string; ColumnType: string): iDriver;
var
  Query: iQuery;
  ScriptSQL: string;
begin
  Result := Self;
  Writeln(Format('[INFO] Create Column %s on Table %s', [ColumnName, TableName]));
  ScriptSQL := Format('ALTER TABLE %s ADD %s %s', [TableName, ColumnName, ColumnType]);
  Writeln('[INFO] '+ScriptSQL);
  Query := TDatabase.Query;
  Query.Add(ScriptSQL);
  Query.ExecSQL;
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
begin
  Result := Self;
  ScripSQL := TStringList.Create;
  try
    Writeln('[INFO] Creating table '+Table.Name);
    ScripSQL.Add('CREATE TABLE ' + Table.Name + '(');
    LArray := Table.Collumns.Keys.ToArray;
    TArray.Sort<string>(LArray);
    for Value in LArray do
    begin
      ScripSQL.Add('  ' + Value + ' ' + Table.Collumns.Items[Value] + ',');
    end;
    ScripSQL.Text := ScripSQL.Text.Remove(ScripSQL.Text.LastIndexOf(','), 1);
    ScripSQL.Add(');');
    Writeln('[INFO] '+ScripSQL.Text+sLineBreak);
    Query := TDatabase.Query;
    Query.Add(ScripSQL.Text);
    Query.ExecSQL;
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
  Result := Self;
  ScriptSQL := Format('ALTER TABLE %s DROP %s', [TableName, ColumnName]);
  Writeln('[INFO] '+ScriptSQL);
  Query := TDatabase.Query;
  Query.Add(ScriptSQL);
  Query.ExecSQL;
end;

function TFirebirdDriver.DropTable(Value: string): iDriver;
var ScripSQL: TStringList;
  Query: iQuery;
begin
  Result := Self;
  ScripSQL := TStringList.Create;
  try
    Writeln('[INFO] Deleting table '+Value);
    ScripSQL.Add('DROP TABLE ' + Value + ';');
    Writeln('[INFO] '+ScripSQL.Text+sLineBreak);
    Query := TDatabase.Query;
    Query.Add(ScripSQL.Text);
    Query.ExecSQL;
  finally
    ScripSQL.Free;
  end;
end;

class function TFirebirdDriver.New: iDriver;
begin
  Result := Self.Create;
end;

end.
