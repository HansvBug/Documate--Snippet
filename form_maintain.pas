unit Form_Maintain;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  AppDbItems, Visual, SettingsManager,
  form_Main;

type

  { TFrm_Maintain }

  TFrm_Maintain = class(TForm)
    ButtonAddNextItem: TButton;
    ButtonAddItem: TButton;
    ButtonClose: TButton;
    ComboBoxNewItem: TComboBox;
    Label1: TLabel;
    procedure ButtonAddItemClick(Sender: TObject);
    procedure ButtonAddNextItemClick(Sender: TObject);
    procedure ButtonCloseClick(Sender: TObject);
    procedure ComboBoxNewItemChange(Sender: TObject);
    procedure ComboBoxNewItemEnter(Sender: TObject);
    procedure ComboBoxNewItemExit(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    Visual  : TVisual;
    FCurrLevel, FCounter : Integer;
    FCurrGuid : String;

    //CurrItemObjectData : AllItemObjectData;

    procedure CheckEntryLength(Sender: TObject; aLength : Integer);
  public
    NewItemObjectData: AllItemsObjectData;
    property CurrLevel : Integer read FCurrLevel write FCurrLevel;
    property CurrGuid : String read FCurrGuid write FCurrGuid;

  end;

var
  Frm_Maintain: TFrm_Maintain;
  SetMan : TSettingsManager;

implementation

{$R *.lfm}

{ TFrm_Maintain }

procedure TFrm_Maintain.FormCreate(Sender: TObject);
begin
  Visual := TVisual.Create;
  SetMan := TSettingsManager.Create;
  FCounter := 1;

  ButtonAddItem.Enabled := False;
  ComboBoxNewItem.Sorted := True;  { #todo 1 : Optie van maken. }
  ComboBoxNewItem.ShowHint := True; { #todo 2 : OPtie van maken }
  ComboBoxNewItem.TextHint := 'Nieuw item';     { #todo 2 : Constant van maken }
end;

procedure TFrm_Maintain.FormDestroy(Sender: TObject);
begin
  Visual.Free;
  SetMan.Free;
end;

procedure TFrm_Maintain.FormShow(Sender: TObject);
var
  i : Integer;
begin
  for i := 0 to Length(NewItemObjectData)-1 do begin
    ComboBoxNewItem.Items.Add(NewItemObjectData[i].Name);
  end;

  ComboBoxNewItem.SetFocus;
end;

procedure TFrm_Maintain.CheckEntryLength(Sender: TObject; aLength: Integer);
begin
  if Visual.CheckEntryLength(Sender, aLength) then begin
    ButtonAddItem.Enabled := True;
  end
  else begin
    ButtonAddItem.Enabled := False;
  end;
end;

procedure TFrm_Maintain.ComboBoxNewItemExit(Sender: TObject);
begin
  Visual.ActiveTextBackGroundColor(Sender, False);
  // add new items to the combobox itemlist.
  if ComboBoxNewItem.Text <> '' then begin
    if ComboBoxNewItem.Items.IndexOf(ComboBoxNewItem.text) = -1 then begin
      ComboBoxNewItem.Items.Add(ComboBoxNewItem.Text);
    end;
  end;
end;

procedure TFrm_Maintain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  i : Integer;
begin
  for i := Length(NewItemObjectData)-1 downto 0 do begin
    if NewItemObjectData[i].Action <> 'Insert' then begin
      delete(NewItemObjectData, i, 1);
    end;
  end;
  CanClose := True; // Just to avoid hint CanClose is not used.
end;

procedure TFrm_Maintain.ButtonCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrm_Maintain.ComboBoxNewItemChange(Sender: TObject);
begin
  CheckEntryLength(Sender, 1000);
end;

procedure TFrm_Maintain.ComboBoxNewItemEnter(Sender: TObject);
begin
  if SetMan.SetActiveBackGround then begin
    Visual.ActiveTextBackGroundColor(Sender, True);
  end;
end;

procedure TFrm_Maintain.ButtonAddItemClick(Sender: TObject);
var
  i : Integer;
  isNew : Boolean;
begin
  if ComboBoxNewItem.Text <> '' then begin
    isNew := True;
    // Eerst zoeken of een item al bestaat
    for i := 0 to Length(NewItemObjectData)-1 do begin
      if NewItemObjectData[i].Name = ComboBoxNewItem.Text then begin

        if Frm_Main.DebugMode then Frm_Main.Logging.WriteToLogDebug('Nieuw item aan de array toevoegen. (ButtonAddItemClick)/');
        NewItemObjectData[FCounter-1].Name := ComboBoxNewItem.Text;
        NewItemObjectData[FCounter-1].Guid := TGUID.NewGuid.ToString();
        NewItemObjectData[FCounter-1].Level := CurrLevel;
        SetLength(NewItemObjectData[FCounter-1].Parent_guid, 1);
        NewItemObjectData[FCounter-1].Parent_guid[0] := CurrGuid;  // Alway the first (and only) item in the array
        NewItemObjectData[FCounter-1].Child_guid := NewItemObjectData[i].Child_guid;
        NewItemObjectData[FCounter-1].Action := 'Insert';
        Inc(FCounter);
        isNew := False;
      end;
    end;

    if isNew then begin
      if Frm_Main.DebugMode then Frm_Main.Logging.WriteToLogDebug('Nieuw item aan de array toevoegen. (ButtonAddItemClick)/');
      SetLength(NewItemObjectData, FCounter);
      NewItemObjectData[FCounter-1].Name := ComboBoxNewItem.Text;
      NewItemObjectData[FCounter-1].Guid := TGUID.NewGuid.ToString();
      NewItemObjectData[FCounter-1].Level := CurrLevel;
      SetLength(NewItemObjectData[FCounter-1].Parent_guid, 1);
      NewItemObjectData[FCounter-1].Parent_guid[0] := CurrGuid;
      NewItemObjectData[FCounter-1].Child_guid := NewItemObjectData[FCounter-1].Guid;
      NewItemObjectData[FCounter-1].Action := 'Insert';
      Inc(FCounter);
    end;
  end;

  // in FormCloseQuery  the items where action <> "Insert' get deleted
  Close;
end;

procedure TFrm_Maintain.ButtonAddNextItemClick(Sender: TObject);
var
  i : Integer;
  isNew : Boolean;
begin
  if ComboBoxNewItem.Text <> '' then begin
    isNew := True;
    for i := 0 to Length(NewItemObjectData)-1 do begin
      if Frm_Main.DebugMode then Frm_Main.Logging.WriteToLogDebug('Volgend nieuw item aan de array toevoegen. (ButtonAddNextItemClick)/');
      if NewItemObjectData[i].Name = ComboBoxNewItem.Text then begin
        NewItemObjectData[FCounter-1].Name := ComboBoxNewItem.Text;
        NewItemObjectData[FCounter-1].Guid := TGUID.NewGuid.ToString();
        NewItemObjectData[FCounter-1].Level := CurrLevel;
        SetLength(NewItemObjectData[FCounter-1].Parent_guid, 1);
        NewItemObjectData[FCounter-1].Parent_guid[0] := CurrGuid;
        NewItemObjectData[FCounter-1].Child_guid := NewItemObjectData[i].Child_guid;
        NewItemObjectData[FCounter-1].Action := 'Insert';
        Inc(FCounter);
        isNew := False;
      end;
    end;

    if isNew then begin
      if Frm_Main.DebugMode then Frm_Main.Logging.WriteToLogDebug('Volgend nieuw item aan de array toevoegen. (ButtonAddNextItemClick)/');
      SetLength(NewItemObjectData, FCounter);
      NewItemObjectData[FCounter-1].Name := ComboBoxNewItem.Text;
      NewItemObjectData[FCounter-1].Guid := TGUID.NewGuid.ToString();
      NewItemObjectData[FCounter-1].Level := CurrLevel;
      SetLength(NewItemObjectData[FCounter-1].Parent_guid, 1);
      NewItemObjectData[FCounter-1].Parent_guid[0] := CurrGuid;
      NewItemObjectData[FCounter-1].Child_guid := NewItemObjectData[FCounter-1].Guid;
      NewItemObjectData[FCounter-1].Action := 'Insert';
      Inc(FCounter);
    end;

    ComboBoxNewItem.Text := '';
    ComboBoxNewItem.SetFocus;
  end;
end;

end.

