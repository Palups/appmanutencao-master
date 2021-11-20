unit Threads;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TMyThread = class(TThread)
  private
    myThreadMemo: TMemo;
    myThreadTime: Integer;
    myThreadBar: TProgressBar;
    myThreadAux: String;
    myThreadisRunning: Boolean;
  public
    constructor Create(pMemo: TMemo; pTime: Integer; pBar: TProgressBar); reintroduce;
    procedure Execute; override;
    procedure writeToMemo; //sincronizar informacoes entre as threads com a thread principal
    procedure attBar; //metodo para sincronizar atualizacao da barra de progresso
  end;

  TfThreads = class(TForm)
    ProgressBar: TProgressBar;
    btStart: TButton;
    Edit_numThreads: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Memo: TMemo;
    Edit_tempoEspera: TEdit;
    procedure Edit_numThreadsExit(Sender: TObject);
    procedure Edit_tempoEsperaExit(Sender: TObject);
    procedure btStartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    numThreads: Integer;
    waitingTime: Integer;
    FThread: TMyThread;
  public
    { Public declarations }
  end;

var
  fThreads: TfThreads;

implementation

{$R *.dfm}

procedure TfThreads.btStartClick(Sender: TObject);
var
  i: Integer;
begin
  ProgressBar.Min := 0;
  ProgressBar.Max := numThreads * 101;

  for i := 1 to numThreads do
  begin
    FThread := TMyThread.Create(Memo, waitingTime, ProgressBar);
  end;
end;

procedure TfThreads.Edit_numThreadsExit(Sender: TObject);
begin
  numThreads := StrToInt(Edit_numThreads.Text);
end;

procedure TfThreads.Edit_tempoEsperaExit(Sender: TObject);
begin
  waitingTime := StrToInt(Edit_tempoEspera.Text);
end;

procedure TfThreads.FormActivate(Sender: TObject);
begin
  Edit_numThreads.Clear;
  Edit_tempoEspera.Clear;
  Memo.Clear;
  ProgressBar.Position := 0;
end;

procedure TfThreads.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Edit_numThreads.Text <> '' then
  begin
    if FThread.myThreadisRunning then
    begin
      Action := caNone;
      ShowMessage('Thread em execução. Por favor, aguarde.');
    end;
  end;
end;

procedure TfThreads.FormCreate(Sender: TObject);
begin
  FThread := nil;
end;




{ TMyThread }

constructor TMyThread.Create(pMemo: TMemo; pTime: Integer; pBar: TProgressBar);
begin
  inherited Create(false);

  myThreadMemo := pMemo;
  myThreadTime := pTime;
  myThreadBar := pBar;
  myThreadisRunning := true;

  FreeOnTerminate := True;
end;

procedure TMyThread.Execute;
var
  i: Integer;
  _id: TThreadID;
begin
  inherited;

  _id := GetCurrentThreadId; //coletando ID da thread
  myThreadAux := IntToStr(_id) + ' - Iniciando processamento.';
  Self.Synchronize(Self.writeToMemo); //escrevendo no memo

  while not Terminated do
  begin
    for i := 0 to 100 do
    begin
      Sleep(Random(myThreadTime)); //aguardar tempo aleatorio com valor max definido pelo usuario
      Self.Synchronize(Self.attBar); //atualizando barra de progresso
    end;

    Terminate;
  end;

  myThreadAux := IntToStr(_id) + ' - Processamento finalizado.';
  Self.Synchronize(Self.writeToMemo); //escrevendo no memo

  myThreadisRunning := false;
end;

procedure TMyThread.writeToMemo;
begin
  myThreadMemo.Lines.Add(myThreadAux);
end;

procedure TMyThread.attBar;
begin
  myThreadBar.Position := myThreadBar.Position + 1;
end;

end.
