// lib/services/audit_synthesis_service.dart

import 'package:cobit/controllers/audit_controller.dart';
import 'package:cobit/models/cobit_models.dart';
import 'package:cobit/models/gap.dart';
import 'package:cobit/models/gap_template.dart';

import '../models/audit_persistence_models.dart';
import '../utils/scope_utils.dart';
import 'database_service.dart';

class AuditSynthesisService {
  final DatabaseService db;
  final AuditController controller;

  AuditSynthesisService(this.db, this.controller);

  /// Generates gaps for a given audit:
  /// - uses questions + answers from AuditController
  /// - respects the scope (audit.scope = APO01,DSS03,...)
  /// - if a target exists for the objective: maturity < target => gap
  /// - otherwise, simple fallback: maturity < 3 => gap
  /// - adds recommendations in the gap description
  Future<void> generateGapsForAudit(int auditId) async {
    // 1) Retrieve the audit to know its scope
    final Audit? audit = await db.getAuditById(auditId);

    Set<String>? scopeObjectives;
    if (audit != null &&
        audit.scope != null &&
        audit.scope!.trim().isNotEmpty) {
      // e.g. "APO01,DSS03" -> {"APO01", "DSS03"}
      scopeObjectives = parseScopeToObjectiveIds(audit.scope);
    }

    // 2) Load any targets defined for this audit
    final targets = await db.getObjectiveTargetsForAudit(auditId);
    final targetsByObjective = <String, int>{
      for (final t in targets) t.objectiveId: t.targetLevel,
    };

    // 3) Clean existing gaps for this audit
    final existingGaps = await db.getGapsForAudit(auditId);
    for (final g in existingGaps) {
      if (g.id != null) {
        await db.deleteGap(g.id!);
      }
    }

    // 4) Go through all questions known by the controller
    for (final q in controller.questions) {
      // Each question has:
      // - q.objectiveId (e.g. "APO01")
      // - q.id         (e.g. "APO01-Q1")

      // a) Respect scope, if defined
      if (scopeObjectives != null && !scopeObjectives.contains(q.objectiveId)) {
        continue; // out of scope
      }

      // b) Get maturity level (0–5)
      final maturityLevel = controller.getAnswer(q.id);

      // c) Check if there is a target for this objective
      final int? targetLevel = targetsByObjective[q.objectiveId];

      int severity;
      String reasonLine;

      if (targetLevel != null) {
        // 🔵 CASE 1: target defined for this objective
        final diff = targetLevel - maturityLevel;
        if (diff <= 0) {
          // maturity already >= target => no gap
          continue;
        }

        severity = _severityFromDifference(diff);
        reasonLine =
            'Target: $targetLevel, current level: $maturityLevel '
            '(gap of $diff level${diff > 1 ? "s" : ""}).';
      } else {
        // 🟡 CASE 2: no target => fallback on a simple rule
        if (maturityLevel >= 3) {
          // above default threshold => no gap
          continue;
        }

        severity = _severityFromMaturity(maturityLevel);
        reasonLine =
            'Current maturity level: $maturityLevel '
            '(default threshold set to 3).';
      }

      // d) Optional template for the title
      final template = _getTemplateForQuestionId(q.id);

      // e) Retrieve objective and domain to enrich recommendations
      final objective = controller.objectives.firstWhere(
        (o) => o.id == q.objectiveId,
        orElse: () => controller.objectives.first,
      );
      final domain = objective.domain;

      // Score & capability level for the related objective
      final objectiveScore0to5 = controller.objectiveScore(
        q.objectiveId,
        scopeOverride: audit?.scope,
      ); // 0–5
      final scorePercent = objectiveScore0to5 * 20.0; // 0–100%
      final level = controller.capabilityLevel(scorePercent);

      final levelReco = controller.recommendationForLevel(level);
      final domainReco = controller.recommendationForDomain(domain);
      final objectiveRecos = controller.recommendationsForObjective(
        q.objectiveId,
      );

      // f) Enriched description (finding + context + recommendations)
      final description = StringBuffer()
        ..writeln('Gap detected on COBIT question: ${q.id}.')
        ..writeln('Objective: ${q.objectiveId}.')
        ..writeln(reasonLine)
        ..writeln('Question text: ${q.text}')
        ..writeln()
        ..writeln(
          'Estimated overall level for objective ${q.objectiveId}: '
          '${objectiveScore0to5.toStringAsFixed(2)} / 5 '
          '(${scorePercent.toStringAsFixed(1)} %, level $level).',
        )
        ..writeln()
        ..writeln('Level-based recommendation (level $level):')
        ..writeln('- $levelReco')
        ..writeln()
        ..writeln(
          'Recommendations for domain ${domain.code} – ${domain.label}:',
        )
        ..writeln('- $domainReco');

      if (objectiveRecos.isNotEmpty) {
        description
          ..writeln()
          ..writeln('Specific improvement ideas for ${q.objectiveId}:');
        for (final r in objectiveRecos) {
          description.writeln('- $r');
        }
      }

      final gap = Gap(
        auditId: auditId,
        title: template?.title ?? 'Gap on question ${q.id}',
        description: description.toString(),
        severity: severity,
        status: 0, // detected
        detectedAt: DateTime.now(),
      );

      await db.insertGap(gap);
    }
  }

  /// Uses a template if you have a question -> template mapping table
  GapTemplate? _getTemplateForQuestionId(String questionId) {
    final index = questionCobitIdToTemplateIndex[questionId];
    if (index == null) return null;
    if (index < 0 || index >= cobitGapTemplates.length) return null;
    return cobitGapTemplates[index];
  }

  /// Severity derived from the difference between target and actual
  int _severityFromDifference(int diff) {
    if (diff >= 3) return 2; // critical
    if (diff == 2) return 1; // major
    return 0; // minor (diff == 1)
  }

  /// Severity derived from maturity level (fallback mode)
  int _severityFromMaturity(int maturityLevel) {
    // 0–1 : critical
    // 2   : major
    // 3+  : normally no gap (we get here only if < 3)
    if (maturityLevel <= 1) return 2; // critical
    if (maturityLevel == 2) return 1; // major
    return 0; // minor
  }
}
