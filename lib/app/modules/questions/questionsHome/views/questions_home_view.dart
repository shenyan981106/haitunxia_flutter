import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../data/services/auth_service.dart';
import '../controllers/questions_home_controller.dart';

class QuestionsHomeView extends GetView<QuestionsHomeController> {
  const QuestionsHomeView({Key? key}) : super(key: key);

  static IconData _iconDataFromCode(String? code) {
    switch (code?.toLowerCase()) {
      case 'e600':
        return const IconData(0xe600, fontFamily: 'iconfont');
      case 'e60d':
        return const IconData(0xe60d, fontFamily: 'iconfont');
      case 'e61a':
        return const IconData(0xe61a, fontFamily: 'iconfont');
      case 'e660':
        return const IconData(0xe660, fontFamily: 'iconfont');
      case 'e661':
        return const IconData(0xe661, fontFamily: 'iconfont');
      case 'e662':
        return const IconData(0xe662, fontFamily: 'iconfont');
      case 'e6bf':
        return const IconData(0xe6bf, fontFamily: 'iconfont');
      case 'e6e5':
        return const IconData(0xe6e5, fontFamily: 'iconfont');
      case 'e7fe':
        return const IconData(0xe7fe, fontFamily: 'iconfont');
      case 'ea2c':
        return const IconData(0xea2c, fontFamily: 'iconfont');
      default:
        return const IconData(0xe662, fontFamily: 'iconfont');
    }
  }

  /// 处理卡片点击事件，进行页面跳转
  /// [item] 卡片数据，包含路由信息和参数
  /// [tabIndex] 可选的子索引，用于章节练习场景
  void _handleCardTap(Map<String, dynamic> item, {int? tabIndex}) {
    final route = item['route'] as String?;
    if (route == null || route.isEmpty) return;

    Map<String, dynamic> args = {};
    if (item['arguments'] is Map) {
      final argMap = item['arguments'];
      if (argMap is Map<String, dynamic>) {
        args.addAll(argMap);
      } else if (argMap is Map) {
        args.addAll(Map<String, dynamic>.from(argMap));
      }
    }

    if (route == '/questions-list' && args['pageType'] == 'chapter') {
      final index = tabIndex ?? controller.selectedSubIndex.value;
      int? subjectId;
      if (index >= 0 && index < controller.subjects.length) {
        subjectId = controller.subjects[index].id;
      }
      args['initialIndex'] = index;
      if (subjectId != null) {
        args['categoryId'] = subjectId;
      }
    }

    if (route == '/questions/questions-exam') {
      Get.toNamed(route,
          parameters: {'pageType': args['pageType'] ?? 'past_exams'});
      return;
    }

    Get.toNamed(route, arguments: args.isEmpty ? null : args);
  }

