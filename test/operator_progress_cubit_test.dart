import 'package:calder/features/quiz/application/operator_progress_cubit.dart';
import 'package:calder/features/quiz/domain/quiz_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('restores and persists operator progress', () async {
    SharedPreferences.setMockInitialValues({
      'calder.streak': 2,
      'calder.sessions': 3,
      'calder.correct': 11,
    });
    final cubit = OperatorProgressCubit();

    await cubit.restore();
    expect(cubit.state.streak, 2);
    expect(cubit.state.completedSessions, 3);
    expect(cubit.state.correctAnswers, 11);

    await cubit.record(
      QuizResult(
        score: 4,
        total: 5,
        category: 'Linux',
        completedAt: DateTime(2026),
      ),
    );

    expect(cubit.state.streak, 3);
    expect(cubit.state.completedSessions, 4);
    expect(cubit.state.correctAnswers, 15);
    await cubit.close();
  });
}
