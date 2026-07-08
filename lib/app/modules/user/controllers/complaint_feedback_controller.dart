import 'package:get/get.dart';
import '../../../data/repositories/exam_repository.dart';
import '../../../services/snackbar_utils.dart';
import '../../../utils/validators.dart';

class ComplaintFeedbackController extends GetxController {
  final ExamRepository _repository = ExamRepository.to;

  final RxBool isLoading = false.obs;
  final RxString selectedReason = '其他'.obs;
  final RxString description = ''.obs;
  final RxString pageUrl = ''.obs;

  final List<String> reasonOptions = [
    '欺诈',
    '色情低俗',
    '血腥暴',
    '传播不实信息',
    '侵权',
    '账号问题',
    '违法犯罪',
    '诽谤他人',
    '恶意营销',
    '其他',
  ];

  void selectReason(String reason) {
    selectedReason.value = reason;
  }

  void updateDescription(String value) {
    description.value = value;
  }

  void updatePageUrl(String value) {
    pageUrl.value = value;
  }

  Future<void> submitReport() async {
    // 使用统一验证器验证必填字段
    final pageUrlError =
        Validators.validateRequired(pageUrl.value.trim(), fieldName: '举报页面链接');
    if (pageUrlError != null) {
      SnackbarUtils.showError(pageUrlError);
      return;
    }

    final descriptionError = Validators.validateRequired(
        description.value.trim(),
        fieldName: '详细描述');
    if (descriptionError != null) {
      SnackbarUtils.showError(descriptionError);
      return;
    }

    isLoading.value = true;

    try {
      final response = await _repository.submitReport({
        'page_url': pageUrl.value.trim(),
        'reason': selectedReason.value,
        'description': description.value.trim(),
      });

      if (response.isSuccess) {
        SnackbarUtils.showSuccess('提交成功');
        Get.back();
      } else {
        SnackbarUtils.showError(response.message ?? '提交失败');
      }
    } catch (e) {
      SnackbarUtils.showError('提交失败，请稍后重试');
    } finally {
      isLoading.value = false;
    }
  }
}
