import 'package:flutter/material.dart';
import '../models/referential_models.dart';
import '../services/database_service.dart';

class QuestionListAdminScreen extends StatefulWidget {
  final CobitProcessRef process;

  const QuestionListAdminScreen({super.key, required this.process});

  @override
  State<QuestionListAdminScreen> createState() =>
      _QuestionListAdminScreenState();
}

class _QuestionListAdminScreenState extends State<QuestionListAdminScreen> {
  final db = DatabaseService.instance;
  bool _loading = true;
  List<CobitQuestionRef> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    if (widget.process.id == null) {
      setState(() {
        _questions = [];
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    final list = await db.getQuestionsForProcess(widget.process.id!);
    setState(() {
      _questions = list;
      _loading = false;
    });
  }

  Future<void> _showQuestionDialog({CobitQuestionRef? existing}) async {
    final textController = TextEditingController(text: existing?.text ?? '');
    final isEdit = existing != null;

    final result = await showDialog<CobitQuestionRef>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Edit question' : 'New question'),
        content: SingleChildScrollView(
          child: TextField(
            controller: textController,
            decoration: const InputDecoration(labelText: 'Question text'),
            maxLines: 4,
            minLines: 2,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = textController.text.trim();
              if (text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Question text is required.')),
                );
                return;
              }

              final q = CobitQuestionRef(
                id: existing?.id,
                processId: widget.process.id!,
                text: text,
              );
              Navigator.pop(context, q);
            },
            child: Text(isEdit ? 'Save' : 'Create'),
          ),
        ],
      ),
    );

    if (result == null) return;

    if (isEdit) {
      await db.updateQuestion(result);
    } else {
      await db.insertQuestion(result);
    }
    await _loadQuestions();
  }

  Future<void> _confirmDeleteQuestion(CobitQuestionRef question) async {
    if (question.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete this question?'),
        content: Text(
          'You are about to delete the following question:\n\n'
          '"${question.text}"\n\n'
          'This action cannot be undone.\n\n'
          'Do you confirm deletion?',
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
      await db.deleteQuestion(question.id!);
      await _loadQuestions();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Question deleted.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.process;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Questions – ${p.code}', style: const TextStyle(fontSize: 20)),
            Text(p.name, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
          ? const Center(
              child: Text('No questions for this objective / process.'),
            )
          : RefreshIndicator(
              onRefresh: _loadQuestions,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final q = _questions[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListTile(
                      title: Text(q.text),
                      onTap: () => _showQuestionDialog(existing: q),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        tooltip: 'Delete question',
                        onPressed: () => _confirmDeleteQuestion(q),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuestionDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Question'),
      ),
    );
  }
}
