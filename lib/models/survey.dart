class TeacherSmallSurvey {
  final String name;
  final String? description;
  final String? file;
  final DateTime startTime;
  final DateTime endTime;

  const TeacherSmallSurvey({
    required this.name,
    this.description,
    this.file,
    required this.startTime,
    required this.endTime,
  });
} 