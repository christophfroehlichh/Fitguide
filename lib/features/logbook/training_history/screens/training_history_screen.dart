import 'package:flutter/material.dart';

class TrainingHistoryScreen extends StatelessWidget {
  const TrainingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainingshistorie'),
      ),
      body: const Center(
        child: Text('Trainingshistorie - Noch keine Einträge'),
      ),
    );
  }
}
