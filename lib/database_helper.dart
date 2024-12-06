import 'package:path/path.dart';
import 'package:routinecareproject/models/journal_entry.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'journal.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE journal_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            imagePath TEXT NOT NULL
            text TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertJournalEntry(JournalEntry entry) async {
    final db = await database;
    return db.insert('journal_entries', entry.toMap());
  }

  Future<List<JournalEntry>> getJournalEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('journal_entries');
    return List.generate(maps.length, (i) {
      return JournalEntry(
        date: maps[i]['date'],
        imagePath: maps[i]['imagePath'],
        text: maps[i]['text'], // 필드 추가
      );
    });
  }

  Future<void> updateJournalEntry(String date, String text) async {
    final db = await database;
    await db.update(
      'journal_entries',
      {'text': text},
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  Future<void> deleteAllEntries() async {
    final db = await database;
    await db.delete('journal_entries');
  }
}
