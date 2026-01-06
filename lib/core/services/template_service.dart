import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/training_planner/exercise_pool/models/exercise_model.dart';
import '../../features/training_planner/plan_builder/models/workout_model.dart';

class TemplateService {
  final FirebaseFirestore _firestore;

  TemplateService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> initializeUserTemplates(
    String userId,
    int trainingFrequency,
  ) async {
    try {
      final exercises = await _fetchTemplateExercises();
      final workouts = await _fetchTemplateWorkouts();

      await _copyExercisesToUser(userId, exercises);
      await _copyWorkoutsToUser(userId, workouts, trainingFrequency);
    } catch (e) {
      throw Exception('Template-Initialisierung fehlgeschlagen: $e');
    }
  }

  Future<List<ExerciseModel>> _fetchTemplateExercises() async {
    final snapshot = await _firestore.collection('template_exercises').get();
    return snapshot.docs
        .map((doc) => ExerciseModel.fromMap(doc.data()))
        .toList();
  }

  Future<List<WorkoutModel>> _fetchTemplateWorkouts() async {
    final snapshot = await _firestore.collection('template_workouts').get();
    return snapshot.docs
        .map((doc) => WorkoutModel.fromTemplate(doc.data()))
        .toList();
  }

  Future<void> _copyExercisesToUser(
    String userId,
    List<ExerciseModel> exercises,
  ) async {
    final batch = _firestore.batch();
    final userExercisesRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('exercises');

    for (final exercise in exercises) {
      final docRef = userExercisesRef.doc(exercise.id);
      final userExercise = ExerciseModel(
        id: exercise.id,
        name: exercise.name,
        category: exercise.category,
        iconUrl: exercise.iconUrl,
        templateId: exercise.id,
      );
      batch.set(docRef, userExercise.toMap());
    }

    await batch.commit();
  }

  Future<void> _copyWorkoutsToUser(
    String userId,
    List<WorkoutModel> workouts,
    int trainingFrequency,
  ) async {
    final batch = _firestore.batch();
    final userWorkoutsRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts');

    for (final workout in workouts) {
      final docRef = userWorkoutsRef.doc(workout.id);
      final isActive = _shouldActivateWorkout(workout.name, trainingFrequency);
      final now = DateTime.now();

      final userWorkout = WorkoutModel(
        id: workout.id,
        name: workout.name,
        isActive: isActive,
        exercises: workout.exercises,
        templateId: workout.id,
        createdAt: now,
        updatedAt: now,
      );

      batch.set(docRef, userWorkout.toMap());
    }

    await batch.commit();
  }

  bool _shouldActivateWorkout(String workoutName, int trainingFrequency) {
    final frequency = _extractFrequencyFromName(workoutName);

    if (frequency != null) {
      return frequency == trainingFrequency;
    }

    final isPPLSplit = workoutName.toLowerCase().contains('push') ||
        workoutName.toLowerCase().contains('pull') ||
        workoutName.toLowerCase().contains('legs');

    if (isPPLSplit) {
      return trainingFrequency >= 3;
    }

    return false;
  }

  int? _extractFrequencyFromName(String workoutName) {
    final regex = RegExp(r'(\d+)x/woche', caseSensitive: false);
    final match = regex.firstMatch(workoutName);

    if (match != null) {
      return int.tryParse(match.group(1)!);
    }

    return null;
  }
}
