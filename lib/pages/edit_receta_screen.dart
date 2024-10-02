import 'package:flutter/material.dart';
import '../models/receta_cafe.dart';
import '../models/usuario.dart';

class EditarRecetaScreen extends StatefulWidget 
{
  final RecetaCafe receta;
  final Usuario usuarioActual;

  const EditarRecetaScreen({super.key, required this.receta, required this.usuarioActual});

  @override
  _EditarRecetaScreenState createState() => _EditarRecetaScreenState();
}

class _EditarRecetaScreenState extends State<EditarRecetaScreen> 
{
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _nuevoPasoController = TextEditingController();
  final List<String> _nuevosPasos = [];

  String? _metodoSeleccionado;
  String? _dificultadSeleccionada;

  final List<String> _dificultades = ['Fácil', 'Intermedia', 'Difícil'];
  final List<String> _metodos = 
  [
    'Cafetera Espresso',
    'Cafetera de Goteo',
    'Molino de Café',
    'Prensa Francesa',
    'Cafetera Italiana',
  ];

  @override
  void initState() 
  {
    super.initState();
    _nombreController.text = widget.receta.nombreReceta;
    _descripcionController.text = widget.receta.descripcion;
    _metodoSeleccionado = widget.receta.metodo;
    _dificultadSeleccionada = widget.receta.dificultad;
  }

  void _guardarReceta() 
  {
    // Crea una nueva receta basada en los datos editados
    RecetaCafe nuevaReceta = RecetaCafe
    (
      nombreReceta: _nombreController.text,
      descripcion: _descripcionController.text,
      ingredientes: widget.receta.ingredientes,
      metodo: _metodoSeleccionado ?? widget.receta.metodo,
      equipoNecesario: widget.receta.equipoNecesario,
      dificultad: _dificultadSeleccionada ?? widget.receta.dificultad,
      tiempoPreparacion: widget.receta.tiempoPreparacion,
      imagen: widget.receta.imagen,
      calificacionPromedio: 0.0,
      numCalificaciones: 0,
      usuarioCreador: widget.usuarioActual,
      etiquetas: widget.receta.etiquetas,
      elaboracion: [...widget.receta.elaboracion, ..._nuevosPasos],
    );

    widget.usuarioActual.agregarFavorita(nuevaReceta);

    Navigator.pop(context, nuevaReceta);
  }

  void _reordenarPasos(int oldIndex, int newIndex) 
  {
    setState(() 
    {
      if (oldIndex < newIndex) 
      {
        newIndex--;
      }
      final paso = _nuevosPasos.removeAt(oldIndex);
      _nuevosPasos.insert(newIndex, paso);
    });
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar
      (
        title: const Text('Editar Receta'),
      ),
      body: Padding
      (
        padding: const EdgeInsets.all(16.0),
        child: Column
        (
          crossAxisAlignment: CrossAxisAlignment.start,
          children: 
          [
            TextField
            (
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre de la receta'),
            ),
            TextField
            (
              controller: _descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: 20),
            const Text('Dificultad:', style: TextStyle(fontSize: 18)),
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
            const Text('Método de Preparación:', style: TextStyle(fontSize: 18)),
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
            const Text('Pasos de Elaboración:', style: TextStyle(fontSize: 18)),
            Expanded(
              child: ListView.builder
              (
                itemCount: widget.receta.elaboracion.length + _nuevosPasos.length,
                itemBuilder: (context, index) 
                {
                  if (index < widget.receta.elaboracion.length) 
                  {
                    return ListTile
                    (
                      title: Text(widget.receta.elaboracion[index]),
                    );
                  } else 
                  {
                    return Dismissible
                    (
                      key: Key(_nuevosPasos[index - widget.receta.elaboracion.length]),
                      onDismissed: (direction) 
                      {
                        setState(() 
                        {
                          _nuevosPasos.removeAt(index - widget.receta.elaboracion.length);
                        });
                        ScaffoldMessenger.of(context).showSnackBar
                        (
                          SnackBar(content: Text('Paso eliminado')),
                        );
                      },
                      child: ListTile
                      (
                        title: Text(_nuevosPasos[index - widget.receta.elaboracion.length]),
                      ),
                    );
                  }
                },
              ),
            ),
            TextField
            (
              controller: _nuevoPasoController,
              decoration: const InputDecoration(labelText: 'Nuevo paso'),
            ),
            ElevatedButton
            (
              onPressed: () 
              {
                setState(() 
                {
                  if (_nuevoPasoController.text.isNotEmpty) 
                  {
                    _nuevosPasos.add(_nuevoPasoController.text);
                    _nuevoPasoController.clear();
                  }
                });
              },
              child: const Text('Agregar Paso'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarReceta,
              child: const Text('Guardar Receta'),
            ),
          ],
        ),
      ),
    );
  }
}
