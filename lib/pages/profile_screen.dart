import 'package:flutter/material.dart';
import '../models/usuario.dart'; // Asegúrate de importar la clase Usuario

class ProfileScreen extends StatelessWidget {
  final Usuario usuario;

  const ProfileScreen({Key? key, required this.usuario}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre: ${usuario.nombre}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text('Email: ${usuario.email}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text('Método Favorito: ${usuario.metodoFavorito}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text('Tipo de Grano Favorito: ${usuario.tipoGranoFavorito}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text('Nivel de Molienda: ${usuario.nivelMolienda}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            const Text('Recetas Favoritas:', style: TextStyle(fontSize: 24)),
            Expanded(
              child: ListView.builder(
                itemCount: usuario.recetasFavoritas.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(usuario.recetasFavoritas[index].nombreReceta),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
