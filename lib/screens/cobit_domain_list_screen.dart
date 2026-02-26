import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/audit_controller.dart';
import '../models/audit_persistence_models.dart'; // Audit
import '../models/cobit_models.dart'; // CobitDomain + CobitObjective
import '../utils/scope_utils.dart';
import 'domain_detail_screen.dart';
import 'audit_summary_screen.dart';

class CobitDomainListScreen extends StatelessWidget {
  final Audit audit;

  const CobitDomainListScreen({super.key, required this.audit});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuditController>();

    // All known COBIT domains
    final allDomains = CobitDomain.values;

    // Read the detailed scope (APO05, DSS03, ...) from audit.scope
    final scopedObjectiveIds = parseScopeToObjectiveIds(audit.scope);

    // If no scope → show all domains
    List<CobitDomain> displayedDomains;
    if (scopedObjectiveIds.isEmpty) {
      displayedDomains = allDomains.toList();
    } else {
      // Otherwise, keep only domains that contain at least
      // one objective included in the scope.
      final objectives = controller.objectives; // List<CobitObjective>

      final allowedDomains = <CobitDomain>{};

      for (final obj in objectives) {
        if (scopedObjectiveIds.contains(obj.id)) {
          allowedDomains.add(obj.domain);
        }
      }

      displayedDomains = allDomains
          .where((d) => allowedDomains.contains(d))
          .toList();

      // Optional: sort for a stable ordering
      displayedDomains.sort((a, b) => a.code.compareTo(b.code));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'COBIT Domains (Audit ${audit.id})',
          style: const TextStyle(fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.assessment),
            tooltip: 'Global summary',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AuditSummaryScreen(audit: audit),
                ),
              );
            },
          ),
        ],
      ),
      body: displayedDomains.isEmpty
          ? const Center(
              child: Text(
                'No domain matches the scope defined for this audit.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: displayedDomains.length,
              itemBuilder: (context, index) {
                final d = displayedDomains[index];

                return ListTile(
                  title: Text('${d.code} - ${d.label}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            DomainDetailScreen(domain: d, audit: audit),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
