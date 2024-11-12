import 'package:flutter/material.dart';
import '../models/database_helper.dart';
import '../models/equipo.dart';
import '../models/receta_cafe.dart';
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
  final DatabaseHelper dbHelper = DatabaseHelper();
  bool _esFavorita = false;
  late Usuario creador;
  late Equipo equipo;

  @override
  void initState() 
  {
    super.initState();
    // Verifica si la receta ya está en la lista de favoritos
    creador = dbHelper.obtenerUsuarioID(widget.receta.creadorId) as Usuario;
    equipo = dbHelper.obtenerEquipoPorId(widget.receta.equipoNecesarioId) as Equipo;
    _esFavorita = widget.usuarioActual.esFavorita(widget.receta.id!);
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
                  _esFavorita = false;
                } else 
                {
                  widget.usuarioActual.agregarFavorita(widget.receta.id!);
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
              Text(widget.receta.descripcion, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 20),

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
                  const SizedBox(width: 5), // Espaciado entre los textos
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
                  const SizedBox(width: 5), // Espaciado entre los textos
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
                  const SizedBox(width: 5), // Espaciado entre los textos
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
              Row
              (
                children: 
                [
                  const Text
                  (
                    'Autor:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 5), // Espaciado entre los textos
                  Text
                  (
                    creador.nombre,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Ingredientes
              const Text('Ingredientes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),

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
                    title: Row
                    (
                      children: 
                      [
                        Text
                        (
                          '${ingrediente.nombreIngrediente}: ',
                          style: const TextStyle
                          (
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text
                        (
                          '${ingrediente.cantidad} ${ingrediente.unidadMedida}',
                          style: const TextStyle
                          (
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 10),


              // Equipo necesario
              const Text('Equipo Necesario', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              // Mostrar solo un equipo
              Card
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
              ),

              const SizedBox(height: 20),

              // Proceso de elaboración
              const Text('Elaboración:', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
            ],
          ),
        ),
      ),
    );
  }
}
