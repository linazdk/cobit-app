import 'package:cobit/screens/process_list_admin_screen2.dart';
import 'package:flutter/material.dart';
import '../models/referential_models.dart';
import '../services/database_service.dart';

class ReferentialHomeScreen extends StatefulWidget {
  const ReferentialHomeScreen({super.key});

  @override
  State<ReferentialHomeScreen> createState() => _ReferentialHomeScreenState();
}

class _ReferentialHomeScreenState extends State<ReferentialHomeScreen> {
  final db = DatabaseService.instance;
  bool _loading = true;
  List<CobitDomainRef> _domains = [];

  @override
  void initState() {
    super.initState();
    _loadDomains();
  }

  Future<void> _loadDomains() async {
    setState(() => _loading = true);
    final list = await db.getAllDomains();
    setState(() {
      _domains = list;
      _loading = false;
    });
  }

  Future<void> _showDomainDialog({CobitDomainRef? existing}) async {
    final codeController = TextEditingController(text: existing?.code ?? '');
    final nameController = TextEditingController(text: existing?.name ?? '');

    final isEdit = existing != null;

    final result = await showDialog<CobitDomainRef>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Edit domain' : 'New domain'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Code (ex: EDM, APO)',
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
                  const SnackBar(
                    content: Text('Code and label are mandatory.'),
                  ),
                );
                return;
              }

              final dom = CobitDomainRef(
                id: existing?.id,
                code: code,
                name: name,
              );
              Navigator.pop(context, dom);
            },
            child: Text(isEdit ? 'Record' : 'Create'),
          ),
        ],
      ),
    );

    if (result == null) return;

    if (isEdit) {
      await db.updateDomain(result);
    } else {
      await db.insertDomain(result);
    }
    await _loadDomains();
  }

  Future<void> _confirmDeleteDomain(CobitDomainRef domain) async {
    if (domain.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete domain ?'),
        content: Text(
          'You are about to delete the domain "${domain.code} – ${domain.name}".\n\n'
          'All goals/processes and questions associated with this domain'
          'will also be deleted.\n\n'
          'This action is irreversible.\n'
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
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await db.deleteDomain(domain.id!);
      await _loadDomains();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Domain "${domain.code}" deleted.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'COBIT referential – Domains',
          style: const TextStyle(fontSize: 20),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _domains.isEmpty
          ? const Center(child: Text('No domain defined. Add one.'))
          : RefreshIndicator(
              onRefresh: _loadDomains,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  80,
                ), // ← espace sécurisé pour le FAB
                itemCount: _domains.length,
                itemBuilder: (context, index) {
                  final d = _domains[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListTile(
                      title: Text(
                        d.code,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(d.name),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProcessListAdminScreen2(domain: d),
                          ),
                        );
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'hange domain',
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showDomainDialog(existing: d),
                          ),
                          IconButton(
                            tooltip: 'Delete domain',
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => _confirmDeleteDomain(d),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDomainDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Domain'),
      ),
    );
  }
}
