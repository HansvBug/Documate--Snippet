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
    public
      AllNewItems : AllItemObjectData; // when you add multiple new items

      constructor Create; overload;
      destructor  Destroy; override;
      procedure InsertNewItem(NewItems: AllItemObjectData);
      procedure InsertRelation(NewItems: AllItemObjectData);
      procedure GetAllItems(aListBox : TListBox; level : Byte);
      Procedure ReadLevel(var AllItems : AllItemObjectData; level: Byte);
      function RelateItem(Guid : String) : String;
      procedure PopulateListbox;
      procedure AddNewItemToList(NewItem : String);
  end;

var
  //NewItem : String;  // hold a new item

  AllItems : AllItemObjectData;
  curListBox : TListBox;


implementation

uses Form_Main, DataModule, Db;
{ TAppDbMaintainComponents }

constructor TAppDbMaintainComponents.Create;
begin
  inherited;
  AllNewItems := nil;
end;

destructor TAppDbMaintainComponents.Destroy;
begin
  inherited Destroy;
end;

procedure TAppDbMaintainComponents.InsertNewItem(NewItems: AllItemObjectData);
var
  SqlText : String;
  i : Integer;
begin
  for i := 0 to Length(NewItems) -1 do begin
    if NewItems[i].Guid <> '' then begin
      SqlText := 'insert into ' + ITEMS + '(GUID, LEVEL, NAME, DATE_CREATED, CREATED_BY) ';
      SqlText += 'values (:GUID, :LEVEL, :NAME, :DATE_CREATED, :CREATED_BY);';

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

procedure TAppDbMaintainComponents.InsertRelation(NewItems: AllItemObjectData);
var
  i : Integer;
  Sqltext : String;
begin
  for i := 0 to Length(NewItems) -1 do begin
    if NewItems[i].Level > 1 then begin
      if NewItems[i].Parent_guid <> '' then begin
        Sqltext := 'Insert into ' + REL_ITEMS + '(GUID, GUID_LEVEL_A, GUID_LEVEL_B) ';
        Sqltext += 'values (:GUID, :GUID_LEVEL_A, :GUID_LEVEL_B)';

        try
          With DataModule1 do begin
            SQLQuery.Close;
            SQLite3Connection.Close();
            SQLite3Connection.DatabaseName := dbFile;

            SQLQuery.SQL.Text := SqlText;

            SQLQuery.Params.ParamByName('GUID').AsString := TGUID.NewGuid.ToString();
            SQLQuery.Params.ParamByName('GUID_LEVEL_A').AsString := NewItems[i].Parent_guid;
            SQLQuery.Params.ParamByName('GUID_LEVEL_B').AsString := NewItems[i].Child_guid;


            SQLite3Connection.Open;
            SQLTransaction.Active:=True;

            SQLQuery.ExecSQL;

            SQLTransaction.Commit;
            SQLite3Connection.Close();
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

  ReadLevel(AllItems, level);

  curListBox := aListBox;
  PopulateListbox;

  Screen.Cursor := crDefault;
end;

procedure TAppDbMaintainComponents.ReadLevel(var AllItems: AllItemObjectData;
  level: Byte);
var
  SqlText : String;
  i : Integer;
begin
  SqlText := 'select ID, GUID, LEVEL, NAME ';
  SqlText += 'from '+ ITEMS;
  SqlText += ' where LEVEL = :LEVEL';

  With DataModule1 do begin
    try
      SQLQuery.Close;
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;
      SQLite3Connection.Open;

      SQLQuery.PacketRecords := -1;
      SQLQuery.SQL.Text := SqlText;

      SQLQuery.Params.ParamByName('LEVEL').AsInteger := level;

      SQLQuery.Open;

      i := 0;
      SetLength(AllItems, SQLQuery.RecordCount);

      SQLQuery.First;
      while not SQLQuery.Eof do begin
        AllItems[i].Id_array := i;  // let op dit is de array id en niet de database is
        AllItems[i].Id_table := SQLQuery.FieldByName('ID').AsInteger;
        AllItems[i].Guid := SQLQuery.FieldByName('GUID').AsString;
        AllItems[i].Name := SQLQuery.FieldByName('NAME').AsString;
        AllItems[i].Level := SQLQuery.FieldByName('LEVEL').AsInteger;
        //AllItems[i].Child_guid := AllItems[i].Guid;
        AllItems[i].Parent_guid := RelateItem(AllItems[i].Guid);

        SQLQuery.next;
        i +=1;
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

function TAppDbMaintainComponents.RelateItem(Guid : String) : String;
var
  SqlText, Return : String;
begin
  SqlText := 'select GUID_LEVEL_A from ' + REL_ITEMS;
  SqlText += ' where GUID_LEVEL_B = :GUID';
  With DataModule1 do begin
    try
      SQLQueryRelItems.Close;
      SQLite3ConnectionRelItems.Close();
      SQLite3ConnectionRelItems.DatabaseName := dbFile;
      SQLite3ConnectionRelItems.Open;
      SQLQueryRelItems.PacketRecords := -1;
      SQLQueryRelItems.SQL.Text := SqlText;
      SQLQueryRelItems.Params.ParamByName('GUID').AsString := Guid;

      SQLQueryRelItems.Open;
      SQLQueryRelItems.First;
      while not SQLQueryRelItems.Eof do begin
        Return :=  SQLQueryRelItems.FieldByName('GUID_LEVEL_A').AsString;
        SQLQueryRelItems.next;
      end;
      SQLQueryRelItems.Close;
      SQLite3ConnectionRelItems.Close();
      result := return;
    except
      on E : Exception do begin
        Frm_Main.Logging.WriteToLogError('Fout bij het lezen van de tabel ' + REL_ITEMS + '.');
        Frm_Main.Logging.WriteToLogError('Melding:');
        Frm_Main.Logging.WriteToLogError(E.Message);

        messageDlg('Fout.', 'Fout bij het lezen van de relaties tussen de onderdelen.', mtError, [mbOK],0);
      end;
    end;
  end;
end;

procedure TAppDbMaintainComponents.PopulateListbox;
var
  i : Integer;
  pItem : PtrItemObject;
begin
  if length(AllItems) > 0 then begin
    Screen.Cursor := crHourGlass;

    // clear the listboxes pointer objects.
    if curListBox.Items.Count > 0 then begin
      for i := 0 to curListBox.Items.Count -1 do begin
        Dispose(PtrItemObject(curListBox.Items.Objects[I]));
      end;
      curListBox.Items.Clear;
    end;

    for i := 0 to length(AllItems) -1 do begin
      new(pItem);
      pItem^.Name := AllItems[i].Name;
      pItem^.Id_table := AllItems[i].Id_table;
      pItem^.Guid := AllItems[i].Guid;
      pItem^.Level:= AllItems[i].Level;
      pItem^.Parent_guid := AllItems[i].Parent_guid;
      curListBox.AddItem(AllItems[i].Name, TObject(pItem));
    end;
    Screen.Cursor := crDefault;
  end;
end;

procedure TAppDbMaintainComponents.AddNewItemToList(NewItem: String);
var
  curLength : Integer;
begin
  curLength := length(AllNewItems);
  Setlength(AllNewItems, curlength + 1);
  AllNewItems[curLength].Name := NewItem;
end;

end.

