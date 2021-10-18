unit Horse.Migration4D;

interface

uses Horse,
  System.Generics.Defaults,
  System.Generics.Collections,
  UnitMigration4D.Interfaces;

type
{$SCOPEDENUMS ON}
  TCommand = (Run, Revert);
{$SCOPEDENUMS OFF}

  TMiddlewareMigration = class
  private
    class function StrToTipoDriver(Value: string): TTipoDriver;
  public
    procedure Run(Driver: iDriver);
    procedure Revert(Driver: iDriver);
    class function New: TMiddlewareMigration;
  end;

function HorseMigration4D(Command: TCommand = TCommand.Run): THorseCallback;
procedure Middleware(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

uses UnitMigration4D.Commands.Types,
  UnitRegisterClass.Model,
  System.SysUtils,
  UnitConfiguration.Model,
  UnitMigration4D.Utils,
  UnitMigrations.Model,
  UnitFactoryDriver;

function HorseMigration4D(Command: TCommand = TCommand.Run): THorseCallback;
var
  TipoDriver: TTipoDriver;
  Driver: iDriver;
begin
  TipoDriver := TMiddlewareMigration.StrToTipoDriver(TConfiguration.New.fromJson.Driver);
  Driver     := TFactoryDriver.New.GetDriver(TipoDriver);
  if Command = TCommand.Run then
    TMiddlewareMigration.New.Run(Driver);
  if Command = TCommand.Revert then
    TMiddlewareMigration.New.Revert(Driver);
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

procedure TMiddlewareMigration.Revert(Driver: iDriver);
var
  ClassesRegistradas: TList<TClass>;
  aClass: TClass;
  Migration: TMigrationsModel;
  aClassesRegistradas: TArray<TClass>;
begin
  ClassesRegistradas  := TRegisterClasses.GetClasses;
  aClassesRegistradas := ClassesRegistradas.ToArray;
  TArray.Sort<TClass>(aClassesRegistradas);
  for aClass in ClassesRegistradas do
  begin
    try
      TMigrationCommands.InvokeMethodsClasses(aClass, TMigrationCommandsTypes.Revert, Driver);
    except
      on E: Exception do
      begin
        Writeln('[Error] Execute migration failure. ' + E.Message);
      end;
    end;
  end;
end;

procedure TMiddlewareMigration.Run(Driver: iDriver);
var
  ClassesRegistradas: TList<TClass>;
  aClass: TClass;
  MigrationsExecuteds: TList<string>;
  Migration: TMigrationsModel;
  aClassesRegistradas: TArray<TClass>;
begin
  MigrationsExecuteds := Driver.GetAllMigrationsExecuted;
  ClassesRegistradas  := TRegisterClasses.GetClasses;
  aClassesRegistradas := ClassesRegistradas.ToArray;
  TArray.Sort<TClass>(aClassesRegistradas);
  for aClass in aClassesRegistradas do
  begin
    if not MigrationsExecuteds.Contains(aClass.ClassName) then
    begin
      try
        TMigrationCommands.InvokeMethodsClasses(aClass, TMigrationCommandsTypes.Run, Driver);
      except
        on E: Exception do
        begin
          TMigrationCommands.InvokeMethodsClasses(aClass, TMigrationCommandsTypes.Revert, Driver);
          Writeln('[Error] Execute migration failure. ' + E.Message);
        end;
      end;
    end;
  end;
end;

class function TMiddlewareMigration.StrToTipoDriver(Value: string): TTipoDriver;
var
  ok: Boolean;
begin
  Result := StrToEnumerado(ok, Value, ['FB', 'PG'], [TTipoDriver.Firebird, TTipoDriver.Postgres]);
end;

end.
