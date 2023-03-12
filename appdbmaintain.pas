unit AppDbMaintain;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs, Windows, fileutil, ComCtrls,
  AppDb;

type

  { TAppDbMaintain }

  TAppDbMaintain = class(TAppDatabase)
    private
      function IsFileInUse(FileName: TFileName): Boolean;

    public
      constructor Create; overload;
      destructor  Destroy; override;

      procedure CompressAppDatabase;
      function CopyDbFile: Boolean;
      procedure Optimze;
      procedure ResetAutoIncrementAll;
      procedure ResetAutoIncrementTbl(aTblName : String);  // Not used
  end;

implementation

uses Form_Main, DataModule, Settings, Db;
{ TAppDbMaintain }

function TAppDbMaintain.IsFileInUse(FileName: TFileName): Boolean;
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

constructor TAppDbMaintain.Create;
begin
  inherited;
end;

destructor TAppDbMaintain.Destroy;
begin
  //..
  inherited Destroy;
end;

procedure TAppDbMaintain.CompressAppDatabase;
begin
  try
    With DataModule1 do begin
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;
      SQLite3Connection.Open;
      SQLTransaction.Active := False;

      SQLite3Connection.ExecuteDirect('End Transaction');       // End the transaction
      SQLite3Connection.ExecuteDirect('VACUUM');
      SQLite3Connection.ExecuteDirect('Begin Transaction');     //Start a transaction for SQLdb to use
      SQLite3Connection.Close();
      Frm_Main.Logging.WriteToLogInfo('De database is schoongemaakt en verkleind.');
    end;
  except
    on E : Exception do begin
      Frm_Main.Logging.WriteToLogError('Fout bij het comprimeren van de applicatie database.');
      Frm_Main.Logging.WriteToLogError('Melding:');
      Frm_Main.Logging.WriteToLogError(E.Message);
      messageDlg('Let op', 'Onverwachte fout bij het comprimeren van de applicatie database.', mtError, [mbOK],0);
    end;
  end;
end;

function TAppDbMaintain.CopyDbFile: Boolean;
var
  Prefix : String;
  SrcFilename, DestFilename : String;
begin
  SrcFilename := ExtractFilePath(Application.ExeName) + Settings.DatabaseFolder + PathDelim + Settings.DatabaseName;

  if not IsFileInUse(SrcFilename) then begin
    Prefix := FormatDateTime('YYYYMMDD_', Now);
    DestFilename := ExtractFilePath(Application.ExeName) + Settings.DatabaseFolder + PathDelim + Settings.BackupFolder + PathDelim + Prefix + Settings.DatabaseName;

    if FileExists(SrcFilename) then begin
      if not FileExists(DestFilename) then begin
        CopyFile(SrcFilename, DestFilename);
        Frm_Main.Logging.WriteToLogInfo('Kopie van de applicatie database is gemaakt.');
        Frm_Main.Logging.WriteToLogInfo('Kopie is: ' + DestFilename);
        Result := True;
      end
      else begin
        if MessageDlg('Let op.', 'Het bestand bestaat al. Wilt u het overschrijven?'  + sLineBreak +
                                 sLineBreak +
                                 'Bestand: ' + DestFilename,
                                 mtWarning, [mbYes, mbNo], 0, mbNo) = mrYes then begin
           CopyFile(SrcFilename, DestFilename, [cffOverwriteFile]);
           Frm_Main.Logging.WriteToLogInfo('Kopie van de applicatie database is gemaakt.');
           Frm_Main.Logging.WriteToLogInfo('Kopie is: ' + DestFilename);
           Result := True;
           end;
      end;
    end
    else begin
      messageDlg('Fout.', 'Het database bestand is niet gevonden.', mtError, [mbOK],0);
      Result := False;
    end;
  end
  else begin
    messageDlg('Let op.', 'Het bestand is in gebruik (door iemand anders). ' +sLineBreak +
                        'Er wordt géén kopie gemaakt.' , mtWarning, [mbOK],0);
    Result := False;
  end;
end;

procedure TAppDbMaintain.Optimze;
begin
  try
    With DataModule1 do begin
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;
      SQLite3Connection.Open;
      SQLTransaction.Active := False;

      SQLite3Connection.ExecuteDirect('End Transaction');       // End the transaction
      SQLite3Connection.ExecuteDirect('pragma optimize;');
      SQLite3Connection.ExecuteDirect('Begin Transaction');     //Start a transaction for SQLdb to use
      SQLite3Connection.Close();
      Frm_Main.Logging.WriteToLogInfo('De database is geoptimaliseerd.');
    end;
  except
    on E : Exception do begin
      Frm_Main.Logging.WriteToLogError('Fout bij het optimaliseren van de applicatie database.');
      Frm_Main.Logging.WriteToLogError('Melding:');
      Frm_Main.Logging.WriteToLogError(E.Message);
      messageDlg('Let op', 'Onverwachte fout bij het optimaliseren van de applicatie database.', mtError, [mbOK],0);
    end;
  end;
end;

procedure TAppDbMaintain.ResetAutoIncrementAll;
var
  SqlText : String;
begin
  SqlText := 'delete from sqlite_sequence';
  With DataModule1 do begin
    try
      SQLQuery.Close;
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;

      SQLQuery.SQL.Text := SqlText;

      SQLite3Connection.Open;
      SQLTransaction.Active:=True;

      SQLQuery.ExecSQL;

      SQLTransaction.Commit;
      SQLite3Connection.Close();

      Frm_Main.Logging.WriteToLogInfo('De ID''s van alle tabellen zijn gereset.');
    except
      on E : Exception do begin
        Frm_Main.Logging.WriteToLogError('Fout bij resetten van alle id''s.');
        Frm_Main.Logging.WriteToLogError('Melding:');
        Frm_Main.Logging.WriteToLogError(E.Message);

        messageDlg('Fout.', 'Fout bij resetten van alle id''s.', mtError, [mbOK],0);
      end;
    end;
  end;
end;

procedure TAppDbMaintain.ResetAutoIncrementTbl(aTblName: String);
var
  SqlText : String;
begin
  SqlText := 'delete from sqlite_sequence where name = :TABLE_NAME';
  With DataModule1 do begin
    try
      SQLQuery.Close;
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;

      SQLQuery.SQL.Text := SqlText;
      SQLQuery.Params.ParamByName('TABLE_NAME').AsString := aTblName;

      SQLite3Connection.Open;
      SQLTransaction.Active:=True;

      SQLQuery.ExecSQL;

      SQLTransaction.Commit;
      SQLite3Connection.Close();

      Frm_Main.Logging.WriteToLogInfo('De ID''s van de tabel ' + aTblName +  ' zijn gereset.');
    except
      on E : Exception do begin
        Frm_Main.Logging.WriteToLogError('Fout bij resetten van de id''s.');
        Frm_Main.Logging.WriteToLogError('Melding:');
        Frm_Main.Logging.WriteToLogError(E.Message);

        messageDlg('Fout.', 'Fout bij resetten van de id''s.', mtError, [mbOK],0);
      end;
    end;
  end;
end;

end.

