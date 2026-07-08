/// 用户模型
/// 用于存储登录用户的基本信息
class UserModel {
  /// 用户ID
  final int? id;

  /// 昵称
  final String? nickname;

  /// 手机号
  final String? mobile;

  /// 头像URL
  final String? avatar;

  /// 账户状态 (normal 等)
  final String? status;

  /// 会员信息
  final UserInfoModel? info;

  UserModel({
    int? id,
    String? nickname,
    String? mobile,
    String? avatar,
    String? status,
    UserInfoModel? info,
  })  : id = id,
        nickname = nickname,
        mobile = mobile,
        avatar = avatar,
        status = status,
        info = info;

  /// 从JSON创建用户模型
  factory UserModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return UserModel();
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      nickname: json['nickname']?.toString(),
      mobile: json['mobile']?.toString(),
      avatar: json['avatar']?.toString().isNotEmpty == true
          ? json['avatar']?.toString()
          : (json['headimg']?.toString().isNotEmpty == true
              ? json['headimg']?.toString()
              : json['head_img']?.toString()),
      status: json['status']?.toString(),
      info: json['info'] is Map
          ? UserInfoModel.fromJson(Map<String, dynamic>.from(json['info']))
          : null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'mobile': mobile,
      'avatar': avatar,
      'status': status,
      'info': info?.toJson(),
    };
  }

  /// 复制并修改属性
  UserModel copyWith({
    int? id,
    String? nickname,
    String? mobile,
    String? avatar,
    String? status,
    UserInfoModel? info,
  }) {
    return UserModel(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      mobile: mobile ?? this.mobile,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
      info: info ?? this.info,
    );
  }
}

/// 会员信息模型
class UserInfoModel {
  final int? id;
  final String? type;
  final int? memberConfigId;
  final int? userId;
  final int? score;
  final int? expireTime;
  final String? typeText;
  final String? expireTimeText;
  /// 会员状态：1=会员, 0=非会员, 2=已过期
  final int? status;

  UserInfoModel({
    this.id,
    this.type,
    this.memberConfigId,
    this.userId,
    this.score,
    this.expireTime,
    this.typeText,
    this.expireTimeText,
    this.status,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    return UserInfoModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      type: json['type']?.toString(),
      memberConfigId: json['member_config_id'] is int
          ? json['member_config_id']
          : int.tryParse(json['member_config_id']?.toString() ?? ''),
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? ''),
      score: json['score'] is int
          ? json['score']
          : int.tryParse(json['score']?.toString() ?? ''),
      expireTime: json['expire_time'] is int
          ? json['expire_time']
          : int.tryParse(json['expire_time']?.toString() ?? ''),
      typeText: json['type_text']?.toString(),
      expireTimeText: json['expire_time_text']?.toString(),
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'member_config_id': memberConfigId,
      'user_id': userId,
      'score': score,
      'expire_time': expireTime,
      'type_text': typeText,
      'expire_time_text': expireTimeText,
      'status': status,
    };
  }
}
