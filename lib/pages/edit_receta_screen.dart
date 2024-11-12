import 'package:coffee_quest/models/ingrediente.dart';
import 'package:flutter/material.dart';
import '../models/database_helper.dart';
import '../models/receta_cafe.dart';
import '../models/usuario.dart';
import '../pages/details_receta_screen.dart';

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
    _nombreController.text = widget.receta.nombreReceta;
    _descripcionController.text = widget.receta.descripcion;
    _metodoSeleccionado = widget.receta.metodo;
    _dificultadSeleccionada = widget.receta.dificultad;

    // Inicializar la lista de ingredientes
    if (widget.receta.ingredientes.isNotEmpty) {
      _ingredientes = List<Ingrediente>.from(widget.receta.ingredientes);
    }

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
  );

  // Guardar receta en la base de datos
  DatabaseHelper helper = DatabaseHelper();
  await helper.insertReceta(nuevaReceta);

  // Agregar receta a la lista de favoritas del usuario
  widget.usuarioActual.agregarFavorita(nuevaReceta.id!);
  
  // Navegar a la pantalla de detalles
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DetalleRecetaScreen(
        receta: nuevaReceta,
        usuarioActual: widget.usuarioActual,
      ),
    ),
  );
}

  void _agregarIngrediente() {
    if (_nuevoIngredienteController.text.isNotEmpty &&
        _cantidadController.text.isNotEmpty &&
        _unidadMedidaController.text.isNotEmpty) {
      setState(() {
        _ingredientes.add(Ingrediente(
          nombreIngrediente: _nuevoIngredienteController.text,
          cantidad: _cantidadController.text,
          unidadMedida: _unidadMedidaController.text,
        ));

        // Limpiar los campos después de agregar
        _nuevoIngredienteController.clear();
        _cantidadController.clear();
        _unidadMedidaController.clear();
      });
    }
  }

  void _eliminarIngrediente(int index) {
    setState(() {
      _ingredientes.removeAt(index);
    });
  }

  void _eliminarPaso(int index) {
    setState(() {
      _pasos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Receta'),
        backgroundColor: const Color(0xFFD9AB82),
      ),
      body: SingleChildScrollView( // Hacemos todo el contenido desplazable
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
              ListView.builder(
                shrinkWrap: true, // Evita el problema de espacio con Expanded
                itemCount: _ingredientes.length,
                itemBuilder: (context, index) {
                  final ingrediente = _ingredientes[index];
                  return ListTile(
                    title: Text('${ingrediente.nombreIngrediente} - ${ingrediente.cantidad} ${ingrediente.unidadMedida}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Color.fromARGB(150, 244, 67, 54)),
                      onPressed: () => _eliminarIngrediente(index),
                    ),
                  );
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
              TextField(
                controller: _unidadMedidaController,
                decoration: const InputDecoration(labelText: 'Unidad de medida'),
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
    );
  }
}
