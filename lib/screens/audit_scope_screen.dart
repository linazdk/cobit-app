// lib/screens/audit_scope_screen.dart
// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cobit/models/objective_target_models.dart';
import 'package:cobit/services/database_service.dart';

import '../controllers/audit_controller.dart';
import '../models/audit_persistence_models.dart';
import '../models/cobit_models.dart';
import '../utils/scope_utils.dart';

class AuditScopeScreen extends StatefulWidget {
  final Audit audit;

  const AuditScopeScreen({super.key, required this.audit});

  @override
  State<AuditScopeScreen> createState() => _AuditScopeScreenState();
}

class _AuditScopeScreenState extends State<AuditScopeScreen> {
  final db = DatabaseService.instance;

  // Audit "fresh" depuis la DB (pour éviter d’utiliser widget.audit.scope obsolète)
  Audit? _auditFromDb;

  /// Selected objectives (e.g. "APO05", "DSS03")
  late Set<String> _selectedObjectiveIds;

  /// Target level for each objective (0–5), kept in memory
  final Map<String, int> _targetLevels = {};

  // --- Auto-save state ---
  Timer? _saveDebounce;
  bool _saving = false;
  bool _dirty = false;

  int? get _auditId => _auditFromDb?.id ?? widget.audit.id;

  @override
  void initState() {
    super.initState();
    // init selection with widget value then refresh from DB
    _selectedObjectiveIds = parseScopeToObjectiveIds(widget.audit.scope);
    _initFromDb();
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    super.dispose();
  }

  Future<void> _initFromDb() async {
    final id = widget.audit.id;
    if (id == null) {
      // Audit non persisté, on reste sur widget.audit
      await _loadTargets();
      return;
    }

    final fresh = await db.getAuditById(id);
    if (!mounted) return;

    setState(() {
      _auditFromDb = fresh ?? widget.audit;
      _selectedObjectiveIds = parseScopeToObjectiveIds(_auditFromDb!.scope);
    });

    await _loadTargets();
  }

  Future<void> _loadTargets() async {
    final auditId = _auditId;
    if (auditId == null) return;

    final targets = await db.getObjectiveTargetsForAudit(auditId);
    if (!mounted) return;

    setState(() {
      _targetLevels.clear();
      for (final t in targets) {
        _targetLevels[t.objectiveId] = t.targetLevel;
      }
    });
  }

