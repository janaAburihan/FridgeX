import 'dart:io';
import 'package:flutter/material.dart';
import 'package:FridgeX/ui/screens/about_screen.dart';
import 'package:FridgeX/ui/widgets/app_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FridgeX Dashboard'),
        actions: [
          PopupMenuButton<String>(
            color: !isDark ? const Color(0xFFC2DCD0) : null,
            itemBuilder: (BuildContext context) => [
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
                  exit(0);
                },
                child: Row(
                  children: const [
                    Icon(Icons.exit_to_app_outlined, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Exit'),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.black, Colors.grey.shade900]
                : [Colors.white, Colors.green.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _buildDashboardTile(
              context,
              title: 'Fridge Inside View',
              icon: Icons.photo_camera,
              routeName: '/inside_view_screen',
            ),
            _buildDashboardTile(
              context,
              title: 'Fridge Items',
              icon: Icons.kitchen,
              routeName: '/food_recognition_screen',
            ),
            _buildDashboardTile(
              context,
              title: 'Recipe Suggestion',
              icon: Icons.restaurant,
              routeName: '/recipe_suggestion_screen',
            ),
            _buildDashboardTile(
              context,
              title: 'My Recipes',
              icon: Icons.menu_book,
              routeName: '/main_recipe_screen',
            ),
            _buildDashboardTile(
              context,
              title: 'Favorite Recipes',
              icon: Icons.favorite,
              iconColor: Colors.red,
              routeName: '/favorite_recipes_screen',
            ),
            _buildDashboardTile(
              context,
              title: 'Shopping List',
              icon: Icons.shopping_cart,
              routeName: '/shopping_list_screen',
            ),
            _buildDashboardTile(
              context,
              title: 'Door Control',
              icon: Icons.meeting_room,
              routeName: '/door_control_screen',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTile(BuildContext context,
      {required String title,
      required IconData icon,
      Color? iconColor,
      required String routeName}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, routeName),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF313232) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black45 : Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: iconColor ?? (isDark ? Colors.white70 : Colors.green)),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
