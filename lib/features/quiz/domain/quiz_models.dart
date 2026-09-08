class QuizQuestion {
  final String id;
  final String prompt;
  final List<String> options;
  final int answer;
  final String explanation;
  final String category;
  final String difficulty;

  const QuizQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.answer,
    required this.explanation,
    required this.category,
    required this.difficulty,
  });
}

class QuizResult {
  final int score;
  final int total;
  final String category;
  final DateTime completedAt;
  const QuizResult({
    required this.score,
    required this.total,
    required this.category,
    required this.completedAt,
  });
}
