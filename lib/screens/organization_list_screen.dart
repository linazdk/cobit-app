import 'package:cobit/app_config.dart';
import 'package:cobit/quiz_cobit.dart';
import 'package:cobit/screens/help_screen.dart';
import 'package:cobit/screens/quiz2_screen.dart';
import 'package:cobit/screens/referential_home_screen.dart';
import 'package:flutter/material.dart';
import '../models/audit_persistence_models.dart';
import '../services/database_service.dart';
import 'audit_list_screen.dart';
import 'backup_management_screen.dart';

class OrganizationListScreen extends StatefulWidget {
  const OrganizationListScreen({super.key});

  @override
  State<OrganizationListScreen> createState() => _OrganizationListScreenState();
}

class _OrganizationListScreenState extends State<OrganizationListScreen> {
  final db = DatabaseService.instance;
  List<Organization> _orgs = [];

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
  }

  Future<void> _loadOrganizations() async {
    final list = await db.getOrganizations();
    setState(() => _orgs = list);
  }

  Future<void> _addOrganization() async {
    final name = TextEditingController();
    final sector = TextEditingController();
    final size = TextEditingController();

    final result = await showDialog<Organization>(
      context: context,
      builder: (_) {
        Theme.of(context);

        return AlertDialog(
          title: const Text('New organization'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Name *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: sector,
                  decoration: const InputDecoration(labelText: 'Sector'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: size,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Size (number of employees)',
                  ),
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
                if (name.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name is required')),
                  );
                  return;
                }

                Navigator.pop(
                  context,
                  Organization(
                    name: name.text.trim(),
                    sector: sector.text.trim().isEmpty
                        ? null
                        : sector.text.trim(),
                    size: size.text.trim().isEmpty
                        ? null
                        : int.tryParse(size.text.trim()),
                  ),
                );
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      await db.insertOrganization(result);
      await _loadOrganizations();
    }
  }

  Future<void> _deleteOrganization(Organization org) async {
    if (org.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete?'),
        content: Text(
          'Delete organization "${org.name}"?\n'
          'This will also delete all associated audits.',
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
      await db.deleteOrganization(org.id!);
      await _loadOrganizations();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Organizations',
          style: const TextStyle(fontSize: 20),
        ),
        actions: [
          IconButton(
            tooltip: 'Backups',
            icon: const Icon(Icons.shield_outlined),
            onPressed: () {
              if (AppConfig.isDemo && AppConfig.demoDisableExport) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Export reserved for the full version.'),
                  ),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BackupManagementScreen(),
                ),
              );
            },
          ),
          PopupMenuButton<int>(
            tooltip: "Options",
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              switch (value) {
                case 1:
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const HelpScreen()));
                  break;

                case 2:
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ReferentialHomeScreen(),
                    ),
                  );
                  break;

                case 3:
                  final quizChoice = await showDialog<int>(
                    context: context,
                    builder: (ctx) {
                      return SimpleDialog(
                        title: const Text('COBIT Quiz'),
                        children: [
                          SimpleDialogOption(
                            onPressed: () => Navigator.pop(ctx, 1),
                            child: const ListTile(
                              leading: Icon(Icons.quiz_outlined),
                              title: Text('COBIT Quiz 1'),
                              subtitle: Text('Basic / educational questions'),
                            ),
                          ),
                          SimpleDialogOption(
                            onPressed: () => Navigator.pop(ctx, 2),
                            child: const ListTile(
                              leading: Icon(Icons.quiz),
                              title: Text('COBIT Quiz 2'),
                              subtitle: Text(
                                'Advanced questions / case studies',
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  if (quizChoice == 1) {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (_) => QuizCobit()));
                  } else if (quizChoice == 2) {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (_) => QuizCobit2()));
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.help_outline, size: 20),
                    SizedBox(width: 8),
                    Text("Help / User manual"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.menu_book_outlined, size: 20),
                    SizedBox(width: 8),
                    Text("COBIT Referential"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 3,
                child: Row(
                  children: [
                    Icon(Icons.quiz_outlined, size: 20),
                    SizedBox(width: 8),
                    Text("Quiz"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _orgs.isEmpty
          ? const Center(child: Text('No organization recorded.'))
          : ListView.builder(
              itemCount: _orgs.length,
              itemBuilder: (_, i) {
                final org = _orgs[i];
                final subtitle = [
                  if (org.sector?.isNotEmpty ?? false) org.sector!,
                  if (org.size != null) 'Size: ${org.size}',
                ].join(' • ');

                return Card(
                  child: ListTile(
                    title: Text(org.name, style: theme.textTheme.titleMedium),
                    subtitle: subtitle.isEmpty
                        ? null
                        : Text(subtitle, style: theme.textTheme.bodySmall),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteOrganization(org),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AuditListScreen(organization: org),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (AppConfig.isDemo &&
              _orgs.length >= AppConfig.maxOrganizationsDemo) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Demo version: limited number of organizations. Contact us for the full version.',
                ),
              ),
            );
            return;
          }

          await _addOrganization();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
