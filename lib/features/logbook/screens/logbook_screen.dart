import 'package:flutter/material.dart';
import '../../training_planner/widgets/big_action_tile.dart';
import '../training_history/screens/training_history_screen.dart';
import '../diary/screens/diary_screen.dart';

class LogbookScreen extends StatelessWidget {
  const LogbookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BigActionTile(
            title: 'Trainingshistorie',
            icon: Icons.history_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TrainingHistoryScreen()),
              );
            },
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: BigActionTile(
            title: 'Tagebuch',
            icon: Icons.book_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DiaryScreen()),
              );
            },
          ),
        ),
      ],
    );
  }
}
