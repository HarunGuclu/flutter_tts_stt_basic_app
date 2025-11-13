import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE stt_history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      text TEXT NOT NULL,
      timestamp TEXT NOT NULL,
      filePath TEXT NOT NULL,
      transcription_id TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE tts_history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      text TEXT NOT NULL,
      voice TEXT NOT NULL,
      timestamp TEXT NOT NULL,
      filePath TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE settings (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL
    )
    ''');
  }

  Future<void> insertSttHistory(String text, String filePath, {String? transcriptionId}) async {
    final db = await instance.database;
    await db.insert('stt_history', {
      'text': text,
      'timestamp': DateTime.now().toIso8601String(),
      'filePath': filePath,
      'transcription_id': transcriptionId,
    });
  }

  Future<List<Map<String, dynamic>>> getSttHistory() async {
    final db = await instance.database;
    return await db.query('stt_history', orderBy: 'timestamp DESC');
  }

  Future<void> insertTtsHistory(String text, String voice, String filePath) async {
    final db = await instance.database;
    await db.insert('tts_history', {
      'text': text,
      'voice': voice,
      'timestamp': DateTime.now().toIso8601String(),
      'filePath': filePath,
    });
  }

  Future<List<Map<String, dynamic>>> getTtsHistory() async {
    final db = await instance.database;
    return await db.query('tts_history', orderBy: 'timestamp DESC');
  }

  Future<void> setSetting(String key, String value) async {
    final db = await instance.database;
    await db.insert('settings', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getSetting(String key) async {
    final db = await instance.database;
    final result = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (result.isNotEmpty) {
      return result.first['value'] as String?;
    }
    return null;
  }

    Future<void> clearSttHistory() async {
    final db = await instance.database;
    await db.delete('stt_history');
  }

  Future<void> clearTtsHistory() async {
    final db = await instance.database;
    await db.delete('tts_history');
  }

}