// lib/screens/referential_objective_detail_screen.dart

import 'package:flutter/material.dart';

import '../models/cobit_models.dart'; // CobitObjective
import '../models/cobit_practice_models.dart'
    show CobitManagementPractice, CobitActivity;
import '../repositories/cobit_repository.dart';

class ReferentialObjectiveDetailScreen extends StatelessWidget {
  final CobitObjective objective;

  const ReferentialObjectiveDetailScreen({super.key, required this.objective});

  @override
  Widget build(BuildContext context) {
    final repo = CobitRepository();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${objective.id} – ${objective.name}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: FutureBuilder(
        future: Future.wait([
          repo.loadPractices(), // Future<List<CobitManagementPractice>>
          repo.loadActivities(), // Future<List<CobitActivity>>
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Loading error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data available.'));
          }

          final results = snapshot.data as List;
          final allPractices = results[0] as List<CobitManagementPractice>;
          final allActivities = results[1] as List<CobitActivity>;

          // Practices linked to this objective (e.g. APO13)
          final practices = allPractices
              .where((p) => p.objectiveId == objective.id)
              .toList();

          if (practices.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No detailed practice is defined for objective ${objective.id}.\n\n'
                'Make sure cobit_practices.json and cobit_activities.json are declared in pubspec.yaml.',
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // 🔹 Simple reminder card for the objective
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${objective.id} – ${objective.name}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Domain: ${objective.domain.code} – ${objective.domain.label}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Related practices and activities',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              ...practices.map((practice) {
                final practiceActivities = allActivities
                    .where((a) => a.practiceId == practice.id)
                    .toList();

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    title: Text(
                      '${practice.id} – ${practice.name}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    // No "purpose" field in CobitManagementPractice,
                    // we use the description as a summary
                    subtitle: practice.description.isEmpty
                        ? null
                        : Text(
                            practice.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                    children: [
                      if (practice.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          practice.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (practiceActivities.isNotEmpty) ...[
                        const Text(
                          'Main activities:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        ...practiceActivities.map(
                          (act) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: 4.0,
                              top: 2.0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• '),
                                Expanded(
                                  child: Text('${act.id} – ${act.description}'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else
                        const Text(
                          'No detailed activity defined for this practice.',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
