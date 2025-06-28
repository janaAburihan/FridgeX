import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:FridgeX/data_repository/fridge_item_dbHelper.dart';
import 'package:FridgeX/providers/recipe_provider.dart';
import 'package:FridgeX/models/fridge_item_model.dart';
import 'package:FridgeX/ui/widgets/app_drawer.dart';

class FoodRecognitionScreen extends StatefulWidget {
  const FoodRecognitionScreen({super.key});

  @override
  State<FoodRecognitionScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends State<FoodRecognitionScreen> {
  List<FridgeItemModel> manualItems = [];
  List<FridgeItemModel> aiItems = [];
  bool isLoading = false;
  final TextEditingController _manualItemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    FridgeItemDbHelper.dbHelper.initDatabase().then((_) {
      loadItemsFromDb();
    });
  }

  Future<void> loadItemsFromDb() async {
    final allItems = await FridgeItemDbHelper.dbHelper.getAllFridgeItems();
    setState(() {
      manualItems = allItems.where((item) => item.source == 'manual').toList();
      aiItems = allItems.where((item) => item.source == 'ai').toList();
    });
  }

  Future<void> fetchFridgeItems() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("http://192.168.10.149:5000/food-recognition"));
      final data = json.decode(response.body);

      if (data["status"] == "success") {
        final List<String> detectedItems = List<String>.from(data["objects"]);
        await FridgeItemDbHelper.dbHelper.syncItems(detectedItems);
        await loadItemsFromDb();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching items: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _addItem(String item) async {
  String normalized = item.trim().toLowerCase(); // Normalize input

  if (normalized.isNotEmpty) {
    final exists = await FridgeItemDbHelper.dbHelper.fridgeItemExists(normalized);
    if (!exists) {
      final model = FridgeItemModel(name: normalized, source: 'manual');
      await FridgeItemDbHelper.dbHelper.insertFridgeItem(model);
      await loadItemsFromDb();
      _manualItemController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item already exists.")),
      );
    }
  }
}


  void _deleteItem(int id) async {
    await FridgeItemDbHelper.dbHelper.deleteFridgeItem(id);
    await loadItemsFromDb();
  }

  Widget buildItemTile(FridgeItemModel item) {
    final isDark = Provider.of<RecipeClass>(context, listen: false).isDark;
    const greenColor = Color(0xFF90BFA9);
    return Container(
      decoration: BoxDecoration(
        color: !isDark ? greenColor.withOpacity(0.2) : null,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(item.name),
        subtitle: Text("Source: ${item.source}"),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _deleteItem(item.id!),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(title: const Text("Fridge Items")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _manualItemController,
              decoration: InputDecoration(
                hintText: "Add item...",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addItem(_manualItemController.text),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                const Text("Manual Items", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                manualItems.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("No manual items."),
                      )
                    : Column(
                        children: manualItems.map(buildItemTile).toList(),
                      ),
                const SizedBox(height: 16),
                const Text("AI-detected Items", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                isLoading
                    ? const Center(child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ))
                    : aiItems.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text("No AI-detected items."),
                          )
                        : Column(
                            children: aiItems.map(buildItemTile).toList(),
                          ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: isLoading ? null : fetchFridgeItems,
            icon: const Icon(Icons.refresh, color: Color(0xFF17120D)),
            label: const Text("Recognize Again"),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Manual items are safe and won't be removed by recognition.",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
