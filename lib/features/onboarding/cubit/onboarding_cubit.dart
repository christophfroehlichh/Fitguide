import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/template_service.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final FirebaseFirestore _firestore;
  final TemplateService _templateService;

  OnboardingCubit({
    FirebaseFirestore? firestore,
    TemplateService? templateService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _templateService = templateService ?? TemplateService(),
       super(OnboardingInitial());

  Future<void> completeOnboarding({
    required String uid,
    required String name,
    required int age,
    required double height,
    required double weight,
    required String goal,
    required String activityLevel,
    required int trainingFrequency,
    required int trainingDuration,
  }) async {
    try {
      emit(OnboardingLoading());

      final calories = OnboardingCubit.calculateDailyCalories(
        age: age,
        weight: weight,
        height: height,
        activityLevel: activityLevel,
        goal: goal,
      );

      final macros = OnboardingCubit.calculateMacros(calories, goal);

      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'age': age,
        'height': height,
        'weight': weight,
        'goal': goal,
        'activityLevel': activityLevel,
        'trainingFrequency': trainingFrequency,
        'trainingDuration': trainingDuration,
        'dailyCalories': calories,
        'dailyProtein': macros['protein'],
        'dailyCarbs': macros['carbs'],
        'dailyFats': macros['fats'],
        'hasCompletedOnboarding': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      try {
        await _templateService.initializeUserTemplates(uid, trainingFrequency);
      } catch (e) {
        //
      }

      emit(OnboardingSuccess());
    } catch (e) {
      emit(OnboardingError('Fehler beim Abschließen des Onboardings: $e'));
    }
  }

  static int calculateDailyCalories({
    required int age,
    required double weight,
    required double height,
    required String activityLevel,
    required String goal,
  }) {
    final bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;

    final activityMultiplier = switch (activityLevel) {
      'Sedentary' => 1.2,
      'Lightly Active' => 1.375,
      'Moderately Active' => 1.55,
      'Very Active' => 1.725,
      'Extra Active' => 1.9,
      _ => 1.2,
    };

    double tdee = bmr * activityMultiplier;

    final calories = switch (goal) {
      'Abnehmen' => tdee - 500,
      'Muskelaufbau' => tdee + 300,
      'Halten' => tdee,
      _ => tdee,
    };

    return calories.round();
  }

  static Map<String, int> calculateMacros(int calories, String goal) {
    final proteinPercentage = switch (goal) {
      'Muskelaufbau' => 0.35,
      'Abnehmen' => 0.40,
      _ => 0.30,
    };

    final protein = ((calories * proteinPercentage) / 4).round();
    final fats = ((calories * 0.25) / 9).round();
    final carbs = ((calories - (protein * 4) - (fats * 9)) / 4).round();

    return {'protein': protein, 'carbs': carbs, 'fats': fats};
  }
}
