import 'comentarios.dart';
import 'equipo.dart';
import 'ingrediente.dart';
import 'usuario.dart';
import 'dart:io';
import 'dart:convert';


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
  List<String> _elaboracion;
  List<Comentarios> _comentarios;

  // Constructor
  RecetaCafe
  ({
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
    required List<String> elaboracion,
    List<Comentarios>? comentarios,
  })  : _nombreReceta = nombreReceta,
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
        _elaboracion = elaboracion, // Asignar los pasos de la receta
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
    List<Ingrediente> ingredientesReceta = (json['ingredientes'] as List).map((ingredienteJson) 
    {
      final ingredienteCargado = ingredientesCargados.firstWhere
      (
        (ingrediente) => ingrediente.nombreIngrediente == ingredienteJson['nombreIngrediente'],
        orElse: () => Ingrediente
        (
          nombreIngrediente: ingredienteJson['nombreIngrediente'],
          cantidad: "0",
          unidadMedida: ingredienteJson['unidadMedida'],
        ),
      );
      return Ingrediente
      (
        nombreIngrediente: ingredienteCargado.nombreIngrediente,
        cantidad: ingredienteJson['cantidad'],
        unidadMedida: ingredienteCargado.unidadMedida,
      );
    }).toList();

    // Cargar equipos desde el JSON
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
      elaboracion: List<String>.from(json['elaboracion']),
      comentarios: [],
    );
  }

    void agregarComentario(String contenido, int calificacion, Usuario usuarioCreador) 
    {
      Comentarios nuevoComentario = Comentarios
      (
        contenido: contenido,
        fecha: DateTime.now(),
        calificacion: calificacion,
        creador: usuarioCreador,
      );

    _comentarios.add(nuevoComentario);

    _calificacionPromedio = (_calificacionPromedio * _numCalificaciones + calificacion) / (_numCalificaciones + 1);
    _numCalificaciones++;
  }

@override
  bool operator ==(Object other) 
  {
    if (identical(this, other)) return true;
    return other is RecetaCafe && other._nombreReceta == _nombreReceta;
  }

  @override
  int get hashCode => _nombreReceta.hashCode;

  // Getters
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
  List<String> get elaboracion => _elaboracion;
  List<Comentarios> get comentarios => List.unmodifiable(_comentarios); // Retorna una copia inmutable

  Map<String, dynamic> toJson() 
    {
      return 
      {
        'nombreReceta': _nombreReceta,
        'descripcion': _descripcion,
        'ingredientes': _ingredientes.map((ingrediente) => ingrediente.toJson()).toList(),
        'metodo': _metodo,
        'equipoNecesario': _equipoNecesario.map((equipo) => equipo.toJson()).toList(),
        'dificultad': _dificultad,
        'tiempoPreparacion': _tiempoPreparacion,
        'imagen': _imagen,
        'calificacionPromedio': _calificacionPromedio,
        'numCalificaciones': _numCalificaciones,
        'usuarioCreador': _usuarioCreador.nombre,
        'etiquetas': _etiquetas,
        'elaboracion': _elaboracion,
        'comentarios': _comentarios.map((comentario) => comentario.toJson()).toList(),
      };
    }

  Future<void> agregarReceta(RecetaCafe receta) async {
    try {
      final file = File('recetas.json');
      
      // Leer el archivo actual de recetas
      String fileContents = await file.readAsString();
      
      // Decodificar el contenido JSON
      List<dynamic> recetasJson = json.decode(fileContents);
      
      // Agregar la nueva receta
      recetasJson.add(receta.toJson());
      
      // Volver a escribir el archivo con la receta agregada
      await file.writeAsString(json.encode(recetasJson), mode: FileMode.write);
      
      print("Receta guardada correctamente");
    } catch (e) {
      print("Error al guardar la receta: $e");
    }
  }
}
