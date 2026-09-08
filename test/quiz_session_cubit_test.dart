import 'package:calder/features/quiz/application/quiz_session_cubit.dart';
import 'package:calder/features/quiz/domain/quiz_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const questions = [
    QuizQuestion(
      id: 'first',
      prompt: 'First?',
      options: ['Wrong', 'Right'],
      answer: 1,
      explanation: 'Because.',
      category: 'Linux',
      difficulty: 'Core',
    ),
    QuizQuestion(
      id: 'second',
      prompt: 'Second?',
      options: ['Right', 'Wrong'],
      answer: 0,
      explanation: 'Because.',
      category: 'Linux',
      difficulty: 'Core',
    ),
  ];

  test('records one answer per question and returns the final result', () {
    final session = QuizSessionCubit(questions: questions, category: 'Linux');

    session.chooseAnswer(1);
    session.chooseAnswer(0);
    expect(session.state.score, 1);
    expect(session.advance(), isNull);
    expect(session.state.questionIndex, 1);

    session.chooseAnswer(1);
    final result = session.advance();

    expect(result, isNotNull);
    expect(result!.score, 1);
    expect(result.total, 2);
    expect(result.category, 'Linux');
    session.close();
  });
}
