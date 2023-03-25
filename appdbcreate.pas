unit AppDbCreate;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs, Windows, fileutil, ComCtrls,
  AppDb;

type

  { TCreateAppdatabase }

  TCreateAppdatabase = class(TAppDatabase)
    private
      FError : Boolean;
      FNewDatabaseCreated : Boolean;

      function CheckDatabaseFile : boolean;
      procedure SqliteAutoVacuum;
      procedure SqliteJournalMode;
      procedure SqliteSynchronous;
      procedure SqliteTemStore;
      procedure SqliteUserVersion;
      procedure CreTable(TableName, SqlText, Version : String);
      function SelectMeta : Integer;
      procedure UpdateMeta(Version : String);

    public
      constructor Create(DbFileName : String); overload;
      destructor  Destroy; override;
      function CreateNewDatabase : boolean;
      procedure InsertMeta(aKey, aValue : String);
      function IsFileInUse(FileName: TFileName): Boolean;
      procedure CreateAllTables;

  end;
implementation

uses Form_Main, DataModule, Db, Settings;
{ TCreateAppdatabase }

const
  creTblSetmeta =     'create table if not exists ' + SETTINGS_META + ' (' +
                      'KEY      VARCHAR(50), ' +
                      'VALUE    VARCHAR(255));';

  creTblItems =       'create table if not exists ' + ITEMS + ' (' +					  
                      'ID              INTEGER      NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, ' +
                      'GUID            VARCHAR(50)  UNIQUE                                   , ' +
                      'LEVEL	       INTEGER                                               , ' +
                      'NAME            VARCHAR(1000)                                         , ' +
                      'DATE_CREATED    DATE                                                  , ' +
                      'DATE_ALTERED    DATE                                                  , ' +
                      'CREATED_BY      VARCHAR(100)                                          , ' +
                      'ALTERED_BY      VARCHAR(100));';
					  
  creTblRelItems =    'create table if not exists ' + REL_ITEMS + ' (' +
                      'ID              INTEGER      NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, ' +
                      'GUID            VARCHAR(50)  UNIQUE                                   , ' +
                      'GUID_LEVEL_A    VARCHAR(50)                                           , ' +
                      'GUID_LEVEL_B    VARCHAR(50));';

function TCreateAppdatabase.CheckDatabaseFile: boolean;
begin
  if dbFile = '' then begin
    result := false;
    Frm_main.Logging.WriteToLogError('Geen database aangemaakt. Bestandnaam is leeg.');
  end
  else begin
    if not FileExists(dbFile) then begin
      Frm_Main.Logging.WriteToLogInfo('Aanmaken nieuw leeg database bestand op de locatie: '+ dbFile );

      try
        DataModule1.SQLite3Connection.Close();
        DataModule1.SQLite3Connection.DatabaseName := dbFile;
        DataModule1.SQLite3Connection.Open; //creates the file
        DataModule1.SQLite3Connection.Close(True);
        Frm_Main.Logging.WriteToLogInfo('Leeg database bestand is aangemaakt.');
        FNewDatabaseCreated := True;
        result := true;
      except
        on E : Exception do begin
          Frm_Main.Logging.WriteToLogError('Fout bij het aanmaken van een leeg database bestand.');
          Frm_Main.Logging.WriteToLogError('Melding:');
          Frm_Main.Logging.WriteToLogError(E.Message);
          FError := true;
          result := false;
        end;
      end;
    end
    else begin
      Frm_Main.Logging.WriteToLogInfo('Het database bestand bestaat al. ('+ dbFile +').');
      FError := false;
      result := true;
    end;
  end;
end;

procedure TCreateAppdatabase.SqliteAutoVacuum;
begin
  try
    With DataModule1 do begin
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;
      SQLite3Connection.Open;
      SQLTransaction.Active := False;

      SQLite3Connection.ExecuteDirect('End Transaction');       // End the transaction
      SQLite3Connection.ExecuteDirect('PRAGMA auto_vacuum = INCREMENTAL;');
      SQLite3Connection.ExecuteDirect('Begin Transaction');     //Start a transaction for SQLdb to use
      SQLite3Connection.Close();
      Frm_Main.Logging.WriteToLogInfo('Database instelling: auto_vacuum = incremental.');
    end;
  except
    on E : Exception do begin
      Frm_Main.Logging.WriteToLogError('Fout bij maken van een database instelling.');
      Frm_Main.Logging.WriteToLogError('Melding:');
      Frm_Main.Logging.WriteToLogError(E.Message);
      messageDlg('Let op', 'Onverwachte fout bij het maken van een database instelling.', mtError, [mbOK],0);
    end;
  end;
