class Equipo 
{
  // Atributos
  String _nombreEquipo;  
  String _tipo;          
  String _descripcion;   
  String _imagen;        

  // Constructor
  Equipo
  (
    {
    required String nombreEquipo,
    required String tipo,
    required String descripcion,
    required String imagen,
    }
  )  : _nombreEquipo = nombreEquipo,
        _tipo = tipo,
        _descripcion = descripcion,
        _imagen = imagen;

  // Método

  factory Equipo.fromJson(Map<String, dynamic> json) 
  {
    return Equipo
    (
      nombreEquipo: json['nombreEquipo'],
      tipo: json['tipo'],
      descripcion: json['descripcion'],
      imagen: json['imagen'],
    );
  }

  void obtenerRecomendacion()
  {
    
  }

  // Getters para acceder a los atributos privados
  String get nombreEquipo => _nombreEquipo;
  String get tipo => _tipo;
  String get descripcion => _descripcion;
  String get imagen => _imagen;
}
