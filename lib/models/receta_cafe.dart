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

  // Métodos
  
  factory RecetaCafe.fromJson
  (
    Map<String, dynamic> json,
    Usuario creador,
    List<Ingrediente> ingredientesCargados,
    List<Equipo> equiposCargados,
  ) 
  {
    // Cargar ingredientes desde el JSON
    List<Ingrediente> ingredientesReceta = (json['ingredientes'] as List).map((ingredienteJson) {
    // Busca el ingrediente en la lista de ingredientes cargados
    final ingredienteCargado = ingredientesCargados.firstWhere(
      (ingrediente) => ingrediente.nombreIngrediente == ingredienteJson['nombreIngrediente'],
      orElse: () => Ingrediente(
        nombreIngrediente: ingredienteJson['nombreIngrediente'], // Si no se encuentra, crea uno nuevo
        cantidad: "0", // Cantidad por defecto si no se encuentra
        unidadMedida: ingredienteJson['unidadMedida'],
      ),
    );

    // Asignar la cantidad de la receta
    return Ingrediente(
      nombreIngrediente: ingredienteCargado.nombreIngrediente,
      cantidad: ingredienteJson['cantidad'], // Esta es la cantidad específica de la receta
      unidadMedida: ingredienteCargado.unidadMedida,
    );
  }).toList();

    List<Equipo> equiposReceta = (json['equipoNecesario'] as List).map((equipoJson) 
    {
      return equiposCargados.firstWhere((equipo) => equipo.nombreEquipo == equipoJson['nombreEquipo']);
    }).toList();

    return RecetaCafe
    (
      nombreReceta: json['nombreReceta'],
      descripcion: json['descripcion'],
      ingredientes: ingredientesReceta,
      metodo: json['metodo'],
      equipoNecesario: equiposReceta,
      dificultad: json['dificultad'],
      tiempoPreparacion: json['tiempoPreparacion'],
      imagen: json['imagen'],
      calificacionPromedio: json['calificacionPromedio'] ?? 0.0,
      numCalificaciones: json['numCalificaciones'] ?? 0,
      usuarioCreador: creador,
      etiquetas: List<String>.from(json['etiquetas']),
      comentarios: [],
    );
  }

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

    return nuevaReceta;
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
