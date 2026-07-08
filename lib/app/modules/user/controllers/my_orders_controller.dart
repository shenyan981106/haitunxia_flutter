import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart' as dio;
import '../../../data/providers/api_client.dart';

class MyOrdersController extends GetxController {
  // 订单列表
  final RxList<Map<String, dynamic>> orderList = <Map<String, dynamic>>[].obs;

  // 加载状态
  RxBool isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    getMyOrderList();
  }

  /// 获取我的订单列表
  Future<void> getMyOrderList() async {
    isLoading.value = true;
    try {
      var response = await ApiClient.to.get('addons/exam/Coures/myList');

      if (response.data != null) {
        var body = response.data;
        List? list;

        if (body is Map && (body['code'] == 1 || body['code'] == 200)) {
          var data = body['data'];
          if (data is Map && data['list'] is List) {
            list = data['list'];
          } else if (data is List) {
            list = data;
          }
        }

        if (list != null && list.isNotEmpty) {
          orderList.value =
              list.map((e) => Map<String, dynamic>.from(e)).toList();
        } else {
          orderList.clear();
        }
      }
    } catch (e) {
      debugPrint("获取我的订单列表失败: $e");
      if (e is dio.DioException) {
        debugPrint("错误详情: ${e.response?.data}");
      }
      orderList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// 下拉刷新
  Future<void> onRefresh() async {
    await getMyOrderList();
  }
}
