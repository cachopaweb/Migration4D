unit Horse.Migration4D;

interface

uses Horse,
     UnitMigration4D.Interfaces,
     System.Generics.Collections;

type
  TMiddlewareMigration = class
  private
    procedure Run(Driver: iDriver);
  public
    class function New: TMiddlewareMigration;
  end;

function HorseMigration4D(Driver: iDriver): THorseCallback;
procedure Middleware(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

uses UnitMigration4D.Commands.Types,
     UnitRegisterClass.Model,
     System.SysUtils;

function HorseMigration4D(Driver: iDriver): THorseCallback;
begin
  TMiddlewareMigration.New.Run(Driver);
  Result := Middleware;
end;

procedure Middleware(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  try

  finally
    Next;
  end;
end;

{ TMiddlewareMigration }

class function TMiddlewareMigration.New: TMiddlewareMigration;
begin
  Result := Self.Create;
end;

procedure TMiddlewareMigration.Run(Driver: iDriver);
var
  ClassesRegistradas: TList<TClass>;
  aClass: TClass;
begin
  ClassesRegistradas := TRegisterClasses.GetClasses;
  for aClass in ClassesRegistradas do
  begin
    try
      TMigrationsCommans.InvokeMethodsClasses(aClass, TMigrationCommandsTypes.Run, Driver);
    except
      on E: Exception do
      begin
        TMigrationsCommans.InvokeMethodsClasses(aClass, TMigrationCommandsTypes.Revert, Driver);
        Writeln('[Error] Execute migration failure. '+E.Message);
      end;
    end;
  end;
end;

end.
