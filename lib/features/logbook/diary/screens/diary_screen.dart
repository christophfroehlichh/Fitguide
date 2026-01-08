import 'package:flutter/material.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tagebuch'),
      ),
      body: const Center(
        child: Text('Tagebuch - Noch keine Einträge'),
      ),
    );
  }
}
