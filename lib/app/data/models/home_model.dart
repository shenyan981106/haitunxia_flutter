// home_model.dart - 首页数据模型

/// 首页接口返回data 结构
class HomeData {
  final List<HomeNotice> notices;
  final List<HomeRoom> rooms;
  final HomePoint? point;
  final HomeSystem? system;
  final HomeStats? stats;
  final List<HomeSlide> slides;
  final List<HomeCourse> courses;
  final List<HomePaper> papers;
  final String? customerMobile;

  HomeData({
    required this.notices,
    required this.rooms,
    this.point,
    this.system,
    this.stats,
    required this.slides,
    required this.courses,
    required this.papers,
    this.customerMobile,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      notices: json['notices'] is List
          ? (json['notices'] as List)
              .map((e) => e is Map<String, dynamic>
                  ? HomeNotice.fromJson(e)
                  : HomeNotice(
                      id: 0, name: '', statusText: '', createTimeText: ''))
              .toList()
          : [],
      rooms: json['rooms'] is List
          ? (json['rooms'] as List)
              .map((e) => e is Map<String, dynamic>
                  ? HomeRoom.fromJson(e)
                  : HomeRoom(
                      id: 0,
                      title: '',
                      totalScore: 0,
                      passScore: 0,
                      typeText: ''))
              .toList()
          : [],
      slides: json['slides'] is List
          ? (json['slides'] as List)
              .map((e) => e is Map<String, dynamic>
                  ? HomeSlide.fromJson(e)
                  : HomeSlide(id: 0, title: '', image: '', url: ''))
              .toList()
          : [],
      courses: json['courses'] is List
          ? (json['courses'] as List)
              .map((e) => e is Map<String, dynamic>
                  ? HomeCourse.fromJson(e)
                  : HomeCourse(
                      id: 0,
                      title: '',
                      coverImage: '',
                      price: '',
                      salePrice: '',
                      categoryId: 0,
                      categoryName: '',
                      enrollCount: 0))
              .cast<HomeCourse>()
              .toList()
          : [],
      papers: json['papers'] is List
          ? (json['papers'] as List)
              .map((e) => e is Map<String, dynamic>
                  ? HomePaper.fromJson(e)
                  : HomePaper(
                      id: 0,
                      title: '',
                      totalScore: 0,
                      passScore: 0,
                      typeText: ''))
              .toList()
          : [],
      point: json['point'] is Map<String, dynamic>
          ? HomePoint.fromJson(json['point'])
          : null,
      system: json['system'] is Map<String, dynamic>
          ? HomeSystem.fromJson(json['system'])
          : null,
      stats: json['stats'] is Map<String, dynamic>
          ? HomeStats.fromJson(json['stats'])
          : null,
      customerMobile: json['customer_mobile'],
    );
  }
}

class HomeStats {
  final int total;
  final int correct;
  final num accuracy;
  final int todayQuestions;
  final num todayHours;
  final int totalDays;

  HomeStats({
    required this.total,
    required this.correct,
    required this.accuracy,
    required this.todayQuestions,
    required this.todayHours,
    required this.totalDays,
  });

  factory HomeStats.fromJson(Map<String, dynamic> json) {
    return HomeStats(
      total: _asInt(json['total']),
      correct: _asInt(json['correct']),
      accuracy: _asNum(json['accuracy']),
      todayQuestions: _asInt(json['today_questions'] ?? json['total_days']),
      todayHours: _asNum(json['today_hours']),
      totalDays: _asInt(json['totalDays']),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static num _asNum(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class HomeSystem {
  final String loginChannel;

  HomeSystem({
    required this.loginChannel,
  });

  factory HomeSystem.fromJson(Map<String, dynamic> json) {
    return HomeSystem(
      loginChannel: json['login_channel'] ?? '',
    );
  }
}

class HomeNotice {
  final int id;
  final String name;
  final String statusText;
  final String createTimeText;

  HomeNotice({
    required this.id,
    required this.name,
    required this.statusText,
    required this.createTimeText,
  });

  factory HomeNotice.fromJson(Map<String, dynamic> json) {
    return HomeNotice(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      statusText: json['status_text'] ?? '',
      createTimeText: json['create_time_text'] ?? '',
    );
  }
}

class HomeRoom {
  final int id;
  final String title;
  final int totalScore;
  final int passScore;
  final String typeText;

  HomeRoom({
    required this.id,
    required this.title,
    required this.totalScore,
    required this.passScore,
    required this.typeText,
  });

  factory HomeRoom.fromJson(Map<String, dynamic> json) {
    return HomeRoom(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      totalScore: json['total_score'] ?? 0,
      passScore: json['pass_score'] ?? 0,
      typeText: json['type_text'] ?? '',
    );
  }
}

class HomePoint {
  final int getPoint;
  final String type;

  HomePoint({
    required this.getPoint,
    required this.type,
  });

  factory HomePoint.fromJson(Map<String, dynamic> json) {
    return HomePoint(
      getPoint: json['get_point'] ?? 0,
      type: json['type'] ?? '',
    );
  }
}

class HomeSlide {
  final int id;
  final String title;
  final String image;
  final String url;

  HomeSlide({
    required this.id,
    required this.title,
    required this.image,
    required this.url,
  });

  factory HomeSlide.fromJson(Map<String, dynamic> json) {
    return HomeSlide(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class HomeCourse {
  final int id;
  final String title;
  final String coverImage;
  final String price;
  final String salePrice;
  final int categoryId;
  final String categoryName;
  final int enrollCount;

  HomeCourse({
    required this.id,
    required this.title,
    required this.coverImage,
    required this.price,
    required this.salePrice,
    required this.categoryId,
    required this.categoryName,
    required this.enrollCount,
  });

  factory HomeCourse.fromJson(Map<String, dynamic> json) {
    return HomeCourse(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      coverImage: json['cover_image'] ?? '',
      price: json['price']?.toString() ?? '',
      salePrice: json['sale_price']?.toString() ?? '',
      categoryId: json['category_id'] ?? 0,
      categoryName: json['category_name'] ?? '',
      enrollCount: json['enroll_count'] ?? 0,
    );
  }
}

class HomePaper {
  final int id;
  final String title;
  final int totalScore;
  final int passScore;
  final String typeText;

  HomePaper({
    required this.id,
    required this.title,
    required this.totalScore,
    required this.passScore,
    required this.typeText,
  });

  factory HomePaper.fromJson(Map<String, dynamic> json) {
    return HomePaper(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      totalScore: json['total_score'] ?? 0,
      passScore: json['pass_score'] ?? 0,
      typeText: json['type_text'] ?? '',
    );
  }
}
