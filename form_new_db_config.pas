unit form_new_db_config;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Visual, SettingsManager;

type

  { TFrm_new_database }

  TFrm_new_database = class(TForm)
    ButtonNewFile: TButton;
    EditNumberOfColumns: TEdit;
    LabelStatus: TLabel;
    LabelColumnNumber: TLabel;
    procedure ButtonNewFileClick(Sender: TObject);
    procedure ButtonNewFileMouseLeave(Sender: TObject);
    procedure ButtonNewFileMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure EditNumberOfColumnsChange(Sender: TObject);
    procedure EditNumberOfColumnsEnter(Sender: TObject);
    procedure EditNumberOfColumnsExit(Sender: TObject);
    procedure EditNumberOfColumnsMouseLeave(Sender: TObject);
    procedure EditNumberOfColumnsMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    SetMan : TSettingsManager;
    Visual : TVisual;
    FCanClose : Boolean;

    procedure SetStatusLabelText(aText : String);

  public

  end;

var
  Frm_new_database: TFrm_new_database;

implementation

uses Form_Main, Settings;

{$R *.lfm}

{ TFrm_new_database }

{ #todo : create Range check on Edit }

procedure TFrm_new_database.ButtonNewFileClick(Sender: TObject);
begin
  Frm_main.NumberOfColumns := StrToInt(EditNumberOfColumns.Text);
  Close;
end;

procedure TFrm_new_database.ButtonNewFileMouseLeave(Sender: TObject);
begin
  SetStatusLabelText(Visual.Helptext(Sender, ''));
end;

procedure TFrm_new_database.ButtonNewFileMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetStatusLabelText(Visual.Helptext(Sender, 'Het database bestand wordt aangemaakt.'));
end;

procedure TFrm_new_database.EditNumberOfColumnsChange(Sender: TObject);
begin
  if StrToInt(EditNumberOfColumns.Text) > 20 then begin
    EditNumberOfColumns.Font.Color := clRed;
    SetStatusLabelText('U kunt maximaal 20 kolommen opgeven.');
    ButtonNewFile.Enabled := False;
    FCanClose := False;
  end
  else begin
    EditNumberOfColumns.Font.Color := clDefault;
    SetStatusLabelText('');
    ButtonNewFile.Enabled := True;
    FCanClose := True;
  end;
end;

procedure TFrm_new_database.EditNumberOfColumnsEnter(Sender: TObject);
begin
  if SetMan.SetActiveBackGround then begin
    Visual.ActiveTextBackGroundColor(Sender, True);
  end;
end;

procedure TFrm_new_database.EditNumberOfColumnsExit(Sender: TObject);
begin
  Visual.ActiveTextBackGroundColor(Sender, False);
end;

procedure TFrm_new_database.EditNumberOfColumnsMouseLeave(Sender: TObject);
begin
  SetStatusLabelText(Visual.Helptext(Sender, ''));
end;

procedure TFrm_new_database.EditNumberOfColumnsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetStatusLabelText(Visual.Helptext(Sender, 'Geef het aantal kolommen op.'));
end;

procedure TFrm_new_database.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  Visual.Free;
  SetMan.Free;
end;

procedure TFrm_new_database.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := FCanClose;
end;

procedure TFrm_new_database.FormCreate(Sender: TObject);
begin
  Caption := 'Nieuw database bestand.';
  ButtonNewFile.Enabled := False;
  SetMan := TSettingsManager.Create;
  Visual := TVisual.Create;
  FCanClose := False;
end;

procedure TFrm_new_database.FormShow(Sender: TObject);
begin
  EditNumberOfColumns.SetFocus;
end;

procedure TFrm_new_database.SetStatusLabelText(aText: String);
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

