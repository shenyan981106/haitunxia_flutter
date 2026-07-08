import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:xmshop/app/data/providers/api_client.dart';
import '../../questionsHome/controllers/questions_home_controller.dart';

class QuestionsListController extends GetxController {
  // 当前页面类型：chapter, must_brush, past_exams, mock_exams
  late String pageType;

  // 当前选中的导航索引
  RxInt currentNavIndex = 0.obs;

  // 当前选中的顶部导航索引
  RxInt currentTopNavIndex = 0.obs;

  // 章节接口加载状态
  RxBool isLoadingChapters = false.obs;
  RxString chapterError = ''.obs;
  RxList<Map<String, dynamic>> chapters = <Map<String, dynamic>>[].obs;
  int? _currentColumnId;
  int? passedCategoryId;

  // 章节展开状态管理
  final Map<String, bool> _chapterExpansionStates = {};

  @override
  void onInit() {
    super.onInit();
    // 从路由参数中获取页面类型，默认为chapter
    final args = Get.arguments;
    if (args != null && args is Map) {
      pageType = args['pageType'] ?? 'chapter';
      if (args['initialIndex'] != null) {
        currentTopNavIndex.value = args['initialIndex'];
      }
      if (args['categoryId'] != null) {
        passedCategoryId = args['categoryId'];
      }
      // 优先使用subject_id参数，如果没有则使用categoryId
      if (args['subject_id'] != null) {
        passedCategoryId = args['subject_id'];
      }
    } else {
      pageType = 'chapter';
    }
  }

  @override
  void onReady() {
    super.onReady();
    if (pageType == 'chapter' || pageType == 'must_brush') {
      try {
        if (Get.isRegistered<QuestionsHomeController>()) {
          final homeController = Get.find<QuestionsHomeController>();
          // 监听 subjects 变化
          ever(homeController.subjects, (_) {
            // 如果当前没有章节数据，或者需要刷新
            // 注意：这里可能需要更精细的控制，避免重复加载
            // 但考虑到 chapters 为空时肯定是需要加载的
            if (chapters.isEmpty) {
              final columnId = _getColumnId(currentTopNavIndex.value);
              if (columnId != null) {
                loadChapters(columnId);
              }
            }
          });

          // 监听 Tab 切换
          ever(currentTopNavIndex, (index) {
            final columnId = _getColumnId(index);
            if (columnId != null) {
              loadChapters(columnId);
            }
          });

          // 初始检查
          if (passedCategoryId != null) {
            loadChapters(passedCategoryId!);
          } else if (homeController.subjects.isNotEmpty) {
            final columnId = _getColumnId(currentTopNavIndex.value);
            if (columnId != null) {
              loadChapters(columnId);
            }
          }
        }
      } catch (e) {
        print('QuestionsListController onReady error: $e');
      }
    }
  }

