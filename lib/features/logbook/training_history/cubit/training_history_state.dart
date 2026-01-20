import 'package:equatable/equatable.dart';
import '../../../training/models/training_history_model.dart';

abstract class TrainingHistoryState extends Equatable {
  const TrainingHistoryState();

  @override
  List<Object?> get props => [];
}

class TrainingHistoryInitial extends TrainingHistoryState {}

class TrainingHistoryLoading extends TrainingHistoryState {}

class TrainingHistoryLoaded extends TrainingHistoryState {
  final List<TrainingHistoryModel> sessions;

  const TrainingHistoryLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

class TrainingHistoryError extends TrainingHistoryState {
  final String message;

  const TrainingHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
