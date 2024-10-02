import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';

class SessionScreen extends StatefulWidget 
{
  const SessionScreen({super.key, required this.title});

  final String title;

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> 
{
  String? _usuario;
  String? _correo;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();

  @override
  void initState()
  {
    super.initState();
    _loadUsuario(); // Cargar el usuario al iniciar
  }

  Future<void> _loadUsuario() async 
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() 
    {
      _usuario = prefs.getString('usuario');
      _correo = prefs.getString('correo');
    });

    if (_usuario != null) 
    {
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pushReplacementNamed(context, '/home', arguments: Usuario
      (
        nombre: _usuario!,
        email: _correo!,
        metodoFavorito: "Desconocido",
        tipoGranoFavorito: "Desconocido",
        nivelMolienda: "Desconocido",
      ));
    }
  }

  Future<void> _guardarUsuario(String nombreUsuario, String correo) async 
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('usuario', nombreUsuario);
    await prefs.setString('correo', correo); // Guardar el correo también
    setState(() 
    {
      _usuario = nombreUsuario;
    });

    // Redirigir a ProfileScreen y reemplazar SessionScreen
    Navigator.pushReplacementNamed(context, '/home', arguments: Usuario
    (
      nombre: nombreUsuario,
      email: correo,
      metodoFavorito: "Desconocido",
      tipoGranoFavorito: "Desconocido",
      nivelMolienda: "Desconocido",
    ));
  }

  Widget _buildCrearUsuario() 
  {
    return Column
    (
      mainAxisAlignment: MainAxisAlignment.center,
      children: 
      [
        const Text('Por favor, crea tu usuario:'),
        Padding
        (
          padding: const EdgeInsets.all(8.0),
          child: TextField
          (
            controller: _nombreController,
            decoration: const InputDecoration(labelText: 'Nombre de usuario'),
          ),
        ),
        Padding
        (
          padding: const EdgeInsets.all(8.0),
          child: TextField
          (
            controller: _correoController,
            decoration: const InputDecoration(labelText: 'Correo electrónico'),
            keyboardType: TextInputType.emailAddress,
          ),
        ),
        ElevatedButton
        (
          onPressed: () 
          {
            if (_nombreController.text.isNotEmpty && _correoController.text.isNotEmpty) 
            {
              _guardarUsuario(_nombreController.text, _correoController.text);
            }
          },
          child: const Text('Crear Usuario'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar
      (
        title: Text(widget.title),
      ),
      body: Center
      (
        child: _usuario == null 
        ? _buildCrearUsuario() 
        : Column
        (
          mainAxisAlignment: MainAxisAlignment.center,
          children: 
          [
            Text('Bienvenido, $_usuario!', style: const TextStyle(fontSize: 24)), // Mensaje de bienvenida
            const SizedBox(height: 20),
            const CircularProgressIndicator(), // Indicador de carga mientras se espera
          ],
        ),
      ),
    );
  }
}
