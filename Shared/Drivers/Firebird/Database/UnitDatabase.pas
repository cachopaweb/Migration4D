unit UnitDatabase;

interface
uses
  UnitConnection.Model.Interfaces,
  UnitFactory.Connection.IBExpress;

type
  TDatabase = class
    class function Query: iQuery;
  end;

implementation

uses
  System.SysUtils,
  UnitConfiguration.Model;

{ TDatabase }

class function TDatabase.Query: iQuery;
begin
  Result := TFactoryConnectionIBExpress.New(TConfiguration.fromJson.pathBD).Query;
end;

end.
