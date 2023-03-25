unit AppDbItems;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  PtrItemObject = ^ItemObjectData;
  ItemObjectData = record
    Id_array     : Integer;  // array index
    Id_table     : Integer;  // item index
    Guid         : String;
    Level        : Integer;
    Parent_guid  : array of String;
    Child_guid   : String;
    Name         : String;
    Action       : String;
  end;
  AllItemsObjectData = array of ItemObjectData;

var
  p : PtrItemObject;

implementation

end.

