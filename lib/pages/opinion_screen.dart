import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class OpinionScreen extends StatefulWidget {
  @override
  _OpinionScreenState createState() => _OpinionScreenState();
}

class _OpinionScreenState extends State<OpinionScreen> {
  List<Map<String, dynamic>> usabilidad = [];
  List<Map<String, dynamic>> contenido = [];
  List<Map<String, dynamic>> compartir = [];
  String userId = "";
  Map<String, int> respuestas = {};

  @override
  void initState() {
    super.initState();
    _cargarPreguntas();
  }

  // Cargar las preguntas del archivo JSON
  Future<void> _cargarPreguntas() async {
    final String response = await rootBundle.loadString('assets/validacion.json');
    final data = json.decode(response);
    setState(() {
      usabilidad = List<Map<String, dynamic>>.from(data['usabilidad']);
      contenido = List<Map<String, dynamic>>.from(data['contenido']);
      compartir = List<Map<String, dynamic>>.from(data['compartir']);
    });
  }

  // Enviar las respuestas por correo
  Future<void> _enviarCorreo() async 
  {
    final Email email = Email(
      body: _generarCorreo(),
      subject: 'Retroalimentación de la aplicación',
      recipients: ['hvillalobos22@alumnos.utalca.cl'], // Cambia al correo del desarrollador
      isHTML: false,
    );
    
    try {
      await FlutterEmailSender.send(email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Retroalimentación enviada!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar el correo: $e')),
      );
    }
  }

  // Generar el cuerpo del correo con las respuestas
  String _generarCorreo() {
    String respuestasCorreo = 'ID de Usuario: $userId\n\n';
    
    // Usabilidad
    respuestasCorreo += 'Usabilidad:\n';
    usabilidad.forEach((pregunta) {
      respuestasCorreo += '${pregunta['titulo']}\nRespuesta: ${pregunta['valor']} estrellas\n\n';
    });
    
    // Contenido
    respuestasCorreo += 'Contenido:\n';
    contenido.forEach((pregunta) {
      respuestasCorreo += '${pregunta['titulo']}\nRespuesta: ${pregunta['valor']} estrellas\n\n';
    });

    // Compartir
    respuestasCorreo += 'Compartir:\n';
    compartir.forEach((pregunta) {
      respuestasCorreo += '${pregunta['titulo']}\nRespuesta: ${pregunta['valor']} estrellas\n\n';
    });

    return respuestasCorreo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tu Opinión')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de ID de usuario
            TextField(
              onChanged: (value) {
                setState(() {
                  userId = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Tu ID',
                hintText: 'Introduce tu ID de usuario',
              ),
            ),
            SizedBox(height: 20),
            
            // Mostrar preguntas de Usabilidad
            Text('Usabilidad', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...usabilidad.map((pregunta) {
              return ListTile(
                title: Text(pregunta['titulo']),
                subtitle: Slider(
                  min: 0,
                  max: 5,
                  divisions: 5,
                  value: (pregunta['valor'] ?? 0).toDouble(),
                  onChanged: (value) {
                    setState(() {
                      pregunta['valor'] = value.toInt();
                    });
                  },
                ),
                trailing: Text('${pregunta['valor']} estrellas'),
              );
            }).toList(),
            SizedBox(height: 20),
            
            // Mostrar preguntas de Contenido
            Text('Contenido', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...contenido.map((pregunta) {
              return ListTile(
                title: Text(pregunta['titulo']),
                subtitle: Slider(
                  min: 0,
                  max: 5,
                  divisions: 5,
                  value: (pregunta['valor'] ?? 0).toDouble(),
                  onChanged: (value) {
                    setState(() {
                      pregunta['valor'] = value.toInt();
                    });
                  },
                ),
                trailing: Text('${pregunta['valor']} estrellas'),
              );
            }).toList(),
            SizedBox(height: 20),
            
            // Mostrar preguntas de Compartir
            Text('Compartir', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...compartir.map((pregunta) {
              return ListTile(
                title: Text(pregunta['titulo']),
                subtitle: Slider(
                  min: 0,
                  max: 5,
                  divisions: 5,
                  value: (pregunta['valor'] ?? 0).toDouble(),
                  onChanged: (value) {
                    setState(() {
                      pregunta['valor'] = value.toInt();
                    });
                  },
                ),
                trailing: Text('${pregunta['valor']} estrellas'),
              );
            }).toList(),
            SizedBox(height: 20),
            
            // Botón para enviar retroalimentación
            ElevatedButton(
              onPressed: _enviarCorreo,
              child: Text('Enviar retroalimentación'),
            ),
          ],
        ),
      ),
    );
  }
}
