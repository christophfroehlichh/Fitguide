import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../exercise_pool/models/exercise_model.dart';
import '../../exercise_pool/cubit/exercise_cubit.dart';
import '../../exercise_pool/cubit/exercise_state.dart';
import '../models/workout_model.dart';
import '../cubit/workout_cubit.dart';
import 'exercise_picker_screen.dart';

class WorkoutFormScreen extends StatefulWidget {
  final WorkoutModel? workout;

  const WorkoutFormScreen({super.key, this.workout});

  @override
  State<WorkoutFormScreen> createState() => _WorkoutFormScreenState();
}

class _WorkoutFormScreenState extends State<WorkoutFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late bool _isActive;
  late List<WorkoutExercise> _exercises;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.workout?.name ?? '');
    _isActive = widget.workout?.isActive ?? false;
    _exercises = List.from(widget.workout?.exercises ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get isEditing => widget.workout != null;

  Future<void> _saveWorkout() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<WorkoutCubit>();

    if (isEditing) {
      await cubit.updateWorkout(
        widget.workout!.copyWith(
          name: _nameController.text.trim(),
          isActive: _isActive,
          exercises: _exercises,
        ),
      );
    } else {
      await cubit.createWorkout(
        name: _nameController.text.trim(),
        isActive: _isActive,
        exercises: _exercises,
      );
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _deleteWorkout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Workout löschen'),
        content: const Text('Möchtest du dieses Workout wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<WorkoutCubit>().deleteWorkout(widget.workout!.id);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _addExercise() async {
    final result = await Navigator.push<WorkoutExercise>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ExerciseCubit>(),
          child: const ExercisePickerScreen(),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _exercises.add(result);
      });
    }
  }

  Future<void> _editExercise(int index) async {
    final exercise = _exercises[index];
    final exerciseState = context.read<ExerciseCubit>().state;

    if (exerciseState is! ExerciseLoaded) return;

    final exerciseModel = exerciseState.exercises.firstWhere(
      (e) => e.id == exercise.exerciseId,
      orElse: () => ExerciseModel(
        id: exercise.exerciseId,
        name: 'Unbekannte Übung',
        category: '',
        iconUrl: '',
      ),
    );

    final result = await _showExerciseDetailsDialog(
      exerciseModel: exerciseModel,
      initialSets: exercise.sets,
      initialReps: exercise.reps,
      initialWeight: exercise.weight,
    );

    if (result != null) {
      setState(() {
        _exercises[index] = result;
      });
    }
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  Future<WorkoutExercise?> _showExerciseDetailsDialog({
    required ExerciseModel exerciseModel,
    int? initialSets,
    int? initialReps,
    double? initialWeight,
  }) async {
    final setsController = TextEditingController(text: initialSets?.toString() ?? '');
    final repsController = TextEditingController(text: initialReps?.toString() ?? '');
    final weightController = TextEditingController(text: initialWeight?.toString() ?? '');

    return showDialog<WorkoutExercise>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exerciseModel.name),
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
                    exerciseId: exerciseModel.id,
                    sets: sets,
                    reps: reps,
                    weight: weight,
                  ),
                );
              }
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Workout bearbeiten' : 'Workout erstellen'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteWorkout,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Bitte gib einen Namen ein';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Aktiv'),
              subtitle: const Text('Wird im Training-Screen angezeigt'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Übungen',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  onPressed: _addExercise,
                  icon: const Icon(Icons.add),
                  label: const Text('Übungen hinzufügen'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_exercises.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Keine Übungen hinzugefügt',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
              )
            else
              BlocBuilder<ExerciseCubit, ExerciseState>(
                builder: (context, state) {
                  final exercises = state is ExerciseLoaded ? state.exercises : <ExerciseModel>[];

                  return Column(
                    children: _exercises.asMap().entries.map((entry) {
                      final index = entry.key;
                      final workoutExercise = entry.value;

                      final exercise = exercises.firstWhere(
                        (e) => e.id == workoutExercise.exerciseId,
                        orElse: () => ExerciseModel(
                          id: workoutExercise.exerciseId,
                          name: 'Unbekannte Übung',
                          category: '',
                          iconUrl: '',
                        ),
                      );

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(exercise.name),
                          subtitle: Text(
                            '${workoutExercise.sets} Sätze × ${workoutExercise.reps} Wdh. @ ${workoutExercise.weight} kg',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _editExercise(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _removeExercise(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveWorkout,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(isEditing ? 'Speichern' : 'Erstellen'),
            ),
          ],
        ),
      ),
    );
  }
}
