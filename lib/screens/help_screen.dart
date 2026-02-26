import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Help / User Guide")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: const Text(
          _helpText,
          style: TextStyle(fontSize: 16, height: 1.4),
        ),
      ),
    );
  }
}

const String _helpText = """

1. Introduction

COBIT Metrics is an application designed to support organizations in assessing, governing, and continuously improving their I&T processes according to the COBIT 2019 framework.

The application enables:

- Creating organizations and audits
- Defining a customized assessment scope
- Evaluating COBIT objectives through a structured questionnaire
- Automatic gap (issue) generation
- Building an action plan based on identified gaps
- Summary dashboards and professional navigation

This manual describes all features of the application.

2. General navigation

The application is organized around the following modules:

- Organizations
- Audits
- COBIT Scope
- Objective assessment
- Question assessment
- Gaps
- Action plan
- Export / Backup

Each main screen has an AppBar with appropriate actions (help, validation, save…).

3. Managing organizations

From the home screen:

- Add an organization using “+ Add”
- Enter a name (e.g., “NovaTech Industries”)
- Choose a sector and size if needed
- Tap an organization to access its audits

Each organization contains one or multiple audits.

4. Managing audits

For each organization, you can:

- View the list of existing audits
- Add a new audit (name, date, auditor…)
- Change an audit’s status following the COBIT workflow:

  - Draft  
  - In progress  
  - In review  
  - Validated  

A validated audit enables automatic gap generation.

5. Defining the audit scope

The scope is essential: it defines which COBIT objectives will actually be evaluated.

Features:

- Select COBIT objectives/processes (APO05, DSS03…)
- Grouping by domain (EDM, APO, BAI, DSS, MEA)
- Optionally define a target maturity level for each objective (0–5)
- Automatic saving of the scope in the audit

Only objectives included in the scope generate gaps and contribute to the action plan.

6. Assessing COBIT objectives

From the domain screen:

- Select a domain (e.g., APO)
- Choose an objective (APO05, APO08…)

Each objective displays:

- Its average score
- Its maturity level
- Its progress status in the audit

7. Assessing questions

Each objective contains several questions.

For each question:

- Use the slider (0 to 5) to set the level of achievement
- Review or check the detailed checklist
- Checked items may automatically adjust the score
- Optionally add a comment for analysis

All responses are saved automatically.

8. Gap generation

When switching an audit to Validated status:

The application:

- Analyzes obtained scores
- Compares them with the targets defined in the scope
- Identifies gaps when:

      Observed level < Target level

Automatically generated:

- Gap title
- Detailed description
- Severity (minor, major, critical)
- COBIT context (domain, objective, question)

You can view these gaps in the “Gaps” screen.

9. Action plan

Based on the gaps, the app generates a structured action plan.

For each action:

An automatic title is proposed.

You can add:

- An owner
- A target date
- A progress status (Planned, In progress, Closed…)
- A progress percentage

Display is limited to the defined scope.

The action plan becomes your operational monitoring tool.

10. Backup / Export

The application allows:

- Exporting the database (share)
- Creating a local backup on the device
- Restoring a local backup

These features are accessible from the AppBar on the Organizations screen.

11. Audit summary

At the end of an audit, you get:

- Global score
- Score by domain
- Score by objective
- List of gaps
- Consolidated action plan
- Automatic recommendations

12. Export, Backup, and Restore

The application provides three essential data-protection features:

12.1 Database export  
- Allows sharing the full SQLite database.  
- Accessible via the "cloud_upload" icon in the Organizations screen.  
- The file can be sent by email, Drive, etc.

12.2 Local backup  
- Creates a copy of the database inside the device.  
- Accessible via the "save" icon.  
- Useful in case of errors or corruption.

12.3 Local restore  
- Restores the latest local backup.  
- Completely replaces the current database.  
- Accessible via the "restore" icon.  
- Requires restarting the application.

Best practices:  
- Backup regularly.  
- Export the database after each validated audit.  
- Keep several archived versions.

13. Assistance and support

If you need help:

- Use the integrated help (❓ icon in the AppBar)
- Contact your internal audit representative
- Consult COBIT 2019 documentation for further details

""";
