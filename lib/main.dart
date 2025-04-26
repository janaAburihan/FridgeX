import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_book/data_repository/fridge_item_dbHelper.dart';
import 'package:recipe_book/data_repository/item_dbHelper.dart';
import 'package:recipe_book/providers/item_provider.dart';
import 'package:recipe_book/ui/screens/favorite_recipes_screen.dart';
import 'package:recipe_book/ui/screens/food_recognition_screeen.dart';
import 'package:recipe_book/ui/screens/home_screen.dart';
import 'package:recipe_book/ui/screens/inside_view_screen.dart';
import 'package:recipe_book/ui/screens/main_recipe_screen.dart';
import 'package:recipe_book/ui/screens/new_recipe_screen.dart';
import 'package:recipe_book/providers/recipe_provider.dart';
import 'package:recipe_book/ui/screens/recipe_suggestion_screen.dart';
import 'package:recipe_book/ui/screens/shopping_list_screen.dart';
import 'package:recipe_book/ui/screens/splash_screen.dart';
import 'data_repository/dbHelper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DbHelper.dbHelper.initDatabase();
  await ItemDbHelper.dbHelper.initDatabase();
  await FridgeItemDbHelper.dbHelper.initDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<RecipeClass>(
        create: (context) => RecipeClass(),
      ),
      ChangeNotifierProvider<ItemClass>(
        create: (context) => ItemClass(),
      ),
    ], child: const InitApp());
  }
}

class InitApp extends StatelessWidget {
  const InitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: Provider.of<RecipeClass>(context).isDark
            ? ThemeData.dark().copyWith(
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF4DB6B),
                    foregroundColor: Color(0xFF17120D),
                  ),
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Color(0xFFF4DB6B),
                  foregroundColor: Color(0xFF17120D),
                ),
              )
            : ThemeData(
                primarySwatch: const MaterialColor(0xFF90BFA9, {
                  50: Color(0xFFE7F1EC),
                  100: Color(0xFFC2DCD0),
                  200: Color(0xFF9DC7B4),
                  300: Color(0xFF78B298),
                  400: Color(0xFF5EA187),
                  500: Color(0xFF459F78),
                  600: Color(0xFF3C906C),
                  700: Color(0xFF357F5F),
                  800: Color(0xFF2D6E53),
                  900: Color(0xFF1F4F3D),
                }),
                scaffoldBackgroundColor: const Color(0xFFF5F2E7),
                dialogBackgroundColor: const Color(0xFFF5F2E7),
                primaryColor: const Color(0xFF90BFA9),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF4DB6B),
                    foregroundColor: Color(0xFF17120D),
                  ),
                ),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color(0xFF90BFA9),
                  foregroundColor: Color(0xFF17120D),
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Color(0xFFF4DB6B),
                  foregroundColor: Color(0xFF17120D),
                ),
              ),
        home: const SplashScreen(),
        routes: {
          '/favorite_recipes_screen': (context) =>
              const FavoriteRecipesScreen(),
          '/new_recipe_screen': (context) => const NewRecipeScreen(),
          '/main_recipe_screen': (context) => const MainRecipeScreen(),
          '/shopping_list_screen': (context) => const ShoppingListScreen(),
          '/food_recognition_screen': (context) =>
              const FoodRecognitionScreen(),
          '/recipe_suggestion_screen': (context) =>
              const RecipeSuggestionScreen(),
          '/inside_view_screen': (context) => const InsideViewScreen(),
          '/home_screen': (context) => const HomePage(),
        },
      ),
    );
  }
}
