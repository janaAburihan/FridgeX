import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:FridgeX/data_repository/fridge_item_dbHelper.dart';
import 'package:FridgeX/providers/item_provider.dart';
import 'package:FridgeX/providers/recipe_provider.dart';
import 'package:FridgeX/models/recipe_model.dart';
import 'package:FridgeX/ui/widgets/app_drawer.dart';

class RecipeSuggestionScreen extends StatefulWidget {
  const RecipeSuggestionScreen({super.key});

  @override
  _RecipeSuggestionScreenState createState() => _RecipeSuggestionScreenState();
}

class _RecipeSuggestionScreenState extends State<RecipeSuggestionScreen> {
  bool isLoading = false;
  String? recipeName;
  String? recipeDescription;
  String? recipeImageBase64;
  List<String> recipeInstructions = [];
  List<String> availableIngredients = [];
  List<String> missingIngredients = [];
  int? preperationTime;

  Future<List<String>> _fetchFridgeItems() async {
    final fridgeItems = await FridgeItemDbHelper.dbHelper.getAllFridgeItems();
    return fridgeItems.map((item) => item.name).toList();
  }

  Future<void> _suggestRecipe() async {
    setState(() => isLoading = true);

    final ingredients = await _fetchFridgeItems();

    final response = await http.post(
      Uri.parse('http://192.168.10.149:5000/recipe-suggestion'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"ingredients": ingredients}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        recipeName = data['recipe']['recipe_name'];
        recipeDescription = data['recipe']['recipe_description'];
        recipeInstructions = List<String>.from(data['recipe']['instructions']);
        availableIngredients = List<String>.from(data['recipe']['ingredients']['available']);
        missingIngredients = List<String>.from(data['recipe']['ingredients']['missing']);
        preperationTime = data['recipe']['time'];
        recipeImageBase64 = data['recipe_image'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      _showErrorDialog('Failed to fetch recipe suggestions.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _addMissingToShoppingList() async {
    try {
      final provider = Provider.of<ItemClass>(context, listen: false);
      provider.insertMultipleItems(missingIngredients);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Items added to your shopping list.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add items: $e')),
      );
    }
  }

  void _saveRecipeToMyRecipes() async {
    if (recipeName != null && recipeInstructions.isNotEmpty) {
      final recipeProvider = Provider.of<RecipeClass>(context, listen: false);

      final ingredientsText = [...availableIngredients, ...missingIngredients].join(', ');
      final instructionsText =
          recipeInstructions.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n');

      File? imageFile;
      if (recipeImageBase64 != null) {
        try {
          final bytes = base64Decode(recipeImageBase64!);
          final tempDir = Directory.systemTemp;
          final filePath = '${tempDir.path}/recipe_${DateTime.now().millisecondsSinceEpoch}.png';
          imageFile = await File(filePath).writeAsBytes(bytes);
        } catch (e) {
          print('Failed to decode and save image: $e');
        }
      }

      final newRecipe = RecipeModel(
        name: recipeName!,
        isFavorite: false,
        preperationTime: preperationTime!,
        ingredients: ingredientsText,
        instructions: instructionsText,
        image: imageFile,
      );

      recipeProvider.insertRecipe(newRecipe);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe added to My Recipes!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(title: const Text('Recipe Suggestions')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (recipeName != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (recipeImageBase64 != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        base64Decode(recipeImageBase64!),
                        fit: BoxFit.cover,
                        height: 200,
                        width: double.infinity,
                      ),
                    )
                  else
                    const Text("Image not available"),
                  const SizedBox(height: 16),
                  Text(
                    recipeName!,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  if (recipeDescription != null && recipeDescription!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        recipeDescription!,
                        style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                      ),
                    ),
                  const Text('Ingredients:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('Available:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  for (var ingredient in availableIngredients)
                    Text(ingredient),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Missing:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      if (missingIngredients.isNotEmpty)
                        InkWell(
                          onTap: _addMissingToShoppingList,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: Colors.grey.withOpacity(0.2),
                            ),
                            child: const Icon(
                              Icons.add_shopping_cart,
                              color: Colors.green,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                  for (var ingredient in missingIngredients)
                    Text(ingredient),
                  const SizedBox(height: 16),
                  const Divider(),
                  const Text('Instructions:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...recipeInstructions.asMap().entries.map((entry) {
                    int index = entry.key + 1;
                    String step = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text('$index. $step'),
                    );
                  }),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _saveRecipeToMyRecipes,
                        icon: const Icon(Icons.save_alt),
                        label: const Text('Save Recipe'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _suggestRecipe,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt_long,
                          size: 80, color: Color(0xFF90BFA9)),
                      const SizedBox(height: 20),
                      const Text(
                        'Ready to cook something delicious?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Tap the button below to get a recipe suggestion based on your fridge items.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: _suggestRecipe,
                        icon: const Icon(Icons.restaurant_menu),
                        label: const Text('Suggest Recipe'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
