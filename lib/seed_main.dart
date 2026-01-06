  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter/material.dart';
  import 'core/scripts/seed_templates.dart';
  import 'firebase_options.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await TemplateSeedScript().seedTemplates();
    print('Fertig!');
  }