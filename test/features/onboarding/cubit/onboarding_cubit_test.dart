import 'package:flutter_test/flutter_test.dart';
import 'package:fitguide/features/onboarding/cubit/onboarding_cubit.dart';

void main() {
  test('berechnet Kalorien für 80kg Mann mit Muskelaufbau', () {
    final calories = OnboardingCubit.calculateDailyCalories(
      age: 25,
      weight: 80,
      height: 180,
      activityLevel: 'Moderately Active',
      goal: 'Muskelaufbau',
    );

    expect(calories, 3098);
  });
}
