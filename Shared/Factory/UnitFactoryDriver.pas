unit UnitFactoryDriver;

interface

uses
  UnitMigration4D.Interfaces;

type
  TFactoryDriver = class(TInterfacedObject, iFactoryDriver)
  private
  public
    constructor Create;
    destructor Destroy; override;
    class function New: iFactoryDriver;
    function GetDriver(Value: TTipoDriver): iDriver;
  end;

implementation

{ TFactoryDriver }

uses UnitFirebird.Driver;

constructor TFactoryDriver.Create;
begin

end;

destructor TFactoryDriver.Destroy;
begin

  inherited;
end;

function TFactoryDriver.GetDriver(Value: TTipoDriver): iDriver;
begin
  case Value of
    Firebird: Result := TFirebirdDriver.New;
    Postgres: ;
  end;
end;

class function TFactoryDriver.New: iFactoryDriver;
begin
  result := Self.Create;
end;

end.
