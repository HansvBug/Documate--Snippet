unit Form_Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ComCtrls,
  StdCtrls, ExtCtrls, PairSplitter,
  AppDbItems, Settings, Settingsmanager, Logging, Visual, Form_Configure,
  AppDbMaintain;

type

  { TFrm_main }

  TFrm_main = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit_: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ListBox1: TListBox;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItemProgramCloseDb: TMenuItem;
    MenuItemProgramOpen: TMenuItem;
    MenuItemOptionsConfigure: TMenuItem;
    PairSplitter2: TPairSplitter;
    PairSplitterSide3: TPairSplitterSide;
    PairSplitterSide4: TPairSplitterSide;
    ScrollBoxColumns: TScrollBox;
    Separator1: TMenuItem;
    MenuItemProgramNew: TMenuItem;
    MenuItemProgramClose: TMenuItem;
    MenuItemProgram: TMenuItem;
    PageControl1: TPageControl;
    PairSplitter1: TPairSplitter;
    PairSplitterSide1: TPairSplitterSide;
    PairSplitterSide2: TPairSplitterSide;
    PanelData_: TPanel;
    PanelSearch: TPanel;
    PanelBody: TPanel;
    PanelBodyVb: TPanel;
    PanelHeader: TPanel;
    Splitter_: TSplitter;
    Splitter__: TSplitter;
    StatusBarFrmMain: TStatusBar;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MenuItemOptionsConfigureClick(Sender: TObject);
    procedure MenuItemProgramCloseClick(Sender: TObject);
    procedure MenuItemProgramCloseDbClick(Sender: TObject);
    procedure MenuItemProgramNewClick(Sender: TObject);
    procedure MenuItemProgramOpenClick(Sender: TObject);



  private
    FCurrListBox : TListBox;
    FCurrGuid : String;  // The guid of the selected listbox item
    FColumns : Byte;
    FDisableAppItems, FDbDescriptionShort : String;
    FDbFile : String;
    FCanContinue : Boolean;

    procedure SetStatusbarText(aText : String);
    procedure SetDbNameInStatusbar(DbName : String);
    procedure CheckAppEnvironment;
    procedure ReadSettings;
    procedure SaveSettings;
    procedure StartLogging;
    procedure FormInitialize;
    procedure RestoreFormState;
    procedure CreateOwnComponents;
    procedure DisableAllButtons;
    procedure EnableButtons(BtnNumber : Integer);
    function GetNumbers(const Value: string): string;
    function GetTheRightListBox(identifier: String) : TListBox;
    function GetListBoxItems(identifier: String) : AllItemObjectData;
    function SelectDbFilePath : Boolean;
    procedure GetAllItemsForListbox(aListBox : TListBox; level : Byte);
    procedure ColorRelatedItems(Level, ItemIdx : Integer);
    PROCEDURE RemoveListBoxObjects;

  public
    Logging : TLog_File;
    Visual  : TVisual;

    procedure ButtonNewOnClick(Sender: TObject);
    procedure ListBoxOnClick(Sender: TObject);

    property NumberOfColumns : Byte read FColumns write FColumns;
    property DbDescriptionShort : String read FDbDescriptionShort write FDbDescriptionShort;
    property CanContinue : Boolean read FCanContinue write FCanContinue;
    property DisableAppItems : string read FDisableAppItems write FDisableAppItems;
  end;

var
  Frm_main: TFrm_main;
  SetMan  : TSettingsManager; // of verplaatsen naar public?
  //ApplicationArguments : array of string;

implementation

uses ApplicationEnvironment, AppDbCreate, form_new_db_config, BuildComponents, Form_Maintain,
  AppDbMaintainComponents;
{$R *.lfm}

{ TFrm_main }

procedure TFrm_main.MenuItemProgramCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrm_main.MenuItemProgramCloseDbClick(Sender: TObject);
var
  newComponent : TBuildComponent;
begin
  newComponent := TBuildComponent.Create(Frm_Main);
  newComponent.RemoveOwnComponents;
  newComponent.Free;
  FDbFile := '';
  SetDbNameInStatusbar('');
  MenuItemProgramCloseDb.Enabled := False;
end;

procedure TFrm_main.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  SaveSettings;
  CloseAction := caFree;
end;

procedure TFrm_main.Button2Click(Sender: TObject);
begin
  ListBox1.ClearSelection;
  ListBox1.Selected[0] := True;
end;

