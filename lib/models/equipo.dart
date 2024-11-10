class Equipo {
  // Atributos
  String _nombreEquipo;
  String _tipo;
  String _descripcion;
  String _imagen;
  List<String> _enlacesCompra;

  // Constructor
  Equipo({
    required String nombreEquipo,
    required String tipo,
    required String descripcion,
    required String imagen,
    required List<String> enlacesCompra,
  })  : _nombreEquipo = nombreEquipo,
        _tipo = tipo,
        _descripcion = descripcion,
        _imagen = imagen,
        _enlacesCompra = enlacesCompra;

  // Método
  factory Equipo.fromJson(Map<String, dynamic> json) {
    return Equipo(
      nombreEquipo: json['nombreEquipo'],
      tipo: json['tipo'],
      descripcion: json['descripcion'],
      imagen: json['imagen'],
      enlacesCompra: List<String>.from(json['enlacesCompra'] ?? []),
    );
  }

  // Método toJson para convertir un objeto Equipo en Map
  Map<String, dynamic> toJson() {
    return {
      'nombreEquipo': _nombreEquipo,
      'tipo': _tipo,
      'descripcion': _descripcion,
      'imagen': _imagen,
      'enlacesCompra': _enlacesCompra,
    };
  }

  // Getters para acceder a los atributos privados
  String get nombreEquipo => _nombreEquipo;
  String get tipo => _tipo;
  String get descripcion => _descripcion;
  String get imagen => _imagen;
  List<String> get enlacesCompra => _enlacesCompra;
}
