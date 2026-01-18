import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class TemplateSeedScript {
  final FirebaseFirestore _firestore;

  TemplateSeedScript({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> seedTemplates() async {
    try {
      final templatesExist = await _checkTemplatesExist();
      if (templatesExist) {
        return;
      }

      final jsonString = await rootBundle.loadString(
        'data/firebase_templates.json',
      );
      final data = json.decode(jsonString) as Map<String, dynamic>;

      await _seedExercises(data['template_exercises'] as List);
      await _seedWorkouts(data['template_workouts'] as List);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> _checkTemplatesExist() async {
    final exercisesSnapshot = await _firestore
        .collection('template_exercises')
        .limit(1)
        .get();
    return exercisesSnapshot.docs.isNotEmpty;
  }

  Future<void> _seedExercises(List exercisesData) async {
    final batch = _firestore.batch();

    for (final exerciseData in exercisesData) {
      final map = exerciseData as Map<String, dynamic>;
      final docRef = _firestore
          .collection('template_exercises')
          .doc(map['id'] as String);
      batch.set(docRef, map);
    }

    await batch.commit();
  }

  Future<void> _seedWorkouts(List workoutsData) async {
    final batch = _firestore.batch();

    for (final workoutData in workoutsData) {
      final map = workoutData as Map<String, dynamic>;
      final docRef = _firestore
          .collection('template_workouts')
          .doc(map['id'] as String);
      batch.set(docRef, map);
    }

    await batch.commit();
  }
}