procedure TFrm_main.FormCreate(Sender: TObject);
begin
  Caption := Settings.ApplicationName;
  CheckAppEnvironment;
  ReadSettings;
  StartLogging;
  FormInitialize;
end;

procedure TFrm_main.FormDestroy(Sender: TObject);
begin
  // clear the listboxes pointer objects...
  RemoveListBoxObjects;

  Visual.Free;
  Logging.StopLogging;
  Logging.Free;
  SetMan.Free;
end;

procedure TFrm_main.FormShow(Sender: TObject);
begin
  RestoreFormState();
end;

procedure TFrm_main.MenuItemOptionsConfigureClick(Sender: TObject);
var
  frm : TFrm_Configure;
  ActivateLogging : Boolean;
begin
  ActivateLogging := SetMan.ActivateLogging;
  SetMan.SaveSettings;
  frm := TFrm_Configure.Create(Self);

  try
    frm.ShowModal;
  finally
    frm.Free;
    ReadSettings();
    if (SetMan.ActivateLogging) and not ActivateLogging then
      begin
        Logging.Free;
        StartLogging();
      end
    end;
end;

procedure TFrm_main.MenuItemProgramNewClick(Sender: TObject);
var
  frm : TFrm_new_database;
  Appdatabase : TCreateAppdatabase;
