unit form_new_db_config;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  Visual, SettingsManager;

type

  { TFrm_new_database }

  TFrm_new_database = class(TForm)
    ButtonStop: TButton;
    ButtonCancel: TButton;
    ButtonNewFile: TButton;
    EditDescriptionShort: TEdit;
    EditNumberOfColumns: TEdit;
    LabelDescriptionShort: TLabel;
    LabelColumnNumber: TLabel;
    StatusBarFrmNewDb: TStatusBar;
    procedure ButtonCancelClick(Sender: TObject);
    procedure ButtonNewFileClick(Sender: TObject);
    procedure ButtonNewFileMouseLeave(Sender: TObject);
    procedure ButtonNewFileMouseMove(Sender: TObject);
    procedure ButtonStopClick(Sender: TObject);
    procedure EditDescriptionShortChange(Sender: TObject);
    procedure EditDescriptionShortEnter(Sender: TObject);
    procedure EditDescriptionShortExit(Sender: TObject);
    procedure EditDescriptionShortMouseLeave(Sender: TObject);
    procedure EditDescriptionShortMouseMove(Sender: TObject);
    procedure EditNumberOfColumnsChange(Sender: TObject);
    procedure EditNumberOfColumnsEnter(Sender: TObject);
    procedure EditNumberOfColumnsExit(Sender: TObject);
    procedure EditNumberOfColumnsMouseLeave(Sender: TObject);
    procedure EditNumberOfColumnsMouseMove(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    SetMan : TSettingsManager;
    Visual : TVisual;
    FCanClose, FCancel : Boolean;

    procedure SetStatusbarText(aText : String);

  public

  end;

var
  Frm_new_database: TFrm_new_database;

implementation

uses Form_Main;

{$R *.lfm}

{ TFrm_new_database }

{ #todo : create Range check on Edit }

procedure TFrm_new_database.ButtonNewFileClick(Sender: TObject);
begin
  Frm_main.NumberOfColumns := StrToInt(EditNumberOfColumns.Text);
  Frm_main.DbDescriptionShort := EditDescriptionShort.Text;
  Close;
end;

procedure TFrm_new_database.ButtonCancelClick(Sender: TObject);
begin
  FCanClose := true;
  FCancel := true;
  Close;
end;

procedure TFrm_new_database.ButtonNewFileMouseLeave(Sender: TObject);
begin
  SetStatusbarText(Visual.Helptext(Sender, ''));
end;

procedure TFrm_new_database.ButtonNewFileMouseMove(Sender: TObject);
begin
  SetStatusbarText(Visual.Helptext(Sender, 'Het database bestand wordt aangemaakt.'));
end;

procedure TFrm_new_database.ButtonStopClick(Sender: TObject);
begin
  FCanClose := true;
  Frm_Main.CanContinue := False;
  Close;
end;

procedure TFrm_new_database.EditDescriptionShortChange(Sender: TObject);
begin
  if Visual.CheckEntryLength(Sender, 255) then begin
    ButtonNewFile.Enabled := True;
  end
  else begin
    ButtonNewFile.Enabled := False;
  end;
end;

procedure TFrm_new_database.EditDescriptionShortEnter(Sender: TObject);
begin
  if SetMan.SetActiveBackGround then begin
    Visual.ActiveTextBackGroundColor(Sender, True);
  end;
end;

procedure TFrm_new_database.EditDescriptionShortExit(Sender: TObject);
begin
  Visual.ActiveTextBackGroundColor(Sender, False);
end;

procedure TFrm_new_database.EditDescriptionShortMouseLeave(Sender: TObject);
begin
  SetStatusbarText(Visual.Helptext(Sender, ''));
end;

procedure TFrm_new_database.EditDescriptionShortMouseMove(Sender: TObject);
begin
  SetStatusbarText(Visual.Helptext(Sender, 'Geef een korte omschrijving van de nieuwe database.'));
end;

procedure TFrm_new_database.EditNumberOfColumnsChange(Sender: TObject);
begin
  if EditNumberOfColumns.Text <> '' then begin
    if StrToInt(EditNumberOfColumns.Text) > 20 then begin
      EditNumberOfColumns.Font.Color := clRed;
      SetStatusbarText('U kunt maximaal 20 kolommen opgeven.');
      ButtonNewFile.Enabled := False;
      FCanClose := False;
    end
    else if StrToInt(EditNumberOfColumns.Text) = 0 then begin
      EditNumberOfColumns.Font.Color := clRed;
      SetStatusbarText('Minimaal 1 kolom opgeven.');
      ButtonNewFile.Enabled := False;
      FCanClose := False;
    end
    else begin
      EditNumberOfColumns.Font.Color := clDefault;
      SetStatusbarText('');
      ButtonNewFile.Enabled := True;
      FCanClose := True;
    end;
  end
  else begin
    EditNumberOfColumns.Font.Color := clDefault;
    SetStatusbarText('');
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
  SetStatusbarText(Visual.Helptext(Sender, ''));
end;

procedure TFrm_new_database.EditNumberOfColumnsMouseMove(Sender: TObject);
begin
  SetStatusbarText(Visual.Helptext(Sender, 'Geef het aantal kolommen op.'));
end;

procedure TFrm_new_database.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  Visual.Free;
  SetMan.Free;
  CloseAction := caFree;
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
  FCancel := False;
end;

procedure TFrm_new_database.FormDestroy(Sender: TObject);
begin
  if FCancel then begin
    Frm_main.MenuItemProgramNewClick(Self);
  end;
end;

procedure TFrm_new_database.FormShow(Sender: TObject);
begin
  EditNumberOfColumns.SetFocus;
end;


procedure TFrm_new_database.SetStatusbarText(aText: String);
begin
  if aText <> '' then begin
    StatusBarFrmNewDb.Panels.Items[0].Text := ' ' + aText;
  end
  else begin
    StatusBarFrmNewDb.Panels.Items[0].Text := '';
  end;

  Application.ProcessMessages;
end;

end.

