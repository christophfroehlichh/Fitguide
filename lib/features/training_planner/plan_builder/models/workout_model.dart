import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutExercise extends Equatable {
  final String exerciseId;
  final int sets;
  final int reps;
  final double weight;

  const WorkoutExercise({
    required this.exerciseId,
    required this.sets,
    required this.reps,
    required this.weight,
  });

  @override
  List<Object?> get props => [exerciseId, sets, reps, weight];

  WorkoutExercise copyWith({
    String? exerciseId,
    int? sets,
    int? reps,
    double? weight,
  }) {
    return WorkoutExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'sets': sets,
      'reps': reps,
      'weight': weight,
    };
  }

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      exerciseId: map['exerciseId'] as String,
      sets: map['sets'] as int,
      reps: map['reps'] as int,
      weight: (map['weight'] as num).toDouble(),
    );
  }
}

class WorkoutModel extends Equatable {
  final String id;
  final String name;
  final bool isActive;
  final List<WorkoutExercise> exercises;
  final String? templateId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkoutModel({
    required this.id,
    required this.name,
    required this.isActive,
    required this.exercises,
    this.templateId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, isActive, exercises, templateId, createdAt, updatedAt];

  WorkoutModel copyWith({
    String? id,
    String? name,
    bool? isActive,
    List<WorkoutExercise>? exercises,
    String? templateId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      exercises: exercises ?? this.exercises,
      templateId: templateId ?? this.templateId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'templateId': templateId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory WorkoutModel.fromMap(Map<String, dynamic> map) {
    return WorkoutModel(
      id: map['id'] as String,
      name: map['name'] as String,
      isActive: map['isActive'] as bool,
      exercises: (map['exercises'] as List<dynamic>)
          .map((e) => WorkoutExercise.fromMap(e as Map<String, dynamic>))
          .toList(),
      templateId: map['templateId'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory WorkoutModel.fromTemplate(Map<String, dynamic> map) {
    final now = DateTime.now();
    return WorkoutModel(
      id: map['id'] as String,
      name: map['name'] as String,
      isActive: false,
      exercises: (map['exercises'] as List<dynamic>)
          .map((e) => WorkoutExercise.fromMap(e as Map<String, dynamic>))
          .toList(),
      templateId: null,
      createdAt: now,
      updatedAt: now,
    );
  }
}
