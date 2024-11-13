import 'package:coffee_quest/pages/create_receta_screen.dart';
import 'package:flutter/material.dart';
import '../models/receta_cafe.dart';
import '../models/usuario.dart';
import '../models/ingrediente.dart';
import '../models/equipo.dart';
import 'details_receta_screen.dart';
import '../models/database_helper.dart';

class RecetasScreen extends StatefulWidget {
  RecetasScreen({super.key, required this.title, required this.usuario});

  String title;
  Usuario usuario;

  @override
  State<RecetasScreen> createState() => _RecetasScreenState();
}

class _RecetasScreenState extends State<RecetasScreen> {
  List<RecetaCafe> _recetas = [];
  List<Ingrediente> _ingredientes = [];
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

  // Obtener todos los usuarios y filtrar el que es "CoffeeQuest"
  var usuarios = await DatabaseHelper().obtenerUsuarios();
  var idCoffeQuest = usuarios.firstWhere((usuario) => usuario.nombre == "CoffeeQuest").id;

  // Filtrar recetas creadas por "CoffeeQuest"
  var recetasFiltradas = recetas.where((receta) => receta.creadorId == idCoffeQuest).toList();

  // Filtrar las recetas que están en las favoritas del usuario actual
  var recetasFavoritas = widget.usuario.recetasFavoritas; // Obtener las recetas favoritas directamente

  // Filtrar las recetas que son favoritas del usuario y son de "CoffeeQuest"
  var recetasFavoritasDeCoffeeQuest = recetasFiltradas.where((receta) => recetasFavoritas.contains(receta.id)).toList();

  // Obtener recetas creadas por el usuario actual
  var recetasDelUsuario = recetas.where((receta) => receta.creadorId == widget.usuario.id).toList();

  // Combinar recetas de "CoffeeQuest" que son favoritas y las recetas del usuario
  var recetasFinal = [...recetasFavoritasDeCoffeeQuest, ...recetasDelUsuario];

  setState(() {
    _recetas = recetasFinal;
  });
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
              leading: Container(
                width: 50, // Limita el ancho
                height: 50, // Limita la altura
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8), // Opcional: bordes redondeados
                  image: DecorationImage(
                    image: AssetImage(receta.imagen),
                    fit: BoxFit.cover, // Ajusta la imagen sin distorsionarla
                  ),
                ),
              ),

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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar a la pantalla para crear una nueva receta
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CrearRecetaScreen(usuario: widget.usuario),
            ),
          );
        },
        tooltip: 'Crear nueva receta',
        child: Icon(Icons.add),
      ),
    );
  }
}
