import 'comentarios.dart';
import 'equipo.dart';
import 'ingrediente.dart';
import 'usuario.dart';

class RecetaCafe 
{
  // Atributos privados
  String _nombreReceta;  
  String _descripcion;   
  List<Ingrediente> _ingredientes;
  String _metodo;
  List<Equipo> _equipoNecesario;
  String _dificultad;
  int _tiempoPreparacion;
  String _imagen;
  double _calificacionPromedio;
  int _numCalificaciones;
  Usuario _usuarioCreador;
  List<String> _etiquetas;
  List<Comentarios> _comentarios;

  // Constructor
  RecetaCafe
  (
    {
    required String nombreReceta,
    required String descripcion,
    required List<Ingrediente> ingredientes,
    required String metodo,
    required List<Equipo> equipoNecesario,
    required String dificultad,
    required int tiempoPreparacion,
    required String imagen,
    required double calificacionPromedio,
    required int numCalificaciones,
    required Usuario usuarioCreador,
    required List<String> etiquetas,
    List<Comentarios>? comentarios, // opcional
    }
  )  : _nombreReceta = nombreReceta,
        _descripcion = descripcion,
        _ingredientes = ingredientes,
        _metodo = metodo,
        _equipoNecesario = equipoNecesario,
        _dificultad = dificultad,
        _tiempoPreparacion = tiempoPreparacion,
        _imagen = imagen,
        _calificacionPromedio = calificacionPromedio,
        _numCalificaciones = numCalificaciones,
        _usuarioCreador = usuarioCreador,
        _etiquetas = etiquetas,
        _comentarios = comentarios ?? [];

  // Método para personalizar la receta
  RecetaCafe personalizarReceta(Usuario nuevoCreador) 
  {
    // Crear una nueva instancia de RecetaCafe
    RecetaCafe nuevaReceta = RecetaCafe(
      nombreReceta: _nombreReceta,
      descripcion: _descripcion,
      ingredientes: _ingredientes,
      metodo: _metodo,
      equipoNecesario: _equipoNecesario,
      dificultad: _dificultad,
      tiempoPreparacion: _tiempoPreparacion,
      imagen: _imagen,
      calificacionPromedio: 0.0,
      numCalificaciones: 0,
      usuarioCreador: nuevoCreador,
      etiquetas: _etiquetas,
      comentarios: [],
    );

    return nuevaReceta; // Devuelve la nueva receta personalizada
  }

  void calificarReceta(Comentarios comentario) 
  {
    // Actualizar la calificación promedio
    _calificacionPromedio = (_calificacionPromedio * _numCalificaciones + comentario.calificacion) / (_numCalificaciones + 1);
    _numCalificaciones++;

    // Agregar el comentario a la lista de comentarios
    _comentarios.add(comentario);
  }

  String compartirReceta() 
  {
    return "¡Mira esta deliciosa receta de café! $_nombreReceta";
  }

  String mostrarGuia()
  {
    return "Guía de preparación de $_nombreReceta: $_descripcion";
  }

  // Getters para acceder a atributos privados
  String get nombreReceta => _nombreReceta;
  String get descripcion => _descripcion;
  List<Ingrediente> get ingredientes => _ingredientes;
  String get metodo => _metodo;
  List<Equipo> get equipoNecesario => _equipoNecesario;
  String get dificultad => _dificultad;
  int get tiempoPreparacion => _tiempoPreparacion;
  String get imagen => _imagen;
  double get calificacionPromedio => _calificacionPromedio;
  int get numCalificaciones => _numCalificaciones;
  Usuario get usuarioCreador => _usuarioCreador;
  List<String> get etiquetas => _etiquetas;
  List<Comentarios> get comentarios => List.unmodifiable(_comentarios); // Retorna una copia inmutable
}
