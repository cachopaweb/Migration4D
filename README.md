# Migration4D
Generate Migrations for Delphi and Framework Horse

### For install CLI Migration4D using [boss](https://github.com/HashLoad/boss):
``` sh
$ boss install github.com/CachopaWeb/Migration4D
```

Sample Horse Server
```delphi

uses System.SysUtils,
     Horse,
     Horse.Migration4D;

begin
  THorse.Use(HorseMigration4D());
  //run migrations based in file configuration    
  //Migration4D.json, generated with command CLI "Migration4D Init"
  //Run generated migrations with command CLI "Migration4D migration:create -n name"

  THorse.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end);

  THorse.Listen(9000,
  procedure (App: THorse)
  begin
    Writeln('Server is running on port '+App.Port.ToString);
  end);

end.
```
