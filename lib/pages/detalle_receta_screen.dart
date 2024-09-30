import 'package:flutter/material.dart';
import '../models/receta_cafe.dart';

class DetalleRecetaScreen extends StatelessWidget {
  final RecetaCafe receta;

  const DetalleRecetaScreen({super.key, required this.receta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(receta.nombreReceta),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Permite hacer scroll si el contenido es largo
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(receta.imagen, width: double.infinity, height: 200, fit: BoxFit.contain),
              const SizedBox(height: 20),
              Text(receta.descripcion, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Text('Método de Preparación: ${receta.metodo}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('Dificultad: ${receta.dificultad}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('Tiempo de Preparación: ${receta.tiempoPreparacion} minutos', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              const Text('Ingredientes', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 10),
              // ListView de ingredientes
              ListView.builder(
                shrinkWrap: true, // Permitir que la lista se ajuste al tamaño del contenido
                physics: const NeverScrollableScrollPhysics(), // Deshabilitar el scroll para la lista
                itemCount: receta.ingredientes.length,
                itemBuilder: (context, index) {
                  final ingrediente = receta.ingredientes[index];
                  return ListTile(
                    title: Text('${ingrediente.nombreIngrediente}: ${ingrediente.cantidad} ${ingrediente.unidadMedida}'),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text('Equipo Necesario', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 10),
              // ListView de equipos
              ListView.builder(
                shrinkWrap: true, // Permitir que la lista se ajuste al tamaño del contenido
                physics: const NeverScrollableScrollPhysics(), // Deshabilitar el scroll para la lista
                itemCount: receta.equipoNecesario.length,
                itemBuilder: (context, index) {
                  final equipo = receta.equipoNecesario[index];
                  return ListTile(
                    title: Text('${equipo.nombreEquipo} (${equipo.tipo})'),
                    subtitle: Text(equipo.descripcion),
                    leading: Image.asset(equipo.imagen, width: 50, height: 50),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text('Etiquetas', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 10),
              // Mostrar etiquetas
              Wrap(
                spacing: 8.0,
                children: receta.etiquetas.map((etiqueta) => Chip(label: Text(etiqueta))).toList(),
              ),
              const SizedBox(height: 20),
              // Mostrar calificación
              Text('Calificación Promedio: ${receta.calificacionPromedio.toStringAsFixed(1)}', style: const TextStyle(fontSize: 18)),
              Text('Número de Calificaciones: ${receta.numCalificaciones}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              // Mostrar comentarios
              const Text('Comentarios:', style: TextStyle(fontSize: 24)),
              ListView.builder(
                shrinkWrap: true, // Permitir que la lista se ajuste al tamaño del contenido
                physics: const NeverScrollableScrollPhysics(), // Deshabilitar el scroll para la lista
                itemCount: receta.comentarios.length,
                itemBuilder: (context, index) {
                  final comentario = receta.comentarios[index];
                  return ListTile(
                    title: Text(comentario.contenido),
                    subtitle: Text('Calificación: ${comentario.calificacion} - ${comentario.fecha}'),
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
