import 'package:equatable/equatable.dart';
import '../models/training_history_model.dart';

abstract class TrainingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TrainingInitial extends TrainingState {}

class TrainingInProgress extends TrainingState {
  final TrainingHistoryModel session;

  TrainingInProgress({required this.session});

  @override
  List<Object?> get props => [session];
}

class TrainingCompleted extends TrainingState {
  final TrainingHistoryModel session;

  TrainingCompleted({required this.session});

  @override
  List<Object?> get props => [session];
}

class TrainingError extends TrainingState {
  final String message;

  TrainingError(this.message);

  @override
  List<Object?> get props => [message];
}
