import 'receta_cafe.dart';

class Usuario {
  // Atributos privados
  String _nombre;
  String _email;
  String _metodoFavorito;
  String _tipoGranoFavorito;
  String _nivelMolienda;
  List<RecetaCafe> _recetasFavoritas;

  // Constructor
  Usuario({
    required String nombre,
    required String email,
    required String metodoFavorito,
    required String tipoGranoFavorito,
    required String nivelMolienda,
    List<RecetaCafe>? recetasFavoritas, // opcional
  })  : _nombre = nombre,
        _email = email,
        _metodoFavorito = metodoFavorito,
        _tipoGranoFavorito = tipoGranoFavorito,
        _nivelMolienda = nivelMolienda,
        _recetasFavoritas = recetasFavoritas ?? [];

  // Métodos

  void agregarFavorita(RecetaCafe receta) {
    if (!esFavorita(receta)) {
      _recetasFavoritas.add(receta);
    }
  }

  void eliminarFavorita(RecetaCafe receta) {
    _recetasFavoritas.remove(receta);
  }

  bool esFavorita(RecetaCafe receta) {
    return _recetasFavoritas.contains(receta);
  }

  void verFavoritas() {
    for (var receta in _recetasFavoritas) {
      print(receta.nombreReceta);
    }
  }

  void ordenarFavoritas() {
    _recetasFavoritas.sort((a, b) => a.nombreReceta.compareTo(b.nombreReceta));
  }

  void actualizarPreferencias(String metodo, String grano, String molienda) {
    _metodoFavorito = metodo;
    _tipoGranoFavorito = grano;
    _nivelMolienda = molienda;
  }

  // Método toJson para convertir un objeto Usuario en Map
  Map<String, dynamic> toJson() {
    return {
      'nombre': _nombre,
      'email': _email,
      'metodoFavorito': _metodoFavorito,
      'tipoGranoFavorito': _tipoGranoFavorito,
      'nivelMolienda': _nivelMolienda,
      'recetasFavoritas': _recetasFavoritas.map((receta) => receta.toJson()).toList(), // Convertir las recetas a JSON
    };
  }

  // Getters para acceder a los atributos privados
  String get nombre => _nombre;
  String get email => _email;
  String get metodoFavorito => _metodoFavorito;
  String get tipoGranoFavorito => _tipoGranoFavorito;
  String get nivelMolienda => _nivelMolienda;
  List<RecetaCafe> get recetasFavoritas => List.unmodifiable(_recetasFavoritas); // Retorna una copia inmutable
}
