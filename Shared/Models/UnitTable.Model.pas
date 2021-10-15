unit UnitTable.Model;

interface

uses
  System.Generics.Collections,
  UnitMigration4D.Interfaces;

type
  TTable = class(TInterfacedObject, iTable, iCollumn)
  private
    FCollumns: TDictionary<String, String>;
    FNameTable: string;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: iTable;
    function SetName(Value: string): iTable;
    function AddCollumn(Name: string; atype: string): iCollumn;
    function &End: iTable;
    function Name: string;
    function Collumns: TDictionary<string, string>;
    function Fields: iCollumn;
  end;

implementation

{ TTable }

function TTable.&End: iTable;
begin
  Result := Self;
end;

function TTable.Fields: iCollumn;
begin
  Result := Self;
end;

function TTable.Collumns: TDictionary<string, string>;
begin
  Result := FCollumns;
end;

constructor TTable.Create;
begin
  FCollumns := TDictionary<String, String>.Create;
end;

destructor TTable.Destroy;
begin
  FCollumns.DisposeOf;
  inherited;
end;

function TTable.Name: string;
begin
  Result := FNameTable;
end;

class function TTable.New: iTable;
begin
  Result := Self.Create;
end;

function TTable.AddCollumn(Name: string; atype: string): iCollumn;
begin
  Result := Self;
  FCollumns.Add(Name, atype);
end;

function TTable.SetName(Value: string): iTable;
begin
  Result     := Self;
  FNameTable := Value;
end;

end.
