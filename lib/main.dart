import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'data_repository/dbHelper.dart';
import 'data_repository/fridge_item_dbHelper.dart';
import 'data_repository/item_dbHelper.dart';
import 'providers/item_provider.dart';
import 'providers/recipe_provider.dart';
import 'services/notification_service.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/favorite_recipes_screen.dart';
import 'ui/screens/food_recognition_screeen.dart';
import 'ui/screens/main_recipe_screen.dart';
import 'ui/screens/new_recipe_screen.dart';
import 'ui/screens/recipe_suggestion_screen.dart';
import 'ui/screens/shopping_list_screen.dart';
import 'ui/screens/inside_view_screen.dart';
import 'ui/screens/door_control_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await DbHelper.dbHelper.initDatabase();
  await ItemDbHelper.dbHelper.initDatabase();
  await FridgeItemDbHelper.dbHelper.initDatabase();

  // ✅ Init notifications
  await initializeNotifications();

  // for testing qr code login OR delete app data
  // final prefs = await SharedPreferences.getInstance();
  // await prefs.setBool('isLoggedIn', false);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<RecipeClass>(create: (_) => RecipeClass()),
        ChangeNotifierProvider<ItemClass>(create: (_) => ItemClass()),
      ],
      child: const InitApp(),
    );
  }
}

class InitApp extends StatelessWidget {
  const InitApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<RecipeClass>(context).isDark;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: isDark
          ? ThemeData.dark().copyWith(
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF4DB6B),
                  foregroundColor: const Color(0xFF17120D),
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
                  backgroundColor: const Color(0xFFF4DB6B),
                  foregroundColor: const Color(0xFF17120D),
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
        '/favorite_recipes_screen': (_) => const FavoriteRecipesScreen(),
        '/new_recipe_screen': (_) => const NewRecipeScreen(),
        '/main_recipe_screen': (_) => const MainRecipeScreen(),
        '/shopping_list_screen': (_) => const ShoppingListScreen(),
        '/food_recognition_screen': (_) => const FoodRecognitionScreen(),
        '/recipe_suggestion_screen': (_) => const RecipeSuggestionScreen(),
        '/inside_view_screen': (_) => const InsideViewScreen(),
        '/door_control_screen': (_) => const DoorControlScreen(),
        '/home_screen': (_) => const HomePage(),
      },
    );
  }
}
