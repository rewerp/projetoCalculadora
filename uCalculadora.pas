unit uCalculadora;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.StdCtrls;

type
  TfrmCalculadora = class(TForm)
    btnSete: TSpeedButton;
    btnOito: TSpeedButton;
    btnNove: TSpeedButton;
    btnQuatro: TSpeedButton;
    btnCinco: TSpeedButton;
    btnSeis: TSpeedButton;
    btnUm: TSpeedButton;
    btnDois: TSpeedButton;
    btnTres: TSpeedButton;
    btnZero: TSpeedButton;
    btnVirgula: TSpeedButton;
    btnFatorial: TSpeedButton;
    btnMultiplicacao: TSpeedButton;
    btnIgual: TSpeedButton;
    btnSoma: TSpeedButton;
    btnSubtracao: TSpeedButton;
    btnDivisao: TSpeedButton;
    btnApagar: TSpeedButton;
    btnLimpar: TSpeedButton;
    edtPainel: TEdit;
    edtEntradaValor: TEdit;
    lbVersao: TLabel;
    procedure NumeroClick(Sender: TObject);
    procedure btnLimparClick(Sender: TObject);
    procedure OperacaoClick(Sender: TObject);
    procedure btnVirgulaClick(Sender: TObject);
    procedure btnApagarClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    Valor1, Valor2: double;
    Resultado: double;
    Operacao, EstadoNumero, EstadoOperacao: integer;

    procedure DigitarNumero(ANumero: String);
    procedure AtribuirValor(ANumero: String);
    procedure AtribuirOperacao(AOperacao: integer);
    function Calcular(AValor1, AValor2: double; AOperacao: integer): double;
    function CalcularFatorial(AValorFatorial: integer): double;
  public
    { Public declarations }
  end;

function GetVersaoAplicacao: string;

var
  frmCalculadora: TfrmCalculadora;

implementation

uses
  System.StrUtils;

{$R *.dfm}

function GetVersaoAplicacao: string;
var
   LVerInfoSize: DWORD;
   LVerInfo: Pointer;
   LVerValueSize: DWORD;
   LVerValue: PVSFixedFileInfo;
   LHandle: DWORD;
