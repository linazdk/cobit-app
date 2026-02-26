import 'dart:io';

import 'package:cobit/models/gap.dart';
import 'package:cobit/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../controllers/audit_controller.dart';
import '../models/audit_persistence_models.dart';
import '../models/cobit_models.dart';
import '../utils/scope_utils.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ActionPlanScreen extends StatefulWidget {
  final int auditId; // 👈 We work on a specific audit

  const ActionPlanScreen({super.key, required this.auditId});

  @override
  State<ActionPlanScreen> createState() => _ActionPlanScreenState();
}

class _ActionPlanScreenState extends State<ActionPlanScreen> {
  CobitDomain? selectedDomain; // null = all domains
  final db = DatabaseService.instance;

  bool _loading = true;
  Audit? _audit;
  List<Gap> _gaps = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final audit = await db.getAuditById(widget.auditId);
    final gaps = await db.getGapsForAudit(widget.auditId);

    setState(() {
      _audit = audit;
      _gaps = gaps;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuditController>();
    final threshold = controller.actionPlanThreshold; // in %

    if (_loading || _audit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Action plan')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 🔹 Final scope (APO05, DSS03, ...) coming from the audit
    final scope = _audit!.scope;
    final scopedObjectives = filterObjectivesByScope(
      controller.objectives,
      scope,
    );

    // 🔹 PART 1: actions based on COBIT objectives (scores) LIMITED TO THE SCOPE
    final objectiveItems = scopedObjectives
        .map((obj) {
          // ⚠️ be careful: we pass the scope to the score calculation
          final rawScore = controller.objectiveScore(
            obj.id,
            scopeOverride: scope,
          ); // 0–5

          final scorePercent = rawScore * 20.0;
          final level = controller.capabilityLevel(scorePercent);

          final recos = <String>[];
          recos.add(
            'Level $level: ${controller.recommendationForLevel(level)}',
          );
          recos.add(
            'Domain ${obj.domain.code}: ${controller.recommendationForDomain(obj.domain)}',
          );
          final metrics = controller.metricsForObjective(obj.id);
          recos.addAll(controller.recommendationsForObjective(obj.id));
          final kpiIntro = 'Recommended monitoring metrics:';
          final kpiLines = metrics.map((m) => '- $m');
          recos.add(kpiIntro);
          recos.addAll(kpiLines);
          return _ActionPlanItem(
            objectiveId: obj.id,
            objectiveName: obj.name,
            domain: obj.domain,
            scorePercent: scorePercent,
            level: level,
            recommendations: recos,
          );
        })
        // Filter on threshold
        .where((item) => item.scorePercent < threshold)
        // Filter on selected domain
        .where(
          (item) => selectedDomain == null || item.domain == selectedDomain,
        )
        .toList();

    // 🔹 PART 2: actions based on the gaps of this audit
    // (Gaps are already generated with the scope applied via AuditSynthesisService)
    final gapActionItems = _gaps.map((gap) {
      final recos = <String>[];

      // 1) General action
      recos.add('Create an action sheet for the gap: "${gap.title}".');

      // 2) Recommendations based on severity
      switch (gap.severity) {
        case 2: // Critical
          recos.addAll([
            'Classify this gap as a CRITICAL priority in the action plan.',
            'Immediately appoint an owner and validate the due date with management.',
            'Implement workaround measures to reduce the short-term risk.',
            'Inform governance bodies (executive committee / risk committee) if the impact is major.',
          ]);
          break;
        case 1: // Major
          recos.addAll([
            'Plan the remediation of this gap in the short-term action plan.',
            'Monitor progress in a regular steering committee (monthly / quarterly).',
            'Document decisions taken (prioritization, resources, budget).',
          ]);
          break;
        case 0: // Minor
        default:
          recos.addAll([
            'Record this gap in the continuous improvement process.',
            'Group similar minor gaps into a single global action where possible.',
            'Monitor how the situation evolves during future audits or committees.',
          ]);
          break;
      }

      // 3) Recommendations based on gap status
      switch (gap.status) {
        case 0: // Detected
          recos.addAll([
            'Analyze the root causes (5 whys, Ishikawa diagram, etc.).',
            'Define corrective and preventive actions with owners and deadlines.',
          ]);
          break;
        case 1: // Validated
          recos.addAll([
            'Validate the actions to be implemented with the relevant stakeholders.',
            'Include the validated gap in the official action plan (tracking tool, dashboard).',
          ]);
          break;
        case 2: // Planned
          recos.addAll([
            'Ensure that the planned actions are clearly assigned and understood.',
            'Set up follow-up checkpoints to track actual progress.',
          ]);
          break;
        case 3: // In progress
          recos.addAll([
            'Regularly monitor progress and remove blockers.',
            'Adjust the plan if new constraints appear (resources, priorities).',
          ]);
          break;
        case 4: // Closed
          recos.addAll([
            'Verify the effectiveness of the actions (tests, controls, indicators).',
            'Capture lessons learned and update procedures if required.',
          ]);
          break;
        default:
          break;
      }

      // 4) Take into account the target closure date if any
      if (gap.targetCloseDate != null) {
        final targetStr = gap.targetCloseDate!
            .toIso8601String()
            .split('T')
            .first;
        recos.add(
          'Respect the target closure date set to $targetStr and escalate any risk of slippage.',
        );
      }

      // 5) Reminder of the context if available
      if (gap.description != null && gap.description!.trim().isNotEmpty) {
        recos.add('Context / audit finding: ${gap.description!.trim()}');
      }

      return _GapActionItem(gap: gap, recommendedActions: recos);
    }).toList();

    final hasAnyContent =
        objectiveItems.isNotEmpty || gapActionItems.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text('Action plan (Audit ${_audit!.id})'),
        actions: [
          IconButton(
            tooltip: 'Export to PDF',
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: !hasAnyContent
                ? null
                : () async {
                    await _exportToPdf(
                      context,
                      objectiveItems,
                      gapActionItems,
                      threshold,
                      selectedDomain,
                      scope,
                    );
                  },
          ),
          IconButton(
            tooltip: 'Adjust threshold',
            icon: const Icon(Icons.tune),
            onPressed: () async {
              final newValue = await _showThresholdDialog(context, threshold);
              if (newValue != null) {
                context.read<AuditController>().setActionPlanThreshold(
                  newValue,
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: [
            // Scope info
            if (scope != null && scope.trim().isNotEmpty) ...[
              Text(
                'Scope: $scope',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Domain filter (applies to the objectives section)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Text(
                      'Domain: ',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<CobitDomain?>(
                        isExpanded: true,
                        value: selectedDomain,
                        items:
                            [
                              const DropdownMenuItem<CobitDomain?>(
                                value: null,
                                child: Text('All domains'),
                              ),
                            ] +
                            CobitDomain.values
                                .map(
                                  (d) => DropdownMenuItem<CobitDomain?>(
                                    value: d,
                                    child: Text(d.label),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDomain = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // SECTION 1: objectives below the threshold
            Text(
              'Actions based on COBIT objectives (below the threshold)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (objectiveItems.isEmpty)
              Text(
                selectedDomain == null
                    ? 'No objective in the scope is below the threshold of ${threshold.toStringAsFixed(0)}%.'
                    : 'No objective in domain ${selectedDomain!.code} '
                          'in the scope is below the threshold of ${threshold.toStringAsFixed(0)}%.',
              )
            else
              ...objectiveItems.map(
                (item) => Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.objectiveId} – ${item.objectiveName}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Domain: ${item.domain.code} • '
                          'Score: ${item.scorePercent.toStringAsFixed(1)}% '
                          '(level ${item.level})',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Recommended actions:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        ...item.recommendations.map(
                          (r) => Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• '),
                                Expanded(child: Text(r)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // SECTION 2: actions based on gaps
            Text(
              'Actions based on detected gaps',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (gapActionItems.isEmpty)
              const Text('No gaps detected for this audit.')
            else
              ...gapActionItems.map(
                (item) => Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_outlined,
                              color: _gapSeverityColor(item.gap.severity),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.gap.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Severity: ${_gapSeverityLabel(item.gap.severity)} • '
                          'Status: ${_gapStatusLabel(item.gap.status)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Recommended actions:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        ...item.recommendedActions.map(
                          (r) => Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• '),
                                Expanded(child: Text(r)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<double?> _showThresholdDialog(
    BuildContext context,
    double current,
  ) async {
    double temp = current;

    return showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Action plan threshold (%)'),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    value: temp,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: temp.toStringAsFixed(0),
                    onChanged: (value) {
                      setStateDialog(() {
                        temp = value;
                      });
                    },
                  ),
                  Text(
                    'Current: ${temp.toStringAsFixed(0)}%',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(temp),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportToPdf(
    BuildContext context,
    List<_ActionPlanItem> objectiveItems,
    List<_GapActionItem> gapItems,
    double threshold,
    CobitDomain? domainFilter,
    String? scope,
  ) async {
    try {
      final doc = pw.Document();

      final dateStr = DateTime.now().toIso8601String().split('T').first;
      final domainLabel = domainFilter == null
          ? 'All domains'
          : domainFilter.label;

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context pdfContext) {
            return [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'COBIT action plan',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Date: $dateStr',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    'Threshold: ${threshold.toStringAsFixed(0)}% • Domain: $domainLabel',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  if (scope != null && scope.trim().isNotEmpty)
                    pw.Text(
                      'Scope: $scope',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  pw.SizedBox(height: 16),
                  pw.Divider(),
                  pw.SizedBox(height: 8),
                ],
              ),

              // Section 1: objectives
              pw.Text(
                'Actions based on COBIT objectives (below the threshold)',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              if (objectiveItems.isEmpty)
                pw.Text(
                  'No objective in the scope is below the defined threshold.',
                  style: const pw.TextStyle(fontSize: 10),
                )
              else
                ...objectiveItems.map(
                  (item) => pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 8),
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        width: 0.5,
                        color: PdfColors.grey600,
                      ),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '${item.objectiveId} – ${item.objectiveName}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Domain: ${item.domain.code}   •   '
                          'Score: ${item.scorePercent.toStringAsFixed(1)}%   •   '
                          'Level: ${item.level}',
                          style: pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Recommended actions:',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: item.recommendations
                              .map(
                                (r) => pw.Padding(
                                  padding: const pw.EdgeInsets.only(
                                    bottom: 2.0,
                                  ),
                                  child: pw.Row(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        '• ',
                                        style: const pw.TextStyle(fontSize: 9),
                                      ),
                                      pw.Expanded(
                                        child: pw.Text(
                                          r,
                                          style: const pw.TextStyle(
                                            fontSize: 9,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),

              pw.SizedBox(height: 16),

              // Section 2: gaps
              pw.Text(
                'Actions based on detected gaps',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              if (gapItems.isEmpty)
                pw.Text(
                  'No gaps detected for this audit.',
                  style: const pw.TextStyle(fontSize: 10),
                )
              else
                ...gapItems.map(
                  (item) => pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 8),
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        width: 0.5,
                        color: PdfColors.grey600,
                      ),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          item.gap.title,
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Severity: ${_gapSeverityLabel(item.gap.severity)}   •   '
                          'Status: ${_gapStatusLabel(item.gap.status)}',
                          style: pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Recommended actions:',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: item.recommendedActions
                              .map(
                                (r) => pw.Padding(
                                  padding: const pw.EdgeInsets.only(
                                    bottom: 2.0,
                                  ),
                                  child: pw.Row(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        '• ',
                                        style: const pw.TextStyle(fontSize: 9),
                                      ),
                                      pw.Expanded(
                                        child: pw.Text(
                                          r,
                                          style: const pw.TextStyle(
                                            fontSize: 9,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
            ];
          },
        ),
      );

      final bytes = await doc.save();
      final dir = await getApplicationDocumentsDirectory();
      final filePath =
          '${dir.path}/cobit_action_plan_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('PDF saved: $filePath')));
      }

      await OpenFilex.open(filePath);
    } catch (e, st) {
      debugPrint('Error while exporting PDF: $e\n$st');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error while exporting PDF: $e')),
        );
      }
    }
  }

  Color _gapSeverityColor(int severity) {
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

  String _gapSeverityLabel(int severity) {
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

  String _gapStatusLabel(int status) {
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

class _ActionPlanItem {
  final String objectiveId;
  final String objectiveName;
  final CobitDomain domain;
  final double scorePercent; // 0–100
  final int level;
  final List<String> recommendations;

  _ActionPlanItem({
    required this.objectiveId,
    required this.objectiveName,
    required this.domain,
    required this.scorePercent,
    required this.level,
    required this.recommendations,
  });
}

class _GapActionItem {
  final Gap gap;
  final List<String> recommendedActions;

  _GapActionItem({required this.gap, required this.recommendedActions});
}
