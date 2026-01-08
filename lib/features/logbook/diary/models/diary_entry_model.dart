import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryEntryModel extends Equatable {
  final String id;
  final DateTime date;
  final double weight;
  final String? photoUrl;
  final bool caloriesReached;
  final bool proteinReached;
  final int caloriesConsumed;
  final int proteinConsumed;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DiaryEntryModel({
    required this.id,
    required this.date,
    required this.weight,
    this.photoUrl,
    required this.caloriesReached,
    required this.proteinReached,
    required this.caloriesConsumed,
    required this.proteinConsumed,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        date,
        weight,
        photoUrl,
        caloriesReached,
        proteinReached,
        caloriesConsumed,
        proteinConsumed,
        notes,
        createdAt,
        updatedAt,
      ];

  DiaryEntryModel copyWith({
    String? id,
    DateTime? date,
    double? weight,
    String? photoUrl,
    bool? caloriesReached,
    bool? proteinReached,
    int? caloriesConsumed,
    int? proteinConsumed,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiaryEntryModel(
      id: id ?? this.id,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      photoUrl: photoUrl ?? this.photoUrl,
      caloriesReached: caloriesReached ?? this.caloriesReached,
      proteinReached: proteinReached ?? this.proteinReached,
      caloriesConsumed: caloriesConsumed ?? this.caloriesConsumed,
      proteinConsumed: proteinConsumed ?? this.proteinConsumed,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': Timestamp.fromDate(date),
      'weight': weight,
      'photoUrl': photoUrl,
      'caloriesReached': caloriesReached,
      'proteinReached': proteinReached,
      'caloriesConsumed': caloriesConsumed,
      'proteinConsumed': proteinConsumed,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory DiaryEntryModel.fromMap(Map<String, dynamic> map) {
    return DiaryEntryModel(
      id: map['id'] as String,
      date: (map['date'] as Timestamp).toDate(),
      weight: (map['weight'] as num).toDouble(),
      photoUrl: map['photoUrl'] as String?,
      caloriesReached: map['caloriesReached'] as bool,
      proteinReached: map['proteinReached'] as bool,
      caloriesConsumed: map['caloriesConsumed'] as int,
      proteinConsumed: map['proteinConsumed'] as int,
      notes: map['notes'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}
