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
    Parent_guid  : String;
    Name         : String;
  end;
  AllItemObjectData = array of ItemObjectData;

var
  p : PtrItemObject;

implementation

end.

