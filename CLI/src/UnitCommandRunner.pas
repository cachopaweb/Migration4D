unit UnitCommandRunner;

interface

uses
  UnitMigration4D.Interfaces;

type
  TCommandRunner = class(TInterfacedObject, iCommandRunner)
  private
  public
    constructor Create;
    destructor Destroy; override;
    class function New: iCommandRunner;
    function CreateMigration(Name: string): iCommandRunner;
    function Init: iCommandRunner;
    procedure Run;
  end;

implementation

uses
  System.Classes, 
  UnitConfiguration.Model, 
  System.SysUtils, 
  System.Rtti,
  UnitMigration4D.Commands.Types, 
  System.JSON, 
  Rest.Json;

{ TCommandRunner }

function FormatJSON(json: String): String;
var
  tmpJson: TJsonObject;
begin
  tmpJson := TJSONObject.ParseJSONValue(json) as TJSONObject;
  Result := TJson.Format(tmpJson);
  FreeAndNil(tmpJson);
end;

constructor TCommandRunner.Create;
begin

end;

function TCommandRunner.CreateMigration(Name: string): iCommandRunner;
var SourceCodeUnit: TStringList;
    Arq: TextFile;
const DirectoryMigrations = 'Migrations';
begin
  SourceCodeUnit := TStringList.Create;
  try
    try
      SourceCodeUnit.Add('Unit Unit[TIMESTAMP].[NAME];');
      SourceCodeUnit.Add('');
      SourceCodeUnit.Add('interface');
      SourceCodeUnit.Add('');
      SourceCodeUnit.Add('uses');
      SourceCodeUnit.Add('  UnitMigration4D.Interfaces,');
      SourceCodeUnit.Add('  System.Classes,');
      SourceCodeUnit.Add('  UnitRegisterClass.Model;');
      SourceCodeUnit.Add('');
      SourceCodeUnit.Add('type');
      SourceCodeUnit.Add('  T[NAME][TIMESTAMP] = class');
      SourceCodeUnit.Add('  private');
      SourceCodeUnit.Add('  public');
      SourceCodeUnit.Add('    procedure Up(QueryRunner: iQueryRunner);');
      SourceCodeUnit.Add('    procedure Down(QueryRunner: iQueryRunner);');
      SourceCodeUnit.Add('  end;');
      SourceCodeUnit.Add('');
      SourceCodeUnit.Add('implementation');
      SourceCodeUnit.Add('');
      SourceCodeUnit.Add('{ T[NAME][TIMESTAMP]  }');
      SourceCodeUnit.Add('');
      SourceCodeUnit.Add('uses');
      SourceCodeUnit.Add('  UnitTable.Model,');
      SourceCodeUnit.Add('  UnitQueryRunner.Model;');
      SourceCodeUnit.Add('');
      SourceCodeUnit.Add('procedure T[NAME][TIMESTAMP].Up(QueryRunner: iQueryRunner);');
      SourceCodeUnit.Add('begin');
      SourceCodeUnit.Add('//  QueryRunner.CreateTable(');
      SourceCodeUnit.Add('//    TTable.New');
      SourceCodeUnit.Add('//      .SetName(''[TABLE_NAME]'')');
      SourceCodeUnit.Add('//      .Fields');
      SourceCodeUnit.Add('//        .AddCollumn(''[COLUMN_PREFIX]_ID'', ''INTEGER NOT NULL PRIMARY KEY'')');
      SourceCodeUnit.Add('//        .AddCollumn(''[COLUMN_PREFIX]_NAME'', ''VARCHAR(50)'')');
      SourceCodeUnit.Add('//      .&End');
      SourceCodeUnit.Add('//  );');
      SourceCodeUnit.Add('//  QueryRunner.CreateColumn(''[TABLE_NAME]'', ''[COLUMN_PREFIX]_NAME'', ''VARCHAR(50)'');}');
      SourceCodeUnit.Add('end;');
      SourceCodeUnit.Add('');
      SourceCodeUnit.Add('procedure T[NAME][TIMESTAMP].Down(QueryRunner: iQueryRunner);');
      SourceCodeUnit.Add('begin');
      SourceCodeUnit.Add('//  QueryRunner.DropTable(''[TABLE_NAME]'');');
      SourceCodeUnit.Add('//  QueryRunner.DropColumn(''[COLUMN_PREFIX]_NAME'');');
      SourceCodeUnit.Add('end;');
      SourceCodeUnit.Add('');
      SourceCodeUnit.Add('initialization');
      SourceCodeUnit.Add('  TRegisterClasses.Registry(T[NAME][TIMESTAMP]);');
      SourceCodeUnit.Add('');
      SourceCodeUnit.Add('end.');

      //replace for name migration
      SourceCodeUnit.Text := SourceCodeUnit.Text.Replace('[NAME]', Name.ToUpper);
      SourceCodeUnit.Text := SourceCodeUnit.Text.Replace('[TIMESTAMP]', FormatDateTime('yyymmdd', Date));
      SourceCodeUnit.Text := SourceCodeUnit.Text.Replace('[TABLE_NAME]', 'CLIENTS');
      SourceCodeUnit.Text := SourceCodeUnit.Text.Replace('[COLUMN_PREFIX]', 'CLI');
      if not DirectoryExists(DirectoryMigrations) then
        CreateDir(DirectoryMigrations);
      Assign(Arq, DirectoryMigrations+'/'+Format('Unit%s.%s.pas', [FormatDateTime('yyymmdd', Date), Name.ToUpper]));
      Rewrite(Arq);
      Write(Arq, SourceCodeUnit.Text);
      CloseFile(Arq);
      Writeln(Format('Unit%s.%s.pas', [FormatDateTime('yyymmdd', Date), Name.ToUpper])+' Created Success!'+sLineBreak);
    except on E: Exception do
      raise Exception.Create('Error try create UnitMigration');
    end;
  finally
    SourceCodeUnit.Free;
  end;
