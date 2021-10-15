unit UnitMigration4D.Utils;

interface

uses
  System.SysUtils;

  function StrToEnumerado(out ok: Boolean; const s: string; const AString: array of string; const AEnumerados: array of variant): variant;
  function EnumeradoToStr(const t: variant; const AString: array of string; const AEnumerados: array of variant): variant;

implementation

function StrToEnumerado(out ok: Boolean; const s: string; const AString: array of string; const AEnumerados: array of variant): variant;
var
  i: integer;
begin
  Result := -1;
  for i  := Low(AString) to High(AString) do
    if AnsiSameText(s, AString[i]) then
      Result := AEnumerados[i];
  ok         := Result <> -1;
  if not ok then
    Result := AEnumerados[0];
end;

function EnumeradoToStr(const t: variant; const AString: array of string; const AEnumerados: array of variant): variant;
var
  i: integer;
begin
  Result := '';
  for i  := Low(AEnumerados) to High(AEnumerados) do
    if t = AEnumerados[i] then
      Result := AString[i];
end;

end.
