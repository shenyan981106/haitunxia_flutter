import 'package:dio/dio.dart' hide Response;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/providers/api_client.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_pages.dart';
import '../../../services/snackbar_utils.dart';
import '../../../utils/api_error_handler.dart';

class UserController extends GetxController {
  Future<Map<String, dynamic>?>? _configFuture;

  Future<Map<String, dynamic>?> _fetchConfig() async {
    _configFuture ??= ApiClient.to.exam(
      'common/getConfig',
      queryParameters: {'id': 1},
    ).then((response) {
      final data = response.data as Map<String, dynamic>?;
      if (data != null && data['code'] == 1 && data['data'] is Map) {
        return Map<String, dynamic>.from(data['data'] as Map);
      }
      SnackbarUtils.showError(data?['msg'] ?? '获取配置失败');
      return null;
    }).catchError((error) {
      _configFuture = null;
      throw error;
    });

    return _configFuture;
  }

  String? _readConfigString(Map<String, dynamic>? config, String key) {
    final value = config?[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  // 退出登录
  void logout() {
    // 清除登录状态
    AuthService.to.clearAuth();
    // 跳转到登录页
    Get.offAllNamed(Routes.LOGIN);
  }

  /// 兑换激活码
  Future<bool> exchangeActivationCode(String code) async {
    try {
      final response = await ApiClient.to
          .post('addons/exam/pay/exchangeCode', data: {'code': code});
      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        if (data['code'] == 1 && data['data'] is Map) {
          final result = data['data'] as Map<String, dynamic>;
          final infoMap = result['info'] is Map
              ? Map<String, dynamic>.from(result['info'])
              : null;
          if (infoMap != null) {
            final newInfo = UserInfoModel.fromJson(infoMap);
            final currentUser = AuthService.to.user.value;
            if (currentUser != null) {
              AuthService.to.updateUser(currentUser.copyWith(info: newInfo));
              AuthService.to.updateMemberStatus(newInfo.status ?? 0);
            }
          }
          SnackbarUtils.showSuccess('兑换成功');
          return true;
        } else {
          SnackbarUtils.showError(data['msg']?.toString() ?? '兑换失败');
        }
      } else {
        SnackbarUtils.showError('兑换失败');
      }
    } on DioException catch (e) {
      ApiErrorHandler.handleDioError(e, fallbackMessage: '兑换失败，请检查激活码是否正确');
    } catch (e) {
      ApiErrorHandler.handleError(e, fallbackMessage: '兑换失败');
    }
    return false;
  }

  /// 获取客服二维码URL
  Future<String?> fetchCustomerServiceQrCode() async {
    try {
      final config = await _fetchConfig();
      return _readConfigString(config, 'ewm_config');
    } on DioException catch (e) {
      ApiErrorHandler.handleDioError(e, fallbackMessage: '获取客服配置失败');
    } catch (e) {
      ApiErrorHandler.handleError(e, fallbackMessage: '获取客服配置失败');
    }
    return null;
  }

  /// 获取咨询二维码URL
  Future<String?> fetchZixunQrCode() async {
    try {
      final config = await _fetchConfig();
      return _readConfigString(config, 'zixun_config');
    } on DioException catch (e) {
      ApiErrorHandler.handleDioError(e, fallbackMessage: '获取咨询配置失败');
    } catch (e) {
      ApiErrorHandler.handleError(e, fallbackMessage: '获取咨询配置失败');
    }
    return null;
  }

  /// 获取企业团报H5链接
  Future<String?> fetchCompanyH5Url() async {
    try {
      final config = await _fetchConfig();
      if (config == null) return null;

      final url = _readConfigString(config, 'company_report_config');
      if (url != null) {
        return url;
      }
      SnackbarUtils.showError('未获取到链接地址');
    } on DioException catch (e) {
      ApiErrorHandler.handleDioError(e, fallbackMessage: '获取企业团报配置失败');
    } catch (e) {
      ApiErrorHandler.handleError(e, fallbackMessage: '获取企业团报配置失败');
    }
    return null;
  }

  /// 提交注销账号申请
  /// 返回 true 表示提交成功，false 表示失败
  Future<bool> submitDeleteAccountRequest() async {
    try {
      final response = await ApiClient.to.post(
        'addons/exam/user/deleteUserRequest',
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        SnackbarUtils.showError('提交失败${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      ApiErrorHandler.handleDioError(e, fallbackMessage: '请求失败');
      return false;
    } catch (e) {
      ApiErrorHandler.handleError(e, fallbackMessage: '请求失败');
      return false;
    }
  }

  /// 检查是否已登录
  bool checkLoginStatus() {
    return AuthService.to.isLoggedIn.value;
  }

  /// 选择并上传头像
  /// 返回 true 表示上传成功，false 表示失败
  Future<bool> pickAndUploadAvatar() async {
    if (!checkLoginStatus()) {
      SnackbarUtils.showError('请先登录后再操作');
      return false;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image == null) return false;

    try {
      SnackbarUtils.showLoading(msg: '正在上传头像...');

      // 第一步：上传图片文件
      final uploadResponse =
          await ApiClient.to.uploadFile<Map<String, dynamic>>(image.path);
      final uploadData = uploadResponse.data;
      if (uploadData == null || uploadData['code'] != 1) {
        SnackbarUtils.dismissLoading();
        SnackbarUtils.showError('图片上传失败');
        return false;
      }

      // 提取上传后的图片URL
      final dataMap = uploadData['data'];
      final newAvatarUrl = (dataMap is Map)
          ? (dataMap['fullurl']?.toString() ?? dataMap['url']?.toString() ?? '')
          : '';
      if (newAvatarUrl.isEmpty) {
        SnackbarUtils.dismissLoading();
        SnackbarUtils.showError('图片上传失败：未获取到图片地址');
        return false;

        // 第二步：保存用户头像到服务器
      }

      final response = await ApiClient.to.post(
        'addons/exam/user/save',
        data: {'avatar': newAvatarUrl},
      );

      if (response.statusCode == 200) {
        SnackbarUtils.dismissLoading();
        final body = response.data;
        Map<String, dynamic>? inner;
        if (body is Map && body['data'] is Map) {
          inner = Map<String, dynamic>.from(body['data']);
        } else if (body is Map<String, dynamic>) {
          inner = Map<String, dynamic>.from(body);
        }

        // 更新本地用户信息
        if (inner != null && inner['user'] is Map) {
          final userMap = Map<String, dynamic>.from(inner['user']);
          final updatedUser = UserModel.fromJson(userMap);
          AuthService.to.updateUser(updatedUser);
        } else {
          final currentUser = AuthService.to.user.value;
          if (currentUser != null) {
            AuthService.to
                .updateUser(currentUser.copyWith(avatar: newAvatarUrl));
          }
        }
        SnackbarUtils.showSuccess('头像修改成功');
        return true;
      } else {
        SnackbarUtils.showError('头像修改失败${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      SnackbarUtils.dismissLoading();
      ApiErrorHandler.handleDioError(e, fallbackMessage: '上传失败');
      return false;
    } catch (e) {
      SnackbarUtils.dismissLoading();
      ApiErrorHandler.handleError(e, fallbackMessage: '上传失败');
      return false;
    }
  }
}
