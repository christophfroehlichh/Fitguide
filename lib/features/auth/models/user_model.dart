import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String name;
  final double? height; 
  final double? weight; 
  final String? goal; 
  final String? activityLevel; 
  final int? trainingFrequency; 
  final int? trainingDuration; 
  final int? dailyCalories; 
  final int? dailyProtein; 
  final int? dailyCarbs; 
  final int? dailyFats; 
  final bool hasCompletedOnboarding;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.height,
    this.weight,
    this.goal,
    this.activityLevel,
    this.trainingFrequency,
    this.trainingDuration,
    this.dailyCalories,
    this.dailyProtein,
    this.dailyCarbs,
    this.dailyFats,
    this.hasCompletedOnboarding = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create empty user for initial registration
  factory UserModel.initial({
    required String uid,
    required String email,
    String name = '',
  }) {
    final now = DateTime.now();
    return UserModel(
      uid: uid,
      email: email,
      name: name,
      createdAt: now,
      updatedAt: now,
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    double? height,
    double? weight,
    String? goal,
    String? activityLevel,
    int? trainingFrequency,
    int? trainingDuration,
    int? dailyCalories,
    int? dailyProtein,
    int? dailyCarbs,
    int? dailyFats,
    bool? hasCompletedOnboarding,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      trainingFrequency: trainingFrequency ?? this.trainingFrequency,
      trainingDuration: trainingDuration ?? this.trainingDuration,
      dailyCalories: dailyCalories ?? this.dailyCalories,
      dailyProtein: dailyProtein ?? this.dailyProtein,
      dailyCarbs: dailyCarbs ?? this.dailyCarbs,
      dailyFats: dailyFats ?? this.dailyFats,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'height': height,
      'weight': weight,
      'goal': goal,
      'activityLevel': activityLevel,
      'trainingFrequency': trainingFrequency,
      'trainingDuration': trainingDuration,
      'dailyCalories': dailyCalories,
      'dailyProtein': dailyProtein,
      'dailyCarbs': dailyCarbs,
      'dailyFats': dailyFats,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // From Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      name: map['name'] as String? ?? '',
      height: map['height']?.toDouble(),
      weight: map['weight']?.toDouble(),
      goal: map['goal'] as String?,
      activityLevel: map['activityLevel'] as String?,
      trainingFrequency: map['trainingFrequency'] as int?,
      trainingDuration: map['trainingDuration'] as int?,
      dailyCalories: map['dailyCalories'] as int?,
      dailyProtein: map['dailyProtein'] as int?,
      dailyCarbs: map['dailyCarbs'] as int?,
      dailyFats: map['dailyFats'] as int?,
      hasCompletedOnboarding: map['hasCompletedOnboarding'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        name,
        height,
        weight,
        goal,
        activityLevel,
        trainingFrequency,
        trainingDuration,
        dailyCalories,
        dailyProtein,
        dailyCarbs,
        dailyFats,
        hasCompletedOnboarding,
        createdAt,
        updatedAt,
      ];
}
