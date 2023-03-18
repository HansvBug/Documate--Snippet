unit Form_Maintain;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  AppDbItems, Visual, SettingsManager, AppDbMaintainComponents;

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
    NewItemObjectData: AllItemObjectData;
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

procedure TFrm_Maintain.ButtonCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrm_Maintain.ComboBoxNewItemChange(Sender: TObject);
begin
  CheckEntryLength(Sender, 255);  // 255 zal per veld gaan verschillen
end;

procedure TFrm_Maintain.ComboBoxNewItemEnter(Sender: TObject);
begin
  if SetMan.SetActiveBackGround then begin
    Visual.ActiveTextBackGroundColor(Sender, True);
  end;
end;

procedure TFrm_Maintain.ButtonAddItemClick(Sender: TObject);
begin
  if ComboBoxNewItem.Text <> '' then begin
    SetLength(NewItemObjectData, FCounter);
    NewItemObjectData[FCounter-1].Name := ComboBoxNewItem.Text;
    NewItemObjectData[FCounter-1].Guid := TGUID.NewGuid.ToString();
    NewItemObjectData[FCounter-1].Level := CurrLevel;
    NewItemObjectData[FCounter-1].Parent_guid := CurrGuid;
    NewItemObjectData[FCounter-1].Child_guid := NewItemObjectData[FCounter-1].Guid;
    Close;
  end;
end;

procedure TFrm_Maintain.ButtonAddNextItemClick(Sender: TObject);
begin
  if ComboBoxNewItem.Text <> '' then begin
    SetLength(NewItemObjectData, FCounter);
    NewItemObjectData[FCounter-1].Name := ComboBoxNewItem.Text;
    NewItemObjectData[FCounter-1].Guid := TGUID.NewGuid.ToString();
    NewItemObjectData[FCounter-1].Level := CurrLevel;
    NewItemObjectData[FCounter-1].Parent_guid := CurrGuid;
    NewItemObjectData[FCounter-1].Child_guid := NewItemObjectData[FCounter-1].Guid;
    Inc(FCounter);

    ComboBoxNewItem.Text := '';
    ComboBoxNewItem.SetFocus;
  end;
end;

end.