end;

procedure TCreateAppdatabase.SqliteJournalMode;
begin
  try
    With DataModule1 do begin
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;
      SQLite3Connection.Open;
      SQLTransaction.Active := False;

      SQLite3Connection.ExecuteDirect('End Transaction');       // End the transaction
      SQLite3Connection.ExecuteDirect('pragma journal_mode = WAL;');
      SQLite3Connection.ExecuteDirect('Begin Transaction');     //Start a transaction for SQLdb to use
      SQLite3Connection.Close();
      Frm_Main.Logging.WriteToLogInfo('Database instelling: journal_mode = WAL.');
    end;
  except
    on E : Exception do begin
      Frm_Main.Logging.WriteToLogError('Fout bij maken van een database instelling.');
      Frm_Main.Logging.WriteToLogError('Melding:');
      Frm_Main.Logging.WriteToLogError(E.Message);
      messageDlg('Let op', 'Onverwachte fout bij het maken van een database instelling.', mtError, [mbOK],0);
    end;
  end;
end;

procedure TCreateAppdatabase.SqliteSynchronous;
begin
  try
    With DataModule1 do begin
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;
      SQLite3Connection.Open;
      SQLTransaction.Active := False;

      SQLite3Connection.ExecuteDirect('End Transaction');       // End the transaction
      SQLite3Connection.ExecuteDirect('pragma synchronous = normal;');
      SQLite3Connection.ExecuteDirect('Begin Transaction');     //Start a transaction for SQLdb to use
      SQLite3Connection.Close();
      Frm_Main.Logging.WriteToLogInfo('Database instelling: synchronous = normal.');
    end;
  except
    on E : Exception do begin
      Frm_Main.Logging.WriteToLogError('Fout bij maken van een database instelling.');
      Frm_Main.Logging.WriteToLogError('Melding:');
      Frm_Main.Logging.WriteToLogError(E.Message);
      messageDlg('Let op', 'Onverwachte fout bij het maken van een database instelling.', mtError, [mbOK],0);
    end;
  end;
end;

procedure TCreateAppdatabase.SqliteTemStore;
begin
  try
    With DataModule1 do begin
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;
      SQLite3Connection.Open;
      SQLTransaction.Active := False;

      SQLite3Connection.ExecuteDirect('End Transaction');       // End the transaction
      SQLite3Connection.ExecuteDirect('pragma temp_store = memory;');
      SQLite3Connection.ExecuteDirect('Begin Transaction');     //Start a transaction for SQLdb to use
      SQLite3Connection.Close();
      Frm_Main.Logging.WriteToLogInfo('Database instelling: temp_store = memory.');
    end;
  except
    on E : Exception do begin
      Frm_Main.Logging.WriteToLogError('Fout bij maken van een database instelling.');
      Frm_Main.Logging.WriteToLogError('Melding:');
      Frm_Main.Logging.WriteToLogError(E.Message);
      messageDlg('Let op', 'Onverwachte fout bij het maken van een database instelling.', mtError, [mbOK],0);
    end;
  end;
end;

procedure TCreateAppdatabase.SqliteUserVersion;
begin
  try
    With DataModule1 do begin
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;
      SQLite3Connection.Open;
      SQLTransaction.Active := False;

      SQLite3Connection.ExecuteDirect('End Transaction');       // End the transaction
      SQLite3Connection.ExecuteDirect('pragma USER_VERSION = ' + Settings.DataBaseVersion + ';');
      SQLite3Connection.ExecuteDirect('Begin Transaction');     //Start a transaction for SQLdb to use
      SQLite3Connection.Close();
      Frm_Main.Logging.WriteToLogInfo('Database instelling: USER_VERSION = ' + Settings.DatabaseVersion);
    end;
  except
    on E : Exception do begin
      Frm_Main.Logging.WriteToLogError('Fout bij maken van eenm database instelling.');
      Frm_Main.Logging.WriteToLogError('Melding:');
      Frm_Main.Logging.WriteToLogError(E.Message);
      messageDlg('Let op', 'Onverwachte fout bij het maken van een database instelling.', mtError, [mbOK],0);
    end;
  end;
