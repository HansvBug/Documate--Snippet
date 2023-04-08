unit AppDb;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms;

type

  { TAppDatabase }

  TAppDatabase = class(TObject)
    private
      FdbFile, FBaseFolder, FDatabaseVersion : String;

    protected
      property BaseFolder      : String Read FBaseFolder Write FBaseFolder;
      property DatabaseVersion : String Read FDatabaseVersion write FDatabaseVersion;
      property dbFile : String Read FdbFile Write FdbFile;

    public
      constructor Create(FullDbFilePath : String); overload;
      destructor  Destroy; override;

    published
  end;

const
  SETTINGS_META = 'SETTINGS_META';
  ITEMS		= 'ITEMS';
  REL_ITEMS	= 'REL_ITEMS';

implementation
uses Settings;

{ TAppDatabase }

constructor TAppDatabase.Create(FullDbFilePath : String);
begin
  FdbFile := FullDbFilePath;
  DatabaseVersion := Settings.DataBaseVersion;
end;

destructor TAppDatabase.Destroy;
begin
  //...
  inherited Destroy;
end;

end.

