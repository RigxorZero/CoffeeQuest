import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert'; // Para manejar JSON
import '../models/equipo.dart'; // Asegúrate de importar la clase Equipo

class EquipmentScreen extends StatefulWidget 
{
  const EquipmentScreen({super.key, required this.title});

  final String title;

  @override
  State<EquipmentScreen> createState() => _MyEquipmentScreenState();
}

class _MyEquipmentScreenState extends State<EquipmentScreen> 
{
  List<Equipo> _equipos = []; // Lista para almacenar los equipos

  @override
  void initState() 
  {
    super.initState();
    _loadEquipos(); // Cargar los equipos al iniciar
  }

  Future<void> _loadEquipos() async 
  {
    final String response = await rootBundle.loadString('assets/equipos.json');
    final List<dynamic> data = json.decode(response);

    setState(() 
    {
      _equipos = data.map((item) => Equipo
      (
        nombreEquipo: item['nombreEquipo'],
        tipo: item['tipo'],
        descripcion: item['descripcion'],
        imagen: item['imagen'],
      )).toList();
    });
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar
      (
        title: Text(widget.title),
      ),
      body: ListView.builder
      (
        itemCount: _equipos.length,
        itemBuilder: (context, index) 
        {
          final equipo = _equipos[index];
          return Card
          (
            elevation: 4.0,
            margin: const EdgeInsets.all(8.0),
            child: ListTile
            (
              title: Text(equipo.nombreEquipo),
              subtitle: Text(equipo.descripcion),
              leading: Image.asset(equipo.imagen, width: 50, height: 50),
            ),
          );
        },
      ),
    );
  }
}
