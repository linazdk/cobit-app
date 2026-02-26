import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/audit_controller.dart';
import '../models/audit_persistence_models.dart';
import '../models/cobit_models.dart';
import 'action_plan_screen.dart';

class AuditSummaryScreen extends StatelessWidget {
  final Audit audit;

  const AuditSummaryScreen({super.key, required this.audit});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuditController>();

    // Global score (0–5), converted to %
    final rawGlobal = controller.globalScore();
    final globalPercent = rawGlobal * 20.0;
    final globalLevel = controller.capabilityLevel(globalPercent);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Audit summary',
          style: const TextStyle(fontSize: 20),
        ),
        bottom: PreferredSize(
          preferredSize: Size.zero,
          child: Text('Audit ${audit.id ?? ""}', textAlign: TextAlign.left),
        ),
        actions: [
          // Export button
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export report',
            onPressed: () => _exportAudit(context),
          ),

          // Action plan threshold
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Set action plan threshold',
            onPressed: () => _showThresholdDialog(context),
          ),

          // Action plan access
          IconButton(
            icon: const Icon(Icons.flag),
            tooltip: 'Open action plan',
            onPressed: () {
              if (audit.id == null) return;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ActionPlanScreen(auditId: audit.id!),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Global score card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Global score',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${globalPercent.toStringAsFixed(1)} % (Level $globalLevel)',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Scores by domain',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Domain scores
          ...CobitDomain.values.map((d) {
            final raw = controller.domainScore(d); // 0–5
            final percent = raw * 20.0;
            final level = controller.capabilityLevel(percent);
            final recommendation = controller.recommendationForDomain(d);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text('${d.code} – ${d.label}'),
                subtitle: Text(
                  'Score: ${percent.toStringAsFixed(1)} %  (Level $level)\n'
                  'Recommendation: $recommendation',
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _exportAudit(BuildContext context) {
    // TODO: implement your export logic (PDF, Excel, etc.)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export not implemented yet.')),
    );
  }

  void _showThresholdDialog(BuildContext context) {
    final controller = Provider.of<AuditController>(context, listen: false);
    double value = controller.actionPlanThreshold;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Action plan threshold'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: value,
                min: 0,
                max: 100,
                divisions: 20,
                label: '${value.round()} %',
                onChanged: (v) {
                  setState(() => value = v);
                },
              ),
              Text('${value.round()} %'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.setActionPlanThreshold(value);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
