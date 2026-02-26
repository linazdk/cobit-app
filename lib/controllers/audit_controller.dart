import 'dart:convert';

import 'package:cobit/models/audit_persistence_models.dart';
import 'package:cobit/models/cobit_metrics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/cobit_models.dart';
import '../models/question_checklist.dart';
import '../services/database_service.dart';

Audit? currentAudit;

/// Main COBIT audit controller
class AuditController extends ChangeNotifier {
  /// List of COBIT objectives (EDM01, APO01, …)
  final List<CobitObjective> objectives;

  /// List of COBIT questions (APO01_Q1, APO01_Q2, …)
  final List<CobitQuestion> questions;

  /// List of checklists per question (APO01_Q1 -> items…)
  final List<QuestionChecklist> questionChecklists;

  final Map<String, List<String>> objectiveMetrics;

  /// SQLite access service (for audits / organizations / answers if needed)
  final DatabaseService db;

  Future<List<CobitObjectiveMetrics>> loadCobitMetrics() async {
    final raw = await rootBundle.loadString('assets/cobit_metrics.json');
    final List<dynamic> data = jsonDecode(raw);
    return data.map((e) => CobitObjectiveMetrics.fromMap(e)).toList();
  }

  AuditController({
    required this.objectives,
    required this.questions,
    required this.questionChecklists,
    required this.objectiveMetrics,
    required this.db,
  });

  /// Current audit ID (in DB)
  int? _currentAuditId;
  int? get currentAuditId => _currentAuditId;

  /// Answers to COBIT questions:
  /// questionId (e.g. "APO01_Q1") -> score (0–5)
  final Map<String, int> _answers = {};

  /// Threshold (%) used in the Action Plan screen
  double _actionPlanThreshold = 80;
  double get actionPlanThreshold => _actionPlanThreshold;

  /// Checked boxes in the checklists:
  /// questionId -> set of checked indices (0,1,2… on the items list)
  final Map<String, Set<int>> _checklistTicks = {};

  List<String> metricsForObjective(String objectiveId) {
    return objectiveMetrics[objectiveId] ?? const [];
  }

  // ---------------------------------------------------------------------------
  // Current audit management
  // ---------------------------------------------------------------------------

