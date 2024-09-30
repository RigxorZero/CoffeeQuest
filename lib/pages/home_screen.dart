import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert'; // Para manejar JSON // Asegúrate de importar la clase Equipo
import '../models/ingrediente.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Ingrediente> _ingredientes = []; // Lista para almacenar los ingredientes

  @override
  void initState() {
    super.initState();
    _loadIngredientes();
    
  }

  Future<void> _loadIngredientes() async {
    final String response = await rootBundle.loadString('assets/ingredientes.json');
    final List<dynamic> data = json.decode(response);

    setState(() {
      _ingredientes = data.map((item) => Ingrediente(
        nombreIngrediente: item['nombreIngrediente'],
        unidadMedida: item['unidadMedida'],
        cantidad: item['cantidad'], // Esto ahora será "0"
      )).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: _ingredientes.length,
        itemBuilder: (context, index) {
          final ingrediente = _ingredientes[index];
          return Card(
            elevation: 4.0,
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(ingrediente.nombreIngrediente),
              subtitle: Text('${ingrediente.cantidad} ${ingrediente.unidadMedida}'),
            ),
          );
        },
      ),
    );
  }
}
