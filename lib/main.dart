import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'pages/splash_screen.dart'; // Importar SplashScreen
import 'pages/session_screen.dart'; // Importar SessionScreen
import 'pages/tab_bar.dart'; // Importar TabBarController

void main() 
{
  runApp(const MyApp());
}

class MyApp extends StatelessWidget 
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) 
  {
    var logger = Logger();
    logger.i("Logger is working!");

    return MaterialApp
    (
      title: 'Coffee Quest',
      theme: ThemeData
      (
        fontFamily: 'Aurora',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 54, 32, 21)),
        useMaterial3: true,
      ),
      initialRoute: '/',  // Ruta inicial
      routes: 
      {
        '/': (context) => const SplashScreen(),
        '/session': (context) => const SessionScreen(title: 'Inicio sesión'),
        '/home': (context) => const TabBarController(),
      },
    );
  }
}
