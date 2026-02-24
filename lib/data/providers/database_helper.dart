import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/activity_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'stepflow.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE activities(id INTEGER PRIMARY KEY AUTOINCREMENT, steps INTEGER, calories REAL, activeMinutes INTEGER, date TEXT, timestamp INTEGER)',
        );
      },
    );
  }

  Future<void> insertActivity(ActivityModel activity) async {
    final db = await database;
    await db.insert(
      'activities',
      activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ActivityModel>> getActivities() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('activities', orderBy: 'timestamp DESC');

    return List.generate(maps.length, (i) {
      return ActivityModel.fromMap(maps[i]);
    });
  }
}
