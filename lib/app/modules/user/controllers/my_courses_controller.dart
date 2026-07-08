import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart' as dio;
import '../../../data/providers/api_client.dart';

class MyCoursesController extends GetxController {
  // 课程订单列表
  final RxList<Map<String, dynamic>> courseOrderList =
      <Map<String, dynamic>>[].obs;

  // 加载状态
  RxBool isLoading = false.obs;

  // 当前选中的科目ID
  RxString currentSubjectId = ''.obs;

  /// 设置科目并刷新列表
  void setSubjectId(String subjectId) {
    currentSubjectId.value = subjectId;
    getMyCourseList();
  }

  @override
  void onInit() {
    super.onInit();
    // 从路由参数获取subject_id
    final args = Get.arguments;
    if (args is Map && args['subject_id'] != null) {
      currentSubjectId.value = args['subject_id'].toString();
    }
  }

  @override
  void onReady() {
    super.onReady();
    getMyCourseList();
  }

  /// 获取我的课程列表
  Future<void> getMyCourseList() async {
    isLoading.value = true;
    try {
      final queryParams = <String, dynamic>{};
      if (currentSubjectId.value.isNotEmpty) {
        queryParams['subject_id'] = currentSubjectId.value;
      }

      var response = await ApiClient.to
          .get('addons/exam/Coures/myList', queryParameters: queryParams);

      if (response.data != null) {
        var body = response.data;
        List? list;

        if (body is Map && (body['code'] == 1 || body['code'] == 200)) {
          var data = body['data'];
          if (data is Map && data['list'] is List) {
            list = data['list'];
          }
        }

        if (list != null && list.isNotEmpty) {
          courseOrderList.value =
              list.map((e) => Map<String, dynamic>.from(e)).toList();
        } else {
          courseOrderList.clear();
        }
      }
    } catch (e) {
      debugPrint("获取我的课程列表失败: $e");
      if (e is dio.DioException) {
        debugPrint("错误详情: ${e.response?.data}");
      }
      courseOrderList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// 下拉刷新
  Future<void> onRefresh() async {
    await getMyCourseList();
  }
}
