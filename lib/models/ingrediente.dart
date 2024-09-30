class Ingrediente 
{
  // Atributos privados
  String _nombreIngrediente;
  String _cantidad;
  String _unidadMedida;

  // Constructor
  Ingrediente
  (
    {
    required String nombreIngrediente,
    required String cantidad,
    required String unidadMedida,
    }
  ) : _nombreIngrediente = nombreIngrediente,
      _cantidad = cantidad,
      _unidadMedida = unidadMedida;

    // Metodos
    factory Ingrediente.fromJson(Map<String, dynamic> json) 
    {
      return Ingrediente
      (
        nombreIngrediente: json['nombreIngrediente'],
        cantidad: json['cantidad'],
        unidadMedida: json['unidadMedida'],
      );
    }

    void detalleIngrediente()
    {
      print("$_nombreIngrediente: $_cantidad $_unidadMedida");
    }

    // Getters para acceder a los atributos privados
    String get nombreIngrediente => _nombreIngrediente;
    String get cantidad => _cantidad;
    String get unidadMedida => _unidadMedida;

    // Setter
    set cantidad(String cantidad) => _cantidad = cantidad;
}