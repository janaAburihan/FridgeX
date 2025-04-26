import 'package:flutter/material.dart';

import '../data_repository/item_dbHelper.dart';
import '../models/item_model.dart';

class ItemClass with ChangeNotifier {
  ItemClass() {
    getItems();
  }

  TextEditingController textEditingController = TextEditingController();

  List<ItemModel> allItems = [];
  List<ItemModel> completeItems = [];
  List<ItemModel> incompleteItems = [];
  getItems() async {
    allItems = await ItemDbHelper.dbHelper.getAllItems();
    completeItems = allItems.where((e) => e.isComplete).toList();
    incompleteItems = allItems.where((e) => !e.isComplete).toList();
    notifyListeners();
  }

  insertNewItem() {
    ItemModel itemModel =
        ItemModel(name: textEditingController.text, isComplete: false);
    ItemDbHelper.dbHelper.insertNewItem(itemModel);
    getItems();
  }

  void insertMultipleItems(List<String> items) {
    for (var item in items) {
      // Check if item exists before inserting
      if (!allItems.any((e) => e.name.toLowerCase() == item.toLowerCase())) {
        ItemModel itemModel = ItemModel(name: item, isComplete: false);
        ItemDbHelper.dbHelper.insertNewItem(itemModel);
      }
    }
    getItems();  // Refresh the list after adding new items
  }

  updateItem(ItemModel itemModel) {
    ItemDbHelper.dbHelper.updateItem(itemModel);
    getItems();
  }

  deleteItem(ItemModel itemModel) {
    ItemDbHelper.dbHelper.deleteItem(itemModel);
    getItems();
  }

  deleteItems() {
    ItemDbHelper.dbHelper.deleteItems();
    getItems();
  }
}
