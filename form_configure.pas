unit Form_Configure;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  Buttons, Visual, SettingsManager;

type

  { TFrm_Configure }

  TFrm_Configure = class(TForm)
    ButtonClose: TButton;
    ButtonCompressSQLite: TButton;
    ButtonCopyDatabase: TButton;
    CheckBoxActivateLogging: TCheckBox;
    CheckBoxAppendLogFile: TCheckBox;
    CheckBoxBackGroundColorActiveControle: TCheckBox;
    CheckBoxDisplayHelpText: TCheckBox;
    EditCopyDbFile: TEdit;
    EditSQLiteLibraryLocation: TEdit;
    GroupBoxAppDb: TGroupBox;
    GroupBoxLogging: TGroupBox;
    GroupBoxVisual: TGroupBox;
    Label1: TLabel;
    LabelCopyDbFile: TLabel;
    LabelStatus: TLabel;
    PageControl1: TPageControl;
    SpeedButtonSQLliteDllLocation: TSpeedButton;
    TabSheetDivers: TTabSheet;
    TabSheetAppDatabase: TTabSheet;
    procedure ButtonCloseClick(Sender: TObject);
    procedure ButtonCompressSQLiteClick(Sender: TObject);
    procedure ButtonCompressSQLiteMouseLeave(Sender: TObject);
    procedure ButtonCompressSQLiteMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure ButtonCopyDatabaseClick(Sender: TObject);
    procedure ButtonCopyDatabaseMouseLeave(Sender: TObject);
    procedure ButtonCopyDatabaseMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure CheckBoxActivateLoggingChange(Sender: TObject);
    procedure CheckBoxActivateLoggingMouseLeave(Sender: TObject);
    procedure CheckBoxActivateLoggingMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure CheckBoxAppendLogFileMouseLeave(Sender: TObject);
    procedure CheckBoxAppendLogFileMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure CheckBoxBackGroundColorActiveControleMouseLeave(Sender: TObject);
    procedure CheckBoxBackGroundColorActiveControleMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure CheckBoxDisplayHelpTextChange(Sender: TObject);
    procedure CheckBoxDisplayHelpTextMouseLeave(Sender: TObject);
    procedure CheckBoxDisplayHelpTextMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure EditCopyDbFileMouseLeave(Sender: TObject);
    procedure EditCopyDbFileMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure EditSQLiteLibraryLocationMouseLeave(Sender: TObject);
    procedure EditSQLiteLibraryLocationMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure SpeedButtonSQLliteDllLocationClick(Sender: TObject);
  private
    SetMan : TSettingsManager;
    Visual : TVisual;

    procedure ReadSettings;
    procedure RestoreFormState;
    procedure SaveSettings;
    procedure SetStatusLabelText(aText : String);

  public

  end;

var
  Frm_Configure: TFrm_Configure;

implementation

{$R *.lfm}

uses Form_Main, AppDbMaintain, Settings;

{ TFrm_Configure }

procedure TFrm_Configure.ButtonCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrm_Configure.ButtonCompressSQLiteClick(Sender: TObject);
var
  DbMaintain : TAppDbMaintain;
begin
  Screen.Cursor := crHourGlass;
  DbMaintain := TAppDbMaintain.Create;
  SetStatusLabelText('Alle ID''s resetten...');
  DbMaintain.ResetAutoIncrementAll;

  SetStatusLabelText('Database compress...');
  DbMaintain.CompressAppDatabase;
  DbMaintain.Free;
  SetStatusLabelText('');
  Screen.Cursor := crDefault;
end;

procedure TFrm_Configure.ButtonCompressSQLiteMouseLeave(Sender: TObject);
begin
  SetStatusLabelText(Visual.Helptext(Sender, ''));
end;

procedure TFrm_Configure.ButtonCompressSQLiteMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetStatusLabelText(Visual.Helptext(Sender, 'Comprimeer de database.'));
end;

procedure TFrm_Configure.ButtonCopyDatabaseClick(Sender: TObject);
var
  DbMaintain : TAppDbMaintain;
begin
  Screen.Cursor := crHourGlass;
  DbMaintain := TAppDbMaintain.Create;
  DbMaintain.CopyDbFile;
  DbMaintain.Free;
  Screen.Cursor := crDefault;
