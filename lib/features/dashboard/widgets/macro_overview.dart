import 'package:flutter/material.dart';

class MacroOverview extends StatelessWidget {
  const MacroOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: MacroCard(
            label: 'Protein',
            value: '180g',
            color: Colors.green,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: MacroCard(label: 'Carbs', value: '220g', color: Colors.orange),
        ),
        SizedBox(width: 12),
        Expanded(
          child: MacroCard(label: 'Fat', value: '70g', color: Colors.blue),
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
