unit Form_Main;

{$mode objfpc}{$H+}

interface

uses
  Windows, Classes, Messages, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ComCtrls,
  StdCtrls, ExtCtrls, PairSplitter, LCLType, lcltranslator,
  AppDbItems, Settings, Settingsmanager, Logging, Visual, Form_Configure,
  AppDbMaintain, AppDbMaintainComponents;

const
  UM_DESTROYCONTROL = WM_USER + 230;

type

  { TFrm_main }

  TFrm_main = class(TForm)
    Button1: TButton;
    Button2: TButton;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit_: TEdit;
    ImageList1: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ListBox1: TListBox;
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    MenuItemBreakReletion: TMenuItem;
    Separator3: TMenuItem;
    MenuItemDelete: TMenuItem;
    MenuItemModify: TMenuItem;
    MenuItemInsert: TMenuItem;
    MenuItemOptionsAbout: TMenuItem;
    PopupMenu1: TPopupMenu;
    Separator2: TMenuItem;
    MenuItemOptionsLanguageEn: TMenuItem;
    MenuItemOptionsLanguageNl: TMenuItem;
    MenuItemOptionsLanguage: TMenuItem;
    MenuItemProgramCloseDb: TMenuItem;
    MenuItemProgramOpen: TMenuItem;
    MenuItemOptionsConfigure: TMenuItem;
    PairSplitter2: TPairSplitter;
    PairSplitter3: TPairSplitter;
    PairSplitterSide3: TPairSplitterSide;
    PairSplitterSide4: TPairSplitterSide;
    PairSplitterSide5: TPairSplitterSide;
    PairSplitterSide6: TPairSplitterSide;
    ScrollBoxColumns: TScrollBox;
    ScrollBoxMainColumn: TScrollBox;
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
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
    procedure MenuItemBreakReletionClick(Sender: TObject);
    procedure MenuItemDeleteClick(Sender: TObject);
    procedure MenuItemInsertClick(Sender: TObject);
    procedure MenuItemModifyClick(Sender: TObject);
    procedure MenuItemOptionsConfigureClick(Sender: TObject);
    procedure MenuItemOptionsLanguageEnClick(Sender: TObject);
    procedure MenuItemOptionsLanguageNlClick(Sender: TObject);
    procedure MenuItemProgramCloseClick(Sender: TObject);
    procedure MenuItemProgramCloseDbClick(Sender: TObject);
    procedure MenuItemProgramNewClick(Sender: TObject);
    procedure MenuItemProgramOpenClick(Sender: TObject);



  private
    FCurrListBox         : TListBox;          // Current Listbox. The active listbox.
    FCurrGuid            : String;            // The guid of the selected listbox item.
    FColumns             : Byte;              // Field of property NumberOfColumns.
    FDisableAppItems     : String;            // Field of property DisableAppItems.  // Not used yet
    FDbFile              : String;            // Location database file.
    FDbDescriptionShort  : String;            // Field of property DbDescriptionShort. Holds the database description when create new db file.
    FCanContinue         : Boolean;           // Property of CanContinue. Can the application continue.
    FFormOpen            : Boolean;           // Used for 'new item form'.
    FFoundItems          : Array of Integer;  // Holds the index of the listbox items.
    FArrayPosition       : Integer;           // Used for search next listbox item.
    FSelLb1ItemIndex     : Integer;          // Holds the index of the selected listbox1 item.
    FSelLbItemIndex      : Integer;          // Holds the index of the selected listbox1 item.

    AllComponents : TAppDbMaintainComponents;

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
    procedure HideComponents(ControleType : String);
    function GetNumbers(const Value: string): String;
    function GetTheRightListBox(identifier: Byte) : TListBox;
    function GetTheRightLabel(identifier: Byte) : TLabel;
    function GetTheRightEdit(identifier: Byte) : TEdit;
    function GetListBoxItems(identifier: Byte) : AllItemsObjectData;
    function SelectDbFilePath : Boolean;
    procedure GetAllItemsForListbox(aListBox : TListBox; level : Byte);
    procedure ColorRelatedItems(Level, ItemIdx : Integer);
    procedure RemoveListBoxObjects;

    // test muteren listbox tabblad 2
    procedure ComboBoxDone(Sender: TObject);
    procedure ComboBoxKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ComboBoxMouseDown(Sender: TObject; {%H-}Button: TMouseButton;
                            {%H-}Shift: TShiftState; X, Y: Integer);
    procedure ComboBoxUmDestroyControl(var msg: TMessage); message UM_DESTROYCONTROL;

    property DisableAppItems : string read FDisableAppItems write FDisableAppItems;

  public
    FDebug : Boolean;

    Logging : TLog_File;
    Visual  : TVisual;

    procedure ButtonNewOnClick(Sender: TObject);
    procedure ButtonNextOnClick(Sender: TObject);

    procedure ListBoxOnClick(Sender: TObject);
    procedure ListBoxOnDblClick(Sender: TObject);
    procedure ListBoxOnSelectionChange(Sender: TObject; User: boolean);
    procedure ListBoxOnMouseDown(Sender: TObject; Button: TMouseButton;
              Shift: TShiftState; X, Y: Integer);
    procedure ListBoxOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

    procedure EditOnChange(Sender: TObject);
    function ListBoxSearchItem(Listbox : TListBox; SearchText : String) : Integer;
    procedure DelteItem;

    property NumberOfColumns : Byte read FColumns write FColumns;
    property DbDescriptionShort : String read FDbDescriptionShort write FDbDescriptionShort;
    property CanContinue : Boolean read FCanContinue write FCanContinue;

  end;

