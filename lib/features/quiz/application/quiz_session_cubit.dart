import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/quiz_models.dart';

/// Snapshot of one cybersecurity drill in progress.
class QuizSession {
  const QuizSession({
    this.questionIndex = 0,
    this.score = 0,
    this.selectedOption,
    this.isAnswered = false,
  });

  final int questionIndex;
  final int score;
  final int? selectedOption;
  final bool isAnswered;
}

/// Encapsulates the state transitions for one cybersecurity drill.
class QuizSessionCubit extends Cubit<QuizSession> {
  QuizSessionCubit({required this.questions, required this.category})
    : assert(questions.isNotEmpty, 'A quiz session needs questions.'),
      super(const QuizSession());

  final List<QuizQuestion> questions;
  final String category;
  bool _closed = false;

  QuizQuestion get currentQuestion => questions[state.questionIndex];
  bool get isLastQuestion => state.questionIndex == questions.length - 1;
  double get completion => (state.questionIndex + 1) / questions.length;

  void chooseAnswer(int optionIndex) {
    if (state.isAnswered) return;
    final gained = optionIndex == currentQuestion.answer ? 1 : 0;
    _publish(
      QuizSession(
        questionIndex: state.questionIndex,
        score: state.score + gained,
        selectedOption: optionIndex,
        isAnswered: true,
      ),
    );
  }

  QuizResult? advance() {
    if (!state.isAnswered) return null;
    if (isLastQuestion) {
      return QuizResult(
        score: state.score,
        total: questions.length,
        category: category,
        completedAt: DateTime.now(),
      );
    }
    _publish(
      QuizSession(questionIndex: state.questionIndex + 1, score: state.score),
    );
    return null;
  }

  void _publish(QuizSession next) {
    if (!_closed) emit(next);
  }

  @override
  Future<void> close() {
    _closed = true;
    return super.close();
  }
}
