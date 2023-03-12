unit BuildComponents;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ComCtrls,
  StdCtrls, ExtCtrls,
  Form_Main;

type

  { TBuildComponent }

  TBuildComponent = class(TObject)
    private
      FAllPanels : TPanel;
      FColumns : Byte;

      _panel : TPanel;
      _splitter : TSplitter;
      _edit : TEdit;
      _label : TLabel;
      _listbox : TListBox;
      _button : TButton;

      allPanels : array of TPanel;        // used in TBuildComponents
      allSplitters : array of TSplitter;  // used in TBuildComponents

      mainForm : TForm;

      function CreatePanel(aName : String; aParent : TWinControl; aWidth : Integer) : TPanel;
      function CreateSplitter(aName : String; aParent : TWinControl) : TSplitter;
      function CreateEdit(aName : String; aParent : TWinControl) : TEdit;
      function CreateLabel(aName : String; aParent : TWinControl) : TLabel;
      function CreateListBox(aName : String; aParent : TWinControl) : TListBox;
      function CreateButton(aName : String; aParent : TWinControl) : TButton;

      procedure SetArrays;
      //procedure PanelClick(Sender: TObject);

    public
      constructor Create(aForm : TFrm_main); overload;
      destructor  Destroy; override;
      procedure RemoveOwnComponents;
      procedure BuildBodyPanelsAndSplitters(aParent : TWinControl);
      procedure BuildHeaderPanels;
      procedure BuildSearchPanels;
      procedure BuildDataPanels;
      procedure BuildListBoxes;
      procedure BuildEdit;
      procedure BuildButtons(aCaption : String);

      property NumberOfColumns : Byte read FColumns write FColumns;
  end;

implementation


{ TBuildComponent }

constructor TBuildComponent.Create(aForm : TFrm_main);
begin
  mainForm := aForm;
end;

destructor TBuildComponent.Destroy;
begin
  inherited Destroy;
end;

procedure TBuildComponent.SetArrays;
begin
  Setlength(allPanels, NumberOfColumns);
  Setlength(allSplitters, NumberOfColumns);
end;

procedure TBuildComponent.RemoveOwnComponents;
var
  i : Integer;
begin
  for i := mainForm.ComponentCount -1 downto 0 do begin
    if mainForm.Components[i] is TButton then begin
      _button :=  TButton(mainForm.Components[i]);
      if Pos('ButtonNew_' , _button.Name) > 0 then begin
        _button.Free;
      end;
    end;
  end;

  for i := mainForm.ComponentCount -1 downto 0 do begin
    if mainForm.Components[i] is TListBox then begin
      _listbox :=  TListBox(mainForm.Components[i]);
      if Pos('ListBox_' , _listbox.Name) > 0 then begin
        _listbox.Free;
      end;
    end;
  end;

  for i := mainForm.ComponentCount -1 downto 0 do begin
    if mainForm.Components[i] is TEdit then begin
      _edit :=  TEdit(mainForm.Components[i]);
      if Pos('EditSearch_' , _edit.Name) > 0 then begin
        _edit.Free;
      end;
    end;
  end;

  for i := mainForm.ComponentCount -1 downto 0 do begin
    if mainForm.Components[i] is TPanel then begin
      _panel :=  TPanel(mainForm.Components[i]);
      if Pos('PanelData_' , _panel.Name) > 0 then begin
        _panel.Free;
      end;
    end;
  end;

  for i := mainForm.ComponentCount -1 downto 0 do begin
    if mainForm.Components[i] is TPanel then begin
      _panel :=  TPanel(mainForm.Components[i]);
      if Pos('PanelSearch' , _panel.Name) > 0 then begin
        _panel.Free;
      end;
    end;
  end;

  for i := mainForm.ComponentCount -1 downto 0 do begin
    if mainForm.Components[i] is TPanel then begin
      _panel :=  TPanel(mainForm.Components[i]);
      if Pos('PanelHeader' , _panel.Name) > 0 then begin
        _panel.Free;
      end;
    end;
  end;

  for i := mainForm.ComponentCount -1 downto 0 do begin
    if mainForm.Components[i] is TSplitter then begin
      _splitter :=  TSplitter(mainForm.Components[i]);
      if Pos('Splitter_' , _splitter.Name) > 0 then begin
        _splitter.Free;
      end;
    end;
  end;

  for i := mainForm.ComponentCount -1 downto 0 do begin
    if mainForm.Components[i] is TPanel then begin
      _panel :=  TPanel(mainForm.Components[i]);
      if Pos('PanelBody_' , _panel.Name) > 0 then begin
        _panel.Free;
      end;
    end;
  end;

