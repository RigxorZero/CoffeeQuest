import 'dart:convert';

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
  DateTime _fechaCreacion;

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
    required DateTime fechaCreacion,
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
        _elaboracion = elaboracion,
        _fechaCreacion = fechaCreacion;

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
      'fechaCreacion': _fechaCreacion.toIso8601String(),
    };
  }

  factory RecetaCafe.fromMap(Map<String, dynamic> map) 
  {
    // Deserializar la cadena JSON en una lista de strings
    List<String> elaboracionList = map['elaboracion'] != null && map['elaboracion'].isNotEmpty
        ? List<String>.from(jsonDecode(map['elaboracion']))
        : [];

    return RecetaCafe(
      id: map['id'],
      nombreReceta: map['nombreReceta'],
      descripcion: map['descripcion'],
      ingredientes: [],
      metodo: map['metodo'],
      equipoNecesarioId: map['equipoNecesario'], // Solo el ID
      dificultad: map['dificultad'],
      tiempoPreparacion: map['tiempoPreparacion'],
      imagen: map['imagen'],
      creadorId: map['creadorId'],
      vecesPreparada: map['vecesPreparada'],
      elaboracion: elaboracionList,
      fechaCreacion: DateTime.parse(map['fechaCreacion']),
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
  DateTime get fechaCreacion => _fechaCreacion;

  set vecesPreparada(int veces) {
    _vecesPreparada = veces;
  }
}
