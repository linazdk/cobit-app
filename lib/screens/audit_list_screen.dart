// ignore_for_file: deprecated_member_use

import 'package:cobit/app_config.dart';
import 'package:cobit/screens/audit_detail_screen.dart';
import 'package:cobit/workflow/audit_workflow.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/audit_controller.dart';
import '../models/audit_persistence_models.dart';
import '../services/database_service.dart';

class AuditListScreen extends StatefulWidget {
  final Organization organization;

  const AuditListScreen({super.key, required this.organization});

  @override
  State<AuditListScreen> createState() => _AuditListScreenState();
}

class _AuditListScreenState extends State<AuditListScreen> {
  final _db = DatabaseService.instance;
  List<Audit> _audits = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAudits();
  }

  Future<void> _loadAudits() async {
    if (widget.organization.id == null) {
      setState(() {
        _audits = [];
        _loading = false;
      });
      return;
    }

    final list = await _db.getAuditsForOrganization(widget.organization.id!);
    setState(() {
      _audits = list;
      _loading = false;
    });
  }

  Future<void> _addAudit() async {
    final ctrl = TextEditingController(text: 'Audit ${DateTime.now().year}');

    final label = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New audit'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Audit label'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (label == null || label.isEmpty) return;

    final newAudit = Audit(
      id: null,
      organizationId: widget.organization.id!,
      date: DateTime.now(),
      auditorName: null,
      scope: label,
      status: auditStatusToString(AuditStatus.draft),
    );

    await _db.insertAudit(newAudit);
    await _loadAudits();
  }

  Future<void> _deleteAudit(Audit audit) async {
    if (audit.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete this audit?'),
        content: const Text(
          'This action will delete all answers, gaps, and data '
          'related to this audit.\n\nDo you confirm?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _db.deleteAudit(audit.id!);
      await _loadAudits();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Audits — ${widget.organization.name}',
          style: const TextStyle(fontSize: 20),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _audits.isEmpty
          ? const Center(child: Text('No audit available.'))
          : ListView.builder(
              itemCount: _audits.length,
              itemBuilder: (_, i) {
                final audit = _audits[i];

                return Card(
                  child: ListTile(
                    title: Text(
                      'Audit on ${audit.date.toIso8601String().split("T").first}',
                      style: theme.textTheme.titleMedium,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Chip(
                        label: Text(audit.status),
                        backgroundColor: audit.statusEnum.color.withOpacity(
                          0.15,
                        ),
                        labelStyle: TextStyle(
                          color: audit.statusEnum.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteAudit(audit),
                    ),
                    onTap: () async {
                      final ctrl = context.read<AuditController>();
                      await ctrl.loadAudit(audit.id!);

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AuditDetailScreen(audit: audit),
                        ),
                      );

                      await _loadAudits();
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (AppConfig.isDemo &&
              _audits.length >= AppConfig.maxAuditsPerOrgDemo) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Demo version: limited number of audits per organization. Contact us for the full version.',
                ),
              ),
            );
            return;
          }

          await _addAudit();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
