import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/global_project_controller.dart';
import '../../../../data/providers/api_client.dart';
import '../../../../data/models/category_model.dart';

class QuestionsHomeController extends GetxController {
  // 全局项目控制器，延迟初始化
  late final GlobalProjectController globalController;

  RxInt selectedTabIndex = 0.obs;
  RxInt selectedSubIndex = 0.obs;
  RxList<Category> categories = <Category>[].obs;
  RxList<CategoryChild> subjects = <CategoryChild>[].obs;

  // 加载状态
  bool isLoading = false;

  String errorMessage = '';

  // 页面控制器
  late PageController pageController;

  // Tab滚动控制 用于水平标签滚动
  late ScrollController tabScrollController;

  @override
  void onInit() {
    super.onInit();

    // 初始化 GlobalProjectController，确保服务已注册
    globalController = GlobalProjectController.to;

    // 初始化 PageController
    pageController = PageController(initialPage: selectedSubIndex.value);

    // 初始化 Tab 滚动控制
    tabScrollController = ScrollController();

    // 监听全局项目变化
    ever(globalController.currentProject, (project) {
      if (project != null) {
        fetchSubjects();
      }
    });

    // 初始化时获取科目
    fetchSubjects();
  }

  @override
  void onClose() {
    pageController.dispose();
    tabScrollController.dispose();
    super.onClose();
  }

  void changeSubTab(int index) {
    if (selectedSubIndex.value == index) return;
    selectedSubIndex.value = index;
    if (pageController.hasClients) {
      pageController.jumpToPage(index);
    }
    update();
  }

  void onPageChanged(int index) {
    if (selectedSubIndex.value == index) return;
    selectedSubIndex.value = index;
    update();
  }

  List<String> get tabTitles {
    if (subjects.isEmpty) return [];
    return subjects.map((e) => e.name).toList();
  }

  // 快捷功能入口 (原学习状态数据)
  final List<Map<String, dynamic>> quickActions = [
    {
      'icon': Icons.error_outline,
      'title': '我的错题',
      'route': '/questions',
    },
    {
      'icon': Icons.star_border,
      'title': '我的收藏',
      'route': '/questions',
    },
    {
      'icon': Icons.calendar_today_outlined,
      'title': '每日一练',
      'route': '/questions',
    },
    {
      'icon': Icons.warning_amber_rounded,
      'title': '易错题',
      'route': '/questions',
    },
  ];

  // 功能入口卡片数据 (仿照 HomeView 结构)
  final List<Map<String, dynamic>> functionCards = [
    {
      'icon': Icons.assignment_outlined,
      'title': '章节练习',
      'desc': '全真模拟 智能批改',
      'route': '/questions-list',
      'arguments': {'pageType': 'chapter'},
      'color': Color(0xFF4CAF50),
    },
    {
      'icon': Icons.error_outline,
      'title': '历年真题',
      'desc': '消灭盲点',
      'route': '/questions/questions-elist',
      'arguments': {'type_id': 1},
      'color': Color(0xFFFF9800),
    },
    {
      'icon': Icons.star_border,
      'title': '模拟考试',
      'desc': '全真模拟 智能批改',
      'route': '/questions/questions-elist',
      'arguments': {'type_id': 2},
      'color': Color(0xFF9C27B0),
    },
  ];

  // 动态工具模块（通过接口获取
  final RxList<Map<String, dynamic>> dynamicTools =
      <Map<String, dynamic>>[].obs;

  // 动态 tabs 导航（通过接口获取）
  final RxList<Map<String, dynamic>> dynamicTabs = <Map<String, dynamic>>[].obs;

  // 固定工具模块（一直显示）
  final List<Map<String, dynamic>> fixedTools = [
    {
      'title': '每日一练',
      'desc': '精选好题',
      'icon': 'e662',
      'color': const Color(0xFF52C41A),
      'route': '/questions',
    },
    {
      'title': '我的笔记',
      'desc': '随学随记',
      'icon': 'e6bf',
      'color': const Color(0xFF5B8CFF),
      'route': '/questions/notes',
    },
    {
      'title': '错题本',
      'desc': '查看错题',
      'icon': 'e7fe',
      'color': const Color(0xFFFF7A45),
      'route': '/questions/wrong',
    },
    {
      'title': '题目收藏',
      'desc': '查看收藏',
      'icon': 'e600',
      'color': const Color.fromARGB(255, 230, 35, 77),
      'route': '/questions/favorite',
    },
    {
      'title': '我要反馈',
      'desc': '问题与建议',
      'icon': 'e660',
      'color': const Color(0xFF9254DE),
      'route': '/questions/feedback',
    },
    {
      'title': '快问老师',
      'desc': '老师在线答疑',
      'icon': 'e60d',
      'color': const Color(0xFF13C2C2),
      'route': '/questions/ask',
    },
  ];

