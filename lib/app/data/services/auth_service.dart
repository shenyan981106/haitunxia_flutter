import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import 'package:get_storage/get_storage.dart';
import '../providers/api_client.dart';

/// 认证服务
/// 负责管理登录状态、Token存储、用户信?
/// 使用 GetxService 实现全局单例
class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final GetStorage _storage = GetStorage();

  // ==================== 响应式状?====================

  /// 登录状?
  final RxBool isLoggedIn = false.obs;

  /// 用户信息
  final Rx<UserModel?> user = Rx<UserModel?>(null);

  /// Token
  final RxnString token = RxnString();

  /// 加载状态
  final RxBool isLoading = false.obs;

  /// 会员状态：1=会员, 0=非会员, 2=已过期
  final RxInt memberStatus = 0.obs;

  // ==================== 存储Key ====================

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';
  static const String _memberStatusKey = 'member_status';

  // ==================== 生命周期 ====================

  @override
  void onInit() {
    super.onInit();
    _loadAuthState();
  }

  // ==================== 核心方法 ====================

  /// 加载本地存储的认证状?
  void _loadAuthState() {
    try {
      final storedToken = _storage.read<String>(_tokenKey);
      final storedUser = _storage.read<Map<String, dynamic>>(_userKey);

      if (storedToken != null && storedToken.isNotEmpty) {
        token.value = storedToken;
        user.value = UserModel.fromJson(storedUser);
        isLoggedIn.value = true;
        // 加载会员状态
        final storedMemberStatus = _storage.read<int>(_memberStatusKey);
        memberStatus.value = storedMemberStatus ?? 0;
        // token 会自动同步到 ApiClient（通过拦截器）
      } else {
        _clearState();
      }
    } catch (e) {
      debugPrint('AuthService: 加载认证状态失败?- $e');
      _clearState();
    }
  }

  /// 保存认证状?
  void _saveAuthState(String newToken, UserModel newUser) {
    _storage.write(_tokenKey, newToken);
    _storage.write(_userKey, newUser.toJson());
  }

  /// 清除认证状态
  void _clearState() {
    _storage.remove(_tokenKey);
    _storage.remove(_userKey);
    _storage.remove(_memberStatusKey);
    token.value = null;
    user.value = null;
    isLoggedIn.value = false;
    memberStatus.value = 0;
  }

  // ==================== 对外接口 ====================

  /// 设置登录状态（登录成功后调用）
  void setAuth(String newToken, UserModel newUser, {int memberStat = 0}) {
    token.value = newToken;
    user.value = newUser;
    isLoggedIn.value = true;
    memberStatus.value = memberStat;
    _saveAuthState(newToken, newUser);
    _storage.write(_memberStatusKey, memberStat);
    // token 会自动同步到 ApiClient（通过拦截器）
  }

  /// 清除认证状态（登出或Token过期时调用）
  void clearAuth() {
    _clearState();
    // ApiClient 会自动处?token（通过拦截器）
  }

  /// 更新用户信息
  void updateUser(UserModel updatedUser) {
    user.value = updatedUser;
    final currentToken = token.value;
    if (currentToken != null) {
      _storage.write(_userKey, updatedUser.toJson());
    }
  }

  /// 更新会员状态
  void updateMemberStatus(int status) {
    memberStatus.value = status;
    _storage.write(_memberStatusKey, status);
  }

  /// 是否为会员
  bool get isMember => memberStatus.value == 1;

  /// 获取会员类型文字
  String? get memberTypeText => user.value?.info?.typeText;

  /// 获取会员到期时间文字
  String? get memberExpireTimeText => user.value?.info?.expireTimeText;

  /// 检查是否已登录
  bool checkLogin() {
    return isLoggedIn.value && token.value != null;
  }

  /// 获取用户ID
  int? get userId => user.value?.id;

  /// 获取昵称
  String? get nickname => user.value?.nickname ?? user.value?.mobile;

  /// 获取头像URL
  String? get avatar => user.value?.avatar;

  /// 打印当前用户信息
  void printUserInfo() {
    debugPrint('========== 当前用户信息 ==========');
    debugPrint('userId: $userId');
    debugPrint('nickname: $nickname');
    debugPrint('mobile: ${user.value?.mobile}');
    debugPrint('avatar: $avatar');
    debugPrint('=================================');
  }
}
