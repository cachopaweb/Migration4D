unit UnitFactoryDriver;

interface

uses
  UnitMigration4D.Interfaces;

type
  TFactoryDriver = class(TInterfacedObject, iFactoryDriver)
  private
    function StrToTipoDriver(Value: string): TTypeDriver;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: iFactoryDriver;
    function GetDriver: iDriver;
  end;

implementation

{ TFactoryDriver }

uses
  UnitFirebird.Driver,
  UnitConfiguration.Model,
  UnitMigration4D.Utils;

constructor TFactoryDriver.Create;
begin

end;

destructor TFactoryDriver.Destroy;
begin

  inherited;
end;

function TFactoryDriver.GetDriver: iDriver;
var
  TypeDriver: TTypeDriver;
begin
  TypeDriver := StrToTipoDriver(TConfiguration.New.fromJson.Driver);
  case TypeDriver of
    Firebird: Result := TFirebirdDriver.New;
    Postgres: ;
  end;
end;

class function TFactoryDriver.New: iFactoryDriver;
begin
  result := Self.Create;
end;

function TFactoryDriver.StrToTipoDriver(Value: string): TTypeDriver;
var
  ok: Boolean;
begin
  Result := StrToEnumerado(ok, Value, ['FB', 'PG'], [TTypeDriver.Firebird, TTypeDriver.Postgres]);
end;

end.