var
  Frm_main: TFrm_main;
  SetMan  : TSettingsManager; // of verplaatsen naar public?

  //ApplicationArguments : array of string;

implementation

uses ApplicationEnvironment, AppDbCreate, form_new_db_config, BuildComponents,
  Form_Maintain;



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

procedure TFrm_main.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  dbMaintain : TAppDbMaintain;
begin
  // Optimize the app. database.
  if FileExists(ExtractFilePath(Application.ExeName) + Settings.DatabaseFolder + PathDelim + Settings.DatabaseName) then begin
  //    CopyAppDbFile;
      dbMaintain := TAppDbMaintain.Create;
      dbMaintain.ResetAutoIncrementAll;
      dbMaintain.Optimze;
      dbMaintain.Free;
  end;
end;

procedure TFrm_main.Button2Click(Sender: TObject);
begin
  // page 2 test button
  ListBox1.ClearSelection;
  ListBox1.Selected[0] := True;
end;

procedure TFrm_main.FormCreate(Sender: TObject);
begin
  Caption := Settings.ApplicationName;
  CheckAppEnvironment;
  ReadSettings;
  SetDefaultLang(SetMan.DefaultLanguage);
  StartLogging;
  FormInitialize;
  FDebug := True;  // tmp
end;

procedure TFrm_main.FormDestroy(Sender: TObject);
begin
  RemoveListBoxObjects;  // Clear the listboxes pointer objects...
  Visual.Free;
  Logging.StopLogging;
  Logging.Free;
  SetMan.Free;
end;

procedure TFrm_main.FormShow(Sender: TObject);
begin
  RestoreFormState();
end;

procedure TFrm_main.ListBox1DblClick(Sender: TObject);
begin
  ListBoxOnDblClick(Sender);
end;

procedure TFrm_main.MenuItemBreakReletionClick(Sender: TObject);
var
  Guid, parentGuid, itemName  : String;

  buttonSelected, Level : Integer;
  appDbMaintain : TAppDbMaintainComponents;
  _listBox : TListBox;
begin
  itemName := PtrItemObject(FCurrListBox.Items.Objects[FCurrListBox.itemindex])^.Name;
  buttonSelected := MessageDlg('Wilt u de relatie naar "' + itemName + '" verwijderen?' ,mtConfirmation, [mbYes,mbCancel], 0);
  if buttonSelected = mrYes    then begin
    Guid := PtrItemObject(FCurrListBox.Items.Objects[FCurrListBox.itemindex])^.Guid;
    Level := PtrItemObject(FCurrListBox.Items.Objects[FCurrListBox.itemindex])^.Level;
    appDbMaintain := TAppDbMaintainComponents.Create;
    appDbMaintain.dbFile := FDbFile;
    appDbMaintain.curListBox := FCurrListBox;  // needed for laod the listbox items again with changed relations

    _listBox := GetTheRightListBox(1);
    parentGuid := PtrItemObject(_listBox.Items.Objects[FSelLb1ItemIndex])^.Guid;
    appDbMaintain.DeleteItemRel(Guid, parentGuid, Level);
    appDbMaintain.Free;
  end;

  GetAllItemsForListbox(FCurrListBox, 0);
  ListBoxOnClick(_listBox);
