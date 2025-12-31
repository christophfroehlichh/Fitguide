import 'package:equatable/equatable.dart';

class ExerciseModel extends Equatable {
  final String id;
  final String name;
  final String category;
  final String iconUrl;
  final String? templateId;

  const ExerciseModel({
    required this.id,
    required this.name,
    required this.category,
    required this.iconUrl,
    this.templateId,
  });

  @override
  List<Object?> get props => [id, name, category, iconUrl, templateId];

  ExerciseModel copyWith({
    String? id,
    String? name,
    String? category,
    String? iconUrl,
    String? templateId,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      iconUrl: iconUrl ?? this.iconUrl,
      templateId: templateId ?? this.templateId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'iconUrl': iconUrl,
      'templateId': templateId,
    };
  }

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      iconUrl: map['iconUrl'] as String,
      templateId: map['templateId'] as String?,
    );
  }
}
