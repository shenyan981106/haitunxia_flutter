class ChapterModel {
  final String title;
  final List<SectionModel> sections;

  ChapterModel({
    required this.title,
    required this.sections,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      title: json['title'],
      sections: (json['sections'] as List)
          .map((section) => SectionModel.fromJson(section))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'sections': sections.map((section) => section.toJson()).toList(),
    };
  }
}

class SectionModel {
  final String title;
  final int questionCount;
  final int doneCount;
  final int accuracy;
  final String? difficulty;
  final String? status;
  final List<SubsectionModel>? subsections;

  SectionModel({
    required this.title,
    required this.questionCount,
    required this.doneCount,
    required this.accuracy,
    this.difficulty,
    this.status,
    this.subsections,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      title: json['title'],
      questionCount: json['questionCount'] ?? 0,
      doneCount: json['doneCount'] ?? 0,
      accuracy: json['accuracy'] ?? 0,
      difficulty: json['difficulty'],
      status: json['status'],
      subsections: json['subsections'] != null
          ? (json['subsections'] as List)
              .map((subsection) => SubsectionModel.fromJson(subsection))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'questionCount': questionCount,
      'doneCount': doneCount,
      'accuracy': accuracy,
      'difficulty': difficulty,
      'status': status,
      'subsections':
          subsections?.map((subsection) => subsection.toJson()).toList(),
    };
  }
}

class SubsectionModel {
  final String title;
  final int count;
  final String difficulty;
  final String status;

  SubsectionModel({
    required this.title,
    required this.count,
    required this.difficulty,
    required this.status,
  });

  factory SubsectionModel.fromJson(Map<String, dynamic> json) {
    return SubsectionModel(
      title: json['title'],
      count: json['count'],
      difficulty: json['difficulty'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'count': count,
      'difficulty': difficulty,
      'status': status,
    };
  }
}

// 题目模型
class Question {
  final String id;
  final String projectId;
  final String subjectId;
  final String type; // single/multi/judgment
  final String kind; // X, JUDGE, SINGLE, MULTI, FILL, SHORT, MATERIAL
  final String content;
  final List<String> options;
  final List<int> correctAnswers;
  final String? answer;
  final String explanation;
  final String difficulty;
  final String? videoUrl;
  final bool isCollected; // 是否已收
  final String cateId; // 题库ID
  final int? questionStatus; // 题目状态：1-未做 2-已做正确 3-已做错误
  final List<int>? userAnswer; // 用户之前选择的答案索引（用于恢复已答记录）

  Question({
    required this.id,
    required this.projectId,
    required this.subjectId,
    required this.type,
    this.kind = 'SINGLE',
    required this.content,
    required this.options,
    required this.correctAnswers,
    this.answer,
    required this.explanation,
    this.difficulty = 'medium',
    this.videoUrl,
    required String chapterId,
    this.isCollected = false,
    this.cateId = '',
    this.questionStatus,
    this.userAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      subjectId: json['subjectId']?.toString() ?? '',
      type: json['type']?.toString() ?? 'single',
      kind: json['kind']?.toString() ?? 'SINGLE',
      content: json['content']?.toString() ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswers: List<int>.from(json['correctAnswers'] ?? []),
      answer: json['answer']?.toString(),
      explanation: json['explanation']?.toString() ?? '',
      difficulty: json['difficulty']?.toString() ?? 'medium',
      videoUrl: json['videoUrl'] ?? json['video'] ?? json['video_url'],
      chapterId: '',
      isCollected: json['isCollected'] ?? false,
      cateId: json['cate_id']?.toString() ?? '',
      questionStatus: json['question_status'] is int
          ? json['question_status']
          : int.tryParse(json['question_status']?.toString() ?? ''),
      userAnswer: json['user_answer'] != null
          ? (json['user_answer'] is List
              ? List<int>.from(json['user_answer'])
              : null)
          : null,
    );
  }
}
