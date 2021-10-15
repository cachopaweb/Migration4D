unit Horse.Migration4D;

interface

uses Horse,
     System.Generics.Collections;

type
  TMiddlewareMigration = class
  private
    procedure Run;
  public
    class function New: TMiddlewareMigration;
  end;

function HorseMigration4D: THorseCallback;
procedure Middleware(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

uses UnitMigration4D.Commands.Types,
     UnitRegisterClass.Model,
     System.SysUtils;

function HorseMigration4D: THorseCallback;
begin
  TMiddlewareMigration.New.Run;
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

procedure TMiddlewareMigration.Run;
var
  ClassesRegistradas: TList<TClass>;
  aClass: TClass;
begin
  ClassesRegistradas := TRegisterClasses.GetClasses;
  for aClass in ClassesRegistradas do
  begin
    try
      InvokeMethodsClasses(aClass, TMigrationCommandsTypes.Run);
    except
      on E: Exception do
      begin
        InvokeMethodsClasses(aClass, TMigrationCommandsTypes.Revert);
        Writeln('[Error] Execute migration failure. '+E.Message);
      end;
    end;
  end;
end;

end.
