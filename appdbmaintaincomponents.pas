unit AppDbMaintainComponents;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Windows, Dialogs, StdCtrls,
  ExtCtrls, ComCtrls, typinfo,
  AppDb, AppDbItems;

type

  { TAppDbMaintainComponents }

  TAppDbMaintainComponents = class(TAppDatabase)
    private
    public
      constructor Create; overload;
      destructor  Destroy; override;
//      procedure InsertComponent(newComponent : String; level : Byte);
//      procedure GetAllComponents(aListBox : TListBox; level : Byte);
//      Procedure ReadLevel(var AllItems : AllItemObjectData; level: Byte);
//      procedure PopulateListbox;
  end;

var
  NewItem : String;  // hold a new item
  AllItems : AllItemObjectData;
  listBox : TListBox;


implementation

{ TAppDbMaintainComponents }

constructor TAppDbMaintainComponents.Create;
begin
  inherited;
  //..
end;

destructor TAppDbMaintainComponents.Destroy;
begin
  inherited Destroy;
end;

end.

