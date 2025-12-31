import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../widgets/section_title.dart';
import '../widgets/calendar_strip.dart';
import '../widgets/weight_card.dart';
import '../widgets/macro_overview.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            // Extrahiere User-Daten wenn authenticated
            final user = state is Authenticated ? state.user : null;
            final hasData = user?.hasCompletedOnboarding ?? false;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Kalender'),
                  const SizedBox(height: 12),
                  const CalendarStrip(
                    moods: ['🤩', '🤩', '🤩', '😢', '😢', '😁', '😁'],
                  ),
                  const SizedBox(height: 28),
                  const SectionTitle('Gewicht'),
                  const SizedBox(height: 12),
                  WeightCard(
                    currentWeight: user?.weight,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SectionTitle('Makronährstoffe'),
                      TextButton(
                        onPressed: hasData ? () {} : null,
                        child: const Text('Anpassen'),
                      ),
                    ],
                  ),
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
          },
        ),
      ),
    );
  }
}
