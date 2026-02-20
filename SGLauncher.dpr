program SGLauncher;



{$R *.dres}

uses
  WinApi.Windows,
  Winapi.Messages,
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  Unit1 in 'Unit1.pas' {SGLMainForm},
  FullScreenImage in 'FullScreenImage.pas' {FullScreenForm},
  DialogForm in 'DialogForm.pas' {DiagForm},
  Help in 'Help.pas' {HelpForm},
  ToolBtnProperties in 'ToolBtnProperties.pas' {ToolBtnPropertiesForm};

{$R *.res}
{$SETPEFLAGS IMAGE_FILE_RELOCS_STRIPPED} //Удаление из exe таблицы релокаций.

const
  MUTEX_NAME = 'Global\StartGameLauncher_SingleInstance_Mutex';
var
  hMutex: THandle;
  hWnd: WinApi.Windows.HWND;
  cds: TCopyDataStruct;
begin
  //Запрещаем открытие больше одного экземпляра
  hMutex := CreateMutex(nil, True, MUTEX_NAME);

  if (hMutex = 0) or (GetLastError = ERROR_ALREADY_EXISTS) then
  begin
    // Ищем окно по имени VCL класса формы
    hWnd := FindWindow('TSGLMainForm', nil);

    if hWnd <> 0 then
    begin
      cds.dwData := 1;
      cds.cbData := 0;
      cds.lpData := nil;

      SendMessage(hWnd, WM_COPYDATA, 0, LPARAM(@cds));
    end;

    Exit;
  end;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  //TStyleManager.TrySetStyle('Windows11 Impressive Dark');
  Application.CreateForm(TSGLMainForm, SGLMainForm);
  Application.CreateForm(TFullScreenForm, FullScreenForm);
  Application.CreateForm(TDiagForm, DiagForm);
  Application.CreateForm(THelpForm, HelpForm);
  Application.CreateForm(TToolBtnPropertiesForm, ToolBtnPropertiesForm);
  Application.Run;

  if hMutex <> 0 then
    CloseHandle(hMutex);
end.
