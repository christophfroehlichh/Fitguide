import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrainingSet extends Equatable {
  final int setNumber;
  final int reps;
  final double weight;
  final bool completed;

  const TrainingSet({
    required this.setNumber,
    required this.reps,
    required this.weight,
    this.completed = false,
  });

  @override
  List<Object?> get props => [setNumber, reps, weight, completed];

  TrainingSet copyWith({
    int? setNumber,
    int? reps,
    double? weight,
    bool? completed,
  }) {
    return TrainingSet(
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'setNumber': setNumber,
      'reps': reps,
      'weight': weight,
      'completed': completed,
    };
  }

  factory TrainingSet.fromMap(Map<String, dynamic> map) {
    return TrainingSet(
      setNumber: map['setNumber'] as int,
      reps: map['reps'] as int,
      weight: (map['weight'] as num).toDouble(),
      completed: map['completed'] as bool? ?? false,
    );
  }
}

class TrainingExercise extends Equatable {
  final String exerciseId;
  final String exerciseName;
  final List<TrainingSet> sets;

  const TrainingExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
  });

  @override
  List<Object?> get props => [exerciseId, exerciseName, sets];

  TrainingExercise copyWith({
    String? exerciseId,
    String? exerciseName,
    List<TrainingSet>? sets,
  }) {
    return TrainingExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      sets: sets ?? this.sets,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'sets': sets.map((s) => s.toMap()).toList(),
    };
  }

  factory TrainingExercise.fromMap(Map<String, dynamic> map) {
    return TrainingExercise(
      exerciseId: map['exerciseId'] as String,
      exerciseName: map['exerciseName'] as String,
      sets: (map['sets'] as List<dynamic>)
          .map((s) => TrainingSet.fromMap(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TrainingHistoryModel extends Equatable {
  final String id;
  final String workoutId;
  final String workoutName;
  final DateTime startedAt;
  final DateTime? completedAt;
  final List<TrainingExercise> exercises;

  const TrainingHistoryModel({
    required this.id,
    required this.workoutId,
    required this.workoutName,
    required this.startedAt,
    this.completedAt,
    required this.exercises,
  });

  @override
  List<Object?> get props => [
        id,
        workoutId,
        workoutName,
        startedAt,
        completedAt,
        exercises,
      ];

  TrainingHistoryModel copyWith({
    String? id,
    String? workoutId,
    String? workoutName,
    DateTime? startedAt,
    DateTime? completedAt,
    List<TrainingExercise>? exercises,
  }) {
    return TrainingHistoryModel(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      workoutName: workoutName ?? this.workoutName,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      exercises: exercises ?? this.exercises,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workoutId': workoutId,
      'workoutName': workoutName,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }

  factory TrainingHistoryModel.fromMap(Map<String, dynamic> map) {
    return TrainingHistoryModel(
      id: map['id'] as String,
      workoutId: map['workoutId'] as String,
      workoutName: map['workoutName'] as String,
      startedAt: (map['startedAt'] as Timestamp).toDate(),
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
      exercises: (map['exercises'] as List<dynamic>)
          .map((e) => TrainingExercise.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
