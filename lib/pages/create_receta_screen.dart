import 'package:coffee_quest/models/ingrediente.dart';
import 'package:coffee_quest/pages/tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../models/receta_cafe.dart';
import '../models/usuario.dart';
import '../models/database_helper.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CrearRecetaScreen extends StatefulWidget {
  final Usuario usuario;

  CrearRecetaScreen({super.key, required this.usuario});

  @override
  State<CrearRecetaScreen> createState() => _CrearRecetaScreenState();
}

class _CrearRecetaScreenState extends State<CrearRecetaScreen> {

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _nuevoPasoController = TextEditingController();
  final TextEditingController _nuevoIngredienteController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _unidadMedidaController = TextEditingController();
  final TextEditingController _tiempoPreparacionController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper();

  // Camara
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  String? _imagenReceta;
  final ImagePicker _picker = ImagePicker();

  List<String> _pasos = []; // Lista combinada de pasos
  List<Ingrediente> _ingredientes = [];

  String? _unidadMedidaSeleccionada;
  bool _isRecetaGuardada = false;
  String? _metodoSeleccionado;
  String? _dificultadSeleccionada;

  // Listas para seleccionar dificultad y método
  final List<String> _unidadesMedida = [
    'ml', 'cucharadas', 'tazas', 'pizca', 'gramos', 'onzas', 'cubos', 'sobre', 'cápsulas'
  ];
  final List<String> _dificultades = ['Fácil', 'Intermedia', 'Difícil'];
  final List<String> _metodos = [
    'Cafetera Espresso',
    'Cafetera de Goteo',
    'Molino de Café',
    'Prensa Francesa',
    'Cafetera Italiana',
  ];

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

      int recetaId = await dbHelper.obtenerMaxRecetaId() + 1;

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

      var ingredientes = await dbHelper.obtenerIngredientesPorReceta(recetaId);

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

  void _guardarReceta() async {
    // Asegurarse de que el tiempo de preparación se haya ingresado
    if (_tiempoPreparacionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, ingrese el tiempo de preparación")),
      );
      return;
    }

    int? equipoId = await dbHelper.obtenerEquipoIdPorNombre(_metodoSeleccionado!);

    // Usamos la ruta de la imagen tomada, si es nula se usa una predeterminada
  String imagenReceta = _imagenReceta ?? "assets/images/cafe_latte.png";

    // Crea una nueva receta basada en los datos editados
    RecetaCafe nuevaReceta = RecetaCafe(
      nombreReceta: _nombreController.text,
      descripcion: _descripcionController.text,
      ingredientes: _ingredientes,
      metodo: _metodoSeleccionado!,
      equipoNecesarioId: equipoId!,
      dificultad: _dificultadSeleccionada!,
      tiempoPreparacion: int.parse(_tiempoPreparacionController.text),  // Convertir a int
      creadorId: widget.usuario.id!,
      vecesPreparada: 0,
      imagen: imagenReceta,
      elaboracion: _pasos,
      fechaCreacion: DateTime.now(),
    );

    // Guardar receta en la base de datos
    nuevaReceta.id = await dbHelper.insertReceta(nuevaReceta);

    // Agregar receta a la lista de favoritas del usuario
    if (nuevaReceta.id != null) {
      widget.usuario.agregarFavorita(nuevaReceta.id!);
      await dbHelper.updateUsuario(widget.usuario);
    } else {
      print("Error: El ID de la receta es null y no se puede agregar a favoritas.");
    }

    _isRecetaGuardada = true;

