import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../models/database_helper.dart';  // Importa tu helper para la base de datos

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key, required this.title});

  final String title;

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  String? _usuario;
  String? _correo;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  
  final DatabaseHelper dbHelper = DatabaseHelper();  // Instancia de DatabaseHelper

  @override
  void initState() {
    super.initState();
    _loadUsuario(); // Cargar el usuario al iniciar
  }

  // Función para cargar el usuario desde la base de datos
  Future<void> _loadUsuario() async 
  {
    var usuarios = await dbHelper.obtenerUsuarios();
    
    // Si encontramos usuarios en la base de datos
    if (usuarios.isNotEmpty) 
    {
      
      for (var usuario in usuarios) 
      {
        if (usuario.nombre != "CoffeeQuest") 
        {
          setState(() 
          {
            _usuario = usuario.nombre;  // Establecemos el nombre del usuario
            _correo = usuario.email;    // Establecemos el correo del usuario
          });

          Navigator.pushReplacementNamed(
            context, 
            '/home', 
            arguments: usuario,  // Pasamos el usuario como argumento a la pantalla de inicio
          );
          return;  // Salir del bucle y la función una vez que hemos encontrado el usuario
        }
      }
    }

    // Si no se encontró ningún usuario con nombre distinto a "CoffeeQuest"
    print("No se encontró un usuario válido distinto de 'CoffeeQuest'.");
  }


  // Verifica si el usuario ya existe en la base de datos
  Future<bool> verificarUsuarioExistente() async {
    var usuarios = await dbHelper.obtenerUsuarios();  // Obtén los usuarios desde la DB
    return usuarios.isNotEmpty;
  }

  // Función para guardar un nuevo usuario en la base de datos
  Future<void> _guardarUsuario(String nombreUsuario, String correo) async {
    Usuario nuevoUsuario = Usuario(
      nombre: nombreUsuario,
      email: correo,
      metodoFavorito: "Desconocido",
      tipoGranoFavorito: "Desconocido",
      nivelMolienda: "Desconocido",
      recetasFavoritas: [1],
    );

    // Guarda el usuario en la base de datos
    nuevoUsuario.id = await dbHelper.insertarUsuario(nuevoUsuario);

    setState(() {
      _usuario = nombreUsuario;
      _correo = correo;
    });

    // Navega al home con el usuario recién creado
    Navigator.pushReplacementNamed(
      context,
      '/home',
      arguments: nuevoUsuario,
    );
  }

  // Widget para crear un usuario
  Widget _buildCrearUsuario() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Por favor, crea tu usuario:'),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _nombreController,
            decoration: const InputDecoration(labelText: 'Nombre de usuario'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _correoController,
            decoration: const InputDecoration(labelText: 'Correo electrónico'),
            keyboardType: TextInputType.emailAddress,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nombreController.text.isNotEmpty && _correoController.text.isNotEmpty) {
              _guardarUsuario(_nombreController.text, _correoController.text);
            }
          },
          child: const Text('Crear Usuario'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _usuario == null
            ? _buildCrearUsuario()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Bienvenido, $_usuario!', style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(),
                ],
              ),
      ),
    );
  }
}
