import 'package:flutter/material.dart';
import 'package:prova1/parcela.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exercicio 1 da Prova 1',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Simulador Financiamento'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController totalController = TextEditingController();
  TextEditingController entradaController = TextEditingController();
  TextEditingController jurosController = TextEditingController();
  TextEditingController parcelasController = TextEditingController();
  DateTime? dataVencimento;
  List<Parcela> parcelas = [];

  Future<void> _selecionarData() async {
    final DateTime? data_escolhida = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now().add(const Duration(days: 30)),
      lastDate: DateTime(2101),
    );
    if (data_escolhida != null && data_escolhida != dataVencimento) {
      setState(() {
        dataVencimento = data_escolhida;
      });
    }
  }

  Widget criarParcela(int idx) {
    Parcela p = parcelas[idx];
    ListTile item = ListTile(title: generateView(p), );
    return item;
  }

  Widget generateView(Parcela p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Parcela nº ${p.numeroParcela} vence em ${p.dataVencimento}"),
        Row(
          children: [
            Expanded(child: Text("Parcela: ${p.valorParcela.toStringAsFixed(2)}")),
            Text("Juros: ${p.juros.toStringAsFixed(2)}"),
            const SizedBox(width: 10),
            Text("Total: ${p.dividaRestante.toStringAsFixed(2)}"),
          ],
        ),
      ],
    );
  }

  void _showMessage(String msg, int time) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg),
            duration: Duration(seconds: time))
    );
  }

  void _limpar() {
    setState(() {
      totalController.text = "";
      entradaController.text = "";
      jurosController.text = "";
      parcelasController.text = "";
      dataVencimento = null;
      parcelas = [];
    });
  }

  void _calcular() {
    if (totalController.text.isEmpty || entradaController.text.isEmpty ||
        jurosController.text.isEmpty || parcelasController.text.isEmpty ||
        dataVencimento == null) {
      _showMessage("Por favor, preencha todos os campos.", 3);
      return;
    }

    try {
      double total = double.parse(totalController.text);
      double entrada = double.parse(entradaController.text);
      double jurosMensal = double.parse(jurosController.text) / 100;
      int numParcelas = int.parse(parcelasController.text);

      if (total <= 0 || entrada < 0 || jurosMensal < 0 || numParcelas <= 0) {
        _showMessage("Valores numéricos inválidos. Apenas juros pode ser 0.", 4);
        return;
      }

      double saldoDevedor = total - entrada;
      double valorPrincipalParcela = saldoDevedor / numParcelas;
      List<Parcela> tempParcelas = [];
      DateTime dataAtual = dataVencimento!;

      for (int i = 1; i <= numParcelas; i++) {
        double jurosDaParcela = saldoDevedor * jurosMensal;
        double valorTotalParcela = valorPrincipalParcela + jurosDaParcela;

        dataAtual = DateTime(dataAtual.year, dataAtual.month + 1, dataAtual.day);

        saldoDevedor -= valorPrincipalParcela;

        tempParcelas.add(
          Parcela(
            numeroParcela: i,
            valorParcela: valorTotalParcela,
            juros: jurosDaParcela,
            dividaRestante: saldoDevedor > 0 ? saldoDevedor : 0,
            dataVencimento: dataAtual,
          ),
        );
      }

      setState(() {
        parcelas = tempParcelas;
      });

    } catch (e) {
      _showMessage("Por favor, insira valores numéricos válidos.", 3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 🔹 Use Expanded/Flexible só onde precisa crescer
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: totalController,
                      decoration: const InputDecoration(
                        labelText: "Valor Total (R\$)",
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: entradaController,
                      decoration: const InputDecoration(
                        labelText: "Entrada (R\$)",
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: jurosController,
                      decoration: const InputDecoration(
                        labelText: "Juros (%)",
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: parcelasController,
                      decoration: const InputDecoration(
                        labelText: "Parcelas",
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  IconButton(
                    onPressed: _selecionarData,
                    icon: const Icon(Icons.date_range_sharp),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _calcular,
                    icon: const Icon(Icons.check),
                    label: const Text("Calcular"),
                  ),
                  ElevatedButton.icon(
                    onPressed: _limpar,
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text("Limpar"),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // 🔹 Lista ocupa o restante da tela
              Expanded(
                child: ListView.builder(
                  itemCount: parcelas.length,
                  itemBuilder: (ctx, idx) => criarParcela(idx),
                ),
              ),
            ],
          ),
        )
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
