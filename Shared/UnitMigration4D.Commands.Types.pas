unit UnitMigration4D.Commands.Types;

interface

uses
  Rtti,
  UnitMigration4D.Interfaces,
  System.SysUtils;

type
  TMigrationCommandsTypes = (Init, Create, Run, Revert);

  THelperForMigrationCommandsTypes = record helper for TMigrationCommandsTypes
    function toString: string;
  end;

  TMigrationCommands = class
  private
    class procedure CreateTableMigrations(Driver: iDriver);
  public
    class function StrToMigrationCommandsTypes(Value: string): TMigrationCommandsTypes;
    class procedure InvokeMethodsClasses(ClassName: TClass; Command: TMigrationCommandsTypes; Driver: iDriver);
    class procedure RegisterMigrationExecuted(ClassName: TClass; Driver: iDriver);
    class procedure RemoveMigrationExecuted(ClassName: TClass; Driver: iDriver);
  end;

implementation

uses
  UnitMigration4D.Utils,
  UnitQueryRunner.Model,
  System.Classes,
  UnitTable.Model;

class function TMigrationCommands.StrToMigrationCommandsTypes(Value: string): TMigrationCommandsTypes;
var
  ok: Boolean;
begin
  Result := StrToEnumerado(ok, Value, ['init', 'migration:create', 'migration:run', 'migration:revert'], [TMigrationCommandsTypes.Init, TMigrationCommandsTypes.Create, TMigrationCommandsTypes.Run, TMigrationCommandsTypes.Revert])
end;

class procedure TMigrationCommands.CreateTableMigrations(Driver: iDriver);
begin
  TQueryRunner.New(Driver)
    .CreateTable(
      TTable.New.SetName('MIGRATIONS')
        .Fields.AddCollumn('ID', 'INTEGER NOT NULL PRIMARY KEY')
          .AddCollumn('CREATED_AT', 'TIMESTAMP')
          .AddCollumn('NAME', 'VARCHAR(1000)')
        .&End
    );
end;

class procedure TMigrationCommands.InvokeMethodsClasses(ClassName: TClass; Command: TMigrationCommandsTypes; Driver: iDriver);
var
  rttiContext: TRttiContext;
  rttiType: TRttiInstanceType;
  rttiMethodUp, rttiMethodDown, rttiNew: TRttiMethod;
  Instance: TValue;
  QueryRunnerInstance: TValue;
begin
  rttiContext := TRttiContext.Create;
  try
    rttiType            := rttiContext.GetType(ClassName).AsInstance;
    rttiNew             := rttiType.GetMethod('Create');
    rttiMethodUp        := rttiType.GetMethod('Up');
    rttiMethodDown      := rttiType.GetMethod('Down');
    Instance            := rttiNew.Invoke(rttiType.MetaclassType, []);
    QueryRunnerInstance := TValue.From<iQueryRunner>(TQueryRunner.New(Driver));
    if Command = TMigrationCommandsTypes.Run then
    begin
      try
        rttiMethodUp.Invoke(Instance, [QueryRunnerInstance]);
        TMigrationCommands.RegisterMigrationExecuted(ClassName, Driver);
      except

      end;
    end;
    if Command = TMigrationCommandsTypes.Revert then
    begin
      try
        rttiMethodDown.Invoke(Instance, [QueryRunnerInstance]);
        TMigrationCommands.RemoveMigrationExecuted(ClassName, Driver);
      except

      end;
    end;
  finally
    rttiContext.Free;
  end;
end;

class procedure TMigrationCommands.RegisterMigrationExecuted(ClassName: TClass; Driver: iDriver);
begin
  CreateTableMigrations(Driver);
  Driver.InsertMigrationsExecuted(ClassName.ClassName);
end;

class procedure TMigrationCommands.RemoveMigrationExecuted(ClassName: TClass; Driver: iDriver);
begin
  Driver.RemoveMigrationsExecuted(ClassName.ClassName);
end;

{ THelperForMigrationCommandsTypes }

function THelperForMigrationCommandsTypes.toString: string;
begin
  Result := EnumeradoToStr(Self, ['init', 'migration:create', 'migration:run', 'migration:revert'], [Init, Create, Run, Revert]);
end;

end.
