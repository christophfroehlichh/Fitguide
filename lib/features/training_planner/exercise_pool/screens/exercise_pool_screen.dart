import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import '../cubit/exercise_cubit.dart';
import '../cubit/exercise_state.dart';
import 'exercise_form_screen.dart';

class ExercisePoolScreen extends StatelessWidget {
  const ExercisePoolScreen({super.key});

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
          create: (context) => ExerciseCubit(userId: authState.user.uid),
          child: const ExercisePoolView(),
        );
      },
    );
  }
}

class ExercisePoolView extends StatelessWidget {
  const ExercisePoolView({super.key});

  static const categories = [
    'Alle',
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Arms',
    'Core',
    'Full Body',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Übungen'),
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
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: categories.map((category) {
                        final isSelected = (state.selectedCategory ?? 'Alle') == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (_) {
                              context.read<ExerciseCubit>().filterByCategory(category);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: state.filteredExercises.isEmpty
                      ? Center(
                          child: Text(
                            'Keine Übungen gefunden',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.filteredExercises.length,
                          itemBuilder: (context, index) {
                            final exercise = state.filteredExercises[index];
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
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider.value(
                                          value: context.read<ExerciseCubit>(),
                                          child: ExerciseFormScreen(exercise: exercise),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ExerciseCubit>(),
                child: const ExerciseFormScreen(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
