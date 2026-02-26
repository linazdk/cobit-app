// lib/repositories/cobit_repository.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/cobit_models.dart';
import '../models/question_checklist.dart';
import '../models/cobit_practice_models.dart';

class CobitRepository {
  /// -------------------------------
  /// OBJECTIFS COBIT
  /// -------------------------------
  Future<List<CobitObjective>> loadObjectives() async {
    final raw = await rootBundle.loadString('assets/cobit_objectives.json');
    final List<dynamic> data = jsonDecode(raw) as List<dynamic>;

    return data
        .map((e) => CobitObjective.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// -------------------------------
  /// QUESTIONS COBIT
  /// -------------------------------
  Future<List<CobitQuestion>> loadQuestions() async {
    final raw = await rootBundle.loadString('assets/cobit_questions.json');
    final List<dynamic> data = jsonDecode(raw) as List<dynamic>;

    return data
        .map((e) => CobitQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// -------------------------------
  /// CHECKLISTS DES QUESTIONS
  /// -------------------------------
  Future<List<QuestionChecklist>> loadQuestionChecklists() async {
    final raw = await rootBundle.loadString(
      'assets/data/question_checklists.json',
    );
    final List<dynamic> data = jsonDecode(raw) as List<dynamic>;

    return data
        .map((e) => QuestionChecklist.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// -------------------------------
  /// PRATIQUES DE MANAGEMENT COBIT
  ///
  /// JSON pratiques :
  /// [
  ///   {
  ///     "id": "EDM01",
  ///     "name": "...",
  ///     "purpose": "...",
  ///     "management_practices": [
  ///       { "id": "EDM01.01", "name": "...", "description": "..." },
  ///       ...
  ///     ]
  ///   },
  ///   ...
  /// ]
  /// -------------------------------
  Future<List<CobitManagementPractice>> loadPractices() async {
    final raw = await rootBundle.loadString('assets/cobit_practices.json');
    final List<dynamic> data = jsonDecode(raw) as List<dynamic>;

    final List<CobitManagementPractice> result = [];

    for (final obj in data) {
      final map = obj as Map<String, dynamic>;
      final String objectiveId = map['id'] as String; // ex : "EDM01"

      final List<dynamic> practicesJson =
          (map['management_practices'] as List<dynamic>? ?? const []);

      for (final p in practicesJson) {
        final pm = p as Map<String, dynamic>;

        result.add(
          CobitManagementPractice(
            id: pm['id'] as String, // ex : "EDM01.01"
            objectiveId: objectiveId,
            name: pm['name'] as String? ?? '',
            description: pm['description'] as String? ?? '',
          ),
        );
      }
    }

    return result;
  }

  /// -------------------------------
  /// ACTIVITÉS COBIT
  ///
  /// JSON activités supposé :
  /// [
  ///   {
  ///     "practiceId": "EDM01.01",
  ///     "activities": [
  ///       { "id": "EDM01.01-A1", "description": "..." },
  ///       ...
  ///     ]
  ///   },
  ///   ...
  /// ]
  /// -------------------------------
  Future<List<CobitActivity>> loadActivities() async {
    final raw = await rootBundle.loadString('assets/cobit_activities.json');
    final List<dynamic> data = jsonDecode(raw) as List<dynamic>;

    final List<CobitActivity> result = [];

    for (final item in data) {
      final m = item as Map<String, dynamic>;
      final String practiceId = m['practiceId'] as String;

      final List<dynamic> actsJson =
          (m['activities'] as List<dynamic>? ?? const []);

      for (final a in actsJson) {
        final am = a as Map<String, dynamic>;

        result.add(
          CobitActivity.fromJson(
            am,
            practiceId: practiceId, // ✅ on passe bien practiceId ici
          ),
        );
      }
    }

    return result;
  }
}
