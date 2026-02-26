import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

import '../db/app_database.dart';

class BackupService {
  BackupService._();
  static final BackupService instance = BackupService._();

  static const _dbFileName = 'cobit_audit.db';
  static const _backupFileName = 'cobit_audit_backup.db';

  /// Fichier DB principal
  Future<File> _getDbFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbFileName);
    return File(path);
  }

  /// Fichier de sauvegarde locale
  Future<File> _getLocalBackupFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _backupFileName);
    return File(path);
  }

  // --------------------------------------------------------------
  // 1) EXPORT / PARTAGE (externe) => share_plus (optionnel)
  // --------------------------------------------------------------

  Future<void> exportDatabase() async {
    final dbFile = await _getDbFile();

    if (!await dbFile.exists()) {
      throw Exception(
        "Fichier de base de données introuvable : ${dbFile.path}",
      );
    }

    await Share.shareXFiles([
      XFile(dbFile.path),
    ], text: 'Sauvegarde COBIT – base SQLite');
  }

  // --------------------------------------------------------------
  // 2) RESTAURATION depuis un fichier choisi par l’utilisateur
  //    (via FilePicker, .db externe)
  // --------------------------------------------------------------

  Future<void> restoreDatabase() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['db'],
    );

    if (result == null || result.files.single.path == null) {
      // Annulé
      return;
    }

    final backupPath = result.files.single.path!;
    final backupFile = File(backupPath);

    if (!await backupFile.exists()) {
      throw Exception("Fichier de backup invalide : $backupPath");
    }

    // On ferme la DB courante
    await AppDatabase.instance.close();

    final dbFile = await _getDbFile();
    await dbFile.parent.create(recursive: true);

    await backupFile.copy(dbFile.path);
  }

  // --------------------------------------------------------------
  // 3) SAUVEGARDE LOCALE (dans le dossier de l’app)
  // --------------------------------------------------------------

  /// Copie la base actuelle vers cobit_audit_backup.db
  Future<void> backupDatabaseLocally() async {
    final dbFile = await _getDbFile();
    if (!await dbFile.exists()) {
      throw Exception("Base courante introuvable : ${dbFile.path}");
    }

    final backupFile = await _getLocalBackupFile();
    await backupFile.parent.create(recursive: true);
    await dbFile.copy(backupFile.path);
  }

  /// Remplace la base courante par la sauvegarde locale cobit_audit_backup.db
  Future<void> restoreLocalBackup() async {
    final backupFile = await _getLocalBackupFile();
    if (!await backupFile.exists()) {
      throw Exception("Aucune sauvegarde locale trouvée : ${backupFile.path}");
    }

    // Fermer la DB SQLite
    await AppDatabase.instance.close();

    final dbFile = await _getDbFile();
    await dbFile.parent.create(recursive: true);

    await backupFile.copy(dbFile.path);
  }
}
