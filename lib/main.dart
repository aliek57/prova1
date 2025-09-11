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
        useMaterial3: true,
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
  TextEditingController dataController = TextEditingController();
  DateTime? dataVencimento;
  List<Parcela> parcelas = [];

  Future<void> _selecionarData() async {
    final DateTime? data_escolhida = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (data_escolhida != null && data_escolhida != dataVencimento) {
      setState(() {
        dataVencimento = data_escolhida;
        dataController.text = "${dataVencimento!.day.toString().padLeft(2, '0')}/${dataVencimento!.month.toString().padLeft(2, '0')}/${dataVencimento!.year}";
      });
    }
  }

  Widget criarParcela(int idx) {
    Parcela p = parcelas[idx];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Parcela nº ${p.numeroParcela} vence em ${p.dataVencimento!.day.toString().padLeft(2, '0')}/${p.dataVencimento!.month.toString().padLeft(2, '0')}/${p.dataVencimento!.year}",
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Parcela: R\$ ${p.valorParcela!.toStringAsFixed(2)}"),
              Text("Juros: R\$ ${p.juros!.toStringAsFixed(2)}"),
              Text("Total: R\$ ${p.totalParcela!.toStringAsFixed(2)}"),
            ],
          ),
        ],
      ),
    );
  }

  void _showMessage(String msg, int time) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: Duration(seconds: time),
      ),
    );
  }

  void _limpar() {
    setState(() {
      totalController.clear();
      entradaController.clear();
      jurosController.clear();
      parcelasController.clear();
      dataController.clear();
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
        _showMessage("Valores numéricos inválidos.", 4);
        return;
      }

      double saldoDevedor = total - entrada;
      double valorPrincipalParcela = (total - entrada) / numParcelas;
      List<Parcela> tempParcelas = [];
      DateTime dataAtual = dataVencimento!;

      for (int i = 1; i <= numParcelas; i++) {
        double jurosDaParcela = saldoDevedor * jurosMensal;
        double valorTotalParcela = valorPrincipalParcela + jurosDaParcela;

        dataAtual = DateTime(dataAtual.year, dataAtual.month + 1, dataAtual.day);

        tempParcelas.add(
          Parcela(
            numeroParcela: i,
            valorParcela: valorPrincipalParcela,
            juros: jurosDaParcela,
            totalParcela: valorTotalParcela,
            dataVencimento: dataAtual,
          ),
        );
        saldoDevedor -= valorPrincipalParcela;
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
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: totalController,
                          decoration: const InputDecoration(labelText: "Valor Total (R\$)"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: entradaController,
                          decoration: const InputDecoration(labelText: "Entrada (R\$)"),
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
                          decoration: const InputDecoration(labelText: "Juros (%)"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: parcelasController,
                          decoration: const InputDecoration(labelText: "Parcelas"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: dataController, // Adicionado o novo TextField
                                decoration: const InputDecoration(
                                  labelText: "1ª Parcela",
                                ),
                                readOnly: true, // Impede que o usuário digite
                              ),
                            ),
                            IconButton(
                              onPressed: _selecionarData,
                              icon: const Icon(Icons.calendar_month),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _calcular,
                  icon: const Icon(Icons.check),
                  label: const Text("Calcular"),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: _limpar,
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text("Limpar"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: parcelas.length,
                  itemBuilder: (ctx, idx) => criarParcela(idx),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}