import 'package:flutter/material.dart';
import '../models/receta_cafe.dart';
import '../models/usuario.dart';
import '../models/ingrediente.dart';
import '../models/equipo.dart';
import 'details_receta_screen.dart';
import '../models/database_helper.dart';

class MyHomePage extends StatefulWidget 
{
  MyHomePage({super.key, required this.title, required this.usuario});

  String title;
  Usuario usuario;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> 
{
  List<RecetaCafe> _recetas = [];
  List<Ingrediente> _ingredientes = []; 
  List<Equipo> _equipos = [];

  @override
  void initState() 
  {
    super.initState();
    _loadData();
  }

  // Cargar los datos necesarios (ingredientes, equipos y recetas)
  Future<void> _loadData() async 
  {
    await _loadIngredientes();
    await _loadEquipos();
    await _loadRecetas();
  }

  // Cargar ingredientes desde la base de datos
  Future<void> _loadIngredientes() async 
  {
    // Obtener ingredientes desde la base de datos
    var ingredientes = await DatabaseHelper().obtenerIngredientes();
    setState(() {
      _ingredientes = ingredientes;
    });
  }

  // Cargar equipos desde la base de datos
  Future<void> _loadEquipos() async 
  {
    // Obtener equipos desde la base de datos
    var equipos = await DatabaseHelper().obtenerEquipos();
    setState(() {
      _equipos = equipos;
    });
  }

  // Cargar recetas desde la base de datos
  Future<void> _loadRecetas() async {
    // Obtener recetas desde la base de datos
    var recetas = await DatabaseHelper().obtenerRecetas();
    
    var usuarios = await DatabaseHelper().obtenerUsuarios();
    
    var idCoffeQuest = usuarios.firstWhere((usuario) => usuario.nombre == "CoffeeQuest").id;

    // Filtrar las recetas que tienen "CoffeQuest" como creador
    var recetasFiltradas = recetas.where((receta) => receta.creadorId == idCoffeQuest).toList();
    
    setState(() {
      _recetas = recetasFiltradas;
    });
  }



  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      body: ListView.builder
      (
        itemCount: _recetas.length,
        itemBuilder: (context, index) 
        {
          final receta = _recetas[index];
          return Card
          (
            elevation: 4.0,
            margin: const EdgeInsets.all(8.0),
            child: ListTile
            (
              title: Text(receta.nombreReceta),
              subtitle: Text(receta.descripcion),
              leading: Image.asset(receta.imagen, width: 50, height: 50),
              onTap: () 
              {
                // Navegar a la pantalla de detalles de la receta
                Navigator.push
                (
                  context,
                  MaterialPageRoute
                  (
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