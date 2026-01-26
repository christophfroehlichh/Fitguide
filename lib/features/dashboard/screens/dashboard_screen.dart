import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../logbook/diary/cubit/diary_cubit.dart';
import '../../logbook/diary/cubit/diary_state.dart';
import '../../logbook/diary/models/diary_entry_model.dart';
import '../widgets/section_title.dart';
import '../widgets/streak_display.dart';
import '../widgets/weight_card.dart';
import '../widgets/macro_overview.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            // Extrahiere User-Daten wenn authenticated
            final user = authState is Authenticated ? authState.user : null;
            final hasData = user?.hasCompletedOnboarding ?? false;

            if (user == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return BlocProvider(
              create: (context) => DiaryCubit(userId: user.uid),
              child: BlocBuilder<DiaryCubit, DiaryState>(
                builder: (context, diaryState) {
                  final List<DiaryEntryModel> diaryEntries =
                      diaryState is DiaryLoaded
                      ? diaryState.entries
                      : <DiaryEntryModel>[];

                  final weightHistory = diaryEntries
                      .map(
                        (entry) => WeightDataPoint(
                          date: entry.date,
                          weight: entry.weight,
                        ),
                      )
                      .toList();

                  final sortedEntries = List<DiaryEntryModel>.from(diaryEntries)
                    ..sort((a, b) => b.date.compareTo(a.date));
                  final currentWeight =
                      sortedEntries.isNotEmpty ? sortedEntries.first.weight : user.weight;

                  return _buildDashboardContent(
                    context,
                    user,
                    hasData,
                    weightHistory,
                    diaryEntries,
                    currentWeight,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    user,
    bool hasData,
    List<WeightDataPoint> weightHistory,
    List<DiaryEntryModel> diaryEntries,
    double? currentWeight,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Streak'),
          const SizedBox(height: 12),
          StreakDisplay(diaryEntries: diaryEntries),
          const SizedBox(height: 28),
          const SectionTitle('Gewicht'),
          const SizedBox(height: 12),
          WeightCard(currentWeight: currentWeight, weightHistory: weightHistory),
          const SizedBox(height: 28),
          const SectionTitle('Makronährstoffe'),
          const SizedBox(height: 12),
          if (hasData)
            MacroOverview(
              calories: user!.dailyCalories ?? 0,
              protein: user.dailyProtein ?? 0,
              carbs: user.dailyCarbs ?? 0,
              fats: user.dailyFats ?? 0,
            )
          else
            // Fallback wenn kein Onboarding abgeschlossen
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    'Bitte schließe das Onboarding ab, um deine Makros zu sehen',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