end;

function TBuildComponent.CreatePanel(aName: String; aParent : TWinControl; aWidth : Integer): TPanel;
begin
  _panel := TPanel.Create(mainForm);
  _panel.Parent := aParent;
  _panel.Name := aName;
  _panel.Width := aWidth;
  //_panel.OnClick := @PanelClick;
  _panel.Left := 9999;  //Necessary because otherwise the splitter will be on the left of the panel instead of on the right
                       //https://forum.lazarus.freepascal.org/index.php?action=post;topic=62608.0;last_msg=473575
  result := _panel;
end;


function TBuildComponent.CreateSplitter(aName: String; aParent: TWinControl
  ): TSplitter;
begin
   _splitter := TSplitter.Create(mainForm);
   _splitter.Parent := aParent;
   _splitter.Name := aName;
   _splitter.MinSize := 30;
   _splitter.Width := 10;
   _splitter.Left := 9999;
   result := _splitter;
end;

function TBuildComponent.CreateEdit(aName: String; aParent: TWinControl): TEdit;
begin
  _edit := TEdit.Create(mainForm);
  _edit.Parent := aParent;
  _edit.Name := aName;
  _edit.Height := 28;  // Default height
  _edit.Width := 100;  // Default with;
  result := _edit;
end;

function TBuildComponent.CreateLabel(aName: String; aParent: TWinControl
  ): TLabel;
begin
  _label := TLabel.Create(mainForm);
  _label.Name := aName;
  result := _label;
end;

function TBuildComponent.CreateListBox(aName: String; aParent: TWinControl
  ): TListBox;
begin
  _listbox := TListBox.Create(mainForm);
  _listbox.Parent := aParent;
  _listbox.Name := aName;
  result := _listbox;
end;

function TBuildComponent.CreateButton(aName: String; aParent: TWinControl
  ): TButton;
begin
  _button := TButton.Create(mainForm);
  _button.Parent := aParent;
  _button.Height := 31;  // Default height
  _button.Width := 50;   // modified
  _button.OnClick :=  @Form_Main.Frm_main.ButtonNewOnClick; //
  result := _button;
end;



procedure TBuildComponent.BuildBodyPanelsAndSplitters(aParent: TWinControl);
var
  i : Integer;
begin
  SetArrays;

  for i := 1 to NumberOfColumns do begin
    allPanels[i-1] := CreatePanel('PanelBody_' + IntToStr(i), aParent, 200);
    allPanels[i-1].AnchorSide[akLeft].Control := aParent;
    allPanels[i-1].Align := alLeft;
    allPanels[i-1].BevelOuter := bvNone;

    allSplitters[i-1] := CreateSplitter('Splitter_' + IntToStr(i), aParent);
    allSplitters[i-1].AnchorSide[akRight].Control := allPanels[i-1];
  end;
end;

procedure TBuildComponent.BuildHeaderPanels;
var
  i, newPanelNumber, allPanelsSize : Integer;
  newPanels : array of TPanel;
begin
  newPanelNumber := 1;
  for i := 0 to Length(allPanels)-1 do begin
    if Pos('PanelBody_' + IntToSTr(i+1), allpanels[i].Name) > 0 then begin
      SetLength(newPanels, newPanelNumber);
      newPanels[newPanelNumber-1] := CreatePanel('PanelHeader_' + IntToStr(newPanelNumber), allPanels[i], 50);

      newPanels[newPanelNumber-1].Align := alTop;
      newPanels[newPanelNumber-1].Caption := 'PanelHeader_'+ IntToStr(newPanelNumber);
      inc(newPanelNumber);
    end;
  end;

  // keep 1 array with panels
  for i := 0 to Length(newPanels)-1 do begin
    allPanelsSize := Length(allPanels);
    SetLength(allPanels, allPanelsSize+1);
    allPanels[allPanelsSize] := newPanels[i];
    inc(allPanelsSize);
  end;

end;

procedure TBuildComponent.BuildSearchPanels;
var
  i, newPanelNumber, allPanelsSize : Integer;
  newPanels : array of TPanel;
