import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../training_planner/plan_builder/models/workout_model.dart';
import '../../training_planner/exercise_pool/models/exercise_model.dart';
import '../models/training_history_model.dart';
import 'training_state.dart';

class TrainingCubit extends Cubit<TrainingState> {
  final FirebaseFirestore _firestore;
  final String userId;

  TrainingCubit({
    required this.userId,
    FirebaseFirestore? firestore,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        super(TrainingInitial());

  Future<void> startTraining({
    required WorkoutModel workout,
    required List<ExerciseModel> exercises,
  }) async {
    try {
      final sessionId = _firestore
          .collection('users')
          .doc(userId)
          .collection('training_history')
          .doc()
          .id;

      final trainingExercises = workout.exercises.map((workoutEx) {
        final exercise = exercises.firstWhere(
          (e) => e.id == workoutEx.exerciseId,
          orElse: () => ExerciseModel(
            id: workoutEx.exerciseId,
            name: 'Unbekannte Übung',
            category: '',
            iconUrl: '',
          ),
        );

        final sets = List.generate(
          workoutEx.sets,
          (index) => TrainingSet(
            setNumber: index + 1,
            reps: workoutEx.reps,
            weight: workoutEx.weight,
            completed: false,
          ),
        );

        return TrainingExercise(
          exerciseId: workoutEx.exerciseId,
          exerciseName: exercise.name,
          sets: sets,
        );
      }).toList();

      final session = TrainingHistoryModel(
        id: sessionId,
        workoutId: workout.id,
        workoutName: workout.name,
        startedAt: DateTime.now(),
        completedAt: null,
        exercises: trainingExercises,
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('training_history')
          .doc(sessionId)
          .set(session.toMap());

      emit(TrainingInProgress(session: session));
    } catch (e) {
      emit(TrainingError('Fehler beim Starten des Trainings: $e'));
    }
  }

  void updateSet({
    required int exerciseIndex,
    required int setIndex,
    int? reps,
    double? weight,
    bool? completed,
  }) {
    final currentState = state;
    if (currentState is! TrainingInProgress) return;

    final exercise = currentState.session.exercises[exerciseIndex];
    final set = exercise.sets[setIndex];

    final updatedSet = set.copyWith(
      reps: reps,
      weight: weight,
      completed: completed,
    );

    final updatedSets = List<TrainingSet>.from(exercise.sets);
    updatedSets[setIndex] = updatedSet;

    final updatedExercise = exercise.copyWith(sets: updatedSets);
    final updatedExercises = List<TrainingExercise>.from(currentState.session.exercises);
    updatedExercises[exerciseIndex] = updatedExercise;

    final updatedSession = currentState.session.copyWith(exercises: updatedExercises);

    emit(TrainingInProgress(session: updatedSession));
  }

  Future<void> completeTraining() async {
    try {
      final currentState = state;
      if (currentState is! TrainingInProgress) return;

      final completedSession = currentState.session.copyWith(
        completedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('training_history')
          .doc(completedSession.id)
          .set(completedSession.toMap());

      emit(TrainingCompleted(session: completedSession));
    } catch (e) {
      emit(TrainingError('Fehler beim Abschließen des Trainings: $e'));
    }
  }

  void cancelTraining() {
    emit(TrainingInitial());
  }
}
