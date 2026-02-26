import 'package:flutter/material.dart';
import '../models/cobit_practice_models.dart';
import '../services/database_service.dart';

class ActivityListAdminScreen extends StatefulWidget {
  final CobitManagementPractice practice;

  const ActivityListAdminScreen({super.key, required this.practice});

  @override
  State<ActivityListAdminScreen> createState() =>
      _ActivityListAdminScreenState();
}

class _ActivityListAdminScreenState extends State<ActivityListAdminScreen> {
  final db = DatabaseService.instance;
  bool _loading = true;

  List<CobitActivity> _activities = [];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final list = await db.getActivitiesForPractice(widget.practice.id);
    setState(() {
      _activities = list;
      _loading = false;
    });
  }

  Future<void> _showActivityDialog({CobitActivity? existing}) async {
    final idCtrl = TextEditingController(text: existing?.id ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');

    final result = await showDialog<CobitActivity>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          existing == null ? "Nouvelle activité" : "Modifier l’activité",
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idCtrl,
              decoration: const InputDecoration(labelText: "ID"),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: "Description"),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(
                context,
                CobitActivity(
                  id: idCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  practiceId: widget.practice.id,
                ),
              );
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );

    if (result == null) return;

    if (existing == null) {
      await db.insertActivity(result);
    } else {
      await db.updateActivity(result);
    }
    await _loadActivities();
  }

  Future<void> _deleteActivity(CobitActivity a) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Supprimer cette activité ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          FilledButton(
            child: const Text("Supprimer"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await db.deleteActivity(a.id);
    await _loadActivities();
  }

  @override
  Widget build(BuildContext context) {
    final practice = widget.practice;

    return Scaffold(
      appBar: AppBar(title: Text("${practice.id} – Activités")),
      body: _loading
          ? const CircularProgressIndicator()
          : _activities.isEmpty
          ? const Center(child: Text("Aucune activité."))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _activities.length,
              itemBuilder: (_, i) {
                final a = _activities[i];
                return Card(
                  child: ListTile(
                    title: Text(a.id),
                    subtitle: Text(a.description, softWrap: true),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showActivityDialog(existing: a),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteActivity(a),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showActivityDialog(),
        icon: const Icon(Icons.add),
        label: const Text("Activité"),
      ),
    );
  }
}
