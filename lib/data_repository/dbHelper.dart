import '../models/recipe_model.dart';

class DbHelper {
  late Database database;
  static DbHelper dbHelper = DbHelper();
  final String tableName = 'tasks';
  final String nameColumn = 'name';
  final String idColumn = 'id';
  final String isCompleteColumn = 'isComplete';

  initDatabase() async {
    database = await connectToDatabase();
  }

  Future<Database> connectToDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = '$directory/tasks.db';
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute(
            'CREATE TABLE $tableName ($idColumn INTEGER PRIMARY KEY AUTOINCREMENT, $nameColumn TEXT, $isCompleteColumn INTEGER)');
      },
      onUpgrade: (db, oldVersion, newVersion) {
        db.execute(
            'CREATE TABLE $tableName ($idColumn INTEGER PRIMARY KEY AUTOINCREMENT, $nameColumn TEXT, $isCompleteColumn INTEGER)');
      },
      onDowngrade: (db, oldVersion, newVersion) {
        db.delete(tableName);
      },
    );
  }

  Future<List<RecipeModel>> getAllTasks() async {
    List<Map<String, dynamic>> tasks = await database.query(tableName);
    return tasks.map((e) => RecipeModel.fromMap(e)).toList();
  }

  insertNewTask(RecipeModel recipeModel) {
    database.insert(tableName, recipeModel.toMap());
  }

  deleteTask(RecipeModel recipeModel) {
    database
        .delete(tableName, where: '$idColumn=?', whereArgs: [recipeModel.id]);
  }

  updateTask(RecipeModel recipeModel) {
    database.update(
        tableName, {isCompleteColumn: !recipeModel.isComplete ? 1 : 0},
        where: '$idColumn=?', whereArgs: [recipeModel.id]);
  }
}

class Directory {}
