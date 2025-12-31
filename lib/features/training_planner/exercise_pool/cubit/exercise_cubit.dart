import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exercise_model.dart';
import 'exercise_state.dart';

class ExerciseCubit extends Cubit<ExerciseState> {
  final FirebaseFirestore _firestore;
  final String userId;
  StreamSubscription<QuerySnapshot>? _exercisesSubscription;

  ExerciseCubit({
    required this.userId,
    FirebaseFirestore? firestore,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        super(ExerciseInitial()) {
    _loadExercises();
  }

  void _loadExercises() {
    try {
      emit(ExerciseLoading());

      _exercisesSubscription?.cancel();
      _exercisesSubscription = _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .orderBy('name')
          .snapshots()
          .listen(
        (snapshot) {
          final exercises = snapshot.docs
              .map((doc) => ExerciseModel.fromMap(doc.data()))
              .toList();
          emit(ExerciseLoaded(exercises: exercises));
        },
        onError: (error) {
          emit(ExerciseError('Fehler beim Laden der Übungen: $error'));
        },
      );
    } catch (e) {
      emit(ExerciseError('Fehler beim Laden der Übungen: $e'));
    }
  }

  void filterByCategory(String? category) {
    final currentState = state;
    if (currentState is ExerciseLoaded) {
      emit(ExerciseLoaded(
        exercises: currentState.exercises,
        selectedCategory: category,
      ));
    }
  }

  Future<void> createExercise({
    required String name,
    required String category,
    String? iconUrl,
  }) async {
    try {
      final exerciseId = _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc()
          .id;

      final exercise = ExerciseModel(
        id: exerciseId,
        name: name,
        category: category,
        iconUrl: iconUrl ?? '',
        templateId: null,
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc(exerciseId)
          .set(exercise.toMap());
    } catch (e) {
      emit(ExerciseError('Fehler beim Erstellen der Übung: $e'));
    }
  }

  Future<void> updateExercise(ExerciseModel exercise) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc(exercise.id)
          .update(exercise.toMap());
    } catch (e) {
      emit(ExerciseError('Fehler beim Aktualisieren der Übung: $e'));
    }
  }

  Future<void> deleteExercise(String exerciseId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc(exerciseId)
          .delete();
    } catch (e) {
      emit(ExerciseError('Fehler beim Löschen der Übung: $e'));
    }
  }

  @override
  Future<void> close() {
    _exercisesSubscription?.cancel();
    return super.close();
  }
}
