import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert'; // Para manejar JSON
import '../models/receta_cafe.dart';
import '../models/usuario.dart';
import '../models/ingrediente.dart';
import '../models/equipo.dart';
import 'detalle_receta_screen.dart';

class MyHomePage extends StatefulWidget 
{
  const MyHomePage({super.key, required this.title, required this.usuario});

  final String title;
  final Usuario usuario;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> 
{
  List<RecetaCafe> _recetas = [];
  List<Ingrediente> _ingredientes = []; 
  List<Equipo> _equipos = []; // Lista para almacenar los equipos

  @override
  void initState() 
  {
    super.initState();
    _loadData(); // Cargar ingredientes, equipos y recetas
  }

  // Cargar los datos necesarios (ingredientes, equipos y recetas)
  Future<void> _loadData() async 
  {
    await _loadIngredientes();
    await _loadEquipos();
    await _loadRecetas();
  }

  Future<void> _loadIngredientes() async 
  {
    final String response = await rootBundle.loadString('assets/ingredientes.json');
    final List<dynamic> data = json.decode(response);
    setState(() 
    {
      _ingredientes = data.map((item) => Ingrediente.fromJson(item)).toList();
    });
  }

  Future<void> _loadEquipos() async 
  {
    final String response = await rootBundle.loadString('assets/equipos.json');
    final List<dynamic> data = json.decode(response);
    setState(() 
    {
      _equipos = data.map((item) => Equipo.fromJson(item)).toList();
    });
  }

  Future<void> _loadRecetas() async 
  {
    final String response = await rootBundle.loadString('assets/recetas.json');
    final List<dynamic> data = json.decode(response);

    // Crear una instancia de Usuario para "CoffeeQuest"
    Usuario creador = Usuario
    (
      nombre: 'CoffeeQuest',
      email: 'coffeequest@app.com',
      metodoFavorito: 'Espresso',
      tipoGranoFavorito: 'Arábica',
      nivelMolienda: 'Medio',
      recetasFavoritas: [],
    );

    setState(() 
    {
      _recetas = data.map((item) => RecetaCafe.fromJson(item, creador, _ingredientes, _equipos)).toList();
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