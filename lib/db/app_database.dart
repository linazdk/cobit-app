import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  static Database? _database;

  AppDatabase._internal();

  factory AppDatabase() => instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'cobit_audit.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    // Organisations
    await db.execute('''
      CREATE TABLE organizations (
        organization_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        sector TEXT,
        size INTEGER
      );
    ''');

    // Audits
    await db.execute('''
      CREATE TABLE audits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        organization_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        auditor_name TEXT,
        scope TEXT,
        status TEXT,
        FOREIGN KEY (organization_id) REFERENCES organizations(organization_id) ON DELETE CASCADE
      );
    ''');

    // Checklists par audit / question
    await db.execute('''
      CREATE TABLE audit_checklists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        auditId INTEGER,
        questionId TEXT,
        itemIndex INTEGER,
        FOREIGN KEY (auditId) REFERENCES audits(id)
      );
    ''');

    // Domaines COBIT
    await db.execute('''
      CREATE TABLE cobit_domains (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL,
        name TEXT NOT NULL
      );
    ''');

    // Processus COBIT
    await db.execute('''
      CREATE TABLE cobit_processes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        domain_id INTEGER NOT NULL,
        code TEXT NOT NULL,
        name TEXT NOT NULL,
        FOREIGN KEY (domain_id) REFERENCES cobit_domains(id) ON DELETE CASCADE
      );
    ''');

    // Questions COBIT (génériques)
    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        process_id INTEGER NOT NULL,
        text TEXT NOT NULL,
        FOREIGN KEY (process_id) REFERENCES cobit_processes(id) ON DELETE CASCADE
      );
    ''');

    // Réponses
    await db.execute('''
      CREATE TABLE answers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        audit_id INTEGER NOT NULL,
        question_id TEXT NOT NULL,        maturity_level INTEGER NOT NULL,
        comment TEXT,
        FOREIGN KEY (audit_id) REFERENCES audits(id) ON DELETE CASCADE,
        FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
      );
    ''');
    await db.execute('''
  CREATE TABLE gaps (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    audit_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    severity INTEGER NOT NULL,
    status INTEGER NOT NULL,
    owner TEXT,
    detected_at TEXT NOT NULL,
    target_close_date TEXT,
    closed_at TEXT,
    progress REAL NOT NULL DEFAULT 0.0,
    FOREIGN KEY (audit_id) REFERENCES audits(id) ON DELETE CASCADE
  )
''');
    await db.execute('''
      CREATE TABLE objective_targets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        audit_id INTEGER NOT NULL,
        objective_id TEXT NOT NULL,
        target_level INTEGER NOT NULL,
        UNIQUE (audit_id, objective_id),
        FOREIGN KEY (audit_id) REFERENCES audits(id) ON DELETE CASCADE
      );
    ''');
    await db.execute('''
    CREATE TABLE cobit_practices (
      id TEXT PRIMARY KEY,
      objectiveId TEXT NOT NULL,
      name TEXT NOT NULL,
      description TEXT
    );
  ''');

    await db.execute('''
    CREATE TABLE cobit_activities (
      id TEXT PRIMARY KEY,
      description TEXT,
      practiceId TEXT NOT NULL,
      FOREIGN KEY(practiceId) REFERENCES cobit_practices(id) ON DELETE CASCADE
    );
  ''');

    // Données COBIT de base
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
