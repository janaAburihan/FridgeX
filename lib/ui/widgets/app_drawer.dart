import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:FridgeX/providers/recipe_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final myProvider = Provider.of<RecipeClass>(context);
    final isDark = myProvider.isDark;

    return Drawer(
      backgroundColor:
          isDark ? const Color(0xFF313232) : const Color(0xFFF5F2E7),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            color: isDark ? const Color(0xFF17120D) : const Color(0xFF78B298),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFF5F2E7),
                    width: 2,
                  ),
                ),
                child: const CircleAvatar(
                  backgroundColor: Color(0xFF78B298),
                  backgroundImage: AssetImage('images/logo.png'),
                  radius: 55,
                ),
              ),
            ),
          ),
          ListTile(
            title: Text(
              'Home',
              style: TextStyle(
                  color: isDark ? Color(0xFFFEFEFE) : Color(0xFF17120D)),
            ),
            leading: Icon(Icons.home,
                color: isDark ? Color(0xFFC8D8CC) : Color(0xFF78B298)),
            onTap: () {
              Navigator.pushNamed(context, '/home_screen');
            },
          ),
          ListTile(
            title: Text(
              'Fridge Inside View',
              style: TextStyle(
                  color: isDark ? Color(0xFFFEFEFE) : Color(0xFF17120D)),
            ),
            leading: Icon(Icons.photo_camera,
                color: isDark ? Color(0xFFC8D8CC) : Color(0xFF78B298)),
            onTap: () {
              Navigator.pushNamed(context, '/inside_view_screen');
            },
          ),
          ListTile(
            title: Text(
              'Fridge Items',
              style: TextStyle(
                  color: isDark ? Color(0xFFFEFEFE) : Color(0xFF17120D)),
            ),
            leading: Icon(Icons.kitchen,
                color: isDark ? Color(0xFFC8D8CC) : Color(0xFF78B298)),
            onTap: () {
              Navigator.pushNamed(context, '/food_recognition_screen');
            },
          ),
          ListTile(
            title: Text(
              'Recipe Suggestion',
              style: TextStyle(
                  color: isDark ? Color(0xFFFEFEFE) : Color(0xFF17120D)),
            ),
            leading: Icon(Icons.restaurant,
                color: isDark ? Color(0xFFC8D8CC) : Color(0xFF78B298)),
            onTap: () {
              Navigator.pushNamed(context, '/recipe_suggestion_screen');
            },
          ),
          //const Divider(thickness: 1),
          ListTile(
            title: Text(
              'My Recipes',
              style: TextStyle(
                  color: isDark ? Color(0xFFFEFEFE) : Color(0xFF17120D)),
            ),
            leading: Icon(Icons.menu_book,
                color: isDark ? Color(0xFFC8D8CC) : Color(0xFF78B298)),
            onTap: () {
              Navigator.pushNamed(context, '/main_recipe_screen');
            },
          ),
          ListTile(
            title: Text(
              'Favorite Recipes',
              style: TextStyle(
                  color: isDark ? Color(0xFFFEFEFE) : Color(0xFF17120D)),
            ),
            leading: const Icon(Icons.favorite, color: Colors.red),
            onTap: () {
              Navigator.pushNamed(context, '/favorite_recipes_screen');
            },
          ),
          //const Divider(thickness: 1),
          ListTile(
            title: Text(
              'Shopping List',
              style: TextStyle(
                  color: isDark ? Color(0xFFFEFEFE) : Color(0xFF17120D)),
            ),
            leading: Icon(Icons.shopping_cart,
                color: isDark ? Color(0xFFC8D8CC) : Color(0xFF78B298)),
            onTap: () {
              Navigator.pushNamed(context, '/shopping_list_screen');
            },
          ),
          //const Divider(thickness: 1),
          ListTile(
            title: Text(
              'Door Control',
              style: TextStyle(
                  color: isDark ? Color(0xFFFEFEFE) : Color(0xFF17120D)),
            ),
            leading: Icon(Icons.meeting_room,
                color: isDark ? Color(0xFFC8D8CC) : Color(0xFF78B298)),
            onTap: () {
              Navigator.pushNamed(context, '/door_control_screen');
            },
          ),
          isDark
              ? ListTile(
                  title: const Text(
                    'Light Mode',
                    style: TextStyle(color: Color(0xFF78B298)),
                  ),
                  leading: const Icon(Icons.light_mode_outlined,
                      color: Color(0xFFF4DB6B)),
                  onTap: () {
                    Provider.of<RecipeClass>(context, listen: false)
                        .changeIsDark();
                    Navigator.pop(context);
                  },
                )
              : ListTile(
                  title: const Text(
                    'Dark Mode',
                    style: TextStyle(color: Color(0xFF17120D)),
                  ),
                  leading: const Icon(Icons.dark_mode_outlined,
                      color: Color(0xFF90BFA9)),
                  onTap: () {
                    Provider.of<RecipeClass>(context, listen: false)
                        .changeIsDark();
                    Navigator.pop(context);
                  },
                ),
        ],
      ),
    );
  }
}
