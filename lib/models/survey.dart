

class Survey {
  final String id;
  final String name;
  final String? description;
  final String? file;
  bool isSubmitted;  // Make this a mutable field
  final DateTime endTime;
  final String className;

  Survey({
    required this.id,
    required this.name,
    this.description,
    this.file,
    this.isSubmitted = false,  // Default to false
    required this.endTime,
    required this.className,
  });

  factory Survey.fromJson(Map<String, dynamic> json) {
    print(json);
    return Survey(
      id: json['id'].toString(),
      name: json['title'],
      description: json['description'],
      file: json['file_url'],
      isSubmitted: false,  // Default to false
      endTime: DateTime.parse(json['deadline']),
      className: json['class_id'],
    );
  }
}

class TeacherSurvey {
  final String id;
  final String name;
  final String? description;
  final String? file;
  final DateTime endTime;
  final String className;

  TeacherSurvey({
    required this.id,
    required this.name,
    this.description,
    this.file, // Default to false
    required this.endTime,
    required this.className,
  });

  factory TeacherSurvey.teacherFromJson(Map<String, dynamic> json) {
    print(json);
    return TeacherSurvey(
      id: json['id'].toString(),
      name: json['title'],
      description: json['description'],
      file: json['file_url'],
      endTime: DateTime.parse(json['deadline']),
      className: json['class_id'],
    );
  }
}