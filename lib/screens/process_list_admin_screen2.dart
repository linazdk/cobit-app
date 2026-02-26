// lib/screens/process_list_admin_screen2.dart

import 'package:cobit/screens/practice_list_admin_screen.dart';
import 'package:flutter/material.dart';

import '../models/referential_models.dart';
import '../services/database_service.dart';
import 'question_list_admin_screen.dart';

class ProcessListAdminScreen2 extends StatefulWidget {
  final CobitDomainRef domain;

  const ProcessListAdminScreen2({super.key, required this.domain});

  @override
  State<ProcessListAdminScreen2> createState() =>
      _ProcessListAdminScreen2State();
}

class _ProcessListAdminScreen2State extends State<ProcessListAdminScreen2> {
  final db = DatabaseService.instance;
  bool _loading = true;
  List<CobitProcessRef> _processes = [];

  @override
  void initState() {
    super.initState();
    _loadProcesses();
  }

  Future<void> _loadProcesses() async {
    if (widget.domain.id == null) {
      setState(() {
        _processes = [];
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    final list = await db.getProcessesForDomain(widget.domain.id!);
    setState(() {
      _processes = list;
      _loading = false;
    });
  }

  Future<void> _showProcessDialog({CobitProcessRef? existing}) async {
    final codeController = TextEditingController(text: existing?.code ?? '');
    final nameController = TextEditingController(text: existing?.name ?? '');
    final isEdit = existing != null;

    final result = await showDialog<CobitProcessRef>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          isEdit ? 'Edit objective / process' : 'New objective / process',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Code (e.g., APO05, DSS03)',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Label'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final code = codeController.text.trim();
              final name = nameController.text.trim();
              if (code.isEmpty || name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Code and label are required.')),
                );
                return;
              }

              final p = CobitProcessRef(
                id: existing?.id,
                domainId: widget.domain.id!,
                code: code,
                name: name,
              );
              Navigator.pop(context, p);
            },
            child: Text(isEdit ? 'Save' : 'Create'),
          ),
        ],
      ),
    );

    if (result == null) return;

    if (isEdit) {
      await db.updateProcess(result);
    } else {
      await db.insertProcess(result);
    }
    await _loadProcesses();
  }

  Future<void> _confirmDeleteProcess(CobitProcessRef process) async {
    if (process.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete this objective / process?'),
        content: Text(
          'You are about to delete "${process.code} – ${process.name}".\n\n'
          'All questions associated with this process will also be deleted.\n\n'
          'Do you confirm the deletion?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
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
      await db.deleteProcess(process.id!);
      await _loadProcesses();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Objective / process "${process.code}" deleted.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final domain = widget.domain;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Objectives – ${domain.code}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(domain.name, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _processes.isEmpty
          ? const Center(child: Text('No objective / process for this domain.'))
          : RefreshIndicator(
              onRefresh: _loadProcesses,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: _processes.length,
                itemBuilder: (context, index) {
                  final p = _processes[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListTile(
                      title: Text(
                        p.code,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(p.name, softWrap: true),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => QuestionListAdminScreen(process: p),
                          ),
                        );
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'View practices & activities',
                            icon: const Icon(Icons.account_tree_outlined),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    PracticeListAdminScreen(process: p),
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Edit objective',
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showProcessDialog(existing: p),
                          ),
                          IconButton(
                            tooltip: 'Delete objective',
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => _confirmDeleteProcess(p),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProcessDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Objective / process'),
      ),
    );
  }
}
