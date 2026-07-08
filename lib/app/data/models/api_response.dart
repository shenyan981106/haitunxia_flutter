/// API响应模型
/// 统一处理后端返回的数据结
class ApiResponse<T> {
  /// 状态码
  final int code;

  /// 消息
  final String message;

  /// 数据
  final T? data;

  /// 时间
  final int? timestamp;

  ApiResponse({
    required this.code,
    required this.message,
    this.data,
    this.timestamp,
  });

  /// 从JSON创建ApiResponse
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T? Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiResponse(
      code: json['code'] is int
          ? json['code']
          : int.tryParse(json['code']?.toString() ?? '') ?? 0,
      message: json['msg']?.toString() ?? json['message']?.toString() ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'] as Map<String, dynamic>)
          : json['data'],
      timestamp: json['timestamp'] is int
          ? json['timestamp']
          : int.tryParse(json['timestamp']?.toString() ?? ''),
    );
  }

  /// 判断是否成功
  bool get isSuccess => code == 0 || code == 1 || code == 200;

  /// 转换为Map
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'msg': message,
      'data': data,
      'timestamp': timestamp,
    };
  }
}

/// 考试倒计时数?
class ExamCountdown {
  /// 剩余天数
  final int remainDays;

  /// 剩余文本
  final String remainText;

  /// 考试日期
  final String? examDate;

  ExamCountdown({
    required this.remainDays,
    required this.remainText,
    this.examDate,
  });

  factory ExamCountdown.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ExamCountdown(remainDays: 0, remainText: '');
    return ExamCountdown(
      remainDays: json['remain_days'] is int
          ? json['remain_days']
          : int.tryParse(json['remain_days']?.toString() ?? '') ?? 0,
      remainText: json['remain_text']?.toString() ?? '',
      examDate: json['exam_date']?.toString(),
    );
  }
}

/// 通用列表数据
class ListData<T> {
  final List<T>? list;
  final int? total;
  final int? page;
  final int? pageSize;

  ListData({
    this.list,
    this.total,
    this.page,
    this.pageSize,
  });

  factory ListData.fromJson(
    Map<String, dynamic>? json,
    T? Function(Map<String, dynamic>)? fromJsonT,
  ) {
    if (json == null) return ListData();
    return ListData(
      list: json['list'] is List
          ? (json['list'] as List)
              .map((e) => fromJsonT != null && e is Map
                  ? fromJsonT(Map<String, dynamic>.from(e))
                  : e as T)
              .toList()
              .cast<T>()
          : null,
      total: json['total'] is int
          ? json['total']
          : int.tryParse(json['total']?.toString() ?? ''),
      page: json['page'] is int
          ? json['page']
          : int.tryParse(json['page']?.toString() ?? ''),
      pageSize: json['page_size'] is int
          ? json['page_size']
          : int.tryParse(json['page_size']?.toString() ?? ''),
    );
  }
}
