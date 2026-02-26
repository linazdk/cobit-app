import 'package:cobit/screens/organization_list_screen.dart';
import 'package:flutter/material.dart';

class QuizCobit2 extends StatelessWidget {
  const QuizCobit2({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'COBIT 2019 Quiz',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
        ),
      ),
      home: const CobitQuizScreen(),
    );
  }
}

// --- Data Models ---
class Question {
  final String text;
  final List<String> options; // MUST contain exactly 4 options
  final String correctAnswer;
  final String explanation;

  Question({
    required this.text,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  }) : assert(
         options.length == 4,
         'Each question must have exactly 4 options.',
       );
}

// --- Quiz Data (40 COBIT 2019 objectives) ---
final List<Question> cobitQuestions = [
  // Domain 1: EDM (Evaluate, Direct and Monitor) - 5 questions
  Question(
    text:
        "The Board of Directors establishes an **IT charter** defining decision-making and IT governance roles.",
    options: [
      "EDM01 (Ensure Governance Framework Setting and Maintenance)",
      "APO02 (Manage Strategy)",
      "EDM03 (Ensure Risk Optimization)",
      "MEA01 (Monitor Performance)",
    ],
    correctAnswer:
        "EDM01 (Ensure Governance Framework Setting and Maintenance)",
    explanation:
        "EDM01 is about establishing and maintaining the enterprise governance of I&T framework.",
  ),
  Question(
    text:
        "Executive management verifies that the new GRC system has actually **increased customer satisfaction by 15%** as initially planned.",
    options: [
      "EDM02 (Ensure Benefits Delivery)",
      "BAI03 (Manage Solutions)",
      "APO05 (Manage Portfolio)",
      "DSS01 (Manage Operations)",
    ],
    correctAnswer: "EDM02 (Ensure Benefits Delivery)",
    explanation:
        "EDM02 is the governance objective that ensures IT-enabled investments deliver value and achieve expected benefits.",
  ),
  Question(
    text:
        "The Board sets a limit for **financial loss acceptable** in case of a major cyberattack.",
    options: [
      "EDM03 (Ensure Risk Optimization)",
      "APO12 (Manage Risk)",
      "DSS05 (Manage Security Services)",
      "EDM05 (Ensure Stakeholder Transparency)",
    ],
    correctAnswer: "EDM03 (Ensure Risk Optimization)",
    explanation:
        "EDM03 defines the risk appetite and ensures that I&T-related risk is managed within prescribed limits.",
  ),
  Question(
    text:
        "Executive management validates that the IT team has **enough staff with the right skills** to manage the new cloud computing environment.",
    options: [
      "EDM04 (Ensure Resource Optimization)",
      "APO07 (Manage Human Resources)",
      "EDM01 (Ensure Governance Framework Setting and Maintenance)",
      "BAI09 (Manage Assets)",
    ],
    correctAnswer: "EDM04 (Ensure Resource Optimization)",
    explanation:
        "EDM04 ensures that key resources (people, financial, technology) are available and used effectively to support IT strategy.",
  ),
  Question(
    text:
        "The CIO presents a **quarterly report** on system downtime and IT budget adherence to executive management.",
    options: [
      "EDM05 (Ensure Stakeholder Transparency)",
      "MEA01 (Monitor, Evaluate and Assess Performance and Conformance)",
      "APO01 (Manage the I&T Management Framework)",
      "DSS06 (Manage Business Process Controls)",
    ],
    correctAnswer: "EDM05 (Ensure Stakeholder Transparency)",
    explanation:
        "EDM05 is about communicating and reporting performance, risks and compliance indicators to stakeholders (management, shareholders, etc.).",
  ),

  // Domain 2: APO (Align, Plan and Organize) - 14 questions
  Question(
    text:
        "The IT manager ensures that **IT management policies and procedures** are in place and consistent.",
    options: [
      "APO01 (Manage the I&T Management Framework)",
      "EDM01 (Ensure Governance Framework Setting and Maintenance)",
      "APO03 (Manage Enterprise Architecture)",
      "MEA02 (Monitor System of Internal Control)",
    ],
    correctAnswer: "APO01 (Manage the I&T Management Framework)",
    explanation:
        "APO01 is about implementing and operating the I&T management framework, including principles, policies and standards.",
  ),
  Question(
    text:
        "The IT team creates a 5-year strategic plan for **cloud migration** to support the enterprise agility objective.",
    options: [
      "APO02 (Manage Strategy)",
      "APO03 (Manage Enterprise Architecture)",
      "BAI01 (Manage Programs)",
      "EDM02 (Ensure Benefits Delivery)",
    ],
    correctAnswer: "APO02 (Manage Strategy)",
    explanation:
        "APO02 ensures that the I&T strategy is aligned with the enterprise strategy and provides a roadmap for execution.",
  ),
  Question(
    text:
        "The enterprise architect documents how the new production system will **integrate** with existing accounting systems.",
    options: [
      "APO03 (Manage Enterprise Architecture)",
      "BAI02 (Manage Requirements Definition)",
      "APO02 (Manage Strategy)",
      "DSS01 (Manage Operations)",
    ],
    correctAnswer: "APO03 (Manage Enterprise Architecture)",
    explanation:
        "APO03 establishes models and principles to design and maintain the integrated enterprise architecture (systems, data, technology).",
  ),
  Question(
    text:
        "The CIO ensures that the **functions, roles and structures** of the IT team are clearly defined and communicated.",
    options: [
      "APO04 (Manage Innovation)",
      "APO09 (Manage Service Agreements)",
      "APO06 (Manage Budget and Costs)",
      "APO04 (Manage the I&T Organization)",
    ],
    correctAnswer: "APO04 (Manage the I&T Organization)",
    explanation:
        "APO04 structures I&T teams, defines roles and ensures that the organizational structure supports I&T objectives.",
  ),
  Question(
    text:
        "The investment committee evaluates several projects (new app, server upgrade) and **selects those providing the best ROI**.",
    options: [
      "APO05 (Manage Portfolio)",
      "BAI01 (Manage Programs)",
      "EDM02 (Ensure Benefits Delivery)",
      "APO06 (Manage Budget and Costs)",
    ],
    correctAnswer: "APO05 (Manage Portfolio)",
    explanation:
        "APO05 deals with selecting, prioritizing and balancing IT-related programs and projects based on business value.",
  ),
  Question(
    text:
        "The finance department **analyzes and justifies the costs** of renewing software licenses and servers.",
    options: [
      "APO06 (Manage Budget and Costs)",
      "APO05 (Manage Portfolio)",
      "BAI09 (Manage Assets)",
      "EDM04 (Ensure Resource Optimization)",
    ],
    correctAnswer: "APO06 (Manage Budget and Costs)",
    explanation:
        "APO06 manages budget planning, cost accounting and financial reporting for I&T services and resources.",
  ),
  Question(
    text:
        "HR creates a **recruitment and training plan** to address cyber security skills gaps.",
    options: [
      "APO07 (Manage Human Resources)",
      "EDM04 (Ensure Resource Optimization)",
      "APO04 (Manage the I&T Organization)",
      "BAI02 (Manage Requirements Definition)",
    ],
    correctAnswer: "APO07 (Manage Human Resources)",
    explanation:
        "APO07 is about managing I&T human resources, including hiring, training, performance evaluation and retention.",
  ),
  Question(
    text:
        "The enterprise sets up a **technology watch program** to identify new technologies that could improve business processes.",
    options: [
      "APO08 (Manage Relationships)",
      "APO04 (Manage the I&T Organization)",
      "APO08 (Manage Innovation)",
      "APO02 (Manage Strategy)",
    ],
    correctAnswer: "APO08 (Manage Innovation)",
    explanation:
        "APO08 explores and implements emerging technologies and innovations to create new business opportunities.",
  ),
  Question(
    text:
        "The IT team formalizes a **Service Level Agreement (SLA)** with the Sales department, committing to 99.9% system availability.",
    options: [
      "APO09 (Manage Service Agreements)",
      "DSS01 (Manage Operations)",
      "MEA01 (Monitor Performance)",
      "DSS02 (Manage Incidents and Service Requests)",
    ],
    correctAnswer: "APO09 (Manage Service Agreements)",
    explanation:
        "APO09 establishes, measures and manages agreed service levels with internal or external customers.",
  ),
  Question(
    text:
        "The company selects **Microsoft Azure** as the single cloud provider after assessing its capabilities and sustainability.",
    options: [
      "APO10 (Manage Vendors)",
      "BAI09 (Manage Assets)",
      "BAI03 (Manage Solutions)",
      "EDM03 (Ensure Risk Optimization)",
    ],
    correctAnswer: "APO10 (Manage Vendors)",
    explanation:
        "APO10 manages relationships with external providers of I&T services, hardware and software.",
  ),
  Question(
    text:
        "The development team ensures software undergoes **thorough testing** and complies with internal coding standards before release.",
    options: [
      "APO11 (Manage Quality)",
      "BAI03 (Manage Solutions)",
      "MEA01 (Monitor Performance)",
      "APO01 (Manage the I&T Management Framework)",
    ],
    correctAnswer: "APO11 (Manage Quality)",
    explanation:
        "APO11 defines and maintains a quality management system for I&T services and products.",
  ),
  Question(
    text:
        "The IT team identifies the risk that a **critical server may fail** and implements real-time data replication.",
    options: [
      "APO12 (Manage Risk)",
      "EDM03 (Ensure Risk Optimization)",
      "DSS05 (Manage Security Services)",
      "BAI04 (Manage Availability and Capacity)",
    ],
    correctAnswer: "APO12 (Manage Risk)",
    explanation:
        "APO12 manages operational and strategic I&T-related risks by identifying, analyzing and responding to them.",
  ),
  Question(
    text:
        "The CIO holds **regular meetings** with the Sales director to understand needs and align priorities.",
    options: [
      "APO13 (Manage Security)",
      "APO08 (Manage Innovation)",
      "APO14 (Manage Data)",
      "APO13 (Manage Relationships)",
    ],
    correctAnswer: "APO13 (Manage Relationships)",
    explanation:
        "APO13 establishes and maintains constructive relationships with internal and external stakeholders.",
  ),
  Question(
    text:
        "The company defines **information classification and ownership standards** to ensure sensitive data is properly used and protected.",
    options: [
      "APO14 (Manage Data)",
      "DSS05 (Manage Security Services)",
      "BAI09 (Manage Assets)",
      "APO03 (Manage Enterprise Architecture)",
    ],
    correctAnswer: "APO14 (Manage Data)",
    explanation:
        "APO14 manages the data life cycle, including definition of standards, ownership and data quality.",
  ),

  // Domain 3: BAI (Build, Acquire and Implement) - 11 questions
  Question(
    text:
        "The IT team launches a **three-year program** to migrate the entire infrastructure to a microservices architecture.",
    options: [
      "BAI01 (Manage Programs)",
      "APO05 (Manage Portfolio)",
      "BAI07 (Manage Change Acceptance and Transitioning)",
      "APO02 (Manage Strategy)",
    ],
    correctAnswer: "BAI01 (Manage Programs)",
    explanation:
        "BAI01 manages I&T investment programs (groups of projects) in a coordinated way to achieve strategic objectives.",
  ),
  Question(
    text:
        "Business analysts **interview users** to collect all needs and expectations before developing the new inventory management application.",
    options: [
      "BAI02 (Manage Requirements Definition)",
      "BAI03 (Manage Solutions Identification and Build)",
      "APO03 (Manage Enterprise Architecture)",
      "APO11 (Manage Quality)",
    ],
    correctAnswer: "BAI02 (Manage Requirements Definition)",
    explanation:
        "BAI02 ensures stakeholder requirements are collected, analyzed, validated and documented.",
  ),
  Question(
    text:
        "Developers **code, configure and test** the new application in a pre-production environment.",
    options: [
      "BAI03 (Manage Solutions Identification and Build)",
      "BAI06 (Manage Changes)",
      "DSS01 (Manage Operations)",
      "APO11 (Manage Quality)",
    ],
    correctAnswer: "BAI03 (Manage Solutions Identification and Build)",
    explanation:
        "BAI03 covers building, purchasing and implementing I&T solutions according to specified requirements.",
  ),
  Question(
    text:
        "The infrastructure team plans server sizing to ensure the website can handle **peak traffic** during sales campaigns.",
    options: [
      "BAI04 (Manage Availability and Capacity)",
      "DSS01 (Manage Operations)",
      "APO09 (Manage Service Agreements)",
      "APO12 (Manage Risk)",
    ],
    correctAnswer: "BAI04 (Manage Availability and Capacity)",
    explanation:
        "BAI04 manages and plans I&T availability, capacity and performance to meet current and future needs.",
  ),
  Question(
    text:
        "The IT team develops a plan to restore **normal operations** within 4 hours after a fire in the main data center.",
    options: [
      "BAI05 (Manage Changes)",
      "DSS01 (Manage Operations)",
      "BAI05 (Manage Organisational Change Enablement / Continuity)*",
      "APO12 (Manage Risk)",
    ],
    correctAnswer:
        "BAI05 (Manage Organisational Change Enablement / Continuity)*",
    explanation:
        "BAI05 in this context is used as the objective related to continuity planning and the ability to continue critical activities after major events.",
  ),
  Question(
    text:
        "The Change Advisory Board approves or rejects **system change requests** to minimize service disruption.",
    options: [
      "BAI06 (Manage Changes)",
      "BAI07 (Manage Change Acceptance and Transitioning)",
      "DSS02 (Manage Incidents and Service Requests)",
      "BAI03 (Manage Solutions Identification and Build)",
    ],
    correctAnswer: "BAI06 (Manage Changes)",
    explanation:
        "BAI06 manages and controls all changes to I&T systems to ensure negative impact is minimized.",
  ),
  Question(
    text:
        "The Sales department **validates and signs off** that it is satisfied with the new GRC application before go-live.",
    options: [
      "BAI07 (Manage Change Acceptance and Transitioning)",
      "BAI02 (Manage Requirements Definition)",
      "BAI06 (Manage Changes)",
      "MEA01 (Monitor Performance)",
    ],
    correctAnswer: "BAI07 (Manage Change Acceptance and Transitioning)",
    explanation:
        "BAI07 ensures that delivered solutions meet business expectations and requirements and are formally accepted.",
  ),
  Question(
    text:
        "The project team performs **data conversion** and user training just before launching the new ERP system.",
    options: [
      "BAI08 (Manage Knowledge)",
      "BAI08 (Manage Change Readiness and Transition)*",
      "BAI03 (Manage Solutions Identification and Build)",
      "DSS03 (Manage Problems)",
    ],
    correctAnswer: "BAI08 (Manage Change Readiness and Transition)*",
    explanation:
        "BAI08 manages the transition of new solutions into production, including data migration and user training.",
  ),
  Question(
    text:
        "The accounting department keeps an up-to-date register of all **software licenses** to ensure compliance and plan renewals.",
    options: [
      "BAI09 (Manage Assets)",
      "APO06 (Manage Budget and Costs)",
      "APO14 (Manage Data)",
      "BAI03 (Manage Solutions Identification and Build)",
    ],
    correctAnswer: "BAI09 (Manage Assets)",
    explanation:
        "BAI09 manages the inventory and life cycle of I&T assets (hardware, software, licenses) from acquisition to disposal.",
  ),
  Question(
    text:
        "The IT department creates and maintains a **knowledge base of solutions and known errors** to improve support efficiency.",
    options: [
      "BAI10 (Manage Configuration)",
      "BAI08 (Manage Change Readiness and Transition)*",
      "BAI10 (Manage Knowledge)",
      "DSS03 (Manage Problems)",
    ],
    correctAnswer: "BAI10 (Manage Knowledge)",
    explanation:
        "BAI10 manages I&T knowledge to support decision-making, process improvement and support optimization.",
  ),
  Question(
    text:
        "The operations team updates the **central repository** of all configuration items (CIs) in the IT infrastructure.",
    options: [
      "BAI11 (Manage Configuration)",
      "APO03 (Manage Enterprise Architecture)",
      "BAI09 (Manage Assets)",
      "BAI10 (Manage Knowledge)",
    ],
    correctAnswer: "BAI11 (Manage Configuration)",
    explanation:
        "BAI11 maintains the integrity of configuration items (servers, routers, applications) and their relationships.",
  ),

  // Domain 4: DSS (Deliver, Service and Support) - 6 questions
  Question(
    text:
        "The operations team monitors performance indicators to ensure the **website response time** never exceeds 3 seconds.",
    options: [
      "DSS01 (Manage Operations)",
      "BAI04 (Manage Availability and Capacity)",
      "APO09 (Manage Service Agreements)",
      "DSS02 (Manage Incidents and Service Requests)",
    ],
    correctAnswer: "DSS01 (Manage Operations)",
    explanation:
        "DSS01 is the execution of day-to-day operational tasks to ensure I&T services run as expected.",
  ),
  Question(
    text:
        "The service desk receives a call reporting a **software outage** (incident) and creates a ticket to resolve it.",
    options: [
      "DSS02 (Manage Incidents and Service Requests)",
      "DSS03 (Manage Problems)",
      "BAI06 (Manage Changes)",
      "DSS01 (Manage Operations)",
    ],
    correctAnswer: "DSS02 (Manage Incidents and Service Requests)",
    explanation:
        "DSS02 manages user service requests and restores normal service after incidents as quickly as possible.",
  ),
  Question(
    text:
        "The support team **analyzes recurring incidents** of application crashes to find and permanently fix the root cause.",
    options: [
      "DSS03 (Manage Problems)",
      "DSS02 (Manage Incidents and Service Requests)",
      "APO11 (Manage Quality)",
      "BAI10 (Manage Knowledge)",
    ],
    correctAnswer: "DSS03 (Manage Problems)",
    explanation:
        "DSS03 identifies, analyzes and resolves root causes of incidents to prevent recurrence.",
  ),
  Question(
    text:
        "The company implements procedures to **back up critical data daily** and store it offsite.",
    options: [
      "DSS04 (Manage Continuity)",
      "BAI05 (Manage Organisational Change Enablement / Continuity)*",
      "DSS04 (Manage User Support and Data)*",
      "APO14 (Manage Data)",
    ],
    correctAnswer: "DSS04 (Manage User Support and Data)*",
    explanation:
        "DSS04 covers user support as well as the management, storage and protection of data (backup and restore).",
  ),
  Question(
    text:
        "The security team installs and maintains **firewalls, antivirus solutions** and intrusion detection systems.",
    options: [
      "DSS05 (Manage Security Services)",
      "APO13 (Manage Relationships)",
      "APO12 (Manage Risk)",
      "BAI05 (Manage Organisational Change Enablement / Continuity)*",
    ],
    correctAnswer: "DSS05 (Manage Security Services)",
    explanation:
        "DSS05 ensures protection of information assets, preserving confidentiality, integrity and availability.",
  ),
  Question(
    text:
        "The accounting system is configured to require **dual approval** for all transactions above €10,000.",
    options: [
      "DSS06 (Manage Business Process Controls)",
      "APO11 (Manage Quality)",
      "DSS05 (Manage Security Services)",
      "MEA02 (Monitor System of Internal Control)",
    ],
    correctAnswer: "DSS06 (Manage Business Process Controls)",
    explanation:
        "DSS06 integrates necessary I&T controls into business processes to ensure effectiveness and reliability.",
  ),

  // Domain 5: MEA (Monitor, Evaluate and Assess) - 4 questions
  Question(
    text:
        "Internal audit checks every quarter that **availability of critical systems** stays above 99.9%.",
    options: [
      "MEA01 (Monitor, Evaluate and Assess Performance and Conformance)",
      "EDM05 (Ensure Stakeholder Transparency)",
      "APO09 (Manage Service Agreements)",
      "DSS01 (Manage Operations)",
    ],
    correctAnswer:
        "MEA01 (Monitor, Evaluate and Assess Performance and Conformance)",
    explanation:
        "MEA01 continuously evaluates I&T performance and ensures objectives and policies are met.",
  ),
  Question(
    text:
        "The internal auditor checks whether the **access review process for critical systems** is correctly applied every month.",
    options: [
      "MEA02 (Monitor, Evaluate and Assess the System of Internal Control)",
      "DSS05 (Manage Security Services)",
      "BAI07 (Manage Change Acceptance and Transitioning)",
      "MEA01 (Monitor, Evaluate and Assess Performance and Conformance)",
    ],
    correctAnswer:
        "MEA02 (Monitor, Evaluate and Assess the System of Internal Control)",
    explanation:
        "MEA02 evaluates the effectiveness of the internal control system, ensuring reliability and integrity of information.",
  ),
  Question(
    text:
        "The legal department ensures that customer data management is **compliant with GDPR** (European data protection regulation).",
    options: [
      "MEA03 (Monitor, Evaluate and Assess Compliance with External Requirements)",
      "APO14 (Manage Data)",
      "DSS05 (Manage Security Services)",
      "APO12 (Manage Risk)",
    ],
    correctAnswer:
        "MEA03 (Monitor, Evaluate and Assess Compliance with External Requirements)",
    explanation:
        "MEA03 verifies compliance with laws, regulations and external contractual obligations (such as GDPR or SOX).",
  ),
  Question(
    text:
        "The IT department performs **certified shredding** of decommissioned hard drives at end of life, according to security policy.",
    options: [
      "BAI09 (Manage Assets)",
      "DSS04 (Manage User Support and Data)*",
      "APO14 (Manage Data)",
      "BAI09 (Manage Assets)", // Repeated on purpose
    ],
    correctAnswer: "BAI09 (Manage Assets)",
    explanation:
        "Secure disposal of I&T assets is part of the asset life cycle managed by BAI09.",
  ),

  // Extra questions to reach 40
  Question(
    text:
        "Executive management meets to evaluate whether last year’s investment in the new e-commerce platform has **met its revenue targets**.",
    options: [
      "EDM02 (Ensure Benefits Delivery)",
      "APO05 (Manage Portfolio)",
      "APO06 (Manage Budget and Costs)",
      "BAI01 (Manage Programs)",
    ],
    correctAnswer: "EDM02 (Ensure Benefits Delivery)",
    explanation:
        "Comparing realized revenue to targeted revenue is a typical measure of benefits realization (EDM02).",
  ),
  Question(
    text:
        "The IT team performs **penetration testing** to identify vulnerabilities in the customer application before public launch.",
    options: [
      "APO12 (Manage Risk)",
      "DSS05 (Manage Security Services)",
      "BAI03 (Manage Solutions Identification and Build)",
      "APO11 (Manage Quality)",
    ],
    correctAnswer: "APO12 (Manage Risk)",
    explanation:
        "Proactively identifying vulnerabilities before go-live is a risk management activity (APO12).",
  ),
  Question(
    text:
        "The company implements mandatory **multi-factor authentication (MFA)** for remote access to internal systems.",
    options: [
      "DSS05 (Manage Security Services)",
      "APO13 (Manage Relationships)",
      "BAI11 (Manage Configuration)",
      "EDM03 (Ensure Risk Optimization)",
    ],
    correctAnswer: "DSS05 (Manage Security Services)",
    explanation:
        "Implementing access controls such as MFA is a key security management activity (DSS05).",
  ),
  Question(
    text:
        "The IT department performs an annual exercise simulating a **major power outage** to test disaster recovery procedures.",
    options: [
      "BAI05 (Manage Organisational Change Enablement / Continuity)*",
      "DSS01 (Manage Operations)",
      "APO12 (Manage Risk)",
      "BAI08 (Manage Change Readiness and Transition)*",
    ],
    correctAnswer:
        "BAI05 (Manage Organisational Change Enablement / Continuity)*",
    explanation:
        "Testing and validating disaster recovery and continuity plans is a core part of BAI05.",
  ),
];

