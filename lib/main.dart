import 'dart:convert';
import 'package:cobit/screens/welcome_screen.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cobit/controllers/audit_controller.dart';
import 'package:cobit/repositories/cobit_repository.dart';
import 'package:cobit/services/database_service.dart';
import 'package:cobit/services/referential_bootstrap_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';

/// ---------------------------------------------------------------------------
/// CHARGEMENT DES METRIQUES COBIT
/// ---------------------------------------------------------------------------
Future<Map<String, List<String>>> loadCobitMetrics() async {
  final raw = await rootBundle.loadString('assets/cobit_metrics.json');
  final List<dynamic> data = jsonDecode(raw);

  final Map<String, List<String>> map = {};
  for (final item in data) {
    final id = item['objectiveId'] as String;
    final metrics = (item['metrics'] as List<dynamic>)
        .map((m) => m.toString())
        .toList();
    map[id] = metrics;
  }
  return map;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = DatabaseService.instance;

  // Charge les données JSON existantes
  final repo = CobitRepository();
  final objectives = await repo.loadObjectives();
  final questions = await repo.loadQuestions();
  final checklists = await repo.loadQuestionChecklists();

  // Charge les métriques COBIT (NOUVEAU)
  final metricsByObjective = await loadCobitMetrics();

  // Initialise le référentiel en base si vide
  final bootstrap = ReferentialBootstrapService(db);
  await bootstrap.initializeIfEmpty();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuditController(
            objectives: objectives,
            questions: questions,
            questionChecklists: checklists,
            db: db,
            objectiveMetrics: metricsByObjective, // 👈 NOUVEAU ARGUMENT
          ),
        ),
      ],
      child: const CobitMetricsApp(),
    ),
  );
}

class CobitMetricsApp extends StatelessWidget {
  const CobitMetricsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'COBIT Metrics',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(), // Material 3 OK
      home: const WelcomeScreen(),
    );
  }
}