  void _scheduleAutoSave() {
    final auditId = _auditId;
    if (auditId == null) return;

    setState(() {
      _dirty = true;
    });

    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 600), () async {
      try {
        await _saveScopeInternal();
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _saving = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Auto-save failed: $e')));
      }
    });
  }

  Future<void> _saveScopeInternal() async {
    final auditId = _auditId;
    if (auditId == null) return;

    if (mounted) {
      setState(() {
        _saving = true;
      });
    }

    final newScope = objectiveIdsToScopeString(_selectedObjectiveIds);

    final updatedAudit = Audit(
      id: auditId,
      organizationId: widget.audit.organizationId,
      date: widget.audit.date,
      auditorName: widget.audit.auditorName,
      scope: newScope,
      status: widget.audit.status,
    );

    // 1) Update audit
    await db.updateAudit(updatedAudit);

    // 2) Delete existing targets for this audit
    await db.deleteObjectiveTargetsForAudit(auditId);

    // 3) Recreate targets only for objectives in scope
    for (final objectiveId in _selectedObjectiveIds) {
      final target = _targetLevels[objectiveId] ?? 3; // default 3
      await db.upsertObjectiveTarget(
        ObjectiveTarget(
          auditId: auditId,
          objectiveId: objectiveId,
          targetLevel: target,
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      _auditFromDb = updatedAudit; // 👈 garde le scope à jour pour le pop
      _saving = false;
      _dirty = false;
    });
  }

  void _toggle(String objectiveId) {
    setState(() {
      if (_selectedObjectiveIds.contains(objectiveId)) {
        _selectedObjectiveIds.remove(objectiveId);
      } else {
        _selectedObjectiveIds.add(objectiveId);
      }
    });
    _scheduleAutoSave();
  }

  void _selectAll(List<CobitObjective> objectives) {
    setState(() {
      _selectedObjectiveIds = objectives.map((o) => o.id).toSet();
    });
    _scheduleAutoSave();
  }

  void _clearAll() {
    setState(() {
      _selectedObjectiveIds.clear();
    });
    _scheduleAutoSave();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuditController>();

    // 👉 All available COBIT objectives
    final allObjectives = List<CobitObjective>.from(controller.objectives);

    // 👉 All existing domains
    final domains = List<CobitDomain>.from(CobitDomain.values);

    // 👉 Logical COBIT order
    const desiredOrder = ['EDM', 'APO', 'BAI', 'DSS', 'MEA'];

    domains.sort((a, b) {
      final ia = desiredOrder.indexOf(a.code);
      final ib = desiredOrder.indexOf(b.code);

      if (ia == -1 && ib == -1) return a.code.compareTo(b.code);
      if (ia == -1) return 1;
      if (ib == -1) return -1;
      return ia.compareTo(ib);
    });

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        // Quand l’utilisateur revient, on renvoie l’audit mis à jour
        // (si déjà poppé, on ne repop pas)
        if (didPop) return;
        Navigator.of(context).pop(_auditFromDb ?? widget.audit);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('COBIT scope', style: TextStyle(fontSize: 20)),
          actions: [
            if (_saving)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else if (_dirty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Center(child: Text('Pending…')),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Center(child: Text('Saved')),
              ),
          ],
        ),
        body: Column(
          children: [
            // Banner + select all / clear all buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => _selectAll(allObjectives),
                    child: const Text('Select all'),
                  ),
                  TextButton(
                    onPressed: _clearAll,
                    child: const Text('Clear selection'),
                  ),
                ],
              ),
            ),

            // 👉 Scrollable content: domains + grids
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final domain in domains) ...[
                      Builder(
                        builder: (context) {
                          final goals = allObjectives
                              .where((o) => o.domain == domain)
                              .toList();

                          if (goals.isEmpty) return const SizedBox.shrink();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),

                              // 🔵 Domain title
                              Text(
                                '${domain.code} — ${domain.label}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // 🟦 Grid of objectives for this domain
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 1.2,
                                      mainAxisSpacing: 10,
                                      crossAxisSpacing: 10,
                                    ),
                                itemCount: goals.length,
                                itemBuilder: (context, index) {
                                  final obj = goals[index];
                                  final isSelected = _selectedObjectiveIds
                                      .contains(obj.id);

                                  final target = _targetLevels[obj.id] ?? 3;

                                  return InkWell(
                                    onTap: () => _toggle(obj.id),
                                    child: Card(
                                      elevation: 2,
                                      color: isSelected
                                          ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.12)
                                          : Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(
                                          color: isSelected
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Code + checkbox row
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    obj.id,
                                                    style: TextStyle(
                                                      fontWeight: isSelected
                                                          ? FontWeight.bold
                                                          : FontWeight.w600,
                                                      fontSize: 15,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Checkbox(
                                                  value: isSelected,
                                                  onChanged: (_) =>
                                                      _toggle(obj.id),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),

                                            // Process name
                                            Expanded(
                                              child: Text(
                                                obj.name,
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),

                                            const SizedBox(height: 6),

                                            // Target row
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  'Target:',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                DropdownButton<int>(
                                                  value: target,
                                                  underline: const SizedBox(),
                                                  items: List.generate(
                                                    6,
                                                    (i) => DropdownMenuItem(
                                                      value: i,
                                                      child: Text(
                                                        i.toString(),
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  onChanged: (val) {
                                                    if (val == null) return;
                                                    setState(() {
                                                      _targetLevels[obj.id] =
                                                          val;
                                                    });
                                                    _scheduleAutoSave();
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
