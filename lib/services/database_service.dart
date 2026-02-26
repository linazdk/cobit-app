import 'package:cobit/models/cobit_practice_models.dart';
import 'package:cobit/models/gap.dart';
import 'package:cobit/models/objective_target_models.dart';
import 'package:cobit/models/referential_models.dart';
import 'package:sqflite/sqflite.dart';
import '../db/app_database.dart';
import '../models/audit_persistence_models.dart';

class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();

  Future<Database> get database async {
    return await AppDatabase.instance.database;
  }

  // ---------------------------------------------------------------------------
  // Organizations
  // ---------------------------------------------------------------------------

  Future<int> insertOrganization(Organization org) async {
    final db = await database;
    return db.insert('organizations', org.toMap());
  }

  Future<List<Organization>> getOrganizations() async {
    final db = await database;
    final maps = await db.query('organizations', orderBy: 'name ASC');
    return maps.map((m) => Organization.fromMap(m)).toList();
  }

  // ---------------------------------------------------------------------------
  // Audits
  // ---------------------------------------------------------------------------

  Future<int> insertAudit(Audit audit) async {
    final db = await database;
    return db.insert('audits', audit.toMap());
  }

  Future<List<Audit>> getAuditsForOrganization(int organizationId) async {
    final db = await database;
    final maps = await db.query(
      'audits',
      where: 'organization_id = ?',
      whereArgs: [organizationId],
      orderBy: 'date DESC',
    );
    return maps.map((m) => Audit.fromMap(m)).toList();
  }

  Future<int> updateAudit(Audit audit) async {
    final db = await database;
    return db.update(
      'audits',
      audit.toMap(),
      where: 'id = ?',
      whereArgs: [audit.id],
    );
  }
  // ---------------------------------------------------------------------------
  // Answers
  // ---------------------------------------------------------------------------

  Future<List<Answer>> getAnswersForAudit(int auditId) async {
    final db = await database;
    final maps = await db.query(
      'answers',
      where: 'audit_id = ?',
      whereArgs: [auditId],
    );
    return maps.map((m) => Answer.fromMap(m)).toList();
  }

  Future<void> upsertAnswer(Answer answer) async {
    final db = await database;

    final existing = await db.query(
      'answers',
      where: 'audit_id = ? AND question_id = ?',
      whereArgs: [answer.auditId, answer.questionId],
    );

    if (existing.isEmpty) {
      await db.insert('answers', answer.toMap());
    } else {
      final id = existing.first['id'] as int;
      await db.update(
        'answers',
        answer.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<Audit?> getAuditById(int id) async {
    final db = await database;
    final maps = await db.query('audits', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) return null;
    return Audit.fromMap(maps.first);
  }

  Future<int> insertGap(Gap gap) async {
    final db = await database;
    return await db.insert('gaps', gap.toMap());
  }

  Future<List<Gap>> getGapsForAudit(int auditId) async {
    final db = await database;
    final maps = await db.query(
      'gaps',
      where: 'audit_id = ?',
      whereArgs: [auditId],
      orderBy: 'severity DESC, detected_at DESC',
    );
    return maps.map((m) => Gap.fromMap(m)).toList();
  }

  Future<Gap?> getGapById(int id) async {
    final db = await database;
    final maps = await db.query(
      'gaps',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Gap.fromMap(maps.first);
  }

  Future<int> updateGap(Gap gap) async {
    final db = await database;
    return await db.update(
      'gaps',
      gap.toMap(),
      where: 'id = ?',
      whereArgs: [gap.id],
    );
  }

  Future<int> deleteGap(int id) async {
    final db = await database;
    return await db.delete('gaps', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> upsertObjectiveTarget(ObjectiveTarget target) async {
    final db = await database;

    // On essaie de trouver une cible existante pour (auditId, objectiveId)
    final existing = await db.query(
      'objective_targets',
      where: 'audit_id = ? AND objective_id = ?',
      whereArgs: [target.auditId, target.objectiveId],
      limit: 1,
    );

    if (existing.isEmpty) {
      await db.insert('objective_targets', target.toMap());
    } else {
      final id = existing.first['id'] as int;
      await db.update(
        'objective_targets',
        target.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<List<ObjectiveTarget>> getObjectiveTargetsForAudit(int auditId) async {
    final db = await database;
    final maps = await db.query(
      'objective_targets',
      where: 'audit_id = ?',
      whereArgs: [auditId],
    );
    return maps.map((m) => ObjectiveTarget.fromMap(m)).toList();
  }

  Future<int> deleteObjectiveTargetsForAudit(int auditId) async {
    final db = await database;
    return db.delete(
      'objective_targets',
      where: 'audit_id = ?',
      whereArgs: [auditId],
    );
  }

  // lib/services/database_service.dart

  Future<int> deleteOrganization(int organizationId) async {
    final db = await database;
    // Grâce au ON DELETE CASCADE, les audits, réponses, écarts liés seront supprimés
    return await db.delete(
      'organizations',
      where: 'organization_id = ?',
      whereArgs: [organizationId],
    );
  }

  Future<int> deleteAudit(int auditId) async {
    final db = await database;
    // Les réponses (answers), écarts (gaps) liés à cet audit sont supprimés via les FK en cascade
    return await db.delete('audits', where: 'id = ?', whereArgs: [auditId]);
  }

  // ---------------------------------------------------------------------------
  // Référentiel COBIT : domaines, processus (objectifs), questions
  // ---------------------------------------------------------------------------

  // ----- DOMAINS -----

  Future<List<CobitDomainRef>> getAllDomains() async {
    final db = await database;
    final maps = await db.query('cobit_domains', orderBy: 'code ASC');
    return maps.map((m) => CobitDomainRef.fromMap(m)).toList();
  }

  Future<int> insertDomain(CobitDomainRef domain) async {
    final db = await database;
    return await db.insert('cobit_domains', domain.toMap());
  }

  Future<int> updateDomain(CobitDomainRef domain) async {
    if (domain.id == null) {
      throw ArgumentError('updateDomain: id manquant');
    }
    final db = await database;
    return await db.update(
      'cobit_domains',
      domain.toMap(),
      where: 'id = ?',
      whereArgs: [domain.id],
    );
  }

  Future<int> deleteDomain(int id) async {
    final db = await database;
    // grâce au ON DELETE CASCADE, les processus & questions liés seront supprimés
    return await db.delete('cobit_domains', where: 'id = ?', whereArgs: [id]);
  }

  // ----- PROCESSES / OBJECTIFS -----

  Future<List<CobitProcessRef>> getProcessesForDomain(int domainId) async {
    final db = await database;
    final maps = await db.query(
      'cobit_processes',
      where: 'domain_id = ?',
      whereArgs: [domainId],
      orderBy: 'code ASC',
    );
    return maps.map((m) => CobitProcessRef.fromMap(m)).toList();
  }

  Future<int> insertProcess(CobitProcessRef process) async {
    final db = await database;
    return await db.insert('cobit_processes', process.toMap());
  }

  Future<int> updateProcess(CobitProcessRef process) async {
    if (process.id == null) {
      throw ArgumentError('updateProcess: id manquant');
    }
    final db = await database;
    return await db.update(
      'cobit_processes',
      process.toMap(),
      where: 'id = ?',
      whereArgs: [process.id],
    );
  }

  Future<int> deleteProcess(int id) async {
    final db = await database;
    // ON DELETE CASCADE supprime aussi les questions liées
    return await db.delete('cobit_processes', where: 'id = ?', whereArgs: [id]);
  }

  // ----- QUESTIONS -----

  Future<List<CobitQuestionRef>> getQuestionsForProcess(int processId) async {
    final db = await database;
    final maps = await db.query(
      'questions',
      where: 'process_id = ?',
      whereArgs: [processId],
      orderBy: 'id ASC',
    );
    return maps.map((m) => CobitQuestionRef.fromMap(m)).toList();
  }

  Future<int> insertQuestion(CobitQuestionRef question) async {
    final db = await database;
    return await db.insert('questions', question.toMap());
  }

  Future<int> updateQuestion(CobitQuestionRef question) async {
    if (question.id == null) {
      throw ArgumentError('updateQuestion: id manquant');
    }
    final db = await database;
    return await db.update(
      'questions',
      question.toMap(),
      where: 'id = ?',
      whereArgs: [question.id],
    );
  }

  Future<int> deleteQuestion(int id) async {
    final db = await database;
    return await db.delete('questions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<CobitManagementPractice>> getManagementPracticesForObjectiveCode(
    String objectiveCode,
  ) async {
    final dbClient = await database;
    final rows = await dbClient.query(
      'cobit_practices',
      where: 'objectiveCode = ?',
      whereArgs: [objectiveCode],
      orderBy: 'id',
    );
    return rows.map((r) => CobitManagementPractice.fromMap(r)).toList();
  }

  Future<List<CobitActivity>> getActivitiesForPracticeIds(
    List<String> practiceIds,
  ) async {
    if (practiceIds.isEmpty) return [];
    final dbClient = await database;

    final placeholders = List.filled(practiceIds.length, '?').join(',');
    final rows = await dbClient.rawQuery(
      'SELECT * FROM cobit_activities WHERE practiceId IN ($placeholders)',
      practiceIds,
    );
    return rows.map((r) => CobitActivity.fromMap(r)).toList();
  }

  Future<List<CobitManagementPractice>> getPracticesForObjective(
    String objectiveId,
  ) async {
    final dbClient = await database;
    final rows = await dbClient.query(
      'cobit_practices',
      where: 'objectiveId = ?',
      whereArgs: [objectiveId],
      orderBy: 'id',
    );
    return rows.map((r) => CobitManagementPractice.fromMap(r)).toList();
  }

  Future<int> insertPractice(CobitManagementPractice practice) async {
    final db = await database;
    return await db.insert('cobit_practices', practice.toMap());
  }

  Future<int> updatePractice(CobitManagementPractice practice) async {
    final db = await database;
    return await db.update(
      'cobit_practices',
      practice.toMap(),
      where: 'id = ?',
      whereArgs: [practice.id],
    );
  }

  Future<int> deletePractice(String practiceId) async {
    final db = await database;
    return await db.delete(
      'cobit_practices',
      where: 'id = ?',
      whereArgs: [practiceId],
    );
  }

  Future<List<CobitActivity>> getActivitiesForPractice(
    String practiceId,
  ) async {
    final dbClient = await database;
    final rows = await dbClient.query(
      'cobit_activities',
      where: 'practiceId = ?',
      whereArgs: [practiceId],
      orderBy: 'id',
    );
    return rows.map((r) => CobitActivity.fromMap(r)).toList();
  }

  Future<int> insertActivity(CobitActivity activity) async {
    final db = await database;
    return await db.insert('cobit_activities', activity.toMap());
  }

  Future<int> updateActivity(CobitActivity activity) async {
    final db = await database;
    return await db.update(
      'cobit_activities',
      activity.toMap(),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

  Future<int> deleteActivity(String id) async {
    final db = await database;
    return await db.delete(
      'cobit_activities',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
