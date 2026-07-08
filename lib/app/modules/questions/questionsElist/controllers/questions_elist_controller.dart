import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/global_project_controller.dart';
import '../../../../data/providers/api_client.dart';
import '../../../../data/models/category_model.dart';

class QuestionsElistController extends GetxController {
  // 全局项目控制器
  late final GlobalProjectController globalController;

  // 页面类型：历年真题/模拟考试
  final pageType = 1.obs;

  // 页面标题
  final pageTitle = '历年真题'.obs;

  // 当前项目名称
  final currentProjectName = ''.obs;

  // 考试倒计时天数
  final daysToExam = 0.obs;

  // 当前选中tab 索引
  final selectedTabIndex = 0.obs;
  final selectedSubIndex = 0.obs;

  // 列表数据
  final examPapers = <Map<String, dynamic>>[].obs;

  // 加载状态
  final isLoading = false.obs;

  // 科目列表（tabs）
  final subjects = <CategoryChild>[].obs;

  // 页面控制器
  late PageController pageController;

  @override
  void onInit() {
    super.onInit();

    globalController = GlobalProjectController.to;

    // 接收路由参数
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      final typeId = args['type_id'];
      if (typeId != null) {
        pageType.value =
            typeId is int ? typeId : int.tryParse(typeId.toString()) ?? 1;
        pageTitle.value = pageType.value == 2 ? '模拟考试' : '历年真题';
      }
    }

    pageController = PageController(initialPage: selectedSubIndex.value);

    // 设置初始项目名称
    final project = globalController.currentProject.value;
    if (project != null) {
      currentProjectName.value = project.name ?? '';
    }
    daysToExam.value = globalController.daysToExam.value;

    // 监听全局项目变化
    ever(globalController.currentProject, (project) {
      if (project != null) {
        currentProjectName.value = project.name ?? '';
        fetchSubjects().then((_) => loadExamPapers());
      }
    });

    // 监听考试天数
    ever(globalController.daysToExam, (days) {
      daysToExam.value = days;
    });

    // 加载科目和试卷数
    fetchSubjects().then((_) => loadExamPapers());
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  // 切换 tab
  void changeTab(int index) {
    if (selectedTabIndex.value == index) return;
    selectedTabIndex.value = index;
    loadExamPapers();
  }

  // 切换子tab
  void changeSubTab(int index) {
    if (selectedSubIndex.value == index) return;
    selectedSubIndex.value = index;
    if (pageController.hasClients) {
      pageController.jumpToPage(index);
    }
    loadExamPapers();
  }

  // 页面变化
  void onPageChanged(int index) {
    if (selectedSubIndex.value == index) return;
    selectedSubIndex.value = index;
    loadExamPapers();
  }

  // 获取tab标题
  List<String> get tabTitles {
    if (subjects.isEmpty) return [];
    return subjects.map((e) => e.name ?? '').toList();
  }

  /// 获取科目列表（当前项目下的子分类）
  Future<void> fetchSubjects() async {
    try {
      isLoading.value = true;

      final project = globalController.currentProject.value;
      if (project == null || project.id == null) {
        subjects.clear();
        isLoading.value = false;
        return;
      }

      final response = await ApiClient.to.getExam(
        'subject/index',
        queryParameters: {'project_id': project.id},
      );

      if (response.statusCode == 200 && response.data['code'] == 1) {
        final List<dynamic> dataList = response.data['data'] ?? [];
        subjects.clear();

        // 查找当前项目下的子分类
        for (var data in dataList) {
          // 如果当前数据就是当前项目，取其 children 作为子分类
          if (data['id']?.toString() == project.id) {
            final children = data['children'];
            if (children != null && children is List) {
              for (var child in children) {
                subjects.add(CategoryChild.fromJson(child));
              }
            }
            break;
          }

          // 否则在当前项目的 children 中查找
          if (data['children'] != null && data['children'] is List) {
            for (var child in data['children']) {
              if (child['id']?.toString() == project.id) {
                // 找到了当前项目，取其 children 作为子分类
                final grandChildren = child['children'];
                if (grandChildren != null && grandChildren is List) {
                  for (var grandChild in grandChildren) {
                    subjects.add(CategoryChild.fromJson(grandChild));
                  }
                }
                break;
              }
            }
          }
        }

        if (subjects.isNotEmpty) {
          selectedSubIndex.value = 0;
        }
      }

      isLoading.value = false;
    } catch (e) {
      subjects.clear();
      isLoading.value = false;
    }
  }

  /// 加载试卷数据
  Future<void> loadExamPapers() async {
    try {
      isLoading.value = true;

      // 确保科目列表已加载
      if (subjects.isEmpty) {
        await fetchSubjects();
      }

      final subject =
          subjects.isNotEmpty && selectedSubIndex.value < subjects.length
              ? subjects[selectedSubIndex.value]
              : null;

      final response = await ApiClient.to.getExam(
        'paper/index',
        queryParameters: {
          if (subject != null) 'subject_id': subject.id,
        },
      );

      if (response.statusCode == 200 && response.data['code'] == 1) {
        final data = response.data['data'];
        final List<dynamic> list = data is Map ? (data['list'] ?? []) : [];

        // 根据页面类型筛选：PASTEXAM=历年真题, MOCKEXAM=模拟考试
        final targetType = pageType.value == 2 ? 'MOCKEXAM' : 'PASTEXAM';
        final filteredList =
            list.where((item) => item['type'] == targetType).toList();

        examPapers.assignAll(
          filteredList.map((e) => Map<String, dynamic>.from(e)).toList(),
        );
      } else {
        examPapers.clear();
      }

      isLoading.value = false;
    } catch (e) {
      examPapers.clear();
      isLoading.value = false;
    }
  }

  /// 点击试卷 - 跳转到答题界面
  void onPaperTap(Map<String, dynamic> paper) {
    final paperId = paper['id'];
    final title = paper['title'] ?? '';
    final limitTime = paper['limit_time'] ?? 0;
    final totalScore = paper['total_score'] ?? 0;
    final passScore = paper['pass_score'] ?? 0;
    final joinCount = paper['join_count'] ?? 0;

    // 根据页面类型设置模式：历年真题和模拟考试都使用 EXAM 模式
    final mode = 'EXAM';

    Get.toNamed(
      '/question-train',
      arguments: {
        'paper_id': paperId,
        'title': title,
        'limit_time': limitTime,
        'total_score': totalScore,
        'pass_score': passScore,
        'join_count': joinCount,
        'mode': mode,
        'pageType': pageType.value == 2 ? 'mock' : 'past',
      },
    );
  }

  /// 点击项目选择
  void onProjectTap() {
    Get.toNamed('/project');
  }
}
