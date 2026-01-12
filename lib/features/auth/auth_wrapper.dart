import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app_shell.dart';
import '../onboarding/screens/onboarding_screen.dart';
import 'cubit/auth_cubit.dart';
import 'cubit/auth_state.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Anmeldefehler'),
              content: Text(state.message),
              actions: [
                FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.read<AuthCubit>().resetToUnauthenticated();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const SplashScreen();
        }

        if (state is Unauthenticated) {
          return const LoginScreen();
        }

        if (state is AuthError) {
          return const LoginScreen();
        }

        if (state is Authenticated) {
          if (!state.user.hasCompletedOnboarding) {
            return const OnboardingScreen();
          }
          return const AppShell();
        }

        return const SplashScreen();
      },
    );
  }
}
