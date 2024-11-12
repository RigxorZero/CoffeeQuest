import 'package:coffee_quest/models/receta_cafe.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';
import '../models/receta_cafe.dart';
import 'details_receta_screen.dart';
import '../models/database_helper.dart';

class ProfileScreen extends StatefulWidget {
  final Usuario usuario;
  const ProfileScreen({super.key, required this.usuario});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<String> _metodos = ['Desconocido', 'Espresso', 'Prensa Francesa', 'Cafetera Italiana', 'Cafetera de Goteo'];
  final List<String> _tiposGrano = ['Desconocido', 'Arábica', 'Robusta', 'Mezcla'];
  final List<String> _nivelesMolienda = ['Desconocido', 'Fino', 'Medio', 'Grueso'];
  final DatabaseHelper dbHelper = DatabaseHelper();

  late String nombre;
  late Usuario usuarioActual;
  late String _metodoSeleccionado = 'Desconocido';
  late String _tipoGranoSeleccionado = 'Desconocido';
  late String _nivelMoliendaSeleccionado = 'Desconocido';

  @override
  void initState() {
    super.initState();
    nombre = widget.usuario.nombre;
    usuarioActual = widget.usuario;
    _loadPreferences(); // Cargar las preferencias guardadas al iniciar
  }

  // Carga de preferencias guardadas
  Future<void> _loadPreferences() async {
    // Cargar preferencias desde la base de datos
    Usuario? usuarioDB = await dbHelper.obtenerUsuario(nombre);
    if (usuarioDB != null) {
      setState(() {
        _metodoSeleccionado = usuarioDB.metodoFavorito;
        _tipoGranoSeleccionado = usuarioDB.tipoGranoFavorito;
        _nivelMoliendaSeleccionado = usuarioDB.nivelMolienda;
      });
    }
  }

  Future<List<RecetaCafe>> _loadRecetasFavoritas() async {
    List<int> recetaIds = usuarioActual.recetasFavoritas;

    // Verificar que la lista de IDs no esté vacía
    if (recetaIds.isEmpty) {
      print('No hay recetas favoritas para cargar.');
      return [];
    }

    // Obtener las recetas completas utilizando los IDs
    List<RecetaCafe> recetas = await dbHelper.obtenerRecetasPorIds(recetaIds);
    return recetas;
  }

  // Guardar las preferencias seleccionadas
  Future<void> _savePreferences() async {
    // Guardar preferencias en SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('metodoSeleccionado', _metodoSeleccionado);
    await prefs.setString('tipoGranoSeleccionado', _tipoGranoSeleccionado);
    await prefs.setString('nivelMoliendaSeleccionado', _nivelMoliendaSeleccionado);

    // Guardar las preferencias en la base de datos
    widget.usuario.actualizarPreferencias(
      _metodoSeleccionado,
      _tipoGranoSeleccionado,
      _nivelMoliendaSeleccionado,
    );
    await dbHelper.updateUsuario(usuarioActual);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: const Color(0xFFD9AB82),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Vuelve a la pantalla anterior
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Nombre:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 5),
                Text(
                  widget.usuario.nombre,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  'Email:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 5),
                Text(
                  widget.usuario.email,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text('Preferencias de Café', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // Dropdown para Método de Preparación
            const Text('Método de Preparación:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _metodoSeleccionado,
              items: _metodos.map((String metodo) {
                return DropdownMenuItem<String>(value: metodo, child: Text(metodo));
              }).toList(),
              onChanged: (String? nuevoMetodo) {
                setState(() {
                  _metodoSeleccionado = nuevoMetodo!;
                });
              },
            ),
            const SizedBox(height: 10),
            const Text('Tipo de Grano Favorito:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _tipoGranoSeleccionado,
              items: _tiposGrano.map((String tipo) {
                return DropdownMenuItem<String>(value: tipo, child: Text(tipo));
              }).toList(),
              onChanged: (String? nuevoTipo) {
                setState(() {
                  _tipoGranoSeleccionado = nuevoTipo!;
                });
              },
            ),
            const SizedBox(height: 10),
            const Text('Nivel de Molienda:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _nivelMoliendaSeleccionado,
              items: _nivelesMolienda.map((String nivel) {
                return DropdownMenuItem<String>(value: nivel, child: Text(nivel));
              }).toList(),
              onChanged: (String? nuevoNivel) {
                setState(() {
                  _nivelMoliendaSeleccionado = nuevoNivel!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.usuario.actualizarPreferencias(
                    _metodoSeleccionado,
                    _tipoGranoSeleccionado,
                    _nivelMoliendaSeleccionado,
                  );
                  _savePreferences();
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preferencias actualizadas')));
              },
              child: const Text('Guardar Preferencias'),
            ),
            const SizedBox(height: 20),
            const Text('Recetas Favoritas:', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            // Usamos FutureBuilder para cargar las recetas favoritas
            Expanded(
              child: FutureBuilder<List<RecetaCafe>>(
                future: _loadRecetasFavoritas(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No tienes recetas favoritas.'));
                  } else {
                    var recetasFavoritasCargadas = snapshot.data!;
                    return ListView.builder(
                      itemCount: recetasFavoritasCargadas.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(recetasFavoritasCargadas[index].nombreReceta),
                            subtitle: Text(recetasFavoritasCargadas[index].descripcion),
                            leading: Image.asset(recetasFavoritasCargadas[index].imagen, width: 50, height: 50),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetalleRecetaScreen(
                                    receta: recetasFavoritasCargadas[index],
                                    usuarioActual: widget.usuario,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
