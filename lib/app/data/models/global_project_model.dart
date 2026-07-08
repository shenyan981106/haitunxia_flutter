// global_project_model.dart - 全局项目数据模型

class GlobalExamCountdown {
  final String examType;
  final String target;
  final int remainSeconds;
  final int remainDays;
  final String remainText;

  GlobalExamCountdown({
    required this.examType,
    required this.target,
    required this.remainSeconds,
    required this.remainDays,
    required this.remainText,
  });

  factory GlobalExamCountdown.fromJson(Map<String, dynamic> json) {
    return GlobalExamCountdown(
      examType: json['exam_type']?.toString() ?? '',
      target: json['target']?.toString() ?? '',
      remainSeconds: json['remain_seconds'] is int
          ? json['remain_seconds'] as int
          : int.tryParse(json['remain_seconds']?.toString() ?? '') ?? 0,
      remainDays: json['remain_days'] is int
          ? json['remain_days'] as int
          : int.tryParse(json['remain_days']?.toString() ?? '') ?? 0,
      remainText: json['remain_text']?.toString() ?? '',
    );
  }
}

class GlobalSystem {
  final String loginChannel;

  GlobalSystem({
    required this.loginChannel,
  });

  factory GlobalSystem.fromJson(Map<String, dynamic> json) {
    return GlobalSystem(
      loginChannel: json['login_channel'] ?? '',
    );
  }
}

class GlobalNotice {
  final int id;
  final String name;
  final String statusText;
  final String createTimeText;

  GlobalNotice({
    required this.id,
    required this.name,
    required this.statusText,
    required this.createTimeText,
  });

  factory GlobalNotice.fromJson(Map<String, dynamic> json) {
    return GlobalNotice(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      statusText: json['status_text'] ?? '',
      createTimeText: json['create_time_text'] ?? '',
    );
  }
}

class GlobalRoom {
  final int id;
  final String name;
  final String contents;
  final String startTimeText;
  final String endTimeText;
  final String statusText;

  GlobalRoom({
    required this.id,
    required this.name,
    required this.contents,
    required this.startTimeText,
    required this.endTimeText,
    required this.statusText,
  });

  factory GlobalRoom.fromJson(Map<String, dynamic> json) {
    return GlobalRoom(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      contents: json['contents'] ?? '',
      startTimeText: json['start_time_text'] ?? '',
      endTimeText: json['end_time_text'] ?? '',
      statusText: json['status_text'] ?? '',
    );
  }
}

class GlobalPoint {
  final int getPoint;
  final String type;

  GlobalPoint({
    required this.getPoint,
    required this.type,
  });

  factory GlobalPoint.fromJson(Map<String, dynamic> json) {
    return GlobalPoint(
      getPoint: json['get_point'] ?? 0,
      type: json['type'] ?? '',
    );
  }
}
