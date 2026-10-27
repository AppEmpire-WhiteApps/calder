import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/calder_theme.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/quiz/presentation/quiz_home_screen.dart';

class CalderApp extends StatelessWidget {
  const CalderApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Calder: Cyber Defense',
    theme: CalderTheme.dark(),
    home: const CalderLaunchGate(),
  );
}

class CalderLaunchGate extends StatelessWidget {
  const CalderLaunchGate({super.key});

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
    future: SharedPreferences.getInstance().then(
      (prefs) => prefs.getBool('calder.onboarding.completed') ?? false,
    ),
    builder: (_, snapshot) => snapshot.data == true
        ? const QuizHomeScreen()
        : const CalderOnboardingScreen(),
  );
}