  // 获取当前项目名称
  String get currentProjectName => globalController.currentProjectName;

  // 获取当前科目
  CategoryChild? getCurrentSubject() {
    final index = selectedSubIndex.value;
    if (index >= 0 && index < subjects.length) {
      return subjects[index];
    }
    return null;
  }

  // 处理历年真题点击
  void onPastExamsTap() {
    final subject = getCurrentSubject();
    Get.toNamed(
      '/questions/questions-elist',
      arguments: {
        'type_id': 1,
        'subject_id': subject?.id,
      },
    );
  }

  // 处理章节练习点击（不依赖响应式变量）
  void onChapterPracticeTap() {
    final index = selectedSubIndex.value;
    int? subjectId;
    if (index >= 0 && index < subjects.length) {
      subjectId = subjects[index].id;
    }

    Get.toNamed(
      '/questions-list',
      arguments: {
        'pageType': 'chapter',
        'subject_id': subjectId,
        'kind': 'QUESTION',
        'initialIndex': index,
        'categoryId': subjectId,
      },
    );
  }

  // 处理模拟考试点击
  void onMockExamTap() {
    final subject = getCurrentSubject();
    Get.toNamed(
      '/questions/questions-elist',
      arguments: {
        'type_id': 2,
        'subject_id': subject?.id,
      },
    );
  }

  // 处理每日一练点击（不依赖响应式变量）
  void onDailyPracticeTap() {
    final index = selectedSubIndex.value;
    int? subjectId;
    if (index >= 0 && index < subjects.length) {
      subjectId = subjects[index].id;
    }

    Get.toNamed(
      '/questions-list',
      arguments: {
        'pageType': 'daily',
        'subject_id': subjectId,
        'kind': 'QUESTION',
        'initialIndex': index,
      },
    );
  }

  // 处理项目点击事件
  void onProjectTap() {
    // 跳转到项目选择页面
    Get.toNamed('/project');
  }

  // 处理专业切换
  void onMajorChange() {
    // 跳转到project_view.dart
    Get.toNamed('/project');
  }