    // Navegar a la pantalla de detalles
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const TabBarController(),
        settings: RouteSettings(arguments: widget.usuario),
      ),
      (route) => false, // Elimina todas las rutas anteriores
    );
  }

  Future<void> _eliminarIngrediente(int ingredienteId, int index) async 
  {
    // Verificar si el índice es válido antes de eliminar
    if (index >= 0 && index <= _ingredientes.length) 
    {
      setState(() 
      {
        _ingredientes.removeAt(index);
      });
    } else {
      print("Índice fuera de rango: $index");
    }
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
                onPressed: () async 
                {
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

  // Solicitar permisos de cámara y almacenamiento
  Future<void> _requestPermissions() async {
    PermissionStatus cameraStatus = await Permission.camera.request();
    if (cameraStatus.isGranted) {
      print("Permiso de cámara concedido");
      _initializeCamera();  // Inicializa la cámara si el permiso es concedido
    } else {
      print("Permiso de cámara denegado");
    }

    PermissionStatus storageStatus = await Permission.storage.request();
    if (storageStatus.isGranted) {
      print("Permiso de almacenamiento concedido");
    } else {
      print("Permiso de almacenamiento denegado");
    }
  }

  // Inicializa la cámara después de que se conceden los permisos
  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(_cameras[0], ResolutionPreset.high);

    await _cameraController.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }

  // Toma una foto con la cámara
  Future<void> _takePicture() async {
    try {
      final XFile file = await _cameraController.takePicture();
      setState(() {
        _imagenReceta = file.path;  // Guardamos la ruta de la imagen
      });
    } catch (e) {
      print("Error al tomar la foto: $e");
    }
  }

  // Seleccionar una imagen desde la galería
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagenReceta = pickedFile.path;
      });
    }
  }


  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Receta'),
        backgroundColor: const Color(0xFFD9AB82),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _onBackPressed,
        ),
      ),
      body: PopScope(
        canPop: _isRecetaGuardada,
        child: SingleChildScrollView( // Desplazable
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
                TextField(
                controller: _tiempoPreparacionController,  // Asocia el controlador
                decoration: const InputDecoration(
                  labelText: 'Tiempo de Preparación (minutos)',
                  labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                keyboardType: TextInputType.number,  // Para ingresar números
              ),
              const SizedBox(height: 20),
                // Dificultad y Método de preparación
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

                // Ingredientes - Listado actual
                const Text('Ingredientes:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _ingredientes.length,  // Número de ingredientes en la lista
                  itemBuilder: (context, index) {
                    final ingrediente = _ingredientes[index];
                    return ListTile(
                      title: Row(
                        children: [
                          Text('${ingrediente.nombreIngrediente}: ',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text('${ingrediente.cantidad} ${ingrediente.unidadMedida}',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Color.fromARGB(150, 244, 67, 54)),
                        onPressed: () {
                          final index = _ingredientes.indexOf(ingrediente);
                                _eliminarIngrediente(ingrediente.ingredienteId!, index);
                        },
                      ),
                    );
                  },
                ),

                // Agregar nuevo ingrediente
                TextField(
                  controller: _nuevoIngredienteController,
                  decoration: const InputDecoration(labelText: 'Ingrediente'),
                ),
                TextField(
                  controller: _cantidadController,
                  decoration: const InputDecoration(labelText: 'Cantidad'),
                ),
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

                // Pasos de Elaboración
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
                // Agregar nuevo paso
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
                // Si la cámara está inicializada, muestra el preview
                if (_isCameraInitialized)
                  Center(  // Centra el preview de la cámara
                    child: Container(
                      height: 300,
                      child: CameraPreview(_cameraController),
                    ),
                  ),

                // Botón para tomar una foto
                Center(  // Centra el botón de tomar foto
                  child: ElevatedButton(
                    onPressed: _takePicture,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD9AB82),
                    ),
                    child: const Text('Tomar Foto'),
                  ),
                ),
                
                // Botón para seleccionar una imagen desde la galería
                Center(
                  child: ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD9AB82),
                    ),
                    child: const Text('Seleccionar Foto de Galería'),
                  ),
                ),
                // Mostrar la imagen tomada
                if (_imagenReceta != null)
                  Center(  // Centra la imagen tomada
                    child: Image.file(File(_imagenReceta!)),
                  ),
                const SizedBox(height: 20),
                Center(  // Centra el botón de guardar
                  child: ElevatedButton(
                    onPressed: _guardarReceta,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD9AB82),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    ),
                    child: const Text('Guardar Receta'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}