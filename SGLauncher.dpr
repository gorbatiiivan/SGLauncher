program SGLauncher;



{$R *.dres}

uses
  WinApi.Windows,
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {MainForm},
  FullScreenImage in 'FullScreenImage.pas' {FullScreenForm},
  DialogForm in 'DialogForm.pas' {DiagForm},
  Help in 'Help.pas' {HelpForm};

{$R *.res}
{$SETPEFLAGS IMAGE_FILE_RELOCS_STRIPPED} //Удаление из exe таблицы релокаций.

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TFullScreenForm, FullScreenForm);
  Application.CreateForm(TDiagForm, DiagForm);
  Application.CreateForm(THelpForm, HelpForm);
  Application.Run;
end.
