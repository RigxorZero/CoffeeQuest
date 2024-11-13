class Ingrediente 
{
  final int? ingredienteId;
  final String nombreIngrediente;
  String? cantidad;
  final String unidadMedida;

  // Constructor
  Ingrediente
  ({
    this.ingredienteId,
    required this.nombreIngrediente,
    required this.cantidad,
    required this.unidadMedida,
  });

  // Convertir el objeto Ingrediente a un Map para almacenarlo en la base de datos
  Map<String, dynamic> toMap() 
  {
    return 
    {
      'ingredienteId': ingredienteId,
      'nombreIngrediente': nombreIngrediente,
      'unidadMedida': unidadMedida,
    };
  }

  // Crear un objeto Ingrediente a partir de un Map (extraído de la base de datos)
  factory Ingrediente.fromMap(Map<String, dynamic> map) 
  {
    return Ingrediente
    (
      ingredienteId: map['ingredienteId'],
      nombreIngrediente: map['nombreIngrediente'],
      cantidad: map['cantidad'],
      unidadMedida: map['unidadMedida'],
    );
  }
}
