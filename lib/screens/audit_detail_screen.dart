// lib/screens/audit_detail_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/audit_controller.dart';
import '../models/audit_persistence_models.dart';
import '../services/database_service.dart';
import '../services/audit_synthesis_service.dart';
import '../workflow/audit_workflow.dart';

import 'audit_scope_screen.dart';
import 'cobit_domain_list_screen.dart';
import 'gap_list_screen.dart';
import 'action_plan_screen.dart';

class AuditDetailScreen extends StatefulWidget {
  final Audit audit;

  const AuditDetailScreen({super.key, required this.audit});

  @override
  State<AuditDetailScreen> createState() => _AuditDetailScreenState();
}

class _AuditDetailScreenState extends State<AuditDetailScreen> {
  late Audit _audit;
  final db = DatabaseService.instance;

  @override
  void initState() {
    super.initState();
    _audit = widget.audit;
  }

  bool _canModifyScope(AuditStatus status) => status == AuditStatus.draft;

  bool _isReadOnly(AuditStatus status) =>
      status == AuditStatus.inReview || status == AuditStatus.validated;

  String _dateLabel(DateTime d) => d.toIso8601String().split('T').first;

  Future<void> _changeStatus(AuditStatus newStatus) async {
    final currentStatus = _audit.statusEnum;
    final nextStatuses = allowedNextStatuses(currentStatus);

    if (!nextStatuses.contains(newStatus)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status transition not allowed.')),
      );
      return;
    }

    final isBackToDraft =
        currentStatus == AuditStatus.inProgress &&
        newStatus == AuditStatus.draft;

    final isBackToInProgressFromReview =
        currentStatus == AuditStatus.inReview &&
        newStatus == AuditStatus.inProgress;

    final isExceptionalUnlock = isBackToDraft || isBackToInProgressFromReview;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isExceptionalUnlock ? 'Go back?' : 'Change status'),
        content: Text(
          isBackToDraft
              ? 'You are about to move the audit from "In progress" back to "Draft".\n\n'
                    'This is intended to fix structural elements (scope, targets…).\n'
                    'Existing data is kept.\n\nConfirm?'
              : isBackToInProgressFromReview
              ? 'You are about to move the audit from "In review" back to "In progress".\n\n'
                    'This re-opens data entry.\n\nConfirm?'
              : 'Move the audit from "${auditStatusLabel(currentStatus)}" '
                    'to "${auditStatusLabel(newStatus)}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final updated = _audit.copyWithStatus(newStatus);
    await db.updateAudit(updated);

    if (newStatus == AuditStatus.validated && updated.id != null) {
      final controller = context.read<AuditController>();
      final synthesis = AuditSynthesisService(db, controller);
      await synthesis.generateGapsForAudit(updated.id!);
    }

    setState(() {
      _audit = updated;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status updated: ${auditStatusLabel(newStatus)}')),
    );
  }

  void _showStatusActionSheet(List<AuditStatus> nextStatuses) {
    final statusEnum = _audit.statusEnum;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Change audit status',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                ...nextStatuses.map((st) {
                  String label;
                  String subtitle;

                  switch (st) {
                    case AuditStatus.inProgress:
                      label = (statusEnum == AuditStatus.inReview)
                          ? 'Move back to In progress'
                          : 'Move to In progress';
                      subtitle = 'Data entry is open (scope is frozen).';
                      break;
                    case AuditStatus.inReview:
                      label = 'Move to In review';
                      subtitle = 'Audit becomes read-only for validation.';
                      break;
                    case AuditStatus.validated:
                      label = 'Validate the audit';
                      subtitle =
                          'Audit is locked, gaps and action plan are frozen.';
                      break;
                    case AuditStatus.draft:
                      label = 'Move back to Draft';
                      subtitle = 'Allows scope and structural modifications.';
                      break;
                  }

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    leading: Icon(
                      Icons.arrow_forward,
                      color: st.color,
                      size: 26,
                    ),
                    title: Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      subtitle,
                      style: const TextStyle(fontSize: 15),
                    ),
                    onTap: () => Navigator.of(ctx).pop(st),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    ).then((selected) async {
      if (selected is AuditStatus) {
        await _changeStatus(selected);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final status = _audit.statusEnum;
    final canEditScope = _canModifyScope(status);
    final readOnly = _isReadOnly(status);

    final scopeText = (_audit.scope == null || _audit.scope!.trim().isEmpty)
        ? 'All COBIT objectives are included.'
        : _audit.scope!;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _audit.id != null ? 'Audit #${_audit.id}' : 'New Audit',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
            Text(
              _dateLabel(_audit.date),
              style: TextStyle(fontSize: 16, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          if (allowedNextStatuses(status).isNotEmpty)
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _showStatusActionSheet(allowedNextStatuses(status)),
              child: Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: status.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: status.color.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      auditStatusLabel(status),
                      style: TextStyle(
                        color: status.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, color: status.color, size: 20),
                  ],
                ),
              ),
            )
          else
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: status.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: status.color.withOpacity(0.3)),
              ),
              child: Text(
                auditStatusLabel(status),
                style: TextStyle(
                  color: status.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Scope Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: canEditScope
                  ? () async {
                      final updated = await Navigator.of(context).push<Audit>(
                        MaterialPageRoute(
                          builder: (_) => AuditScopeScreen(audit: _audit),
                        ),
                      );
                      if (updated != null) {
                        setState(() => _audit = updated);
                      }
                    }
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Scope can only be modified in Draft status.',
                          ),
                        ),
                      );
                    },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.grid_view_rounded,
                          size: 24,
                          color: canEditScope
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Objectives Scope',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.chevron_right,
                          color: scheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Actions Section
          Text(
            'Actions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
              fontSize: 19,
            ),
          ),

          const SizedBox(height: 12),

          _ActionTile(
            icon: Icons.view_module_outlined,
            title: readOnly ? 'View COBIT Domains' : 'COBIT Domains',
            subtitle: 'Access evaluation framework',
            color: scheme.primary,
            onTap: () async {
              if (_audit.id == null) return;
              final fresh = await db.getAuditById(_audit.id!);
              if (fresh != null) {
                setState(() => _audit = fresh);
              }
              if (!mounted) return;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CobitDomainListScreen(audit: fresh ?? _audit),
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          _ActionTile(
            icon: Icons.warning_amber_outlined,
            title: 'Gaps',
            subtitle: 'View identified gaps',
            color: Colors.orange,
            onTap: () async {
              if (_audit.id != null) {
                final controller = context.read<AuditController>();
                final synthesis = AuditSynthesisService(db, controller);
                await synthesis.generateGapsForAudit(_audit.id!);
              }
              if (!mounted) return;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GapListScreen(auditId: _audit.id!),
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          _ActionTile(
            icon: Icons.list_alt_outlined,
            title: 'Action Plan',
            subtitle: 'Manage remediation actions',
            color: Colors.green,
            onTap: () {
              if (_audit.id == null) return;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ActionPlanScreen(auditId: _audit.id!),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Tip
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 22, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Finalize the scope in Draft. Once in progress, the scope is frozen.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final Widget? trailing;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 15,
                        color: scheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (trailing != null) ...[
                      const SizedBox(height: 6),
                      trailing!,
                    ],
                  ],
                ),
              ),
              if (trailing == null)
                Icon(
                  Icons.chevron_right,
                  color: scheme.onSurfaceVariant.withOpacity(0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
