import 'package:flutter/material.dart';
import 'models/training_plan.dart';

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
      name: 'Plan 4',
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
        padding: const EdgeInsets.all(16),
        child: _PlansAccordion(plans: _plans),
      ),
    );
  }
}

class _PlansAccordion extends StatefulWidget {
  final List<TrainingPlan> plans;
  const _PlansAccordion({required this.plans});

  @override
  State<_PlansAccordion> createState() => _PlansAccordionState();
}

class _PlansAccordionState extends State<_PlansAccordion> {
  // ExpansionPanelList.radio verwaltet “nur eins offen” selbst,
  // aber wir nutzen isExpanded aus headerBuilder fürs grüne Highlight.

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList.radio(
      elevation: 0,
      expandedHeaderPadding: EdgeInsets.zero,
      children: widget.plans.map((plan) {
        return ExpansionPanelRadio(
          value: plan.id,
          canTapOnHeader: true,
          headerBuilder: (context, isExpanded) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: isExpanded ? Colors.green.withOpacity(0.25) : null,
                border: Border.all(color: Colors.black26),
              ),
              child: Text(
                plan.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            );
          },
          body: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.black26),
                right: BorderSide(color: Colors.black26),
                bottom: BorderSide(color: Colors.black26),
              ),
            ),
            child: Column(
              children: [for (final ex in plan.exercises) _RowLine(text: ex)],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _RowLine extends StatelessWidget {
  final String text;
  const _RowLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black26)),
      ),
      child: Text(text, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
