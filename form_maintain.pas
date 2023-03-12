unit Form_Maintain;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  AppDbItems, Visual;

type

  { TFrm_Maintain }

  TFrm_Maintain = class(TForm)
    ButtonAddItem: TButton;
    ButtonClose: TButton;
    ComboBoxNewItem: TComboBox;
    Label1: TLabel;
    procedure ButtonAddItemClick(Sender: TObject);
    procedure ButtonCloseClick(Sender: TObject);
    procedure ComboBoxNewItemChange(Sender: TObject);
    procedure ComboBoxNewItemExit(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    Visual  : TVisual;
    procedure CheckEntryLength(Sender: TObject; aLength : Integer);
  public
    ItemObjectData : AllItemObjectData;
  end;

var
  Frm_Maintain: TFrm_Maintain;

implementation

uses AppDbMaintainComponents;
{$R *.lfm}

{ TFrm_Maintain }

procedure TFrm_Maintain.FormCreate(Sender: TObject);
begin
  Visual := TVisual.Create;
  ButtonAddItem.Enabled := False;
  ComboBoxNewItem.Sorted := True;  { #todo 1 : Optie van maken. }
  ComboBoxNewItem.ShowHint := True; { #todo 2 : OPtie van maken }
  ComboBoxNewItem.TextHint := 'Nieuw item';     { #todo 2 : Constant van maken }
end;

procedure TFrm_Maintain.FormDestroy(Sender: TObject);
begin
  Visual.Free;
end;

procedure TFrm_Maintain.FormShow(Sender: TObject);
var
  i : Integer;
begin
  for i := 0 to Length(ItemObjectData)-1 do begin
    ComboBoxNewItem.Items.Add(ItemObjectData[i].Name);
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
  // add new items to the combobox itemlist.
  if ComboBoxNewItem.Items.IndexOf(ComboBoxNewItem.text) = -1 then begin
    ComboBoxNewItem.Items.Add(ComboBoxNewItem.Text);
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

procedure TFrm_Maintain.ButtonAddItemClick(Sender: TObject);
begin
  if ComboBoxNewItem.Text <> '' then begin
    AppDbMaintainComponents.NewItem := ComboBoxNewItem.Text;
    Close;
  end;
end;

end.

