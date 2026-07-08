// 章节学习数据模型

class ChapterData {
  final String title;
  final List<SectionData> sections;
  bool isExpanded;

  ChapterData({
    required this.title,
    required this.sections,
    this.isExpanded = false,
  });
}

class SectionData {
  final String name;
  final int total;
  final int done;
  final String accuracy;
  final int stars;
  final List<SubTopicData> subTopics;
  bool isExpanded;

  SectionData({
    required this.name,
    required this.total,
    required this.done,
    required this.accuracy,
    required this.stars,
    required this.subTopics,
    this.isExpanded = false,
  });
}

class SubTopicData {
  final String name;
  final int stars;
  final int total;
  final int done;

  SubTopicData({
    required this.name,
    required this.stars,
    required this.total,
    required this.done,
  });
}
