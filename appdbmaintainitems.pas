unit AppDbMaintainItems;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, ComCtrls, typinfo,
  AppDb, AppDbItems;

type

  { TAppDbMaintainItems }

  TAppDbMaintainItems = class(TAppDatabase)
    private
      arrayCounter : Integer;

      function GetNumbers(const Value: string): String;
      procedure DeleteItemSelf(Guid : String);
      function DeleteItemRel(Guid : String; level : Integer) : Boolean;

    public
      AllItems : AllItemsObjectData;
      curListBox : TListBox;

      constructor Create(FullDbFilePath : String); overload;
      destructor  Destroy; override;
      procedure InsertNewItem(NewItems: AllItemsObjectData);
      procedure InsertRelation(NewItems: AllItemsObjectData);
      procedure UpdateRelation(NewItems: AllItemsObjectData);
      function InsertModifiedRelation(ptr : PtrItemObject) : Boolean;
      procedure UpdateItem(NewItems: AllItemsObjectData);
      procedure GetAllItems(aListBox : TListBox; level : Byte);
      Procedure ReadLevel(level: Byte);
      Procedure RelateItem;
      procedure PopulateListbox;
      function DoesItemNameExists(aName : String; aLevel : Integer) : Boolean;
      procedure DeleteItem(Guid : String; level : Integer);
      procedure DeleteItemRel(Guid, parentGuid : String; level : Integer);

  end;


implementation

uses Form_Main, DataModule, Db;
{ TAppDbMaintainItems }

function TAppDbMaintainItems.GetNumbers(const Value: string): String;
var
  ch: char;
  Index, Count: integer;
