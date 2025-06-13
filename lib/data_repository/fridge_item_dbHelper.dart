import 'package:FridgeX/models/fridge_item_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class FridgeItemDbHelper {
  static final FridgeItemDbHelper dbHelper = FridgeItemDbHelper._();

  FridgeItemDbHelper._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'fridge_items.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE fridge_items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE,
            source TEXT DEFAULT 'manual'
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) {
        db.execute(
            'ALTER TABLE fridge_items ADD COLUMN source TEXT DEFAULT "manual"');
      },
      onDowngrade: (db, oldVersion, newVersion) {
        db.delete('fridge_items');
      },
    );
  }

  Future<void> insertFridgeItem(FridgeItemModel item) async {
    final db = await database;
    final exists = await fridgeItemExists(item.name);

    if (!exists) {
      await db.insert(
        'fridge_items',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<bool> fridgeItemExists(String name) async {
    final db = await initDatabase();
    final trimmedName = name.trim().toLowerCase();

    final result = await db.query(
      'fridge_items',
      where: 'LOWER(TRIM(name)) = ?',
      whereArgs: [trimmedName],
    );

    return result.isNotEmpty;
  }

  Future<List<FridgeItemModel>> getAllFridgeItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('fridge_items');

    return List.generate(maps.length, (i) {
      return FridgeItemModel(
        id: maps[i]['id'],
        name: maps[i]['name'],
        source: maps[i]['source'] ?? 'manual',
      );
    });
  }

  Future<void> deleteItemByName(String name) async {
    final db = await database;
    await db.delete('fridge_items', where: 'name = ?', whereArgs: [name]);
  }

  Future<void> deleteFridgeItem(int id) async {
    final db = await database;
    await db.delete(
      'fridge_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateFridgeItem(FridgeItemModel item) async {
    final db = await database;
    await db.update(
      'fridge_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> syncItems(List<String> detectedItems) async {
    final db = await initDatabase();

    // Normalize: lowercase + trim
    final normalizedDetected = detectedItems
        .map((e) => e.trim().toLowerCase())
        .toSet(); // avoid duplicates

    // Fetch current AI items
    final currentAIItems = await db.query(
      'fridge_items',
      where: "source = ?",
      whereArgs: ['ai'],
    );

    final currentAINames = currentAIItems
        .map((item) => item['name'].toString().trim().toLowerCase())
        .toSet();

    // Items to add
    final itemsToAdd = normalizedDetected.difference(currentAINames);
    for (var item in itemsToAdd) {
      await insertFridgeItem(FridgeItemModel(name: item, source: 'ai'));
    }

    // Also check if any AI item should update label from manual → ai
    final manualItems = await db.query(
      'fridge_items',
      where: "source = ?",
      whereArgs: ['manual'],
    );

    for (var item in manualItems) {
      final name = item['name'].toString().trim().toLowerCase();
      if (normalizedDetected.contains(name)) {
        await db.update(
          'fridge_items',
          {'source': 'ai'},
          where: "id = ?",
          whereArgs: [item['id']],
        );
      }
    }

    // Items to delete (those that were previously detected by AI but are now missing)
    final itemsToDelete = currentAINames.difference(normalizedDetected);
    for (var item in itemsToDelete) {
      await db.delete(
        'fridge_items',
        where: "name = ? AND source = ?",
        whereArgs: [item, 'ai'],
      );
    }
  }
}
