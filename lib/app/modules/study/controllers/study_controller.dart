// study_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import '../../../data/providers/api_client.dart';
import '../../../config/env_config.dart';
import '../../../services/global_project_controller.dart';
import '../../../services/snackbar_utils.dart';

class StudyController extends GetxController {
  // 当前选中的导航索引
  RxInt currentNavIndex = 0.obs;

  // 原始课程数据列表（缓存从接口获取的所有数据）
  final List<Map<String, dynamic>> _allCourseList = [];

  // 用于界面显示的响应式列表（根据筛选条件排序后的结果）
  final RxList<Map<String, dynamic>> courseList = <Map<String, dynamic>>[].obs;

  final ScrollController scrollController = ScrollController();

  // 加载状态
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxBool hasMore = true.obs;

  int _currentPage = 1;
  static const int _pageSize = 10;

  DateTime? _lastVisibleRefreshAt;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    // 监听全局项目切换，项目改变时自动刷新课程列表
    ever(GlobalProjectController.to.currentProject, (project) {
      debugPrint(
          "🔔 检测到项目切换: ${project?.name} (ID: ${project?.id})，正在刷新课程列表...");
      getCourseList();
    });
  }

  @override
  void onReady() {
    super.onReady();
    // 页面准备就绪后获取课程列表
    getCourseList();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  // 筛选排序
  final RxInt currentFilterIndex = 0.obs;
  final List<String> filterList = ["最热", "最新", "低价优先", "高价优先"];

  // 改变筛选索引（前端本地排序）
  void changeFilterIndex(int index) {
    debugPrint("🔘 切换筛选索引 $index (${filterList[index]})");
    currentFilterIndex.value = index;
    _applyLocalSort();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      loadMoreCourseList();
    }
  }

  /// 页面再次显示时刷新，避免 KeepAlive 页面只加载一次导致课程列表不更新。
  Future<void> refreshWhenVisible({bool force = false}) async {
    if (isLoading.value || isLoadingMore.value) return;

    final now = DateTime.now();
    if (!force &&
        _lastVisibleRefreshAt != null &&
        now.difference(_lastVisibleRefreshAt!) < const Duration(seconds: 2)) {
      return;
    }

    _lastVisibleRefreshAt = now;
    await getCourseList();
  }

  // 执行本地排序逻辑
  void _applyLocalSort() {
    if (_allCourseList.isEmpty) {
      courseList.value = [];
      return;
    }

    List<Map<String, dynamic>> sortedList = List.from(_allCourseList);

    switch (currentFilterIndex.value) {
      case 0: // 最热：按照报名人数 (total_students) 降序排列
        sortedList.sort((a, b) {
          int studentsA =
              int.tryParse(a['total_students']?.toString() ?? '0') ?? 0;
          int studentsB =
              int.tryParse(b['total_students']?.toString() ?? '0') ?? 0;
          return studentsB.compareTo(studentsA);
        });
        break;
      case 1: // 最新：按照创建时间 (createtime) 降序排列
        sortedList.sort((a, b) {
          int timeA = int.tryParse(a['createtime']?.toString() ?? '0') ?? 0;
          int timeB = int.tryParse(b['createtime']?.toString() ?? '0') ?? 0;
          return timeB.compareTo(timeA);
        });
        break;
      case 2: // 低价优先：price 升序
        sortedList.sort((a, b) {
          double priceA = double.tryParse(a['price']?.toString() ?? '0') ?? 0.0;
          double priceB = double.tryParse(b['price']?.toString() ?? '0') ?? 0.0;
          return priceA.compareTo(priceB);
        });
        break;
      case 3: // 高价优先：price 降序
        sortedList.sort((a, b) {
          double priceA = double.tryParse(a['price']?.toString() ?? '0') ?? 0.0;
          double priceB = double.tryParse(b['price']?.toString() ?? '0') ?? 0.0;
          return priceB.compareTo(priceA);
        });
        break;
    }

    courseList.value = sortedList;
  }

  Future<void> getCourseList() async {
    if (isLoading.value || isLoadingMore.value) return;

    _currentPage = 1;
    hasMore.value = true;
    isLoading.value = true;

    try {
      await _loadCoursePage(page: _currentPage, refresh: true);
    } catch (e) {
      _handleCourseListError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreCourseList() async {
    if (isLoading.value || isLoadingMore.value || !hasMore.value) return;

    final nextPage = _currentPage + 1;
    isLoadingMore.value = true;

    try {
      await _loadCoursePage(page: nextPage, refresh: false);
    } catch (e) {
      _handleCourseListError(e);
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> _loadCoursePage({
    required int page,
    required bool refresh,
  }) async {
    final params = _buildCourseListParams(page);
    const apiPath = 'addons/exam/coures/index';
    final queryString =
        params.entries.map((e) => "${e.key}=${e.value}").join("&");
    debugPrint("🚀 正在发起 XHR 请求: ${EnvConfig.baseUrl}$apiPath?$queryString");

    final response = await ApiClient.to.get(apiPath, queryParameters: params);
    final body = response.data;
    final list = _extractCourseList(body);

    if (list == null) {
      debugPrint("未能在返回数据中解析到列表，body: $body");
      if (refresh) {
        _allCourseList.clear();
        courseList.value = [];
      }
      hasMore.value = false;
      return;
    }

    final newCourses = list.map((e) => Map<String, dynamic>.from(e)).toList();

    if (refresh) {
      _allCourseList
        ..clear()
        ..addAll(newCourses);
    } else {
      _allCourseList.addAll(newCourses);
    }

    _currentPage = page;
    hasMore.value = _resolveHasMore(body, page, newCourses.length);
    _applyLocalSort();

    debugPrint(
        "成功解析到课程列表，page: $page，新增: ${newCourses.length}，hasMore: ${hasMore.value}");
  }

  Map<String, dynamic> _buildCourseListParams(int page) {
    final params = <String, dynamic>{
      'page': page,
      '_t': DateTime.now().millisecondsSinceEpoch,
    };

    final currentProjectId =
        GlobalProjectController.to.currentProject.value?.id;
    if (currentProjectId != null && currentProjectId.toString().isNotEmpty) {
      params['subject_id'] = currentProjectId.toString();
    } else {
      debugPrint("⚠️ 未检测到全局项目 ID，正在使用默认项目ID 5 进行数据请求");
      params['subject_id'] = "5";
    }

    return params;
  }

  dynamic _extractListContainer(dynamic body) {
    if (body is! Map || (body['code'] != 1 && body['code'] != 200)) {
      return null;
    }

    final data = body['data'];
    if (data is Map && data.containsKey('list')) {
      return data['list'];
    }
    return data;
  }

  List? _extractCourseList(dynamic body) {
    final listContainer = _extractListContainer(body);

    if (listContainer is Map) {
      if (listContainer['data'] is List) {
        return listContainer['data'];
      }
      if (listContainer['list'] is List) {
        return listContainer['list'];
      }
    }

    if (listContainer is List) {
      return listContainer;
    }

    return null;
  }

  bool _resolveHasMore(dynamic body, int page, int loadedCount) {
    final listContainer = _extractListContainer(body);

    if (listContainer is Map) {
      final currentPage =
          int.tryParse(listContainer['current_page']?.toString() ?? '') ?? page;
      final lastPage =
          int.tryParse(listContainer['last_page']?.toString() ?? '');
      if (lastPage != null) {
        return currentPage < lastPage;
      }

      final total = int.tryParse(listContainer['total']?.toString() ?? '');
      final perPage =
          int.tryParse(listContainer['per_page']?.toString() ?? '') ??
              _pageSize;
      if (total != null) {
        return currentPage * perPage < total;
      }
    }

    return loadedCount >= _pageSize;
  }

  void _handleCourseListError(Object e) {
    debugPrint("获取课程列表失败: $e");
    if (e is dio.DioException) {
      debugPrint("错误详情: ${e.response?.data}");
      SnackbarUtils.showError("服务器错误 ${e.response?.statusCode}，数据获取失败");
    } else {
      SnackbarUtils.showError("获取课程列表失败");
    }
  }

  // 设置当前导航索引
  void setCurrentNavIndex(int index) {
    currentNavIndex.value = index;
  }

  // 跳转到课程详情页
  void goToCourseDetail(Map<String, dynamic> course) {
    // 提取课程ID并传递给详情页
    final courseId = course['id']?.toString();
    if (courseId != null) {
      Get.toNamed('/study/details', arguments: courseId);
    } else {
      SnackbarUtils.showError("课程ID不存在");
    }
  }

  // 获取过滤后的课程列表（根据当前选中的导航项过滤）
  List<Map<String, dynamic>> get filteredCourses {
    // 根据当前选中的导航索引返回对应的课程列表
    // 这里为了演示，我们简单返回不同的课程数据
    // 实际项目中，你可能需要根据导航项的ID或名称来过滤
    return courseList.toList();
  }
}