  Future<void> fetchSubjects() async {
    isLoading = true;
    errorMessage = '';
    update();

    try {
      final response = await ApiClient.to.getExam('subject/index');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 1) {
          final List<dynamic> categoryData = data['data'] ?? [];
          categories.assignAll(
              categoryData.map((item) => Category.fromJson(item)).toList());

          subjects.clear();

          if (categories.isNotEmpty) {
            final currentProject = globalController.currentProject.value;
            CategoryChild? target;

            // 1. 尝试通过 ID 匹配（更准确）
            if (currentProject != null) {
              for (final category in categories) {
                for (final child in category.children) {
                  if (child.id.toString() == currentProject.id) {
                    target = child;
                    break;
                  }
                }
                if (target != null) break;
              }
            }

            // 2. 如果 ID 匹配失败，尝试通过名称匹配（兼容旧逻辑）
            if (target == null && currentProject != null) {
              final currentName = currentProject.name;
              for (final category in categories) {
                for (final child in category.children) {
                  if (child.name == currentName) {
                    target = child;
                    break;
                  }
                }
                if (target != null) break;
              }
            }

            // 3. 如果还是没有匹配到，默认使用第一个有子项的分类
            if (target == null) {
              for (final category in categories) {
                if (category.children.isNotEmpty) {
                  target = category.children.first;
                  break;
                }
              }
            }

            if (target != null && target.children.isNotEmpty) {
              subjects.assignAll(target.children);
              selectedTabIndex.value = 0;
              selectedSubIndex.value = 0;
              // 获取动态工具模块和 tabs 导航
              fetchDynamicTools(target.id);
            } else {
              errorMessage = '暂无子分类数据';
            }
          } else {
            errorMessage = '暂无科目数据';
          }
        } else {
          errorMessage = data['msg']?.toString() ?? '获取科目数据失败';
        }
      } else {
        errorMessage = '网络请求失败，请稍后重试';
      }
    } catch (_) {
      errorMessage = '网络错误，请检查网络连接';
    } finally {
      // 如果没有获取到科目数据，使用默认数据（为了界面展示效果）
      if (subjects.isEmpty) {
        subjects.assignAll([
          CategoryChild(id: 101, name: '经济基础', parentId: 0, weigh: 0),
          CategoryChild(id: 102, name: '专业实务', parentId: 0, weigh: 0),
        ]);
        if (selectedSubIndex.value >= subjects.length) {
          selectedSubIndex.value = 0;
        }
      }

      isLoading = false;
      update();
    }
  }

  // 获取动态页面配置（addons/exam/question/getPageConfig）
  Future<void> fetchDynamicTools(int subjectId) async {
    try {
      final response = await ApiClient.to.getExam(
        'paper/getPageConfig',
        queryParameters: {'subject_id': subjectId},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        debugPrint('getPageConfig API返回: $data');

        if (data['code'] == 1) {
          final dataMap = data['data'];
          if (dataMap == null || dataMap is! Map) return;

          // 清空现有数据
          dynamicTools.clear();
          dynamicTabs.clear();

          // 后端返回格式：{ code: 1, data: { list: [...] } }
          final toolsData = (dataMap['list'] as List?) ?? [];

          for (var item in toolsData) {
            if (item is! Map) continue;

            final title = item['title']?.toString() ?? '';
            final desc = item['desc']?.toString() ?? '';
            final icon = item['icon']?.toString() ?? '';
            final colorStr = item['color']?.toString();
            final uses = item['uses']?.toString() ?? '';

            // 根据 title/uses 匹配路由和参数
            final routeInfo = _resolveRouteByTitle(title, uses);
            final rawId = item['id'];

            // 动态配置项：统一使用 pageConfig 模式进入做题
            String route = '/question-train';
            Map<String, dynamic> arguments = {
              'pageType': 'page_config',
              'pageConfigId': rawId,
              'title': title,
            };

            final toolItem = <String, dynamic>{
              'title': title,
              'desc': desc,
              'icon': icon,
              'color': _parseColor(colorStr),
              'route': route,
              'arguments': arguments,
              'uses': uses,
              'is_yu': item['is_yu'] ?? false,
              'is_hot': item['is_hot'] ?? false,
              'raw': Map<String, dynamic>.from(item),
            };

            dynamicTools.add(toolItem);
          }

          debugPrint('动态页面配置数量：${dynamicTools.length}');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('获取 getPageConfig 失败：$e');
      debugPrint('堆栈：$stackTrace');
    }
  }

  /// 根据标题匹配对应的路由和参数
  Map<String, dynamic> _resolveRouteByTitle(String title, String uses) {
    final t = title.toLowerCase();
    if (t.contains('章节') || t.contains('练习')) {
      return {
        'route': '/questions-list',
        'arguments': {'pageType': 'chapter'}
      };
    } else if (t.contains('真题') || t.contains('历年')) {
      return {
        'route': '/questions/questions-elist',
        'arguments': {'type_id': 1}
      };
    } else if (t.contains('模拟') || t.contains('考试')) {
      return {
        'route': '/questions/questions-elist',
        'arguments': {'type_id': 2}
      };
    } else if (t.contains('每日') || t.contains('一练')) {
      return {
        'route': '/questions-list',
        'arguments': {'pageType': 'daily'}
      };
    } else if (t.contains('错题') || t.contains('错题本')) {
      return {'route': '/questions/wrong', 'arguments': {}};
    } else if (t.contains('收藏') || t.contains('题目收藏')) {
      return {'route': '/questions/favorite', 'arguments': {}};
    } else if (t.contains('笔记') || t.contains('我的笔记')) {
      return {'route': '/questions/notes', 'arguments': {}};
    } else if (t.contains('反馈') || t.contains('我要反馈')) {
      return {'route': '/questions/feedback', 'arguments': {}};
    } else if (t.contains('快问') || t.contains('老师')) {
      return {'route': '/questions/ask', 'arguments': {}};
    } else if (t.contains('易错')) {
      return {'route': '/questions/wrong', 'arguments': {}};
    }
    // 默认不设置路由，View 层可忽略无路由的项
    return {'route': '', 'arguments': <String, dynamic>{}};
  }

  // 解析颜色
  Color _parseColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty) {
      return const Color(0xFF5B8CFF);
    }
    try {
      // 移除#号
      colorStr = colorStr.replaceAll('#', '');
      // 如果是 6 位颜色
      if (colorStr.length == 6) {
        return Color(int.parse('FF$colorStr', radix: 16));
      }
      // 如果是 8 位颜色
      if (colorStr.length == 8) {
        return Color(int.parse(colorStr, radix: 16));
      }
    } catch (_) {
      // 解析失败使用默认颜色
    }
    return const Color(0xFF5B8CFF);
  }
}
