import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'app_shell.dart';
import 'core/services/auth_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/cubit/auth_state.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const FitGuideApp());
}

class FitGuideApp extends StatelessWidget {
  const FitGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(authService: AuthService()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FitGuide',
        theme: AppTheme.dark(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const SplashScreen();
        }

        if (state is Unauthenticated) {
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
