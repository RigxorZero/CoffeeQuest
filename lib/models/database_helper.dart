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
  static final columnVecesPreparada = 'vecesPreparada';
  static final columnImagen = 'imagen';
  static final columnCreadorId = 'creadorId';
  static final columnElaboracion = 'elaboracion';

  var logger = Logger();

  Future<Database> get database async 
  {
    if (_database != null) 
    {
      return _database!;
    }

    try 
    {
      _database = await _initDatabase();
      return _database!;
    } catch (e) 
    {
      rethrow;
    }
  }


  // Inicializa la base de datos
  Future<Database> _initDatabase() async 
  {
    String path = await getDatabasesPath();
    String dbPath = join(path, 'coffeQuest.db');
    return await openDatabase
    (
      dbPath,
      version: 5, // Actualiza la versión a 2 si es necesario migrar cambios
      onCreate: _onCreate,
    );
  }

  // Método para crear las tablas en la base de datos
  Future<void> _onCreate(Database db, int version) async 
  {
    // Tabla para las recetas
    await db.execute
    ('''
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
      fechaCreacion TEXT,
      FOREIGN KEY (equipoNecesario) REFERENCES equipos(id)
    )

''');

    // Tabla para los ingredientes
    await db.execute
    ('''
      CREATE TABLE ingredientes(
        ingredienteId INTEGER PRIMARY KEY AUTOINCREMENT,
        nombreIngrediente TEXT,
        unidadMedida TEXT
      )
    ''');

    // Tabla intermedia para la relación muchos-a-muchos entre recetas e ingredientes
    await db.execute
    ('''
      CREATE TABLE receta_ingredientes(
        recetaId INTEGER,
        ingredienteId INTEGER,
        cantidad TEXT,
        FOREIGN KEY (recetaId) REFERENCES recetas(id),
        FOREIGN KEY (ingredienteId) REFERENCES ingredientes(ingredienteId),
        PRIMARY KEY (recetaId, ingredienteId)
      )
    ''');

    // Tabla para los equipos
    await db.execute
    ('''
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
    await db.execute
    ('''
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

    String jsonStringEquipos = await rootBundle.loadString('assets/equipos.json');
    List<dynamic> jsonResponseEquipos = json.decode(jsonStringEquipos);

    // Insertar los datos del JSON en la tabla 'equipos'
    for (var item in jsonResponseEquipos) 
    {
      await db.insert
      (
        'equipos',
        {
          'nombreEquipo': item['nombreEquipo'],
          'tipo': item['tipo'],
          'descripcion': item['descripcion'],
          'imagen': item['imagen'],
          'enlacesCompra': json.encode(item['enlacesCompra']),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    String jsonStringIngredientes = await rootBundle.loadString('assets/ingredientes.json');
    List<dynamic> jsonResponseIngredientes = json.decode(jsonStringIngredientes);

    for (var item in jsonResponseIngredientes) 
    {
      await db.insert
      (
        'ingredientes',
        {
          'nombreIngrediente': item['nombreIngrediente'],
          'unidadMedida': item['unidadMedida'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    String jsonStringRecetas = await rootBundle.loadString('assets/recetas.json');
    List<dynamic> jsonResponseRecetas = json.decode(jsonStringRecetas);

    for (var item in jsonResponseRecetas) 
    {
      // Insertar la receta
      int recetaId = await db.insert
      (
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
          'elaboracion': json.encode(item['elaboracion']),
          'equipoNecesario': item['equipoNecesario'][0]['idEquipo'],
          'fechaCreacion': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insertar los ingredientes relacionados con la receta
      for (var ingrediente in item['ingredientes']) 
      {
        await db.insert
        (
          'receta_ingredientes',
          {
            'recetaId': recetaId,
            'ingredienteId': ingrediente['ingredienteId'],
            'cantidad': ingrediente['cantidad'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }

  // Método para insertar un usuario en la base de datos
  Future<int> insertarUsuario(Usuario usuario) async 
  {
    var db = await database;
    int userId = await db.insert
    (
      'usuarios',
      usuario.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Retornar el ID generado
    return userId;
  }

  // Método para incrementar el contador de veces que una receta ha sido preparada
  Future<void> incrementarVecesPreparada(int recetaId) async 
  {
    var db = await database;
    var result = await db.query(
      'recetas',
      columns: ['vecesPreparada'],
      where: 'id = ?',
      whereArgs: [recetaId],
    );

    if (result.isNotEmpty) 
    {
      int vecesPreparada = result.first['vecesPreparada'] as int;
      vecesPreparada += 1;
      await db.update
      (
        'recetas',
        {'vecesPreparada': vecesPreparada},
        where: 'id = ?',
        whereArgs: [recetaId],
      );
    }
  }


  // Método para actualizar una receta en la base de datos
  Future<void> updateReceta(int recetaId, RecetaCafe recetaActualizada) async 
  {
    var db = await database;
    var logger = Logger();

    try 
    {
      await db.update
      (
        'recetas',
        {
          columnNombreReceta: recetaActualizada.nombreReceta,
          columnDescripcion: recetaActualizada.descripcion,
          columnMetodo: recetaActualizada.metodo,
          columnDificultad: recetaActualizada.dificultad,
          columnTiempoPreparacion: recetaActualizada.tiempoPreparacion,
          columnImagen: recetaActualizada.imagen,
          columnVecesPreparada: recetaActualizada.vecesPreparada,
          columnElaboracion: jsonEncode(recetaActualizada.elaboracion),
          columnEquipoNecesario: recetaActualizada.equipoNecesarioId,
          'fechaCreacion': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [recetaId],
      );

      await db.delete
      (
        'receta_ingredientes',
        where: 'recetaId = ?',
        whereArgs: [recetaId],
      );
      for (var ingrediente in recetaActualizada.ingredientes) 
      {
        await db.insert
        (
          'receta_ingredientes',
          {
            'recetaId': recetaId,
            'ingredienteId': ingrediente.ingredienteId,
            'cantidad': ingrediente.cantidad,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      logger.i("Receta con ID $recetaId actualizada exitosamente.");
    } catch (e) 
    {
      logger.e("Error al actualizar la receta con ID $recetaId: $e");
      rethrow;
    }
  }



  Future<void> insertarIngredienteReceta(int recetaId, int ingredienteId, String cantidad, String unidadMedida) async 
  {
    var db = await database;
    await db.insert
    (
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
    var resultado = await db.query('ingredientes');
    
    return List.generate(resultado.length, (i) 
    {
      return Ingrediente.fromMap(resultado[i]);
    });
  }


  Future<List<Ingrediente>> obtenerIngredientesPorReceta(int recetaId) async 
  {
    final db = await database;
    var result = await db.rawQuery
    ('''
      SELECT 
        ingredientes.*, 
        receta_ingredientes.cantidad AS cantidad
      FROM 
        ingredientes 
      JOIN 
        receta_ingredientes 
      ON 
        ingredientes.ingredienteId = receta_ingredientes.ingredienteId 
      WHERE 
        receta_ingredientes.recetaId = ?
    ''', [recetaId]);

    List<Ingrediente> ingredientes = [];
    for (var item in result) 
    {
      ingredientes.add(Ingrediente
      (
        ingredienteId: item['ingredienteId'] as int,
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
    var resultado = await db.query('equipos');

    return List.generate(resultado.length, (i) 
    {
      return Equipo.fromMap(resultado[i]);
    });
  }

  Future<Equipo?> obtenerEquipoPorId(int equipoId) async 
  {
    final db = await database;
    var result = await db.query('equipos', where: 'id = ?', whereArgs: [equipoId]);
    if (result.isNotEmpty) 
    {
      return Equipo
      (
        id: result[0]['id'] as int,
        nombreEquipo: result[0]['nombreEquipo'] as String,
        descripcion: result[0]['descripcion'] as String,
        tipo: result[0]['tipo'] as String,
        imagen: result[0]['imagen'] as String,
        enlacesCompra: (result[0]['enlacesCompra'] as String).split(',').toList(),
      );
    } else 
    {
      return null;
    }
  }

  Future<int?> obtenerEquipoIdPorNombre(String nombreEquipo) async 
  {
    var db = await database;
    var result = await db.query
    (
      'equipos',
      where: 'nombreEquipo = ?',
      whereArgs: [nombreEquipo],
    );

    if (result.isNotEmpty) 
    {
      return result.first['id'] as int;
    }

    return null;
  }

  // Método para obtener todas las recetas
  Future<List<RecetaCafe>> obtenerRecetas() async 
  {
    var db = await database;
    var resultado = await db.query('recetas');
    return List.generate(resultado.length, (i) 
    {
      return RecetaCafe.fromMap(resultado[i]);
    });
  }

  // Método para obtener el valor máximo del ID en la tabla 'recetas'
  Future<int> obtenerMaxRecetaId() async 
  {
    var db = await database;
    var result = await db.rawQuery('SELECT MAX(id) FROM recetas');
    return result.isNotEmpty && result.first['MAX(id)'] != null
        ? result.first['MAX(id)'] as int
        : 0;
  }

  Future<List<RecetaCafe>> obtenerRecetasPorIds(List<int> ids) async 
  {
    try 
    {
      var db = await database;
      String idsString = ids.join(',');
      List<Map<String, dynamic>> result = await db.rawQuery
      (''' 
        SELECT * FROM Recetas WHERE id IN ($idsString)
      ''');

      logger.i("Recetas obtenidas: $result");
      return result.map((map) => RecetaCafe.fromMap(map)).toList();
    } catch (e) {
      logger.e("Error al obtener recetas por IDs: $e");
      rethrow;
    }
  }

  Future<RecetaCafe?> obtenerRecetaPorId(int id) async 
  {
    try 
    {
      var db = await database;
      List<Map<String, dynamic>> result = await db.query
      (
        'recetas',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (result.isNotEmpty) 
      {
        return RecetaCafe.fromMap(result.first);
      } else 
      {
        return null;
      }
    } catch (e) 
    {
      logger.e("Error al obtener receta por ID: $e");
      rethrow;
    }
  }

  // Método para actualizar las preferencias de un usuario
  Future<void> updateUsuario(Usuario usuario) async 
  {
    var db = await database;
    // Actualiza las preferencias del usuario
    await db.update
    (
      'usuarios',
      usuario.toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  // Método para eliminar una receta de la base de datos
  Future<void> eliminarReceta(int recetaId) async 
  {
    var db = await database;
    try 
    {
      await db.delete
      (
        'receta_ingredientes',
        where: 'recetaId = ?',
        whereArgs: [recetaId],
      );
      await db.delete
      (
        'recetas',
        where: 'id = ?',
        whereArgs: [recetaId],
      );
      logger.i("Receta con ID $recetaId eliminada exitosamente.");
    } catch (e) 
    {
      logger.e("Error al eliminar la receta con ID $recetaId: $e");
      rethrow;
    }
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
  Future<int> insertReceta(RecetaCafe receta) async 
  {
    var db = await database;

    // Convertir la lista de ingredientes a Map y luego a JSON
    List<Map<String, dynamic>> ingredientesMap = receta.ingredientes.map((ingrediente) => ingrediente.toMap()).toList();

    Map<String, dynamic> row = 
    {
      columnNombreReceta: receta.nombreReceta,
      columnDescripcion: receta.descripcion,
      columnIngredientes: jsonEncode(ingredientesMap), // Si es lista, la conviertes a String
      columnMetodo: receta.metodo,
      columnEquipoNecesario: receta.equipoNecesarioId,
      columnDificultad: receta.dificultad,
      columnTiempoPreparacion: receta.tiempoPreparacion,
      columnVecesPreparada: receta.vecesPreparada,
      columnImagen: receta.imagen,
      columnCreadorId: receta.creadorId,
      columnElaboracion: jsonEncode(receta.elaboracion),
      'fechaCreacion': DateTime.now().toIso8601String(),
    };

    // Insertar la receta y capturar el ID generado
    int recetaId = await db.insert('recetas', row);

    // Asignar el ID generado a la receta
    receta.id = recetaId;

    return recetaId;
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
    var logger = Logger();
    var resultado = await db.query
    (
      'receta_ingredientes',
      where: 'recetaId = ?',
      whereArgs: [recetaId],
    );

    if (resultado.isEmpty) 
    {
      logger.i("No se encontraron ingredientes para la receta con ID $recetaId.");
      return [];
    }

    List<Ingrediente> ingredientes = [];
    for (var item in resultado) 
    {
      logger.i("RecetaIngrediente encontrado: ingredienteId = ${item['ingredienteId']}");

      var ingrediente = await db.query
      (
        'ingredientes',
        where: 'id = ?',
        whereArgs: [item['ingredienteId']],
      );

      if (ingrediente.isNotEmpty) 
      {
        ingredientes.add(Ingrediente.fromMap(ingrediente.first));
        logger.i("Ingrediente encontrado: ${ingrediente.first['nombreIngrediente']}");
      } else 
      {
        logger.w("Ingrediente con ID ${item['ingredienteId']} no encontrado.");
      }
    }
    return ingredientes;
  }

  // Método para obtener todos los registros de la tabla 'receta_ingredientes' para validar
  Future<List<Map<String, dynamic>>> obtenerTodosRecetaIngredientes() async 
  {
    var db = await database;
    var resultado = await db.query('receta_ingredientes');
    return resultado;
  }
}
