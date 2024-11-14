import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'pages/splash_screen.dart';
import 'pages/session_screen.dart';
import 'pages/tab_bar.dart';
import 'models/usuario.dart';
import 'models/database_helper.dart';
import 'package:sqflite/sqflite.dart';

// Función para eliminar la base de datos
Future<void> eliminarBaseDeDatos() async 
{
  // Elimina la base de datos
  //await deleteDatabase(path);
}

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();

  await eliminarBaseDeDatos();

  // Inicializa la base de datos
  var dbHelper = DatabaseHelper();
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

  verificarRecetasExistentes(dbHelper);

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

// Ejemplo de uso de la función para verificar los registros de receta_ingredientes con Logger
void verificarRecetaIngredientes() async {
  var logger = Logger();
  var dbHelper = DatabaseHelper();
  var ingredientes = await dbHelper.obtenerTodosRecetaIngredientes();
  
  // Mostrar los resultados usando el logger
  if (ingredientes.isNotEmpty) {
    for (var ingrediente in ingredientes) {
      logger.i('RecetaId: ${ingrediente['recetaId']}, IngredienteId: ${ingrediente['ingredienteId']}');
    }
  } else {
    logger.i("No hay registros en la tabla receta_ingredientes.");
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
      return true;
    } else {
      logger.i("No hay usuarios en la base de datos.");
      return false;
    }
  }

  // Verifica los ingredientes de una receta en la base de datos
Future<bool> verificarIngredientesPorReceta(int recetaId, DatabaseHelper dbHelper) async {
  var ingredientes = await dbHelper.obtenerIngredientesDeReceta(recetaId);
  var logger = Logger();

  // Imprime los datos de los ingredientes obtenidos
  if (ingredientes.isNotEmpty) {
    logger.i("Ingredientes encontrados para la receta con ID $recetaId:");
    for (var ingrediente in ingredientes) {
      logger.i("ID Ingrediente: ${ingrediente.ingredienteId}");
      logger.i("Nombre Ingrediente: ${ingrediente.nombreIngrediente}");
      logger.i("Cantidad: ${ingrediente.cantidad}");
      logger.i("Unidad de medida: ${ingrediente.unidadMedida}");
    }
    return true;
  } else {
    logger.i("No se encontraron ingredientes para la receta con ID $recetaId.");
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
