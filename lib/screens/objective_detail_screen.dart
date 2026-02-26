// lib/screens/objective_detail_screen.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/audit_controller.dart';
import '../models/audit_persistence_models.dart';
import '../models/cobit_models.dart';
import '../workflow/audit_workflow.dart';

class ObjectiveDetailScreen extends StatelessWidget {
  final CobitObjective objective;
  final Audit audit;

  const ObjectiveDetailScreen({
    super.key,
    required this.objective,
    required this.audit,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuditController>();

    final status = audit.statusEnum;
    final canEdit =
        status == AuditStatus.draft || status == AuditStatus.inProgress;

    final questions = controller.questions
        .where((q) => q.objectiveId == objective.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(objective.id, style: const TextStyle(fontSize: 20)),
      ),
      body: Column(
        children: [
          if (!canEdit)
            Container(
              width: double.infinity,
              color: Colors.orange.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: const Text(
                'This audit is in review or validated: answers are read-only.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final q = questions[index];
                final answer = controller.getAnswer(q.id);
                final checklist = controller.checklistForQuestion(q.id);
                final metrics = controller.metricsForObjective(objective.id);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q.text,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              'Score: $answer / 5',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                        Slider(
                          min: 0,
                          max: 5,
                          divisions: 5,
                          value: answer.toDouble(),
                          label: '$answer',
                          onChanged: canEdit
                              ? (v) {
                                  controller.setAnswer(q.id, v.round());
                                }
                              : null,
                        ),
                      ],
                    ),
                    children: [
                      if (checklist == null)
                        const Text(
                          'No detailed checklist is defined for this question.',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Detailed checklist:',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            ...List.generate(checklist.items.length, (i) {
                              final item = checklist.items[i];
                              final ticks = controller.getChecklistTicks(q.id);
                              final checked = ticks.contains(i);

                              return CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(item.text),
                                value: checked,
                                onChanged: canEdit
                                    ? (_) {
                                        controller.toggleChecklistItem(q.id, i);
                                      }
                                    : null,
                              );
                            }),
                          ],
                        ),
                      if (metrics.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Recommended COBIT metrics for this objective',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                ...metrics.map(
                                  (m) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('• '),
                                        Expanded(child: Text(m)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
