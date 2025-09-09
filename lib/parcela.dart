class Parcela {
  int numeroParcela;
  double valorParcela;
  double juros;
  double dividaRestante;
  DateTime dataVencimento;

  Parcela({
    required this.numeroParcela,
    required this.valorParcela,
    required this.juros,
    required this.dividaRestante,
    required this.dataVencimento,
  });
}