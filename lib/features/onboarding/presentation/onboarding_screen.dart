import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/calder_theme.dart';
import '../../quiz/presentation/quiz_home_screen.dart';
import '../application/briefing_progress_cubit.dart';

class CalderOnboardingScreen extends StatefulWidget {
  const CalderOnboardingScreen({super.key});

  @override
  State<CalderOnboardingScreen> createState() => _CalderOnboardingScreenState();
}

class _CalderOnboardingScreenState extends State<CalderOnboardingScreen> {
  static const slides = [
    (
      'READ THE SIGNAL',
      'Train your eye for the small clues that matter during a sysadmin incident.',
      'assets/onboarding/signal.png',
    ),
    (
      'MAKE THE CALL',
      'Practice the practical decisions: contain, preserve evidence, rotate, and recover.',
      'assets/onboarding/terminal.png',
    ),
    (
      'BUILD YOUR SHIELD',
      'Turn daily five-minute sessions into stronger operator instincts.',
      'assets/onboarding/shield.png',
    ),
  ];

  final pages = PageController();
  late final BriefingProgressCubit briefing;

  @override
  void initState() {
    super.initState();
    briefing = BriefingProgressCubit(slideCount: slides.length);
  }

  Future<void> finish() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('calder.onboarding.completed', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const QuizHomeScreen()),
    );
  }

  void next() {
    if (briefing.isFinalSlide) {
      finish();
      return;
    }
    pages.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    pages.dispose();
    briefing.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<BriefingProgressCubit, int>(
    bloc: briefing,
    builder: (context, currentSlide) => Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'CALDER',
                    style: TextStyle(
                      color: CalderTheme.cyan,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    '${currentSlide + 1} / ${slides.length}',
                    style: const TextStyle(color: CalderTheme.muted),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: PageView.builder(
                  controller: pages,
                  itemCount: slides.length,
                  onPageChanged: briefing.moveTo,
                  itemBuilder: (_, index) =>
                      _BriefingSlide(data: slides[index]),
                ),
              ),
              Row(
                children: List.generate(
                  slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.only(right: 6),
                    width: index == currentSlide ? 30 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == currentSlide
                          ? CalderTheme.cyan
                          : CalderTheme.panel,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: next,
                style: FilledButton.styleFrom(
                  backgroundColor: CalderTheme.cyan,
                  foregroundColor: CalderTheme.ink,
                  minimumSize: const Size.fromHeight(56),
                ),
                child: Text(
                  briefing.isFinalSlide ? 'START QUIZ' : 'CONTINUE',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              if (!briefing.isFinalSlide)
                Center(
                  child: TextButton(
                    onPressed: finish,
                    child: const Text(
                      'Skip intro',
                      style: TextStyle(color: CalderTheme.muted),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _BriefingSlide extends StatelessWidget {
  const _BriefingSlide({required this.data});

  final (String, String, String) data;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Image.asset(data.$3, fit: BoxFit.cover),
        ),
      ),
      const SizedBox(height: 22),
      Text(
        data.$1,
        style: const TextStyle(
          fontSize: 34,
          height: 1,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 14),
      Text(
        data.$2,
        style: const TextStyle(
          color: CalderTheme.muted,
          fontSize: 17,
          height: 1.4,
        ),
      ),
    ],
  );
}
