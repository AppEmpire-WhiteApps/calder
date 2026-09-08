import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/settings/training_desk_support.dart';
import '../../../core/theme/calder_theme.dart';
import '../application/operator_progress_cubit.dart';
import '../application/quiz_session_cubit.dart';
import '../data/question_repository.dart';
import '../domain/quiz_models.dart';
import '../../tools/presentation/admin_tools_screen.dart';

class QuizHomeScreen extends StatefulWidget {
  const QuizHomeScreen({super.key});

  @override
  State<QuizHomeScreen> createState() => _QuizHomeScreenState();
}

class _QuizHomeScreenState extends State<QuizHomeScreen> {
  final repository = const QuestionRepository();
  late final OperatorProgressCubit progress;

  @override
  void initState() {
    super.initState();
    progress = OperatorProgressCubit()..restore();
  }

  @override
  void dispose() {
    progress.close();
    super.dispose();
  }

  Future<void> _startDrill() async {
    final selectedTrack = progress.state.selectedTrack;
    final questions = repository
        .all()
        .where(
          (question) =>
              selectedTrack == 'All' || question.category == selectedTrack,
        )
        .toList();
    final result = await Navigator.push<QuizResult>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            QuizSessionScreen(questions: questions, category: selectedTrack),
      ),
    );
    if (result != null) {
      await progress.record(result);
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<OperatorProgressCubit, OperatorProgress>(
        bloc: progress,
        builder: (context, progressState) {
          if (progressState.isRestoring) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final categories = ['All', ...repository.categories()];
          return Scaffold(
            body: SafeArea(
              child: IndexedStack(
                index: progressState.selectedSection,
                children: [
                  _Dashboard(
                    streak: progressState.streak,
                    sessions: progressState.completedSessions,
                    correct: progressState.correctAnswers,
                    category: progressState.selectedTrack,
                    categories: categories,
                    onCategory: progress.selectTrack,
                    onStart: _startDrill,
                  ),
                  _Progress(
                    sessions: progressState.completedSessions,
                    correct: progressState.correctAnswers,
                  ),
                  const _OperatorSettings(),
                  const AdminToolsScreen(),
                ],
              ),
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: progressState.selectedSection,
              onDestinationSelected: progress.selectSection,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.quiz_outlined),
                  label: 'Quiz',
                ),
                NavigationDestination(
                  icon: Icon(Icons.insights_outlined),
                  label: 'Progress',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  label: 'Settings',
                ),
                NavigationDestination(
                  icon: Icon(Icons.build_outlined),
                  label: 'Tools',
                ),
              ],
            ),
          );
        },
      );
}

class _Dashboard extends StatelessWidget {
  final int streak, sessions, correct;
  final String category;
  final List<String> categories;
  final ValueChanged<String> onCategory;
  final VoidCallback onStart;
  const _Dashboard({
    required this.streak,
    required this.sessions,
    required this.correct,
    required this.category,
    required this.categories,
    required this.onCategory,
    required this.onStart,
  });
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(22),
    children: [
      const Text(
        'CALDER',
        style: TextStyle(
          color: CalderTheme.cyan,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
      const SizedBox(height: 30),
      const Text(
        'Think like\nan operator.',
        style: TextStyle(
          fontSize: 42,
          height: .98,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 14),
      const Text(
        'Short, practical cybersecurity scenarios for sysadmins.',
        style: TextStyle(color: CalderTheme.muted, fontSize: 16),
      ),
      const SizedBox(height: 28),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CalderTheme.panel,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.local_fire_department_rounded,
              color: CalderTheme.amber,
              size: 34,
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streak day streak',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'Keep your incident instincts sharp',
                  style: TextStyle(color: CalderTheme.muted),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 28),
      const Text(
        'CHOOSE A TRACK',
        style: TextStyle(
          color: CalderTheme.muted,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: categories
            .map(
              (item) => ChoiceChip(
                label: Text(item),
                selected: item == category,
                onSelected: (_) => onCategory(item),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 24),
      FilledButton.icon(
        onPressed: onStart,
        icon: const Icon(Icons.play_arrow_rounded),
        label: const Text('START 5-MINUTE QUIZ'),
        style: FilledButton.styleFrom(
          backgroundColor: CalderTheme.cyan,
          foregroundColor: CalderTheme.ink,
          minimumSize: const Size.fromHeight(56),
        ),
      ),
      const SizedBox(height: 18),
      Row(
        children: [
          Expanded(child: _MiniStat('$sessions', 'sessions')),
          const SizedBox(width: 10),
          Expanded(child: _MiniStat('$correct', 'correct answers')),
        ],
      ),
      const SizedBox(height: 24),
      const Text(
        'No live services or accounts required. Your progress stays on this device.',
        style: TextStyle(color: CalderTheme.muted, fontSize: 12),
      ),
    ],
  );
}

class _MiniStat extends StatelessWidget {
  final String value, label;
  const _MiniStat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          Text(label, style: const TextStyle(color: CalderTheme.muted)),
        ],
      ),
    ),
  );
}

class QuizSessionScreen extends StatefulWidget {
  const QuizSessionScreen({
    required this.questions,
    required this.category,
    super.key,
  });

  final List<QuizQuestion> questions;
  final String category;

