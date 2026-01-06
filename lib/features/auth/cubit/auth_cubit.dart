import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/template_service.dart';
import '../models/user_model.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  final FirebaseFirestore _firestore;
  final TemplateService _templateService;
  StreamSubscription<UserModel?>? _userSubscription;

  AuthCubit({
    required AuthService authService,
    FirebaseFirestore? firestore,
    TemplateService? templateService,
  })  : _authService = authService,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _templateService = templateService ?? TemplateService(),
        super(AuthInitial()) {
    _initialize();
  }

  void _initialize() {
    _authService.authStateChanges.listen((firebaseUser) {
      if (firebaseUser == null) {
        emit(Unauthenticated());
        _userSubscription?.cancel();
      } else {
        _loadUserData(firebaseUser.uid);
      }
    });
  }

  Future<void> _loadUserData(String uid) async {
    try {
      emit(AuthLoading());

      _userSubscription?.cancel();
      _userSubscription = _firestore
          .collection('users')
          .doc(uid)
          .snapshots()
          .map((doc) {
            if (doc.exists) {
              return UserModel.fromMap(doc.data()!);
            }
            return null;
          })
          .listen(
            (user) {
              if (user != null) {
                emit(Authenticated(user));
              } else {
                emit(const AuthError('Benutzerdaten nicht gefunden'));
              }
            },
            onError: (error) {
              emit(AuthError('Fehler beim Laden der Benutzerdaten: $error'));
            },
          );
    } catch (e) {
      emit(AuthError('Fehler beim Laden der Benutzerdaten: $e'));
    }
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      emit(AuthLoading());

      final userCredential = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel.initial(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
      );

      await _firestore.collection('users').doc(user.uid).set(user.toMap());

    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      emit(AuthLoading());

      final userCredential = await _authService.signInWithGoogle();
      final firebaseUser = userCredential.user!;

      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        final user = UserModel.initial(
          uid: firebaseUser.uid,
          email: firebaseUser.email!,
          name: firebaseUser.displayName ?? '',
        );

        await _firestore.collection('users').doc(user.uid).set(user.toMap());
      }

    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> updateUserProfile(UserModel updatedUser) async {
    try {
      final currentState = state;
      if (currentState is! Authenticated) return;

      await _firestore
          .collection('users')
          .doc(updatedUser.uid)
          .update(updatedUser.copyWith(updatedAt: DateTime.now()).toMap());

    } catch (e) {
      emit(AuthError('Fehler beim Aktualisieren des Profils: $e'));
    }
  }

  Future<void> completeOnboarding({
    required String name,
    required int age,
    required double height,
    required double weight,
    required String goal,
    required String activityLevel,
    required int trainingFrequency,
    required int trainingDuration,
  }) async {
    try {
      final currentState = state;
      if (currentState is! Authenticated) return;

      final calories = _calculateDailyCalories(
        age: age,
        weight: weight,
        height: height,
        activityLevel: activityLevel,
        goal: goal,
      );

      final macros = _calculateMacros(calories, goal);

      final updatedUser = currentState.user.copyWith(
        name: name,
        age: age,
        height: height,
        weight: weight,
        goal: goal,
        activityLevel: activityLevel,
        trainingFrequency: trainingFrequency,
        trainingDuration: trainingDuration,
        dailyCalories: calories,
        dailyProtein: macros['protein'],
        dailyCarbs: macros['carbs'],
        dailyFats: macros['fats'],
        hasCompletedOnboarding: true,
        updatedAt: DateTime.now(),
      );

      await updateUserProfile(updatedUser);

      try {
        await _templateService.initializeUserTemplates(
          currentState.user.uid,
          trainingFrequency,
        );
      } catch (e) {
        print('Template-Initialisierung fehlgeschlagen: $e');
      }
    } catch (e) {
      emit(AuthError('Fehler beim Abschließen des Onboardings: $e'));
    }
  }

  int _calculateDailyCalories({
    required int age,
    required double weight,
    required double height,
    required String activityLevel,
    required String goal,
  }) {

    final bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;

    final activityMultiplier = switch (activityLevel) {
      'Sedentary' => 1.2,
      'Lightly Active' => 1.375,
      'Moderately Active' => 1.55,
      'Very Active' => 1.725,
      'Extra Active' => 1.9,
      _ => 1.2,
    };

    double tdee = bmr * activityMultiplier;

    // Adjust for goal
    final calories = switch (goal) {
      'Abnehmen' => tdee - 500,
      'Muskelaufbau' => tdee + 300, 
      'Halten' => tdee,
      _ => tdee,
    };

    return calories.round();
  }

  // Calculate macros based on calories and goal
  Map<String, int> _calculateMacros(int calories, String goal) {

    final proteinPercentage = switch (goal) {
      'Muskelaufbau' => 0.35,
      'Abnehmen' => 0.40,
      _ => 0.30,
    };

    final protein = ((calories * proteinPercentage) / 4).round(); 
    final fats = ((calories * 0.25) / 9).round(); 
    final carbs = ((calories - (protein * 4) - (fats * 9)) / 4).round();

    return {
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
    };
  }


  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _userSubscription?.cancel();
    } catch (e) {
      emit(AuthError('Fehler beim Abmelden: $e'));
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
