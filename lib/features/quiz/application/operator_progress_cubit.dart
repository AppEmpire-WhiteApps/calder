import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/quiz_models.dart';

/// Snapshot of the operator's persisted training progress and desk choices.
class OperatorProgress {
  const OperatorProgress({
    this.selectedSection = 0,
    this.selectedTrack = 'All',
    this.streak = 0,
    this.completedSessions = 0,
    this.correctAnswers = 0,
    this.isRestoring = true,
  });

  final int selectedSection;
  final String selectedTrack;
  final int streak;
  final int completedSessions;
  final int correctAnswers;
  final bool isRestoring;

  OperatorProgress copyWith({
    int? selectedSection,
    String? selectedTrack,
    int? streak,
    int? completedSessions,
    int? correctAnswers,
    bool? isRestoring,
  }) => OperatorProgress(
    selectedSection: selectedSection ?? this.selectedSection,
    selectedTrack: selectedTrack ?? this.selectedTrack,
    streak: streak ?? this.streak,
    completedSessions: completedSessions ?? this.completedSessions,
    correctAnswers: correctAnswers ?? this.correctAnswers,
    isRestoring: isRestoring ?? this.isRestoring,
  );
}

/// Owns the operator's locally persisted training progress and desk choices.
class OperatorProgressCubit extends Cubit<OperatorProgress> {
  OperatorProgressCubit({Future<SharedPreferences>? preferences})
    : _preferences = preferences ?? SharedPreferences.getInstance(),
      super(const OperatorProgress());

  static const _streakKey = 'calder.streak';
  static const _sessionsKey = 'calder.sessions';
  static const _correctAnswersKey = 'calder.correct';

  final Future<SharedPreferences> _preferences;
  bool _closed = false;

  Future<void> restore() async {
    final preferences = await _preferences;
    _publish(
      state.copyWith(
        streak: preferences.getInt(_streakKey) ?? 0,
        completedSessions: preferences.getInt(_sessionsKey) ?? 0,
        correctAnswers: preferences.getInt(_correctAnswersKey) ?? 0,
        isRestoring: false,
      ),
    );
  }

  void selectSection(int index) {
    if (state.selectedSection == index) return;
    _publish(state.copyWith(selectedSection: index));
  }

  void selectTrack(String track) {
    if (state.selectedTrack == track) return;
    _publish(state.copyWith(selectedTrack: track));
  }

  Future<void> record(QuizResult result) async {
    final nextSessions = state.completedSessions + 1;
    final nextCorrect = state.correctAnswers + result.score;
    final nextStreak = state.streak + 1;
    final preferences = await _preferences;

    await Future.wait([
      preferences.setInt(_sessionsKey, nextSessions),
      preferences.setInt(_correctAnswersKey, nextCorrect),
      preferences.setInt(_streakKey, nextStreak),
    ]);

    _publish(
      state.copyWith(
        completedSessions: nextSessions,
        correctAnswers: nextCorrect,
        streak: nextStreak,
      ),
    );
  }

  void _publish(OperatorProgress next) {
    if (!_closed) emit(next);
  }

  @override
  Future<void> close() {
    _closed = true;
    return super.close();
  }
}
