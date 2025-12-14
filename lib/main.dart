import 'package:flutter/material.dart';
import 'app_shell.dart';

void main() => runApp(const FitGuideApp());

class FitGuideApp extends StatelessWidget {
  const FitGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitGuide',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: const AppShell(),
    );
  }
}
