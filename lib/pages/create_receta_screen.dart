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
// ignore: depend_on_referenced_packages
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';


class CrearRecetaScreen extends StatefulWidget 
{
  final Usuario usuario;

  const CrearRecetaScreen({super.key, required this.usuario});

  @override
  State<CrearRecetaScreen> createState() => _CrearRecetaScreenState();
}

class _CrearRecetaScreenState extends State<CrearRecetaScreen> 
{

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
  bool _isImagePickerActive = false;

  List<String> _pasos = []; // Lista combinada de pasos
  List<Ingrediente> _ingredientes = [];

  String? _unidadMedidaSeleccionada;
  bool _isRecetaGuardada = false;
  String? _metodoSeleccionado;
  String? _dificultadSeleccionada;
  bool _camaraVisible = true;

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

  void _agregarIngrediente() async 
  {
    if (_nuevoIngredienteController.text.isNotEmpty && _cantidadController.text.isNotEmpty) 
    {
      String nuevoIngrediente = _nuevoIngredienteController.text.toLowerCase();
      var db = await DatabaseHelper().database;
      var resultado = await db.query
      (
        'ingredientes',
        where: 'LOWER(nombreIngrediente) = ?',
        whereArgs: [nuevoIngrediente],
      );

      int recetaId = await dbHelper.obtenerMaxRecetaId() + 1;

      int? ingredienteId;

      if (resultado.isEmpty) 
      {
        ingredienteId = await db.insert
        (
          'ingredientes',
          {
            'nombreIngrediente': _nuevoIngredienteController.text,
            'unidadMedida': _unidadMedidaController.text,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } else 
      {
        ingredienteId = resultado.first['ingredienteId'] as int;
      }

      var resultadoRelacion = await db.query
      (
        'receta_ingredientes',
        where: 'recetaId = ? AND ingredienteId = ?',
        whereArgs: [recetaId, ingredienteId],
      );

      if (resultadoRelacion.isEmpty) 
      {
        await db.insert
        (
          'receta_ingredientes',
          {
            'recetaId': recetaId,
            'ingredienteId': ingredienteId,
            'cantidad': _cantidadController.text,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } else 
      {
        await db.update
        (
          'receta_ingredientes',
          {
            'cantidad': _cantidadController.text,
          },
          where: 'recetaId = ? AND ingredienteId = ?',
          whereArgs: [recetaId, ingredienteId],
        );
      }

      var ingredientes = await dbHelper.obtenerIngredientesPorReceta(recetaId);

      setState(() 
      {
        _ingredientes = ingredientes;
        _nuevoIngredienteController.clear();
        _cantidadController.clear();
        _unidadMedidaController.clear();
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar
      (
        SnackBar(content: Text("Ingrediente agregado o actualizado con éxito")),
      );
    }
  }

  void _guardarReceta() async 
  {
    if (_tiempoPreparacionController.text.isEmpty) 
    {
      ScaffoldMessenger.of(context).showSnackBar
      (
        const SnackBar(content: Text("Por favor, ingrese el tiempo de preparación")),
      );
      return;
    }

    int? equipoId = await dbHelper.obtenerEquipoIdPorNombre(_metodoSeleccionado!);

    String imagenReceta = _imagenReceta ?? "assets/images/cafe_latte.png";

    // Crea una nueva receta basada en los datos editados
    RecetaCafe nuevaReceta = RecetaCafe
    (
      nombreReceta: _nombreController.text,
      descripcion: _descripcionController.text,
      ingredientes: _ingredientes,
      metodo: _metodoSeleccionado!,
      equipoNecesarioId: equipoId!,
      dificultad: _dificultadSeleccionada!,
      tiempoPreparacion: int.parse(_tiempoPreparacionController.text),
      creadorId: widget.usuario.id!,
      vecesPreparada: 0,
      imagen: imagenReceta,
      elaboracion: _pasos,
      fechaCreacion: DateTime.now(),
    );

    // Guardar receta en la base de datos
    nuevaReceta.id = await dbHelper.insertReceta(nuevaReceta);

    // Agregar receta a la lista de favoritas del usuario
    if (nuevaReceta.id != null) 
    {
      widget.usuario.agregarFavorita(nuevaReceta.id!);
      await dbHelper.updateUsuario(widget.usuario);
    }

    _isRecetaGuardada = true;

    // Navegar a la pantalla de detalles
    Navigator.pushAndRemoveUntil
    (
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute
      (
        builder: (context) => const TabBarController(),
        settings: RouteSettings(arguments: widget.usuario),
      ),
      (route) => false,
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
    }
  }

  void _eliminarPaso(int index) {
    setState(() {
      _pasos.removeAt(index);
    });
  }

  void _onBackPressed() async 
  {
    if (!_isRecetaGuardada) 
    {
      bool? confirmExit = await showDialog
      (
        context: context,
        builder: (context) 
        {
          return AlertDialog
          (
            title: const Text("¿Seguro?"),
            content: const Text("No has guardado la receta, ¿seguro que quieres salir?"),
            actions: 
            [
              TextButton
              (
                onPressed: () => Navigator.pop(context, false), // No salir
                child: const Text("Cancelar"),
              ),
              TextButton
              (
                onPressed: () async 
                {
                  // Salir de la pantalla sin guardar
                  Navigator.pop(context, true);
                },
                child: const Text("Salir"),
              ),
            ],
          );
        },
      );

      if (confirmExit == true) 
      {
        // ignore: use_build_context_synchronously
        Navigator.pop(context); // Permite el retroceso
      }
    } else 
    {
      Navigator.pop(context); // Si está guardada, permite el retroceso
    }
  }

  // Solicitar permisos de cámara y almacenamiento
  Future<void> _requestPermissions() async
  {
    await Permission.camera.request();
    await Permission.storage.request();
  }


  // Función para inicializar la cámara
  Future<void> _initializeCamera() async 
  {
    // Verifica si ya está inicializada
    if (_isCameraInitialized) return;

    try 
    {
      _cameras = await availableCameras();
      _cameraController = CameraController
      (
        _cameras[0],
        ResolutionPreset.high,
      );

      await _cameraController.initialize();
      setState(() 
      {
        _isCameraInitialized = true; // Marcar como inicializada
      });
    } catch (e) 
    {
      print("Error al inicializar la cámara: $e");
    }
  }

  // Función que toma la foto
  Future<void> _takePicture() async 
  {
    // Verificar que la cámara esté inicializada
    if (!_isCameraInitialized) 
    {
      ScaffoldMessenger.of(context).showSnackBar
      (
        const SnackBar(content: Text("La cámara no está lista. Intente nuevamente.")),
      );
      return;
    }

    try 
    {
      final XFile file = await _cameraController.takePicture();

      // Redimensionar la imagen después de tomarla
      final img.Image image = img.decodeImage(await file.readAsBytes())!;
      final img.Image resizedImage = img.copyResize(image, width: 400, height: 400);

      // Guardar la imagen redimensionada
      final resizedFile = File('${(await getTemporaryDirectory()).path}/resized_image.png')
        ..writeAsBytesSync(img.encodePng(resizedImage));

      setState(() 
      {
        _imagenReceta = resizedFile.path;
        _camaraVisible = false;
      });
    } catch (e) 
    {
      print("Error al tomar la foto: $e");
    }
  }

  Future<void> _pickImage() async 
  {
    if (_isImagePickerActive) return;

    setState(() 
    {
      _isImagePickerActive = true;
    });

    try 
    {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) 
      {
        setState(() 
        {
          _imagenReceta = pickedFile.path;
        });
      }
    } catch (e) 
    {
      // ignore: avoid_print
      print("Error al seleccionar imagen: $e");
    } finally 
    {
      setState(() 
      {
        _isImagePickerActive = false;
      });
    }
  }


  @override
  void dispose() 
  {
    _cameraController.dispose();
    super.dispose();
  }


  @override
  void initState() 
  {
    super.initState();
    _initializeCamera();
  }


  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar
      (
        title: const Text('Crear Receta'),
        backgroundColor: const Color(0xFFD9AB82),
        leading: IconButton
        (
          icon: const Icon(Icons.arrow_back),
          onPressed: _onBackPressed,
        ),
      ),
      body: PopScope
      (
        canPop: _isRecetaGuardada,
        child: SingleChildScrollView
        ( // Desplazable
          child: Padding
          (
            padding: const EdgeInsets.all(16.0),
            child: Column
            (
              crossAxisAlignment: CrossAxisAlignment.start,
              children: 
              [
                // Campos de nombre y descripción
                TextField(
                  controller: _nombreController,
                  decoration: const InputDecoration
                  (
                    labelText: 'Nombre de la receta',
                    labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                TextField
                (
                  controller: _descripcionController,
                  decoration: const InputDecoration
                  (
                    labelText: 'Descripción',
                    labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                TextField
                (
                controller: _tiempoPreparacionController,  // Asocia el controlador
                  decoration: const InputDecoration
                  (
                    labelText: 'Tiempo de Preparación (minutos)',
                    labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                const Text('Dificultad:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                DropdownButton<String>
                (
                  value: _dificultadSeleccionada,
                  hint: const Text('Selecciona la dificultad'),
                  items: _dificultades.map((String dificultad) 
                  {
                    return DropdownMenuItem<String>
                    (
                      value: dificultad,
                      child: Text(dificultad),
                    );
                  }).toList(),
                  onChanged: (String? nuevaDificultad) 
                  {
                    setState(() 
                    {
                      _dificultadSeleccionada = nuevaDificultad;
                    });
                  },
                ),
                const SizedBox(height: 20),
                const Text('Método de Preparación:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                DropdownButton<String>
                (
                  value: _metodoSeleccionado,
                  hint: const Text('Selecciona el método'),
                  items: _metodos.map((String metodo) 
                  {
                    return DropdownMenuItem<String>
                    (
                      value: metodo,
                      child: Text(metodo),
                    );
                  }).toList(),
                  onChanged: (String? nuevoMetodo) 
                  {
                    setState(() 
                    {
                      _metodoSeleccionado = nuevoMetodo;
                    });
                  },
                ),
                const SizedBox(height: 20),
                // Ingredientes - Listado actual
                const Text('Ingredientes:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                ListView.builder
                (
                  shrinkWrap: true,
                  itemCount: _ingredientes.length,  // Número de ingredientes en la lista
                  itemBuilder: (context, index) 
                  {
                    final ingrediente = _ingredientes[index];
                    return ListTile
                    (
                      title: Row
                      (
                        children: 
                        [
                          Text
                          (
                            '${ingrediente.nombreIngrediente}: ',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text
                          (
                            '${ingrediente.cantidad} ${ingrediente.unidadMedida}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          Expanded(child: Container()),
                        ],
                      ),
                      trailing: IconButton
                      (
                        icon: const Icon(Icons.delete, color: Color.fromARGB(150, 244, 67, 54)),
                        onPressed: () 
                        {
                          final index = _ingredientes.indexOf(ingrediente);
                          _eliminarIngrediente(ingrediente.ingredienteId!, index);
                        },
                      ),
                    );
                  },
                ),

                // Agregar nuevo ingrediente
                TextField
                (
                  controller: _nuevoIngredienteController,
                  decoration: const InputDecoration(labelText: 'Ingrediente'),
                ),
                TextField
                (
                  controller: _cantidadController,
                  decoration: const InputDecoration(labelText: 'Cantidad'),
                ),
                DropdownButton<String>
                (
                  value: _unidadMedidaSeleccionada,
                  hint: const Text('Selecciona la unidad de medida'),
                  items: _unidadesMedida.map((String unidad) 
                  {
                    return DropdownMenuItem<String>
                    (
                      value: unidad,
                      child: Text(unidad),
                    );
                  }).toList(),
                  onChanged: (String? nuevaUnidad) 
                  {
                    setState(() 
                    {
                      _unidadMedidaSeleccionada = nuevaUnidad;
                    });
                  },
                ),
                ElevatedButton
                (
                  onPressed: _agregarIngrediente,
                  style: ElevatedButton.styleFrom
                  (
                    backgroundColor: const Color(0xFFD9AB82),
                  ),
                  child: const Text('Agregar Ingrediente'),
                ),
                const SizedBox(height: 20),

                // Pasos de Elaboración
                const Text('Pasos de Elaboración:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ReorderableListView
                (
                  shrinkWrap: true,
                  onReorder: (oldIndex, newIndex) 
                  {
                    setState(() 
                    {
                      if (oldIndex < newIndex) 
                      {
                        newIndex -= 1;
                      }
                      final paso = _pasos.removeAt(oldIndex);
                      _pasos.insert(newIndex, paso);
                    });
                  },
                  children: List.generate(_pasos.length, (index) 
                  {
                    return Dismissible
                    (
                      key: Key('$index-${_pasos[index]}'),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) 
                      {
                        _eliminarPaso(index);
                        ScaffoldMessenger.of(context).showSnackBar
                        (
                          const SnackBar(content: Text('Paso eliminado')),
                        );
                      },
                      child: Card
                      (
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 4.0,
                        color: const Color(0xFFD9AB82),
                        child: ListTile
                        (
                          title: Text(_pasos[index]),
                          trailing: IconButton
                          (
                            icon: const Icon(Icons.delete),
                            onPressed: () => _eliminarPaso(index),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                // Agregar nuevo paso
                TextField
                (
                  controller: _nuevoPasoController,
                  decoration: const InputDecoration(labelText: 'Nuevo Paso'),
                ),
                ElevatedButton
                (
                  onPressed: () 
                  {
                    if (_nuevoPasoController.text.isNotEmpty) 
                    {
                      setState(() 
                      {
                        _pasos.add(_nuevoPasoController.text);
                        _nuevoPasoController.clear();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom
                  (
                    backgroundColor: const Color(0xFFD9AB82),
                  ),
                  child: const Text('Agregar Paso'),
                ),
                const SizedBox(height: 20),
                // Si la cámara está inicializada, muestra el preview
                if (_isCameraInitialized && _camaraVisible)
                Center
                (  // Centra el preview de la cámara
                  child: SizedBox
                  (
                    width: double.infinity,
                    height: 400,
                    child: CameraPreview(_cameraController),
                  ),
                ),
                Center
                (
                  child: ElevatedButton
                  (
                    onPressed: () 
                    {
                      if (_camaraVisible) 
                      {
                        _takePicture();
                      } else 
                      {
                        setState(() 
                        {
                          _camaraVisible = true;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom
                    (
                      backgroundColor: const Color(0xFFD9AB82),
                    ),
                    child: Text(_camaraVisible ? 'Tomar Foto' : 'Mostrar Cámara'),
                  ),
                ),
                Center
                (
                  child: ElevatedButton
                  (
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom
                    (
                      backgroundColor: const Color(0xFFD9AB82),
                    ),
                    child: const Text('Seleccionar Foto de Galería'),
                  ),
                ),
                if (_imagenReceta != null)
                Center
                (  // Centra la imagen tomada
                  child: Image.file(File(_imagenReceta!)),
                ),
                const SizedBox(height: 20),
                Center
                (  // Centra el botón de guardar
                  child: ElevatedButton
                  (
                    onPressed: _guardarReceta,
                    style: ElevatedButton.styleFrom
                    (
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