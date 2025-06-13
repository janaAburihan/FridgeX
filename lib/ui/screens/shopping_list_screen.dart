import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:FridgeX/ui/widgets/app_drawer.dart';

import '../../providers/item_provider.dart';
import '../../providers/recipe_provider.dart';
import '../widgets/item_widget.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<RecipeClass, ItemClass>(
        builder: ((context, provider, provider2, child) => Scaffold(
            appBar: AppBar(
              title: const Text('Shopping List'),
              actions: [
                InkWell(
                    onTap: () => provider2.deleteItems(),
                    child: const Icon(Icons.delete))
              ],
            ),
            drawer: AppDrawer(),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      itemCount: provider2.allItems.length,
                      itemBuilder: (context, index) {
                        return ItemWidget(provider2.allItems[index]);
                      }),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: TextField(
                        controller: provider2.textEditingController,
                        decoration: InputDecoration(
                            label: const Text('Item Name'),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15))),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        provider2.insertNewItem();
                        provider2.textEditingController.clear();
                      },
                      child: const Text('Add Item'),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
              ],
            ))));
  }
}
