import 'package:cobit/models/audit_persistence_models.dart';
import 'package:cobit/services/database_service.dart';

/// DbHelper est maintenant une simple façade par-dessus DatabaseService.
/// Il n'ouvre plus sa propre base, n'a plus de schéma séparé.
class DbHelper {
  DbHelper._internal();
  static final DbHelper instance = DbHelper._internal();

  final DatabaseService _dbService = DatabaseService.instance;

  // ---------- ORGANISATIONS ----------

  Future<int> insertOrganization(Organization org) {
    return _dbService.insertOrganization(org);
  }

  Future<List<Organization>> getOrganizations() {
    return _dbService.getOrganizations();
  }

  // ---------- AUDITS ----------

  /// Pour compatibilité avec l'ancien nom `getAuditsForOrg`
  Future<int> insertAudit(Audit audit) {
    return _dbService.insertAudit(audit);
  }

  Future<List<Audit>> getAuditsForOrg(int orgId) {
    return _dbService.getAuditsForOrganization(orgId);
  }

  // ---------- ANSWERS ----------

  Future<void> upsertAnswer(Answer answer) {
    return _dbService.upsertAnswer(answer);
  }

  Future<List<Answer>> getAnswersForAudit(int auditId) {
    return _dbService.getAnswersForAudit(auditId);
  }
}
