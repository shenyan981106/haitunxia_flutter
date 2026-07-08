class Subject {
  final String id;
  final String projectId;
  final String name;
  final String description;
  final String icon;
  final int chapterCount;
  final int questionCount;
  final double progress;

  Subject({
    required this.id,
    required this.projectId,
    required this.name,
    required this.description,
    required this.icon,
    this.chapterCount = 0,
    this.questionCount = 0,
    this.progress = 0.0,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      chapterCount: json['chapterCount'] ?? 0,
      questionCount: json['questionCount'] ?? 0,
      progress: (json['progress'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      'description': description,
      'icon': icon,
      'chapterCount': chapterCount,
      'questionCount': questionCount,
      'progress': progress,
    };
  }
}
