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
  String? _openPlanId; // nur EINER offen

  void _toggle(String id) {
    setState(() {
      _openPlanId = (_openPlanId == id) ? null : id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final plan in widget.plans) ...[
          _PlanHeaderRow(
            title: plan.name,
            isOpen: _openPlanId == plan.id,
            onTap: () => _toggle(plan.id),
          ),
          if (_openPlanId == plan.id) _PlanBody(exercises: plan.exercises),
        ],
      ],
    );
  }
}

class _PlanHeaderRow extends StatelessWidget {
  final String title;
  final bool isOpen;
  final VoidCallback onTap;

  const _PlanHeaderRow({
    required this.title,
    required this.isOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isOpen ? Colors.green.withOpacity(0.25) : null,
          border: Border.all(color: Colors.black26),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            Icon(
              isOpen ? Icons.expand_less : Icons.expand_more,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanBody extends StatelessWidget {
  final List<String> exercises;
  const _PlanBody({required this.exercises});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.black26),
          right: BorderSide(color: Colors.black26),
          bottom: BorderSide(color: Colors.black26),
        ),
      ),
      child: Column(children: [for (final ex in exercises) _RowLine(text: ex)]),
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
