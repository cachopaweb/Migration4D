program Migration4D;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  UnitCommandRunner in 'src\UnitCommandRunner.pas',
  UnitMigration4D.Commands.Types in '..\Shared\UnitMigration4D.Commands.Types.pas',
  UnitMigration4D.Interfaces in '..\Shared\Interfaces\UnitMigration4D.Interfaces.pas',
  UnitFirebird.Driver in '..\Shared\Drivers\Firebird\UnitFirebird.Driver.pas',
  UnitDatabase in '..\Shared\Drivers\Firebird\Database\UnitDatabase.pas',
  UnitConfiguration.Model in '..\Shared\Models\UnitConfiguration.Model.pas',
  UnitQueryRunner.Model in '..\Shared\Models\UnitQueryRunner.Model.pas',
  UnitRegisterClass.Model in '..\Shared\Models\UnitRegisterClass.Model.pas',
  UnitTable.Model in '..\Shared\Models\UnitTable.Model.pas',
  UnitMigration4D.Utils in '..\Shared\Utils\UnitMigration4D.Utils.pas';

begin
  try
    TCommandRunner.New.Run;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
