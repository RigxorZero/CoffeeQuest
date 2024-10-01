import 'usuario.dart';

class Comentarios 
{
  // Atributos
  String _contenido;
  DateTime _fecha;
  int _calificacion;
  Usuario _creador;

  // Constructor
  Comentarios
  (
    {
    String? contenido,
    DateTime? fecha,
    required int calificacion,
    required Usuario creador,
    }
  )  : _contenido = contenido ?? "Sin contenido",
        _fecha = fecha ?? DateTime.now(),
        _calificacion = calificacion,
        _creador = creador;

  // Métodos
  String mostrarComentario() 
  {
    return "Comentario: $_contenido - Calificación: $_calificacion - Fecha: $_fecha - Creador: ${_creador.nombre}";
  }

  void eliminarComentario() 
  {
    _contenido = "Comentario eliminado";
  }

  void editarComentario(String nuevoContenido, int nuevaCalificacion) 
  {
    _contenido = nuevoContenido;
    _fecha = DateTime.now(); // Actualizar fecha al editar
    _calificacion = nuevaCalificacion;
  }

  // Getters para acceder a atributos privados
  String get contenido => _contenido;
  DateTime get fecha => _fecha;
  int get calificacion => _calificacion;
  Usuario get creador => _creador;
}
