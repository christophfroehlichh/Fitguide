import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import '../../../training/models/training_history_model.dart';
import '../cubit/training_history_cubit.dart';
import '../cubit/training_history_state.dart';

class TrainingHistoryScreen extends StatelessWidget {
  const TrainingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return const Scaffold(
            body: Center(child: Text('Nicht angemeldet')),
          );
        }

        return BlocProvider(
          create: (context) => TrainingHistoryCubit(userId: authState.user.uid),
          child: const TrainingHistoryView(),
        );
      },
    );
  }
}

class TrainingHistoryView extends StatelessWidget {
  const TrainingHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainingshistorie'),
      ),
      body: BlocBuilder<TrainingHistoryCubit, TrainingHistoryState>(
        builder: (context, state) {
          if (state is TrainingHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TrainingHistoryError) {
            return Center(
              child: Text(
                state.message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            );
          }

          if (state is TrainingHistoryLoaded) {
            if (state.sessions.isEmpty) {
              return Center(
                child: Text(
                  'Noch keine abgeschlossenen Trainings',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            return TrainingHistoryList(sessions: state.sessions);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class TrainingHistoryList extends StatefulWidget {
  final List<TrainingHistoryModel> sessions;

  const TrainingHistoryList({super.key, required this.sessions});

  @override
  State<TrainingHistoryList> createState() => _TrainingHistoryListState();
}

class _TrainingHistoryListState extends State<TrainingHistoryList> {
  String? _expandedSessionId;
  String? _expandedExerciseId;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.sessions.length,
      itemBuilder: (context, index) {
        final session = widget.sessions[index];
        final isExpanded = _expandedSessionId == session.id;
        final dateStr = session.completedAt != null
            ? DateFormat('dd.MM.yyyy • HH:mm').format(session.completedAt!)
            : 'Nicht abgeschlossen';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  session.workoutName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(dateStr),
                trailing: IconButton(
                  icon: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  onPressed: () {
                    setState(() {
                      _expandedSessionId = isExpanded ? null : session.id;
                      _expandedExerciseId = null;
                    });
                  },
                ),
              ),
              if (isExpanded && session.exercises.isNotEmpty)
                ...session.exercises.map((exercise) {
                  final completedSets =
                      exercise.sets.where((s) => s.completed).toList();
                  final isExerciseExpanded =
                      _expandedExerciseId == exercise.exerciseId;

                  if (completedSets.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    children: [
                      const Divider(height: 1),
                      ListTile(
                        contentPadding:
                            const EdgeInsets.only(left: 32, right: 16),
                        title: Text(exercise.exerciseName),
                        subtitle: Text('${completedSets.length} Sätze abgeschlossen'),
                        trailing: Icon(
                          isExerciseExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          size: 20,
                        ),
                        onTap: () {
                          setState(() {
                            _expandedExerciseId = isExerciseExpanded
                                ? null
                                : exercise.exerciseId;
                          });
                        },
                      ),
                      if (isExerciseExpanded)
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 48,
                            right: 16,
                            bottom: 12,
                          ),
                          child: Column(
                            children: completedSets.map((set) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Satz ${set.setNumber}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                    Text(
                                      '${set.reps} × ${set.weight} kg',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
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
  }
}
