// lib/screens/question_list_screen.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/audit_controller.dart';
import '../models/audit_persistence_models.dart';
import '../models/cobit_models.dart';
import '../workflow/audit_workflow.dart';

class QuestionListScreen extends StatefulWidget {
  final Audit audit;
  final CobitObjective
  process; // here "process" = COBIT objective (APO01, EDM01...)

  const QuestionListScreen({
    super.key,
    required this.audit,
    required this.process,
  });

  @override
  State<QuestionListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen> {
  final Map<String, TextEditingController> _commentControllers = {};

  @override
  void dispose() {
    for (final c in _commentControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuditController>();

    final status = widget.audit.statusEnum;
    final canEdit =
        status == AuditStatus.draft || status == AuditStatus.inProgress;

    final questions = controller.questions
        .where((q) => q.objectiveId == widget.process.id)
        .toList();

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('${widget.process.id} – Questions')),
        body: const Center(
          child: Text('No question defined for this objective.'),
        ),
      );
    }

    for (final q in questions) {
      _commentControllers.putIfAbsent(q.id, () => TextEditingController());
    }

    return Scaffold(
      appBar: AppBar(title: Text('${widget.process.id} – Questions')),
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
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final q = questions[index];
                final currentLevel = controller.getAnswer(q.id);

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q.text,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<int>(
                          hint: const Text('Maturity level (0–5)'),
                          value: currentLevel,
                          items: List.generate(
                            6,
                            (i) =>
                                DropdownMenuItem(value: i, child: Text('$i')),
                          ),
                          onChanged: canEdit
                              ? (value) async {
                                  if (value == null) return;
                                  await controller.setAnswer(q.id, value);
                                }
                              : null,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _commentControllers[q.id],
                          readOnly: !canEdit,
                          decoration: InputDecoration(
                            labelText: canEdit
                                ? 'Comment'
                                : 'Comment (read-only)',
                            border: const OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton(
              tooltip: 'Scores are automatically saved',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Scores are already saved automatically.'),
                  ),
                );
              },
              child: const Icon(Icons.save),
            )
          : null,
    );
  }
}