end;

procedure TCreateAppdatabase.CreTable(TableName, SqlText, Version: String);
begin
  try
    Frm_Main.Logging.WriteToLogInfo('Aanmaken tabel: ' + TableName + '. (Versie: ' + Version + ').');
    With DataModule1 do begin
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName:=dbFile;
      SQLite3Connection.Open;
      SQLTransaction.Active:=True;

      SQLite3Connection.ExecuteDirect(SqlText);

      SQLTransaction.Commit;
      SQLite3Connection.Close();
    end;
  except
    on E : Exception do begin
      Frm_Main.Logging.WriteToLogError('Fout bij het aanmaken van de tabel: ' + TableName + '. (Versie: ' + Version + ').');
      Frm_Main.Logging.WriteToLogError('Melding:');
      Frm_Main.Logging.WriteToLogError(E.Message);

      messageDlg('Let op', 'Het aanmaken van de tabel "' + TableName + '" is mislukt.', mtError, [mbOK],0);
      FError := true;
    end;
  end;
end;

procedure TCreateAppdatabase.InsertMeta(aKey, aValue : String);
var
  SqlString : String;
begin
  SqlString := 'insert into ' + SETTINGS_META + ' (KEY, VALUE) values (:KEY, :VALUE)';
  try
    With DataModule1 do begin
      SQLQuery.Close;

      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName:=dbFile;

      SQLQuery.SQL.Text :=SqlString;
      SQLQuery.Params.ParamByName('KEY').AsString := aKey;
      SQLQuery.Params.ParamByName('VALUE').AsString := aValue;

      SQLite3Connection.Open;
      SQLTransaction.Active:=True;

      SQLQuery.ExecSQL;

      SQLTransaction.Commit;
      SQLite3Connection.Close();
      Frm_Main.Logging.WriteToLogInfo('Toegevoegd aan de tabel '+ SETTINGS_META + ' is : ' + aKey + ' - ' + Avalue + '.');
    end;
  except
    on E: EDatabaseError do begin
      Frm_Main.Logging.WriteToLogError('Melding:');
      Frm_Main.Logging.WriteToLogError(E.Message);
      messageDlg('Fout.', 'Het invoeren van "Versienummmer" is mislukt.', mtError, [mbOK],0);
      FError := true;
    end;
  end;
end;

function TCreateAppdatabase.IsFileInUse(FileName: TFileName): Boolean;
var
  HFileRes: HFILE;
