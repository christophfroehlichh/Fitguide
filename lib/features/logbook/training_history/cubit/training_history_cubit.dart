import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../training/models/training_history_model.dart';
import 'training_history_state.dart';

class TrainingHistoryCubit extends Cubit<TrainingHistoryState> {
  final FirebaseFirestore _firestore;
  final String userId;
  StreamSubscription? _historySubscription;

  TrainingHistoryCubit({
    required this.userId,
    FirebaseFirestore? firestore,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        super(TrainingHistoryInitial()) {
    _loadHistory();
  }

  void _loadHistory() {
    emit(TrainingHistoryLoading());

    _historySubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('training_history')
        .where('completedAt', isNull: false)
        .orderBy('completedAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            final sessions = snapshot.docs
                .map((doc) => TrainingHistoryModel.fromMap(doc.data()))
                .toList();
            emit(TrainingHistoryLoaded(sessions));
          },
          onError: (error) {
            emit(TrainingHistoryError('Fehler beim Laden: $error'));
          },
        );
  }

  @override
  Future<void> close() {
    _historySubscription?.cancel();
    return super.close();
  }
}
