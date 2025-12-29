import 'package:flutter/material.dart';
import '../models/training_plan.dart';
import '../widgets/plans_accordion.dart';

class PlanBuilderScreen extends StatelessWidget {
  const PlanBuilderScreen({super.key});

  static final List<TrainingPlan> _plans = [
    const TrainingPlan(
      id: 'p1',
      name: 'Plan 1',
      exercises: ['Übung 1', 'Übung 2', 'Übung 3'],
    ),
    const TrainingPlan(
      id: 'p2',
      name: 'Plan 2',
      exercises: ['Übung A', 'Übung B'],
    ),
    const TrainingPlan(id: 'p3', name: 'Plan 3', exercises: ['Übung X']),
    const TrainingPlan(
      id: 'p4',
      name: 'Plan 5',
      exercises: ['Übung Y', 'Übung Z'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainingsplan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: PlansAccordion(plans: _plans),
      ),
    );
  }
}
