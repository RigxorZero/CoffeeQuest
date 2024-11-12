import 'package:coffee_quest/models/ingrediente.dart';

class RecetaCafe {
  // Atributos privados
  int? id;
  String _nombreReceta;
  String _descripcion;
  List<Ingrediente> _ingredientes;
  String _metodo;
  int _equipoNecesarioId; // Solo el ID del equipo
  String _dificultad;
  int _tiempoPreparacion;
  String _imagen;
  int _creadorId;
  int _vecesPreparada;
  List<String> _elaboracion;

  // Constructor
  RecetaCafe({
    this.id,
    required String nombreReceta,
    required String descripcion,
    required List<Ingrediente> ingredientes,
    required String metodo,
    required int equipoNecesarioId, // Solo el ID del equipo
    required String dificultad,
    required int tiempoPreparacion,
    required String imagen,
    required int creadorId,
    required int vecesPreparada,
    required List<String> elaboracion,
  })  : _nombreReceta = nombreReceta,
        _descripcion = descripcion,
        _ingredientes = ingredientes,
        _metodo = metodo,
        _equipoNecesarioId = equipoNecesarioId, // Almacenamos solo el ID
        _dificultad = dificultad,
        _tiempoPreparacion = tiempoPreparacion,
        _imagen = imagen,
        _creadorId = creadorId,
        _vecesPreparada = vecesPreparada,
        _elaboracion = elaboracion;

  // Método para convertir la receta en un mapa (para almacenamiento en base de datos)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombreReceta': _nombreReceta,
      'descripcion': _descripcion,
      'metodo': _metodo,
      'equipoNecesario': _equipoNecesarioId, // Guardamos solo el ID
      'dificultad': _dificultad,
      'tiempoPreparacion': _tiempoPreparacion,
      'imagen': _imagen,
      'vecesPreparada': _vecesPreparada,
      'creadorId': _creadorId,
      'elaboracion': _elaboracion.join(';'), // Guardamos las listas como strings
    };
  }

  // Método para crear un objeto RecetaCafe a partir de un mapa (extraído de la base de datos)
  factory RecetaCafe.fromMap(Map<String, dynamic> map) {
    return RecetaCafe(
      id: map['id'],
      nombreReceta: map['nombreReceta'],
      descripcion: map['descripcion'],
      ingredientes: [], // Aquí manejarías los ingredientes de forma adecuada
      metodo: map['metodo'],
      equipoNecesarioId: map['equipoNecesario'], // Solo el ID
      dificultad: map['dificultad'],
      tiempoPreparacion: map['tiempoPreparacion'],
      imagen: map['imagen'],
      creadorId: map['creadorId'],
      vecesPreparada: map['vecesPreparada'],
      elaboracion: map['elaboracion'].split(';'),
    );
  }

  // Getters
  String get nombreReceta => _nombreReceta;
  String get descripcion => _descripcion;
  List<Ingrediente> get ingredientes => _ingredientes;
  String get metodo => _metodo;
  int get equipoNecesarioId => _equipoNecesarioId; // Solo el ID
  String get dificultad => _dificultad;
  int get tiempoPreparacion => _tiempoPreparacion;
  String get imagen => _imagen;
  int get vecesPreparada => _vecesPreparada;
  int get creadorId => _creadorId;
  List<String> get elaboracion => _elaboracion;
}
