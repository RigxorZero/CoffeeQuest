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
        title: Text(nombreEquipo),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(imagen, width: double.infinity, height: 200, fit: BoxFit.cover),
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
                    leading: const Icon(Icons.shopping_cart, color: Colors.blue),
                    title: Text('Comprar aquí', style: TextStyle(fontSize: 16)),
                    trailing: const Icon(Icons.arrow_forward, color: Colors.blue),
                    tileColor: Colors.blue.shade50,
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
