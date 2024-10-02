import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import '../models/usuario.dart';

class TabBarController extends StatelessWidget 
{
  const TabBarController({super.key});

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
              Tab(text: 'Recetas'),
              Tab(text: 'Perfil'),
            ],
          ),
        ),
        body: TabBarView
        (
          children: 
          [
            MyHomePage(title: 'Inicio', usuario: usuario),
            ProfileScreen(usuario: usuario),
          ],
        ),
      ),
    );
  }
}
