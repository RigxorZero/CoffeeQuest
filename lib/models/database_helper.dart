import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'usuario.dart';
import 'ingrediente.dart';
import 'receta_cafe.dart';
import 'equipo.dart';

class DatabaseHelper 
{
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  // Constructor privado
  DatabaseHelper._internal();

  static final columnId = '_id';
  static final columnNombreReceta = 'nombreReceta';
  static final columnDescripcion = 'descripcion';
  static final columnIngredientes = 'ingredientes';
  static final columnMetodo = 'metodo';
  static final columnEquipoNecesario = 'equipoNecesario';
  static final columnDificultad = 'dificultad';
  static final columnTiempoPreparacion = 'tiempoPreparacion';
  static final columnImagen = 'imagen';
  static final columnElaboracion = 'elaboracion';

  var logger = Logger();

  Future<Database> get database async {
    // Usamos logger en lugar de print
    logger.i("Intentando obtener la base de datos...");

    if (_database != null) {
      logger.i("Base de datos ya inicializada");
      return _database!;
    }

    try {
      logger.i("Inicializando la base de datos...");
      _database = await _initDatabase();
      logger.i("Base de datos inicializada correctamente");
      return _database!;
    } catch (e) {
      logger.e("Error al inicializar la base de datos: $e");
      rethrow;
    }
  }


  // Inicializa la base de datos
  Future<Database> _initDatabase() async 
  {
    String path = await getDatabasesPath();
    String dbPath = join(path, 'coffeQuest.db');
    return await openDatabase(
      dbPath,
      version: 5, // Actualiza la versión a 2 si es necesario migrar cambios
      onCreate: _onCreate,
    );
  }