begin
  if SelectDbFilePath then begin
    frm := TFrm_new_database.Create(self);
    try
      frm.Caption := 'Database bestand: ' + ExtractFileName(FDbFile);
      frm.ShowModal;
    finally
      frm.Free;
    end;

    if CanContinue then begin
      Appdatabase  := TCreateAppdatabase.Create(FDbFile);
      try
        if not Appdatabase.CreateNewDatabase() then begin
          messageDlg('Fout.', 'Het aanmaken van het de database (tabellen) is mislukt.', mtInformation, [mbOK],0);
          Frm_Main.Logging.WriteToLogError('Het aanmaken van de database (tabellen) is mislukt.');
          Frm_main.DisableAppItems := 'Volledig uit';  { #todo : Const voor maken }
        end
        else begin
          Appdatabase.InsertMeta('Columns', IntToStr(FColumns));
          Appdatabase.InsertMeta('Description', DbDescriptionShort);
          Appdatabase.CreateAllTables;

          SetDbNameInStatusbar(ExtractFileName(FDbFile));
          MenuItemProgramCloseDb.Enabled := True;
        end;
      finally
        Appdatabase.Free;
        SetStatusbarText('');
      end;
    end
    else begin
      DisableAppItems := 'Volledig uit';
    end;
  end;

  if  DisableAppItems <> 'Volledig uit' then begin
    CreateOwnComponents;
  end;
end;

procedure TFrm_main.MenuItemProgramOpenClick(Sender: TObject);
var
  openDialog : TOpenDialog;
  Levels : TAppDbMaintain;
  i : Integer;
  _listBox : TListBox;
begin
  Screen.Cursor := crHourGlass;
  PageControl1.ActivePage := TabSheet1;
  openDialog := TOpenDialog.Create(self);
  openDialog.InitialDir := GetCurrentDir + Settings.DatabaseFolder;
  openDialog.Options := [ofFileMustExist];
  openDialog.Filter := 'Documate files|*.db';
  if openDialog.Execute then begin
    // query die aantal levels ophaalt
    Levels := TAppDbMaintain.Create;
    try
      FDbFile := openDialog.FileName;
      Levels.dbFile := FDbFile;
      NumberOfColumns := Levels.GetNumberOfColumns;

      RemoveListBoxObjects;  // when a database is open en a new is opened the listbox object data must be removed
      CreateOwnComponents;
      MenuItemProgramCloseDb.Enabled := True;
      SetDbNameInStatusbar(ExtractFileName(FDbFile));

      // Get all items for all Listboxes
      if  FColumns > 0 then begin
        for i := 1 to FColumns do begin
          _listBox := GetTheRightListBox(IntToStr(i));
          GetAllItemsForListbox(_listBox, i);
        end;
      end;

      // Select the first item in the first listbox, just select no OnClick
      ColorRelatedItems(1, 0);

    finally
      Levels.Free;
    end;
  end
  else begin
    //
  end;
  openDialog.Free;
  Screen.Cursor := crDefault;
end;

function TFrm_main.SelectDbFilePath : Boolean;
var
  saveDialog : TSaveDialog;
  Appdatabase : TCreateAppdatabase;
begin
  Screen.Cursor := crHourGlass;
  SetStatusbarText('Aanmaken leeg database bestand...');
  saveDialog := TSaveDialog.Create(self);
  saveDialog.Title := 'Opslaan nieuw database bestand';
  saveDialog.InitialDir := ExtractFilePath(Application.ExeName) +  Settings.DatabaseFolder;
  saveDialog.Filter := 'SQLite db file|*.db';
  saveDialog.DefaultExt := 'db';
  saveDialog.Options := saveDialog.Options + [ofOverwritePrompt, ofNoTestFileCreate];

  if saveDialog.Execute then begin
    Appdatabase := TCreateAppdatabase.Create;
    if not Appdatabase.IsFileInUse(saveDialog.FileName) then begin
      FDbFile := saveDialog.FileName;
      CanContinue := True;
    end
    else begin
      messageDlg('Fout.', 'Het bestand is in gebruik door een ander proces.', mtInformation, [mbOK],0);
      CanContinue := False;
    end;
    Appdatabase.Free;
  end
  else begin
    CanContinue := False;
  end;

  Screen.Cursor := crDefault;
  result := CanContinue;
end;

procedure TFrm_main.SetDbNameInStatusbar(DbName: String);
begin
  if DbName <> '' then begin
    StatusBarFrmMain.Panels.Items[1].Text := 'Database: ' + DbName + '     ';
  end
  else begin
    StatusBarFrmMain.Panels.Items[1].Text := 'Database: -     ';
  end;
end;

procedure TFrm_main.SetStatusbarText(aText: String);
begin
  if aText <> '' then begin
    StatusBarFrmMain.Panels.Items[0].Text := ' ' + aText;
  end
  else begin
    StatusBarFrmMain.Panels.Items[0].Text := '';
  end;

  Application.ProcessMessages;
end;

procedure TFrm_main.CheckAppEnvironment;
var
  CheckEnvironment : TApplicationEnvironment;
  BaseFolder : string;
begin
  BaseFolder :=  ExtractFilePath(Application.ExeName);

  if BaseFolder <> '' then begin//create the folders
    CheckEnvironment := TApplicationEnvironment.Create;
    CheckEnvironment.CreateFolder(BaseFolder, Settings.SettingsFolder);
    CheckEnvironment.CreateFolder(BaseFolder, Settings.DatabaseFolder);
    CheckEnvironment.CreateFolder(BaseFolder, Settings.LoggingFolder);
    CheckEnvironment.CreateFolder(BaseFolder, Settings.DatabaseFolder + PathDelim + Settings.BackupFolder);

    //create the settings file
    CheckEnvironment.CreateSettingsFile(BaseFolder + Settings.SettingsFolder + PathDelim);

    if CheckEnvironment.CheckDllFiles then begin
      //DisableFunctions;
    end;

    CheckEnvironment.Free;
  end;
end;

procedure TFrm_main.ReadSettings;
begin
  if assigned(SetMan) then SetMan.Free;
  SetMan := TSettingsManager.Create();
end;

procedure TFrm_main.SaveSettings;
begin
  SetMan.SaveSettings;
  SetMan.StoreFormState(self);
end;

procedure TFrm_main.StartLogging;
begin
  Logging := TLog_File.Create();
  Logging.ActivateLogging := SetMan.ActivateLogging;
  Logging.AppendLogFile := Setman.AppendLogFile;
  Logging.StartLogging;
end;

procedure TFrm_main.FormInitialize;
begin
  Visual := TVisual.Create;
  Visual.AlterSystemMenu;
  SetStatusbarText('Welkom');
  SetDbNameInStatusbar('');
  MenuItemProgramCloseDb.Enabled := False;

  // Get the command line parameters.
//  GetApplicationArguments;
//  ProcessApplicationArguments;

    // Optimize the app. database.
  if FileExists(ExtractFilePath(Application.ExeName) + Settings.DatabaseFolder + PathDelim + Settings.DatabaseName) then begin
//    CopyAppDbFile;
//    dbMaintain := TAppDbMaintain.Create;
//    dbMaintain.ResetAutoIncrementAll;
//    dbMaintain.Optimze;
//    dbMaintain.Free;
  end;

end;

procedure TFrm_main.RestoreFormState;
begin
  SetMan.RestoreFormState(self);
end;

procedure TFrm_main.CreateOwnComponents;
var
  newComponent : TBuildComponent;
begin
  Screen.Cursor := crHourGlass;
  SetStatusbarText('Voorbereiden scherm...');

  newComponent := TBuildComponent.Create(Frm_Main);
  try
    newComponent.RemoveOwnComponents;
    newComponent.NumberOfColumns := NumberOfColumns;

    newComponent.BuildBodyPanelsAndSplitters(ScrollBoxColumns); // Create "body" panels and splitters between them
    newComponent.BuildHeaderPanels;     // Create "header" panels
    newComponent.BuildSearchPanels;     // Create "search" panels
    newComponent.BuildDataPanels;       // Create "data" panels
    newComponent.BuildListBoxes;        // Create listboxes which hold the data
    newComponent.BuildEdit;             // Create the search Edit boxes
    newComponent.BuildButtons('Nieuw'); // Create the new item buttons
    DisableAllButtons;                  // Disalbe all new buttons
    EnableButtons(1);                   // Enable the first button
    SetStatusbarText('');
    Screen.Cursor := crDefault;
  finally
    newComponent.Free;
  end;
end;

procedure TFrm_main.DisableAllButtons;
var
  i : Integer;
  _button : TButton;
begin
  for i := 0 to Frm_Main.ComponentCount -1 do begin
    if Components[i] is TButton then begin
      _button :=  TButton(Components[i]);
      if Pos('ButtonNew_' , _button.Name) > 0 then begin
        _button.Enabled := False;
      end;
    end;
  end;
end;

procedure TFrm_main.EnableButtons(BtnNumber: Integer);
var
  i : Integer;
  _button : TButton;
begin
  for i := 0 to Frm_Main.ComponentCount -1 do begin
    if Components[i] is TButton then begin
      _button :=  TButton(Components[i]);
      if _button.Name = 'ButtonNew_' + IntToStr(BtnNumber)  then begin
        _button.Enabled := True;
      end
      else begin
        if not _button.Enabled then begin  // if a button already is enabled them keep it enabled
      //    _button.Enabled := False;
        end;
      end;
    end;
  end;
end;

function TFrm_main.GetNumbers(const Value: string): string;
var
  ch: char;
  Index, Count: integer;
begin
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

function TFrm_main.GetTheRightListBox(identifier: String): TListBox;
var
  i : Integer;
  _listbox : TListBox;
begin
  Result := nil;
  for i := 0 to Frm_Main.ComponentCount -1 do begin
    if Components[i] is TListBox then begin
      _listbox :=  TListBox(Components[i]);
      if _listbox.Name = 'ListBox_' + identifier  then
        begin
          Result := _listbox;
          break;
        end;
    end;
  end;
end;

function TFrm_main.GetListBoxItems(identifier: String): AllItemObjectData;
var
  itemsObjectData : AllItemObjectData = nil;
  i, level : Integer;
begin
 FCurrListBox := GetTheRightListBox(identifier);
 Level := StrToInt(GetNumbers(FCurrListBox.Name));
  SetLength(itemsObjectData, FCurrListBox.Items.Count);
  for i := 0 to FCurrListBox.Items.Count -1 do begin
    itemsObjectData[i].Name := FCurrListBox.Items[i];
    itemsObjectData[i].Level := level;
  end;

  result := itemsObjectData;
end;

procedure TFrm_main.ButtonNewOnClick(Sender: TObject);
var
  _button : TButton;
  _listbox : TListBox;
  frm : TFrm_Maintain;
  itemsNames : AllItemObjectData;
  AllNewItems : AllItemObjectData;
  Level : String;
  appDbMaintain : TAppDbMaintainComponents;
  i : Integer;
begin
  if sender is TButton then begin
    _button := TButton(sender);
    Level := GetNumbers(_button.Name);
  end
  else begin
    ShowMessage('Er gaat iets mis');
    Logging.WriteToLogError('Er is op een button geklikt maar de sender is géén button.');
  end;

  itemsNames := GetListBoxItems(Level);// create a list of existing items

  frm := TFrm_Maintain.Create(Self);
  try
    frm.Caption := _button.Name;
    frm.ComboBoxNewItem.TextHint := _button.Name; { #todo : Optie van maken. }
    frm.CurrLevel := StrToInt(Level);  // Level alvast meegeven
    frm.CurrGuid := FCurrGuid;
    frm.NewItemObjectData := itemsNames;
    frm.ShowModal;
  finally
    AllNewItems := frm.NewItemObjectData;
    frm.Free;
  end;

  if Length(AllNewItems) > 0 then begin
    // Safe new item direct...
    appDbMaintain := TAppDbMaintainComponents.Create;
    try
      AppDbMaintain.dbFile := FDbFile;

      for i := 0 to Length(AllNewItems) - 1 do begin
        AllNewItems[i].Level := StrToInt(level);
      end;
      AppDbMaintain.InsertNewItem(AllNewItems);  // Insert the new item.
      AppDbMaintain.InsertRelation(AllNewItems);  // Insert the relation
    finally
      appDbMaintain.free;
    end;

    _listbox := GetTheRightListBox(level);
    GetAllItemsForListbox(_listbox, StrToInt(level));

    // Select the last added item and trigger the onclick event
    if _listbox <> nil  then begin
      if _listbox.Items.Count > 0 then begin
        _listbox.ClearSelection;
        i := _listbox.Items.Count;
        _listbox.Selected[i-1] := True;
      end;
    end;
  end;

  _listbox := GetTheRightListBox('1');
  ListBoxOnClick(_listbox); // Keep the New buttons enabled
end;

procedure TFrm_main.ListBoxOnClick(Sender: TObject);
var
  i, curNumber : Integer;
begin
  if sender is TListBox then begin
    curListBox := TListBox(sender);

    curNumber := StrToInt(GetNumbers(curListBox.Name));  // Get the number of the list box.
    if curNumber = 1 then begin
      if curListBox.ItemIndex >= 0 then begin
        p := PtrItemObject(curListBox.Items.Objects[curListBox.ItemIndex]);
        FCurrGuid := p^.Guid;

        // tijdelijk ter controle
        Edit1.Text := 'Level : ' + IntToStr(p^.Level);
        Edit2.Text := p^.Name;
        Edit3.Text := 'tbl id : ' + IntToStr(p^.Id_table);
        Edit4.Text := p^.Guid;
        Edit5.Text := p^.Parent_guid;
        Edit6.Text := p^.Child_guid;
      end;

      if curNumber = 1 then begin
        for i := 1 to FColumns do begin                      // Enable all New buttons.
          EnableButtons(i);
        end;
      end;

      ColorRelatedItems(curNumber, curListBox.ItemIndex);
    end
    else begin
      for i := 1 to FColumns do begin                      // Disable all New buttons.
          DisableAllButtons;
        end;
      // select alle navolgende data
    end;
  end;
end;

procedure TFrm_main.GetAllItemsForListbox(aListBox: TListBox; level: Byte);
var
  AllComponents : TAppDbMaintainComponents;
begin
  SetStatusbarText('Bezig met het ophalen van alle gegevens...');
  AllComponents := TAppDbMaintainComponents.Create;

  try
    AllComponents.dbFile := FDbFile;
    AllComponents.GetAllItems(aListBox, level);
  finally
    AllComponents.Free;
    SetStatusbarText('');
  end;
end;

procedure TFrm_main.ColorRelatedItems(Level, ItemIdx : Integer);
var
  i, j, counter : Integer;
  _listbox : TListBox;
  parentGuid : String;
begin
  counter := 1;
  for i := 1 to FColumns do begin
    _listbox := GetTheRightListBox(IntToStr(i));
    if level = i then begin  // open file
      if _listbox.Items.Count > 0 then begin
        p := PtrItemObject(_listbox.Items.Objects[ItemIdx]);
        parentGuid := p^.Guid;
        _listbox.ClearSelection;
        _listbox.Selected[ItemIdx] := True;
      end;
    end
    else begin  // ga naar de volgende listbox
      if _listbox.Items.Count > 0 then begin
        _listbox.ClearSelection;
        _listbox.MultiSelect := True;

        for j := 0 to _listbox.Items.Count -1 do begin
          p := PtrItemObject(_listbox.Items.Objects[j]);
          if p^.Parent_guid = parentGuid then begin
            _listbox.Selected[j] := True;
            Inc(counter)
          end;
        end;
      end;
    end;
  end ;
end;

procedure TFrm_main.RemoveListBoxObjects;
var
  i, j : Byte;
  curListBox : TListBox;
begin
  // clear the listboxes pointer objects...
  if  FColumns > 0 then begin
    for i := 1 to FColumns do begin
      curListBox := GetTheRightListBox(IntToStr(i));
      if curListBox <> nil then begin
        if curListBox.Items.Count > 0 then begin
          for j := 0 to curListBox.Items.Count -1 do begin
            Dispose(PtrItemObject(curListBox.Items.Objects[j]));
          end;
          curListBox.Items.Clear;
        end;
      end;
    end;
  end;
end;



end.

