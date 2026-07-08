import 'package:get/get.dart';
import '../../../data/providers/api_client.dart';
import '../../../services/snackbar_utils.dart';

class DeleteAccountController extends GetxController {
  final RxBool isAgreed = false.obs;
  final RxString agreementContent = ''.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchAgreement();
  }

  /// 切换同意状态
  void toggleAgreed() {
    isAgreed.value = !isAgreed.value;
  }

  /// 获取注销协议
  Future<void> _fetchAgreement() async {
    try {
      final response = await ApiClient.to.get(
        'addons/exam/common/richtextContent',
        queryParameters: {'id': 4},
      );

      final data = response.data;
      String content = '';

      if (data is Map) {
        final innerData = data['data'];
        if (innerData is Map) {
          content = innerData['content']?.toString() ?? '';
        } else {
          content = data['content']?.toString() ?? '';
        }
      } else if (data is String) {
        content = data;
      }

      agreementContent.value = content.isEmpty ? '暂无协议内容' : content;
    } catch (e) {
      agreementContent.value = '加载协议内容失败: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// 提交注销请求
  Future<void> submitLogoutRequest() async {
    try {
      SnackbarUtils.showLoading(msg: '提交中...');

      final response = await ApiClient.to.post(
        'addons/exam/user/userLogoutRequest',
        data: {
          'reason': '用户主动申请注销账号',
        },
      );

      SnackbarUtils.dismissLoading();

      final data = response.data;
      if (data is Map && data['code'] == 1) {
        SnackbarUtils.showSuccess('注销请求提交成功，请等待审核');
      } else {
        final msg = data is Map ? data['msg'] : '提交失败';
        SnackbarUtils.showError(msg?.toString() ?? '注销请求提交失败');
      }
    } catch (e) {
      SnackbarUtils.dismissLoading();
      SnackbarUtils.showError('提交失败：${e}');
    }
  }
}
