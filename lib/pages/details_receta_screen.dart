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
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path_provider/path_provider.dart';


class DetalleRecetaScreen extends StatefulWidget 
{
  final RecetaCafe receta;
  final Usuario usuarioActual; // Recibe el usuario actual

  const DetalleRecetaScreen({super.key, required this.receta, required this.usuarioActual});

  @override
  _DetalleRecetaScreenState createState() => _DetalleRecetaScreenState();
}

class _DetalleRecetaScreenState extends State<DetalleRecetaScreen> 
{
  final DatabaseHelper dbHelper = DatabaseHelper();
  bool _esFavorita = false;
  late Future<Usuario?> creadorFuture;
  late Future<Equipo?> equipoFuture;
  List<Ingrediente?> ingredientes = [];
  List<bool> _seleccionados = [];

  @override
  void initState() 
  {
    super.initState();
    creadorFuture = dbHelper.obtenerUsuarioID(widget.receta.creadorId);
    equipoFuture = dbHelper.obtenerEquipoPorId(widget.receta.equipoNecesarioId);
    _esFavorita = widget.usuarioActual.esFavorita(widget.receta.id!);
    _seleccionados = List.generate(widget.receta.ingredientes.length, (_) => false);
  }

  // Función para generar el resumen de la receta (nombre, ingredientes y pasos)
  String _generarResumen() 
  {

    dbHelper.obtenerIngredientesPorReceta(widget.receta.id!);
    List<String> ingredientesSeleccionados = [];
    for (int i = 0; i < ingredientes.length; i++) 
    {
        String ingredienteTexto = ingredientes[i]!.nombreIngrediente;
      // Verificamos si el ingrediente está marcado como faltante
      if (_seleccionados[i]) 
      {
        ingredienteTexto += " (Faltante)\n\n";
      }
      ingredientesSeleccionados.add(ingredienteTexto);
    }

    List<String> pasos = widget.receta.elaboracion;

    String resumen = 'Receta: ${widget.receta.nombreReceta}\n\n';
    resumen += 'Ingredientes:\n ${ingredientesSeleccionados.join(' ')}\n';
    resumen += 'Pasos a seguir:\n';
    for (int i = 0; i < pasos.length; i++) 
    {
      resumen += '${i + 1}. ${pasos[i]}\n';
    }
    return resumen;
  }

