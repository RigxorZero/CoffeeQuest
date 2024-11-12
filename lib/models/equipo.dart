class Equipo 
{
  final int? id;
  final String nombreEquipo;
  final String tipo;
  final String descripcion;
  final String imagen;
  final List<String> enlacesCompra;

  Equipo
  ({
    this.id,
    required this.nombreEquipo,
    required this.tipo,
    required this.descripcion,
    required this.imagen,
    required this.enlacesCompra,
  });

  // Convertir el objeto Equipo a un Map para almacenarlo en la base de datos
  Map<String, dynamic> toMap() 
  {
    return 
    {
      'id': id,
      'nombreEquipo': nombreEquipo,
      'tipo': tipo,
      'descripcion': descripcion,
      'imagen': imagen,
      'enlacesCompra': enlacesCompra.join(','),  // Convertir la lista a una cadena
    };
  }

  // Crear un objeto Equipo a partir de un Map (extraído de la base de datos)
  factory Equipo.fromMap(Map<String, dynamic> map) 
  {
    return Equipo
    (
      id: map['id'],
      nombreEquipo: map['nombreEquipo'],
      tipo: map['tipo'],
      descripcion: map['descripcion'],
      imagen: map['imagen'],
      enlacesCompra: map['enlacesCompra'].split(',').toList(), // Convertir la cadena a lista
    );
  }
}