  /// To be called when selecting or creating an audit in AuditListScreen.
  ///
  /// For now, we do not reload the answers from SQLite using numeric question
  /// IDs, because the controller works with COBIT IDs (String).
  Future<void> loadAudit(int auditId) async {
    // 1️⃣ remember the current audit ID
    _currentAuditId = auditId;

    // (optional) if you want to keep a global currentAudit:
    currentAudit = await db.getAuditById(auditId);

    // 2️⃣ clear in-memory answers
    _answers.clear();

    // 3️⃣ reload from DB
    final stored = await db.getAnswersForAudit(auditId);
    for (final ans in stored) {
      _answers[ans.questionId] = ans.maturityLevel;
    }

    // 4️⃣ notify UI
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Simple answers (main questions)
  // ---------------------------------------------------------------------------

  int getAnswer(String questionId) {
    return _answers[questionId] ?? 0;
  }

  /// Updates the answer in memory and, later, in DB.
  Future<void> setAnswer(String questionId, int value) async {
    if (value < 0) value = 0;
    if (value > 5) value = 5;

    _answers[questionId] = value;
    notifyListeners();

    if (_currentAuditId == null) {
      debugPrint(
        '⚠ setAnswer called with no current audit (_currentAuditId == null)',
      );
      return;
    }

    // 🔥 Save to DB
    await db.upsertAnswer(
      Answer(
        id: null,
        auditId: _currentAuditId!,
        questionId: questionId,
        maturityLevel: value,
        comment: null, // or handle a comment field elsewhere
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Checklists per question (in memory only)
  // ---------------------------------------------------------------------------

  /// Returns the checklist associated with a COBIT question, or null if none.
  QuestionChecklist? checklistForQuestion(String questionId) {
    try {
      return questionChecklists.firstWhere((c) => c.questionId == questionId);
    } catch (_) {
      return null;
    }
  }

  /// Checked indices for a question (set of item indices).
  Set<int> getChecklistTicks(String questionId) {
    return _checklistTicks[questionId] ?? <int>{};
  }

  void _updateAnswerFromChecklist(String questionId) {
    final checklist = checklistForQuestion(questionId);
    if (checklist == null || checklist.items.isEmpty) return;

    final ticks = _checklistTicks[questionId]?.length ?? 0;
    final total = checklist.items.length;
    if (total == 0) return;

    // progress ratio 0.0–1.0
    final ratio = ticks / total;

    // suggested score 0–5
    final suggested = (ratio * 5).round();

    _answers[questionId] = suggested;
  }

  /// Toggles a checklist item for a question.
  void toggleChecklistItem(String questionId, int index) {
    final current = _checklistTicks[questionId] ?? <int>{};

    if (current.contains(index)) {
      current.remove(index);
    } else {
      current.add(index);
    }

    _checklistTicks[questionId] = current;

    // 🔹 automatically updates the 0–5 score for the question
    _updateAnswerFromChecklist(questionId);

    notifyListeners();
  }

  /// Number of checked items for a question.
  int checklistTickCount(String questionId) {
    return getChecklistTicks(questionId).length;
  }

  // ---------------------------------------------------------------------------
  // Action plan threshold
  // ---------------------------------------------------------------------------

  void setActionPlanThreshold(double value) {
    if (value < 0) value = 0;
    if (value > 100) value = 100;
    _actionPlanThreshold = value;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Scores & levels
  // ---------------------------------------------------------------------------

  /// Score for a question (0–5) based on the rating
  int questionScore(String questionId) {
    return _answers[questionId] ?? 0;
  }

  /// Average score for an objective (average of associated questions)
  /// Computes the average score (0–5) of a COBIT objective.
  /// - objectiveId: e.g. "APO05"
  /// - scopeOverride: if provided, only objectives in this scope are considered
  ///   (e.g. "APO05,DSS03")
  double objectiveScore(String objectiveId, {String? scopeOverride}) {
    // 🔹 1) Respect the scope: if scopeOverride is defined
    if (scopeOverride != null && scopeOverride.trim().isNotEmpty) {
      final idsInScope = scopeOverride
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toSet();

      // If the objective is not in scope -> "perfect" score
      // so that it does not trigger an action plan.
      if (!idsInScope.contains(objectiveId)) {
        return 5.0;
      }
    }

    // 🔹 2) Get all questions for this objective
    final questionsForObjective = questions
        .where((q) => q.objectiveId == objectiveId)
        .toList();

    if (questionsForObjective.isEmpty) {
      // No questions for this objective -> consider OK
      return 5.0;
    }

    double total = 0;
    int count = 0;

    for (final q in questionsForObjective) {
      final level = getAnswer(q.id); // int 0–5
      total += level.toDouble();
      count++;
    }

    if (count == 0) {
      // No answers for this objective -> neutral or 5
      return 5.0;
    }

    return total / count; // average 0–5
  }

  /// Average score for a COBIT domain (average of the domain’s objectives)
  double domainScore(CobitDomain domain) {
    final domainObjectives = objectives
        .where((o) => o.domain == domain)
        .toList();
    if (domainObjectives.isEmpty) return 0.0;

    double sum = 0;
    for (final obj in domainObjectives) {
      sum += objectiveScore(obj.id);
    }
    return sum / domainObjectives.length;
  }

  /// Global score (average of all objectives)
  double globalScore() {
    if (objectives.isEmpty) return 0.0;
    double sum = 0;
    for (final obj in objectives) {
      sum += objectiveScore(obj.id);
    }
    return sum / objectives.length;
  }

  /// Capability level (0–5) from a score in %
  int capabilityLevel(double scorePercent) {
    if (scorePercent <= 0) return 0;
    if (scorePercent < 20) return 1;
    if (scorePercent < 40) return 2;
    if (scorePercent < 60) return 3;
    if (scorePercent < 80) return 4;
    return 5;
  }

  // ---------------------------------------------------------------------------
  // Recommendations
  // ---------------------------------------------------------------------------

  String recommendationForLevel(int level) {
    switch (level) {
      case 0:
        return "Formalize a minimal process, assign an owner, define basic objectives and requirements.";
      case 1:
        return "Document existing practices, standardize them and set up simple indicators.";
      case 2:
        return "Define formal policies and procedures, structure controls and clarify roles.";
      case 3:
        return "Standardize execution, automate repetitive tasks and monitor regular KPIs.";
      case 4:
        return "Monitor performance, reduce variation and integrate the process into corporate governance.";
      case 5:
        return "Support continuous improvement, external benchmarking and ongoing innovation.";
      default:
        return "";
    }
  }

  String recommendationForDomain(CobitDomain domain) {
    switch (domain) {
      case CobitDomain.edm:
        return "Strengthen the involvement of governance bodies (executive committee, board), clarify I&T decision-making roles, improve risk management and transparency to stakeholders.";
      case CobitDomain.apo:
        return "Align I&T strategy with business strategy, develop a formal enterprise architecture, professionalize portfolio management and strengthen risk and security management.";
      case CobitDomain.bai:
        return "Professionalize program and project management, secure change management processes, improve asset and configuration management and integrate security from design onward.";
      case CobitDomain.dss:
        return "Standardize operations, strengthen incident/problem management, improve continuity and disaster recovery and secure day-to-day operations.";
      case CobitDomain.mea:
        return "Implement an I&T performance measurement system, formalize internal control assessments and strengthen compliance with regulatory requirements.";
    }
  }

  List<String> recommendationsForObjective(String objectiveId) {
    switch (objectiveId) {
      // ----------------- EDM -----------------
      case 'EDM01':
        return [
          "Formally document and approve the I&T governance framework (principles, roles, committees).",
          "Set up a calendar of periodic I&T governance reviews by senior management.",
          "Align the I&T governance framework with recognized references (COBIT 2019, ISO 38500, etc.).",
        ];
      case 'EDM02':
        return [
          "Require a business case for every significant I&T investment.",
          "Implement systematic benefits tracking after go-live (post-implementation review).",
          "Set up a benefits portfolio with clearly identified benefit owners.",
        ];
      case 'EDM03':
        return [
          "Maintain an I&T risk register integrated into the enterprise-wide risk register.",
          "Define I&T risk appetite and tolerance with senior management.",
          "Establish regular reporting on major I&T risks to governance bodies.",
        ];
      case 'EDM04':
        return [
          "Consolidate a view of I&T resources (skills, applications, infrastructure, data).",
          "Align sourcing decisions (cloud, outsourcing) with a cost/risk/strategy analysis.",
          "Monitor capacity of critical resources and arbitrate priority conflicts at executive level.",
        ];
      case 'EDM05':
        return [
          "Map key I&T stakeholders and structure communications (reports, committees).",
          "Formalize regular reports on I&T performance, risks and costs.",
          "Set up stakeholder feedback mechanisms and integrate feedback into steering.",
        ];

      // ----------------- APO -----------------
      case 'APO01':
        return [
          "Clearly define and document the I&T management system policies, processes and roles.",
          "Align the management system with a good-practice framework (COBIT, ITIL, ISO).",
          "Organize regular reviews of the I&T management system and track action plans.",
        ];
      case 'APO02':
        return [
          "Develop a formal I&T strategy, approved by senior management and aligned to business strategy.",
          "Translate the I&T strategy into roadmaps with milestones, priorities and budgets.",
          "Systematically involve business stakeholders in defining and reviewing I&T strategy.",
        ];
      case 'APO03':
        return [
          "Implement an enterprise architecture map (processes, data, applications, technologies).",
          "Define architecture principles and enforce them in projects and investment decisions.",
          "Set up architecture boards to validate major structural choices (solutions, integration, cloud).",
        ];
      case 'APO04':
        return [
          "Structure the innovation process (idea collection, evaluation, PoC, industrialization).",
          "Allocate dedicated budget and time for I&T innovation initiatives.",
          "Systematically assess risks and benefits before scaling up innovations.",
        ];
      case 'APO05':
        return [
          "Build a single portfolio of I&T projects and services with explicit prioritization.",
          "Define selection and prioritization criteria (value, risks, resources, dependencies).",
          "Organize regular portfolio reviews with management and make go/kill decisions.",
        ];
      case 'APO06':
        return [
          "Set up a clear I&T budgeting process aligned with the enterprise financial cycle.",
          "Track costs by service, project and business unit (showback/chargeback).",
          "Analyze budget vs actual variances and decide on I&T cost optimization actions.",
        ];
      case 'APO07':
        return [
          "Identify key I&T skills and set up a development plan (training, certification).",
          "Formalize job descriptions and responsibilities for I&T roles.",
          "Implement knowledge transfer mechanisms to reduce dependency on individuals.",
        ];
      case 'APO08':
        return [
          "Establish Business Relationship Manager roles or business liaisons.",
          "Regularly measure user satisfaction with I&T services.",
          "Organize regular committees with business to prioritize demands and address pain points.",
        ];
      case 'APO09':
        return [
          "Build and publish an I&T service catalog with clear SLAs.",
          "Monitor service performance (availability, incidents, response time) versus SLAs.",
          "Review SLAs regularly with business and adjust commitments when needed.",
        ];
      case 'APO10':
        return [
          "Define a vendor management policy, including selection and performance criteria.",
          "Include SLA, security, confidentiality and compliance clauses in contracts.",
          "Set up periodic performance reviews with critical vendors.",
        ];
      case 'APO11':
        return [
          "Define a quality policy for I&T activities (projects, services).",
          "Implement systematic quality reviews (code, design, deliverables).",
          "Use quality results (defects, nonconformities) to feed a continuous improvement plan.",
        ];
      case 'APO12':
        return [
          "Deploy an I&T risk management framework (method, registers, roles).",
          "Integrate I&T risks into the enterprise-wide risk register.",
          "Implement regular reporting of major I&T risks to governance bodies.",
        ];
      case 'APO13':
        return [
          "Define and maintain an information security policy approved by senior management.",
          "Deploy a security awareness program for all users.",
          "Implement technical controls (access management, patching, monitoring) aligned with risks.",
        ];

      // ----------------- BAI -----------------
      case 'BAI01':
        return [
          "Standardize project and program management methodology (waterfall, agile, hybrid).",
          "Set up a project portfolio with centralized control over risks, costs and benefits.",
          "Organize regular project review meetings with business sponsors.",
        ];
      case 'BAI02':
        return [
          "Implement a formal requirements gathering and validation process with business.",
          "Ensure traceability of requirements throughout the life cycle (specifications, tests).",
          "Include security and compliance constraints from the requirements phase.",
        ];
      case 'BAI03':
        return [
          "Systematically assess options (buy/build/SaaS) in line with the target architecture.",
          "Implement controlled development practices (code review, testing, CI/CD where possible).",
          "Integrate security by design into solution design and development.",
        ];
      case 'BAI04':
        return [
          "Define capacity and availability targets together with the business.",
          "Implement performance monitoring and load testing for critical applications.",
          "Anticipate load increases using trend analysis and capacity planning.",
        ];
      case 'BAI05':
        return [
          "Systematically include change management in projects impacting business operations.",
          "Plan communication, training and user support activities.",
          "Measure adoption of new processes and tools after deployment.",
        ];
      case 'BAI06':
        return [
          "Set up a change management process including logging, assessment and approval.",
          "Hold a Change Advisory Board (CAB) for significant changes.",
          "Analyze failed changes and strengthen controls before go-live.",
        ];
      case 'BAI07':
        return [
          "Standardize deployment plans including testing, validation, communication and rollback.",
          "Clearly separate environments (dev / test / pre-prod / prod).",
          "Implement post-deployment monitoring to detect incidents and drifts.",
        ];
      case 'BAI08':
        return [
          "Create and maintain an IT and support knowledge base.",
          "Document solutions to recurring incidents/problems in the knowledge base.",
          "Promote knowledge base usage through support tools and user portals.",
        ];
      case 'BAI09':
        return [
          "Establish a complete inventory of I&T assets (hardware, software, licenses, data).",
          "Define asset owners and manage the asset life cycle (acquisition, operation, retirement).",
          "Control software license management to reduce legal risks and costs.",
        ];
      case 'BAI10':
        return [
          "Implement a CMDB (or equivalent) and include critical configuration items.",
          "Link the CMDB to the change process to ensure automatic updates.",
          "Use the CMDB to analyze the impact of incidents and changes.",
        ];
      case 'BAI11':
        return [
          "Define a common project management framework (templates, roles, indicators).",
          "Systematically track progress, costs, risks and quality for projects.",
          "Formally close projects with a final review and lessons learned.",
        ];

      // ----------------- DSS -----------------
      case 'DSS01':
        return [
          "Document operating procedures (backups, batch jobs, checks).",
          "Set up an operations schedule and track successful completion of tasks.",
          "Regularly review operation logs to detect anomalies and drifts.",
        ];
      case 'DSS02':
        return [
          "Log all incidents and requests in a central ticketing tool.",
          "Standardize ticket categorization and prioritization.",
          "Measure resolution times and act on the root causes of excessive delays.",
        ];
      case 'DSS03':
        return [
          "Analyze recurring incidents to identify underlying problems.",
          "Maintain a problem register with root causes and corrective actions.",
          "Implement permanent fixes or documented workarounds.",
        ];
      case 'DSS04':
        return [
          "Define business continuity and disaster recovery plans (BCP/DRP) for critical services with validated RTO/RPO.",
          "Regularly test backup restorations and recovery scenarios.",
          "Update continuity plans after every major change.",
        ];
      case 'DSS05':
        return [
          "Implement security log and alert collection and analysis (SIEM if possible).",
          "Formalize security incident management procedures (detection, response, communication).",
          "Strengthen privileged account and remote access management.",
        ];
      case 'DSS06':
        return [
          "Identify key controls in business processes supported by I&T.",
          "Regularly review the effectiveness of automated and manual controls.",
          "Adapt controls when processes or applications change.",
        ];

      // ----------------- MEA -----------------
      case 'MEA01':
        return [
          "Define an I&T dashboard with indicators aligned with business objectives.",
          "Produce regular I&T performance reports and share them with stakeholders.",
          "Analyze performance trends to anticipate issues and opportunities.",
        ];
      case 'MEA02':
        return [
          "Document the I&T internal control framework (references, responsibilities, key controls).",
          "Perform periodic assessments of I&T internal control effectiveness.",
          "Track remediation plans for control weaknesses until closure.",
        ];
      case 'MEA03':
        return [
          "Maintain an inventory of regulatory and contractual requirements applicable to I&T.",
          "Plan regular compliance reviews/audits (security, data protection, sector regulations, etc.).",
          "Set up tracking for noncompliance issues and related corrective actions.",
        ];

      // ----------------- default -----------------
      default:
        return [
          "Analyze the detailed audit results for this objective.",
          "Prioritize 2–3 short-term corrective actions with a clearly identified owner.",
          "Monitor progress of actions and reassess the score after implementation.",
        ];
    }
  }
}
