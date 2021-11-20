unit ClienteServidor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Datasnap.DBClient, Data.DB,
  Vcl.Grids, Vcl.DBGrids;

type
  TServidor = class
  private
    FPath: AnsiString;
  public
    constructor Create;
    //Tipo do parâmetro não pode ser alterado
    function SalvarArquivos(AData: OleVariant): Boolean;
    function ContarArquivos(pPath: AnsiString): Integer;
  end;

  TMyThread = class(TThread)
  private
    myThreadCds: TClientDataSet;
    myThreadServer: TServidor;
  public
    constructor Create(pCds: TClientDataSet); reintroduce;
    procedure Execute; override;
  end;

  TfClienteServidor = class(TForm)
    ProgressBar: TProgressBar;
    btEnviarSemErros: TButton;
    btEnviarComErros: TButton;
    btEnviarParalelo: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btEnviarSemErrosClick(Sender: TObject);
    procedure btEnviarComErrosClick(Sender: TObject);
    procedure btEnviarParaleloClick(Sender: TObject);
  public
    procedure SetProgress(pProgress: Integer; pChoice: Boolean);
  private
    FPath: AnsiString;
    FServidor: TServidor;
    FThread: TMyThread;

    function InitDataset: TClientDataset;
  public
  end;

var
  fClienteServidor: TfClienteServidor;
  fFlagError: Boolean; //variavel para error acontecer somente no botao Enviar com Erros

const
  QTD_ARQUIVOS_ENVIAR = 100;

implementation

uses
  IOUtils;

{$R *.dfm}

procedure TfClienteServidor.btEnviarComErrosClick(Sender: TObject);
var
  cds: TClientDataset;
  i: Integer;
begin
  cds := InitDataset;
  fFlagError := true;
  ProgressBar.Position := 0;

  cds.Append;
  TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(string(FPath)); //typecasting FPath para UnicodeString, evitando warning
  cds.Post;

  for i := 0 to QTD_ARQUIVOS_ENVIAR do
  begin
    {$REGION Simulação de erro, não alterar}
    if i = (QTD_ARQUIVOS_ENVIAR/2) then
      FServidor.SalvarArquivos(NULL);
    {$ENDREGION}
  end;

  FServidor.SalvarArquivos(cds.Data);
end;

procedure TfClienteServidor.btEnviarParaleloClick(Sender: TObject);
var
  cds: TClientDataset;
begin
  cds := InitDataset;
  fFlagError := false;
  ProgressBar.Position := 0;

  cds.Append;
  TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(string(FPath)); //typecasting FPath para UnicodeString, evitando warning
  cds.Post;

  FThread := TMyThread.Create(cds);
end;

procedure TfClienteServidor.btEnviarSemErrosClick(Sender: TObject);
var
  cds: TClientDataset;
begin
  cds := InitDataset;
  fFlagError := false;
  ProgressBar.Position := 0;

  cds.Append;
  TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(string(FPath)); //typecasting FPath para UnicodeString, evitando warning
  cds.Post;

  FServidor.SalvarArquivos(cds.Data);
end;

procedure TfClienteServidor.FormCreate(Sender: TObject);
begin
  inherited;
  //IncludeTrailingBackslash alterado para IncludeTrailingPathDelimiter e typecasting para AnsiString
  FPath := AnsiString(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'pdf.pdf');

  FServidor := TServidor.Create;

  ProgressBar.Min := 0;
  ProgressBar.Max := QTD_ARQUIVOS_ENVIAR + 1;

  ProgressBar.Position := ProgressBar.Min;
end;

function TfClienteServidor.InitDataset: TClientDataset;
begin
  Result := TClientDataset.Create(nil);
  Result.FieldDefs.Add('Arquivo', ftBlob);
  Result.CreateDataSet;
end;

procedure TfClienteServidor.SetProgress(pProgress: Integer; pChoice: Boolean);
begin
  if pChoice then
    ProgressBar.Position := ProgressBar.Position + pProgress //fazer com que a barra carregue fiel ao numero de iteracoes feitas
  else
  begin
    while ProgressBar.Position > 0 do
    begin
      ProgressBar.Position := ProgressBar.Position - pProgress; //zerar barra gradativamente
    end;
  end;
end;




{ TServidor }

function TServidor.ContarArquivos(pPath: AnsiString): Integer;
var
  searchRec: TSearchRec;
  _fileCount: Integer;
begin
  _fileCount := 0;

  //typecasting pPath para UnicodeString (warning)
  if FindFirst(string(pPath) + '*.pdf', faAnyFile and not faDirectory, searchRec) = 0 then
  begin
    Inc(_fileCount);

    while FindNext(SearchRec) = 0 do
    begin
      Inc(_fileCount);
    end;
  end;

  FindClose(searchRec);

  Result := _fileCount;
end;

constructor TServidor.Create;
begin
  FPath := AnsiString(ExtractFilePath(ParamStr(0)) + 'Servidor\'); //typecasting para AnsiString (warning)
end;

function TServidor.SalvarArquivos(AData: OleVariant): Boolean;
var
  cds: TClientDataSet;
  FileName: string;
  i, j: Integer;
  _names: array of String;
begin
  try
    if not DirectoryExists(string(FPath)) then //warning
      ForceDirectories(string(FPath)); //warning

    cds := TClientDataset.Create(nil);
    cds.Data := AData;

    if cds.Data = NULL then
    begin
      Result := False;
      Exit;
    end;

    {$REGION Simulação de erro, não alterar}
    if cds.RecordCount = 0 then
    begin
      Result := False; //warning
      Exit;
    end;
    {$ENDREGION}

    cds.First;

    for i := 0 to QTD_ARQUIVOS_ENVIAR do
    begin
      SetLength(_names, i+1);
      _names[i] := IntToStr(i+1);

      //------------------------- devido a alteracoes feitas para funcionar a Correcao 2, criei este erro para poder testar a Correcao 3
      if fFlagError then
      begin
        {$REGION Simulação de erro para botao Enviar com Erros -- Criado por: Vinicius Palu}
          if i = (QTD_ARQUIVOS_ENVIAR/2) then FileName := '' else FileName := '.';
        {$ENDREGION}
      end
      else
        FileName := '.';
      //--------------------------

      if FileName <> '' then
      begin
        FileName := string(FPath) + (i+1).ToString + '.pdf'; //warning
        if TFile.Exists(FileName) then
          TFile.Delete(FileName);

        fClienteServidor.SetProgress(1, true); //incrementar 1 para cima na barra de progresso
        TBlobField(cds.FieldByName('Arquivo')).SaveToFile(FileName);
      end
      else
      begin
        Result := False;

        //rollback nos arquivos em caso de erro
        if ContarArquivos(FPath) <> 0 then
        begin
          for j := 0 to ContarArquivos(FPath) do
          begin
            DeleteFile(string(FPath) + _names[j] + '.pdf'); //warning
          end;

          fClienteServidor.SetProgress(1, false); //decrementar 1 ate barra chegar a zero
        end;

        Exit;
      end;
    end;

    Result := True;
  except
    //Result := False; //hint
    raise;
  end;
end;



{ TMyThread }

constructor TMyThread.Create(pCds: TClientDataSet);
begin
  inherited Create(false);

  myThreadCds := pCds;

  FreeOnTerminate := True;
end;

procedure TMyThread.Execute;
begin
  inherited;

  myThreadServer := TServidor.Create;

  while not Terminated do
  begin
    myThreadServer.SalvarArquivos(myThreadCds.Data);
    Terminate;
  end;
end;

end.
