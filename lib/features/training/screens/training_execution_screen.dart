import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../training_planner/plan_builder/models/workout_model.dart';
import '../../training_planner/exercise_pool/models/exercise_model.dart';
import '../cubit/training_cubit.dart';
import '../cubit/training_state.dart';
import '../models/training_history_model.dart';

class TrainingExecutionScreen extends StatefulWidget {
  final WorkoutModel workout;
  final List<ExerciseModel> exercises;

  const TrainingExecutionScreen({
    super.key,
    required this.workout,
    required this.exercises,
  });

  @override
  State<TrainingExecutionScreen> createState() => _TrainingExecutionScreenState();
}

class _TrainingExecutionScreenState extends State<TrainingExecutionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TrainingCubit>().startTraining(
          workout: widget.workout,
          exercises: widget.exercises,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TrainingCubit, TrainingState>(
      listener: (context, state) {
        if (state is TrainingCompleted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Training abgeschlossen!')),
          );
        }
        if (state is TrainingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is TrainingInProgress) {
          return Scaffold(
            appBar: AppBar(
              title: Text(state.session.workoutName),
              actions: [
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Training abbrechen?'),
                        content: const Text(
                          'Möchtest du das Training wirklich abbrechen? '
                          'Der Fortschritt wird nicht gespeichert.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Zurück'),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<TrainingCubit>().cancelTraining();
                              Navigator.pop(dialogContext);
                              Navigator.pop(context);
                            },
                            child: const Text('Abbrechen'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Abbrechen'),
                ),
              ],
            ),
            body: TrainingExercisesList(session: state.session),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {
                    context.read<TrainingCubit>().completeTraining();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Training abschließen'),
                ),
              ),
            ),
          );
        }

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class TrainingExercisesList extends StatelessWidget {
  final TrainingHistoryModel session;

  const TrainingExercisesList({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: session.exercises.length,
      itemBuilder: (context, index) {
        final exercise = session.exercises[index];
        return ExerciseCard(
          exercise: exercise,
          exerciseIndex: index,
        );
      },
    );
  }
}

class ExerciseCard extends StatelessWidget {
  final TrainingExercise exercise;
  final int exerciseIndex;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.exerciseIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.exerciseName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            ...exercise.sets.asMap().entries.map((entry) {
              final setIndex = entry.key;
              final set = entry.value;
              return SetRow(
                set: set,
                exerciseIndex: exerciseIndex,
                setIndex: setIndex,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class SetRow extends StatefulWidget {
  final TrainingSet set;
  final int exerciseIndex;
  final int setIndex;

  const SetRow({
    super.key,
    required this.set,
    required this.exerciseIndex,
    required this.setIndex,
  });

  @override
  State<SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<SetRow> {
  late TextEditingController _repsController;
  late TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _repsController = TextEditingController(text: widget.set.reps.toString());
    _weightController = TextEditingController(text: widget.set.weight.toString());
  }

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              'Satz ${widget.set.setNumber}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _repsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Wdh.',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) {
                final reps = int.tryParse(value);
                if (reps != null) {
                  context.read<TrainingCubit>().updateSet(
                        exerciseIndex: widget.exerciseIndex,
                        setIndex: widget.setIndex,
                        reps: reps,
                      );
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'kg',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) {
                final weight = double.tryParse(value);
                if (weight != null) {
                  context.read<TrainingCubit>().updateSet(
                        exerciseIndex: widget.exerciseIndex,
                        setIndex: widget.setIndex,
                        weight: weight,
                      );
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Checkbox(
            value: widget.set.completed,
            onChanged: (value) {
              context.read<TrainingCubit>().updateSet(
                    exerciseIndex: widget.exerciseIndex,
                    setIndex: widget.setIndex,
                    completed: value ?? false,
                  );
            },
          ),
        ],
      ),
    );
  }
}
