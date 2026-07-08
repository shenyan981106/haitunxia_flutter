/// 统一输入验证工具类
/// 提供常用的表单验证方法，确保验证逻辑的一致性和可维护性
class Validators {
  // ==================== 正则表达式常量 ====================

  /// 中国大陆手机号正则（1开头，第二位3-9，共11位）
  static final RegExp _phoneRegex = RegExp(r'^1[3-9]\d{9}$');

  /// 邮箱地址正则
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// 密码强度正则（至少8位，包含字母和数字）
  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,}$',
  );

  // ==================== 验证常量 ====================

  /// 验证码最小长度
  static const int minVerificationCodeLength = 4;

  /// 验证码最大长度
  static const int maxVerificationCodeLength = 6;

  /// 手机号长度
  static const int phoneLength = 11;

  /// 昵称最小长度
  static const int minNicknameLength = 2;

  /// 昵称最大长度
  static const int maxNicknameLength = 20;

  // ==================== 手机号验证 ====================

  /// 验证手机号格式是否正确
  /// [phone] 手机号码字符串
  /// 返回 true 表示格式正确
  static bool isValidPhone(String phone) {
    if (phone.isEmpty) return false;
    return _phoneRegex.hasMatch(phone.trim());
  }

  /// 验证手机号并返回错误信息
  /// 如果手机号有效，返回 null；否则返回错误提示
  static String? validatePhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return '请输入手机号码';
    }
    if (!isValidPhone(phone)) {
      return '请输入正确的手机号码格式';
    }
    return null;
  }

  // ==================== 验证码验证 ====================

  /// 验证验证码长度是否符合要求
  /// [code] 验证码字符串
  /// [minLength] 最小长度（默认4位）
  /// 返回 true 表示长度符合要求
  static bool isValidVerificationCode(String code, {int minLength = 4}) {
    if (code.isEmpty) return false;
    return code.trim().length >= minLength;
  }

  /// 验证验证码并返回错误信息
  static String? validateVerificationCode(String? code) {
    if (code == null || code.trim().isEmpty) {
      return '请输入验证码';
    }
    if (code.trim().length < minVerificationCodeLength) {
      return '请输入$minVerificationCodeLength位验证码';
    }
    return null;
  }

  // ==================== 密码验证 ====================

  /// 验证密码强度
  /// [password] 密码字符串
  /// 返回 true 表示密码强度符合要求
  static bool isValidPassword(String password) {
    if (password.isEmpty) return false;
    return _passwordRegex.hasMatch(password);
  }

  /// 验证密码并返回错误信息
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return '请输入密码';
    }
    if (password.length < 8) {
      return '密码长度不能少于8位';
    }
    if (!isValidPassword(password)) {
      return '密码必须包含字母和数字';
    }
    return null;
  }

  // ==================== 邮箱验证 ====================

  /// 验证邮箱格式是否正确
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    return _emailRegex.hasMatch(email.trim());
  }

  /// 验证邮箱并返回错误信息
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return '请输入邮箱地址';
    }
    if (!isValidEmail(email)) {
      return '请输入正确的邮箱格式';
    }
    return null;
  }

  // ==================== 昵称验证 ====================

  /// 验证昵称是否符合要求
  static bool isValidNickname(String nickname) {
    if (nickname.isEmpty) return false;
    final trimmed = nickname.trim();
    return trimmed.length >= minNicknameLength &&
        trimmed.length <= maxNicknameLength;
  }

  /// 验证昵称并返回错误信息
  static String? validateNickname(String? nickname) {
    if (nickname == null || nickname.trim().isEmpty) {
      return '请输入昵称';
    }
    if (nickname.trim().length < minNicknameLength) {
      return '昵称长度不能少于$minNicknameLength个字符';
    }
    if (nickname.trim().length > maxNicknameLength) {
      return '昵称长度不能超过$maxNicknameLength个字符';
    }
    return null;
  }

  // ==================== 通用验证 ====================

  /// 检查字符串是否为空
  static bool isEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// 检查字符串是否不为空
  static bool isNotEmpty(String? value) {
    return !isEmpty(value);
  }

  /// 验证必填字段并返回错误信息
  static String? validateRequired(String? value, {String fieldName = '此字段'}) {
    if (value == null || value.trim().isEmpty) {
      return '请输入$fieldName';
    }
    return null;
  }

  /// 验证字符串长度范围
  static bool isLengthInRange(
    String value, {
    required int min,
    int? max,
  }) {
    final length = value.trim().length;
    if (length < min) return false;
    if (max != null && length > max) return false;
    return true;
  }
}
