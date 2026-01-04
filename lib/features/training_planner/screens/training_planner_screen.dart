import 'package:flutter/material.dart';
import '../widgets/big_action_tile.dart';
import '../plan_builder/screens/workout_list_screen.dart';
import '../exercise_pool/screens/exercise_pool_screen.dart';

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
                MaterialPageRoute(builder: (_) => const WorkoutListScreen()),
              );
            },
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: BigActionTile(
            title: 'Übungen',
            icon: Icons.fitness_center_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExercisePoolScreen()),
              );
            },
          ),
        ),
      ],
    );
  }
}
