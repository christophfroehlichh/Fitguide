import 'package:equatable/equatable.dart';
import '../models/exercise_model.dart';

abstract class ExerciseState extends Equatable {
  const ExerciseState();

  @override
  List<Object?> get props => [];
}

class ExerciseInitial extends ExerciseState {}

class ExerciseLoading extends ExerciseState {}

class ExerciseLoaded extends ExerciseState {
  final List<ExerciseModel> exercises;
  final String? selectedCategory;

  const ExerciseLoaded({
    required this.exercises,
    this.selectedCategory,
  });

  @override
  List<Object?> get props => [exercises, selectedCategory];

  List<ExerciseModel> get filteredExercises {
    if (selectedCategory == null || selectedCategory == 'Alle') {
      return exercises;
    }
    return exercises.where((ex) => ex.category == selectedCategory).toList();
  }
}

class ExerciseError extends ExerciseState {
  final String message;

  const ExerciseError(this.message);

  @override
  List<Object?> get props => [message];
}
