import 'dart:io';
import 'package:coffee_quest/pages/create_receta_screen.dart';
import 'package:flutter/material.dart';
import '../models/receta_cafe.dart';
import '../models/usuario.dart';
import '../models/ingrediente.dart';
import '../models/equipo.dart';
import 'details_receta_screen.dart';
import '../models/database_helper.dart';

// ignore: must_be_immutable
class RecetasScreen extends StatefulWidget 
{
  RecetasScreen({super.key, required this.title, required this.usuario});

  String title;
  Usuario usuario;

  @override
  State<RecetasScreen> createState() => _RecetasScreenState();
}

class _RecetasScreenState extends State<RecetasScreen> 
{
  List<RecetaCafe> _recetas = [];
  // ignore: unused_field
  List<Ingrediente> _ingredientes = [];
  // ignore: unused_field
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
    var ingredientes = await DatabaseHelper().obtenerIngredientes();
    setState(() 
    {
      _ingredientes = ingredientes;
    });
  }

  // Cargar equipos desde la base de datos
  Future<void> _loadEquipos() async 
  {
    var equipos = await DatabaseHelper().obtenerEquipos();
    setState(() 
    {
      _equipos = equipos;
    });
  }

  // Cargar recetas desde la base de datos
  Future<void> _loadRecetas() async 
  {
    var recetas = await DatabaseHelper().obtenerRecetas();

    // Obtener todos los usuarios y filtrar el que es "CoffeeQuest"
    var usuarios = await DatabaseHelper().obtenerUsuarios();
    var idCoffeQuest = usuarios.firstWhere((usuario) => usuario.nombre == "CoffeeQuest").id;

    // Filtrar recetas creadas por "CoffeeQuest"
    var recetasFiltradas = recetas.where((receta) => receta.creadorId == idCoffeQuest).toList();

    // Filtrar las recetas que están en las favoritas del usuario actual
    var recetasFavoritas = widget.usuario.recetasFavoritas;

    var recetasFavoritasDeCoffeeQuest = recetasFiltradas.where((receta) => recetasFavoritas.contains(receta.id)).toList();

    var recetasDelUsuario = recetas.where((receta) => receta.creadorId == widget.usuario.id).toList();

    var recetasFinal = [...recetasFavoritasDeCoffeeQuest, ...recetasDelUsuario];

    setState(() 
    {
      _recetas = recetasFinal;
    });
  }

  // Método para mostrar imagen, verificando si es de los assets o un archivo local
  Widget _mostrarImagen(String rutaImagen) 
  {
    if (rutaImagen.startsWith('assets/')) 
    {
      return Image.asset
      (
        rutaImagen,
        width: 50,  // Tamaño ajustado para miniatura
        height: 50,
        fit: BoxFit.cover,  // Ajuste para miniaturas
      );
    } else 
    {
      return Image.file
      (
        File(rutaImagen),
        width: 50,  // Tamaño ajustado para miniatura
        height: 50,
        fit: BoxFit.cover,  // Ajuste para miniaturas
      );
    }
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
              leading: _mostrarImagen(receta.imagen),
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
              onLongPress: () async 
              {
                // Verificar si el usuario es el creador de la receta
                if (receta.creadorId == widget.usuario.id) 
                {
                  // Mostrar un diálogo de confirmación
                  bool confirmDelete = await _mostrarConfirmacionEliminar(context);
                  if (confirmDelete) 
                  {
                    await DatabaseHelper().eliminarReceta(receta.id!);

                    setState(() 
                    {
                      _recetas.removeAt(index);
                    });
                  }
                } else 
                {
                  ScaffoldMessenger.of(context).showSnackBar
                  (
                    SnackBar(content: Text('No puedes eliminar recetas que no creaste.')),
                  );
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton
      (
        onPressed: () 
        {
          // Navegar a la pantalla para crear una nueva receta
          Navigator.push
          (
            context,
            MaterialPageRoute
            (
              builder: (context) => CrearRecetaScreen(usuario: widget.usuario),
            ),
          );
        },
        tooltip: 'Crear nueva receta',
        child: Icon(Icons.add),
      ),
    );
  }

  // Método para mostrar un diálogo de confirmación de eliminación
  Future<bool> _mostrarConfirmacionEliminar(BuildContext context) async 
  {
    return await showDialog<bool>
    (
      context: context,
      builder: (BuildContext context) 
      {
        return AlertDialog
        (
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar esta receta?'),
          actions: <Widget>
          [
            TextButton
            (
              child: Text('Cancelar'),
              onPressed: () 
              {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton
            (
              child: Text('Eliminar'),
              onPressed: () 
              {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ) ?? false;
  }
}