  // Método para crear las tablas en la base de datos
  Future<void> _onCreate(Database db, int version) async 
  {
    // Tabla para las recetas
    await db.execute('''
      CREATE TABLE recetas(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombreReceta TEXT,
      descripcion TEXT,
      metodo TEXT,
      dificultad TEXT,
      tiempoPreparacion INTEGER,
      imagen TEXT,
      creadorId INTEGER,
      vecesPreparada INTEGER,
      elaboracion TEXT,  -- Almacenar como cadena JSON
      ingredientes TEXT,  -- Almacenar como cadena JSON
      equipoNecesario INTEGER,
      FOREIGN KEY (equipoNecesario) REFERENCES equipos(id)
    )

''');


    // Tabla para los ingredientes
    await db.execute('''
      CREATE TABLE ingredientes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombreIngrediente TEXT,
        cantidad TEXT,
        unidadMedida TEXT
      )
    ''');

    // Tabla intermedia para la relación muchos-a-muchos entre recetas e ingredientes
    await db.execute('''
      CREATE TABLE receta_ingredientes(
        recetaId INTEGER,
        ingredienteId INTEGER,
        cantidad TEXT,
        unidadMedida TEXT,
        FOREIGN KEY (recetaId) REFERENCES recetas(id),
        FOREIGN KEY (ingredienteId) REFERENCES ingredientes(id),
        PRIMARY KEY (recetaId, ingredienteId)
      )
    ''');

    // Tabla para los equipos
    await db.execute('''
      CREATE TABLE equipos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombreEquipo TEXT,
        tipo TEXT,
        descripcion TEXT,
        imagen TEXT,
        enlacesCompra TEXT  -- Almacenar como cadena JSON
      )
    ''');

    // Tabla para los usuarios
    await db.execute('''
      CREATE TABLE usuarios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        email TEXT,
        metodoFavorito TEXT,
        tipoGranoFavorito TEXT,
        nivelMolienda TEXT,
        recetasFavoritas TEXT  -- Almacenar como cadena JSON
      )
    ''');

    // Tabla intermedia para las recetas favoritas de los usuarios
    await db.execute('''
      CREATE TABLE usuario_recetas_favoritas(
        usuarioId INTEGER,
        recetaId INTEGER,
        FOREIGN KEY (usuarioId) REFERENCES usuarios(id),
        FOREIGN KEY (recetaId) REFERENCES recetas(id)
      )
    ''');

    String jsonStringEquipos = await rootBundle.loadString('assets/equipos.json');
    List<dynamic> jsonResponseEquipos = json.decode(jsonStringEquipos);

    // Insertar los datos del JSON en la tabla 'equipos'
    for (var item in jsonResponseEquipos) {
      await db.insert(
        'equipos',
        {
          'nombreEquipo': item['nombreEquipo'],
          'tipo': item['tipo'],
          'descripcion': item['descripcion'],
          'imagen': item['imagen'],
          'enlacesCompra': json.encode(item['enlacesCompra']),  // Convertimos la lista en String JSON
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    String jsonStringIngredientes = await rootBundle.loadString('assets/ingredientes.json');
    List<dynamic> jsonResponseIngredientes = json.decode(jsonStringIngredientes);

    // Insertar los datos del JSON en la tabla 'equipos'
    for (var item in jsonResponseIngredientes) {
      await db.insert(
        'ingredientes',
        {
          'nombreIngrediente': item['nombreIngrediente'],
          'unidadMedida': item['unidadMedida'],
          'cantidad': item['cantidad'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // Cargar las recetas desde el archivo JSON
    String jsonStringRecetas = await rootBundle.loadString('assets/recetas.json');
    List<dynamic> jsonResponseRecetas = json.decode(jsonStringRecetas);

    for (var item in jsonResponseRecetas) {
      // Insertar la receta
      int recetaId = await db.insert(
        'recetas',
        {
          'nombreReceta': item['nombreReceta'],
          'descripcion': item['descripcion'],
          'metodo': item['metodo'],
          'dificultad': item['dificultad'],
          'tiempoPreparacion': item['tiempoPreparacion'],
          'imagen': item['imagen'],
          'creadorId': 1,
          'vecesPreparada': item['vecesPreparada'],
          'elaboracion': json.encode(item['elaboracion']), // Convertir la lista en JSON
          'equipoNecesario': item['equipoNecesario'][0]['idEquipo'], // Asumimos que solo hay un equipo
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insertar los ingredientes relacionados con la receta
      for (var ingrediente in item['ingredientes']) {
        await db.insert(
          'receta_ingredientes',
          {
            'recetaId': recetaId,
            'ingredienteId': ingrediente['ingredienteId'],
            'cantidad': ingrediente['cantidad'],
            'unidadMedida': ingrediente['unidadMedida'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }

  // Método para insertar un usuario en la base de datos
  Future<void> insertarUsuario(Usuario usuario) async 
  {
    var db = await database;
    await db.insert
    (
      'usuarios',
      usuario.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, 
    );
  }

  Future<void> insertarIngredienteReceta(int recetaId, int ingredienteId, String cantidad, String unidadMedida) async {
  var db = await database;
  await db.insert(
    'receta_ingredientes',
    {
      'recetaId': recetaId,
      'ingredienteId': ingredienteId,
      'cantidad': cantidad,
      'unidadMedida': unidadMedida, 
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

  // Método para obtener todos los usuarios
  Future<List<Usuario>> obtenerUsuarios() async 
  {
    var db = await database;
    var resultado = await db.query('usuarios');
    return List.generate(resultado.length, (i) 
    {
      return Usuario.fromMap(resultado[i]);
    });
  }

  Future<List<Ingrediente>> obtenerIngredientes() async 
  {
    var db = await database;

    // Consultar todos los ingredientes en la base de datos
    var resultado = await db.query('ingredientes');
    
    // Convertir los resultados a una lista de objetos Ingrediente
    return List.generate(resultado.length, (i) 
    {
      return Ingrediente.fromMap(resultado[i]);
    });
  }

  Future<List<Ingrediente>> obtenerIngredientesPorReceta(int recetaId) async 
  {
    final db = await database;
    var result = await db.rawQuery('''
      SELECT ingredientes.id AS idIngrediente, ingredientes.nombreIngrediente, 
             receta_ingredientes.cantidad, receta_ingredientes.unidadMedida
      FROM receta_ingredientes
      JOIN ingredientes ON receta_ingredientes.ingredienteId = ingredientes.id
      WHERE receta_ingredientes.recetaId = ?
    ''', [recetaId]);

    List<Ingrediente> ingredientes = [];
    for (var item in result) {
      ingredientes.add(Ingrediente(
        id: item['idIngrediente'] as int,
        nombreIngrediente: item['nombreIngrediente'] as String,
        cantidad: item['cantidad'] as String,
        unidadMedida: item['unidadMedida'] as String,
      ));
    }
    return ingredientes;
}



  // Método para obtener todos los equipos
  Future<List<Equipo>> obtenerEquipos() async 
  {
    var db = await database;

    // Consultar todos los equipos en la base de datos
    var resultado = await db.query('equipos');

    // Convertir los resultados a una lista de objetos Equipo
    return List.generate(resultado.length, (i) 
    {
      return Equipo.fromMap(resultado[i]);
    });
  }

  Future<Equipo?> obtenerEquipoPorId(int equipoId) async 
  {
    final db = await database;
    var result = await db.query('equipos', where: 'id = ?', whereArgs: [equipoId]);

    if (result.isNotEmpty) {
      return Equipo(
        id: result[0]['id'] as int,
        nombreEquipo: result[0]['nombreEquipo'] as String,
        descripcion: result[0]['descripcion'] as String,
        tipo: result[0]['tipo'] as String,
        imagen: result[0]['imagen'] as String,
        // Usar split para separar los enlaces si están guardados en una cadena separada por comas
        enlacesCompra: (result[0]['enlacesCompra'] as String).split(',').toList(),
      );
    } else {
      return null;
    }
  }




  // Método para obtener todas las recetas
  Future<List<RecetaCafe>> obtenerRecetas() async 
  {
    var db = await database;

    // Obtener todas las recetas de la tabla 'recetas'
    var resultado = await db.query('recetas');

    // Convertir las filas de la base de datos en una lista de objetos RecetaCafe
    return List.generate(resultado.length, (i) {
      return RecetaCafe.fromMap(resultado[i]);
    });
  }

  Future<List<RecetaCafe>> obtenerRecetasPorIds(List<int> ids) async {
    try {
      var db = await database;
      
      // Preparamos la consulta
      String idsString = ids.join(','); // Convertimos los IDs en un formato de cadena para la consulta
      List<Map<String, dynamic>> result = await db.rawQuery(''' 
        SELECT * FROM Recetas WHERE id IN ($idsString)
      ''');

      // Mapear los resultados a objetos RecetaCafe
      logger.i("Recetas obtenidas: $result");
      return result.map((map) => RecetaCafe.fromMap(map)).toList();
    } catch (e) {
      logger.e("Error al obtener recetas por IDs: $e");
      rethrow; // Vuelve a lanzar la excepción
    }
  }



// Método para actualizar las preferencias de un usuario
Future<void> updateUsuario(Usuario usuario) async 
{
  var db = await database;

  // Actualiza las preferencias del usuario
  await db.update(
    'usuarios',
    usuario.toMap(),
    where: 'id = ?',
    whereArgs: [usuario.id],
  );
}


  // Método para obtener un usuario por su Nombre
  Future<Usuario?> obtenerUsuario(String nombre) async 
  {
    var db = await database;
    
    // Buscar el usuario por su ID
    var resultado = await db.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [nombre]
    );
    
    if (resultado.isNotEmpty) 
    {
      return Usuario.fromMap(resultado.first);
    }
    
    return null;
  }

  // Insertar receta en la base de datos
  Future<int> insertReceta(RecetaCafe receta) async {
    var db = await database;

    Map<String, dynamic> row = {
      columnNombreReceta: receta.nombreReceta,
      columnDescripcion: receta.descripcion,
      columnIngredientes: receta.ingredientes.join(', '), // Si es lista, la conviertes a String
      columnMetodo: receta.metodo,
      columnEquipoNecesario: receta.equipoNecesarioId,
      columnDificultad: receta.dificultad,
      columnTiempoPreparacion: receta.tiempoPreparacion,
      columnImagen: receta.imagen,
      columnElaboracion: receta.elaboracion.join(', '), // También si es lista
    };

    return await db.insert('recetas', row);
  }

  

  // Método para obtener un usuario por su Nombre
  Future<Usuario?> obtenerUsuarioID(int id) async 
  {
    var db = await database;
    
    // Buscar el usuario por su ID
    var resultado = await db.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id]
    );
    
    if (resultado.isNotEmpty) 
    {
      return Usuario.fromMap(resultado.first);
    }
    
    return null;
  }

  // Método para obtener los ingredientes de una receta por su ID
  Future<List<Ingrediente>> obtenerIngredientesDeReceta(int recetaId) async 
  {
    var db = await database;
    
    // Obtener los ingredientes relacionados con la receta
    var resultado = await db.query(
      'receta_ingredientes',
      where: 'recetaId = ?',
      whereArgs: [recetaId],
    );
    
    List<Ingrediente> ingredientes = [];
    for (var item in resultado) {
      // Obtener los datos del ingrediente
      var ingrediente = await db.query
      (
        'ingredientes',
        where: 'id = ?',
        whereArgs: [item['ingredienteId']],
      );
      
      ingredientes.add(Ingrediente.fromMap(ingrediente.first));
    }
    
    return ingredientes;
  }
}
