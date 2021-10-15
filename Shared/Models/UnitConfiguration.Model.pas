unit UnitConfiguration.Model;

interface
uses
  System.Json;

type
  TConfiguration = class
  private
    FDriver: string;
    FpathBD: string;
  published
    property Driver: string read FDriver write FDriver;
    property pathBD: string read FpathBD write FpathBD;
    class function fromJson: TConfiguration;
    function toJsonObject: TJSONObject;
    class function New: TConfiguration;
  end;

implementation
uses
  Rest.Json,
  System.SysUtils,
  System.Classes;

{ TConfiguration }

class function TConfiguration.fromJson: TConfiguration;
var
  FileConfig: string;
  FileStream: TStringStream;
begin
  FileConfig := '../../'+ChangeFileExt('Migration4D', '.json');
  if not FileExists(FileConfig) then
    raise Exception.Create('File configuration not found!'+sLineBreak+'Run command "Migration4D init" for create file.');
  FileStream := TStringStream.Create;
  try
    FileStream.LoadFromFile(FileConfig);
    FileStream.Position := 0;
    Result := TJson.JsonToObject<TConfiguration>(FileStream.DataString);
  finally
    FileStream.Free;
  end;
end;

class function TConfiguration.New: TConfiguration;
begin
  Result := Self.Create;
end;

function TConfiguration.toJsonObject: TJSONObject;
begin
  Result := TJson.ObjectToJsonObject(Self);
end;

end.
