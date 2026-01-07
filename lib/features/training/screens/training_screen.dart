import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../training_planner/plan_builder/cubit/workout_cubit.dart';
import '../../training_planner/plan_builder/cubit/workout_state.dart';
import '../../training_planner/exercise_pool/cubit/exercise_cubit.dart';
import '../../training_planner/exercise_pool/cubit/exercise_state.dart';
import '../../training_planner/exercise_pool/models/exercise_model.dart';
import '../../training_planner/plan_builder/models/workout_model.dart';
import '../cubit/training_cubit.dart';
import 'training_execution_screen.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return const Scaffold(
            body: Center(child: Text('Nicht angemeldet')),
          );
        }

        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => WorkoutCubit(userId: authState.user.uid),
            ),
            BlocProvider(
              create: (context) => ExerciseCubit(userId: authState.user.uid),
            ),
            BlocProvider(
              create: (context) => TrainingCubit(userId: authState.user.uid),
            ),
          ],
          child: const TrainingView(),
        );
      },
    );
  }
}

class TrainingView extends StatelessWidget {
  const TrainingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Training'),
      ),
      body: BlocBuilder<WorkoutCubit, WorkoutState>(
        builder: (context, state) {
          if (state is WorkoutLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WorkoutError) {
            return Center(
              child: Text(
                state.message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            );
          }

          if (state is WorkoutLoaded) {
            final activeWorkouts = state.workouts.where((w) => w.isActive).toList();

            if (activeWorkouts.isEmpty) {
              return Center(
                child: Text(
                  'Keine aktiven Trainingspläne vorhanden',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            return ActiveWorkoutsList(workouts: activeWorkouts);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class ActiveWorkoutsList extends StatefulWidget {
  final List<WorkoutModel> workouts;

  const ActiveWorkoutsList({super.key, required this.workouts});

  @override
  State<ActiveWorkoutsList> createState() => _ActiveWorkoutsListState();
}

class _ActiveWorkoutsListState extends State<ActiveWorkoutsList> {
  String? _expandedWorkoutId;
  String? _expandedExerciseId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseCubit, ExerciseState>(
      builder: (context, exerciseState) {
        final exercises = exerciseState is ExerciseLoaded
            ? exerciseState.exercises
            : <ExerciseModel>[];

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: widget.workouts.length,
          itemBuilder: (context, index) {
            final workout = widget.workouts[index];
            final isExpanded = _expandedWorkoutId == workout.id;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      workout.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('${workout.exercises.length} Übungen'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MultiBlocProvider(
                                  providers: [
                                    BlocProvider.value(value: context.read<TrainingCubit>()),
                                    BlocProvider.value(value: context.read<ExerciseCubit>()),
                                  ],
                                  child: TrainingExecutionScreen(
                                    workout: workout,
                                    exercises: exercises,
                                  ),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.play_arrow, size: 20),
                          label: const Text('Starten'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                          ),
                          onPressed: () {
                            setState(() {
                              _expandedWorkoutId = isExpanded ? null : workout.id;
                              _expandedExerciseId = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  if (isExpanded && workout.exercises.isNotEmpty)
                    ...workout.exercises.map((workoutExercise) {
                      final exercise = exercises.firstWhere(
                        (e) => e.id == workoutExercise.exerciseId,
                        orElse: () => ExerciseModel(
                          id: workoutExercise.exerciseId,
                          name: 'Unbekannte Übung',
                          category: '',
                          iconUrl: '',
                        ),
                      );

                      final isExerciseExpanded = _expandedExerciseId == workoutExercise.exerciseId;

                      return Column(
                        children: [
                          const Divider(height: 1),
                          ListTile(
                            contentPadding: const EdgeInsets.only(left: 32, right: 16),
                            title: Text(exercise.name),
                            trailing: Icon(
                              isExerciseExpanded ? Icons.expand_less : Icons.expand_more,
                              size: 20,
                            ),
                            onTap: () {
                              setState(() {
                                _expandedExerciseId = isExerciseExpanded
                                    ? null
                                    : workoutExercise.exerciseId;
                              });
                            },
                          ),
                          if (isExerciseExpanded)
                            Padding(
                              padding: const EdgeInsets.only(left: 48, right: 16, bottom: 12),
                              child: Column(
                                children: [
                                  _DetailRow(
                                    label: 'Sätze',
                                    value: workoutExercise.sets.toString(),
                                  ),
                                  const SizedBox(height: 8),
                                  _DetailRow(
                                    label: 'Wiederholungen',
                                    value: workoutExercise.reps.toString(),
                                  ),
                                  const SizedBox(height: 8),
                                  _DetailRow(
                                    label: 'Gewicht',
                                    value: '${workoutExercise.weight} kg',
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    }),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
