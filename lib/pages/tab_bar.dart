import 'package:coffee_quest/pages/recetas_screen.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import '../models/usuario.dart';

class TabBarController extends StatelessWidget {
  const TabBarController({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener el usuario pasado como argumento
    final Usuario usuario = ModalRoute.of(context)!.settings.arguments as Usuario;

    return DefaultTabController(
      length: 2, // Número de pestañas
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Text('Coffee Quest'),  // Título de la app
              const Spacer(),  // Empuja el icono hacia la derecha
              GestureDetector(
                onTap: () {
                  // Acción para abrir el perfil del usuario
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(usuario: usuario),
                    ),
                  );
                },
                child: CircleAvatar(
                  backgroundImage: AssetImage('assets/images/user.png'),
                  radius: 20,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFD9AB82),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Mis Recetas'),
              Tab(text: 'Barista'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            RecetasScreen(title: 'Inicio', usuario: usuario),
            MyHomePage(title: 'Inicio', usuario: usuario),
          ],
        ),
      ),
    );
  }
}
