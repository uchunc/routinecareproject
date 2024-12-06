import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

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
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "journal.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE Journal (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            content TEXT,
            imagePath TEXT
          )
        ''');
      },
    );
  }

  Future<List<Map<String, dynamic>>> getJournalsByDate(String dateKey) async {
    final db = await database;
    final result = await db.query(
      'Journal',
      where: 'date = ?',
      whereArgs: [dateKey],
    );
    print("Journals for $dateKey: $result"); // 디버깅용
    return result;
  }

  Future<void> insertJournal(
      String dateKey, String content, String imagePath) async {
    final db = await database;
    await db.insert(
      'Journal',
      {'date': dateKey, 'content': content, 'imagePath': imagePath},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print(await db.query('Journal')); // 모든 데이터 출력
  }

  Future<int> deleteJournal(int id) async {
    final db = await database;
    return await db.delete('Journal', where: 'id = ?', whereArgs: [id]);
  }
}