  @override
  State<QuizSessionScreen> createState() => _QuizSessionScreenState();
}

class _QuizSessionScreenState extends State<QuizSessionScreen> {
  late final QuizSessionCubit session;

  @override
  void initState() {
    super.initState();
    session = QuizSessionCubit(
      questions: widget.questions,
      category: widget.category,
    );
  }

  @override
  void dispose() {
    session.close();
    super.dispose();
  }

  void _advance() {
    final result = session.advance();
    if (result != null) {
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<QuizSessionCubit, QuizSession>(
        bloc: session,
        builder: (context, quizState) {
          final question = session.currentQuestion;
          return Scaffold(
            appBar: AppBar(
              title: Text(
                '${quizState.questionIndex + 1} / ${session.questions.length}',
              ),
            ),
            body: ListView(
              padding: const EdgeInsets.all(22),
              children: [
                LinearProgressIndicator(
                  value: session.completion,
                  color: CalderTheme.cyan,
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Text(
                      question.category.toUpperCase(),
                      style: const TextStyle(
                        color: CalderTheme.cyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      question.difficulty,
                      style: const TextStyle(color: CalderTheme.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  question.prompt,
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 24),
                ...question.options.asMap().entries.map((entry) {
                  final isCorrect = entry.key == question.answer;
                  final isSelected = entry.key == quizState.selectedOption;
                  final color = !quizState.isAnswered
                      ? CalderTheme.panel
                      : isCorrect
                      ? const Color(0xFF1F604F)
                      : isSelected
                      ? const Color(0xFF713C3C)
                      : CalderTheme.panel;
                  return Card(
                    color: color,
                    child: InkWell(
                      onTap: () => session.chooseAnswer(entry.key),
                      child: Padding(
                        padding: const EdgeInsets.all(17),
                        child: Row(
                          children: [
                            Text(
                              String.fromCharCode(65 + entry.key),
                              style: const TextStyle(
                                color: CalderTheme.cyan,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (quizState.isAnswered && isCorrect)
                              const Icon(
                                Icons.check_circle,
                                color: CalderTheme.cyan,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                if (quizState.isAnswered) ...[
                  const SizedBox(height: 22),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(17),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'OPERATOR NOTE',
                            style: TextStyle(
                              color: CalderTheme.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            question.explanation,
                            style: const TextStyle(
                              color: CalderTheme.muted,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                if (quizState.isAnswered)
                  FilledButton(
                    onPressed: _advance,
                    child: Text(
                      session.isLastQuestion ? 'SEE RESULT' : 'NEXT QUESTION',
                    ),
                  ),
              ],
            ),
          );
        },
      );
}

class _Progress extends StatelessWidget {
  final int sessions, correct;
  const _Progress({required this.sessions, required this.correct});
  @override
  Widget build(BuildContext context) {
    final rate = correct == 0 ? 0 : ((correct / (sessions * 5)) * 100).round();
    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        const Text(
          'PROGRESS',
          style: TextStyle(
            color: CalderTheme.cyan,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Your operator profile',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$rate%',
                  style: const TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    color: CalderTheme.cyan,
                  ),
                ),
                const Text(
                  'answer accuracy',
                  style: TextStyle(color: CalderTheme.muted),
                ),
                const SizedBox(height: 18),
                LinearProgressIndicator(
                  value: rate / 100,
                  color: CalderTheme.cyan,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _MiniStat('$sessions', 'completed sessions'),
        const SizedBox(height: 10),
        _MiniStat('$correct', 'correct answers'),
        const SizedBox(height: 24),
        const Text(
          'Progress is calculated from completed five-question sessions and stored locally.',
          style: TextStyle(color: CalderTheme.muted, height: 1.4),
        ),
      ],
    );
  }
}

class _OperatorSettings extends StatelessWidget {
  const _OperatorSettings();
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(22),
    children: [
      const Text(
        'SETTINGS',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 10),
      const Text(
        'Calder for practical sysadmin security.',
        style: TextStyle(color: CalderTheme.muted),
      ),
      const SizedBox(height: 24),
      FutureBuilder<String>(
        future: TrainingDeskSupport.version(),
        builder: (_, snapshot) => ListTile(
          leading: const Icon(Icons.info_outline, color: CalderTheme.cyan),
          title: const Text('Version'),
          trailing: Text(snapshot.data ?? 'Loading…'),
        ),
      ),
      ListTile(
        leading: const Icon(
          Icons.support_agent_outlined,
          color: CalderTheme.cyan,
        ),
        title: const Text('Support'),
        subtitle: const Text('Contact the Calder team'),
        onTap: () => TrainingDeskSupport.support(),
      ),
      ListTile(
        leading: const Icon(Icons.star_border_rounded, color: CalderTheme.cyan),
        title: const Text('Rate Calder'),
        subtitle: const Text('Leave a review in the App Store'),
        onTap: () => TrainingDeskSupport.rate(),
      ),
      const SizedBox(height: 24),
      const Card(
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Text(
            'Calder is an educational quiz. It does not perform scans, access production systems, or replace your incident response runbook.',
            style: TextStyle(color: CalderTheme.muted, height: 1.4),
          ),
        ),
      ),
    ],
  );
}
