unit UnitQueryRunner.Model;

interface

uses
  UnitMigration4D.Interfaces;

type
  TQueryRunner = class(TInterfacedObject, iQueryRunner)
  private
    FDriver: iDriver;
    function Driver: iDriver;
  public
    constructor Create(Driver: iDriver);
    destructor Destroy; override;
    class function New(Driver: iDriver): iQueryRunner;
    function CreateTable(Table: iTable): iQueryRunner;
    function DropTable(Value: string): iQueryRunner;
    function CreateColumn(TableName: string; ColumnName: string; ColumnType: string): iQueryRunner;
    function DropColumn(TableName: string; ColumnName: string): iQueryRunner;
  end;

implementation

uses
  System.Classes,
  System.SysUtils;

{ TQueryRunner }

function TQueryRunner.CreateColumn(TableName: string; ColumnName: string; ColumnType: string): iQueryRunner;
begin
  Result := Self;
  FDriver.CreateColumn(TableName, ColumnName, ColumnType);
end;

constructor TQueryRunner.Create(Driver: iDriver);
begin
  FDriver := Driver;
end;

function TQueryRunner.CreateTable(Table: iTable): iQueryRunner;
begin
  Result := Self;
  FDriver.CreateTable(Table);
end;

destructor TQueryRunner.Destroy;
begin

  inherited;
end;

function TQueryRunner.Driver: iDriver;
begin
  Result := FDriver;
end;

function TQueryRunner.DropColumn(TableName: string; ColumnName: string): iQueryRunner;
begin
  Result := Self;
  FDriver.DropColumn(TableName, ColumnName);
end;

function TQueryRunner.DropTable(Value: string): iQueryRunner;
begin
  Result := Self;
  FDriver.DropTable(Value);
end;

class function TQueryRunner.New(Driver: iDriver): iQueryRunner;
begin
  Result := Self.Create(Driver);
end;

end.
