import 'package:coffee_quest/models/ingrediente.dart';
import 'package:coffee_quest/pages/home_screen.dart';
import 'package:coffee_quest/pages/tab_bar.dart';
import 'package:flutter/material.dart';
import '../models/database_helper.dart';
import '../models/receta_cafe.dart';
import '../models/usuario.dart';
import '../pages/details_receta_screen.dart';
import 'package:sqflite/sqflite.dart';

class EditarRecetaScreen extends StatefulWidget {
  final RecetaCafe receta;
  final Usuario usuarioActual;

  const EditarRecetaScreen({super.key, required this.receta, required this.usuarioActual});

  @override
  _EditarRecetaScreenState createState() => _EditarRecetaScreenState();
}

class _EditarRecetaScreenState extends State<EditarRecetaScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _nuevoPasoController = TextEditingController();
  final TextEditingController _nuevoIngredienteController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _unidadMedidaController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<String> _pasos = []; // Lista combinada de pasos
  List<Ingrediente> _ingredientes = [];
  // Lista de unidades de medida
  final List<String> _unidadesMedida = [
    'ml', 'cucharadas', 'tazas', 'pizca', 'gramos', 'onzas', 'cubos', 'sobre', 'cápsulas'
  ];

  String? _unidadMedidaSeleccionada;
  bool _isRecetaGuardada = false;
  int _recetaOriginalId = 0;
  

  // Variables de selección
  String? _metodoSeleccionado;
  String? _dificultadSeleccionada;

  // Listas para seleccionar dificultad y método
  final List<String> _dificultades = ['Fácil', 'Intermedia', 'Difícil'];
  final List<String> _metodos = [
    'Cafetera Espresso',
    'Cafetera de Goteo',
    'Molino de Café',
    'Prensa Francesa',
    'Cafetera Italiana',
  ];

  @override
  void initState() {
    super.initState();
    _recetaOriginalId = widget.receta.id!;
    _nombreController.text = widget.receta.nombreReceta;
    _descripcionController.text = widget.receta.descripcion;
    _metodoSeleccionado = widget.receta.metodo;
    _dificultadSeleccionada = widget.receta.dificultad;

    _cargarIngredientes();

    // Verifica que la lista de pasos tenga datos
    if (widget.receta.elaboracion.isNotEmpty) {
      _pasos = List<String>.from(widget.receta.elaboracion);
    } else {
      // Si no hay pasos, se inicializa con un paso vacío
      _pasos = [''];
    }
  }

  void _guardarReceta() async 
  {
  // Crea una nueva receta basada en los datos editados
  RecetaCafe nuevaReceta = RecetaCafe(
    nombreReceta: _nombreController.text,
    descripcion: _descripcionController.text,
    ingredientes: _ingredientes,
    metodo: _metodoSeleccionado ?? widget.receta.metodo,
    equipoNecesarioId: widget.receta.equipoNecesarioId,
    dificultad: _dificultadSeleccionada ?? widget.receta.dificultad,
    tiempoPreparacion: widget.receta.tiempoPreparacion,
    creadorId: widget.usuarioActual.id!,
    vecesPreparada: 0,
    imagen: widget.receta.imagen,
    elaboracion: _pasos, // Usa la lista completa de pasos
    fechaCreacion: DateTime.now(),
  );

  // Guardar receta en la base de datos
  DatabaseHelper helper = DatabaseHelper();
  helper.updateReceta(widget.receta.id!, nuevaReceta);

  // Agregar receta a la lista de favoritas del usuario
  if (widget.receta.id != null) {
    widget.usuarioActual.agregarFavorita(widget.receta.id!);
    helper.updateUsuario(widget.usuarioActual);
  } else {
    print("Error: El ID de la receta es null y no se puede agregar a favoritas.");
  }

  _isRecetaGuardada = true;
  // Navegar a la pantalla de detalles y reemplazar la pantalla actual
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => const TabBarController(),
      settings: RouteSettings(arguments: widget.usuarioActual), // Pasar usuarioActual
    ),
    (route) => false, // Elimina todas las rutas anteriores
  );
}

  void _agregarIngrediente() async {
    if (_nuevoIngredienteController.text.isNotEmpty &&
        _cantidadController.text.isNotEmpty) {
      
      String nuevoIngrediente = _nuevoIngredienteController.text.toLowerCase();
      var db = await DatabaseHelper().database;

      // Verificar si el ingrediente ya existe en la tabla 'ingredientes'
      var resultado = await db.query(
        'ingredientes',
        where: 'LOWER(nombreIngrediente) = ?',
        whereArgs: [nuevoIngrediente],
      );

      int recetaId = widget.receta.id!;  // ID de la receta editada
      int? ingredienteId;

      if (resultado.isEmpty) {
        // Insertar el nuevo ingrediente en 'ingredientes' si no existe
        ingredienteId = await db.insert(
          'ingredientes',
          {
            'nombreIngrediente': _nuevoIngredienteController.text,
            'unidadMedida': _unidadMedidaController.text,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } else {
        // Si el ingrediente ya existe, obtener su ID
        ingredienteId = resultado.first['ingredienteId'] as int;
      }

      // Verificar si el ingrediente ya está en la receta
      var resultadoRelacion = await db.query(
        'receta_ingredientes',
        where: 'recetaId = ? AND ingredienteId = ?',
        whereArgs: [recetaId, ingredienteId],
      );

      if (resultadoRelacion.isEmpty) {
        // Si no existe la relación, insertar con la nueva cantidad
        await db.insert(
          'receta_ingredientes',
          {
            'recetaId': recetaId,
            'ingredienteId': ingredienteId,
            'cantidad': _cantidadController.text,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } else {
        // Si ya existe la relación, actualizar la cantidad
        await db.update(
          'receta_ingredientes',
          {
            'cantidad': _cantidadController.text,
          },
          where: 'recetaId = ? AND ingredienteId = ?',
          whereArgs: [recetaId, ingredienteId],
        );
      }

      var ingredientes = await dbHelper.obtenerIngredientesPorReceta(widget.receta.id!);

      setState(() {
        _ingredientes = ingredientes;
        _nuevoIngredienteController.clear();
        _cantidadController.clear();
        _unidadMedidaController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ingrediente agregado o actualizado con éxito")),
      );
    }
  }

  Future<void> _eliminarIngrediente(int ingredienteId, int index) async {
    var db = await DatabaseHelper().database;
    
    int recetaId = widget.receta.id!;  // Usamos el ID de la receta editada

    // Eliminar la relación en la tabla receta_ingredientes
    await db.delete(
      'receta_ingredientes',
      where: 'recetaId = ? AND ingredienteId = ?',
      whereArgs: [recetaId, ingredienteId],
    );

    // Verificar si el índice es válido antes de eliminar
    if (index >= 0 && index <= _ingredientes.length) {
      setState(() {
        _ingredientes.removeAt(index);
      });
    } else {
      print("Índice fuera de rango: $index");
    }
  }

  void _cargarIngredientes() async {
    var db = await DatabaseHelper().database;

    // Primero, inserta la receta y obtiene el nuevo ID
    RecetaCafe nuevaReceta = RecetaCafe(
      nombreReceta: _nombreController.text,
      descripcion: _descripcionController.text,
      ingredientes: _ingredientes,
      metodo: _metodoSeleccionado ?? widget.receta.metodo,
      equipoNecesarioId: widget.receta.equipoNecesarioId,
      dificultad: _dificultadSeleccionada ?? widget.receta.dificultad,
      tiempoPreparacion: widget.receta.tiempoPreparacion,
      creadorId: widget.usuarioActual.id!,
      vecesPreparada: 0,
      imagen: widget.receta.imagen,
      elaboracion: _pasos,
      fechaCreacion: DateTime.now(),
    );

    // Inserta la nueva receta y obtiene su ID
    nuevaReceta.id = await dbHelper.insertReceta(nuevaReceta);

    var ingredientesOriginales = await dbHelper.obtenerIngredientesPorReceta(_recetaOriginalId!);

    if (nuevaReceta.id != null) 
    {
      // Ahora vinculamos los ingredientes de la receta original con la nueva receta
      for (Ingrediente ingrediente in ingredientesOriginales) {
        await db.insert(
          'receta_ingredientes',
          {
            'recetaId': nuevaReceta.id!,  // Usamos el nuevo ID de la receta
            'ingredienteId': ingrediente.ingredienteId,  // ID del ingrediente original
            'cantidad': ingrediente.cantidad,  // La cantidad original
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // Ahora cargamos los ingredientes asociados a la nueva receta
      var ingredientes = await dbHelper.obtenerIngredientesPorReceta(widget.receta.id!);

      setState(() {
        _ingredientes = ingredientes;  // Guardamos los ingredientes en la lista local
      });
    } else {
      print("Error al guardar la receta");
    }

    widget.receta.id = nuevaReceta.id;
  }

  void _eliminarPaso(int index) {
    setState(() {
      _pasos.removeAt(index);
    });
  }

  void _onBackPressed() async {
    if (!_isRecetaGuardada) {
      bool? confirmExit = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("¿Seguro?"),
            content: const Text("No has guardado la receta, ¿seguro que quieres salir?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), // No salir
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () async {
                  // Eliminar la receta precargada si no se ha guardado
                  if (widget.receta.id!= null) {
                    var db = await DatabaseHelper().database;

                    // Eliminar la receta de la base de datos (solo si tiene ID)
                    await db.delete(
                      'recetas',
                      where: 'id = ?',
                      whereArgs: [widget.receta.id],
                    );

                    // Eliminar los ingredientes asociados a la receta
                    for (Ingrediente ingrediente in _ingredientes) {
                      await db.delete(
                        'receta_ingredientes',
                        where: 'recetaId = ? AND ingredienteId = ?',
                        whereArgs: [widget.receta.id, ingrediente.ingredienteId],
                      );
                    }
                  }

                  // Salir de la pantalla sin guardar
                  Navigator.pop(context, true); // Salir de la pantalla
                },
                child: const Text("Salir"),
              ),
            ],
          );
        },
      );

      if (confirmExit == true) {
        Navigator.pop(context); // Permite el retroceso
      }
    } else {
      Navigator.pop(context); // Si está guardada, permite el retroceso
    }
  }



  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Receta'),
        backgroundColor: const Color(0xFFD9AB82),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _onBackPressed,
        ),
      ),
      body: PopScope(
        canPop: _isRecetaGuardada, // Maneja el evento de retroceso
        child: SingleChildScrollView( // Hacemos todo el contenido desplazable
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Campos de nombre y descripción
                TextField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la receta',
                    labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                TextField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Dificultad:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: _dificultadSeleccionada,
                  hint: const Text('Selecciona la dificultad'),
                  items: _dificultades.map((String dificultad) {
                    return DropdownMenuItem<String>(
                      value: dificultad,
                      child: Text(dificultad),
                    );
                  }).toList(),
                  onChanged: (String? nuevaDificultad) {
                    setState(() {
                      _dificultadSeleccionada = nuevaDificultad;
                    });
                  },
                ),
                const SizedBox(height: 20),
                const Text('Método de Preparación:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: _metodoSeleccionado,
                  hint: const Text('Selecciona el método'),
                  items: _metodos.map((String metodo) {
                    return DropdownMenuItem<String>(
                      value: metodo,
                      child: Text(metodo),
                    );
                  }).toList(),
                  onChanged: (String? nuevoMetodo) {
                    setState(() {
                      _metodoSeleccionado = nuevoMetodo;
                    });
                  },
                ),
                const SizedBox(height: 20),
                // Editar Ingredientes
                const Text('Ingredientes:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                FutureBuilder<List<Ingrediente>>(
                  future: dbHelper.obtenerIngredientesPorReceta(widget.receta.id!), // Llamada asincrónica
                  builder: (context, snapshot) {
                    // Muestra el indicador de carga mientras esperamos la respuesta
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      // Si hay un error, mostramos el mensaje de error
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      // Si no hay datos o la lista está vacía
                      return const Text('No se encontraron ingredientes');
                    } else {
                      final ingredientes = snapshot.data!;

                      // ListView que muestra los ingredientes
                      return ListView.builder(
                        shrinkWrap: true, // Evita el problema de espacio con Expanded
                        itemCount: ingredientes.length,
                        itemBuilder: (context, index) {
                          final ingrediente = ingredientes[index];
                          return ListTile(
                            title: Row(
                              children: [
                                Text(
                                  '${ingrediente.nombreIngrediente}: ',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${ingrediente.cantidad} ${ingrediente.unidadMedida}',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Color.fromARGB(150, 244, 67, 54)),
                              onPressed: () {
                                final index = ingredientes.indexOf(ingrediente);
                                _eliminarIngrediente(ingrediente.ingredienteId!, index);
                              },
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
                // Formulario para agregar un nuevo ingrediente
                TextField(
                  controller: _nuevoIngredienteController,
                  decoration: const InputDecoration(labelText: 'Ingrediente'),
                ),
                TextField(
                  controller: _cantidadController,
                  decoration: const InputDecoration(labelText: 'Cantidad'),
                ),
                // Dropdown para unidades de medida
                DropdownButton<String>(
                  value: _unidadMedidaSeleccionada,
                  hint: const Text('Selecciona la unidad de medida'),
                  items: _unidadesMedida.map((String unidad) {
                    return DropdownMenuItem<String>(
                      value: unidad,
                      child: Text(unidad),
                    );
                  }).toList(),
                  onChanged: (String? nuevaUnidad) {
                    setState(() {
                      _unidadMedidaSeleccionada = nuevaUnidad;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: _agregarIngrediente,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9AB82),
                  ),
                  child: const Text('Agregar Ingrediente'),
                ),
                const SizedBox(height: 20),
                const Text('Pasos de Elaboración:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ReorderableListView(
                  shrinkWrap: true,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final paso = _pasos.removeAt(oldIndex);
                      _pasos.insert(newIndex, paso);
                    });
                  },
                  children: List.generate(_pasos.length, (index) {
                    return Dismissible(
                      key: Key('$index-${_pasos[index]}'),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        _eliminarPaso(index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Paso eliminado')),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 4.0,
                        color: const Color(0xFFD9AB82),
                        child: ListTile(
                          title: Text(_pasos[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _eliminarPaso(index),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                // Campo para agregar nuevos pasos
                TextField(
                  controller: _nuevoPasoController,
                  decoration: const InputDecoration(labelText: 'Nuevo Paso'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_nuevoPasoController.text.isNotEmpty) {
                      setState(() {
                        _pasos.add(_nuevoPasoController.text);
                        _nuevoPasoController.clear();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9AB82),
                  ),
                  child: const Text('Agregar Paso'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _guardarReceta,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9AB82),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  ),
                  child: const Text('Guardar Receta'),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}
