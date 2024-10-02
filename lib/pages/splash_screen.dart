import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:coffee_quest/pages/session_screen.dart'; // Asegúrate de importar SessionScreen
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget 
{
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) 
  {
    return AnimatedSplashScreen
    (
      splash: Lottie.asset
      (
        'assets/animation/Carga.json',
        width: 300,
        height: 300,
        fit: BoxFit.cover,
      ),
      nextScreen: const SessionScreen(title: "Sesión"),
      duration: 4000, 
      splashTransition: SplashTransition.fadeTransition,
      backgroundColor: const Color.fromARGB(255, 116, 73, 36),
    );
  }
}