  /// 处理章节练习卡片点击
  void _handleChapterTap() {
    final index = controller.selectedSubIndex.value;
    int? subjectId;
    if (index >= 0 && index < controller.subjects.length) {
      subjectId = controller.subjects[index].id;
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

  /// 处理历年真题卡片点击
  void _handlePastExamTap() {
    final subject = controller.getCurrentSubject();
    Get.toNamed(
      '/questions/questions-elist',
      arguments: {
        'type_id': 1,
        'subject_id': subject?.id,
      },
    );
  }

  /// 处理每日一练卡片点击
  void _handleDailyPracticeTap() {
    Get.toNamed(
      '/question-train',
      preventDuplicates: false,
      arguments: {
        'subject': '每日一练',
        'mode': 'prac',
        '_ts': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 50.h),
                    _buildHeader(),
                    SizedBox(height: 50.h),
                    _buildSecondaryTabs(),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: const Color(0xFFF3F4F9),
                  child: Obx(() {
                    final count = controller.tabTitles.length;
                    if (count == 0) return const SizedBox.shrink();
                    return PageView.builder(
                      controller: controller.pageController,
                      onPageChanged: controller.onPageChanged,
                      itemCount: count,
                      itemBuilder: (context, index) {
                        final bottomInset =
                            MediaQuery.of(context).padding.bottom;
                        final bottomSafeSpace = bottomInset + 240.h;
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(
                              top: 40.h, bottom: bottomSafeSpace),
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32.w),
                              child: _buildTopCards(),
                            ),
                            SizedBox(height: 28.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32.w),
                              child: _buildToolsSection(),
                            ),
                            SizedBox(height: 24.h),
                          ],
                        );
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _cardGradient(Color base) {
    final hsl = HSLColor.fromColor(base);
    final light = (hsl.lightness + 0.08).clamp(0.0, 1.0);
    final dark = (hsl.lightness - 0.06).clamp(0.0, 1.0);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        hsl.withLightness(dark).toColor(),
        hsl.withLightness(light).toColor(),
      ],
    );
  }

  List<BoxShadow> _cardShadows(Color base) {
    final shadowColor = (Color.lerp(base, Colors.black, 0.35) ?? Colors.black)
        .withOpacity(0.22);
    return [
      BoxShadow(
        color: shadowColor,
        blurRadius: 28.r,
        offset: Offset(0, 14.h),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 10.r,
        offset: Offset(0, 4.h),
      ),
    ];
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: controller.onProjectTap,
          child: Row(
            children: [
              Obx(() => Text(
                    controller.currentProjectName,
                    style: TextStyle(
                      fontSize: 50.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF333333),
                    ),
                  )),
              Icon(Icons.arrow_drop_down,
                  color: const Color(0xFF333333), size: 48.sp),
            ],
          ),
        ),
        Obx(() {
          final days = controller.globalController.daysToExam.value;
          print('距离考试天数: $days');
          return Row(
            children: [
              Text(
                '距离考试 ',
                style: TextStyle(
                  fontSize: 36.sp,
                  color: const Color(0xFF333333), // 黑色文字
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$days',
                style: TextStyle(
                  fontSize: 36.sp, // 增大数字字号
                  color: const Color(0xFF333333), // 黑色数字
                ),
              ),
              Text(
                ' 天',
                style: TextStyle(
                  fontSize: 36.sp,
                  color: const Color(0xFF333333), // 黑色文字
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 12.w),
              Icon(
                _iconDataFromCode('e6e5'), // 闹铃图标
                size: 48.sp, // 增大图标大小
                color: const Color(0xFF0164E5), // 蓝色图标
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildSecondaryTabs() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth;
        return Container(
          height: 140.h,
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Obx(() {
            final titles = controller.tabTitles;
            if (titles.isEmpty) return const SizedBox.shrink();
            return ListView.separated(
              controller: controller.tabScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: titles.length,
              separatorBuilder: (c, i) => SizedBox(width: 40.w),
              itemBuilder: (context, index) {
                return Obx(() {
                  final isSelected = controller.selectedSubIndex.value == index;
                  return GestureDetector(
                    key: ValueKey('tab_$index'),
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      controller.changeSubTab(index);
                      _scrollToTab(index, viewportWidth);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            titles[index],
                            style: TextStyle(
                              fontSize: isSelected ? 48.sp : 44.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                              color: isSelected
                                  ? const Color(0xFF000000)
                                  : const Color(0xFF999999),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Container(
                            height: 6.h,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF3D7CFF)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(3.r),
                            ),
                            child: isSelected
                                ? LayoutBuilder(
                                    builder: (context, constraints) {
                                      final textPainter = TextPainter(
                                        text: TextSpan(
                                          text: titles[index],
                                          style: TextStyle(
                                            fontSize: 48.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        textDirection: TextDirection.ltr,
                                      );
                                      textPainter.layout();
                                      return SizedBox(width: textPainter.width);
                                    },
                                  )
                                : SizedBox(width: 0),
                          ),
                        ],
                      ),
                    ),
                  );
                });
              },
            );
          }),
        );
      },
    );
  }

  /// 滚动到指定的标签
  void _scrollToTab(int index, double viewportWidth) {
    final scrollController = controller.tabScrollController;
    if (!scrollController.hasClients) return;

    final titles = controller.tabTitles;
    if (titles.isEmpty) return;

    // 直接根据索引计算目标位置
    final double itemWidth = 140;
    final double maxScroll = scrollController.position.maxScrollExtent;

    double targetOffset;

    if (index == 0) {
      // 第一个标签，滚动到最左边
      targetOffset = 0;
    } else if (index == titles.length - 1) {
      // 最后一个标签，滚动到最右边
      targetOffset = maxScroll;
    } else {
      // 计算目标位置，确保标签居中或完全可见
      final double itemCenter = index * itemWidth + itemWidth / 2;
      final double viewportCenter = viewportWidth / 2;

      targetOffset = itemCenter - viewportCenter;
    }

    // 确保在有效范围内
    targetOffset = targetOffset.clamp(0.0, maxScroll);

    // 执行滚动
    scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Widget _buildTopCards() {
    // 硬编码文案
    const largeCardData = {
      'title': '章节练习',
      'subtitle': '按章节练习，巩固知识点',
      'onTap': null,
    };

    const smallCard1Data = {
      'title': '历年真题',
      'subtitle': '熟悉考试题型，掌握考点',
      'onTap': null,
    };

    const smallCard2Data = {
      'title': '每日一练',
      'subtitle': '每天进步，保持手感',
      'onTap': null,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        // 计算宽度，与下方工具按钮保持一致间距
        final spacing = 24.w;
        final availableWidth = constraints.maxWidth;
        final toolItemWidth = (availableWidth - spacing) / 2;

        return SizedBox(
          height: 460.h,
          child: Row(
            children: [
              SizedBox(
                width: toolItemWidth,
                height: 660.h,
                child: _buildLargeCard(
                  title: largeCardData['title']!,
                  subtitle: largeCardData['subtitle']!,
                  icon: _iconDataFromCode('ea2c'), // 章节练习图标
                  onTap: _handleChapterTap,
                  showPrimaryButton: true,
                  backgroundColor: const Color(0xFF5A8EF4),
                ),
              ),
              SizedBox(width: spacing),
              SizedBox(
                width: toolItemWidth, // 与章节练习保持相同宽度
                child: Column(
                  children: [
                    SizedBox(
                      width: toolItemWidth,
                      height: 210.h,
                      child: _buildSmallCard(
                        title: smallCard1Data['title']!,
                        subtitle: smallCard1Data['subtitle']!,
                        icon: _iconDataFromCode('e61a'), // 历年真题图标
                        onTap: _handlePastExamTap,
                        backgroundColor: const Color(0xFFEF826E),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    SizedBox(
                      width: toolItemWidth,
                      height: 210.h,
                      child: _buildSmallCard(
                        title: smallCard2Data['title']!,
                        subtitle: smallCard2Data['subtitle']!,
                        icon: _iconDataFromCode('e661'), // 每日一练图标
                        onTap: _handleDailyPracticeTap,
                        backgroundColor:
                            const Color.fromARGB(255, 51, 170, 110),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLargeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool showPrimaryButton,
    required Color backgroundColor,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(22.w),
        decoration: BoxDecoration(
          gradient: _cardGradient(backgroundColor),
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: _cardShadows(backgroundColor),
          border: Border.all(
            color: Colors.white.withOpacity(0.16),
            width: 1.w,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -18.w,
              bottom: -40.h,
              child: Icon(
                icon,
                size: 200.sp, // 减小图标大小
                color: Colors.white.withOpacity(0.22),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 54.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 32.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: 50.h), // 添加额外的空白空间，保持卡片长度
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Color backgroundColor,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          gradient: _cardGradient(backgroundColor),
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: _cardShadows(backgroundColor),
          border: Border.all(
            color: Colors.white.withOpacity(0.16),
            width: 1.w,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10.w,
              bottom: -22.h,
              child: Icon(
                icon,
                size: 150.sp, // 减小图标大小
                color: Colors.white.withOpacity(0.22),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 50.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 32.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolsSection() {
    // 固定工具模块（始终显示）
    final fixedTools = [
      {
        'title': '模拟考试',
        'desc': '',
        'icon': 'e662',
        'color': const Color(0xFF52C41A),
        'route': '/questions/questions-elist',
        'arguments': {'type_id': 2},
      },
      // {
      //   'title': '我的笔记',
      //   'desc': '随学随记',
      //   'icon': 'e6bf',
      //   'color': const Color(0xFF5B8CFF),
      //   'route': '/questions/notes',
      //   'arguments': {},
      // },
      {
        'title': '错题本',
        'desc': '查看错题',
        'icon': 'e7fe',
        'color': const Color(0xFFFF7A45),
        'route': '/questions/wrong',
        'arguments': {},
      },
      {
        'title': '题目收藏',
        'desc': '查看收藏',
        'icon': 'e600',
        'color': const Color.fromARGB(255, 230, 35, 77),
        'route': '/questions/favorite',
        'arguments': {},
      },
      {
        'title': '我要反馈',
        'desc': '问题与建议',
        'icon': 'e660',
        'color': const Color(0xFF9254DE),
        'route': '/question-feedback',
        'arguments': {},
      },
      {
        'title': '快问老师',
        'desc': '老师在线答疑',
        'icon': 'e60d',
        'color': const Color(0xFF13C2C2),
        'route': '/questions/ask',
        'arguments': {},
      },
    ];

    return Obx(() {
      // 获取当前选中的科目subjectId
      final currentSubject = controller.getCurrentSubject();
      final currentSubjectId = currentSubject?.id;

      // 从动态配置中筛选出属于当前科目的项
      final List<Map<String, dynamic>> dynamicItems = [];
      if (currentSubjectId != null) {
        for (final item in controller.dynamicTools) {
          final raw = item['raw'];
          if (raw is! Map) continue;

          final itemSubjectId = raw['subject_id'];

          // 严格subject_id 匹配：只显示属于当前选中科目的动态模块
          if (itemSubjectId != null && itemSubjectId == currentSubjectId) {
            dynamicItems.add(item);
          }
        }
      }

      // 合并：固定工具模块 + 当前科目的动态配置
      final allTools = <Map<String, dynamic>>[
        ...fixedTools,
        ...dynamicItems,
      ];

      return LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;

          return Wrap(
            spacing: 24.w,
            runSpacing: 24.h,
            children: List.generate(allTools.length, (index) {
              final item = allTools[index];

              return SizedBox(
                width: (availableWidth - 24.w) / 2,
                child: _buildToolItem(item),
              );
            }),
          );
        },
      );
    });
  }

  void _showVipDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        titlePadding: EdgeInsets.only(top: 56.h),
        contentPadding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 28.h),
        actionsPadding: EdgeInsets.only(bottom: 48.h, top: 36.h),
        title: Text(
          '提示',
          style: TextStyle(
            fontSize: 50.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF333333),
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          '该功能需要开通VIP会员才能使用',
          style: TextStyle(
            fontSize: 38.sp,
            color: const Color(0xFF666666),
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: SizedBox(
              width: 360.w,
              height: 92.h,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1890FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  '我知道了',
                  style: TextStyle(
                    fontSize: 32.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
      ),
    );
  }

  Widget _buildToolItem(Map<String, dynamic> item) {
    final Color color = item['color'] as Color;
    final rawIcon = item['icon'];
    final IconData icon =
        rawIcon is IconData ? rawIcon : _iconDataFromCode(rawIcon?.toString());
    final String title = item['title'] as String;
    final String desc = item['desc'] as String? ?? '';

    final bool isVipItem = title == '考前押题' || title == '核心母题';

    void handleTap() {
      if (isVipItem && !AuthService.to.isMember) {
        _showVipDialog();
      } else {
        _handleCardTap(item);
      }
    }

    return GestureDetector(
      onTap: handleTap,
      child: SizedBox(
        height: 180.h,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16.r,
                    offset: Offset(0, 8.h),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1.w,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 42.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        if (desc.isNotEmpty) ...[
                          SizedBox(height: 10.h),
                          Text(
                            desc,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 32.sp,
                              color: const Color(0xFF999999),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 60.sp,
                    ),
                  ),
                ],
              ),
            ),
            // VIP标签 - 右上角（覆盖在卡片上）
            if (isVipItem)
              Positioned(
                right: 0,
                top: 0,
                child: SvgPicture.asset(
                  'assets/fonts/vip_icon.svg',
                  width: 130.w,
                  height: 72.h,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
