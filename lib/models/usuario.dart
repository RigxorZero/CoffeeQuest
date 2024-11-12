class Usuario 
{
  int? id; // ID único para la base de datos
  String _nombre;
  String _email;
  String _metodoFavorito;
  String _tipoGranoFavorito;
  String _nivelMolienda;
  List<int> recetasFavoritas; // Lista de IDs de las recetas favoritas

  Usuario
  ({
    this.id,
    required String nombre,
    required String email,
    required String metodoFavorito,
    required String tipoGranoFavorito,
    required String nivelMolienda,
    this.recetasFavoritas = const [], // Inicializar con una lista vacía
  })  : _nombre = nombre,
        _email = email,
        _metodoFavorito = metodoFavorito,
        _tipoGranoFavorito = tipoGranoFavorito,
        _nivelMolienda = nivelMolienda;

  // Convertir el Usuario a un Map para la base de datos
  Map<String, dynamic> toMap() 
  {
    return 
    {
      'id': id,
      'nombre': _nombre,
      'email': _email,
      'metodoFavorito': _metodoFavorito,
      'tipoGranoFavorito': _tipoGranoFavorito,
      'nivelMolienda': _nivelMolienda,
      'recetasFavoritas': recetasFavoritas.join(','), // Convertir lista a string
    };
  }

  // Crear un Usuario a partir de un Map
  factory Usuario.fromMap(Map<String, dynamic> map) 
  {
    return Usuario
    (
      id: map['id'],
      nombre: map['nombre'],
      email: map['email'],
      metodoFavorito: map['metodoFavorito'],
      tipoGranoFavorito: map['tipoGranoFavorito'],
      nivelMolienda: map['nivelMolienda'],
      recetasFavoritas: map['recetasFavoritas'] != null
          ? List<int>.from(map['recetasFavoritas'].split(',').map((e) => int.parse(e)))
          : [],
    );
  }

  // Agregar una receta favorita
  void agregarFavorita(int recetaId) 
  {
    if (!recetasFavoritas.contains(recetaId)) 
    {
      recetasFavoritas.add(recetaId);
    }
  }

  // Eliminar una receta favorita
  void eliminarFavorita(int recetaId) 
  {
    recetasFavoritas.remove(recetaId);
  }

  bool esFavorita(int recetaId) 
  {
    return recetasFavoritas.contains(recetaId);
  }

  // Método para actualizar las preferencias del usuario
  void actualizarPreferencias(String metodo, String grano, String molienda) 
  {
    _metodoFavorito = metodo;
    _tipoGranoFavorito = grano;
    _nivelMolienda = molienda;
  }

  // Getters para acceder a los atributos privados
  String get nombre => _nombre;
  String get email => _email;
  String get metodoFavorito => _metodoFavorito;
  String get tipoGranoFavorito => _tipoGranoFavorito;
  String get nivelMolienda => _nivelMolienda;
}
