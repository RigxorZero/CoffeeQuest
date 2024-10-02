import 'package:flutter/material.dart';
import '../models/receta_cafe.dart';
import '../models/comentarios.dart';
import '../models/usuario.dart';
import 'edit_receta_screen.dart';
import 'recommendation_screen.dart';

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
  final TextEditingController _comentarioController = TextEditingController();
  int? _calificacionSeleccionada;
  bool _esFavorita = false;

  @override
  void initState() 
  {
    super.initState();
    // Verifica si la receta ya está en la lista de favoritos
    _esFavorita = widget.usuarioActual.esFavorita(widget.receta);
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar
      (
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
                  widget.usuarioActual.eliminarFavorita(widget.receta);
                  _esFavorita = false;
                } else 
                {
                  widget.usuarioActual.agregarFavorita(widget.receta);
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
              // Navegar a la pantalla de edición
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
              Image.asset(widget.receta.imagen, width: double.infinity, height: 200, fit: BoxFit.contain),
              const SizedBox(height: 20),

              // Descripción de la receta
              Text(widget.receta.descripcion, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),

              // Método de preparación
              Text('Método de Preparación: ${widget.receta.metodo}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),

              // Dificultad y tiempo de preparación
              Text('Dificultad: ${widget.receta.dificultad}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('Tiempo de Preparación: ${widget.receta.tiempoPreparacion} minutos', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),

              // Autor de la receta
              Text('Autor: ${widget.receta.usuarioCreador.nombre}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),

              // Ingredientes
              const Text('Ingredientes', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 10),
              // ListView de ingredientes
              ListView.builder
              (
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.receta.ingredientes.length,
                itemBuilder: (context, index) 
                {
                  final ingrediente = widget.receta.ingredientes[index];
                  return ListTile
                  (
                    title: Text('${ingrediente.nombreIngrediente}: ${ingrediente.cantidad} ${ingrediente.unidadMedida}'),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Equipo necesario
              const Text('Equipo Necesario', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 10),
              // ListView de equipos
              ListView.builder
              (
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.receta.equipoNecesario.length,
                itemBuilder: (context, index) 
                {
                  final equipo = widget.receta.equipoNecesario[index];
                  return Card
                  (
                    elevation: 4.0,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile
                    (
                      title: Text('${equipo.nombreEquipo} (${equipo.tipo})'),
                      subtitle: Text(equipo.descripcion),
                      leading: Image.asset(equipo.imagen, width: 50, height: 50),
                      onTap: () 
                      {
                        // Navegar a la pantalla de recomendación de equipo sin recrear la clase
                        Navigator.push
                        (
                          context,
                          MaterialPageRoute
                          (
                            builder: (context) => RecomendacionEquipoScreen
                            (
                              nombreEquipo: equipo.nombreEquipo,
                              descripcion: equipo.descripcion,
                              imagen: equipo.imagen,
                              enlacesCompra: equipo.enlacesCompra,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Proceso de elaboración
              const Text('Elaboración:', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 10),
              // ListView numerado para los pasos de elaboración
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
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Row
                    (
                      children: 
                      [
                        CircleAvatar
                        (
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 10),
                        Expanded
                        (
                          child: Text
                          (
                            widget.receta.elaboracion[index],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Calificación promedio y número de calificaciones
              Text('Calificación Promedio: ${widget.receta.calificacionPromedio.toStringAsFixed(1)}', style: const TextStyle(fontSize: 18)),
              Text('Número de Calificaciones: ${widget.receta.numCalificaciones}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),

              // Sección para agregar calificación y comentario
              const Text('Calificación y Comentario', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 10),
              DropdownButton<int>(
                hint: const Text('Selecciona una calificación'),
                value: _calificacionSeleccionada,
                items: List.generate(5, (index) => index + 1).map((int valor) 
                {
                  return DropdownMenuItem<int>
                  (
                    value: valor,
                    child: Text(valor.toString()),
                  );
                }).toList(),
                onChanged: (int? nuevoValor) 
                {
                  setState(() 
                  {
                    _calificacionSeleccionada = nuevoValor;
                  });
                },
              ),
              const SizedBox(height: 10),
              TextField
              (
                controller: _comentarioController,
                decoration: const InputDecoration
                (
                  labelText: 'Comentario',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              ElevatedButton
              (
                onPressed: () 
                {
                  if (_calificacionSeleccionada != null && _comentarioController.text.isNotEmpty) 
                  {
                    Comentarios nuevoComentario = Comentarios
                    (
                      contenido: _comentarioController.text,
                      calificacion: _calificacionSeleccionada!,
                      creador: widget.usuarioActual,
                    );

                    // Agregar el comentario a la receta
                    widget.receta.agregarComentario(nuevoComentario.contenido, nuevoComentario.calificacion, widget.usuarioActual);
                    ScaffoldMessenger.of(context).showSnackBar
                    (
                      const SnackBar(content: Text('Comentario agregado')),
                    );

                    // Limpiar los campos
                    _comentarioController.clear();
                    setState(() 
                    {
                      _calificacionSeleccionada = null; // Resetear la calificación
                    });
                  } else 
                  {
                    ScaffoldMessenger.of(context).showSnackBar
                    (
                      const SnackBar(content: Text('Por favor, completa la calificación y el comentario')),
                    );
                  }
                },
                child: const Text('Agregar Comentario'),
              ),
              const SizedBox(height: 20),

              // Listado de comentarios
              const Text('Comentarios:', style: TextStyle(fontSize: 24)),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.receta.comentarios.length,
                itemBuilder: (context, index) 
                {
                  final comentario = widget.receta.comentarios[index];
                  return ListTile
                  (
                    title: Text(comentario.contenido),
                    subtitle: Text('Calificación: ${comentario.calificacion} \nFecha: ${comentario.fecha.toLocal()} \nAutor: ${comentario.creador.nombre}'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
