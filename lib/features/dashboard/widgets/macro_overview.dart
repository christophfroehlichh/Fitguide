import 'package:flutter/material.dart';

class MacroOverview extends StatelessWidget {
  final int calories;
  final int protein;
  final int carbs;
  final int fats;

  const MacroOverview({
    super.key,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Erste Reihe: Kalorien + Protein
        Row(
          children: [
            Expanded(
              child: MacroCard(
                label: 'Kalorien',
                value: '${calories}kcal',
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MacroCard(
                label: 'Protein',
                value: '${protein}g',
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Zweite Reihe: Carbs + Fats
        Row(
          children: [
            Expanded(
              child: MacroCard(
                label: 'Carbs',
                value: '${carbs}g',
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MacroCard(
                label: 'Fette',
                value: '${fats}g',
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class MacroCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const MacroCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
