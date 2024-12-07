import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'journal.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 기존 테이블 삭제 (필요 시)
    await db.execute('DROP TABLE IF EXISTS journals');

    // 새 테이블 생성
    await db.execute('''
    CREATE TABLE journals (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      imagePath TEXT NOT NULL,
      journal TEXT
    )
  ''');
  }

  Future<void> insertJournal(String date, String imagePath, String journal) async {
    final db = await database;
    await db.insert(
      'journals',
      {'date': date, 'imagePath': imagePath, 'journal': journal},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getJournalsByDate(String date) async {
    final db = await database;
    return await db.query(
      'journals',
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  Future<Map<String, dynamic>?> getJournalByImagePath(String imagePath) async {
    final db = await database;
    final results = await db.query(
      'journals',
      where: 'imagePath = ?',
      whereArgs: [imagePath],
    );

    if (results.isNotEmpty) {
      return results.first; // 일치하는 첫 번째 데이터 반환
    }
    return null; // 데이터 없으면 null 반환
  }

  Future<void> deleteJournalByImagePath(String imagePath) async {
    final db = await database;
    await db.delete(
      'journals',
      where: 'imagePath = ?',
      whereArgs: [imagePath],
    );
  }

  Future<void> deleteJournal(int id) async {
    final db = await database;
    await db.delete(
      'journals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}
