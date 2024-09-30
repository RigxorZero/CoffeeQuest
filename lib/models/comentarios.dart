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
    String? contenido, // Opcional
    required DateTime fecha,
    required int calificacion,
    required Usuario creador,
    }
  )  : _contenido = contenido ?? "Sin contenido", // Valor predeterminado
        _fecha = fecha,
        _calificacion = calificacion,
        _creador = creador;

  // Metodos
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
    _fecha = DateTime.now();
    _calificacion = nuevaCalificacion;
  }


  // Getters para acceder a atributos privados
  String get contenido => _contenido;
  DateTime get fecha => _fecha;
  int get calificacion => _calificacion;
  Usuario get creador => _creador;
}