end;

procedure TFrm_main.MenuItemDeleteClick(Sender: TObject);
begin
  DelteItem;
end;

procedure TFrm_main.MenuItemInsertClick(Sender: TObject);
begin
  ButtonNewOnClick(FCurrListBox);
end;

procedure TFrm_main.MenuItemModifyClick(Sender: TObject);
begin
  ListBoxOnDblClick(FCurrListBox);
end;

procedure TFrm_main.ComboBoxDone(Sender: TObject);
var
  appDbMaintain : TAppDbMaintainComponents;
  AllNewItems : AllItemsObjectData;
  tmp : String;
begin
  //Change the item in the databse file
  AllNewItems := nil;
  SetLength(AllNewItems, 1);
  AllNewItems[0].Level := PtrItemObject(FCurrListBox.Items.Objects[FCurrListBox.itemindex])^.Level;
  AllNewItems[0].Name := (Sender as TComboBox).Text;
  AllNewItems[0].Parent_guid := PtrItemObject(FCurrListBox.Items.Objects[FCurrListBox.itemindex])^.Parent_guid;
  AllNewItems[0].Child_guid :=  PtrItemObject(FCurrListBox.Items.Objects[FCurrListBox.itemindex])^.Child_guid;
  AllNewItems[0].Action := 'Update';

  (Sender as TComboBox).OnExit := nil; // sometimes this method is called twice, this is to prevent this
  FCurrListBox.Items[FCurrListBox.itemindex] := (Sender As TComboBox).Text;

  appDbMaintain := TAppDbMaintainComponents.Create;
  appDbMaintain.dbFile := FDbFile;
  // insert OF update, hangt er van af.
  if not AppDbMaintain.DoesItemNameExists(AllNewItems[0].Name, AllNewItems[0].Level) then begin  // Item name is new, then insert.
    AppDbMaintain.UpdateItem(AllNewItems);
  end
  else begin
    // naam komt voor:
    //  dan naam niet opslaan maar wel de:
    //    de relaties van het gewijzigde item naar het bestaande item overbrengen
    //    als bestaande item naam niet verder voorkomt dan verwijderen


  end;


  AppDbMaintain.Free;

  PostMessage(Handle, UM_DESTROYCONTROL, 0, PtrInt(Sender));
end;

procedure TFrm_main.ComboBoxKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
  If Shift = [] then
    case Key of
      VK_RETURN: ComboBoxDone(Sender);
      VK_ESCAPE: begin
                   (Sender as TCombobox).OnExit := nil;
                   PostMessage(Handle, UM_DESTROYCONTROL, 0, PtrInt(Sender));
                 end;
    end;
end;

procedure TFrm_main.ComboBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  If not PtInrect((Sender As TControl).ClientRect, Point(X, Y)) then
    ComboBoxDone(Sender);
end;

procedure TFrm_main.ComboBoxUmDestroyControl(var msg: TMessage);
begin
  TObject(msg.lparam).Free;
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
    if FDebug then Logging.WriteToLogDebug('Openen configuratie scherm.');
    frm.ShowModal;
  finally
    frm.Free;
    ReadSettings();
    if FDebug then Logging.WriteToLogDebug('Sluiten configuratie scherm.');
    if (SetMan.ActivateLogging) and not ActivateLogging then
      begin
        Logging.Free;
        StartLogging();
      end
    end;
end;

procedure TFrm_main.MenuItemOptionsLanguageEnClick(Sender: TObject);
begin
  SetDefaultLang('en');
  MenuItemOptionsLanguageEN.Checked := True;
  MenuItemOptionsLanguageNL.Checked := False;
  //GetLocaleFormatSettings($409, DefaultFormatSettings);
  SetMan.DefaultLanguage := 'en';
  SetMan.SaveSettings;
end;