  int? _getColumnId(int index) {
    try {
      if (Get.isRegistered<QuestionsHomeController>()) {
        final homeController = Get.find<QuestionsHomeController>();
        if (index >= 0 && index < homeController.subjects.length) {
          return homeController.subjects[index].id;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<void> loadChapters(int columnId) async {
    if (_currentColumnId == columnId && chapters.isNotEmpty) {
      // 即使是同一个columnId，也可能因为是重新进入页面，需要刷新
      // 但为了避免不必要的刷新，如果已经有数据且columnId相同，暂时不刷新
      // return; // 移除这个返回，强制每次切换都刷新，或者在外部控制
    }

    // 清空当前章节数据，以便UI显示加载状态或清空旧数据
    if (_currentColumnId != columnId) {
      chapters.clear();
    }
    _currentColumnId = columnId;
    isLoadingChapters.value = true;
    chapterError.value = '';

    try {
      // 只传入 subject_id，遵循用户明确的接口参数要求
      final response = await ApiClient.to.getExam(
        'cate/getThree',
        queryParameters: {
          'subject_id': columnId,
          'page': 'look',
          'kind': 'QUESTION',
        },
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map;
        final code = data['code'];
        if (code == 1) {
          final list = data['data'];
          if (list is List) {
            chapters.value =
                list.whereType<Map>().map<Map<String, dynamic>>((item) {
              final map = item.map<String, dynamic>(
                  (key, value) => MapEntry(key.toString(), value));
              final title = map['name']?.toString() ??
                  map['title']?.toString() ??
                  map['text']?.toString() ??
                  map['cate_name']?.toString() ??
                  map['category_name']?.toString() ??
                  '章节名称';

              final children = item['children'];
              List<Map<String, dynamic>> sections = [];

              if (children is List && children.isNotEmpty) {
                sections = children.map<Map<String, dynamic>>((child) {
                  final childMap = child is Map
                      ? child.map<String, dynamic>(
                          (key, value) => MapEntry(key.toString(), value))
                      : <String, dynamic>{};

                  final sectionTitle = childMap['name']?.toString() ??
                      childMap['title']?.toString() ??
                      childMap['text']?.toString() ??
                      childMap['cate_name']?.toString() ??
                      childMap['category_name']?.toString() ??
                      '小节名称';

                  // 选择更可靠的节ID：优先 id/value；若 cate_id 存在且不等于 subject_id（columnId），则用 cate_id
                  dynamic sectionId = childMap['id'] ?? childMap['value'];
                  if (sectionId == null && childMap['cate_id'] != null) {
                    final cateId = childMap['cate_id'];
                    if (cateId != columnId) {
                      sectionId = cateId;
                    }
                  }
                  try {
                    print(
                        '构造子节: title=$sectionTitle, id=$sectionId, cate_id=${childMap['cate_id']}, subject_id=$columnId');
                  } catch (_) {}
                  return {
                    'title': sectionTitle,
                    'progress': childMap['progress']?.toString() ?? '',
                    'accuracy': childMap['accuracy']?.toString() ?? '',
                    'type': 'action',
                    'raw': childMap,
                    'id': sectionId,
                  };
                }).toList();
              } else {
                // 如果没有子章节，就把当前章节作为唯一的一节
                dynamic sectionId = map['id'] ?? map['value'];
                if (sectionId == null && map['cate_id'] != null) {
                  final cateId = map['cate_id'];
                  if (cateId != columnId) {
                    sectionId = cateId;
                  }
                }
                sections.add({
                  'title': title,
                  'progress': map['progress']?.toString() ?? '',
                  'accuracy': map['accuracy']?.toString() ?? '',
                  'type': 'action',
                  'raw': map,
                  'id': sectionId,
                });
              }

              dynamic chapterId = map['id'] ?? map['value'];
              if (chapterId == null && map['cate_id'] != null) {
                final cateId = map['cate_id'];
                if (cateId != columnId) {
                  chapterId = cateId;
                }
              }
              final result = {
                'title': title,
                'progress': map['progress']?.toString() ?? '',
                'sections': sections,
                'raw': map,
                'id': chapterId,
              };
              try {
                print('构造章节: title=$title, id=$chapterId, rawKeys=${map.keys}');
              } catch (_) {}
              return result;
            }).toList();

            // 按正序排列章节（根据 ID 或名称排序）
            chapters.sort((a, b) {
              // 尝试根据 ID 排序
              final idA = a['id'];
              final idB = b['id'];
              if (idA != null && idB != null) {
                if (idA is int && idB is int) {
                  return idA.compareTo(idB);
                }
                return idA.toString().compareTo(idB.toString());
              }
              // 如果 ID 不可用，根据标题排序
              return a['title'].toString().compareTo(b['title'].toString());
            });
          } else {
            chapters.value = [];
            chapterError.value = '章节数据格式错误';
          }
        } else {
          chapters.value = [];
          chapterError.value = data['msg']?.toString() ?? '章节获取失败';
        }
      } else {
        chapters.value = [];
        chapterError.value = '网络请求失败';
      }
    } catch (_) {
      chapters.value = [];
      chapterError.value = '网络错误，请检查网络连接';
    } finally {
      isLoadingChapters.value = false;
    }
  }

  // 设置当前导航索引
  void setCurrentNavIndex(int index) {
    currentNavIndex.value = index;
  }

  // 设置当前顶部导航索引
  void setCurrentTopNavIndex(int index) {
    currentTopNavIndex.value = index;
  }

  // 切换章节展开状态
  void toggleChapterExpansion(int tabIndex, int chapterIndex,
      {bool hasSections = true}) {
    // 如果没有子分类，不执行切换操作
    if (!hasSections) {
      return;
    }

    final key = '$tabIndex-$chapterIndex';
    _chapterExpansionStates[key] = !(_chapterExpansionStates[key] ?? true);
    update();
  }

  // 获取章节展开状态
  bool isChapterExpanded(int tabIndex, int chapterIndex) {
    final key = '$tabIndex-$chapterIndex';
    // 第一个章节默认展开，其他章节默认关闭
    final defaultExpanded = chapterIndex == 0;
    return _chapterExpansionStates[key] ?? defaultExpanded;
  }

  // 根据页面类型获取标题
  String getPageTitle() {
    switch (pageType) {
      case 'must_brush':
        return '必刷母题';
      case 'past_exams':
        return '历年真题';
      case 'mock_exams':
        return '模拟考试';
      default:
        return '章节练习';
    }
  }

  // Tab数据 - 根据页面类型返回不同的数据
  List<String> get tabTitles {
    // 尝试获取动态标题
    if (pageType == 'chapter' || pageType == 'must_brush') {
      try {
        if (Get.isRegistered<QuestionsHomeController>()) {
          final titles = Get.find<QuestionsHomeController>().tabTitles;
          if (titles.isNotEmpty) return titles;
        }
      } catch (_) {}
    }

    switch (pageType) {
      case 'must_brush':
        return [
          "中国近现代史纲要",
          "自考英语二",
          "马克思主义基本原理概论",
          "高等数学（一）",
          "大学语文",
          "思想道德修养",
          "计算机应用基础",
          "管理学原理",
          "经济学原理",
          "法律基础",
        ];
      case 'past_exams':
        return [
          "2025年",
          "2024年",
          "2023年",
          "2022年",
          "2021年",
          "2020年",
          "2019年",
          "2018年",
          "2017年",
          "2016年及以前",
        ];
      case 'mock_exams':
        return [
          "模拟考试一",
          "模拟考试二",
          "模拟考试三",
          "模拟考试四",
          "模拟考试五",
          "模拟考试六",
          "模拟考试七",
          "模拟考试八",
          "模拟考试九",
          "模拟考试十",
        ];
      default: // chapter
        return [
          "中国近现代史纲要",
          "自考英语二",
          "马克思主义基本原理概论",
          "高等数学（一）",
          "大学语文",
          "思想道德修养",
          "计算机应用基础",
          "管理学原理",
          "经济学原理",
          "法律基础",
        ];
    }
  }

  // 每个Tab的卡片标题
  List<List<String>> get tabCardTitles {
    switch (pageType) {
      case 'must_brush':
        return [
          ["历史必刷母题", "历史核心考点"],
          ["英语必刷母题", "英语核心考点"],
          ["马原必刷母题", "马原核心考点"],
          ["高数必刷母题", "高数核心考点"],
          ["语文必刷母题", "语文核心考点"],
          ["思修必刷母题", "思修核心考点"],
          ["计算机必刷母题", "计算机核心考点"],
          ["管理必刷母题", "管理核心考点"],
          ["经济必刷母题", "经济核心考点"],
          ["法律必刷母题", "法律核心考点"],
        ];
      case 'past_exams':
        return [
          ["2025年真题", "2025年解析"],
          ["2024年真题", "2024年解析"],
          ["2023年真题", "2023年解析"],
          ["2022年真题", "2022年解析"],
          ["2021年真题", "2021年解析"],
          ["2020年真题", "2020年解析"],
          ["2019年真题", "2019年解析"],
          ["2018年真题", "2018年解析"],
          ["2017年真题", "2017年解析"],
          ["2016年真题", "2016年解析"],
        ];
      case 'mock_exams':
        return [
          ["模拟考试一", "考试解析"],
          ["模拟考试二", "考试解析"],
          ["模拟考试三", "考试解析"],
          ["模拟考试四", "考试解析"],
          ["模拟考试五", "考试解析"],
          ["模拟考试六", "考试解析"],
          ["模拟考试七", "考试解析"],
          ["模拟考试八", "考试解析"],
          ["模拟考试九", "考试解析"],
          ["模拟考试十", "考试解析"],
        ];
      default: // chapter
        return [
          ["历史章节练习", "历史VIP题库"],
          ["英语章节练习", "英语VIP题库"],
          ["马原章节练习", "马原VIP题库"],
          ["高数章节练习", "高数VIP题库"],
          ["语文章节练习", "语文VIP题库"],
          ["思修章节练习", "思修VIP题库"],
          ["计算机章节练习", "计算机VIP题库"],
          ["管理章节练习", "管理VIP题库"],
          ["经济章节练习", "经济VIP题库"],
          ["法律章节练习", "法律VIP题库"],
        ];
    }
  }

  // 每个Tab的卡片描述
  List<List<String>> get tabCardDescriptions {
    switch (pageType) {
      case 'must_brush':
        return [
          ["掌握核心母题", "一次通关"],
          ["掌握核心母题", "一次通关"],
          ["掌握核心母题", "一次通关"],
          ["掌握核心母题", "一次通关"],
          ["掌握核心母题", "一次通关"],
          ["掌握核心母题", "一次通关"],
          ["掌握核心母题", "一次通关"],
          ["掌握核心母题", "一次通关"],
          ["掌握核心母题", "一次通关"],
          ["掌握核心母题", "一次通关"],
        ];
      case 'past_exams':
        return [
          ["原题实战", "把握趋势"],
          ["原题实战", "把握趋势"],
          ["原题实战", "把握趋势"],
          ["原题实战", "把握趋势"],
          ["原题实战", "把握趋势"],
          ["原题实战", "把握趋势"],
          ["原题实战", "把握趋势"],
          ["原题实战", "把握趋势"],
          ["原题实战", "把握趋势"],
          ["原题实战", "把握趋势"],
        ];
      case 'mock_exams':
        return [
          ["限时模考", "综合检验"],
          ["限时模考", "综合检验"],
          ["限时模考", "综合检验"],
          ["限时模考", "综合检验"],
          ["限时模考", "综合检验"],
          ["限时模考", "综合检验"],
          ["限时模考", "综合检验"],
          ["限时模考", "综合检验"],
          ["限时模考", "综合检验"],
          ["限时模考", "综合检验"],
        ];
      default: // chapter
        return [
          ["历史考点预测", "历史专项练习"],
          ["英语考点预测", "英语专项练习"],
          ["马原考点预测", "马原专项练习"],
          ["高数考点预测", "高数专项练习"],
          ["语文考点预测", "语文专项练习"],
          ["思修考点预测", "思修专项练习"],
          ["计算机考点预测", "计算机专项练习"],
          ["管理考点预测", "管理专项练习"],
          ["经济考点预测", "经济专项练习"],
          ["法律考点预测", "法律专项练习"],
        ];
    }
  }

  // 每个Tab的颜色主题（使用MaterialColor或Color）
  List<Color> get tabThemeColors {
    switch (pageType) {
      case 'must_brush':
        return List.filled(10, const Color(0xFF3D7CFF));
      case 'past_exams':
        return [
          Colors.teal, // 2025 - 青色
          Colors.teal, // 2024 - 青色
          Colors.teal, // 2023 - 青色
          Colors.teal, // 2022 - 青色
          Colors.teal, // 2021 - 青色
          Colors.teal, // 2020 - 青色
          Colors.teal, // 2019 - 青色
          Colors.teal, // 2018 - 青色
          Colors.teal, // 2017 - 青色
          Colors.teal, // 2016 - 青色
        ];
      case 'mock_exams':
        return [
          Colors.purple, // 模拟一 - 紫色
          Colors.purple, // 模拟二 - 紫色
          Colors.purple, // 模拟三 - 紫色
          Colors.purple, // 模拟四 - 紫色
          Colors.purple, // 模拟五 - 紫色
          Colors.purple, // 模拟六 - 紫色
          Colors.purple, // 模拟七 - 紫色
          Colors.purple, // 模拟八 - 紫色
          Colors.purple, // 模拟九 - 紫色
          Colors.purple, // 模拟十 - 紫色
        ];
      default: // chapter
        return List.filled(10, const Color(0xFF3D7CFF));
    }
  }

  // 获取当前Tab的数据
  String getCurrentTabTitle(int index) =>
      tabTitles.isNotEmpty ? tabTitles[index % tabTitles.length] : '';
  List<String> getCardTitles(int index) => tabCardTitles.isNotEmpty
      ? tabCardTitles[index % tabCardTitles.length]
      : [];
  List<String> getCardDescriptions(int index) => tabCardDescriptions.isNotEmpty
      ? tabCardDescriptions[index % tabCardDescriptions.length]
      : [];
  Color getThemeColor(int index) => tabThemeColors.isNotEmpty
      ? tabThemeColors[index % tabThemeColors.length]
      : const Color(0xFF3D7CFF);

  // 智能做题的标题
  String getSmartExerciseTitle(int index) {
    if (tabTitles.isEmpty) return "智能做题";
    switch (pageType) {
      case 'must_brush':
        return "${tabTitles[index % tabTitles.length]}核心母题";
      case 'past_exams':
        return "${tabTitles[index % tabTitles.length]}真题练习";
      case 'mock_exams':
        return "${tabTitles[index % tabTitles.length]}模拟练习";
      default:
        return "${tabTitles[index % tabTitles.length]}智能做题";
    }
  }

  // 思维导图标题
  String getMindMapTitle(int index) {
    if (tabTitles.isEmpty) return "知识体系";
    return "${tabTitles[index % tabTitles.length]}知识体系";
  }

  String getMindMapDescription(int index) {
    if (tabTitles.isEmpty) return "知识体系详情";
    switch (pageType) {
      case 'must_brush':
        return "${tabTitles[index % tabTitles.length]}核心考点脉络";
      case 'past_exams':
        return "${tabTitles[index % tabTitles.length]}真题考点分析";
      case 'mock_exams':
        return "${tabTitles[index % tabTitles.length]}模拟考点梳理";
      default:
        List<String> descriptions = [
          "中国近现代史重要事件脉络",
          "英语核心词汇语法体系",
          "马克思主义基本原理框架",
          "高等数学公式定理全解",
          "大学语文文学常识结构",
          "思想道德修养知识要点",
          "计算机应用基础考点",
          "管理学原理知识体系",
          "经济学原理核心概念",
          "法律基础知识框架",
        ];
        return descriptions[index % descriptions.length];
    }
  }

  // ========== 学习进度概览统计 ==========

  /// 获取总完成率（百分比字符串，如 "33%"）
  String get overallCompletionRate {
    final done = totalDoneCount;
    final total = totalCount;
    if (total == 0) return '0%';
    final rate = (done / total * 100).round();
    return '$rate%';
  }

  /// 获取已完成题目数
  int get totalDoneCount {
    int done = 0;
    for (var chapter in chapters) {
      final sections = chapter['sections'];
      if (sections is List) {
        for (var section in sections) {
          final progress = section['progress']?.toString() ?? '';
          if (progress.contains('/')) {
            final parts = progress.split('/');
            if (parts.isNotEmpty) {
              done += int.tryParse(parts[0].trim()) ?? 0;
            }
          }
        }
      }
      // 如果章节没有子节，则从章节自身的 progress 获取
      else {
        final progress = chapter['progress']?.toString() ?? '';
        if (progress.contains('/')) {
          final parts = progress.split('/');
          if (parts.isNotEmpty) {
            done += int.tryParse(parts[0].trim()) ?? 0;
          }
        }
      }
    }
    return done;
  }

  /// 获取总题数
  int get totalCount {
    int total = 0;
    for (var chapter in chapters) {
      final sections = chapter['sections'];
      if (sections is List) {
        for (var section in sections) {
          final progress = section['progress']?.toString() ?? '';
          if (progress.contains('/')) {
            final parts = progress.split('/');
            if (parts.length > 1) {
              total += int.tryParse(parts[1].trim()) ?? 0;
            }
          }
        }
      } else {
        final progress = chapter['progress']?.toString() ?? '';
        if (progress.contains('/')) {
          final parts = progress.split('/');
          if (parts.length > 1) {
            total += int.tryParse(parts[1].trim()) ?? 0;
          }
        }
      }
    }
    return total;
  }
}
