import 'package:equatable/equatable.dart';
import '../models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Initial state when app starts
class AuthInitial extends AuthState {}

// Loading state
class AuthLoading extends AuthState {}

// User is authenticated and user data is loaded
class Authenticated extends AuthState {
  final UserModel user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

// User is not authenticated
class Unauthenticated extends AuthState {}

// Error state
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