begin
  result := False;
  if not FileExists(FileName) then exit;

  HFileRes := CreateFile(PChar(FileName), GENERIC_READ or GENERIC_WRITE, 0, nil,
    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

  result := (HFileRes = INVALID_HANDLE_VALUE);

  if not result then CloseHandle(HFileRes);
end;

function TCreateAppdatabase.SelectMeta: Integer;
var
  SqlString : String;
  Version : Integer;
begin
  SqlString := 'select VALUE from ' + SETTINGS_META + ' where KEY = :KEY';
    try
    With DataModule1 do begin
      SQLQuery.Close;

      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName:=dbFile;

      SQLQuery.SQL.Text := SqlString;
      SQLQuery.Params.ParamByName('KEY').AsString := 'Version';

      SQLite3Connection.Open;

      SQLQuery.Open;
      SQLQuery.First;

      while not SQLQuery.Eof do begin
        Version := SQLQuery.FieldByName('VALUE').AsInteger;
        SQLQuery.Next;
      end;

      SQLQuery.Close;
      SQLite3Connection.Close();

      Frm_Main.Logging.WriteToLogInfo('Versie is opgevraagd. (Tabel: '+ SETTINGS_META + ').');
      Result := Version;
    end;
  except
    on E: EDatabaseError do begin
      Frm_Main.Logging.WriteToLogError('Melding:');
      Frm_Main.Logging.WriteToLogError(E.Message);
      messageDlg('Fout.', 'Opvragen versienummer is mislukt.', mtError, [mbOK],0);
      FError := true;
      Result := -1;
    end;
  end;
end;

procedure TCreateAppdatabase.UpdateMeta(Version: String);
  var
    SqlString : String;
  begin
    SqlString := 'update ' + SETTINGS_META + ' set VALUE = :VALUE where KEY = :KEY;';
      try
      With DataModule1 do begin
        SQLQuery.Close;

        SQLite3Connection.Close();
        SQLite3Connection.DatabaseName:=dbFile;

        SQLQuery.SQL.Text :=SqlString;
        SQLQuery.Params.ParamByName('KEY').AsString := 'Version';
        SQLQuery.Params.ParamByName('VALUE').AsString := Version;

        SQLite3Connection.Open;
        SQLTransaction.Active:=True;

        SQLQuery.ExecSQL;

        SQLTransaction.Commit;
        SQLite3Connection.Close();
        Frm_Main.Logging.WriteToLogInfo('Versie is bijgewerkt in de tabel '+ SETTINGS_META + '.');
      end;
    except
      on E: EDatabaseError do begin
        Frm_Main.Logging.WriteToLogError('Melding:');
        Frm_Main.Logging.WriteToLogError(E.Message);
        messageDlg('Fout.', 'Het actualiseren van het versienummer is mislukt.', mtError, [mbOK],0);
        FError := true;
      end;
    end;
end;


{%region constructor - destructor}
constructor TCreateAppdatabase.Create(DbFileName : String);
begin
  //inherited;
  FNewDatabaseCreated := False;
  dbFile := DbFileName;
end;

destructor TCreateAppdatabase.Destroy;
begin
  inherited Destroy;
end;
{%endregion constructor - destructor}

function TCreateAppdatabase.CreateNewDatabase: boolean;
begin
  if CheckDatabaseFile then begin // check if database file exists, if not then the file is created
    if FNewDatabaseCreated then begin
      //Set SQlite database settings
      SqliteAutoVacuum;
      SqliteJournalMode;
      SqliteSynchronous;
      SqliteTemStore;
      SqliteUserVersion;
      if not FError then CreTable(SETTINGS_META, creTblSetmeta, '0');
      if not FError then InsertMeta('Version', '0');
      if not FError then InsertMeta('DatabaseName', ExtractFileName(dbFile));
    end;
		
    CreateAllTables;  // Create the tables
    result := true;
  end
  else begin
    result := false;
  end;
end;

procedure TCreateAppdatabase.CreateAllTables;
var
  Version : String;
begin
  if FileExists(dbFile) then begin
    if (StrToInt(Settings.DataBaseVersion) >= 1) and (SelectMeta = 0) then begin  // (version 1 tables)
      Version := '1';
      if not FError then CreTable(ITEMS, creTblItems, Version);
      if not FError then CreTable(REL_ITEMS, creTblRelItems, Version);


      if not FError then UpdateMeta(Version);
      Frm_Main.Logging.WriteToLogInfo('Het aanmaken/bijwerken van de database (tabellen) is gereed. (Versie: ' + Version + ').');
    end;

    if StrToInt(Settings.DataBaseVersion) > SelectMeta then begin
      if SelectMeta < 3 then begin
        //Version := '2';

        //if not FError then SqliteUserVersion;
        //if not FError then UpdateMeta(Version);

        //Frm_Main.Logging.WriteToLogInfo('Het aanmaken/bijwerken van de database (tabellen) is gereed. (Versie: ' + Version + ').');
      end;
      {if SelectMeta < 4 then begin
        Version := '3';
        SqliteUserVersion;
        //..
      end;  }
    end;

    if not FError then begin
      messageDlg('Gereed.', 'Het aanmaken/bijwerken van de database (tabellen) is gereed.', mtInformation, [mbOK],0);
    end;
  end
  else begin  // database file does not exists
    Frm_Main.Logging.WriteToLogError('De database is niet gevonden.');
    messageDlg('Let op', 'De database is niet gevonden.', mtError, [mbOK],0);
    FError := true;
  end;
end;
  
end.

