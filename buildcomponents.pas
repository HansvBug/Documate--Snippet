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
      function CreateButtonNew(aName : String; aParent : TWinControl) : TButton;
      function CreateButtonNext(aName : String; aParent : TWinControl) : TButton;

      procedure SetArrays;

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
      procedure BuildLabel;

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
      end
      else if Pos('ButtonNext_' , _button.Name) > 0 then begin
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

  for i := mainForm.ComponentCount -1 downto 0 do begin
    if mainForm.Components[i] is TLabel then begin
      _label :=  TLabel(mainForm.Components[i]);
      if Pos('LabelSearchResult_' , _label.Name) > 0 then begin
        _label.Free;
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
  _panel.BevelInner := bvNone;
  _panel.BevelOuter := bvNone;
  result := _panel;
end;

function TBuildComponent.CreateSplitter(aName: String; aParent: TWinControl
  ): TSplitter;
begin
   _splitter := TSplitter.Create(mainForm);
   _splitter.Parent := aParent;
   _splitter.Name := aName;
   //_splitter.MinSize := 30;
   _splitter.Width := 10;
   _splitter.Left := 9999;
   result := _splitter;
end;

function TBuildComponent.CreateEdit(aName: String; aParent: TWinControl): TEdit;
begin
  _edit := TEdit.Create(mainForm);
  _edit.Visible := False;
  _edit.Parent := aParent;
  _edit.Name := aName;
  _edit.Height := 28;  // Default height
  _edit.Width := 100;  // Default with;
  _edit.OnChange := @Form_Main.Frm_main.EditOnChange; //
  result := _edit;
end;

function TBuildComponent.CreateLabel(aName: String; aParent: TWinControl
  ): TLabel;
begin
  _label := TLabel.Create(mainForm);
  _label.Visible := False;
  _label.Parent := aParent;
  _label.Name := aName;
  result := _label;
end;

function TBuildComponent.CreateListBox(aName: String; aParent: TWinControl
  ): TListBox;
begin
  _listbox := TListBox.Create(mainForm);
  _listbox.Parent := aParent;
  _listbox.Name := aName;
  _listbox.OnClick := @Form_Main.Frm_main.ListBoxOnClick;
  _listBox.OnSelectionChange := @Form_Main.Frm_main.ListBoxOnSelectionChange;
  _listbox.OnDblClick := @Form_Main.Frm_main.ListBoxOnDblClick;
  _listbox.OnMouseDown := @Form_Main.Frm_main.ListBoxOnMouseDown;
  _listbox.OnKeyDown := @Form_Main.Frm_main.ListBoxOnKeyDown;
  result := _listbox;
end;

function TBuildComponent.CreateButtonNew(aName: String; aParent: TWinControl
  ): TButton;
begin
  _button := TButton.Create(mainForm);
  _button.Visible := False;
  _button.Parent := aParent;
//  _button.Name := aName;
  _button.Height := 31;  // Default height
  _button.Width := 50;   // modified
  _button.OnClick :=  @Form_Main.Frm_main.ButtonNewOnClick; //
  result := _button;
end;

function TBuildComponent.CreateButtonNext(aName: String; aParent: TWinControl
  ): TButton;
begin
  _button := TButton.Create(mainForm);
  _button.Parent := aParent;
  _button.OnClick :=  @Form_Main.Frm_main.ButtonNextOnClick; //
  result := _button;
end;

procedure TBuildComponent.BuildBodyPanelsAndSplitters(aParent: TWinControl);
var
  i : Integer;
begin
  SetArrays;

  if aParent.Name =  'ScrollBoxMainColumn' then begin
    allPanels[0] := CreatePanel('PanelBody_' + IntToStr(1), aParent, 200);
    allPanels[0].Align := alClient;
    allPanels[0].BorderStyle := bsSingle;
    allPanels[0].Color := clSkyBlue;
  end
  else if aParent.Name =  'ScrollBoxColumns' then begin
    for i := 2 to NumberOfColumns do begin
      allPanels[i-1] := CreatePanel('PanelBody_' + IntToStr(i), aParent, 200);
      allPanels[i-1].AnchorSide[akLeft].Control := aParent;
      allPanels[i-1].Align := alLeft;
      allPanels[i-1].BorderStyle := bsSingle;

      if i = NumberOfColumns then begin // build 1 splitter less and align the last panel allClient
        allPanels[i-1].Align := alClient;
        break;
      end;

      allSplitters[i-1] := CreateSplitter('Splitter_' + IntToStr(i), aParent);
      allSplitters[i-1].Align := alLeft;
      allSplitters[i-1].AnchorSide[akLeft].Control := allPanels[i-1];
    end;
  end;
end;

procedure TBuildComponent.BuildHeaderPanels;
var
  i, newPanelNumber, allPanelsSize : Integer;
  newPanels : array of TPanel = nil;
begin
  newPanelNumber := 1;
  for i := 0 to Length(allPanels)-1 do begin
    if Pos('PanelBody_' + IntToSTr(i+1), allpanels[i].Name) > 0 then begin
      SetLength(newPanels, newPanelNumber);
      newPanels[newPanelNumber-1] := CreatePanel('PanelHeader_' + IntToStr(newPanelNumber), allPanels[i], 50);

      newPanels[newPanelNumber-1].Align := alTop;
      newPanels[newPanelNumber-1].Caption := '';
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
  newPanels : array of TPanel = nil;
