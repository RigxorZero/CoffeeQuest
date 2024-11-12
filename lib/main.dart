import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'dart:convert'; // Para manejar JSON
import 'pages/splash_screen.dart'; // Importar SplashScreen
import 'pages/session_screen.dart'; // Importar SessionScreen
import 'pages/tab_bar.dart'; // Importar TabBarController
import 'models/usuario.dart'; // Asegúrate de importar Usuario
import 'models/database_helper.dart'; // Si necesitas trabajar con la base de datos
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Función para eliminar la base de datos
Future<void> eliminarBaseDeDatos() async {
  // Obtén la ruta de la base de datos
  String path = join(await getDatabasesPath(), 'coffeQuest.db');
  
  // Elimina la base de datos
  await deleteDatabase(path);
  
  print("Base de datos eliminada.");
}


void main() async
{
  WidgetsFlutterBinding.ensureInitialized();

  //await eliminarBaseDeDatos();

  // Inicializa la base de datos
  var dbHelper = DatabaseHelper();
  var db = await dbHelper.database;

  // Verifica las tablas de la base de datos
  await verificarTablasExistentes(db);

  // Verifica las recetas de la base de datos
  await verificarRecetasExistentes(dbHelper);

  runApp(const MyApp());

  // Crea un usuario por defecto
  Usuario usuarioPorDefecto = Usuario(
    nombre: 'CoffeeQuest',
    email: 'coffeequest@app.com',
    metodoFavorito: 'Espresso',
    tipoGranoFavorito: 'Arábica',
    nivelMolienda: 'Medio',
    recetasFavoritas: [1],
  );

  bool usuarioExistente = await verificarUsuarioExistente(dbHelper);
  if (!usuarioExistente) 
  {
    await dbHelper.insertarUsuario(usuarioPorDefecto);
  }
}

Future<void> verificarTablasExistentes(Database db) async 
{
  var result = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table';");
  var logger = Logger();

  if (result.isNotEmpty) {
    logger.i("Tablas existentes en la base de datos:");
    for (var table in result) {
      logger.i("Tabla: ${table['name']}");
    }
  } else {
    logger.i("No hay tablas en la base de datos.");
  }
}


Future<void> verificarRecetasExistentes(DatabaseHelper dbHelper) async {
  // Recuperar las recetas de la base de datos
  var recetas = await dbHelper.obtenerRecetas();  // Este método debe recuperar la lista de recetas desde la base de datos.
  var logger = Logger();

  // Imprime los datos de las recetas obtenidas
  if (recetas.isNotEmpty) {
    logger.i("Recetas encontradas en la base de datos:");
    for (var receta in recetas) {
      // Mostrar la información básica de la receta
      logger.i("ID: ${receta.id}");
      logger.i("Nombre de la receta: ${receta.nombreReceta}");
      logger.i("Descripción: ${receta.descripcion}");
      logger.i("Método: ${receta.metodo}");
      logger.i("Dificultad: ${receta.dificultad}");
      logger.i("Tiempo de preparación: ${receta.tiempoPreparacion}");
      logger.i("Imagen: ${receta.imagen}");
      logger.i("Veces preparada: ${receta.vecesPreparada}");
      logger.i("Elaboración: ${receta.elaboracion.join(', ')}");  // Convertir la lista de elaboración desde JSON
      
      // Obtener ingredientes asociados con la receta
      var ingredientes = await dbHelper.obtenerIngredientesPorReceta(receta.id!);
      if (ingredientes.isNotEmpty) {
        logger.i("Ingredientes:");
        for (var ingrediente in ingredientes) {
          logger.i(" - ${ingrediente.nombreIngrediente}: ${ingrediente.cantidad}");
        }
      } else {
        logger.i("No se encontraron ingredientes para esta receta.");
      }
      
      // Obtener el equipo necesario para la receta
      var equipo = await dbHelper.obtenerEquipoPorId(receta.equipoNecesarioId);
      if (equipo != null) {
        logger.i("Equipo necesario: ${equipo.nombreEquipo}");  // Muestra el nombre del equipo necesario
        logger.i("Descripción del equipo: ${equipo.descripcion}");
      } else {
        logger.i("No se encontró el equipo necesario para esta receta.");
      }
      
      logger.i("---------------------------"); // Separador entre recetas
    }
  } else {
    logger.i("No hay recetas en la base de datos.");
  }
}




// Verifica si el usuario ya existe en la base de datos
  Future<bool> verificarUsuarioExistente(DatabaseHelper dbHelper) async {
    var usuarios = await dbHelper.obtenerUsuarios();
    var logger = Logger();

    // Imprime los datos de los usuarios obtenidos
    if (usuarios.isNotEmpty) {
      logger.i("Usuarios encontrados en la base de datos:");
      for (var usuario in usuarios) {
        logger.i("Nombre: ${usuario.id}");
        logger.i("Nombre: ${usuario.nombre}");
        logger.i("Email: ${usuario.email}");
        logger.i("Método favorito: ${usuario.metodoFavorito}");
        logger.i("Tipo de grano favorito: ${usuario.tipoGranoFavorito}");
        logger.i("Nivel de molienda: ${usuario.nivelMolienda}");
        logger.i("Recetas favoritas: ${usuario.recetasFavoritas}");
      }
      return true;
    } else {
      logger.i("No hay usuarios en la base de datos.");
      return false;
    }
  }


class MyApp extends StatelessWidget 
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) 
  {
    var logger = Logger();
    logger.i("Logger is working!");

    return MaterialApp
    (
      title: 'Coffee Quest',
      theme: ThemeData
      (
        fontFamily: 'Aurora',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 54, 32, 21)),
        useMaterial3: true,
      ),
      initialRoute: '/',  // Ruta inicial
      routes: 
      {
        '/': (context) => const SplashScreen(),
        '/session': (context) => const SessionScreen(title: 'Inicio sesión'),
        '/home': (context) => const TabBarController(),
      },
    );
  }
}