  Future<void> _mostrarSeleccionIngredientes() async 
  {
    showDialog
    (
      context: context,
      builder: (BuildContext context) 
      {
        // Usamos un StatefulBuilder para que el setState funcione dentro del dialog
        return StatefulBuilder
        (
          builder: (BuildContext context, setStateDialog) 
          {
            return AlertDialog
            (
              title: const Text('Ingredientes faltantes'),
              content: SingleChildScrollView
              (
                child: Column
                (
                  children: List.generate(ingredientes.length, (index) 
                  {
                    final ingrediente = ingredientes[index];
                    return CheckboxListTile
                    (
                      title: Text(ingrediente!.nombreIngrediente),
                      value: _seleccionados[index],
                      onChanged: (bool? value) 
                      {
                        setStateDialog(() 
                        {
                          _seleccionados[index] = value ?? false;
                        });
                      },
                    );
                  }),
                ),
              ),
              actions: 
              [
                TextButton
                (
                  onPressed: () 
                  {
                    Navigator.of(context).pop();
                    _compartirReceta();
                  },
                  child: const Text('Compartir'),
                ),
                TextButton
                (
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Función para compartir la receta con la imagen
  Future<void> _compartirReceta() async 
  {
    final resumen = _generarResumen();
    final recetaActual = await dbHelper.obtenerRecetaPorId(widget.receta.id!);
    final String imagenPath = recetaActual!.imagen;

    try 
    {
      // Si la imagen está en los assets
      if (imagenPath.startsWith('assets/')) 
      {
        // Lee la imagen desde los assets
        final ByteData data = await rootBundle.load(imagenPath);
        final Directory tempDir = await getTemporaryDirectory();
        final String tempPath = '${tempDir.path}/temp_image.png';
        final File tempFile = File(tempPath);

        // Escribe los bytes en el archivo temporal
        await tempFile.writeAsBytes(data.buffer.asUint8List());

        // Ahora compartimos el archivo temporal
        final XFile imagen = XFile(tempPath);
        await Share.shareXFiles([imagen], text: resumen);
      } else 
      {
        final XFile imagen = XFile(imagenPath);  // La ruta ya es un archivo
        await Share.shareXFiles([imagen], text: resumen);
      }
    } catch (e) 
    {
      // ignore: avoid_print
      print("Error al compartir la receta: $e");
      await Share.share(resumen);
    }
  }

  Widget _mostrarImagen(String rutaImagen) 
  {
    if (rutaImagen.startsWith('assets/')) 
    {
      return Image.asset
      (
        rutaImagen,
        width: double.infinity,
        height: 200,
        fit: BoxFit.contain,
      );
    } else 
    {
      return Image.file
      (
        File(rutaImagen),
        width: double.infinity,
        height: 200,
        fit: BoxFit.contain,
      );
    }
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar
      (
        backgroundColor: const Color(0xFFD9AB82),
        title: Text(widget.receta.nombreReceta),
        actions: 
        [
          IconButton
          (
            icon: Icon
            (
              _esFavorita ? Icons.favorite : Icons.favorite_border,
              color: _esFavorita ? Colors.red : null,
            ),
            onPressed: () 
            {
              setState(() 
              {
                if (_esFavorita) 
                {
                  widget.usuarioActual.eliminarFavorita(widget.receta.id!);
                  dbHelper.updateUsuario(widget.usuarioActual);  // Actualizar en la base de datos
                  _esFavorita = false;
                } else 
                {
                  widget.usuarioActual.agregarFavorita(widget.receta.id!);
                  dbHelper.updateUsuario(widget.usuarioActual);
                  _esFavorita = true;
                }
              });
            },
          ),
          IconButton
          (
            icon: const Icon(Icons.edit),
            onPressed: () 
            {
              Navigator.push
              (
                context,
                MaterialPageRoute
                (
                  builder: (context) => EditarRecetaScreen
                  (
                    receta: widget.receta,
                    usuarioActual: widget.usuarioActual,
                  ),
                ),
              );
            },
          ),
          IconButton
          (
            icon: const Icon(Icons.share),
            onPressed: _mostrarSeleccionIngredientes,
          ),
        ],
      ),
      body: Padding
      (
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView
        (
          child: Column
          (
            crossAxisAlignment: CrossAxisAlignment.start,
            children: 
            [
              // Imagen de la receta
              _mostrarImagen(widget.receta.imagen),
              const SizedBox(height: 20),

              // Descripción de la receta
              Text(widget.receta.descripcion, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 20),

              // Método de preparación
              Row
              (
                children: 
                [
                  const Text
                  (
                    'Veces preparada:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 5),
                  Text
                  (
                    widget.receta.vecesPreparada.toString(),
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Método de preparación
              Row
              (
                children: 
                [
                  const Text
                  (
                    'Método de Preparación:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 5),
                  Text
                  (
                    widget.receta.metodo,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Dificultad
              Row
              (
                children: 
                [
                  const Text
                  (
                    'Dificultad:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 5),
                  Text
                  (
                    widget.receta.dificultad,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Tiempo de preparación
              Row
              (
                children: 
                [
                  const Text
                  (
                    'Tiempo de Preparación:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 5),
                  Text
                  (
                    widget.receta.tiempoPreparacion.toString(),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const Text
                  (
                    ' minutos',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Autor de la receta
              FutureBuilder<Usuario?>
              (
                future: creadorFuture,
                builder: (context, snapshot) 
                {
                  if (snapshot.connectionState == ConnectionState.waiting) 
                  {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) 
                  {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data == null) 
                  {
                    return const Text('No se pudo cargar el creador');
                  } else 
                  {
                    final creador = snapshot.data!;
                    return Row
                    (
                      children: 
                      [
                        const Text
                        (
                          'Autor:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 5),
                        Text
                        (
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
              Row
              (
                children: 
                [
                  const Text
                  (
                    'Fecha de Creación:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 5),
                  Text
                  (
                    DateFormat('dd/MM/yyyy').format(widget.receta.fechaCreacion),
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Ingredientes
              const Text('Ingredientes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),

              FutureBuilder<List<Ingrediente>>
              (
                future: dbHelper.obtenerIngredientesPorReceta(widget.receta.id!),
                builder: (context, snapshot) 
                {
                  if (snapshot.connectionState == ConnectionState.waiting) 
                  {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) 
                  {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) 
                  {
                    return const Text('No se encontraron ingredientes');
                  } else 
                  {
                    ingredientes = snapshot.data!;

                    if(_seleccionados.length != ingredientes.length) 
                    {
                      _seleccionados = List.generate(ingredientes.length, (_) => false);
                    }
                    return ListView.builder
                    (
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: ingredientes.length,
                      itemBuilder: (context, index) 
                      {
                        final ingrediente = ingredientes[index];

                        return ListTile
                        (
                          title: Row
                          (
                            children: 
                            [
                              Text
                              (
                                '${ingrediente?.nombreIngrediente}: ',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text
                              (
                                '${ingrediente?.cantidad} ${ingrediente?.unidadMedida}',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
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
              FutureBuilder<Equipo?>
              (
                future: equipoFuture,
                builder: (context, snapshot) 
                {
                  if (snapshot.connectionState == ConnectionState.waiting) 
                  {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) 
                  {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData)
                  {
                    return const Text('No se pudo cargar el equipo');
                  } else 
                  {
                    final equipo = snapshot.data!;
                    return Card
                    (
                      elevation: 4.0,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile
                      (
                        title: Text('${equipo.nombreEquipo} (${equipo.tipo})'),
                        subtitle: Text(equipo.descripcion),
                        leading: Image.asset(equipo.imagen, width: 50, height: 50),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              const Text('Elaboración:', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListView.builder
              (
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.receta.elaboracion.length,
                itemBuilder: (context, index) 
                {
                  return Container
                  (
                    margin: const EdgeInsets.only(bottom: 10.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration
                    (
                      color: const Color(0xFFD9AB82),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Row
                    (
                      children: 
                      [
                        CircleAvatar
                        (
                          backgroundColor: const Color(0xFFA6785D),
                          child: Text('${index + 1}', style: const TextStyle(color: Color.fromARGB(255, 255, 252, 252))),
                        ),
                        const SizedBox(width: 10),
                        Expanded
                        (
                          child: Text
                          (
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
              Center
              (
                child: ElevatedButton
                (
                  onPressed: ()
                  {
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
  void _concluirPreparacion(int recetaId) async 
  {
    try 
    {
      await DatabaseHelper().incrementarVecesPreparada(recetaId);

      setState(() 
      {
        widget.receta.vecesPreparada += 1;
      });
      
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar
      (
        SnackBar(content: Text('Preparación concluida. ¡Receta registrada!'))
      );
    } catch (e) 
    {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar
      (
        SnackBar(content: Text('Error al concluir la preparación.'))
      );
    }
  }
}
