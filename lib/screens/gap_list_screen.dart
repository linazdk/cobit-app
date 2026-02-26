// ignore_for_file: deprecated_member_use

import 'package:cobit/models/gap.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'gap_detail_screen.dart';

class GapTemplate {
  final String label; // short label, for the menu
  final String title; // full title, for the field

  const GapTemplate({required this.label, required this.title});
}

const List<GapTemplate> gapTemplates = [
  GapTemplate(
    label: 'IT alignment',
    title: 'IT objectives not aligned with strategic objectives',
  ),
  GapTemplate(label: 'Risk governance', title: 'No governance over IT risks'),
  GapTemplate(label: 'Steering committee', title: 'No IT steering committee'),

  // APO
  GapTemplate(label: 'IT roadmap', title: 'No strategic IT roadmap'),
  GapTemplate(
    label: 'Security policies',
    title: 'Security policies incomplete or outdated',
  ),
  GapTemplate(
    label: 'Risk register',
    title: 'IT risk register not kept up to date',
  ),
  GapTemplate(label: 'Training plan', title: 'No IT training plan'),
  GapTemplate(label: 'Service catalog', title: 'No IT services catalog'),

  // etc. you can add as many as you want
];

/// Predefined gap titles, used in the creation form.
const List<String> predefinedGapTitles = [
  // Governance (EDM)
  'IT objectives not aligned with strategic objectives',
  'No governance over IT risks',
  'No IT steering committee',

  // Alignment / Planning (APO)
  'No strategic IT roadmap',
  'Security policies incomplete or outdated',
  'IT risk register not kept up to date',
  'No IT training plan',
  'IT budget not formalized',
  'No IT services catalog',

  // Build & Implementation (BAI)
  'Business requirements not validated before development',
  'Insufficient technical documentation',
  'Tests not formalized or incomplete',
  'No deployment plan defined',
  'Change management not under control',

  // Delivery & Support (DSS)
  'No incident tracking',
  'Recurring incidents not addressed',
  'No access management procedure',
  'Backups unreliable or not tested',
  'No business continuity plan available',
  'No configuration management',

  // Monitoring / Audit (MEA)
  'IT KPIs not measured',
  'No recurring IT audits',
  'Action plans not monitored',
  'Audit findings not closed',
];

class GapListScreen extends StatefulWidget {
  final int auditId;

  const GapListScreen({Key? key, required this.auditId}) : super(key: key);

  @override
  State<GapListScreen> createState() => _GapListScreenState();
}

class _GapListScreenState extends State<GapListScreen> {
  final db = DatabaseService.instance;
  late Future<List<Gap>> _futureGaps;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _futureGaps = db.getGapsForAudit(widget.auditId);
    });
  }

  Future<void> _showCreateGapDialog() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    int selectedSeverity = 1; // 0 = minor, 1 = major, 2 = critical
    GapTemplate? selectedTemplate;

    final formKey = GlobalKey<FormState>();

    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              scrollable: true,
              title: const Text('New gap'),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🔽 Dropdown with short labels
                      DropdownButtonFormField<GapTemplate>(
                        value: selectedTemplate,
                        decoration: const InputDecoration(
                          labelText: 'Title (pre-filled)',
                        ),
                        items: gapTemplates.map((tpl) {
                          return DropdownMenuItem<GapTemplate>(
                            value: tpl,
                            child: Text(tpl.label), // short -> no overflow
                          );
                        }).toList(),
                        onChanged: (tpl) {
                          setStateDialog(() {
                            selectedTemplate = tpl;
                            titleController.text = tpl?.title ?? '';
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      // 🔽 Customizable title (filled from dropdown)
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title (customizable)',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Title is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: descController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 12),

                      DropdownButtonFormField<int>(
                        value: selectedSeverity,
                        decoration: const InputDecoration(
                          labelText: 'Severity',
                        ),
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('Minor')),
                          DropdownMenuItem(value: 1, child: Text('Major')),
                          DropdownMenuItem(value: 2, child: Text('Critical')),
                        ],
                        onChanged: (value) {
                          setStateDialog(() {
                            selectedSeverity = value ?? 1;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      final gap = Gap(
                        auditId: widget.auditId,
                        title: titleController.text.trim(),
                        description: descController.text.trim().isEmpty
                            ? null
                            : descController.text.trim(),
                        severity: selectedSeverity,
                        status: 0, // Detected
                        detectedAt: DateTime.now(),
                      );
                      await db.insertGap(gap);
                      if (!mounted) return;
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );

    if (created == true) {
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audit gaps')),
      body: FutureBuilder<List<Gap>>(
        future: _futureGaps,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final gaps = snapshot.data ?? [];
          if (gaps.isEmpty) {
            return const Center(child: Text('No gap for this audit.'));
          }

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.builder(
              itemCount: gaps.length,
              itemBuilder: (context, index) {
                final gap = gaps[index];
                return ListTile(
                  leading: Icon(
                    Icons.warning_amber_outlined,
                    color: _severityColor(gap.severity),
                  ),
                  title: Text(gap.title),
                  subtitle: Text(
                    '${_severityLabel(gap.severity)} · ${_statusLabel(gap.status)}',
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => GapDetailScreen(gap: gap),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateGapDialog,
        icon: const Icon(Icons.add),
        label: const Text('New gap'),
      ),
    );
  }

  Color _severityColor(int severity) {
    switch (severity) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.orange;
      case 2:
      default:
        return Colors.red;
    }
  }

  String _severityLabel(int severity) {
    switch (severity) {
      case 0:
        return 'Minor';
      case 1:
        return 'Major';
      case 2:
      default:
        return 'Critical';
    }
  }

  String _statusLabel(int status) {
    switch (status) {
      case 0:
        return 'Detected';
      case 1:
        return 'Validated';
      case 2:
        return 'Planned';
      case 3:
        return 'In progress';
      case 4:
        return 'Closed';
      default:
        return 'Unknown';
    }
  }
}
