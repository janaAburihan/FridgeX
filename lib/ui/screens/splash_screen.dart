import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:FridgeX/ui/screens/home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Container(
        padding: const EdgeInsets.all(2), // space between border and avatar
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Color(0xFFF5F2E7),
            width: 2, // thickness of the border
          ),
        ),
        child: const CircleAvatar(
          backgroundColor: Color(0xFF90BFA9),
          backgroundImage: AssetImage('images/logo.png'),
          radius: 80,
        ),
      ),
      nextScreen: const HomePage(),
      splashTransition: SplashTransition.rotationTransition,
      splashIconSize: 180,
      backgroundColor: Color(0xFF90BFA9),
    );
  }
}
