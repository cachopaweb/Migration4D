unit UnitMigration4D.Commands.Types;

interface

uses
  Rtti,
  System.SysUtils;

type
  TMigrationCommandsTypes = (Init, Create, Run, Revert);

  THelperForMigrationCommandsTypes = record helper for TMigrationCommandsTypes
    function toString: string;
  end;

function StrToMigrationCommandsTypes(Value: string): TMigrationCommandsTypes;
procedure InvokeMethodsClasses(ClassName: TClass; Command: TMigrationCommandsTypes);

implementation

{ THelperForMigrationCommandsTypes }

uses
  UnitMigration4D.Utils,
  UnitQueryRunner.Model,
  UnitMigration4D.Interfaces,
  UnitFirebird.Driver,
  System.Classes;

function StrToMigrationCommandsTypes(Value: string): TMigrationCommandsTypes;
var
  ok: Boolean;
begin
  Result := StrToEnumerado(ok, Value, ['init', 'migration:create', 'migration:run', 'migration:revert'], [Init, Create, Run, Revert])
end;

function THelperForMigrationCommandsTypes.toString: string;
begin
  Result := EnumeradoToStr(Self, ['init', 'migration:create', 'migration:run', 'migration:revert'], [Init, Create, Run, Revert]);
end;

procedure InvokeMethodsClasses(ClassName: TClass; Command: TMigrationCommandsTypes);
var
  rttiContext: TRttiContext;
  rttiType: TRttiInstanceType;
  rttiMethodUp, rttiMethodDown, rttiNew: TRttiMethod;
  Instance: TValue;
  QueryRunnerInstance: TValue;
begin
  rttiContext := TRttiContext.Create;
  try
    rttiType       := rttiContext.GetType(ClassName).AsInstance;
    rttiNew        := rttiType.GetMethod('Create');
    rttiMethodUp   := rttiType.GetMethod('Up');
    rttiMethodDown := rttiType.GetMethod('Down');
    Instance       := rttiNew.Invoke(rttiType.MetaclassType, []);
    QueryRunnerInstance := TValue.From<iQueryRunner>(TQueryRunner.New(TFirebirdDriver.New));
    if Command = TMigrationCommandsTypes.Run then
    begin
      try
        rttiMethodUp.Invoke(Instance, [QueryRunnerInstance])
      except
        rttiMethodDown.Invoke(Instance, [QueryRunnerInstance])
      end;
    end;
    if Command = TMigrationCommandsTypes.Revert then
    begin
      try
        rttiMethodDown.Invoke(Instance, [QueryRunnerInstance])
      except
      end;
    end;
  finally
    rttiContext.Free;
  end;
end;

end.
