program Documate;

{$mode objfpc}{$H+}

uses
  Interfaces, // this includes the LCL widgetset
  lcltranslator,
  Forms, Settings, DataModule, Form_Main, BuildComponents, 
form_new_db_config, Form_Maintain,
  AppDbItems, AppDbMaintainItems, AppDb, Form_Configure, AppDbCreate
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TFrm_main, Frm_main);
  Application.CreateForm(TDataModule1, DataModule1);
  Application.Run;
end.

