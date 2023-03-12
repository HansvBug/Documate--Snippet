unit Form_Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ComCtrls,
  StdCtrls, ExtCtrls, PairSplitter, Types,
  AppDbItems, Settings, Settingsmanager, Logging, Visual, Form_Configure;

type

  { TFrm_main }

  TFrm_main = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit_: TEdit;
    ListBox1: TListBox;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
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
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MenuItemOptionsConfigureClick(Sender: TObject);
    procedure MenuItemProgramCloseClick(Sender: TObject);
    procedure MenuItemProgramNewClick(Sender: TObject);



  private
    FCurrListBox : TListBox;
    FColumns : Byte;
    FDisableAppItems : String;
    FDbFile : String;

    procedure SetStatusbarText(aText : String);
    procedure CheckAppEnvironment;
    procedure ReadSettings;
    procedure SaveSettings;
    procedure StartLogging;
    procedure FormInitialize;
    procedure RestoreFormState;
    procedure CreateOwnComponents;
    function GetNumbers(const Value: string): string;
    function GetTheRightListBox(identifier: String) : TListBox;
    function GetListBoxItems(identifier: String) : AllItemObjectData;
    function CreateNewDbFile : Boolean;

  public
    Logging : TLog_File;
    Visual  : TVisual;

    procedure ButtonNewOnClick(Sender: TObject);

    property NumberOfColumns : Byte read FColumns write FColumns;
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

procedure TFrm_main.Button1Click(Sender: TObject);
begin
  NumberOfColumns := 3;
  CreateOwnComponents;
end;

procedure TFrm_main.Button2Click(Sender: TObject);
var
  newComponent : TBuildComponent;
begin
  newComponent := TBuildComponent.Create(Frm_Main);
  newComponent.RemoveOwnComponents;
  newComponent.Free;
end;

procedure TFrm_main.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  SaveSettings;
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
  if CreateNewDbFile then begin
    frm := TFrm_new_database.Create(self);
    try
      frm.ShowModal;
    finally
      frm.Free;
    end;

    Appdatabase  := TCreateAppdatabase.Create(FDbFile);
    Appdatabase.InsertMeta('Columns', IntToStr(FColumns));
    Appdatabase.Free;

  end
  else begin
    DisableAppItems := 'Volledig uit';
  end;



  if  DisableAppItems <> 'Volledig uit' then begin
    CreateOwnComponents;
  end;
end;

function TFrm_main.CreateNewDbFile : Boolean;
var
  saveDialog : TSaveDialog;
  Appdatabase : TCreateAppdatabase;
  CanContinue : Boolean;
begin
  Screen.Cursor := crHourGlass;
  saveDialog := TSaveDialog.Create(self);
  saveDialog.Title := 'Opslaan nieuw database bestand';
  saveDialog.InitialDir := ExtractFilePath(Application.ExeName) +  Settings.DatabaseFolder;
  saveDialog.Filter := 'SQLite db file|*.db';
  saveDialog.DefaultExt := 'db';
  saveDialog.Options := saveDialog.Options + [ofOverwritePrompt, ofNoTestFileCreate];
  if saveDialog.Execute then begin
    if not Appdatabase.IsFileInUse(saveDialog.FileName) then begin
      Appdatabase  := TCreateAppdatabase.Create(saveDialog.FileName);
      FDbFile := saveDialog.FileName;  // use for with inserting number of columns
      try
        if not Appdatabase.CreateNewDatabase() then begin
          messageDlg('Fout.', 'Het aanmaken van het de database (tabellen) is mislukt.', mtInformation, [mbOK],0);
          Frm_Main.Logging.WriteToLogError('Het aanmaken van de database (tabellen) is mislukt.');
          Frm_main.DisableAppItems := 'Volledig uit';  { #todo : Const voor maken }
          CanContinue := False;
        end
        else begin
          CanContinue := True;
        end;
      finally
        Appdatabase.Free;
      end;
    end
    else begin
      messageDlg('Fout.', 'Het bestand is in gebruik door een ander proces.', mtInformation, [mbOK],0);
      CanContinue := False;
    end;
  end
  else begin
    CanContinue := False;
  end;

  Screen.Cursor := crDefault;
  result := CanContinue;
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
  //SetStatusbarText('Welkom');

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

//  DisableFunctions;

//  GetAllComponents(ListBoxLevel1, 1);  // mag alleen als er geen DisableFunctions zijn
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
    SetStatusbarText('');
    Screen.Cursor := crDefault;
  finally
    newComponent.Free;
  end;
end;

function TFrm_main.GetNumbers(const Value: string): string;
var
  ch: char;
  Index, Count: integer;
begin
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
  for i := 0 to Frm_Main.ComponentCount -1 do begin
    if Components[i] is TListBox then begin
      _listbox :=  TListBox(Components[i]);
      if _listbox.Name = 'ListBox_' + identifier  then
        begin
          break;
        end;
    end;
  end;
  Result := _listbox;
end;

function TFrm_main.GetListBoxItems(identifier: String): AllItemObjectData;
var
  itemsObjectData : AllItemObjectData;
  i : Integer;
begin
 FCurrListBox := GetTheRightListBox(identifier);

  SetLength(itemsObjectData, FCurrListBox.Items.Count);
  for i := 0 to FCurrListBox.Items.Count -1 do begin
    itemsObjectData[i].Name := FCurrListBox.Items[i];
  end;

  result := itemsObjectData;
end;


procedure TFrm_main.ButtonNewOnClick(Sender: TObject);
var
  tmp : String;
var
  _button : TButton;
  frm : TFrm_Maintain;
  itemsObjectData : AllItemObjectData;
  i, buttonNumber : String;
begin
  if sender is TButton then begin
    _button := TButton(sender);
    buttonNumber := GetNumbers(_button.Name);
  end
  else begin
    ShowMessage('Er gaat iets mis');
    Logging.WriteToLogError('Er is op een button geklikt maar de sender is géén button.');
  end;

  itemsObjectData := GetListBoxItems(buttonNumber);// create a list of existing items


  frm := TFrm_Maintain.Create(Self);
  try
    frm.Caption := _button.Name;
      frm.ComboBoxNewItem.TextHint := _button.Name; { #todo : Optie van maken. }
      frm.ItemObjectData := itemsObjectData;
      frm.ShowModal;
  finally
    frm.Free;
  end;

  if AppDbMaintainComponents.NewItem <> '' then begin  // hoer moet insert into table komen
    tmp := FCurrListBox.Name;
    FCurrListBox.Items.Add(AppDbMaintainComponents.NewItem);
  end;
end;






end.

