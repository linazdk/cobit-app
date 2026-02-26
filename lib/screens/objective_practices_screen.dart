// lib/screens/objective_practices_screen.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../models/cobit_practice_models.dart';
// CobitManagementPractice, CobitActivity

class ObjectivePracticesScreen extends StatelessWidget {
  /// Code de l'objectif / processus, ex : "EDM01", "APO13"
  final String objectiveCode;

  /// Libellé de l'objectif / processus
  final String objectiveName;

  /// Pratiques de management liées à cet objectif
  final List<CobitManagementPractice> practices;

  /// Activités par id de pratique (ex : "EDM01.01" -> [activités...])
  final Map<String, List<CobitActivity>> activitiesByPracticeId;

  const ObjectivePracticesScreen({
    super.key,
    required this.objectiveCode,
    required this.objectiveName,
    required this.practices,
    required this.activitiesByPracticeId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$objectiveCode – Pratiques & activités',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: practices.isEmpty
          ? const Center(
              child: Text(
                'Aucune pratique de management définie pour cet objectif COBIT.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // En-tête objectif
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$objectiveCode – $objectiveName',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Liste des pratiques
                ...practices.map((p) {
                  final activities =
                      activitiesByPracticeId[p.id] ?? const <CobitActivity>[];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      leading: CircleAvatar(
                        backgroundColor: scheme.primaryContainer.withOpacity(
                          0.9,
                        ),
                        foregroundColor: scheme.onPrimaryContainer,
                        child: Text(
                          p.id.split('.').last, // ex : "01"
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(
                        p.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: p.description.trim().isEmpty
                          ? null
                          : Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                p.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),

                      // Contenu développé : description complète + activités
                      children: [
                        if (p.description.trim().isNotEmpty) ...[
                          Text(
                            p.description,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                        ],
                        Text(
                          'Activités associées',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (activities.isEmpty)
                          Text(
                            'Aucune activité détaillée définie pour cette pratique.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: scheme.onSurfaceVariant,
                            ),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: activities.map((a) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• '),
                                    Expanded(
                                      child: Text(
                                        a.description.isNotEmpty
                                            ? a.description
                                            : a.id,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
    );
  }
}
