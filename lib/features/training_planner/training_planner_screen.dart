import 'package:flutter/material.dart';

class TrainingPlannerScreen extends StatelessWidget {
  const TrainingPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'FitGuide',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _BigActionTile(
              title: 'Trainingspläne',
              icon: Icons.assignment_outlined,
              onTap: () {}, // später: Navigation
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _BigActionTile(
              title: 'Übungen',
              icon: Icons.fitness_center_outlined,
              onTap: () {}, // später: Navigation
            ),
          ),
        ],
      ),
    );
  }
}

class _BigActionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _BigActionTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            Icon(icon, size: 110),
          ],
        ),
      ),
    );
  }
}
