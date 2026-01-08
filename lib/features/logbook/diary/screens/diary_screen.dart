import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import '../cubit/diary_cubit.dart';
import '../cubit/diary_state.dart';
import '../models/diary_entry_model.dart';
import 'diary_form_screen.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

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
          create: (context) => DiaryCubit(userId: authState.user.uid),
          child: DiaryView(user: authState.user),
        );
      },
    );
  }
}

class DiaryView extends StatelessWidget {
  final dynamic user;

  const DiaryView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tagebuch'),
      ),
      body: BlocBuilder<DiaryCubit, DiaryState>(
        builder: (context, state) {
          if (state is DiaryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DiaryError) {
            return Center(
              child: Text(
                state.message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            );
          }

          if (state is DiaryLoaded) {
            if (state.entries.isEmpty) {
              return Center(
                child: Text(
                  'Keine Einträge vorhanden',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.entries.length,
              itemBuilder: (context, index) {
                final entry = state.entries[index];
                return DiaryEntryCard(
                  entry: entry,
                  dailyCalories: user.dailyCalories,
                  dailyProtein: user.dailyProtein,
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final state = context.read<DiaryCubit>().state;
          DiaryEntryModel? todayEntry;

          if (state is DiaryLoaded) {
            final today = DateTime.now();
            final todayId = 'diary_${DateFormat('yyyyMMdd').format(today)}';

            todayEntry = state.entries.firstWhere(
              (entry) => entry.id == todayId,
              orElse: () => state.entries.firstWhere(
                (entry) =>
                    entry.date.year == today.year &&
                    entry.date.month == today.month &&
                    entry.date.day == today.day,
                orElse: () => DiaryEntryModel(
                  id: '',
                  date: DateTime.now(),
                  weight: 0,
                  caloriesReached: false,
                  proteinReached: false,
                  caloriesConsumed: 0,
                  proteinConsumed: 0,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              ),
            );

            if (todayEntry.id.isEmpty) {
              todayEntry = null;
            }
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<DiaryCubit>(),
                child: DiaryFormScreen(
                  entry: todayEntry,
                  dailyCalories: user.dailyCalories,
                  dailyProtein: user.dailyProtein,
                  userGoal: user.goal ?? 'Halten',
                ),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DiaryEntryCard extends StatelessWidget {
  final DiaryEntryModel entry;
  final int dailyCalories;
  final int dailyProtein;

  const DiaryEntryCard({
    super.key,
    required this.entry,
    required this.dailyCalories,
    required this.dailyProtein,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(entry.date),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => BlocProvider.value(
      value: context.read<DiaryCubit>(),
      child: DiaryFormScreen(
        entry: entry,
        dailyCalories: dailyCalories,
        dailyProtein: dailyProtein,
        userGoal: context.read<AuthCubit>().state is Authenticated
            ? (context.read<AuthCubit>().state as Authenticated).user.goal ?? 'gewichtHalten'
            : 'gewichtHalten',
      ),
    ),
  ),
);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DataRow(
              label: 'Gewicht',
              value: '${entry.weight} kg',
            ),
            const SizedBox(height: 8),
            _DataRow(
              label: 'Kalorien',
              value: '${entry.caloriesConsumed} / $dailyCalories kcal',
              status: entry.caloriesReached,
            ),
            const SizedBox(height: 8),
            _DataRow(
              label: 'Protein',
              value: '${entry.proteinConsumed} / $dailyProtein g',
              status: entry.proteinReached,
            ),
            if (entry.notes != null && entry.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                entry.notes!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  final bool? status;

  const _DataRow({
    required this.label,
    required this.value,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Row(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (status != null) ...[
              const SizedBox(width: 8),
              Icon(
                status! ? Icons.check_circle : Icons.cancel,
                size: 20,
                color: status!
                    ? Colors.green
                    : Theme.of(context).colorScheme.error,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
