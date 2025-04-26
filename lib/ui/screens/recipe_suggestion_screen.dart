import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_book/data_repository/fridge_item_dbHelper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:recipe_book/providers/item_provider.dart';
import 'package:recipe_book/ui/widgets/app_drawer.dart';

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
  List<String> recipeInstructions = []; // Changed here
  List<String> availableIngredients = [];
  List<String> missingIngredients = [];

  Future<List<String>> _fetchFridgeItems() async {
    final fridgeItems = await FridgeItemDbHelper.dbHelper.getAllFridgeItems();
    return fridgeItems.map((item) => item.name).toList();
  }

  Future<void> _suggestRecipe() async {
    setState(() {
      isLoading = true;
    });

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
        recipeDescription = data['recipe']['recipe_image'];
        recipeInstructions = List<String>.from(data['recipe']['instructions']);

        availableIngredients =
            List<String>.from(data['recipe']['ingredients']['available']);
        missingIngredients =
            List<String>.from(data['recipe']['ingredients']['missing']);

        recipeImageBase64 = data['recipe_image'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to fetch recipe suggestions.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('Recipe Suggestions'),
      ),
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
                    Image.memory(
                      base64Decode(recipeImageBase64!),
                      fit: BoxFit.cover,
                      height: 200,
                    )
                  else
                    const Text("Image not available"),
                  const SizedBox(height: 16),
                  Text(
                    recipeName ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Ingredients:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Available Ingredients:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  for (var ingredient in availableIngredients)
                    Text(ingredient,
                        style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Missing Ingredients:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                    Text(ingredient,
                        style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Instructions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  recipeInstructions.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: recipeInstructions
                              .asMap()
                              .entries
                              .map((entry) {
                            int idx = entry.key + 1;
                            String step = entry.value;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                '$idx. $step',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            );
                          }).toList(),
                        )
                      : const Text(
                          'No instructions available.',
                          style: TextStyle(fontSize: 16),
                        ),
                  const Divider(),
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Tap the button below to get a recipe suggestion based on your fridge items.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: _suggestRecipe,
                label: Text(
                  recipeName != null
                      ? 'Suggest Another Recipe'
                      : 'Suggest Recipe',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                icon: const Icon(Icons.restaurant_menu),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