begin
  { #todo : Dezelfde functie staat ook in het main form }
  Result := '';
  SetLength(Result, Length(Value));
  Count := 0;
  for Index := 1 to length(Value) do
  begin
    ch := Value[Index];
    if (ch >= '0') and (ch <='9') then
    begin
      inc(Count);
      Result[Count] := ch;
    end;
  end;
  SetLength(Result, Count);
end;

constructor TAppDbMaintainItems.Create(FullDbFilePath : String);
begin
  dbFile := FullDbFilePath;
  AllItems := nil;
  arrayCounter := 0;
end;

destructor TAppDbMaintainItems.Destroy;
begin
  inherited Destroy;
end;

procedure TAppDbMaintainItems.InsertNewItem(NewItems: AllItemsObjectData);
var
  SqlText : String;
  i : Integer;
begin
  for i := 0 to Length(NewItems) -1 do begin
    if NewItems[i].Guid <> '' then begin
      if Frm_Main.DebugMode then Frm_Main.Logging.WriteToLogDebug('Toevoegen nieuw item.');

      SqlText := 'insert into ' + ITEMS + '(GUID, LEVEL, NAME, DATE_CREATED, CREATED_BY) ';
      SqlText += 'select :GUID, :LEVEL, :NAME, :DATE_CREATED, :CREATED_BY ';
      SqlText += 'where not exists (select NAME from ' + ITEMS;
      SqlText += ' where NAME = :NAME and LEVEL = :LEVEL);';

      try
        With DataModule1 do begin
          SQLQuery.Close;
          SQLite3Connection.Close();
          SQLite3Connection.DatabaseName := dbFile;

          SQLQuery.SQL.Text := SqlText;

          SQLQuery.Params.ParamByName('GUID').AsString := NewItems[i].Guid;
          SQLQuery.Params.ParamByName('LEVEL').AsInteger := NewItems[i].Level;
          SQLQuery.Params.ParamByName('NAME').AsString := NewItems[i].Name;
          SQLQuery.Params.ParamByName('DATE_CREATED').AsString := FormatDateTime('DD MM YYYY hh:mm:ss', Now);
          SQLQuery.Params.ParamByName('CREATED_BY').AsString := SysUtils.GetEnvironmentVariable('USERNAME');

          SQLite3Connection.Open;
          SQLTransaction.Active:=True;

          SQLQuery.ExecSQL;

          SQLTransaction.Commit;
          SQLite3Connection.Close();

          Frm_Main.Logging.WriteToLogInfo('Component ' + NewItems[i].Name + ' is toegevoegd aan tabel ' + ITEMS + '.');
        end;
      except
        on E: EDatabaseError do
          begin
            Frm_Main.Logging.WriteToLogInfo('Het invoeren van een nieuw component in de tabel LEVEL_' + IntToStr(NewItems[i].Level) +' is mislukt.');
            Frm_Main.Logging.WriteToLogError('Melding:');
            Frm_Main.Logging.WriteToLogError(E.Message);
            messageDlg('Fout.', 'Het opslaan van "' + NewItems[i].Name + '" is mislukt.', mtError, [mbOK],0);
          end;
      end;
    end;
  end;
end;

procedure TAppDbMaintainItems.InsertRelation(NewItems: AllItemsObjectData);
var
  i : Integer;
  Sqltext : String;
begin
  for i := 0 to Length(NewItems) -1 do begin
    if NewItems[i].Level > 1 then begin
      if NewItems[i].Parent_guid[0] <> '' then  begin  // new rel_item always has 1 parent_guid
        Sqltext := 'Insert into ' + REL_ITEMS + '(GUID, GUID_LEVEL_A, GUID_LEVEL_B) ';
        Sqltext += 'values (:GUID, :GUID_LEVEL_A, :GUID_LEVEL_B)';

        try
          if Frm_Main.DebugMode then Frm_Main.Logging.WriteToLogDebug('Toevoegen nieuwe realatie naar item.');

          With DataModule1 do begin
            SQLQuery.Close;
            SQLite3Connection.Close();
            SQLite3Connection.DatabaseName := dbFile;

            SQLQuery.SQL.Text := SqlText;

            SQLQuery.Params.ParamByName('GUID').AsString := TGUID.NewGuid.ToString();
            SQLQuery.Params.ParamByName('GUID_LEVEL_A').AsString := NewItems[i].Parent_guid[0];
            SQLQuery.Params.ParamByName('GUID_LEVEL_B').AsString := NewItems[i].Child_guid;

            SQLite3Connection.Open;
            SQLTransaction.Active:=True;

            SQLQuery.ExecSQL;

            SQLTransaction.Commit;
            SQLite3Connection.Close();
            if Frm_Main.DebugMode then Frm_Main.Logging.WriteToLogDebug('Relatie naar item is toegevoegd.');
          end;
        except
          on E: EDatabaseError do
            begin
              Frm_Main.Logging.WriteToLogInfo('Het invoeren van een nieuwe relatie in de tabel ' + REL_ITEMS +' is mislukt.');
              Frm_Main.Logging.WriteToLogError('Melding:');
              Frm_Main.Logging.WriteToLogError(E.Message);
              messageDlg('Fout.', 'Het invoeren van een relatie is mislukt.', mtError, [mbOK],0);
            end;
        end;
      end;
    end;
  end;
end;

procedure TAppDbMaintainItems.UpdateRelation(NewItems: AllItemsObjectData);
var
  i : Integer;
  Sqltext : String;
begin
  Sqltext := 'update ' + REL_ITEMS;
  Sqltext += ' set GUID_LEVEL_B = :NEW_GUID_B';
  Sqltext += ' where GUID_LEVEL_B = :OLD_GUID_B';

  try
    With DataModule1 do begin
      for i := 0 to Length(NewItems[0].Org_Parent_guid) -1 do begin

        SQLQuery.Close;
        SQLite3Connection.Close();
        SQLite3Connection.DatabaseName := dbFile;

        SQLQuery.SQL.Text := SqlText;

        SQLQuery.Params.ParamByName('NEW_GUID_B').AsString := NewItems[0].Child_guid;
        SQLQuery.Params.ParamByName('OLD_GUID_B').AsString := NewItems[0].Action;

        SQLite3Connection.Open;
        SQLTransaction.Active:=True;

        SQLQuery.ExecSQL;

        SQLTransaction.Commit;
        SQLite3Connection.Close();

      end;
    end;
  except
    on E: EDatabaseError do
      begin
        Frm_Main.Logging.WriteToLogInfo('Het actualiseren van de relatie tabel is mislukt.');
        Frm_Main.Logging.WriteToLogError('Melding:');
        Frm_Main.Logging.WriteToLogError(E.Message);
        messageDlg('Fout.', 'Het actualiseren van de relatie tabel is mislukt.', mtError, [mbOK],0);
      end;
  end;
end;

function TAppDbMaintainItems.InsertModifiedRelation(ptr : PtrItemObject) : Boolean;
var
  i : Integer;
  Sqltext : String;
begin
  if p = nil then begin
    Result := False;
    exit;
  end;

  Sqltext := 'Select GUID, GUID_LEVEL_A, GUID_LEVEL_B from ' + REL_ITEMS;

  try
    With DataModule1 do begin
      SQLQuery.Close;
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;
      SQLite3Connection.Open;

      SQLQuery.PacketRecords := -1;
      SQLQuery.SQL.Text := SqlText;

      SQLQuery.Open;

      SQLQuery.First;
      while not SQLQuery.Eof do begin
        for i := 0 to Length(ptr^.Parent_guid) -1 do begin
          if ptr^.Parent_guid[i] = SQLQuery.FieldByName('GUID_LEVEL_A').AsString then begin
            SQLQuery.next;
          end
          else begin
            Setlength(AllItems, 1);
            AllItems[0].Guid := TGUID.NewGuid.ToString();
            SetLength(AllItems[0].Parent_guid,1);
            AllItems[0].Parent_guid[0] := ptr^.Parent_guid[i];
            AllItems[0].Child_guid := ptr^.Child_guid;
            AllItems[0].Level := ptr^.Level;
            AllItems[0].Org_Parent_guid := ptr^.Org_Parent_guid;
            AllItems[0].Action := ptr^.Action;
            SQLQuery.Last;
          end;
        end;
        SQLQuery.next;
      end;

      SQLite3Connection.Close();
      InsertRelation(AllItems); // Insert the new relatation record
      UpdateRelation(AllItems); // update existing relation(s)
    end;
  except
    on E: EDatabaseError do
      begin
        Frm_Main.Logging.WriteToLogInfo('Het aanpassen van de relatie tabel is mislukt.');
        Frm_Main.Logging.WriteToLogError('Melding:');
        Frm_Main.Logging.WriteToLogError(E.Message);
        messageDlg('Fout.', 'Het aanpassen van de relatie tabel is mislukt.', mtError, [mbOK],0);
      end;
  end;
end;

procedure TAppDbMaintainItems.UpdateItem(NewItems: AllItemsObjectData);
var
  SqlText : String;
begin
  SqlText := 'update '+ ITEMS;
  SqlText += ' set NAME = :NAME';
  SqlText += ' where GUID = :GUID';
  SqlText += ' and LEVEL = :LEVEL';

  try
    if Frm_Main.DebugMode then Frm_Main.Logging.WriteToLogDebug('Naam bestaand item wordt aangepast.');

    With DataModule1 do begin
      SQLQuery.Close;
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;

      SQLQuery.SQL.Text := SqlText;

      SQLQuery.Params.ParamByName('GUID').AsString := NewItems[0].Guid;
      SQLQuery.Params.ParamByName('NAME').AsString := NewItems[0].Name;
      SQLQuery.Params.ParamByName('LEVEL').AsInteger := NewItems[0].Level;

      SQLite3Connection.Open;
      SQLTransaction.Active:=True;

      SQLQuery.ExecSQL;

      SQLTransaction.Commit;
      SQLite3Connection.Close();
      if Frm_Main.DebugMode then Frm_Main.Logging.WriteToLogDebug('Item is hernoemd.');
    end;
  except
    on E: EDatabaseError do
      begin
        Frm_Main.Logging.WriteToLogInfo('Het hernoemen van een bestaand item is mislukt.');
        Frm_Main.Logging.WriteToLogError('Melding:');
        Frm_Main.Logging.WriteToLogError(E.Message);
        messageDlg('Fout.', 'Het hernoemen van een bestaand item is mislukt.', mtError, [mbOK],0);
      end;
  end;
end;

procedure TAppDbMaintainItems.GetAllItems(aListBox: TListBox;
  level: Byte);
begin
  Screen.Cursor := crHourGlass;

  ReadLevel(level);
  RelateItem;

  curListBox := aListBox;
  PopulateListbox;

  Screen.Cursor := crDefault;
end;

procedure TAppDbMaintainItems.ReadLevel(level: Byte);
var
  SqlText : String;
begin
  SqlText := 'select ID, GUID, LEVEL, NAME ';
  SqlText += 'from '+ ITEMS;
  if level > 0 then begin
    SqlText += ' where LEVEL = :LEVEL';
  end;

  With DataModule1 do begin
    try
      if Frm_Main.DebugMode then Frm_Main.Logging.WriteToLogDebug('Start ReadLevel(level : ' + IntToStr(level));
      SQLQuery.Close;
      SQLite3Connection.Close();

      SQLite3Connection.DatabaseName := dbFile;
      SQLite3Connection.Open;

      SQLQuery.PacketRecords := -1;
      SQLQuery.SQL.Text := SqlText;

      if level > 0 then begin
        SQLQuery.Params.ParamByName('LEVEL').AsInteger := level;
      end;

      SQLQuery.Open;

      if SQLQuery.RecordCount > 0 then begin
        SetLength(AllItems, SQLQuery.RecordCount + Length(AllItems));
      end;

      SQLQuery.First;
      while not SQLQuery.Eof do begin
        AllItems[arrayCounter].Id_table := SQLQuery.FieldByName('ID').AsInteger;
        AllItems[arrayCounter].Guid := SQLQuery.FieldByName('GUID').AsString;
        AllItems[arrayCounter].Name := SQLQuery.FieldByName('NAME').AsString;
        AllItems[arrayCounter].Level := SQLQuery.FieldByName('LEVEL').AsInteger;
        AllItems[arrayCounter].Child_guid := AllItems[arrayCounter].Guid;

        SQLQuery.next;
        Inc(arrayCounter);
      end;

      SQLQuery.Close;
      SQLite3Connection.Close();
    except
      on E : Exception do begin
        Frm_Main.Logging.WriteToLogError('Fout bij het lezen van de tabel ' + ITEMS + '.');
        Frm_Main.Logging.WriteToLogError('Melding:');
        Frm_Main.Logging.WriteToLogError(E.Message);

        messageDlg('Fout.', 'Fout bij het lezen van de onderdelen.', mtError, [mbOK],0);
      end;
    end;
  end;
end;

procedure TAppDbMaintainItems.RelateItem;
var
  SqlText : String;
  i, j, k : Integer;
begin
  SqlText := 'select GUID_LEVEL_A, GUID_LEVEL_B from ' + REL_ITEMS;

  With DataModule1 do begin
    try
      if Frm_Main.DebugMode then Frm_Main.Logging.WriteToLogDebug('Relatie tussen de items leggen. (RelateItem).');
      SQLQuery.Close;
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;
      SQLite3Connection.Open;

      SQLQuery.PacketRecords := -1;
      SQLQuery.SQL.Text := SqlText;

      SQLQuery.Open;

      i := 0;
      SQLQuery.First;
      while not SQLQuery.Eof do begin
        for i := 0 to Length(AllItems) - 1 do begin

          if AllItems[i].Guid = SQLQuery.FieldByName('GUID_LEVEL_A').AsString then begin

            for j := 0 to Length(AllItems) - 1 do begin
              if AllItems[j].Guid = SQLQuery.FieldByName('GUID_LEVEL_B').AsString then begin
                SetLength(AllItems[j].Parent_guid, length(AllItems[j].Parent_guid) + 1);

                for k := 0 to Length(AllItems[j].Parent_guid) - 1 do begin
                  if AllItems[j].Parent_guid[k] = '' then begin
                    AllItems[j].Parent_guid[k] := SQLQuery.FieldByName('GUID_LEVEL_A').AsString;
                  end;
                end;

              end;
            end;
          end;
        end;
        SQLQuery.next;
      end;

      SQLQuery.Close;
      SQLite3Connection.Close();
    except
      on E : Exception do begin
        Frm_Main.Logging.WriteToLogError('Fout bij het lezen van de tabel ' + ITEMS + '.');
        Frm_Main.Logging.WriteToLogError('Melding:');
        Frm_Main.Logging.WriteToLogError(E.Message);

        messageDlg('Fout.', 'Fout bij het lezen van de onderdelen.', mtError, [mbOK],0);
      end;
    end;
  end;
end;

procedure TAppDbMaintainItems.PopulateListbox;
var
  i : Integer;
  pItem : PtrItemObject;
  currLevel : Integer;
begin
  if length(AllItems) > 0 then begin
    Screen.Cursor := crHourGlass;

    if Frm_Main.DebugMode then Frm_Main.Logging.WriteToLogDebug('Gegevens in de listboxen zetten. (PopulateListbox).');
    // clear the listboxes pointer objects.
    curListBox.Items.BeginUpdate;
    if curListBox.Items.Count > 0 then begin
      for i := 0 to curListBox.Items.Count -1 do begin
        Dispose(PtrItemObject(curListBox.Items.Objects[I]));
      end;
      curListBox.Items.Clear;
    end;

    currLevel := StrToInt(GetNumbers(curListBox.Name));

    for i := 0 to length(AllItems) -1 do begin
      if currLevel = AllItems[i].Level then begin
        new(pItem);
        pItem^.Name := AllItems[i].Name;
        pItem^.Id_table := AllItems[i].Id_table;
        pItem^.Guid := AllItems[i].Guid;
        pItem^.Level:= AllItems[i].Level;
        pItem^.Parent_guid := AllItems[i].Parent_guid;
        pItem^.Child_guid :=  AllItems[i].Child_guid;
        curListBox.AddItem(AllItems[i].Name, TObject(pItem));
      end;
    end;
    curListBox.Items.EndUpdate;
    Screen.Cursor := crDefault;
  end;
end;

function TAppDbMaintainItems.DoesItemNameExists(aName: String; aLevel : Integer): Boolean;
var
  SqlText : String;
begin
  SqlText := 'select NAME ';
  SqlText += 'from '+ ITEMS;
  SqlText += ' where NAME = :NAME';
  SqlText += ' and LEVEL = :LEVEL';

  With DataModule1 do begin
    try
      if Frm_Main.DebugMode then Frm_Main.Logging.WriteToLogDebug('Start DoesItemExists.');
      SQLQuery.Close;
      SQLite3Connection.Close();

      SQLite3Connection.DatabaseName := dbFile;
      SQLite3Connection.Open;

      SQLQuery.PacketRecords := -1;
      SQLQuery.SQL.Text := SqlText;

      SQLQuery.Params.ParamByName('NAME').AsString := aName;
      SQLQuery.Params.ParamByName('LEVEL').AsInteger := aLevel;

      SQLQuery.Open;

      if SQLQuery.RecordCount > 0 then begin
        Result := True;
      end
      else begin
        Result := False;
      end;

      SQLQuery.Close;
      SQLite3Connection.Close();
    except
      on E : Exception do begin
        Frm_Main.Logging.WriteToLogError('Fout bij het opvragen van alle itemnamen. (tabel :' + ITEMS + ').');
        Frm_Main.Logging.WriteToLogError('Melding:');
        Frm_Main.Logging.WriteToLogError(E.Message);

        messageDlg('Fout.', 'Fout bij het lezen van de onderdelen.', mtError, [mbOK],0);
      end;
    end;
  end;
end;

procedure TAppDbMaintainItems.DeleteItem(Guid: String; level : Integer);
begin
  if DeleteItemRel(Guid, level) then
    DeleteItemSelf(Guid)
  else
    messageDlg('Fout.', 'Item is niet verwijderd.', mtError, [mbOK],0);
end;

procedure TAppDbMaintainItems.DeleteItemRel(Guid, parentGuid : String; level : Integer);
var
  SqlText : String;
begin
  SqlText := 'delete from ' + REL_ITEMS;
  if level > 1 then begin
    SqlText += ' where GUID_LEVEL_B = :GUID';
    SqlText += ' and GUID_LEVEL_A = :PARENT_GUID';
  end
  else begin
    SqlText += ' where GUID_LEVEL_A = :GUID';
  end;

  With DataModule1 do begin
    try
      if Frm_Main.DebugMode then Frm_Main.Logging.WriteToLogDebug('Start DeleteItemRel.');
      SQLQuery.Close;
      SQLite3Connection.Close();

      SQLite3Connection.DatabaseName := dbFile;
      SQLite3Connection.Open;

      SQLQuery.SQL.Text := SqlText;

      SQLQuery.Params.ParamByName('GUID').AsString := Guid;
      SQLQuery.Params.ParamByName('PARENT_GUID').AsString := parentGuid;

      SQLite3Connection.Open;
      SQLTransaction.Active:=True;

      SQLQuery.ExecSQL;

      SQLTransaction.Commit;
      SQLite3Connection.Close();

      if Frm_Main.DebugMode then Frm_Main.Logging.WriteToLogDebug('Relatie naar item is verwijderd.');

      ReadLevel(level);
      RelateItem;
      curListBox := curListBox;
      PopulateListbox;
    except
      on E : Exception do begin
        Frm_Main.Logging.WriteToLogError('Fout bij het verwijderen van een relatie naar een item.');
        Frm_Main.Logging.WriteToLogError('Melding:');
        Frm_Main.Logging.WriteToLogError(E.Message);

        messageDlg('Fout.', 'Fout bij het verwijderen van een relatie naar item.', mtError, [mbOK],0);
      end;
    end;
  end;
end;

function TAppDbMaintainItems.DeleteItemRel(Guid: String; level : Integer) : Boolean;
var
  SqlText : String;
begin
  SqlText := 'delete from ' + REL_ITEMS;
  if level > 1 then begin
    SqlText += ' where GUID_LEVEL_B = :GUID';
  end
  else begin
    SqlText += ' where GUID_LEVEL_A = :GUID';
  end;

  With DataModule1 do begin
    try
      if Frm_Main.DebugMode then Frm_Main.Logging.WriteToLogDebug('Start DeleteItemRel.');
      SQLQuery.Close;
      SQLite3Connection.Close();

      SQLite3Connection.DatabaseName := dbFile;
      SQLite3Connection.Open;

      SQLQuery.SQL.Text := SqlText;

      SQLQuery.Params.ParamByName('GUID').AsString := Guid;

      SQLite3Connection.Open;
      SQLTransaction.Active:=True;

      SQLQuery.ExecSQL;

      SQLTransaction.Commit;
      SQLite3Connection.Close();

      if Frm_Main.DebugMode then Frm_Main.Logging.WriteToLogDebug('Relatie naar item is verwijderd.');

      result := True;
    except
      on E : Exception do begin
        Frm_Main.Logging.WriteToLogError('Fout bij het verwijderen van een relatie naar een item.');
        Frm_Main.Logging.WriteToLogError('Melding:');
        Frm_Main.Logging.WriteToLogError(E.Message);

        messageDlg('Fout.', 'Fout bij het verwijderen van een relatie naar item.', mtError, [mbOK],0);
        Result := False;
      end;
    end;
  end;
end;

procedure TAppDbMaintainItems.DeleteItemSelf(Guid: String);
var
  SqlText : String;
begin
  SqlText := 'delete from ' + ITEMS;
  SqlText += ' where GUID = :GUID';

  With DataModule1 do begin
    try
      if Frm_Main.DebugMode then Frm_Main.Logging.WriteToLogDebug('Start DeleteItemSelf.');
      SQLQuery.Close;
      SQLite3Connection.Close();

      SQLite3Connection.DatabaseName := dbFile;
      SQLite3Connection.Open;

      SQLQuery.SQL.Text := SqlText;

      SQLQuery.Params.ParamByName('GUID').AsString := Guid;

      SQLite3Connection.Open;
      SQLTransaction.Active:=True;

      SQLQuery.ExecSQL;

      SQLTransaction.Commit;
      SQLite3Connection.Close();

      if Frm_Main.DebugMode then Frm_Main.Logging.WriteToLogDebug('Item is verwijderd.');
    except
      on E : Exception do begin
        Frm_Main.Logging.WriteToLogError('Fout bij het verwijderen van een item.');
        Frm_Main.Logging.WriteToLogError('Melding:');
        Frm_Main.Logging.WriteToLogError(E.Message);

        messageDlg('Fout.', 'Fout bij het verwijderen van een item.', mtError, [mbOK],0);
      end;
    end;
  end;
end;


end.


