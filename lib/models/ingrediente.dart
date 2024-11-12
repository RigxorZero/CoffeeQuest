class Ingrediente 
{
  final int? id;
  final String nombreIngrediente;
  final String cantidad;
  final String unidadMedida;

  // Constructor
  Ingrediente
  ({
    this.id,
    required this.nombreIngrediente,
    required this.cantidad,
    required this.unidadMedida,
  });

  // Convertir el objeto Ingrediente a un Map para almacenarlo en la base de datos
  Map<String, dynamic> toMap() 
  {
    return 
    {
      'id': id,
      'nombreIngrediente': nombreIngrediente,
      'cantidad': cantidad,
      'unidadMedida': unidadMedida,
    };
  }

  // Crear un objeto Ingrediente a partir de un Map (extraído de la base de datos)
  factory Ingrediente.fromMap(Map<String, dynamic> map) 
  {
    return Ingrediente
    (
      id: map['id'],
      nombreIngrediente: map['nombreIngrediente'],
      cantidad: map['cantidad'],
      unidadMedida: map['unidadMedida'],
    );
  }
}
