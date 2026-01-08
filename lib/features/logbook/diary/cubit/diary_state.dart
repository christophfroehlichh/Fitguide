import 'package:equatable/equatable.dart';
import '../models/diary_entry_model.dart';

abstract class DiaryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DiaryInitial extends DiaryState {}

class DiaryLoading extends DiaryState {}

class DiaryLoaded extends DiaryState {
  final List<DiaryEntryModel> entries;

  DiaryLoaded({required this.entries});

  @override
  List<Object?> get props => [entries];
}

class DiaryError extends DiaryState {
  final String message;

  DiaryError(this.message);

  @override
  List<Object?> get props => [message];
}