// --- Main Quiz Screen ---
class CobitQuizScreen extends StatefulWidget {
  const CobitQuizScreen({super.key});

  @override
  State<CobitQuizScreen> createState() => _CobitQuizScreenState();
}

class _CobitQuizScreenState extends State<CobitQuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _answerWasSelected = false;
  String? _selectedAnswer;
  bool _isCorrect = false;

  void _answerQuestion(String selectedAnswer) {
    if (_answerWasSelected) return;

    setState(() {
      _selectedAnswer = selectedAnswer;
      _answerWasSelected = true;
      _isCorrect =
          cobitQuestions[_currentQuestionIndex].correctAnswer == selectedAnswer;
      if (_isCorrect) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestionIndex++;
      _answerWasSelected = false;
      _selectedAnswer = null;
      _isCorrect = false;
    });
  }

  void _resetQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _answerWasSelected = false;
      _selectedAnswer = null;
      _isCorrect = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLastQuestion = _currentQuestionIndex == cobitQuestions.length - 1;
    bool isQuizFinished = _currentQuestionIndex >= cobitQuestions.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const OrganizationListScreen()),
              (route) => false,
            );
          },
        ),
        title: const Text('COBIT 2019 Quiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetQuiz,
            tooltip: 'Reset quiz',
          ),
        ],
      ),
      body: isQuizFinished
          ? Center(
              child: QuizResultScreen(
                score: _score,
                totalQuestions: cobitQuestions.length,
                onResetQuiz: _resetQuiz,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LinearProgressIndicator(
                      value:
                          (_currentQuestionIndex + 1) / cobitQuestions.length,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Question ${_currentQuestionIndex + 1}/${cobitQuestions.length}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    QuestionText(cobitQuestions[_currentQuestionIndex].text),
                    const SizedBox(height: 20),
                    ...cobitQuestions[_currentQuestionIndex].options.map((opt) {
                      Color? buttonColor;
                      if (_answerWasSelected) {
                        if (opt == _selectedAnswer) {
                          buttonColor = _isCorrect ? Colors.green : Colors.red;
                        } else if (opt ==
                            cobitQuestions[_currentQuestionIndex]
                                .correctAnswer) {
                          buttonColor = Colors.green;
                        }
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: AnswerButton(
                          text: opt,
                          onPressed: () => _answerQuestion(opt),
                          color: buttonColor,
                          enabled: !_answerWasSelected,
                        ),
                      );
                    }).toList(),
                    if (_answerWasSelected) ...[
                      const SizedBox(height: 20),
                      FeedbackMessage(
                        isCorrect: _isCorrect,
                        explanation:
                            cobitQuestions[_currentQuestionIndex].explanation,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _nextQuestion,
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(
                          isLastQuestion ? 'Finish quiz' : 'Next question',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.blueGrey,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}

// --- Reusable Widgets ---
class QuestionText extends StatelessWidget {
  final String questionText;

  const QuestionText(this.questionText, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          questionText,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class AnswerButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final bool enabled;

  const AnswerButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}

class FeedbackMessage extends StatelessWidget {
  final bool isCorrect;
  final String explanation;

  const FeedbackMessage({
    super.key,
    required this.isCorrect,
    required this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: isCorrect ? Colors.green[50] : Colors.red[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isCorrect
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  color: isCorrect ? Colors.green[700] : Colors.red[700],
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  isCorrect ? 'Correct!' : 'Incorrect…',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? Colors.green[700] : Colors.red[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              explanation,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final VoidCallback onResetQuiz;

  const QuizResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.onResetQuiz,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Quiz finished!',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text(
          'Your score: $score / $totalQuestions',
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 30),
        ElevatedButton.icon(
          onPressed: onResetQuiz,
          icon: const Icon(Icons.replay),
          label: const Text('Restart quiz'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 20),
          ),
        ),
      ],
    );
  }
}
