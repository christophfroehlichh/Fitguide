import 'package:flutter/material.dart';
import 'widgets/big_action_tile.dart';
import 'plan_builder/plan_builder_screen.dart';

class TrainingPlannerScreen extends StatelessWidget {
  const TrainingPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BigActionTile(
            title: 'Trainingspläne',
            icon: Icons.assignment_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlanBuilderScreen()),
              );
            },
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: BigActionTile(
            title: 'Übungen',
            icon: Icons.fitness_center_outlined,
            onTap: () {}, // später Navigation
          ),
        ),
      ],
    );
  }
}
