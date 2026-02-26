import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class GettingStarted extends StatelessWidget {
  const GettingStarted({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'COBIT Audit Course',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const CobitCoursePage(),
    );
  }
}

class CobitCoursePage extends StatelessWidget {
  const CobitCoursePage({Key? key}) : super(key: key);

  Future<void> _exportToPdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'COBIT Audit Application – Learner Edition',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Header(
              level: 1,
              child: pw.Text(
                'Course Overview',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Paragraph(
              text:
                  'This learner-friendly version focuses on practical steps to use the COBIT Audit App. The goal is to help you perform audits, understand scores, and produce reports using the app.',
            ),
            pw.SizedBox(height: 20),
            _buildModule(
              'Module 1: What is COBIT?',
              'COBIT is a framework for governing and managing enterprise IT. You should know:',
              [
                'The 5 domains: EDM, APO, BAI, DSS, MEA',
                'What capability levels are (0–5)',
                'That each objective contains audit questions',
              ],
            ),
            _buildModule('Module 2: Getting Started', 'In the app:', [
              'Create an organization',
              'Select the organization',
              'Tap ' + ' to create a new audit',
              'View domains and objectives',
            ]),
            _buildModule(
              'Module 3: Answering Audit Questions',
              'Each objective contains questions. To complete them:',
              [
                'Select the domain',
                'Select the objective',
                'Check checklist items',
                'The capability level will update automatically',
                'Add comments when necessary',
              ],
            ),
            _buildModule(
              'Module 4: Understanding Scores',
              'You should remember:',
              [
                'Each question has a capability score 0–5',
                'Objective score = average of its questions',
                'Domain score = average of its objectives',
                'Global score = average of all objectives',
                'Capability level is based on score percentage',
              ],
            ),
            _buildModule(
              'Module 5: Using the Action Plan',
              'The app can generate a plan of action:',
              [
                'Open Action Plan screen',
                'Adjust the threshold slider (e.g., items below 80%)',
                'View recommended actions per objective',
                'Export to PDF',
              ],
            ),
            _buildModule(
              'Module 6: Workflow Stages',
              'Audit workflow statuses:',
              ['Draft', 'In Progress', 'Review', 'Completed'],
            ),
            pw.Paragraph(
              text: 'You can move between stages from the audit header.',
            ),
            pw.SizedBox(height: 10),
            _buildModule('Module 7: Backup & Restore', 'You can:', [
              'Export the audit database (local backup)',
              'Restore a previous backup',
            ]),
            pw.Paragraph(text: 'Use the menu on the Organizations screen.'),
            pw.SizedBox(height: 20),
            pw.Header(
              level: 1,
              child: pw.Text(
                'Practical Exercises',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Paragraph(text: 'Try completing the following:'),
            pw.SizedBox(height: 10),
            ...List.generate(5, (index) {
              final exercises = [
                'Create a new organization called "Test Org"',
                'Create an audit and fill in one domain',
                'Change audit workflow to "Review"',
                'Export an action plan to PDF',
                'Backup the database',
              ];
              return pw.Padding(
                padding: const pw.EdgeInsets.only(left: 20, bottom: 5),
                child: pw.Text('${index + 1}. ${exercises[index]}'),
              );
            }),
            pw.SizedBox(height: 20),
            pw.Header(
              level: 1,
              child: pw.Text(
                'Quick Answers',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            ...List.generate(5, (index) {
              final answers = [
                'Menu → Add Organization → Enter name',
                'Open organization → Add audit → Navigate to domain',
                'Tap workflow button in audit header',
                'Action Plan → Export as PDF',
                'Organizations → Menu → Backup database',
              ];
              return pw.Padding(
                padding: const pw.EdgeInsets.only(left: 20, bottom: 5),
                child: pw.Text('${index + 1}. ${answers[index]}'),
              );
            }),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static pw.Widget _buildModule(
    String title,
    String intro,
    List<String> points,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(
          level: 2,
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
            ),
          ),
        ),
        pw.Paragraph(text: intro),
        pw.SizedBox(height: 5),
        ...points.map(
          (point) => pw.Padding(
            padding: const pw.EdgeInsets.only(left: 20, bottom: 3),
            child: pw.Text('• $point'),
          ),
        ),
        pw.SizedBox(height: 15),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('COBIT Audit Course'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export to PDF',
            onPressed: () => _exportToPdf(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'COBIT Audit Application – Learner Edition',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              'Course Overview',
              'This learner-friendly version focuses on practical steps to use the COBIT Audit App. The goal is to help you perform audits, understand scores, and produce reports using the app.',
            ),
            const SizedBox(height: 24),
            _buildModuleCard(
              context,
              'Module 1: What is COBIT?',
              'COBIT is a framework for governing and managing enterprise IT.',
              [
                'The 5 domains: EDM, APO, BAI, DSS, MEA',
                'What capability levels are (0–5)',
                'That each objective contains audit questions',
              ],
              Colors.blue,
            ),
            _buildModuleCard(
              context,
              'Module 2: Getting Started',
              'In the app:',
              [
                'Create an organization',
                'Select the organization',
                'Tap ' + ' to create a new audit',
                'View domains and objectives',
              ],
              Colors.green,
            ),
            _buildModuleCard(
              context,
              'Module 3: Answering Audit Questions',
              'Each objective contains questions. To complete them:',
              [
                'Select the domain',
                'Select the objective',
                'Check checklist items',
                'The capability level will update automatically',
                'Add comments when necessary',
              ],
              Colors.orange,
            ),
            _buildModuleCard(
              context,
              'Module 4: Understanding Scores',
              'You should remember:',
              [
                'Each question has a capability score 0–5',
                'Objective score = average of its questions',
                'Domain score = average of its objectives',
                'Global score = average of all objectives',
                'Capability level is based on score percentage',
              ],
              Colors.purple,
            ),
            _buildModuleCard(
              context,
              'Module 5: Using the Action Plan',
              'The app can generate a plan of action:',
              [
                'Open Action Plan screen',
                'Adjust the threshold slider (e.g., items below 80%)',
                'View recommended actions per objective',
                'Export to PDF',
              ],
              Colors.teal,
            ),
            _buildModuleCard(
              context,
              'Module 6: Workflow Stages',
              'Audit workflow statuses:',
              ['Draft', 'In Progress', 'Review', 'Completed'],
              Colors.indigo,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 16),
              child: Text(
                'You can move between stages from the audit header.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            _buildModuleCard(
              context,
              'Module 7: Backup & Restore',
              'You can:',
              [
                'Export the audit database (local backup)',
                'Restore a previous backup',
              ],
              Colors.red,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 24),
              child: Text(
                'Use the menu on the Organizations screen.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            _buildExercisesSection(context),
            const SizedBox(height: 24),
            _buildAnswersSection(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(content, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }

  Widget _buildModuleCard(
    BuildContext context,
    String title,
    String intro,
    List<String> points,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  color: color,
                  margin: const EdgeInsets.only(right: 12),
                ),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(intro, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            ...points.map(
              (point) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        point,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExercisesSection(BuildContext context) {
    final exercises = [
      'Create a new organization called "Test Org"',
      'Create an audit and fill in one domain',
      'Change audit workflow to "Review"',
      'Export an action plan to PDF',
      'Backup the database',
    ];

    return Card(
      color: Colors.amber.shade50,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Practical Exercises',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.amber.shade900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try completing the following:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ...exercises.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text(
                  '${entry.key + 1}. ${entry.value}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswersSection(BuildContext context) {
    final answers = [
      'Menu → Add Organization → Enter name',
      'Open organization → Add audit → Navigate to domain',
      'Tap workflow button in audit header',
      'Action Plan → Export as PDF',
      'Organizations → Menu → Backup database',
    ];

    return Card(
      color: Colors.green.shade50,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Answers',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade900,
              ),
            ),
            const SizedBox(height: 12),
            ...answers.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text(
                  '${entry.key + 1}. ${entry.value}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
