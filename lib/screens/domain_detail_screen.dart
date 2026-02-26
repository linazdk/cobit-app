import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/audit_controller.dart';
import '../models/cobit_models.dart';
import '../models/audit_persistence_models.dart';
import '../utils/scope_utils.dart';
import '../workflow/audit_workflow.dart';
import 'objective_detail_screen.dart';

class DomainDetailScreen extends StatelessWidget {
  final CobitDomain domain;
  final Audit audit; // ⬅️ audit passed here

  const DomainDetailScreen({
    super.key,
    required this.domain,
    required this.audit,
  });

  // Pastel background color depending on audit status
  Color _tileBackground(AuditStatus status) {
    switch (status) {
      case AuditStatus.draft:
        return const Color(0xFFF2F2F2); // light grey
      case AuditStatus.inProgress:
        return const Color(0xFFE7F1FF); // pastel blue
      case AuditStatus.inReview:
        return const Color(0xFFFFF4E5); // pastel orange
      case AuditStatus.validated:
        return const Color(0xFFE8FFE9); // pastel green
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuditController>();

    // All COBIT objectives belonging to this domain
    final allDomainObjectives = controller.objectives
        .where((o) => o.domain == domain)
        .toList();

    // Detailed scope (APO05, DSS03, ...) for this audit
    final scopedObjectiveIds = parseScopeToObjectiveIds(audit.scope);

    // If no scope defined → show all objectives in the domain
    // Otherwise → show only objectives whose ID is in the scope
    final domainObjectives = scopedObjectiveIds.isEmpty
        ? allDomainObjectives
        : allDomainObjectives
              .where((o) => scopedObjectiveIds.contains(o.id))
              .toList();

    // Primary color based on audit status
    final statusColor = audit.statusEnum.color;
    final bgColor = _tileBackground(audit.statusEnum);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              domain.code,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              domain.label,
              style: const TextStyle(fontSize: 18),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: domainObjectives.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  scopedObjectiveIds.isEmpty
                      ? 'No objectives are defined for this domain.'
                      : 'No objectives in this domain are included in the selected scope for this audit.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              itemCount: domainObjectives.length,
              itemBuilder: (context, index) {
                final obj = domainObjectives[index];

                // Raw score 0–5
                final rawScore = controller.objectiveScore(obj.id);
                // in %
                final scorePercent = rawScore * 20.0;
                // level 0–5 derived from %
                final level = controller.capabilityLevel(scorePercent);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  color:
                      bgColor, // ⬅️ pastel background according to audit status
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: statusColor, // ⬅️ badge = status color
                      child: Text(
                        level.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text('${obj.id} – ${obj.name}'),
                    subtitle: Text(
                      'Score: ${scorePercent.toStringAsFixed(1)} % (level $level)\n'
                      'Audit status: ${audit.status}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),

                    // Open objective detail
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ObjectiveDetailScreen(
                            objective: obj,
                            audit: audit, // ⬅️ important
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
