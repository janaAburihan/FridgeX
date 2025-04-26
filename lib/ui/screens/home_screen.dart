import 'dart:io';

import 'package:flutter/material.dart';
import 'package:recipe_book/ui/screens/about_screen.dart';
import 'package:recipe_book/ui/widgets/app_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FridgeX'),
        actions: [
          PopupMenuButton<String>(
            color: !isDark ? Color(0xFFC2DCD0) : null,
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'open_menu',
                onTap: () => Scaffold.of(context).openDrawer(),
                child: const Text('Open menu'),
              ),
              PopupMenuItem<String>(
                value: 'about',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutScreen()),
                  );
                },
                child: const Text('About'),
              ),
              PopupMenuItem<String>(
                value: 'exit',
                onTap: () {
                  exit(0); // This will exit the app
                },
                child: Column(
                  children: [
                    const Divider(
                      color: Colors.black,
                      thickness: 1,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: const [
                        Icon(
                          Icons.exit_to_app_outlined,
                          color: Colors.red,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text('Exit'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.black, Colors.grey.shade900]
                : [Colors.white, Colors.green.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo inside a circle avatar for better styling
            CircleAvatar(
              radius: 70,
              backgroundColor: Colors.green.shade100,
              child: ClipOval(
                child: Image.asset(
                  'images/logo.png',
                  fit: BoxFit.cover,
                  width: 120,
                  height: 120,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Welcome to FridgeX!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.green.shade800,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Recognize your food items, get recipe suggestions,\nand control your fridge anytime, anywhere.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/inside_view_screen');
              },
              label: const Text(
                'Start Now',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                backgroundColor: Colors.green.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
