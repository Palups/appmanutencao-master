unit Main;
interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, MidasLib;
type
  TfMain = class(TForm)
    btDatasetLoop: TButton;
    btThreads: TButton;
    btStreams: TButton;
    procedure btDatasetLoopClick(Sender: TObject);
    procedure btStreamsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btThreadsClick(Sender: TObject);
  private
    FLogFile: String;
  public
    procedure saveToLog(pTxt: String); //salvar informacoes no log
    procedure handleException(Sender: TObject; E: Exception); //o que fazer em caso de excecao
  end;
var
  fMain: TfMain;
implementation
uses
  DatasetLoop, ClienteServidor, Threads;
{$R *.dfm}
procedure TfMain.btDatasetLoopClick(Sender: TObject);
begin
  fDatasetLoop.Show;
end;
procedure TfMain.btStreamsClick(Sender: TObject);
begin
  fClienteServidor.Show;
end;
procedure TfMain.btThreadsClick(Sender: TObject);
begin
  fThreads.Show;
end;

Procedure TfMain.FormCreate(Sender: TObject);
begin
  FLogFile := ChangeFileExt('exceptions', '.log');
  Application.onException := handleException;

  //ReportMemoryLeaksOnShutdown := True; //ver os leaks do programa apos sair
end;

procedure TfMain.handleException(Sender: TObject; E: Exception);
begin
  if TComponent(Sender) is TForm then
  begin
    saveToLog('Form: ' + TForm(Sender).Name + ' - Caption: ' + TForm(Sender).Caption);
    saveToLog('Error: ' + E.ClassName + ' - Error message: ' + E.Message);
  end
  else //mesmo que nao seja um TForm as propriedades do componente com erro serao coletadas
  begin
    saveToLog('Form: ' + TForm(Sender).Name + ' - Caption: ' + TForm(Sender).Caption);
    saveToLog('Error: ' + E.ClassName + ' - Error message: ' + E.Message);
  end;
  saveToLog('=======================================================================');
  Showmessage(E.Message);
end;

procedure TfMain.saveToLog(pTxt: String);
var
  _txtLog: TextFile;
begin
  AssignFile(_txtLog, FLogFile);
  if FileExists(FLogFile) then
      Append(_txtLog)
  else
      Rewrite(_txtLog);
  Writeln(_txtLog, FormatDateTime('dd/mm/YY hh:mm:ss - ', now) + pTxt);
  CloseFile(_txtLog);
end;

end.
