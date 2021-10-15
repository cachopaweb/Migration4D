unit UnitRegisterClass.Model;

interface
uses
  System.Generics.Collections;

type
  TRegisterClasses = class
  class var FListClass: TList<TClass>;
  public
    class constructor Create;
    class destructor Destroy;
    class procedure Registry(Value: TClass);
    class function GetClasses: TList<TClass>;
  end;

implementation

{ TRegisterClasses }

class constructor TRegisterClasses.Create;
begin
  FListClass := TList<TClass>.Create;
end;

class destructor TRegisterClasses.Destroy;
begin
  FListClass.Free;
end;

class function TRegisterClasses.GetClasses: TList<TClass>;
begin
  Result := FListClass;
end;

class procedure TRegisterClasses.Registry(Value: TClass);
begin
  FListClass.Add(Value);
end;

end.
