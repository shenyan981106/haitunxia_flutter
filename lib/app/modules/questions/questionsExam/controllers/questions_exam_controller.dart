import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../services/global_project_controller.dart';
import '../../../../data/providers/api_client.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/project_model.dart';

class QuestionsExamController extends GetxController {
  // 全局项目控制器 - 延迟初始化
  late final GlobalProjectController globalController;

  // 页面类型：must_brush, past_exams, mock_exams
  final String pageType;

  QuestionsExamController({required this.pageType});

  // 科目列表
  RxList<Category> categories = <Category>[].obs;
  RxList<CategoryChild> subjects = <CategoryChild>[].obs;
  final RxInt currentSubjectIndex = 0.obs;

  // 加载状态
  bool isLoading = false;
  String errorMessage = '';

  List<String> get tabTitles {
    if (subjects.isEmpty) return [];
    return subjects.map((e) => e.name).toList();
  }

  // 课程数据
  final List<Map<String, dynamic>> courses = [
    {
      'image':
          'https://neeko-copilot.bytedance.net/api/text2image?prompt=online%20course%20cover%20math&size=512x512',
      'type': '直播',
      'title': '高等数学必刷母题精讲',
      'teacher': '张老师',
      'progress': '已更新2/20课时',
      'watched': '已观看课时'
    },
    {
      'image':
          'https://neeko-copilot.bytedance.net/api/text2image?prompt=online%20course%20cover%20english&size=512x512',
      'type': '录播',
      'title': '英语历年真题解析',
      'teacher': '李老师',
      'progress': '已更新5/15课时',
      'watched': '已观看课时'
    },
    {
      'image':
          'https://neeko-copilot.bytedance.net/api/text2image?prompt=online%20course%20cover%20computer&size=512x512',
      'type': '直播',
      'title': '计算机基础模拟考试',
      'teacher': '王老师',
      'progress': '已更新0/12课时',
      'watched': '已观看课时'
    },
  ];

  // 页面控制器
  late PageController pageController;

  // 试卷列表缓存 Map<subjectId, List<ExamPaper>>
  RxMap<int, List<Map<String, dynamic>>> examPapersMap =
      <int, List<Map<String, dynamic>>>{}.obs;

  // 试卷加载状态 Map<subjectId, bool>
  RxMap<int, bool> isExamLoadingMap = <int, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // 在 onInit 中获取 GlobalProjectController，确保服务已注册
    globalController = GlobalProjectController.to;
    pageController = PageController(initialPage: currentSubjectIndex.value);

    if (pageType == 'chapter_detail') {
      final args = Get.arguments;
      if (args != null && args is Map) {
        if (args['sections'] != null && args['sections'] is List) {
          final sectionsList = args['sections'] as List;
          final newSubjects = sectionsList.map<CategoryChild>((section) {
            final raw = section['raw'] ?? {};
            int id = 0;
            if (raw['id'] != null) {
              id = int.tryParse(raw['id'].toString()) ?? 0;
            }
            return CategoryChild(
              id: id,
              name: section['title'] ?? '',
              parentId: 0,
              weigh: 0,
              children: [],
            );
          }).toList();
          subjects.assignAll(newSubjects);

          if (subjects.isNotEmpty) {
            currentSubjectIndex.value = 0;
            fetchExamPapers(subjects[0].id);
          }
        }
      }
    } else {
      fetchSubjects();

      // 监听全局项目变化
      ever<Project?>(globalController.currentProject, (project) {
        if (project != null) {
          fetchSubjects();
        }
      });
    }

    // 监听科目切换，获取对应试卷列表
    ever(currentSubjectIndex, (index) {
      if (subjects.isNotEmpty && index >= 0 && index < subjects.length) {
        final subjectId = subjects[index].id;
        // 如果该科目没有数据且未在加载中，则请求数据
        if (!examPapersMap.containsKey(subjectId)) {
          fetchExamPapers(subjectId);
        }
      }
    });
  }

  // 获取试卷列表
  Future<void> fetchExamPapers(int subjectId) async {
    // 如果正在加载，则忽略
    if (isExamLoadingMap[subjectId] == true) return;

    isExamLoadingMap[subjectId] = true;

    try {
      // 调用 paper/index 接口，传递 subject_id 参数
      final response = await ApiClient.to
          .getExam('paper/index', queryParameters: {'subject_id': subjectId});

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 1) {
          final listData = data['data']['list']['data'];
          if (listData != null && listData is List) {
            examPapersMap[subjectId] =
                List<Map<String, dynamic>>.from(listData);
          } else {
            examPapersMap[subjectId] = [];
          }
        }
      }
    } catch (e) {
      print('Fetch exam papers error: $e');
      // 出错时也设为空列表，避免无限重试
      if (!examPapersMap.containsKey(subjectId)) {
        examPapersMap[subjectId] = [];
      }
    } finally {
      isExamLoadingMap[subjectId] = false;
    }
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
            final currentName = globalController.currentProjectName;
            CategoryChild? target;

            for (final category in categories) {
              for (final child in category.children) {
                if (child.name == currentName) {
                  target = child;
                  break;
                }
              }
              if (target != null) {
                break;
              }
            }

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
              currentSubjectIndex.value = 0;
              // 初始加载第一个科目的试卷
              fetchExamPapers(target.children[0].id);
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
      isLoading = false;
      update();
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  // 设置当前科目索引（点击Tab调用）
  void setCurrentSubjectIndex(int index) {
    if (currentSubjectIndex.value == index) return;
    currentSubjectIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // 页面滑动回调
  void onPageChanged(int index) {
    if (currentSubjectIndex.value == index) return;
    currentSubjectIndex.value = index;
  }

  // 每个Tab的颜色主题（使用MaterialColor或Color）
  List<MaterialColor> get tabThemeColors {
    switch (pageType) {
      case 'must_brush':
        return [
          Colors.blue, // 历史 - 蓝色
          Colors.blue, // 英语 - 蓝色
          Colors.blue, // 马原 - 蓝色
          Colors.blue, // 高数 - 蓝色
          Colors.blue, // 语文 - 蓝色
        ];
      case 'past_exams':
        return [
          Colors.teal, // 2025 - 青色
          Colors.teal, // 2024 - 青色
          Colors.teal, // 2023 - 青色
          Colors.teal, // 2022 - 青色
          Colors.teal, // 2021 - 青色
        ];
      case 'mock_exams':
        return [
          Colors.purple, // 模拟一 - 紫色
          Colors.purple, // 模拟二 - 紫色
          Colors.purple, // 模拟三 - 紫色
          Colors.purple, // 模拟四 - 紫色
          Colors.purple, // 模拟五 - 紫色
        ];
      default:
        return [
          Colors.blue, // 默认 - 蓝色
          Colors.blue, // 默认 - 蓝色
          Colors.blue, // 默认 - 蓝色
          Colors.blue, // 默认 - 蓝色
          Colors.blue, // 默认 - 蓝色
        ];
    }
  }

  // 获取主题颜色
  Color getThemeColor(int index) {
    if (index < 0 || index >= tabThemeColors.length) {
      return Colors.blue; // 默认颜色
    }
    return tabThemeColors[index];
  }

  // 获取默认主题颜色
  Color get defaultThemeColor {
    switch (pageType) {
      case 'must_brush':
        return Colors.blue;
      case 'past_exams':
        return Colors.teal;
      case 'mock_exams':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }
}
