import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RecomendacionEquipoScreen extends StatelessWidget {
  final String nombreEquipo;
  final String descripcion;
  final String imagen;
  final List<String> enlacesCompra;

  const RecomendacionEquipoScreen({
    super.key,
    required this.nombreEquipo,
    required this.descripcion,
    required this.imagen,
    required this.enlacesCompra,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD9AB82),
        title: Text(nombreEquipo),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(imagen, width: double.infinity, height: 200, fit: BoxFit.contain),
            const SizedBox(height: 20),
            Text(nombreEquipo, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(descripcion, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            const Text('Comprar en:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            // Lista visual mejorada con iconos y espaciado
            Column(
              children: enlacesCompra.map((enlace) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: const Icon(Icons.shopping_cart, color: Color(0xFF40352B)),
                    title: const Text('Comprar aquí', style: TextStyle(fontSize: 16, color: Color(0xFFF2E3D5))),
                    trailing: const Icon(Icons.arrow_forward, color: Color(0xFF40352B)),
                    tileColor: const Color(0xFFA6785D),
                    onTap: () {
                      _launchUrl(enlace);
                    },
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String enlace) async {
    Uri url = Uri.parse(enlace);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $enlace');
    }
  }
}
