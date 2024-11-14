import 'dart:io';
import 'package:flutter/material.dart';
import '../models/receta_cafe.dart';
import '../models/usuario.dart';
import '../models/ingrediente.dart';
import '../models/equipo.dart';
import 'details_receta_screen.dart';
import '../models/database_helper.dart';

// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title, required this.usuario});

  String title;
  Usuario usuario;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<RecetaCafe> _recetas = [];
  // ignore: unused_field
  List<Ingrediente> _ingredientes = []; 
  // ignore: unused_field
  List<Equipo> _equipos = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Cargar los datos necesarios (ingredientes, equipos y recetas)
  Future<void> _loadData() async {
    await _loadIngredientes();
    await _loadEquipos();
    await _loadRecetas();
  }

  // Cargar ingredientes desde la base de datos
  Future<void> _loadIngredientes() async {
    var ingredientes = await DatabaseHelper().obtenerIngredientes();
    setState(() {
      _ingredientes = ingredientes;
    });
  }

  // Cargar equipos desde la base de datos
  Future<void> _loadEquipos() async {
    var equipos = await DatabaseHelper().obtenerEquipos();
    setState(() {
      _equipos = equipos;
    });
  }

  // Cargar recetas desde la base de datos
  Future<void> _loadRecetas() async {
    var recetas = await DatabaseHelper().obtenerRecetas();
    var usuarios = await DatabaseHelper().obtenerUsuarios();
    
    var idCoffeQuest = usuarios.firstWhere((usuario) => usuario.nombre == "CoffeeQuest").id;

    // Filtrar las recetas que tienen "CoffeQuest" como creador
    var recetasFiltradas = recetas.where((receta) => receta.creadorId == idCoffeQuest).toList();
    
    setState(() {
      _recetas = recetasFiltradas;
    });
  }

  // Método para mostrar imagen, verificando si es de los assets o un archivo local
  Widget _mostrarImagen(String rutaImagen) {
    if (rutaImagen.startsWith('assets/')) {
      return Image.asset(
        rutaImagen,
        width: 50,  // Tamaño ajustado para miniatura
        height: 50,
        fit: BoxFit.cover,  // Ajuste para miniaturas
      );
    } else {
      return Image.file(
        File(rutaImagen),
        width: 50,  // Tamaño ajustado para miniatura
        height: 50,
        fit: BoxFit.cover,  // Ajuste para miniaturas
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _recetas.length,
        itemBuilder: (context, index) {
          final receta = _recetas[index];
          return Card(
            elevation: 4.0,
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(receta.nombreReceta),
              subtitle: Text(receta.descripcion),
              leading: _mostrarImagen(receta.imagen),
              onTap: () {
                // Navegar a la pantalla de detalles de la receta
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalleRecetaScreen(receta: receta, usuarioActual: widget.usuario),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