begin
  //create search panels
  newPanelNumber := 1;

  for i := 0 to Length(allPanels)-1 do begin
    if Pos('PanelBody_' + IntToSTr(i+1), allpanels[i].Name) > 0 then begin
      SetLength(newPanels, newPanelNumber);
      newPanels[newPanelNumber-1] := CreatePanel('PanelSearch_' + IntToStr(newPanelNumber), allPanels[i], 50);
      newPanels[newPanelNumber-1].Align := alBottom;
      newPanels[newPanelNumber-1].Caption := 'Search '+ IntToStr(newPanelNumber);
      inc(newPanelNumber);
    end;
  end;

  // keep 1 array with panels
  for i := 0 to Length(newPanels)-1 do begin
    allPanelsSize := Length(allPanels);
    SetLength(allPanels, allPanelsSize+1);
    allPanels[allPanelsSize] := newPanels[i];
    inc(allPanelsSize);
  end;
end;

procedure TBuildComponent.BuildDataPanels;
var
  i, newPanelNumber, allPanelsSize : Integer;
  newPanels : array of TPanel;
begin
  newPanelNumber := 1;

  for i := 0 to Length(allPanels)-1 do begin
    if Pos('PanelBody_' + IntToSTr(i+1), allpanels[i].Name) > 0 then begin
      SetLength(newPanels, newPanelNumber);
      newPanels[newPanelNumber-1] := CreatePanel('PanelData_' + IntToStr(newPanelNumber), allPanels[i], 50);
      newPanels[newPanelNumber-1].Align := alClient;
      newPanels[newPanelNumber-1].Caption := 'PanelData_ '+ IntToStr(newPanelNumber);
      inc(newPanelNumber);
    end;
  end;

  // keep 1 array with panels
  for i := 0 to Length(newPanels)-1 do begin
    allPanelsSize := Length(allPanels);
    SetLength(allPanels, allPanelsSize+1);
    allPanels[allPanelsSize] := newPanels[i];
    inc(allPanelsSize);
  end;

  // Body panels can now be removed from the array
  for i := Length(allPanels)-1 downto 0 do begin
    if Pos('PanelBody_' + IntToSTr(i+1), allpanels[i].Name) > 0 then begin
      delete(allPanels, i,1);
    end;
  end;
end;

procedure TBuildComponent.BuildListBoxes;
var
  newListBoxes : array of TListBox;
  i, newListBox : Integer;
begin
  newListBox := 1;
  for i := 0 to Length(allPanels)-1 do begin
    if Pos('PanelData_', allpanels[i].Name) > 0 then begin
      SetLength(newListBoxes, newListBox);
      newListBoxes[newListBox-1] := CreateListBox('ListBox_' + IntToStr(newListBox), allPanels[i]);
      newListBoxes[newListBox-1].Align := alClient;
      Inc(newListBox);
    end;
  end;
end;

procedure TBuildComponent.BuildEdit;
var
  newEditboxes : array of TEdit;
  i, newEditbox : Integer;
begin
  newEditbox := 1;
  for i := 0 to Length(allPanels)-1 do begin
    if Pos('PanelSearch_', allpanels[i].Name) > 0 then begin
      SetLength(newEditboxes, newEditbox);
      newEditboxes[newEditbox-1] := CreateEdit('EditSearch_' + IntToStr(newEditbox), allPanels[i]);
      newEditboxes[newEditbox-1].Left := 8;
      newEditboxes[newEditbox-1].Top := 16;
      Inc(newEditbox);
    end;
  end;
end;

procedure TBuildComponent.BuildButtons(aCaption : String);
var
  newButtons : array of TButton;
  i, newButton : Integer;
begin
  newButton := 1;
  for i := 0 to Length(allPanels)-1 do begin
    if Pos('PanelHeader_', allpanels[i].Name) > 0 then begin
      SetLength(newButtons, newButton);
      newButtons[newButton-1] := CreateButton('ButtonNew_' + IntToStr(newButton), allPanels[i]);
      newButtons[newButton-1].Left := 8;
      newButtons[newButton-1].Top := 16;
      newButtons[newButton-1].Name := 'ButtonNew_' + IntToStr(newButton);
      newButtons[newButton-1].Caption := aCaption;
      Inc(newButton);
    end;
  end;
end;


end.

