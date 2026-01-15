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
  }) : _authService = authService,
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
      print('1. Emitting AuthLoading');
      emit(AuthLoading());
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('2. Login successful');
    } catch (e) {
      print('3. Login failed: $e');
      print('4. Emitting AuthError');
      emit(AuthError('E-Mail oder Passwort nicht korrekt')); // KEIN const!
    }
  }

  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
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
        name: '',
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

      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

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

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _userSubscription?.cancel();
    } catch (e) {
      emit(AuthError('Fehler beim Abmelden: $e'));
    }
  }

  void resetToUnauthenticated() {
    emit(Unauthenticated());
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
