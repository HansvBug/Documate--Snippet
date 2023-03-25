unit AppDbMaintainComponents;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, ComCtrls, typinfo,
  AppDb, AppDbItems;

type

  { TAppDbMaintainComponents }

  TAppDbMaintainComponents = class(TAppDatabase)
    private
      arrayCounter : Integer;

      function GetNumbers(const Value: string): String;

    public
      AllItems : AllItemsObjectData;
      curListBox : TListBox;

      constructor Create; overload;
      destructor  Destroy; override;
      procedure InsertNewItem(NewItems: AllItemsObjectData);
      procedure InsertRelation(NewItems: AllItemsObjectData);
      procedure GetAllItems(aListBox : TListBox; level : Byte);
      Procedure ReadLevel(level: Byte);
      Procedure RelateItem;
      procedure PopulateListbox;
  end;


implementation

uses Form_Main, DataModule, Db;
{ TAppDbMaintainComponents }

function TAppDbMaintainComponents.GetNumbers(const Value: string): String;
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

constructor TAppDbMaintainComponents.Create;
begin
  inherited;
  AllItems := nil;
  arrayCounter := 0;
end;

destructor TAppDbMaintainComponents.Destroy;
begin
  inherited Destroy;
end;

procedure TAppDbMaintainComponents.InsertNewItem(NewItems: AllItemsObjectData);
var
  SqlText : String;
  i : Integer;
begin
  for i := 0 to Length(NewItems) -1 do begin
    if NewItems[i].Guid <> '' then begin
      if Frm_Main.FDebug then Frm_Main.Logging.WriteToLogDebug('Toevoegen nieuw item.');

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

procedure TAppDbMaintainComponents.InsertRelation(NewItems: AllItemsObjectData);
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
          if Frm_Main.FDebug then Frm_Main.Logging.WriteToLogDebug('Toevoegen nieuwe realatie naar item.');

          With DataModule1 do begin
            SQLQuery.Close;
            SQLite3Connection.Close();
            SQLite3Connection.DatabaseName := dbFile;

            SQLQuery.SQL.Text := SqlText;

            SQLQuery.Params.ParamByName('GUID').AsString := TGUID.NewGuid.ToString();
            SQLQuery.Params.ParamByName('GUID_LEVEL_A').AsString := NewItems[i].Parent_guid[0];// MOET ANDERS
            SQLQuery.Params.ParamByName('GUID_LEVEL_B').AsString := NewItems[i].Child_guid;

            SQLite3Connection.Open;
            SQLTransaction.Active:=True;

            SQLQuery.ExecSQL;

            SQLTransaction.Commit;
            SQLite3Connection.Close();
            if Frm_Main.FDebug then Frm_Main.Logging.WriteToLogDebug('Relatie naar item is toegevoegd.');
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

procedure TAppDbMaintainComponents.GetAllItems(aListBox: TListBox;
  level: Byte);
begin
  Screen.Cursor := crHourGlass;

  ReadLevel(level);
  RelateItem;

  curListBox := aListBox;
  PopulateListbox;

  Screen.Cursor := crDefault;
end;

procedure TAppDbMaintainComponents.ReadLevel(level: Byte);
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
      if Frm_Main.FDebug then Frm_Main.Logging.WriteToLogDebug('Start ReadLevel(level : ' + IntToStr(level));
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

procedure TAppDbMaintainComponents.RelateItem;
var
  SqlText : String;
  i, j, k : Integer;
begin
  SqlText := 'select GUID_LEVEL_A, GUID_LEVEL_B from ' + REL_ITEMS;

  With DataModule1 do begin
    try
      if Frm_Main.FDebug then Frm_Main.Logging.WriteToLogDebug('Relatie tussen de items leggen. (RelateItem).');
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

procedure TAppDbMaintainComponents.PopulateListbox;
var
  i : Integer;
  pItem : PtrItemObject;
  currLevel : Integer;
begin
  if length(AllItems) > 0 then begin
    Screen.Cursor := crHourGlass;

    if Frm_Main.FDebug then Frm_Main.Logging.WriteToLogDebug('Gegevens in de listboxen zetten. (PopulateListbox).');
    // clear the listboxes pointer objects.
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
    Screen.Cursor := crDefault;
  end;
end;


end.


