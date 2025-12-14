import 'package:flutter/material.dart';
import '../models/training_plan.dart';

class PlansAccordion extends StatefulWidget {
  final List<TrainingPlan> plans;
  const PlansAccordion({super.key, required this.plans});

  @override
  State<PlansAccordion> createState() => _PlansAccordionState();
}

class _PlansAccordionState extends State<PlansAccordion> {
  String? _openPlanId;

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
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isOpen ? scheme.primaryContainer : scheme.surface,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: scheme.onSurface),
              ),
            ),
            Icon(
              isOpen ? Icons.expand_less : Icons.expand_more,
              color: scheme.onSurfaceVariant,
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
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          left: BorderSide(color: scheme.outlineVariant),
          right: BorderSide(color: scheme.outlineVariant),
          bottom: BorderSide(color: scheme.outlineVariant),
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
    final scheme = Theme.of(context).colorScheme;

    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: scheme.onSurface),
      ),
    );
  }
}
