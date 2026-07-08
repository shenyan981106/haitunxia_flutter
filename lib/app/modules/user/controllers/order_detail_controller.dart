import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../services/snackbar_utils.dart';

class OrderDetailController extends GetxController {
  // 订单数据（从路由参数传入）
  final Rxn<Map<String, dynamic>> order = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      order.value = args;
    }
  }

  /// 复制交易单号到剪贴板
  Future<void> copyOrderNo(String orderNo) async {
    await Clipboard.setData(ClipboardData(text: orderNo));
    SnackbarUtils.showSuccess('已复制到剪贴板');
  }
}
