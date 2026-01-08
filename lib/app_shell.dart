import 'package:flutter/material.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/training/screens/training_screen.dart';
import 'features/training_planner/screens/training_planner_screen.dart';
import 'features/logbook/screens/logbook_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final Widget body = switch (_currentIndex) {
      0 => const DashboardScreen(),
      1 => const TrainingScreen(),
      2 => const TrainingPlannerScreen(),
      3 => const LogbookScreen(),
      _ => const DashboardScreen(),
    };

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'FitGuide',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () {}, // später: Settings-Screen
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            label: '',
          ),
          NavigationDestination(icon: Icon(Icons.book_outlined), label: ''),
        ],
      ),
    );
  }
}