end;

procedure TFrm_Configure.ButtonCopyDatabaseMouseLeave(Sender: TObject);
begin
  SetStatusLabelText(Visual.Helptext(Sender, ''));
end;

procedure TFrm_Configure.ButtonCopyDatabaseMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetStatusLabelText(Visual.Helptext(Sender, 'Maak nu een kopie van de applicatie database.'));
end;

procedure TFrm_Configure.CheckBoxActivateLoggingChange(Sender: TObject);
begin
  if CheckBoxActivateLogging.Checked then begin
    CheckBoxAppendLogFile.Enabled := True;
  end
  else begin
    CheckBoxAppendLogFile.Enabled := False;
    CheckBoxAppendLogFile.Checked := False;
  end;
end;

procedure TFrm_Configure.CheckBoxActivateLoggingMouseLeave(Sender: TObject);
begin
  SetStatusLabelText(Visual.Helptext(Sender, ''));
end;

procedure TFrm_Configure.CheckBoxActivateLoggingMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetStatusLabelText(Visual.Helptext(Sender, 'Activeer de log functionaliteit.'));
end;

procedure TFrm_Configure.CheckBoxAppendLogFileMouseLeave(Sender: TObject);
begin
  SetStatusLabelText(Visual.Helptext(Sender, ''));
end;

procedure TFrm_Configure.CheckBoxAppendLogFileMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetStatusLabelText(Visual.Helptext(Sender, 'Vul het bestaande log aan.'));
end;

procedure TFrm_Configure.CheckBoxBackGroundColorActiveControleMouseLeave(
  Sender: TObject);
begin
  SetStatusLabelText(Visual.Helptext(Sender, ''));
end;

