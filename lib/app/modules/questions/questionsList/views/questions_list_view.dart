import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/global_project_controller.dart';
import '../../questionsHome/controllers/questions_home_controller.dart';
import '../../questionTrain/controllers/question_train_controller.dart';
import '../controllers/questions_list_controller.dart';
import '../../../../services/keepAliveWrapper.dart';
import "../../../../services/screenAdapter.dart";
import '../../../../services/snackbar_utils.dart';

class QuestionsListView extends StatefulWidget {
  const QuestionsListView({super.key});

  @override
  State<QuestionsListView> createState() => _QuestionsListViewState();
}

class _QuestionsListViewState extends State<QuestionsListView> {
  final QuestionsListController controller =
      Get.find<QuestionsListController>();
  final ScrollController _tabScrollController = ScrollController();
  final Map<int, GlobalKey> _tabKeys = {};
  Worker? _navIndexWorker;

  @override
  void initState() {
    super.initState();
    _navIndexWorker = ever(controller.currentTopNavIndex, (index) {
      _scrollToIndex(index);
    });
  }

  @override
  void dispose() {
    _tabScrollController.dispose();
    _navIndexWorker?.dispose();
    super.dispose();
  }

  void _scrollToIndex(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final key = _tabKeys[index];
      if (key != null && key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final globalController = GlobalProjectController.to;

    return KeepAliveWrapper(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Obx(() => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    globalController.currentProjectName,
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(50),
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: ScreenAdapter.height(6)),
                ],
              )),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(ScreenAdapter.height(150)),
            child: _buildCustomTabBar(),
          ),
        ),
        body: Obx(() {
          final currentIndex = controller.currentTopNavIndex.value;
          return _buildTabContent(currentIndex);
        }),
      ),
    );
  }

  // 构建每个 Tab 的内容
  Widget _buildTabContent(int tabIndex) {
    if (controller.pageType == 'chapter') {
      if (controller.isLoadingChapters.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (controller.chapterError.value.isNotEmpty) {
        return Center(
          child: Text(controller.chapterError.value),
        );
      }
    }

    // 获取当前科目的章节数
    final chapters = _getChaptersForSubject(tabIndex);

    // 如果没有章节数据，显示提示
    if (chapters.isEmpty) {
      return Center(
        child: Text(
          '该科目下暂无题目',
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(40),
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        // 学习进度概览卡片
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(bottom: ScreenAdapter.height(20)),
            child: _buildProgressOverviewCard(tabIndex),
          ),
        ),
        // 章节列表
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, chapterIndex) {
              return _buildChapterItem(tabIndex, chapterIndex, chapters);
            },
            childCount: chapters.length,
          ),
        ),
      ],
    );
  }

  // 构建学习进度概览卡片
  Widget _buildProgressOverviewCard(int tabIndex) {
    final themeColor = controller.getThemeColor(tabIndex);

    return Obx(() {
      final completionRate = controller.overallCompletionRate;
      final doneCount = controller.totalDoneCount;
      final totalCount = controller.totalCount;

      return Container(
        margin: EdgeInsets.symmetric(
          horizontal: ScreenAdapter.width(30),
          vertical: ScreenAdapter.height(10),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: ScreenAdapter.width(40),
          vertical: ScreenAdapter.height(50),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeColor,
              themeColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(ScreenAdapter.width(24)),
          boxShadow: [
            BoxShadow(
              color: themeColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Text(
              '学习进度概览',
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(36),
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: ScreenAdapter.height(30)),
            // 统计数据
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 完成率
                _buildStatItem('$completionRate', '完成率'),
                // 已做题
                _buildStatItem('$doneCount', '已做题'),
                // 总题数
                _buildStatItem('$totalCount', '总题数'),
              ],
            ),
          ],
        ),
      );
    });
  }

  // 构建统计项
  Widget _buildStatItem(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(60),
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: ScreenAdapter.height(10)),
        Text(
          label,
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(28),
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  // 构建免费学习卡片
  Widget _buildFreeLearningCard(int tabIndex) {
    final themeColor = controller.getThemeColor(tabIndex);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ScreenAdapter.width(30),
        vertical: ScreenAdapter.height(10),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenAdapter.width(20)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [themeColor.withOpacity(0.9), themeColor.withOpacity(0.7)],
        ),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
    );
  }

  // 构建章节列表项
  Widget _buildChapterItem(
      int tabIndex, int chapterIndex, List<Map<String, dynamic>> chapters) {
    if (chapterIndex < chapters.length) {
      var chapter = chapters[chapterIndex];
      return _ChapterCard(
        tabIndex: tabIndex,
        chapterIndex: chapterIndex,
        chapter: chapter,
        controller: controller,
      );
    }
    return SizedBox();
  }

  // 构建Bar
  Widget _buildCustomTabBar() {
    final homeController = Get.find<QuestionsHomeController>();

    return Obx(() {
      final List<String> titles = controller.pageType == 'chapter'
          ? homeController.tabTitles
          : controller.tabTitles;
      if (titles.isEmpty) {
        return const SizedBox.shrink();
      }

      final themeColors = controller.tabThemeColors;

      return Container(
        height: ScreenAdapter.height(150),
        color: Colors.white,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(
          left: ScreenAdapter.width(30),
          right: ScreenAdapter.width(30),
          top: ScreenAdapter.height(10),
          bottom: ScreenAdapter.height(30),
        ),
        child: SingleChildScrollView(
          controller: _tabScrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(titles.length, (index) {
              final isSelected = controller.currentTopNavIndex.value == index;
              final themeColor = themeColors.isNotEmpty
                  ? themeColors[index % themeColors.length]
                  : const Color(0xFF3D7CFF);
              final key = _tabKeys.putIfAbsent(index, () => GlobalKey());

              return GestureDetector(
                key: key,
                onTap: () {
                  controller.setCurrentTopNavIndex(index);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenAdapter.width(26),
                    vertical: ScreenAdapter.height(12),
                  ),
                  margin: EdgeInsets.only(right: ScreenAdapter.width(20)),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: ScreenAdapter.height(4),
                        color: isSelected ? themeColor : Colors.transparent,
                      ),
                    ),
                  ),
                  child: Text(
                    titles[index],
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(44),
                      color: isSelected ? const Color(0xFF1A1A2E) : Colors.grey,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      );
    });
  }

  // 获取对应科目的章节数
  List<Map<String, dynamic>> _getChaptersForSubject(int subjectIndex) {
    if (controller.pageType == 'chapter') {
      // 按正序排列章节
      // (确保章节按顺序显示)
      // (排除父章节的 cate_id)
      // (排除子分类的 cate_id)
      final chapters = controller.chapters.toList();
      return chapters;
    }

    // 根据页面类型返回不同的数据结构
    switch (controller.pageType) {
      case 'must_brush':
      case 'past_exams':
      case 'mock_exams':
      default:
        return [];
    }
  }
}

// 单独的章节卡片组件，使用GetX管理状态
class _ChapterCard extends StatelessWidget {
  final int tabIndex;
  final int chapterIndex;
  final Map<String, dynamic> chapter;
  final QuestionsListController controller;

  const _ChapterCard({
    required this.tabIndex,
    required this.chapterIndex,
    required this.chapter,
    required this.controller,
  });

  get section => null;

  // 解析进度字符串（如 "14/62"）返回比例 0.0~1.0
  static double _parseProgressFraction(String progress) {
    if (progress.isEmpty) return 0.0;
    final parts = progress.split('/');
    if (parts.length != 2) return 0.0;
    final done = int.tryParse(parts[0].trim()) ?? 0;
    final total = int.tryParse(parts[1].trim()) ?? 1;
    if (total == 0) return 0.0;
    return (done / total).clamp(0.0, 1.0);
  }

  // 根据正确率返回对应颜色
  static Color _getAccuracyColor(String accuracy) {
    if (accuracy.isEmpty) return const Color(0xFF3D7CFF);
    final value = double.tryParse(accuracy.replaceAll('%', '').trim()) ?? 0;
    if (value == 0) return const Color(0xFF3D7CFF);
    if (value <= 50) return const Color(0xFFFF9F43);
    return const Color(0xFFE74C3C);
  }

  // 根据完成率（progress）返回对应颜色
  static Color _getProgressColor(String progress) {
    final rate = _parseProgressFraction(progress);
    if (rate == 0) return const Color(0xFF3D7CFF); // 未做 - 蓝色
    if (rate < 1.0) return const Color(0xFFFF9F43); // 部分完成 - 橙色
    return const Color(0xFF52C41A); // 全部完成 - 绿色
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QuestionsListController>(
      builder: (controller) {
        // 判断是否有子分类
        final sectionsData = chapter['sections'];
        final hasSections = sectionsData is List && sectionsData.isNotEmpty;

        // 获取展开状态
        final isExpanded = controller.isChapterExpanded(tabIndex, chapterIndex);

        // 如果没有子分类，强制显示为展开状态（显示"-"图标），不允许收起
        // 如果有子分类，根据展开状态显示
        final effectiveExpanded = hasSections ? isExpanded : true;

        final themeColor = controller.getThemeColor(tabIndex);
        final chapterProgress = chapter['progress'] ?? '';

        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: ScreenAdapter.width(30),
            vertical: ScreenAdapter.height(15),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(ScreenAdapter.width(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: GestureDetector(
            // 只有有子分类时才允许点击切换
            onTap: hasSections
                ? () {
                    controller.toggleChapterExpansion(
                      tabIndex,
                      chapterIndex,
                      hasSections: hasSections,
                    );
                  }
                : null, // 没有子分类时设置为null，完全不响应点击
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 章节标题
                Padding(
                  padding: EdgeInsets.all(ScreenAdapter.width(26)),
                  child: Row(
                    children: [
                      // 章节序号徽章
                      Container(
                        width: ScreenAdapter.width(70),
                        height: ScreenAdapter.width(70),
                        decoration: BoxDecoration(
                          color: chapterIndex % 2 == 0
                              ? const Color(0xFF3D7CFF)
                              : const Color(0xFFFF9F43),
                          borderRadius:
                              BorderRadius.circular(ScreenAdapter.width(16)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${chapterIndex + 1}',
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(36),
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: ScreenAdapter.width(24)),
                      // 标题
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chapter['title'],
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(40),
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: ScreenAdapter.height(12)),
                            // 进度条
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: ScreenAdapter.height(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(
                                          ScreenAdapter.width(4)),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: _parseProgressFraction(
                                          chapterProgress),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: chapterIndex % 2 == 0
                                              ? const Color(0xFF3D7CFF)
                                              : const Color(0xFFFF9F43),
                                          borderRadius: BorderRadius.circular(
                                              ScreenAdapter.width(4)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: ScreenAdapter.width(20)),
                                Text(
                                  chapterProgress.isNotEmpty
                                      ? chapterProgress
                                      : '0/4000',
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(30),
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // 右侧箭头（有子分类时显示下拉/上拉，无子分类时显示右箭头）
                      Icon(
                        hasSections
                            ? (effectiveExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down)
                            : Icons.arrow_forward_ios,
                        color: Colors.grey[400],
                        size: ScreenAdapter.fontSize(32),
                      ),
                    ],
                  ),
                ),

                // 节内显示
                if (effectiveExpanded && hasSections)
                  ...List.generate(chapter['sections'].length, (sectionIndex) {
                    var section = chapter['sections'][sectionIndex];
                    return _ChapterCard._buildSectionItem(
                      section,
                      themeColor,
                      isLast: sectionIndex == chapter['sections'].length - 1,
                      tabIndex: tabIndex,
                      chapter: chapter,
                      controller: controller,
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  // 构建节内项
  static Widget _buildSectionItem(
    Map<String, dynamic> section,
    Color themeColor, {
    bool isLast = false,
    required int tabIndex,
    required Map<String, dynamic> chapter,
    required QuestionsListController controller,
  }) {
    bool hasAction = section['type'] == 'action';
    final sectionTitle = section['title'] ?? '';
    final progress = section['progress'] ?? '';
    final accuracy = section['accuracy'] ?? '';

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
          bottom: isLast
              ? BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                )
              : BorderSide.none,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: ScreenAdapter.width(60),
          top: ScreenAdapter.width(30),
          right: ScreenAdapter.width(30),
          bottom: ScreenAdapter.width(30),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 蓝色圆点
            Container(
              width: ScreenAdapter.width(20),
              height: ScreenAdapter.width(20),
              decoration: const BoxDecoration(
                color: Color(0xFF3D7CFF),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: ScreenAdapter.width(24)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sectionTitle,
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(36),
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: ScreenAdapter.height(10)),
                  Row(
                    children: [
                      // 完成率标签（基于 progress 计算）
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenAdapter.width(12),
                          vertical: ScreenAdapter.height(6),
                        ),
                        decoration: BoxDecoration(
                          color: _getProgressColor(progress).withOpacity(0.15),
                          borderRadius:
                              BorderRadius.circular(ScreenAdapter.width(8)),
                        ),
                        child: Text(
                          '${(_parseProgressFraction(progress) * 100).round()}%',
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(30),
                            color: _getProgressColor(progress),
                          ),
                        ),
                      ),
                      SizedBox(width: ScreenAdapter.width(20)),
                      // 进度文本
                      Text(
                        progress.isNotEmpty ? progress : '0/4000',
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(30),
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 做题按钮（实心蓝色）
            if (hasAction)
              GestureDetector(
                onTap: () {
                  var cateId = section['id'];

                  print(
                      '👉 准备跳转做题，cate_id: $cateId, Title: ${section['title']}, RAW: ${section['raw']}');

                  if (cateId == null) {
                    SnackbarUtils.showError('章节 ID 为空，无法加载题目');
                    return;
                  }

                  try {
                    Get.delete<QuestionTrainController>(force: true);
                  } catch (e) {
                    print('Failed to delete QuestionTrainController: $e');
                  }

                  Get.toNamed(
                    '/question-train',
                    parameters: {'cate_id': cateId.toString()},
                    preventDuplicates: false,
                    arguments: {
                      'cate_id': cateId,
                      'subject': controller.tabTitles[tabIndex] ?? '',
                      'chapter': chapter['title']?.toString() ?? '',
                      'sectionTitle': section['title']?.toString() ?? '',
                      '_ts': DateTime.now().millisecondsSinceEpoch,
                    },
                  );
                },
                child: Container(
                  width: ScreenAdapter.width(160),
                  height: ScreenAdapter.height(90),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D7CFF),
                    borderRadius:
                        BorderRadius.circular(ScreenAdapter.width(24)),
                  ),
                  child: Text(
                    '做题',
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(28),
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
