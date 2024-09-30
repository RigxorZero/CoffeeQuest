import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart'; // Asegúrate de importar la clase Usuario

class ProfileScreen extends StatefulWidget 
{
  final Usuario usuario;

  const ProfileScreen({super.key, required this.usuario});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> 
{
  // Opciones predefinidas
  final List<String> _metodos = ['Desconocido', 'Espresso', 'Prensa Francesa', 'Cafetera Italiana', 'Cafetera de Goteo'];
  final List<String> _tiposGrano = ['Desconocido', 'Arábica', 'Robusta', 'Mezcla'];
  final List<String> _nivelesMolienda = ['Desconocido', 'Fino', 'Medio', 'Grueso'];

  // Valores seleccionados (Por defecto: 'Desconocido' para prevenir errores)
  late String _metodoSeleccionado = 'Desconocido';
  late String _tipoGranoSeleccionado = 'Desconocido';
  late String _nivelMoliendaSeleccionado = 'Desconocido';

  @override
  void initState() 
  {
    super.initState();
    _loadPreferences(); // Cargar las preferencias guardadas al iniciar
  }

  // Carga de preferencias guardadas
  Future<void> _loadPreferences() async 
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() 
    {
      _metodoSeleccionado = prefs.getString('metodoSeleccionado') ?? widget.usuario.metodoFavorito;
      _tipoGranoSeleccionado = prefs.getString('tipoGranoSeleccionado') ?? widget.usuario.tipoGranoFavorito;
      _nivelMoliendaSeleccionado = prefs.getString('nivelMoliendaSeleccionado') ?? widget.usuario.nivelMolienda;
    });
  }

  // Guardar las preferencias seleccionadas
  Future<void> _savePreferences() async 
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('metodoSeleccionado', _metodoSeleccionado);
    await prefs.setString('tipoGranoSeleccionado', _tipoGranoSeleccionado);
    await prefs.setString('nivelMoliendaSeleccionado', _nivelMoliendaSeleccionado);
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (

      body: Padding
      (
        padding: const EdgeInsets.all(16.0),
        child: Column
        (
          crossAxisAlignment: CrossAxisAlignment.start,
          children: 
          [
            Text('Nombre: ${widget.usuario.nombre}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text('Email: ${widget.usuario.email}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            const Text('Preferencias de Café', style: TextStyle(fontSize: 24)),

            const SizedBox(height: 10),
            // Dropdown para Método de Preparación
            const Text('Método de Preparación:', style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              value: _metodoSeleccionado,
              items: _metodos.map((String metodo) 
              {
                return DropdownMenuItem<String>
                (
                  value: metodo,
                  child: Text(metodo),
                );
              }).toList(),
              onChanged: (String? nuevoMetodo) 
              {
                setState(() 
                {
                  _metodoSeleccionado = nuevoMetodo!;
                });
              },
            ),
            const SizedBox(height: 10),

            // Dropdown para Tipo de Grano
            const Text('Tipo de Grano Favorito:', style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              value: _tipoGranoSeleccionado,
              items: _tiposGrano.map((String tipo) 
              {
                return DropdownMenuItem<String>
                (
                  value: tipo,
                  child: Text(tipo),
                );
              }).toList(),
              onChanged: (String? nuevoTipo) 
              {
                setState(() 
                {
                  _tipoGranoSeleccionado = nuevoTipo!;
                });
              },
            ),
            const SizedBox(height: 10),

            // Dropdown para Nivel de Molienda
            const Text('Nivel de Molienda:', style: TextStyle(fontSize: 18)),
            DropdownButton<String>
            (
              value: _nivelMoliendaSeleccionado,
              items: _nivelesMolienda.map((String nivel) 
              {
                return DropdownMenuItem<String>
                (
                  value: nivel,
                  child: Text(nivel),
                );
              }).toList(),
              onChanged: (String? nuevoNivel) 
              {
                setState(() 
                {
                  _nivelMoliendaSeleccionado = nuevoNivel!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Botón para guardar las preferencias actualizadas
            ElevatedButton
            (
              onPressed: () 
              {
                setState(()
                {
                  // Guardar preferencias en el objeto usuario
                  widget.usuario.actualizarPreferencias
                  (
                    _metodoSeleccionado,
                    _tipoGranoSeleccionado,
                    _nivelMoliendaSeleccionado,
                  );
                  // Guardar preferencias localmente
                  _savePreferences();
                });
                ScaffoldMessenger.of(context).showSnackBar
                (
                  const SnackBar(content: Text('Preferencias actualizadas')),
                );
              },
              child: const Text('Guardar Preferencias'),
            ),

            const SizedBox(height: 20),
            const Text('Recetas Favoritas:', style: TextStyle(fontSize: 24)),
            Expanded
            (
              child: ListView.builder
              (
                itemCount: widget.usuario.recetasFavoritas.length,
                itemBuilder: (context, index) 
                {
                  return ListTile
                  (
                    title: Text(widget.usuario.recetasFavoritas[index].nombreReceta),
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