begin
   LVerInfoSize := GetFileVersionInfoSize(PChar(ParamStr(0)), LHandle);
   GetMem(LVerInfo, LVerInfoSize);
   GetFileVersionInfo(PChar(ParamStr(0)), 0, LVerInfoSize, LVerInfo);
   VerQueryValue(LVerInfo, '\', Pointer(LVerValue), LVerValueSize);

   with LVerValue^ do
   begin
      Result := IntToStr(dwFileVersionMS shr 16);
      Result := Result + '.' + IntToStr(dwFileVersionMS and $FFFF);
      Result := Result + '.' + IntToStr(dwFileVersionLS shr 16);
      Result := Result + '.' + IntToStr(dwFileVersionLS and $FFFF);
   end;

   //FreeMem(LVerInfo, LVerInfoSize);
end;

function TfrmCalculadora.Calcular(AValor1, AValor2: double;
  AOperacao: integer): double;
begin
  Result := 0;

  case AOperacao of
    1: Result := AValor1 + AValor2;
    2: Result := AValor1 - AValor2;
    3: Result := AValor1 * AValor2;
    4:
    begin
      if (AValor2 <> 0) then
        Result := AValor1 / AValor2;
    end;
  end;
end;

function TfrmCalculadora.CalcularFatorial(AValorFatorial: integer): double;
begin
  if (AValorFatorial = 0) then
     CalcularFatorial := 1
  else
     CalcularFatorial := AValorFatorial * CalcularFatorial(AValorFatorial - 1);
end;

procedure TfrmCalculadora.AtribuirValor(ANumero: string);
begin
	case EstadoNumero of
    0:
    begin
      DigitarNumero(ANumero);
      Valor1 := StrToFloat(edtEntradaValor.Text);
    end;
    1:
    begin
      if (EstadoOperacao = 0) then
      begin
        edtEntradaValor.Clear;
        EstadoOperacao := 1;
      end;
      DigitarNumero(ANumero);
      Valor2 := StrToFloat(edtEntradaValor.Text);
    end;
  end;
end;

procedure TfrmCalculadora.AtribuirOperacao(AOperacao: integer);
const
  SOMA = 1;
  SUBTRACAO = 2;
  MULTIPLICACAO = 3;
  DIVISAO = 4;
  FATORIAL = 5;
  IGUAL = 6;
var
  LSimboloTag: string;
begin
  case AOperacao of
    SOMA:  LSimboloTag := ' + ';
    SUBTRACAO:  LSimboloTag := ' - ';
    MULTIPLICACAO:  LSimboloTag := ' × ';
    DIVISAO:  LSimboloTag := ' ÷ ';
    FATORIAL:  LSimboloTag := ' ! ';
    IGUAL:  LSimboloTag := ' = ';
  end;

	case EstadoOperacao of
    0:
    begin
      if (AOperacao = FATORIAL) then
      begin
        Resultado := CalcularFatorial(Trunc(Valor1));
        edtEntradaValor.Text := Resultado.ToString;
        EstadoOperacao := 1;
      end
      else
        begin
        if (EstadoNumero = 0) then
          edtPainel.Text := edtPainel.Text + Valor1.ToString + LSimboloTag
        else
          edtPainel.Text := Copy(edtPainel.Text, 0, Length(edtPainel.Text) - 3) + LSimboloTag;
      end;
    end;
    1:
    begin
      edtPainel.Text := edtPainel.Text + Valor2.ToString + LSimboloTag;
      Resultado := Calcular(Valor1, Valor2, Operacao);
      edtEntradaValor.Text := Resultado.ToString;
      Valor1 := Resultado;
      EstadoOperacao := 0;
    end;
  end;

  Operacao := AOperacao;
  EstadoNumero := 1;
end;

procedure TfrmCalculadora.DigitarNumero(ANumero: String);
begin
  if (edtEntradaValor.Text = '0') then
    edtEntradaValor.Text := ANumero
  else
    edtEntradaValor.Text := edtEntradaValor.Text + ANumero;
end;

procedure TfrmCalculadora.btnApagarClick(Sender: TObject);
begin
  if (Length(edtEntradaValor.Text) > 1) then
    edtEntradaValor.Text := Copy(edtEntradaValor.Text, 0, Length(edtEntradaValor.Text) - 1)
  else
    edtEntradaValor.Text := '0'
end;

procedure TfrmCalculadora.btnLimparClick(Sender: TObject);
begin
  edtEntradaValor.Text := '0';
  edtPainel.Clear;
  Valor1 := 0;
  Valor2 := 0;
  Resultado := 0;
  Operacao := 0;
  EstadoNumero := 0;
  EstadoOperacao := 0;
end;

procedure TfrmCalculadora.NumeroClick(Sender: TObject);
begin
  AtribuirValor(TButton(Sender).Caption);
end;

procedure TfrmCalculadora.btnVirgulaClick(Sender: TObject);
begin
  if (edtEntradaValor.Text = '') then
    edtEntradaValor.Text := '0';
  if (Pos(',', edtEntradaValor.Text) = 0) then
    edtEntradaValor.Text := edtEntradaValor.Text + ',';
end;

procedure TfrmCalculadora.OperacaoClick(Sender: TObject);
begin
  AtribuirOperacao(TButton(Sender).Tag);
end;

procedure TfrmCalculadora.FormCreate(Sender: TObject);
begin
   lbVersao.Caption := 'versão ' + GetVersaoAplicacao() + '.23092021.1738';
end;

procedure TfrmCalculadora.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    27                     : btnLimpar.Click();  {ESC}
    VK_BACK                : btnApagar.Click();
    VK_RETURN              : btnIgual.Click();
    VK_NUMPAD0..VK_NUMPAD9 : AtribuirValor(IntToStr(key-96));
    VK_MULTIPLY            : btnMultiplicacao.Click();
    VK_ADD                 : btnSoma.Click();
    VK_SUBTRACT            : btnSubtracao.Click();
    VK_DIVIDE              : btnDivisao.Click();
    VK_DECIMAL             : btnVirgula.Click();
    VK_OEM_COMMA           : btnVirgula.Click();
    VK_OEM_PERIOD          : btnVirgula.Click();
    194                    : btnVirgula.Click();  {NUM PONTO}
  end;
end;

end.
