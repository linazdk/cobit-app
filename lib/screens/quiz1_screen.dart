import 'package:cobit/screens/organization_list_screen.dart';
import 'package:flutter/material.dart';
import '../data/quiz_cobit_data.dart';
import '../models/quiz_question.dart';

class Quiz1Screen extends StatefulWidget {
  const Quiz1Screen({super.key});

  @override
  State<Quiz1Screen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<Quiz1Screen> {
  int _questionIndex = 0;
  String? _selectedAnswer;
  bool _isAnswered = false;

  // NOUVELLES VARIABLES D'ÉTAT POUR LE SCORE
  int _score = 0;
  int _questionsAttempted = 0;

  void _answerQuestion(String answer) {
    if (_isAnswered) return;

    final currentQuestion = cobitQuestions[_questionIndex];
    final bool isCorrect = answer == currentQuestion.correctAnswer;

    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true;
      _questionsAttempted++; // Incrémente le nombre de questions tentées

      // Mise à jour du score si la réponse est correcte
      if (isCorrect) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      // Logique pour passer à la question suivante ou recommencer le quiz
      if (_questionIndex < cobitQuestions.length - 1) {
        _questionIndex++;
      } else {
        // Optionnel : Réinitialiser le quiz
        _questionIndex = 0;
        _score = 0;
        _questionsAttempted = 0;
      }
      _selectedAnswer = null;
      _isAnswered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (cobitQuestions.isEmpty) {
      return const Center(child: Text("Aucune question disponible."));
    }

    final Question currentQuestion = cobitQuestions[_questionIndex];
    final bool isLastQuestion = _questionIndex == cobitQuestions.length - 1;

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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Affichage de la progression actuelle
            Text("QCM Cobit - ${_questionIndex + 1}/${cobitQuestions.length}"),
            // AFFICHAGE DU SCORE dans l'AppBar
            Text(
              "Score: $_score / $_questionsAttempted",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Texte de la question
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  currentQuestion.questionText,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Options de réponse
            ...currentQuestion.answers.map((answer) {
              final bool isCorrect = answer == currentQuestion.correctAnswer;
              final bool isSelected = answer == _selectedAnswer;

              Color buttonColor = Colors.blueGrey;

              if (_isAnswered) {
                if (isCorrect) {
                  buttonColor = Colors.green; // Bonne réponse
                } else if (isSelected && !isCorrect) {
                  buttonColor = Colors.red; // Mauvaise réponse sélectionnée
                }
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _answerQuestion(answer),
                  child: Text(answer, textAlign: TextAlign.center),
                ),
              );
            }).toList(),

            const Spacer(),

            // Bouton de navigation
            if (_isAnswered)
              ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.all(15),
                ),
                child: Text(
                  isLastQuestion ? "Recommencer le QCM" : "Question Suivante",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