procedure TFrm_main.MenuItemOptionsLanguageNlClick(Sender: TObject);
begin
  SetDefaultLang('nl');
  MenuItemOptionsLanguageNl.Checked := True;
  MenuItemOptionsLanguageEn.Checked := False;
  //GetLocaleFormatSettings($413, DefaultFormatSettings);
  SetMan.DefaultLanguage := 'nl';
  SetMan.SaveSettings;
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
          Logging.WriteToLogError('Het aanmaken van de database (tabellen) is mislukt.');
          DisableAppItems := 'Volledig uit';  { #todo : Const voor maken }
        end
        else begin
          Appdatabase.InsertMeta('Columns', IntToStr(NumberOfColumns));
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

  if  (DisableAppItems <> 'Volledig uit') and (DisableAppItems <> '') then begin
    CreateOwnComponents;
  end;
end;

procedure TFrm_main.MenuItemProgramOpenClick(Sender: TObject);
var
  openDialog : TOpenDialog;
  appDbMaintain : TAppDbMaintain;
  i : Integer;
  _listBox : TListBox;
begin
  Screen.Cursor := crHourGlass;
  SetStatusbarText('Openen documentatie bestand...');
  PageControl1.ActivePage := TabSheet1;
  openDialog := TOpenDialog.Create(self);
  openDialog.InitialDir := GetCurrentDir + Settings.DatabaseFolder;
  openDialog.Options := [ofFileMustExist];
  openDialog.Filter := 'Documate files|*.db';

  if openDialog.Execute then begin
    appDbMaintain := TAppDbMaintain.Create;

    try
      FFormOpen := True;
      FDbFile := openDialog.FileName;
      appDbMaintain.dbFile := FDbFile; { #todo : moet anders }
      NumberOfColumns := appDbMaintain.GetNumberOfColumns;
      if FDebug then Logging.WriteToLogDebug('Database bestand openen: ' + FDbFile);

      RemoveListBoxObjects;  // when a database is open en a new is opened the listbox object data must be removed
      CreateOwnComponents;
      MenuItemProgramCloseDb.Enabled := True;
      SetDbNameInStatusbar(ExtractFileName(FDbFile));

      AllComponents := TAppDbMaintainComponents.Create;

      // Get all items for all Listboxes
      if  NumberOfColumns > 0 then begin
        for i := 1 to NumberOfColumns do begin
          _listBox := GetTheRightListBox(i);
          _listBox.Items.BeginUpdate;
          GetAllItemsForListbox(_listBox, i);
          _listBox.Items.EndUpdate;
        end;
      end;

      ColorRelatedItems(1, 0);
      AllComponents.Free;
    finally
      FFormOpen := False;
      appDbMaintain.Free;
      if FDebug then Logging.WriteToLogDebug('Database bestand is geopend');
    end;
  end
  else begin
    // Cancel opendialog
  end;
  SetStatusbarText('');
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
  FFormOPen := False;

  if SetMan.DefaultLanguage = 'nl' then begin
    MenuItemOptionsLanguageNl.Checked := True;
    MenuItemOptionsLanguageEn.Checked := False;
    {%H-}GetLocaleFormatSettings($409, DefaultFormatSettings);{%H-}
  end
  else if SetMan.DefaultLanguage = 'en' then begin
    MenuItemOptionsLanguageEn.Checked := True;
    MenuItemOptionsLanguageNl.Checked := False;
    {%H-}GetLocaleFormatSettings($413, DefaultFormatSettings);{%H-}
  end
  else begin
    SetDefaultLang('en');
  end;

  //PageControl1.Page[1].TabVisible := False;  // disable the second page.
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

    newComponent.BuildBodyPanelsAndSplitters(ScrollBoxMainColumn);
    newComponent.BuildBodyPanelsAndSplitters(ScrollBoxColumns); // Create "body" panels and splitters between them
    newComponent.BuildHeaderPanels;     // Create "header" panels
    newComponent.BuildSearchPanels;     // Create "search" panels
    newComponent.BuildButtons('Next'); // Create the new item buttons
    newComponent.BuildDataPanels;       // Create "data" panels
    newComponent.BuildListBoxes;        // Create listboxes which hold the data
    newComponent.BuildLabel;            // Create the search Labels
//    HideComponents('TLabel');
    newComponent.BuildEdit;             // Create the search Edit boxes

    newComponent.BuildButtons('New'); // Create the new item buttons
//    HideComponents('TEdit'); // hide all search edits accept the first one.
//    HideComponents('TButton');
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
      end;
    end;
  end;
end;

procedure TFrm_main.HideComponents(ControleType : String);
var
  _edit : TEdit = nil;
  _label : TLabel;
  _button : TButton;
  currNumber : String;
  i, j : Integer;
begin
  case ControleType of
    'TEdit' : begin
      for i := 0 to Frm_Main.ComponentCount - 1 do begin
        if Components[i] is TEdit then begin
          _edit :=  TEdit(Components[i]);
          currNumber := GetNumbers(_edit.Name);
          if currNumber <> '' then begin
            j := StrToInt(currNumber);
          end
          else J := 0;
          if (Pos('EditSearch_' , _edit.Name) > 0) and (j > 1) then begin
            _edit.Visible := False;
          end;
        end
      end;
    end;
    'TLabel' : begin
      for i := 0 to Frm_Main.ComponentCount - 1 do begin
        if Components[i] is TLabel then begin
          _label :=  TLabel(Components[i]);
          currNumber := GetNumbers(_label.Name);
          if currNumber <> '' then begin
            j := StrToInt(currNumber);
          end
          else J := 0;
          if (Pos('LabelSearchResult_' , _label.Name) > 0) and (j > 1) then begin
            _label.Visible := False;
          end;
        end
      end;
    end;
    'TButton' : begin
      for i := 0 to Frm_Main.ComponentCount - 1 do begin
        if Components[i] is TButton then begin
          _button :=  TButton(Components[i]);
          currNumber := GetNumbers(_button.Name);
          if currNumber <> '' then begin
            j := StrToInt(currNumber);
          end
          else J := 0;
          if (Pos('ButtonNext_' , _button.Name) > 0) and (j > 1) then begin
            _button.Visible := False;
          end;
        end
      end;
    end;
  end;
end;

function TFrm_main.GetNumbers(const Value: string): String;
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

function TFrm_main.GetTheRightListBox(identifier: Byte): TListBox;
var
  i : Integer;
  _listbox : TListBox;
begin
  Result := nil;
  for i := 0 to Frm_Main.ComponentCount -1 do begin
    if Components[i] is TListBox then begin
      _listbox :=  TListBox(Components[i]);
      if _listbox.Name = 'ListBox_' + IntToStr(identifier)  then
        begin
          Result := _listbox;
          break;
        end;
    end;
  end;
end;

function TFrm_main.GetTheRightLabel(identifier: Byte): TLabel;
var
  i : Integer;
  _label : TLabel;
begin
  Result := nil;
  for i := 0 to Frm_Main.ComponentCount -1 do begin
    if Components[i] is TLabel then begin
      _label :=  TLabel(Components[i]);
      if _label.Name = 'LabelSearchResult_' + IntToStr(identifier)  then
        begin
          Result := _label;
          break;
        end;
    end;
  end;
end;

function TFrm_main.GetTheRightEdit(identifier: Byte): TEdit;
var
  i : Integer;
  _edit : TEdit;
begin
  Result := nil;
  for i := 0 to Frm_Main.ComponentCount -1 do begin
    if Components[i] is TEdit then begin
      _edit :=  TEdit(Components[i]);
      if _edit.Name = 'EditSearch_' + IntToStr(identifier)  then
        begin
          Result := _edit;
          break;
        end;
    end;
  end;
end;

function TFrm_main.GetListBoxItems(identifier: Byte): AllItemsObjectData;
var
  itemsObjectData : AllItemsObjectData = nil;
  i : Integer;
begin
  FCurrListBox := GetTheRightListBox(identifier);
  SetLength(itemsObjectData, FCurrListBox.Items.Count);

  for i := 0 to FCurrListBox.Items.Count -1 do begin
    itemsObjectData[i].Name := PtrItemObject(FCurrListBox.Items.Objects[i])^.Name;
    itemsObjectData[i].Level := PtrItemObject(FCurrListBox.Items.Objects[i])^.Level;
    itemsObjectData[i].Guid := PtrItemObject(FCurrListBox.Items.Objects[i])^.Guid;
    itemsObjectData[i].Parent_guid := PtrItemObject(FCurrListBox.Items.Objects[i])^.Parent_guid;
    itemsObjectData[i].Child_guid := PtrItemObject(FCurrListBox.Items.Objects[i])^.Child_guid;
  end;

  result := itemsObjectData;
end;

procedure TFrm_main.ButtonNewOnClick(Sender: TObject);
var
  _button : TButton;
  frm : TFrm_Maintain;
  itemsNames : AllItemsObjectData;
  AllNewItems : AllItemsObjectData;
  Level : Byte;
  appDbMaintain : TAppDbMaintainComponents;
  i : Integer;
begin
  if sender is TButton then begin
    _button := TButton(sender);
    Level := StrToInt(GetNumbers(_button.Name));
  end
  else if sender is TListBox then begin
    FCurrListBox := TListBox(sender);
    Level := StrToInt(GetNumbers(FCurrListBox.Name));
  end;

  if Level > 0 then begin

    itemsNames := GetListBoxItems(Level);// create a list of existing items
    frm := TFrm_Maintain.Create(Self);

    try
      frm.Caption := 'Voeg een nieuw item toe';
      frm.ComboBoxNewItem.TextHint := 'Nieuw item'; { #todo : Optie van maken. }
      frm.CurrLevel := Level;  // Level alvast meegeven
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
        FCurrListBox := GetTheRightListBox(level);

        for i := 0 to Length(AllNewItems) - 1 do begin
          AllNewItems[i].Level := level;
        end;
        AppDbMaintain.InsertNewItem(AllNewItems);  // Insert the new item.
        AppDbMaintain.InsertRelation(AllNewItems);  // Insert the relation
      finally
        appDbMaintain.free;
      end;

      GetAllItemsForListbox(FCurrListBox, 0);

      if level = 1 then begin // select new added item
        if FCurrListBox.Items.Count > 0 then begin
          FCurrListBox.ClearSelection;
          i := FCurrListBox.Items.Count;
          FCurrListBox.Selected[i-1] := True;
        end;
      end;
    end;

    FCurrListBox := GetTheRightListBox(1);
    ListBoxOnClick(FCurrListBox); // Keep the New buttons enabled
  end;
end;

procedure TFrm_main.ButtonNextOnClick(Sender: TObject);
var
  _listBox : TListBox;
  FListBoxMaxItemIndex : Integer;
begin
  if NumberOfColumns >= 1 then begin
    _listBox := GetTheRightListBox(1);
  end;

  if Length(FFoundItems) > 0 then
    begin
      _listBox.ClearSelection;

      if FArrayPosition = -1 then
        begin
          FListBoxMaxItemIndex :=  _listBox.ItemIndex;
          FArrayPosition := 0; // first array element
          _listBox.Selected[FFoundItems[FArrayPosition]] := True;
          _listBox.OnSelectionChange(_listbox, false);

          if FFoundItems[FArrayPosition] = FListBoxMaxItemIndex then
            FArrayPosition := -1
        end
      else
        begin
        FArrayPosition := FArrayPosition + 1;
        _listBox.Selected[FFoundItems[FArrayPosition]] := True;
        _listBox.OnSelectionChange(_listbox, false);
        if FFoundItems[FArrayPosition] = FListBoxMaxItemIndex then
          FArrayPosition := -1
        end;
    end;
end;

procedure TFrm_main.ListBoxOnClick(Sender: TObject);
var
  i, j, curNumber : Integer;
  _edit : TEdit;
begin
  if sender is TListBox then begin
    FCurrListBox := TListBox(sender);

    curNumber := StrToInt(GetNumbers(FCurrListBox.Name));  // Get the number of the list box.
    if curNumber = 1 then begin
      if FCurrListBox.ItemIndex >= 0 then begin
        FSelLbItemIndex := FCurrListBox.ItemIndex; // used with ButtonNew
        p := PtrItemObject(FCurrListBox.Items.Objects[FCurrListBox.ItemIndex]);
        FCurrGuid := p^.Guid;

        // tijdelijk ter controle
        Edit1.Text := 'Level : ' + IntToStr(p^.Level);
        Edit2.Text := p^.Name;
        Edit3.Text := 'tbl id : ' + IntToStr(p^.Id_table);
        Edit4.Text := p^.Guid;

        for j:= 0 to Length(p^.Parent_guid) -1 do begin
          Edit5.Text := 'P: ' + p^.Parent_guid[j+1];
        end;
        Edit6.Text := 'C: ' + p^.Child_guid;
      end;

      if curNumber = 1 then begin
        for i := 1 to NumberOfColumns do begin                      // Enable all New buttons.
          EnableButtons(i);
        end;
      end;

      ColorRelatedItems(curNumber, FCurrListBox.ItemIndex);
    end
    else begin
      for i := 1 to NumberOfColumns do begin                      // Disable all New buttons.
          DisableAllButtons;
        end;
      // select alle navolgende data
    end;

    //Clear the search array
    FArrayPosition := -1;
    FFoundItems := nil;
    //disable search next button
    _edit := GetTheRightEdit(curNumber);
    _edit.Clear;
    if FCurrListBox.ItemIndex >= 0 then begin
      FCurrListBox.Selected[FCurrListBox.ItemIndex] := true;  // Reselect. Needed when search next is used.
    end;
  end;
end;

procedure TFrm_main.ListBoxOnDblClick(Sender: TObject);
var
  r: TRect;
  cb: TComboBox;
  Level : Byte;
  itemsNames : AllItemsObjectData;
  i : Integer;
begin
  if sender is TListbox then begin
    FCurrListBox := Sender as TListbox;
    if FCurrListBox.ItemIndex < 0 then Exit;
  end;

  cb := TComboBox.Create(Self);
  cb.Font.Size := 9;
  r := FCurrListBox.ItemRect(FCurrListBox.itemindex);
  r.topleft := FCurrListBox.ClientToScreen(r.topleft);
  r.BottomRight := FCurrListBox.clienttoscreen(r.bottomright);
  r.topleft := ScreenToClient(r.topleft);
  r.BottomRight := screenToClient(r.bottomright);

  Level := StrToInt(GetNumbers(FCurrListBox.Name));
  itemsNames := GetListBoxItems(Level);
  for i := 0 to Length(itemsNames)-1 do begin
    cb.Items.Add(itemsNames[i].Name);
  end;

  cb.Text :=  FCurrListBox.Items[FCurrListBox.itemindex];
  cb.setbounds(r.left, r.top-2, FCurrListBox.clientwidth, r.bottom - r.top + 4);
  cb.OnExit := @ComboBoxDone;
  cb.OnMouseDown:= @ComboBoxMouseDown;
  cb.OnKeyUp := @ComboBoxKeyUp;
  cb.Parent := Self;
  cb.SetFocus;
end;

procedure TFrm_main.ListBoxOnSelectionChange(Sender: TObject; User: boolean);
var
  curNumber : Integer;
begin
  if sender is TListBox then begin
    FCurrListBox := TListBox(sender);

    curNumber := StrToInt(GetNumbers(FCurrListBox.Name));  // Get the number of the list box.
    if curNumber = 1 then begin
      if FCurrListBox.ItemIndex >= 0 then begin
        ColorRelatedItems(curNumber, FCurrListBox.ItemIndex);   { #todo : Deze regel is dubbel met listbox OnClick }
      end;
    end;
  end;
end;

procedure TFrm_main.ListBoxOnMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  curNumber : Integer;
begin
  if sender is TListBox then begin
    FCurrListBox := TListBox(sender);
  end;

  { #todo : Deels dubbel met listboxOnClik ==> Opschonen }
  curNumber := StrToInt(GetNumbers(FCurrListBox.Name));  // Get the number of the list box.
  if curNumber = 1 then begin
    if FCurrListBox.ItemIndex >= 0 then begin
      FSelLb1ItemIndex := FCurrListBox.ItemIndex;
    end;
  end;

  if FSelLb1ItemIndex >= 0 then begin
    FCurrListBox.PopupMenu := PopupMenu1;
  end
  else begin
    FCurrListBox.PopupMenu := nil;
  end;
end;

procedure TFrm_main.ListBoxOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if FCurrListBox.Items.Count > 0 then begin
    if Key = VK_DELETE then begin
      DelteItem;
    end;
  end;
end;

procedure TFrm_main.EditOnChange(Sender: TObject);
var
  _edit : TEdit;
  _label : TLabel;
  i, curNumber : Integer;
begin
  if sender is TEdit then begin
    _edit := TEdit(sender);

    // Get the right listbox to search in
    curNumber := StrToInt(GetNumbers(_edit.Name));  // Get the number of the Edit box
    FCurrListBox := GetTheRightListBox(curNumber);

    i := ListBoxSearchItem(FCurrListBox, _edit.Text);

    // LabelSearchResult_
    _label := GetTheRightLabel(curNumber);
    _label.Caption := IntToStr(i) + ' st.';

    FArrayPosition := -1;
  end;
end;

function TFrm_main.ListBoxSearchItem(Listbox: TListBox; SearchText: String
  ): Integer;
var
  i, counter : Integer;
begin
  Listbox.ClearSelection;
  SetLength(FFoundItems, 0);
  Listbox.MultiSelect := True;
  counter := 0;
  for i := 0 to Listbox.Items.Count - 1 do begin
    if Pos(SearchText, Listbox.Items[i]) > 0 then begin
      ListBox.Selected[i] := True;
      SetLength(FFoundItems, counter + 1);
      FFoundItems[counter] := i;
      Inc(Counter);
    end;
  end;

  Result := Counter;
end;

procedure TFrm_main.DelteItem;
var
  Guid, itemName  : String;
  appDbMaintain : TAppDbMaintainComponents;
  buttonSelected, Level : Integer;
begin
  itemName := PtrItemObject(FCurrListBox.Items.Objects[FCurrListBox.itemindex])^.Name;
  buttonSelected := MessageDlg('Wilt u "' + itemName + '" verwijderen?' ,mtConfirmation, [mbYes,mbCancel], 0);

  if buttonSelected = mrYes    then begin
    Guid := PtrItemObject(FCurrListBox.Items.Objects[FCurrListBox.itemindex])^.Guid;
    Level := PtrItemObject(FCurrListBox.Items.Objects[FCurrListBox.itemindex])^.Level;
    appDbMaintain := TAppDbMaintainComponents.Create;
    appDbMaintain.dbFile := FDbFile;
    appDbMaintain.DeleteItem(Guid, level);
    appDbMaintain.Free;

    Dispose(PtrItemObject(FCurrListBox.Items.Objects[FCurrListBox.itemindex])); // delete the Item.Object.
    FCurrListBox.Items.Delete(FCurrListBox.itemindex);
  end;
end;

procedure TFrm_main.GetAllItemsForListbox(aListBox : TListBox; level : Byte);
var
  GetAllComponents : TAppDbMaintainComponents;
begin
  SetStatusbarText('Bezig met het ophalen van alle gegevens...');

  if not FFormOPen then begin
    GetAllComponents := TAppDbMaintainComponents.Create;
    GetAllComponents.dbFile := FDbFile;  { #todo : Database file moet anders worden toegekend }
    GetAllComponents.GetAllItems(aListBox, level);
    GetAllComponents.Free;
  end
  else begin
    try
      AllComponents.dbFile := FDbFile;  { #todo : Database file moet anders worden toegekend }
      AllComponents.GetAllItems(aListBox, level);
    finally
      SetStatusbarText('');
    end;
  end;
end;

procedure TFrm_main.ColorRelatedItems(Level, ItemIdx : Integer);
var
  i, j, k, counter : Integer;
  _listbox : TListBox;
  parentGuid : String;
begin
  counter := 1;
  for i := 1 to NumberOfColumns do begin
    _listbox := GetTheRightListBox(i);
    if level = i then begin  // open file
      if _listbox.Items.Count > 0 then begin
        p := PtrItemObject(_listbox.Items.Objects[ItemIdx]);
        parentGuid := p^.Guid;
        _listbox.ClearSelection;
        _listbox.Selected[ItemIdx] := True;
        Application.ProcessMessages;
      end;
    end
    else begin  // ga naar de volgende listbox
      if _listbox.Items.Count > 0 then begin
        _listbox.ClearSelection;
        _listbox.MultiSelect := True;
        Application.ProcessMessages;
        for j := 0 to _listbox.Items.Count -1 do begin
          p := PtrItemObject(_listbox.Items.Objects[j]);

          for k:= 0 to Length(p^.Parent_guid) -1 do begin
            if p^.Parent_guid[k] = parentGuid then begin  // Dit moet anders
              _listbox.Selected[j] := True;
              Inc(counter);
              Application.ProcessMessages;
            end;
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
  if  NumberOfColumns > 0 then begin
    for i := 1 to NumberOfColumns do begin
      curListBox := GetTheRightListBox(i);
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


