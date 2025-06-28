import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'qr_connection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Widget nextScreen = const SizedBox(); // default until loaded

  @override
  void initState() {
    super.initState();
    _loadLoginStatus();
  }

  Future<void> _loadLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    setState(() {
      nextScreen = isLoggedIn ? const HomePage() : const QRConnectionScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (nextScreen is SizedBox) {
      return const Scaffold(
        backgroundColor: Color(0xFF90BFA9),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return AnimatedSplashScreen(
      splash: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Color(0xFFF5F2E7), width: 2),
        ),
        child: const CircleAvatar(
          backgroundColor: Color(0xFF90BFA9),
          backgroundImage: AssetImage('images/logo.png'),
          radius: 80,
        ),
      ),
      nextScreen: nextScreen,
      splashTransition: SplashTransition.rotationTransition,
      splashIconSize: 180,
      backgroundColor: const Color(0xFF90BFA9),
    );
  }
}
