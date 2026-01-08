import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry_model.dart';
import 'diary_state.dart';

class DiaryCubit extends Cubit<DiaryState> {
  final FirebaseFirestore _firestore;
  final String userId;
  StreamSubscription<QuerySnapshot>? _entriesSubscription;

  DiaryCubit({
    required this.userId,
    FirebaseFirestore? firestore,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        super(DiaryInitial()) {
    _loadEntries();
  }

  void _loadEntries() {
    emit(DiaryLoading());

    _entriesSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('diary_entries')
        .orderBy('date', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            final entries = snapshot.docs
                .map((doc) => DiaryEntryModel.fromMap(doc.data()))
                .toList();
            emit(DiaryLoaded(entries: entries));
          },
          onError: (error) {
            emit(DiaryError('Fehler beim Laden der Einträge: $error'));
          },
        );
  }

  Future<void> createEntry({
    required DateTime date,
    required double weight,
    required int caloriesConsumed,
    required int proteinConsumed,
    required int dailyCalories,
    required int dailyProtein,
    required String userGoal,
    String? notes,
  }) async {
    try {
      final entryId = 'diary_${DateFormat('yyyyMMdd').format(date)}';

      final caloriesReached = _calculateCaloriesReached(
        caloriesConsumed,
        dailyCalories,
        userGoal,
      );

      final proteinReached = _calculateProteinReached(
        proteinConsumed,
        dailyProtein,
        userGoal,
      );

      final now = DateTime.now();
      final entry = DiaryEntryModel(
        id: entryId,
        date: date,
        weight: weight,
        photoUrl: null,
        caloriesReached: caloriesReached,
        proteinReached: proteinReached,
        caloriesConsumed: caloriesConsumed,
        proteinConsumed: proteinConsumed,
        notes: notes,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('diary_entries')
          .doc(entryId)
          .set(entry.toMap());
    } catch (e) {
      emit(DiaryError('Fehler beim Erstellen des Eintrags: $e'));
    }
  }

  Future<void> updateEntry({
    required DiaryEntryModel entry,
    DateTime? date,
    double? weight,
    int? caloriesConsumed,
    int? proteinConsumed,
    required int dailyCalories,
    required int dailyProtein,
    required String userGoal,
    String? notes,
  }) async {
    try {
      final newCalories = caloriesConsumed ?? entry.caloriesConsumed;
      final newProtein = proteinConsumed ?? entry.proteinConsumed;

      final caloriesReached = _calculateCaloriesReached(
        newCalories,
        dailyCalories,
        userGoal,
      );

      final proteinReached = _calculateProteinReached(
        newProtein,
        dailyProtein,
        userGoal,
      );

      final updatedEntry = entry.copyWith(
        date: date,
        weight: weight,
        caloriesConsumed: caloriesConsumed,
        proteinConsumed: proteinConsumed,
        caloriesReached: caloriesReached,
        proteinReached: proteinReached,
        notes: notes,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('diary_entries')
          .doc(updatedEntry.id)
          .update(updatedEntry.toMap());
    } catch (e) {
      emit(DiaryError('Fehler beim Aktualisieren des Eintrags: $e'));
    }
  }

  Future<void> deleteEntry(String entryId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('diary_entries')
          .doc(entryId)
          .delete();
    } catch (e) {
      emit(DiaryError('Fehler beim Löschen des Eintrags: $e'));
    }
  }

  bool _calculateCaloriesReached(int consumed, int goal, String userGoal) {
    switch (userGoal) {
      case 'Muskelaufbau':
        return consumed >= goal * 0.9 && consumed <= goal * 1.2;
      case 'Halten':
        return consumed >= goal * 0.85 && consumed <= goal * 1.15;
      case 'Abnehmen':
        return consumed >= goal * 0.8 && consumed <= goal * 1.05;
      default:
        return false;
    }
  }

  bool _calculateProteinReached(int consumed, int goal, String userGoal) {
    switch (userGoal) {
      case 'Muskelaufbau':
        return consumed >= goal * 0.9;
      case 'Halten':
        return consumed >= goal * 0.85 && consumed <= goal * 1.15;
      case 'Abnehmen':
        return consumed >= goal * 0.9 && consumed <= goal * 1.2;
      default:
        return false;
    }
  }

  @override
  Future<void> close() {
    _entriesSubscription?.cancel();
    return super.close();
  }
}
