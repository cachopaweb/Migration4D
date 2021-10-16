unit UnitMigrations.Model;

interface
type
  TMigrationsModel = class
  private
    Fid: integer;
    FName: string;
  public
    property id: integer read Fid write Fid;
    property Name: string read FName write FName;
  end;

implementation

end.
