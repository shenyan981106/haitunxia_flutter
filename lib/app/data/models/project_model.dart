class Project {
  final String id;
  final String name;
  final String code;
  final String description;
  final String icon;
  final bool isActive;
  final int subjectCount;
  final int questionCount;

  Project({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.icon,
    this.isActive = true,
    this.subjectCount = 0,
    this.questionCount = 0,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      isActive: json['isActive'] ?? true,
      subjectCount: json['subjectCount'] ?? 0,
      questionCount: json['questionCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'icon': icon,
      'isActive': isActive,
      'subjectCount': subjectCount,
      'questionCount': questionCount,
    };
  }

  @override
  String toString() {
    return 'Project{name: $name, code: $code}';
  }
}
