import 'package:flutter/material.dart';
import 'screens/quiz1_screen.dart'; // Ajustez le chemin si nécessaire

class QuizCobit extends StatelessWidget {
  const QuizCobit({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QCM Flutter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Quiz1Screen(), // Démarrez avec l'écran du QCM
    );
  }
}
