# Migration4D
Generate Migrations for Delphi and Framework Horse

### For install CLI Migration4D using [boss](https://github.com/HashLoad/boss):
``` sh
$ boss install -g github.com/CachopaWeb/Migration4D/CLI
```

# Horse-Server-Static
Middleware for Run the migrations 

### For install in your project using [boss](https://github.com/HashLoad/boss):
``` sh
$ boss install github.com/CachopaWeb/Migration4D/Middleware
```

Sample Horse Server
```delphi

uses System.SysUtils,
     Horse,
     Horse.Migration4D;

begin
  THorse.Use(HorseMigration4D);
  {run migrations based in file configuration    Magration4D.json, generated with command CLI "Migration 4D Init"}

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
