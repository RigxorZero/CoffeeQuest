import 'package:flutter/material.dart';
import 'home_screen.dart'; // Importa HomeScreen
import 'profile_screen.dart'; // Importa ProfileScreen
import '../models/usuario.dart'; // Importa Usuario

class TabBarController extends StatelessWidget 
{
  const TabBarController({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) 
  {
    // Obtener el usuario pasado como argumento
    final Usuario usuario = ModalRoute.of(context)!.settings.arguments as Usuario;

    return DefaultTabController
    (
      length: 2, // Número de pestañas
      child: Scaffold
      (
        appBar: AppBar
        (
          title: const Text('Coffee Quest'),
          bottom: const TabBar
          (
            tabs:
            [
              Tab(text: 'Recetas'), // Pestaña para HomeScreen
              Tab(text: 'Perfil'), // Pestaña para ProfileScreen
            ],
          ),
        ),
        body: TabBarView
        (
          children: 
          [
            MyHomePage(title: 'Inicio', usuario: usuario), // La pantalla de inicio
            ProfileScreen(usuario: usuario), // La pantalla de perfil
          ],
        ),
      ),
    );
  }
}
