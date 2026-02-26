// lib/services/referential_bootstrap_service.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

import '../models/referential_models.dart';
import '../services/database_service.dart';

class ReferentialBootstrapService {
  final DatabaseService db;

  ReferentialBootstrapService(this.db);

  /// À appeler au démarrage de l’app.
  ///
  /// - Si aucun domaine n’est présent, on importe domaines + objectifs + questions.
  /// - Puis, dans tous les cas, on tente d’initialiser les pratiques et activités
  ///   si leurs tables sont vides.
  Future<void> initializeIfEmpty() async {
    final existingDomains = await db.getAllDomains();
    if (existingDomains.isEmpty) {
      await _initDomainsObjectivesQuestions();
    }

    // On récupère le Database sqflite brut pour les insert en batch
    final dbClient = await db.database;

    await _initPracticesIfEmpty(dbClient);
    await _initActivitiesIfEmpty(dbClient);
  }

  // ---------------------------------------------------------------------------
  // 1) Domaines / Objectifs / Questions (ton code d’origine, déplacé ici)
  // ---------------------------------------------------------------------------
  Future<void> _initDomainsObjectivesQuestions() async {
    // 1) Charger les JSON depuis les assets
    final domainsJson =
        jsonDecode(await rootBundle.loadString('assets/cobit_domains.json'))
            as List<dynamic>;
    final objectivesJson =
        jsonDecode(await rootBundle.loadString('assets/cobit_objectives.json'))
            as List<dynamic>;
    final questionsJson =
        jsonDecode(await rootBundle.loadString('assets/cobit_questions.json'))
            as List<dynamic>;

    // 2) Insérer les domaines
    // On garde un mapping code -> id en base
    final Map<String, int> domainIdByCode = {};

    for (final d in domainsJson) {
      final dom = CobitDomainRef(
        code: d['code'] as String,
        name: d['name'] as String,
      );
      final newId = await db.insertDomain(dom);
      domainIdByCode[dom.code] = newId;
    }

    // 3) Insérer les objectifs / processus
    // On garde un mapping objectiveId (APO05...) -> processId SQL
    final Map<String, int> processIdByObjectiveId = {};

    for (final o in objectivesJson) {
      final objectiveId = o['id'] as String; // ex: "APO05"
      final name = o['name'] as String;
      final domainCode = o['domain'] as String; // ex: "APO"
      final domainId = domainIdByCode[domainCode];
      if (domainId == null) {
        // domaine non trouvé -> on ignore ou on log
        continue;
      }

      final processRef = CobitProcessRef(
        domainId: domainId,
        code: objectiveId,
        name: name,
      );
      final newId = await db.insertProcess(processRef);
      processIdByObjectiveId[objectiveId] = newId;
    }

    // 4) Insérer les questions
    for (final q in questionsJson) {
      // ex: "APO05.Q1"
      final text = q['text'] as String;
      final objectiveId = q['objectiveId'] as String; // ex: "APO05"

      final processId = processIdByObjectiveId[objectiveId];
      if (processId == null) {
        // objectif non trouvé -> on ignore ou log
        continue;
      }

      final questionRef = CobitQuestionRef(processId: processId, text: text);
      await db.insertQuestion(questionRef);
    }
  }

  // ---------------------------------------------------------------------------
  // 2) Pratiques de management (table cobit_practices)
  // ---------------------------------------------------------------------------
  Future<void> _initPracticesIfEmpty(Database dbClient) async {
    final count =
        Sqflite.firstIntValue(
          await dbClient.rawQuery('SELECT COUNT(*) FROM cobit_practices'),
        ) ??
        0;

    if (count > 0) {
      // La table est déjà alimentée : on ne refait pas l’import
      return;
    }

    // JSON au format :
    // [
    //   {
    //     "id": "EDM01",
    //     "name": "...",
    //     "name_en": "...",
    //     "purpose": "...",
    //     "management_practices": [
    //       {
    //         "id": "EDM01.01",
    //         "name": "...",
    //         "description": "..."
    //       },
    //       ...
    //     ]
    //   },
    //   ...
    // ]
    final raw = await rootBundle.loadString('assets/cobit_practices.json');
    final List<dynamic> data = jsonDecode(raw) as List<dynamic>;

    final batch = dbClient.batch();

    for (final obj in data) {
      final map = obj as Map<String, dynamic>;
      final String objectiveId = map['id'] as String; // ex: "EDM01", "APO13"

      final List<dynamic> practices =
          map['management_practices'] as List<dynamic>? ?? [];

      for (final p in practices) {
        final pm = p as Map<String, dynamic>;

        final id = pm['id'] as String; // ex: "EDM01.01"
        final name = pm['name'] as String? ?? '';
        final description = pm['description'] as String? ?? '';

        batch.insert('cobit_practices', {
          'id': id,
          'objectiveId': objectiveId,
          'name': name,
          'description': description,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }

    await batch.commit(noResult: true);
  }

  // ---------------------------------------------------------------------------
  // 3) Activités (table cobit_activities) – optionnel
  // ---------------------------------------------------------------------------
  ///
  /// Format JSON attendu (si tu as ce fichier) :
  ///
  /// [
  ///   {
  ///     "practiceId": "EDM01.01",
  ///     "activities": [
  ///       { "id": "EDM01.01-A1", "description": "..." },
  ///       { "id": "EDM01.01-A2", "description": "..." }
  ///     ]
  ///   },
  ///   ...
  /// ]
  ///
  Future<void> _initActivitiesIfEmpty(Database dbClient) async {
    final count =
        Sqflite.firstIntValue(
          await dbClient.rawQuery('SELECT COUNT(*) FROM cobit_activities'),
        ) ??
        0;

    if (count > 0) {
      return;
    }

    try {
      final raw = await rootBundle.loadString('assets/cobit_activities.json');
      final List<dynamic> data = jsonDecode(raw) as List<dynamic>;

      final batch = dbClient.batch();

      for (final bloc in data) {
        final b = bloc as Map<String, dynamic>;
        final String practiceId = b['practiceId'] as String;
        final List<dynamic> activities =
            b['activities'] as List<dynamic>? ?? [];

        for (final a in activities) {
          final am = a as Map<String, dynamic>;
          final id = am['id'] as String;
          final description = am['description'] as String? ?? '';

          batch.insert('cobit_activities', {
            'id': id,
            'description': description,
            'practiceId': practiceId,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      await batch.commit(noResult: true);
    } catch (_) {
      // Si le fichier n’existe pas encore, on ignore tranquillement.
      // Tu pourras l’ajouter plus tard sans casser le démarrage.
    }
  }
}
