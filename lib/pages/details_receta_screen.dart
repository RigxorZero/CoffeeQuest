import 'package:coffee_quest/models/ingrediente.dart';
import 'package:flutter/material.dart';
import '../models/database_helper.dart';
import '../models/equipo.dart';
import '../models/receta_cafe.dart';
import '../models/usuario.dart';
import 'edit_receta_screen.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';


class DetalleRecetaScreen extends StatefulWidget 
{
  final RecetaCafe receta;
  final Usuario usuarioActual; // Recibe el usuario actual

  const DetalleRecetaScreen({super.key, required this.receta, required this.usuarioActual});

  @override
  _DetalleRecetaScreenState createState() => _DetalleRecetaScreenState();
}

class _DetalleRecetaScreenState extends State<DetalleRecetaScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  bool _esFavorita = false;
  late Future<Usuario?> creadorFuture;
  late Future<Equipo?> equipoFuture;
  List<bool> _seleccionados = [];

  @override
  void initState() {
    super.initState();
    creadorFuture = dbHelper.obtenerUsuarioID(widget.receta.creadorId);
    equipoFuture = dbHelper.obtenerEquipoPorId(widget.receta.equipoNecesarioId);
    _esFavorita = widget.usuarioActual.esFavorita(widget.receta.id!);
    _seleccionados = List.generate(widget.receta.ingredientes.length, (_) => false);
  }

  // Función para generar el resumen de la receta (nombre, ingredientes y pasos)
  String _generarResumen() {
    List<String> ingredientesSeleccionados = [];
    for (int i = 0; i < widget.receta.ingredientes.length; i++) {
      if (_seleccionados[i]) {
        ingredientesSeleccionados.add(widget.receta.ingredientes[i].nombreIngrediente);
      }
    }

    List<String> pasos = widget.receta.elaboracion;

    String resumen = 'Receta: ${widget.receta.nombreReceta}\n\n';
    resumen += 'Ingredientes: ${ingredientesSeleccionados.join(', ')}\n\n';
    resumen += 'Pasos a seguir:\n';
    for (int i = 0; i < pasos.length; i++) {
      resumen += '${i + 1}. ${pasos[i]}\n';
    }

    return resumen;
  }

  // Función para compartir la receta con la imagen
  void _compartirReceta() async {
    final resumen = _generarResumen();
    final String? imagenPath = widget.receta.imagen;

    // Si la imagen está disponible, la compartimos junto con el resumen
    if (imagenPath != null && File(imagenPath).existsSync()) {
      // Compartimos tanto el texto como la imagen
      final XFile imagen = XFile(imagenPath);
      await Share.shareXFiles(
        [imagen], // La imagen que deseas compartir
        text: resumen, // El texto con el resumen de la receta
      );
    } else {
      // Si no hay imagen, solo compartimos el texto
      await Share.share(resumen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD9AB82),
        title: Text(widget.receta.nombreReceta),
        actions: [
          IconButton(
            icon: Icon(
              _esFavorita ? Icons.favorite : Icons.favorite_border,
              color: _esFavorita ? Colors.red : null,
            ),
            onPressed: () {
              setState(() {
                if (_esFavorita) {
                  widget.usuarioActual.eliminarFavorita(widget.receta.id!);
                  dbHelper.updateUsuario(widget.usuarioActual);  // Actualizar en la base de datos
                  _esFavorita = false;
                } else {
                  widget.usuarioActual.agregarFavorita(widget.receta.id!);
                  dbHelper.updateUsuario(widget.usuarioActual);
                  _esFavorita = true;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditarRecetaScreen(
                    receta: widget.receta,
                    usuarioActual: widget.usuarioActual,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen de la receta
              Image.asset(widget.receta.imagen, width: double.infinity, height: 200, fit: BoxFit.contain),
              const SizedBox(height: 20),

              // Descripción de la receta
              Text(widget.receta.descripcion, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 20),

              // Método de preparación
              Row(
                children: [
                  const Text(
                    'Veces preparada:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.receta.vecesPreparada.toString(),
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Método de preparación
              Row(
                children: [
                  const Text(
                    'Método de Preparación:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.receta.metodo,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Dificultad
              Row(
                children: [
                  const Text(
                    'Dificultad:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.receta.dificultad,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Tiempo de preparación
              Row(
                children: [
                  const Text(
                    'Tiempo de Preparación:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.receta.tiempoPreparacion.toString(),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const Text(
                    ' minutos',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Autor de la receta
              FutureBuilder<Usuario?>(
                future: creadorFuture,  // Usamos Future<Usuario?>
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();  // Mientras carga
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return const Text('No se pudo cargar el creador');
                  } else {
                    final creador = snapshot.data!;
                    return Row(
                      children: [
                        const Text(
                          'Autor:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          creador.nombre,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 10),

              // Fecha de creación de la receta
              Row(
                children: [
                  const Text(
                    'Fecha de Creación:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    DateFormat('dd/MM/yyyy').format(widget.receta.fechaCreacion), // Formato personalizado
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Ingredientes
              const Text('Ingredientes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),

              FutureBuilder<List<Ingrediente>>(
                future: dbHelper.obtenerIngredientesPorReceta(widget.receta.id!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No se encontraron ingredientes');
                  } else {
                    final ingredientes = snapshot.data!;
                    // Inicializa la lista _seleccionados con el tamaño de ingredientes
                    if (_seleccionados.length != ingredientes.length) {
                      _seleccionados = List.generate(ingredientes.length, (_) => false);
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: ingredientes.length,
                      itemBuilder: (context, index) {
                        final ingrediente = ingredientes[index];
                        
                        // Asegurarse de que _seleccionados tenga el tamaño adecuado
                        if (_seleccionados.length != ingredientes.length) {
                          _seleccionados = List.generate(ingredientes.length, (_) => false);
                        }

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
                          trailing: Checkbox(
                            value: _seleccionados[index],
                            onChanged: (bool? value) {
                              setState(() {
                                _seleccionados[index] = value!;
                              });
                            },
                          ),
                        );
                      },
                    );

                  }
                },
              ),

              const SizedBox(height: 10),

              // Equipo necesario
              const Text('Equipo Necesario', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // FutureBuilder para el equipo
              FutureBuilder<Equipo?>(
                future: equipoFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData) {
                    return const Text('No se pudo cargar el equipo');
                  } else {
                    final equipo = snapshot.data!;
                    return Card(
                      elevation: 4.0,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text('${equipo.nombreEquipo} (${equipo.tipo})'),
                        subtitle: Text(equipo.descripcion),
                        leading: Image.asset(equipo.imagen, width: 50, height: 50),
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 20),

              // Proceso de elaboración
              const Text('Elaboración:', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // ListView numerado para los pasos de elaboración
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.receta.elaboracion.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9AB82),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFA6785D),
                          child: Text('${index + 1}', style: const TextStyle(color: Color.fromARGB(255, 255, 252, 252))),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.receta.elaboracion[index],
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Botón para compartir
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    final resumen = _generarResumen();
                    // Compartir el resumen usando share_plus
                    Share.share(resumen);
                  },
                  child: const Text('Compartir Receta'),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Llamada a la función para concluir la preparación
                    _concluirPreparacion(widget.receta.id!);
                  },
                  child: Text('Concluir preparación'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Llamada al método para concluir la preparación
  void _concluirPreparacion(int recetaId) async {
    try {
      // Llamamos a la función para incrementar 'vecesPreparada' en la base de datos
      await DatabaseHelper().incrementarVecesPreparada(recetaId);

      setState(() {
        widget.receta.vecesPreparada += 1;
      });
      
      // Aquí puedes agregar código adicional, como mostrar un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preparación concluida. ¡Receta registrada!'))
      );
    } catch (e) {
      // Manejo de errores en caso de que algo falle
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al concluir la preparación.'))
      );
    }
  }

}
