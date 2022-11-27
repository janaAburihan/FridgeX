import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_book/data_repository/item_dbHelper.dart';
import 'package:recipe_book/providers/item_provider.dart';
import 'package:recipe_book/ui/screens/favorite_recipes_screen.dart';
import 'package:recipe_book/ui/screens/main_recipe_screen.dart';
import 'package:recipe_book/ui/screens/new_recipe_screen.dart';
import 'package:recipe_book/providers/recipe_provider.dart';
import 'package:recipe_book/ui/screens/shopping_list_screen.dart';
import 'package:recipe_book/ui/screens/splash_screen.dart';
import 'data_repository/dbHelper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DbHelper.dbHelper.initDatabase();
  await ItemDbHelper.dbHelper.initDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider<RecipeClass>(
          create: (context) => RecipeClass(),),
          ChangeNotifierProvider<ItemClass>(
          create: (context) => ItemClass(),),],
        child: const InitApp());
    
  }
}

class InitApp extends StatelessWidget {
  const InitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<RecipeClass>(context).isDark
          ? ThemeData.dark()
          : ThemeData(
              primarySwatch: Colors.pink,
              scaffoldBackgroundColor: Colors.pink[200],
              dialogBackgroundColor: Colors.pink[200],
              primaryColor: Colors.pink[200]),
      title: 'gsk',
      home: const SplashScreen(),
      routes: {
        '/favorite_recipes_screen': (context) => const FavoriteRecipesScreen(),
        '/new_recipe_screen': (context) => const NewRecipeScreen(),
        '/main_recipe_screen': (context) => const MainRecipeScreen(),
        '/shopping_list_screen': (context) => const ShoppingListScreen(),
      },
    );
  }
}
