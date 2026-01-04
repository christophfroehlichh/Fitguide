import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_model.dart';
import 'workout_state.dart';

class WorkoutCubit extends Cubit<WorkoutState> {
  final FirebaseFirestore _firestore;
  final String userId;
  StreamSubscription<QuerySnapshot>? _workoutsSubscription;

  WorkoutCubit({
    required this.userId,
    FirebaseFirestore? firestore,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        super(WorkoutInitial()) {
    _loadWorkouts();
  }

  void _loadWorkouts() {
    try {
      emit(WorkoutLoading());

      _workoutsSubscription?.cancel();
      _workoutsSubscription = _firestore
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .orderBy('name')
          .snapshots()
          .listen(
        (snapshot) {
          final workouts = snapshot.docs
              .map((doc) => WorkoutModel.fromMap(doc.data()))
              .toList();
          emit(WorkoutLoaded(workouts: workouts));
        },
        onError: (error) {
          emit(WorkoutError('Fehler beim Laden der Workouts: $error'));
        },
      );
    } catch (e) {
      emit(WorkoutError('Fehler beim Laden der Workouts: $e'));
    }
  }

  Future<void> createWorkout({
    required String name,
    required bool isActive,
    required List<WorkoutExercise> exercises,
  }) async {
    try {
      final workoutId = _firestore
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .doc()
          .id;

      final now = DateTime.now();
      final workout = WorkoutModel(
        id: workoutId,
        name: name,
        isActive: isActive,
        exercises: exercises,
        templateId: null,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .doc(workoutId)
          .set(workout.toMap());
    } catch (e) {
      emit(WorkoutError('Fehler beim Erstellen des Workouts: $e'));
    }
  }

  Future<void> updateWorkout(WorkoutModel workout) async {
    try {
      final updatedWorkout = workout.copyWith(updatedAt: DateTime.now());

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .doc(workout.id)
          .update(updatedWorkout.toMap());
    } catch (e) {
      emit(WorkoutError('Fehler beim Aktualisieren des Workouts: $e'));
    }
  }

  Future<void> deleteWorkout(String workoutId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .doc(workoutId)
          .delete();
    } catch (e) {
      emit(WorkoutError('Fehler beim Löschen des Workouts: $e'));
    }
  }

  @override
  Future<void> close() {
    _workoutsSubscription?.cancel();
    return super.close();
  }
}
