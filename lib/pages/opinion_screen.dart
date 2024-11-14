import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

// ignore: use_key_in_widget_constructors
class OpinionScreen extends StatefulWidget {
  @override
  _OpinionScreenState createState() => _OpinionScreenState();
}

class _OpinionScreenState extends State<OpinionScreen> {
  List<Map<String, dynamic>> usabilidad = [];
  List<Map<String, dynamic>> contenido = [];
  List<Map<String, dynamic>> compartir = [];
  String nombreUsuario = "";
  String seleccionTipo = "Alumno trabajando en su piloto"; // Valor por defecto
  String relacionConDesarrollador = "";
  Map<String, int> respuestas = {};

  // Opciones para el dropdown
  final List<String> tipoUsuarioOptions = [
    "Alumno trabajando en su piloto",
    "Persona del área de programación",
    "Persona sin conocimientos técnicos"
  ];

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
  Future<void> _enviarCorreo() async {
    final Email email = Email(
      body: _generarCorreo(),
      subject: 'Retroalimentación de la aplicación',
      recipients: ['hvillalobos22@alumnos.utalca.cl'], // Cambia al correo del desarrollador
      isHTML: true,
    );
    
    try {
      await FlutterEmailSender.send(email);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Retroalimentación enviada!')),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar el correo: $e')),
      );
      print('Error al enviar el correo: $e');
    }
  }

  // Generar el cuerpo del correo con las respuestas
  String _generarCorreo() {
    String respuestasCorreo = 'Nombre de Usuario: $nombreUsuario\nTipo: $seleccionTipo\nRelación con el desarrollador: $relacionConDesarrollador\n\n';
    
    // Usabilidad
    respuestasCorreo += 'Usabilidad:\n';
    usabilidad.forEach((pregunta) {
      respuestasCorreo += '${pregunta['titulo']}\nRespuesta: ${pregunta['valor']} estrellas\n\n';
    });
    
    // Añadir más espacio entre las secciones
    respuestasCorreo += '\n'; // Agregar un salto de línea extra
    
    // Contenido
    respuestasCorreo += 'Contenido:\n';
    contenido.forEach((pregunta) {
      respuestasCorreo += '${pregunta['titulo']}\nRespuesta: ${pregunta['valor']} estrellas\n\n';
    });

    // Añadir más espacio entre las secciones
    respuestasCorreo += '\n'; // Otro salto de línea

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
            // Campo de nombre de usuario
            TextField(
              onChanged: (value) {
                setState(() {
                  nombreUsuario = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Tu nombre',
                hintText: 'Introduce tu nombre',
              ),
            ),
            SizedBox(height: 20),
            
            // Dropdown para seleccionar el tipo de usuario
            DropdownButton<String>(
              value: seleccionTipo,
              onChanged: (String? newValue) {
                setState(() {
                  seleccionTipo = newValue!;
                });
              },
              items: tipoUsuarioOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            // Campo de relación con el desarrollador
            TextField(
              onChanged: (value) {
                setState(() {
                  relacionConDesarrollador = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Relación con el desarrollador',
                hintText: 'Ej. Colega, Familiar, etc.',
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
