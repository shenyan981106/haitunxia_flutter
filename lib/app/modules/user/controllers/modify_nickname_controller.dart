import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/api_client.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../../services/snackbar_utils.dart';
import '../../../utils/validators.dart';
import '../../../utils/api_error_handler.dart';

class ModifyNicknameController extends GetxController {
  late final TextEditingController textController;
  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    final user = AuthService.to.user.value;
    final currentName = (user?.nickname?.isNotEmpty == true)
        ? user!.nickname!
        : (user?.mobile ?? '');
    textController = TextEditingController(text: currentName);
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  /// 提交修改昵称
  Future<void> submit() async {
    final newName = textController.text.trim();

    // 使用统一验证器验证昵称
    final nicknameError = Validators.validateNickname(newName);
    if (nicknameError != null) {
      SnackbarUtils.showError(nicknameError);
      return;
    }

    if (!AuthService.to.isLoggedIn.value) {
      SnackbarUtils.showError('请先登录后再修改昵称');
      return;
    }

    isSubmitting.value = true;
    try {
      final response = await ApiClient.to.post(
        'addons/exam/user/save',
        data: {'nickname': newName},
      );

      if (response.statusCode == 200) {
        final body = response.data;
        Map<String, dynamic>? inner;
        if (body is Map && body['data'] is Map) {
          inner = Map<String, dynamic>.from(body['data']);
        } else if (body is Map<String, dynamic>) {
          inner = Map<String, dynamic>.from(body);
        }

        if (inner != null && inner['user'] is Map) {
          final userMap = Map<String, dynamic>.from(inner['user']);
          final updatedUser = UserModel.fromJson(userMap);
          AuthService.to.updateUser(updatedUser);
          SnackbarUtils.showSuccess('昵称修改成功');
          Get.back();
        } else {
          SnackbarUtils.showError('昵称修改失败：数据格式错误');
        }
      } else {
        SnackbarUtils.showError('昵称修改失败${response.statusCode}');
      }
    } on DioException catch (e) {
      ApiErrorHandler.handleDioError(e, fallbackMessage: '修改失败');
    } catch (e) {
      ApiErrorHandler.handleError(e, fallbackMessage: '修改失败');
    } finally {
      isSubmitting.value = false;
    }
  }
}
