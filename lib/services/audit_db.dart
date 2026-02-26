import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AuditDB {
  static final AuditDB instance = AuditDB._init();
  static Database? _database;

  AuditDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("audit.db");
    return _database!;
  }

  Future<Database> _initDB(String file) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, file);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE audits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        createdAt TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE audit_answers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        auditId INTEGER,
        questionId TEXT,
        answer INTEGER,
        FOREIGN KEY (auditId) REFERENCES audits(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE audit_checklists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        auditId INTEGER,
        questionId TEXT,
        itemIndex INTEGER,
        FOREIGN KEY (auditId) REFERENCES audits(id)
      );
    ''');
  }
}