begin
  //create search panels
  newPanelNumber := 1;

  for i := 0 to Length(allPanels)-1 do begin
    if Pos('PanelBody_' + IntToSTr(i+1), allpanels[i].Name) > 0 then begin
      SetLength(newPanels, newPanelNumber);
      newPanels[newPanelNumber-1] := CreatePanel('PanelSearch_' + IntToStr(newPanelNumber), allPanels[i], 50);
      newPanels[newPanelNumber-1].Align := alBottom;
      // newPanels[newPanelNumber-1].Caption := 'Search '+ IntToStr(newPanelNumber);
      newPanels[newPanelNumber-1].Caption := '';
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
      SetLength({%H-}newPanels, newPanelNumber);{%H+}
      newPanels[newPanelNumber-1] := CreatePanel('PanelData_' + IntToStr(newPanelNumber), allPanels[i], 50);
      newPanels[newPanelNumber-1].Align := alClient;
      // newPanels[newPanelNumber-1].Caption := 'PanelData_ '+ IntToStr(newPanelNumber);
      newPanels[newPanelNumber-1].Caption := '';
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
  newListBoxes : array of TListBox = nil;
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
  newEditboxes : array of TEdit = nil;
  i, newEditbox : Integer;
begin
  newEditbox := 1;
  for i := 0 to Length(allPanels)-1 do begin
    if Pos('PanelSearch_', allpanels[i].Name) > 0 then begin
      SetLength(newEditboxes, newEditbox);
      newEditboxes[newEditbox-1] := CreateEdit('EditSearch_' + IntToStr(newEditbox), allPanels[i]);
      newEditboxes[newEditbox-1].Left := 8;
      newEditboxes[newEditbox-1].Top := 16;
      newEditboxes[newEditbox-1].Text := '';
      newEditboxes[newEditbox-1].TextHint := 'Search item';  { #todo : Optioneel maken }
      newEditboxes[newEditbox-1].Anchors := [TAnchorKind.akLeft, TAnchorKind.akRight];

      if newEditbox-1 > 0 then newEditboxes[newEditbox-1].Visible := False else  // For now only the first listbox has search function
        newEditboxes[newEditbox-1].Visible := True;
      Inc(newEditbox);
    end;
  end;
end;

procedure TBuildComponent.BuildButtons(aCaption : String);
var
  newButtons : array of TButton = nil;
  i, newButton : Integer;
begin
  if aCaption = 'New' then begin
    newButton := 1;
    for i := 0 to Length(allPanels)-1 do begin
      if Pos('PanelHeader_', allpanels[i].Name) > 0 then begin
        SetLength(newButtons, newButton);
        newButtons[newButton-1] := CreateButtonNew('ButtonNew_' + IntToStr(newButton), allPanels[i]);
        newButtons[newButton-1].Left := 8;
        newButtons[newButton-1].Top := 16;
        newButtons[newButton-1].Name := 'ButtonNew_' + IntToStr(newButton);
        newButtons[newButton-1].Caption := aCaption;
        newButtons[newButton-1].Anchors := [TAnchorKind.akLeft];
        newButtons[newButton-1].Visible := True;
        Inc(newButton);
      end;
    end;
  end
  else if aCaption = 'Next' then begin
    newButton := 1;
    newButtons := nil;
    for i := 0 to Length(allPanels)-1 do begin
      if Pos('PanelSearch_', allpanels[i].Name) > 0 then begin
        SetLength(newButtons, newButton);
        newButtons[newButton-1] := CreateButtonNext('ButtonNext_' + IntToStr(newButton), allPanels[i]);
        newButtons[newButton-1].Left := 160;
        newButtons[newButton-1].Top := 16;
        newButtons[newButton-1].Width := 30;
        newButtons[newButton-1].Height := 28;
        newButtons[newButton-1].Name := 'ButtonNext_' + IntToStr(newButton);
        newButtons[newButton-1].Caption := '>';
        newButtons[newButton-1].Anchors := [TAnchorKind.akRight];
        if newButton-1 > 0 then newButtons[newButton-1].Visible := False else  // For now only the first listbox has search function
          newButtons[newButton-1].Visible := True;
        Inc(newButton);
      end;
    end;
  end;
end;

procedure TBuildComponent.BuildLabel;
var
  newlabels : array of TLAbel = nil;
  i, newLabel : Integer;
begin
  newLabel := 1;
  for i := 0 to Length(allPanels)-1 do begin
    if Pos('PanelSearch_', allpanels[i].Name) > 0 then begin
      SetLength(newlabels, newLabel);
      newlabels[newLabel-1] := CreateLabel('LabelSearchResult_' + IntToStr(newLabel), allPanels[i]);
      newlabels[newLabel-1].Left := 140;
      newlabels[newLabel-1].Top := 16;
      newlabels[newLabel-1].Caption := 'st';
      newlabels[newLabel-1].Anchors := [TAnchorKind.akRight];
      if newLabel-1 > 0 then newlabels[newLabel-1].Visible := False else  // For now only the first listbox has search function
        newlabels[newLabel-1].Visible := True;
      Inc(newLabel);
    end;
  end;
end;


end.

