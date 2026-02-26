// lib/screens/gap_detail_screen.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cobit/models/gap.dart';
import '../services/database_service.dart';

/// Same list as in gap_list_screen (you can factor it later
/// into a shared file if you want to avoid duplication).
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

class GapDetailScreen extends StatefulWidget {
  final Gap gap;

  const GapDetailScreen({Key? key, required this.gap}) : super(key: key);

  @override
  State<GapDetailScreen> createState() => _GapDetailScreenState();
}

class _GapDetailScreenState extends State<GapDetailScreen> {
  final db = DatabaseService.instance;
  late Gap _gap;

  @override
  void initState() {
    super.initState();
    _gap = widget.gap;
  }

  Future<void> _saveUpdatedGap(Gap updated) async {
    if (updated.id == null) {
      // gap not yet stored in DB → do not try to update
      return;
    }
    await db.updateGap(updated);
    setState(() {
      _gap = updated;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Gap updated')));
  }

  Future<void> _showEditDialog() async {
    final titleController = TextEditingController(text: _gap.title);
    final ownerController = TextEditingController(text: _gap.owner ?? '');

    int selectedSeverity = _gap.severity;
    int selectedStatus = _gap.status;
    String? selectedPredefinedTitle;

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              scrollable: true, // 👈 very important to avoid overflows
              title: const Text('Edit gap'),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🔽 Pre-filled title
                      DropdownButtonFormField<String>(
                        value: selectedPredefinedTitle,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Title (pre-filled)',
                        ),
                        items: predefinedGapTitles.map((title) {
                          return DropdownMenuItem<String>(
                            value: title,
                            child: SizedBox(
                              width: double
                                  .infinity, // 👈 force text to respect available width
                              child: Text(
                                title,
                                maxLines: 1, // 👈 single line
                                softWrap: false,
                                overflow: TextOverflow
                                    .ellipsis, // 👈 "..." instead of overflow
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setStateDialog(() {
                            selectedPredefinedTitle = value;
                            titleController.text = value ?? '';
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      // 🔽 Customizable title
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title (customizable)',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Title is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // 🔽 Severity
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

                      const SizedBox(height: 12),

                      // 🔽 Status
                      DropdownButtonFormField<int>(
                        value: selectedStatus,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('Detected')),
                          DropdownMenuItem(value: 1, child: Text('Validated')),
                          DropdownMenuItem(value: 2, child: Text('Planned')),
                          DropdownMenuItem(
                            value: 3,
                            child: Text('In progress'),
                          ),
                          DropdownMenuItem(value: 4, child: Text('Closed')),
                        ],
                        onChanged: (value) {
                          setStateDialog(() {
                            selectedStatus = value ?? selectedStatus;
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      // 🔽 Owner
                      TextFormField(
                        controller: ownerController,
                        decoration: const InputDecoration(labelText: 'Owner'),
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
                      final updated = _gap.copyWith(
                        title: titleController.text.trim(),
                        severity: selectedSeverity,
                        status: selectedStatus,
                        owner: ownerController.text.trim().isEmpty
                            ? null
                            : ownerController.text.trim(),
                        closedAt: selectedStatus == 4
                            ? (_gap.closedAt ?? DateTime.now())
                            : null,
                      );
                      await _saveUpdatedGap(updated);
                      if (!mounted) return;
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      // _gap is already updated in _saveUpdatedGap
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gap details', style: const TextStyle(fontSize: 20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _gap.title,
              style: Theme.of(context).textTheme.headlineSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(_severityLabel(_gap.severity)),
                  backgroundColor: _severityColor(
                    _gap.severity,
                  ).withOpacity(0.15),
                ),
                const SizedBox(width: 8),
                Chip(label: Text(_statusLabel(_gap.status))),
              ],
            ),
            const SizedBox(height: 16),

            if (_gap.description != null && _gap.description!.trim().isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(_gap.description!),
                  const SizedBox(height: 16),
                ],
              ),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow('Owner', _gap.owner ?? 'Not defined'),
                    const SizedBox(height: 8),
                    _infoRow('Detected on', _formatDate(_gap.detectedAt)),
                    if (_gap.targetCloseDate != null) ...[
                      const SizedBox(height: 8),
                      _infoRow('Due date', _formatDate(_gap.targetCloseDate!)),
                    ],
                    if (_gap.closedAt != null) ...[
                      const SizedBox(height: 8),
                      _infoRow('Closed on', _formatDate(_gap.closedAt!)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text('Progress', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: _gap.progress.clamp(0.0, 1.0),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${(_gap.progress * 100).round()} %'),
              ],
            ),
            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _showEditDialog,
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
            ),
          ],
        ),
      ),
    );
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(flex: 3, child: Text(value)),
      ],
    );
  }
}
