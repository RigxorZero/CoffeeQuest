class ProductoRelacionado 
{
  // Atributos
  String _nombreProducto;
  String _tipo;
  String _descripcion;
  int _precio;
  String _enlaceCompra;

  // Constructor
  ProductoRelacionado
  (
    {
    required String nombreProducto,
    required String tipo,
    required String descripcion,
    required String precio,
    required String enlaceCompra,
    }
  ) : _nombreProducto = nombreProducto,
      _tipo = tipo,
      _descripcion = descripcion,
      _precio = int.parse(precio),
      _enlaceCompra = enlaceCompra;

  // Métodos
  void mostrarDetallesProducto() 
  {
  print("Nombre: $_nombreProducto\nTipo: $_tipo\nDescripción: $_descripcion\nPrecio: \$$_precio\nEnlace de compra: $_enlaceCompra");
  }
}