procedure TFrm_Configure.CheckBoxBackGroundColorActiveControleMouseMove(
  Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  SetStatusLabelText(Visual.Helptext(Sender, 'Verander achtergrond kleur van het actieve invoerveld.'));
end;

procedure TFrm_Configure.CheckBoxDisplayHelpTextChange(Sender: TObject);
begin
  SaveSettings;
  ReadSettings;
end;

procedure TFrm_Configure.CheckBoxDisplayHelpTextMouseLeave(Sender: TObject);
begin
  SetStatusLabelText(Visual.Helptext(Sender, ''));
end;

procedure TFrm_Configure.CheckBoxDisplayHelpTextMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetStatusLabelText(Visual.Helptext(Sender, 'Toon hulpteksen als de muis over een component beweegt.'));
end;

procedure TFrm_Configure.EditCopyDbFileMouseLeave(Sender: TObject);
begin
  SetStatusLabelText(Visual.Helptext(Sender, ''));
end;

procedure TFrm_Configure.EditCopyDbFileMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetStatusLabelText(Visual.Helptext(Sender, 'Er wordt een kopie van de applicatie database gemaakt na elke ... opstarten van de applicatie.'));
end;

procedure TFrm_Configure.EditSQLiteLibraryLocationMouseLeave(Sender: TObject);
begin
  SetStatusLabelText(Visual.Helptext(Sender, ''));
end;

procedure TFrm_Configure.EditSQLiteLibraryLocationMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetStatusLabelText(Visual.Helptext(Sender, 'Locatie en naam van het SQlite dll bestand. (sqlite3.dll)'));
end;

procedure TFrm_Configure.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  SaveSettings;
  Visual.Free;
  SetMan.Free;
end;

procedure TFrm_Configure.FormCreate(Sender: TObject);
begin
  SetMan := TSettingsManager.Create;
  Caption := 'Opties';
  ReadSettings;
  Visual := TVisual.Create;
  PageControl1.ActivePage := TabSheetDivers;
end;

procedure TFrm_Configure.FormShow(Sender: TObject);
begin
  RestoreFormState;
end;

procedure TFrm_Configure.PageControl1Change(Sender: TObject);
var
  BaseFolder, dbFile : String;
begin
  BaseFolder := ExtractFilePath(Application.ExeName);
  dbFile := BaseFolder + Settings.DatabaseFolder + PathDelim + Settings.DatabaseName;

  if PageControl1.ActivePageIndex = 1 then begin
      if not FileExists(dbFile) then begin
      Frm_main.Logging.WriteToLogError('Database base bestand is niet aanwezig.');
      Frm_main.Logging.WriteToLogError('Betreft bestand: '+ dbFile);
      messageDlg('Fout.', 'Het database base bestand is niet aanwezig.', mtInformation, [mbOK],0);
      ButtonCompressSQLite.Enabled := False;
      ButtonCopyDatabase.Enabled := False;
    end
    else begin
      ButtonCompressSQLite.Enabled := True;
      ButtonCopyDatabase.Enabled := True;
    end;

  end;
end;

procedure TFrm_Configure.SpeedButtonSQLliteDllLocationClick(Sender: TObject);
var
  OpenFileDlg : TOpenDialog;
begin
  OpenFileDlg := TOpenDialog.Create(Self);
  //OpenFileDlg.Filter := 'Dynamic library|*.dll';
  OpenFileDlg.Filter := 'Dynamic library|sqlite3.dll';
  OpenFileDlg.Title := 'Location sqlite3.dll';
  if OpenFileDlg.Execute then
    begin
      EditSQLiteLibraryLocation.Text := OpenFileDlg.FileName;
    end;

  OpenFileDlg.Free;
end;

procedure TFrm_Configure.ReadSettings;
begin
  CheckBoxAppendLogFile.Enabled := False;

  if Setman.AppendLogFile then begin
    CheckBoxAppendLogFile.Checked := True;
  end
  else begin
    CheckBoxAppendLogFile.Checked := False;
  end;

  if SetMan.ActivateLogging then begin
    CheckBoxActivateLogging.Checked := True;
    CheckBoxActivateLogging.Enabled := True;
  end
  else begin
    CheckBoxActivateLogging.Checked := False;
    CheckBoxAppendLogFile.Checked := False;
    CheckBoxAppendLogFile.Enabled := False;
  end;

  EditSQLiteLibraryLocation.Text := SetMan.SQLiteDllLocation;

  if SetMan.SetActiveBackGround then begin
    CheckBoxBackGroundColorActiveControle.Checked := True;
  end
  else begin
    CheckBoxBackGroundColorActiveControle.Checked := False;
  end;

  EditCopyDbFile.Text := IntToStr(SetMan.FileCopyCount);

  if SetMan.DisplayHelpText then begin
    CheckBoxDisplayHelpText.Checked := True;
  end
  else begin
    CheckBoxDisplayHelpText.Checked := False;
  end;

  //..add settings
end;

procedure TFrm_Configure.RestoreFormState;
begin
  SetMan.RestoreFormState(self);
end;

procedure TFrm_Configure.SaveSettings;
begin
  SetMan.StoreFormState(self);

  if CheckBoxActivateLogging.Checked then
    begin
      Setman.ActivateLogging := True;
      Frm_Main.Logging.ActivateLogging := True;
    end
  else
    begin
      Setman.ActivateLogging := False;
      Frm_Main.Logging.ActivateLogging := False;
      Frm_Main.Logging.AppendLogFile := False;
    end;

  if CheckBoxAppendLogFile.Checked then
    begin
      SetMan.AppendLogFile := True;
    end
  else
    begin
      SetMan.AppendLogFile := False;
    end;

  SetMan.SQLiteDllLocation:= EditSQLiteLibraryLocation.Text;

  if  CheckBoxBackGroundColorActiveControle.Checked then begin
    SetMan.SetActiveBackGround := True;
  end
  else  begin
    SetMan.SetActiveBackGround := False;
  end;

  SetMan.FileCopyCount := StrToInt(EditCopyDbFile.Text);

  if CheckBoxDisplayHelpText.Checked then begin
    SetMan.DisplayHelpText := True;
  end
  else begin
    SetMan.DisplayHelpText := False;
  end;

  //..add settings

  SetMan.SaveSettings;
end;

procedure TFrm_Configure.SetStatusLabelText(aText: String);
begin
  if aText <> '' then begin
    LabelStatus.Caption := ' ' + aText;
  end
  else begin
    LabelStatus.Caption := '';
  end;

  Application.ProcessMessages;
end;

end.