end;

destructor TCommandRunner.Destroy;
begin

  inherited;
end;

function TCommandRunner.Init: iCommandRunner;
var stringStream: TStringStream;
  Configuration: TConfiguration;
begin
  stringStream := TStringStream.Create;
  try
    try
      Configuration := TConfiguration.New;
      Configuration.Driver := 'FB';
      Configuration.pathBD := '../../PRINCIPAL.FDB';
      stringStream.WriteString(FormatJSON(Configuration.toJsonObject.ToString));
      stringStream.SaveToFile(ChangeFileExt('Migration4D', '.json'));
      Writeln('Migration4D.json generated with success!'+sLineBreak);
    except on E: Exception do
      Writeln('Failure try create Migration4D.json'+sLineBreak+E.Message+sLineBreak);
    end;
  finally
    stringStream.Free;
  end;
end;

class function TCommandRunner.New: iCommandRunner;
begin
  Result := Self.Create;
end;

procedure TCommandRunner.Run;
var
  rttiContext: TRttiContext;
  rttiType: TRttiInstanceType;
  rttiMethodCreateMigration, rttiNew, rttiMethodInit: TRttiMethod;
  Instance: TValue;
  QueryRunnerInstance: TValue;
  Command: TMigrationCommandsTypes;
begin
  rttiContext := TRttiContext.Create;
  Command := TMigrationCommands.StrToMigrationCommandsTypes(ParamStr(1));
  try
    rttiType       := rttiContext.GetType(Self.NewInstance.ClassType).AsInstance;
    rttiNew        := rttiType.GetMethod('Create');
    Instance       := rttiNew.Invoke(rttiType.MetaclassType, []);
    rttiMethodInit            := rttiType.GetMethod('Init');
    rttiMethodCreateMigration := rttiType.GetMethod('CreateMigration');
    if Command = TMigrationCommandsTypes.Init then
    begin
      try
        rttiMethodInit.Invoke(Instance, [])
      except
        rttiMethodInit.Invoke(Instance, [])
      end;
    end;
    if Command = TMigrationCommandsTypes.Create then
    begin
      if (ParamStr(2) = '-n') and (ParamStr(3) <> '') then
        rttiMethodCreateMigration.Invoke(Instance, [ParamStr(3)]);
    end;
  finally
    rttiContext.Free;
  end;
end;

end.
