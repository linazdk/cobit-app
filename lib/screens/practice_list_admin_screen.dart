import 'package:flutter/material.dart';
import '../models/cobit_practice_models.dart';
import '../services/database_service.dart';
import '../models/referential_models.dart';
import 'activity_list_admin_screen.dart';

class PracticeListAdminScreen extends StatefulWidget {
  final CobitProcessRef process;

  const PracticeListAdminScreen({super.key, required this.process});

  @override
  State<PracticeListAdminScreen> createState() =>
      _PracticeListAdminScreenState();
}

class _PracticeListAdminScreenState extends State<PracticeListAdminScreen> {
  final db = DatabaseService.instance;
  bool _loading = true;

  List<CobitManagementPractice> _practices = [];

  @override
  void initState() {
    super.initState();
    _loadPractices();
  }

  Future<void> _loadPractices() async {
    setState(() => _loading = true);
    final list = await db.getPracticesForObjective(widget.process.code);
    setState(() {
      _practices = list;
      _loading = false;
    });
  }

  Future<void> _showPracticeDialog({CobitManagementPractice? existing}) async {
    final idCtrl = TextEditingController(text: existing?.id ?? '');
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');

    final isEdit = existing != null;

    final result = await showDialog<CobitManagementPractice>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Edit practice' : 'New practice'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: idCtrl,
                decoration: const InputDecoration(
                  labelText: 'ID (e.g., APO13.01)',
                ),
              ),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Label'),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (idCtrl.text.isEmpty || nameCtrl.text.isEmpty) return;

              Navigator.pop(
                context,
                CobitManagementPractice(
                  id: idCtrl.text.trim(),
                  objectiveId: widget.process.code,
                  name: nameCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                ),
              );
            },
            child: Text(isEdit ? 'Save' : 'Create'),
          ),
        ],
      ),
    );

    if (result == null) return;

    if (isEdit) {
      await db.updatePractice(result);
    } else {
      await db.insertPractice(result);
    }

    await _loadPractices();
  }

  Future<void> _deletePractice(CobitManagementPractice p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete this practice?'),
        content: const Text('All associated activities will also be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await db.deletePractice(p.id);
    await _loadPractices();
  }

  @override
  Widget build(BuildContext context) {
    final process = widget.process;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${process.code} – Practices',
          style: const TextStyle(fontSize: 20),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _practices.isEmpty
          ? const Center(child: Text('No practice defined.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _practices.length,
              itemBuilder: (_, i) {
                final p = _practices[i];
                return Card(
                  child: ListTile(
                    title: Text('${p.id} – ${p.name}'),
                    subtitle: Text(p.description, softWrap: true),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ActivityListAdminScreen(practice: p),
                        ),
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showPracticeDialog(existing: p),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deletePractice(p),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPracticeDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Practice'),
      ),
    );
  }
}
