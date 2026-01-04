import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../exercise_pool/cubit/exercise_cubit.dart';
import '../../exercise_pool/cubit/exercise_state.dart';
import '../../exercise_pool/models/exercise_model.dart';
import '../models/workout_model.dart';

class ExercisePickerScreen extends StatelessWidget {
  const ExercisePickerScreen({super.key});

  Future<WorkoutExercise?> _showExerciseDetailsDialog(
    BuildContext context,
    ExerciseModel exercise,
  ) async {
    final setsController = TextEditingController();
    final repsController = TextEditingController();
    final weightController = TextEditingController();

    return showDialog<WorkoutExercise>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exercise.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: setsController,
              decoration: const InputDecoration(
                labelText: 'Sätze',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: repsController,
              decoration: const InputDecoration(
                labelText: 'Wiederholungen',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: weightController,
              decoration: const InputDecoration(
                labelText: 'Gewicht (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              final sets = int.tryParse(setsController.text);
              final reps = int.tryParse(repsController.text);
              final weight = double.tryParse(weightController.text);

              if (sets != null && reps != null && weight != null) {
                Navigator.pop(
                  context,
                  WorkoutExercise(
                    exerciseId: exercise.id,
                    sets: sets,
                    reps: reps,
                    weight: weight,
                  ),
                );
              }
            },
            child: const Text('Hinzufügen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Übung auswählen'),
      ),
      body: BlocBuilder<ExerciseCubit, ExerciseState>(
        builder: (context, state) {
          if (state is ExerciseLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ExerciseError) {
            return Center(
              child: Text(
                state.message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            );
          }

          if (state is ExerciseLoaded) {
            if (state.exercises.isEmpty) {
              return Center(
                child: Text(
                  'Keine Übungen vorhanden',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.exercises.length,
              itemBuilder: (context, index) {
                final exercise = state.exercises[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: exercise.iconUrl.isNotEmpty
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(exercise.iconUrl),
                          )
                        : const CircleAvatar(
                            child: Icon(Icons.fitness_center),
                          ),
                    title: Text(exercise.name),
                    subtitle: Text(exercise.category),
                    trailing: const Icon(Icons.add),
                    onTap: () async {
                      final result = await _showExerciseDetailsDialog(context, exercise);
                      if (result != null && context.mounted) {
                        Navigator.pop(context, result);
                      }
                    },
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
