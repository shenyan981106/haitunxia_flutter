import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/providers/api_client.dart';
import '../../../data/repositories/exam_repository.dart';
import '../../../services/snackbar_utils.dart';
import '../../../utils/validators.dart';

class QuestionFeedbackController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final RxList<XFile> images = <XFile>[].obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isUploading = false.obs;

  final ImagePicker _picker = ImagePicker();
  final ExamRepository _examRepository = ExamRepository.to;

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  /// 选择图片
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 80,
    );
    if (image != null) {
      images.add(image);
    }
  }

  /// 移除图片
  void removeImage(int index) {
    if (index >= 0 && index < images.length) {
      images.removeAt(index);
    }
  }

  /// 提交反馈
  Future<void> submit() async {
    final content = textController.text.trim();

    // 使用统一验证器验证必填字段
    final contentError =
        Validators.validateRequired(content, fieldName: '问题描述');
    if (contentError != null) {
      SnackbarUtils.showWarning(contentError);
      return;
    }

    isSubmitting.value = true;
    try {
      final data = <String, dynamic>{'description': content};

      // 先上传图片，获取URL
      if (images.isNotEmpty) {
        isUploading.value = true;
        final List<String> imageUrls = [];
        for (final image in images) {
          final result = await _examRepository.uploadImage(image.path);
          if (result.isSuccess && (result.data?.isNotEmpty ?? false)) {
            imageUrls.add(result.data!);
          }
        }
        if (imageUrls.isNotEmpty) {
          data['images'] = imageUrls.join(',');
        }
        isUploading.value = false;
      }

      final response = await ApiClient.to.exam(
        'user/submitReport',
        method: 'POST',
        data: data,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map &&
            (responseData['code'] == 1 || responseData['code'] == 200)) {
          SnackbarUtils.showSuccess(responseData['msg']?.toString() ?? '提交成功');
          textController.clear();
          images.clear();
          Future.delayed(const Duration(seconds: 1), () {
            Get.back();
          });
        } else {
          SnackbarUtils.showError(
              responseData['msg']?.toString() ?? '提交失败，请重试');
        }
      } else {
        SnackbarUtils.showError('提交失败，请稍后重试');
      }
    } catch (e) {
      SnackbarUtils.showError('提交失败，请稍后重试');
    } finally {
      isSubmitting.value = false;
    }
  }
}
