import 'package:flutter/material.dart';
import '../services/backup_service.dart';

class BackupManagementScreen extends StatefulWidget {
  const BackupManagementScreen({super.key});

  @override
  State<BackupManagementScreen> createState() => _BackupManagementScreenState();
}

class _BackupManagementScreenState extends State<BackupManagementScreen> {
  bool _isWorking = false;
  String? _lastMessage;
  Future<void> _runSafely(
    Future<void> Function() action,
    String successMsg,
  ) async {
    if (_isWorking) return;
    setState(() {
      _isWorking = true;
      _lastMessage = null;
    });

    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMsg)));
      setState(() {
        _lastMessage = successMsg;
      });
    } catch (e) {
      if (!mounted) return;
      final msg = 'Error: $e';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      setState(() {
        _lastMessage = msg;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isWorking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Backup management')),
      body: AbsorbPointer(
        absorbing: _isWorking,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_isWorking) const LinearProgressIndicator(),
            if (_isWorking) const SizedBox(height: 16),

            Text(
              'Data protection',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'From this screen, you can export the database, create a local backup and restore an existing backup.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // --- EXTERNAL EXPORT ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cloud_upload, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          'External export',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Generates a database file that you can share '
                      '(email, Drive, etc.) for archiving or external analysis.',
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () => _runSafely(
                          () => BackupService.instance.exportDatabase(),
                          'Database exported (sharing started).',
                        ),
                        icon: const Icon(Icons.share),
                        label: const Text('Export and share'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- LOCAL BACKUP ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.save, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          'Local backup',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Creates a local copy of the database in the '
                      'application storage (backup folder).',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _runSafely(
                            () =>
                                BackupService.instance.backupDatabaseLocally(),
                            'Local backup created.',
                          ),
                          icon: const Icon(Icons.save_alt),
                          label: const Text('Create backup'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- RESTORE ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.restore, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          'Local restore',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Restores the latest available local backup. '
                      'This operation replaces the current database with the backup copy.',
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Confirm restore'),
                              content: const Text(
                                'The restore will overwrite the current database with the local backup.\n\n'
                                'Do you want to continue?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Restore'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await _runSafely(
                              () => BackupService.instance.restoreLocalBackup(),
                              'Local backup restored. Please restart the application.',
                            );
                          }
                        },
                        icon: const Icon(Icons.settings_backup_restore),
                        label: const Text('Restore backup'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- PATH INFO ---
            Card(
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Local backups are stored in the application’s private folder '
                        '(generally under Android/data/<package>/files/backup on Android).\n\n'
                        'This folder is not directly visible with all file explorers. '
                        'For advanced access, you can use a file explorer such as "X-plore".',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            if (_lastMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                'Last operation:',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(_lastMessage!, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
