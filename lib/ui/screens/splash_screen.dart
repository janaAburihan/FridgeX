import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:recipe_book/ui/screens/home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: CircleAvatar(
        backgroundColor: Color(0xFF90BFA9),
        backgroundImage: AssetImage('images/logo.png'),
        radius: 80,
      ),
      nextScreen: const HomePage(),
      splashTransition: SplashTransition.rotationTransition,
      splashIconSize: 180,
      backgroundColor: Color(0xFF90BFA9),
    );
  }
}
