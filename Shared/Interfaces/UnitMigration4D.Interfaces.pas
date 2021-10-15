unit UnitMigration4D.Interfaces;

interface

uses
  System.Generics.Collections;

type
  iTable = interface;

  iCollumn = interface
    ['{3D7932E5-9211-44AF-BCAB-D4799C76EE13}']
    function AddCollumn(Name: string; atype: string): iCollumn;
    function &End: iTable;
  end;

  iTable = interface
    ['{BECC0905-7D88-4132-9F6C-E07FA14995A7}']
    function SetName(Value: string): iTable;
    function Name: string;
    function Fields: iCollumn;
    function Collumns: TDictionary<string, string>;
  end;

  iDriver = interface
    ['{D1366B3B-653B-4B47-8F89-F51AE0BEB4F6}']
    function CreateTable(Table: iTable): iDriver;
    function DropTable(Value: string): iDriver;
    function CreateColumn(TableName: string; ColumnName: string; ColumnType: string): iDriver;
    function DropColumn(TableName: string; ColumnName: string): iDriver;
  end;

  iQueryRunner = interface
    ['{FF9345E9-CBB2-4512-83BE-020A6DE31F8D}']
    function CreateTable(Table: iTable): iQueryRunner;
    function DropTable(Value: string): iQueryRunner;
    function CreateColumn(TableName: string; ColumnName: string; ColumnType: string): iQueryRunner;
    function DropColumn(TableName: string; ColumnName: string): iQueryRunner;
  end;

  iCommandRunner = interface
    ['{E841E525-A389-49F4-BD1F-18DA0013F9AD}']
    function Init: iCommandRunner;
    function CreateMigration(Name: string): iCommandRunner;
    procedure Run;
  end;

  iMigration = interface
    { Run the migrations }
    function Up(QueryRunner: iQueryRunner): iMigration;
    { Reverse the migrations }
    function Down(QueryRunner: iQueryRunner): iMigration;
  end;

implementation

end.
