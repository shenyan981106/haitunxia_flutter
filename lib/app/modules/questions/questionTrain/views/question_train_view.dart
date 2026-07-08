import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:xmshop/app/data/models/question_model.dart';
import 'package:xmshop/app/services/snackbar_utils.dart';
import 'package:xmshop/app/services/screenAdapter.dart';
import 'package:xmshop/app/services/htxFonts.dart';
import '../controllers/question_train_controller.dart';

/// 题库训练页面
class QuestionTrainView extends GetView<QuestionTrainController> {
  const QuestionTrainView({super.key});

  // ==================== 颜色常量 ====================
  static const Color _primaryColor = Color(0xFF1890FF);
  static const Color _successColor = Color(0xFF52C41A);
  static const Color _warningColor = Color(0xFFFAAD14);
  static const Color _errorColor = Color(0xFFF5222D);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = controller.isDarkMode.value;
      final theme = _ThemeColors.fromDarkMode(isDark);
      // 夜间模式颜色
      final bgColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: bgColor,
                statusBarIconBrightness: Brightness.light,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: bgColor,
                statusBarIconBrightness: Brightness.dark,
              ),
        child: PopScope(
          canPop: controller.canPopNow.value,
          onPopInvoked: (didPop) async {
            if (didPop) return;
            final shouldPop = await controller.onWillPop();
            if (shouldPop) {
              controller.canPopNow.value = true;
              WidgetsBinding.instance.addPostFrameCallback((_) => Get.back());
            }
          },
          child: Scaffold(
            backgroundColor: bgColor,
            body: SafeArea(
              child: Obx(() => Container(
                    color: bgColor,
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            _buildTopBar(isDark),
                            _buildGradientDivider(),
                            Expanded(child: _buildContent(isDark, theme)),
                          ],
                        ),
                        // 字体大小悬浮卡片
                        Obx(() => controller.showFontSizeCard.value
                            ? _buildFloatingFontSizeCard()
                            : const SizedBox.shrink()),
                        // 设置悬浮卡片
                        Obx(() => controller.showSettingsCard.value
                            ? _buildFloatingSettingsCard()
                            : const SizedBox.shrink()),
                      ],
                    ),
                  )),
            ),
          ),
        ),
      );
    });
  }

  // ==================== 顶部区域 ====================
  Widget _buildTopBar(bool isDark) {
    final bgColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    return Container(
      height: ScreenAdapter.height(240),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenAdapter.width(32),
        vertical: ScreenAdapter.height(20),
      ),
      decoration: BoxDecoration(
        color: bgColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTopBarActions(isDark),
          _buildTopBarTitle(isDark),
        ],
      ),
    );
  }

  Widget _buildTopBarActions(bool isDark) {
    return SizedBox(
      height: ScreenAdapter.height(100),
      child: Row(
        children: [
          _buildIconButton(Icons.arrow_back, () async {
            if (await controller.onWillPop()) {
              controller.canPopNow.value = true;
              WidgetsBinding.instance.addPostFrameCallback((_) => Get.back());
            }
          }, isDark: isDark),
          SizedBox(width: ScreenAdapter.width(50)),
          _buildTimer(isDark),
          const Spacer(),
          // 收藏按钮
          _buildFavoriteButton(isDark),
          SizedBox(width: ScreenAdapter.width(76)),
          // 答题卡按钮
          _buildIconButton(htxFonts.trainDatika, controller.showAnswerCard,
              isDark: isDark),
          SizedBox(width: ScreenAdapter.width(76)),
          // 设置按钮
          _buildIconButton(Icons.more_horiz, controller.toggleSettingsCard,
              isDark: isDark, size: ScreenAdapter.width(72)),
        ],
      ),
    );
  }

  // 字体大小悬浮卡片（在图标正下方）
  Widget _buildFloatingFontSizeCard() {
    final isDark = controller.isDarkMode.value;
    final cardBgColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF3D444C);
    final selectedColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final unselectedColor =
        isDark ? const Color(0xFF666666) : const Color(0xFFBFBFBF);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => controller.showFontSizeCard.value = false,
      child: Container(
        color: Colors.transparent,
        child: Align(
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: EdgeInsets.only(
                top: ScreenAdapter.height(230),
              ),
              width: ScreenAdapter.width(500),
              padding: EdgeInsets.symmetric(
                horizontal: ScreenAdapter.width(40),
                vertical: ScreenAdapter.height(28),
              ),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(ScreenAdapter.radius(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('字体大小',
                      style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(32),
                          fontWeight: FontWeight.w500,
                          color: textColor)),
                  SizedBox(height: ScreenAdapter.height(24)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 小号 Aa
                      GestureDetector(
                        onTap: () => controller.setFontSize(0.8),
                        child: Obx(() {
                          final isSelected =
                              controller.fontSizeScale.value == 0.8;
                          return Padding(
                            padding: EdgeInsets.all(ScreenAdapter.width(24)),
                            child: Text('Aa',
                                style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(40) * 0.8,
                                  color: isSelected
                                      ? selectedColor
                                      : unselectedColor,
                                  fontWeight: isSelected
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                )),
                          );
                        }),
                      ),
                      SizedBox(width: ScreenAdapter.width(32)),
                      // 标准 Aa
                      GestureDetector(
                        onTap: () => controller.setFontSize(1.0),
                        child: Obx(() {
                          final isSelected =
                              controller.fontSizeScale.value == 1.0;
                          return Padding(
                            padding: EdgeInsets.all(ScreenAdapter.width(24)),
                            child: Text('Aa',
                                style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(48),
                                  color: isSelected
                                      ? selectedColor
                                      : unselectedColor,
                                  fontWeight: isSelected
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                )),
                          );
                        }),
                      ),
                      SizedBox(width: ScreenAdapter.width(32)),
                      // 大号 Aa
                      GestureDetector(
                        onTap: () => controller.setFontSize(1.2),
                        child: Obx(() {
                          final isSelected =
                              controller.fontSizeScale.value == 1.2;
                          return Padding(
                            padding: EdgeInsets.all(ScreenAdapter.width(24)),
                            child: Text('Aa',
                                style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(56) * 1.15,
                                  color: isSelected
                                      ? selectedColor
                                      : unselectedColor,
                                  fontWeight: isSelected
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                )),
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimer(bool isDark) {
    return Obx(() => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time,
                size: ScreenAdapter.width(60), color: _getIconColor(isDark)),
            SizedBox(width: ScreenAdapter.width(10)),
            Text(
              controller.timerText,
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(40),
                color: _getIconColor(isDark),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ));
  }

  Widget _buildFavoriteButton(bool isDark) {
    return Obx(() {
      final isFav =
          controller.favoriteQuestions[controller.currentQuestionIndex.value] ??
              false;
      final isCollecting = controller.isCollecting.value;

      return GestureDetector(
        onTap: isCollecting ? null : controller.toggleFavorite,
        child: Opacity(
          opacity: isCollecting ? 0.6 : 1.0,
          child: _buildIconButton(
            htxFonts.trainShoucang,
            controller.toggleFavorite,
            color: isFav ? Colors.red : _getIconColor(isDark),
          ),
        ),
      );
    });
  }

  Widget _buildTopBarTitle(bool isDark) {
    return SizedBox(
      height: ScreenAdapter.height(100),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${controller.subject} ${controller.chapter} ${controller.pageMode.value == 'VIEW' ? '- 背题' : ''}',
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(40),
                color: isDark ? const Color(0xFF999999) : Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: ScreenAdapter.width(20)),
          Obx(() => Text(
                '${controller.currentQuestionIndex.value + 1}/${controller.questions.length}',
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(40),
                  color: isDark ? const Color(0xFF999999) : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildGradientDivider() {
    final isDark = controller.isDarkMode.value;

    return Container(
      height: ScreenAdapter.height(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.45, 1.0],
          colors: isDark
              ? [
                  const Color(0xFF151515),
                  const Color(0xFF181818),
                  const Color(0xFF1A1A1A),
                ]
              : [
                  const Color(0xFFF1F1F1),
                  const Color(0xFFFAFAFA),
                  Colors.white,
                ],
        ),
      ),
    );
  }

  // ==================== 交卷按钮区域 ====================
  Widget _buildSubmitBar(bool isDark) {
    final bgColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenAdapter.width(32),
        vertical: ScreenAdapter.height(20),
      ),
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: ScreenAdapter.height(96),
        child: ElevatedButton(
          onPressed: () => controller.submitExam(),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ScreenAdapter.radius(48)),
            ),
            elevation: 0,
          ),
          child: Text(
            '交卷',
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(36),
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ==================== 内容区域 ====================
  Widget _buildContent(bool isDark, _ThemeColors theme) {
    if (controller.isLoading.value) {
      return const Center(
          child: CircularProgressIndicator(color: _primaryColor));
    }
    if (controller.errorMessage.value.isNotEmpty) {
      return Center(
          child: Text(controller.errorMessage.value,
              style: TextStyle(color: theme.text)));
    }
    if (controller.questions.isEmpty) {
      return Center(child: Text('暂无题目', style: TextStyle(color: theme.text)));
    }

    return Container(
      color: theme.background,
      child: PageView.builder(
        controller: controller.pageController,
        onPageChanged: controller.updateCurrentIndex,
        itemCount: controller.questions.length,
        itemBuilder: (context, index) => SingleChildScrollView(
          padding: EdgeInsets.only(
            left: ScreenAdapter.width(32),
            right: ScreenAdapter.width(32),
            top: ScreenAdapter.width(32),
            bottom: ScreenAdapter.width(32) + ScreenAdapter.bottomPadding(),
          ),
          child: _QuestionCard(
            index: index,
            isDark: isDark,
            theme: theme,
          ),
        ),
      ),
    );
  }

  // ==================== 设置悬浮卡片 ====================
  Widget _buildFloatingSettingsCard() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => controller.showSettingsCard.value = false,
      child: Container(
        color: Colors.transparent,
        child: Align(
          alignment: Alignment.topRight,
          child: GestureDetector(
            onTap: () {},
            child: Obx(() {
              final isDarkObs = controller.isDarkMode.value;
              final bgColor =
                  isDarkObs ? const Color(0xFF2A2A2A) : Colors.white;
              final borderColor =
                  isDarkObs ? const Color(0xFF3A3A3A) : const Color(0xFFF0F0F0);

              return SafeArea(
                child: Container(
                  margin: EdgeInsets.only(
                    top: ScreenAdapter.height(128),
                    right: ScreenAdapter.width(20),
                  ),
                  width: ScreenAdapter.width(460),
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenAdapter.width(32),
                    vertical: ScreenAdapter.height(32),
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius:
                        BorderRadius.circular(ScreenAdapter.radius(16)),
                    border: Border.all(
                      color: borderColor,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildPopoverModeRow(isDarkObs),
                      SizedBox(height: ScreenAdapter.height(32)),
                      _buildPopoverFontSizeRow(isDarkObs),
                      SizedBox(height: ScreenAdapter.height(32)),
                      _buildPopoverThemeRow(isDarkObs),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildPopoverModeRow(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildPopoverTextSegment(
            label: '做题模式',
            isSelected: controller.pageMode.value != 'VIEW',
            isDark: isDark,
            onTap: () => controller.changePageMode('TRAINING'),
          ),
        ),
        SizedBox(width: ScreenAdapter.width(16)),
        Expanded(
          child: _buildPopoverTextSegment(
            label: '背题模式',
            isSelected: controller.pageMode.value == 'VIEW',
            isDark: isDark,
            onTap: () {
              controller.changePageMode('VIEW');
              controller.showExplanation.value = false;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopoverFontSizeRow(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildPopoverFontSizeButton(0.8, ScreenAdapter.fontSize(38), isDark),
        _buildPopoverFontSizeButton(1.0, ScreenAdapter.fontSize(48), isDark),
        _buildPopoverFontSizeButton(1.2, ScreenAdapter.fontSize(58), isDark),
      ],
    );
  }

  Widget _buildPopoverThemeRow(bool isDark) {
    return Container(
      height: ScreenAdapter.height(68),
      padding: EdgeInsets.all(ScreenAdapter.width(5)),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242424) : const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(ScreenAdapter.radius(25)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPopoverTextSegment(
              label: '夜间',
              isSelected: controller.isDarkMode.value,
              isDark: isDark,
              compact: true,
              onTap: () => controller.toggleDarkMode(true),
            ),
          ),
          Expanded(
            child: _buildPopoverTextSegment(
              label: '日间',
              isSelected: !controller.isDarkMode.value,
              isDark: isDark,
              compact: true,
              onTap: () => controller.toggleDarkMode(false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopoverTextSegment({
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
    bool compact = false,
  }) {
    final selectedBg = isDark ? const Color(0xFF3A3A3A) : Colors.white;
    final selectedText = isDark ? Colors.white : const Color(0xFF3D444C);
    final unselectedText =
        isDark ? const Color(0xFF777777) : const Color(0xFFB0B4BA);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: compact ? double.infinity : ScreenAdapter.height(70),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(ScreenAdapter.radius(24)),
          boxShadow: isSelected && compact && !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(compact ? 32 : 36),
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            color: isSelected ? selectedText : unselectedText,
          ),
        ),
      ),
    );
  }

  Widget _buildPopoverFontSizeButton(
      double scale, double fontSize, bool isDark) {
    final isSelected = controller.fontSizeScale.value == scale;
    final selectedColor = isDark ? Colors.white : const Color(0xFF1F2329);
    final unselectedColor =
        isDark ? const Color(0xFF777777) : const Color(0xFFB0B4BA);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.setFontSize(scale),
      child: SizedBox(
        width: ScreenAdapter.width(124),
        height: ScreenAdapter.height(74),
        child: Center(
          child: Text(
            'Aa',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? selectedColor : unselectedColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLineHeightButton(String label, double height, bool isDark) {
    final isSelected = controller.lineHeight.value == height;
    return GestureDetector(
      onTap: () => controller.setLineHeight(height),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenAdapter.width(24),
          vertical: ScreenAdapter.height(14),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1890FF)
              : (isDark ? const Color(0xFF333333) : const Color(0xFFF5F5F5)),
          borderRadius: BorderRadius.circular(ScreenAdapter.radius(28)),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1890FF)
                : (isDark ? const Color(0xFF444444) : const Color(0xFFE0E0E0)),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(32),
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFF999999) : const Color(0xFF666666)),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsModeSelection(bool isDark, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(bottom: ScreenAdapter.height(32)),
          child: Text('设置出题模式',
              style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(40), color: textColor)),
        ),
        Row(
          children: [
            Expanded(
                child: _ModeOptionButton(
                    mode: 'TRAINING',
                    title: '做题模式',
                    color: Colors.blueAccent,
                    isDark: isDark)),
            SizedBox(width: ScreenAdapter.width(30)),
            Expanded(
                child: _ModeOptionButton(
                    mode: 'VIEW',
                    title: '背题模式',
                    color: Colors.green,
                    isDark: isDark)),
          ],
        ),
      ],
    );
  }

  // ==================== 左右切换开关组 ====================
  Widget _buildModeToggleSwitch({
    required String leftLabel,
    required String rightLabel,
    required bool isRightSelected,
    required VoidCallback onLeftTap,
    required VoidCallback onRightTap,
    required bool isDark,
  }) {
    final bgColor = isDark ? const Color(0xFF333333) : const Color(0xFFE8E8E8);
    final selectedBgColor = const Color(0xFF1890FF);
    final selectedTextColor = Colors.white;
    final unselectedTextColor =
        isDark ? const Color(0xFF666666) : const Color(0xFF999999);
    // 按钮宽度200，左右各一个，加上padding
    final switchWidth = ScreenAdapter.width(400);
    final switchHeight = ScreenAdapter.height(80);
    final padding = ScreenAdapter.width(6);

    return GestureDetector(
      onTap: () {
        if (isRightSelected) {
          onLeftTap();
        } else {
          onRightTap();
        }
      },
      child: Container(
        width: switchWidth,
        height: switchHeight,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(ScreenAdapter.radius(40)),
          border: Border.all(
            color: isDark ? const Color(0xFF444444) : const Color(0xFFDDDDDD),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // 滑动指示器
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: isRightSelected ? (switchWidth / 2 - padding) : padding,
              top: padding,
              bottom: padding,
              width: (switchWidth / 2) - padding * 1.5,
              child: Container(
                decoration: BoxDecoration(
                  color: selectedBgColor,
                  borderRadius: BorderRadius.circular(ScreenAdapter.radius(36)),
                ),
              ),
            ),
            // 文字层（垂直居中）
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onLeftTap,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        leftLabel,
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(36),
                          fontWeight: FontWeight.w500,
                          color: !isRightSelected
                              ? selectedTextColor
                              : unselectedTextColor,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: onRightTap,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        rightLabel,
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(36),
                          fontWeight: FontWeight.w500,
                          color: isRightSelected
                              ? selectedTextColor
                              : unselectedTextColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeSetting(bool isDark, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('字体大小',
            style: TextStyle(
                fontSize: ScreenAdapter.fontSize(40), color: textColor)),
        SizedBox(height: ScreenAdapter.height(32)),
        Row(
          children: [
            Expanded(
                child: _FontSizeOption(label: '小', scale: 0.8, isDark: isDark)),
            SizedBox(width: ScreenAdapter.width(30)),
            Expanded(
                child:
                    _FontSizeOption(label: '标准', scale: 1.0, isDark: isDark)),
            SizedBox(width: ScreenAdapter.width(30)),
            Expanded(
                child: _FontSizeOption(label: '大', scale: 1.2, isDark: isDark)),
          ],
        ),
      ],
    );
  }

  Widget _buildNightModeSetting(bool isDark, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('夜间模式',
            style: TextStyle(
                fontSize: ScreenAdapter.fontSize(40),
                fontWeight: FontWeight.w500,
                color: textColor)),
        SizedBox(height: ScreenAdapter.height(32)),
        Row(
          children: [
            Expanded(
                child: _NightModeOption(
                    label: '日间模式', isDarkMode: false, isDark: isDark)),
            SizedBox(width: ScreenAdapter.width(30)),
            Expanded(
                child: _NightModeOption(
                    label: '夜间模式', isDarkMode: true, isDark: isDark)),
          ],
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return GestureDetector(
      onTap: () => SmartDialog.dismiss(),
      child: Container(
        width: ScreenAdapter.width(800),
        height: ScreenAdapter.height(130),
        decoration: BoxDecoration(
          color: _primaryColor,
          borderRadius: BorderRadius.circular(ScreenAdapter.radius(24)),
        ),
        child: Center(
          child: Text('确定',
              style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(50), color: Colors.white)),
        ),
      ),
    );
  }

  // ==================== 工具方法 ====================
  Color _getIconColor(bool isDark) =>
      isDark ? const Color(0xFF999999) : const Color(0xFF3D444C);

  Widget _buildIconButton(IconData icon, VoidCallback onTap,
      {Color? color, bool isDark = false, double? size}) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon,
          size: size ?? ScreenAdapter.width(60),
          color: color ?? _getIconColor(isDark)),
    );
  }
}

// ==================== 主题颜色====================
class _ThemeColors {
  final Color background;
  final Color card;
  final Color text;

  const _ThemeColors(
      {required this.background, required this.card, required this.text});

  factory _ThemeColors.fromDarkMode(bool isDark) {
    return _ThemeColors(
      background: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      card: isDark ? const Color(0xFF242424) : Colors.white,
      text: isDark ? const Color(0xFF999999) : const Color(0xFF3D444C),
    );
  }
}

// ==================== 题目卡片组件 ====================
class _QuestionCard extends GetView<QuestionTrainController> {
  final int index;
  final bool isDark;
  final _ThemeColors theme;

  const _QuestionCard(
      {required this.index, required this.isDark, required this.theme});

  static const Color _primaryColor = Color(0xFF1890FF);
  static const Color _successColor = Color(0xFF52C41A);
  static const Color _errorColor = Color(0xFFF5222D);

  @override
  Widget build(BuildContext context) {
    final question = controller.questions[index];

    return Obx(() {
      // 根据模式决定显示内容
      // 答题模式(TRAINING/EXAM): 只显示题目和选项
      // 背题模式(VIEW): 显示题目、选项，点击选项后显示答案统计和解析
      final bool isViewMode = controller.pageMode.value == 'VIEW';

      return Column(
        children: [
          _buildQuestionContainer(question),

          // 答案统计 + 解析区域：背题模式下点击选项后才显示
          if (isViewMode && controller.showExplanation.value) ...[
            _buildSectionGap(),
            _AnswerStats(index: index, isDark: isDark, theme: theme),
            _buildSectionGap(),
            _ExplanationSection(
                question: question, isDark: isDark, theme: theme),
            _buildSectionGap(),
            _VideoSection(isDark: isDark, question: question),
            _buildSectionGap(),
            _KnowledgePointsSection(isDark: isDark, theme: theme),
          ],
        ],
      );
    });
  }

  Widget _buildQuestionContainer(Question question) {
    return Container(
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(ScreenAdapter.radius(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        ScreenAdapter.width(32),
        ScreenAdapter.height(12),
        ScreenAdapter.width(32),
        ScreenAdapter.width(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuestionTitle(question),
          SizedBox(height: ScreenAdapter.height(40)),
          ...List.generate(
              question.options.length,
              (optIndex) => _OptionItem(
                    qIndex: index,
                    optIndex: optIndex,
                    question: question,
                    isDark: isDark,
                    theme: theme,
                  )),
        ],
      ),
    );
  }

  Widget _buildQuestionTitle(Question question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _QuestionTypeLabel(question: question),
        SizedBox(height: ScreenAdapter.height(20)),
        Text(
          question.content,
          style: TextStyle(
            fontSize:
                ScreenAdapter.fontSize(46) * controller.fontSizeScale.value,
            height: controller.lineHeight.value,
            fontWeight: FontWeight.w400,
            color: isDark ? const Color(0xFF999999) : const Color(0xFF3D444C),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionGap() => Container(
        width: double.infinity,
        height: ScreenAdapter.height(24),
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      );
}

// ==================== 选项组件 ====================
class _OptionItem extends StatelessWidget {
  final int qIndex;
  final int optIndex;
  final Question question;
  final bool isDark;
  final _ThemeColors theme;

  const _OptionItem({
    required this.qIndex,
    required this.optIndex,
    required this.question,
    required this.isDark,
    required this.theme,
  });

  static const Color _primaryColor = Color(0xFF1890FF);
  static const Color _successColor = Color(0xFF52C41A);
  static const Color _errorColor = Color(0xFFF5222D);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<QuestionTrainController>();
      final userAnswers = controller.userAnswers[qIndex] ?? [];
      final isSelected = userAnswers.contains(optIndex);
      final prefix = String.fromCharCode(65 + optIndex);
      final colors = _getOptionColors(controller, isSelected);

      return GestureDetector(
        onTap: () => controller.selectAnswer(optIndex),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          margin: EdgeInsets.only(bottom: ScreenAdapter.height(24)),
          padding: EdgeInsets.symmetric(
              horizontal: ScreenAdapter.width(32),
              vertical: ScreenAdapter.height(24)),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(ScreenAdapter.radius(16)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                width: ScreenAdapter.width(90),
                height: ScreenAdapter.width(90),
                decoration: BoxDecoration(
                  color: colors.bg,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.border, width: 1),
                ),
                child: Center(
                  child: Text(prefix,
                      style: TextStyle(
                          color: colors.text,
                          fontSize: ScreenAdapter.fontSize(40))),
                ),
              ),
              SizedBox(width: ScreenAdapter.width(24)),
              Expanded(
                child: Text(
                  question.options[optIndex],
                  style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(46),
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? const Color(0xFF999999)
                          : const Color(0xFF3D444C)),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  _OptionColors _getOptionColors(
      QuestionTrainController controller, bool isSelected) {
    Color bg = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    Color text = isDark ? const Color(0xFF888888) : Colors.grey[600]!;
    Color border = isDark ? const Color(0xFF444444) : Colors.grey[400]!;

    if (controller.showExplanation.value) {
      final isCorrect = question.correctAnswers.contains(optIndex);
      if (isCorrect) {
        return _OptionColors(
            bg: _successColor, text: Colors.white, border: _successColor);
      } else if (isSelected) {
        return _OptionColors(
            bg: _errorColor, text: Colors.white, border: _errorColor);
      }
    } else if (isSelected) {
      return _OptionColors(
          bg: _primaryColor, text: Colors.white, border: _primaryColor);
    }

    return _OptionColors(bg: bg, text: text, border: border);
  }
}

class _OptionColors {
  final Color bg;
  final Color text;
  final Color border;
  const _OptionColors(
      {required this.bg, required this.text, required this.border});
}

// ==================== 题型标签组件 ====================
class _QuestionTypeLabel extends GetView<QuestionTrainController> {
  final Question question;
  const _QuestionTypeLabel({required this.question});

  // 题型标签颜色
  static const Color _labelBg = Color(0xFFEDF0FF);
  static const Color _labelText = Color(0xFF517FB1);

  @override
  Widget build(BuildContext context) {
    final text = controller.getQuestionTypeText(question);
    final isDark = controller.isDarkMode.value;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: ScreenAdapter.width(16),
          vertical: ScreenAdapter.height(8)),
      decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : _labelBg,
          borderRadius: BorderRadius.circular(4)),
      child: Text(
        text,
        style: TextStyle(
            fontSize: ScreenAdapter.fontSize(32),
            color: isDark ? const Color(0xFF6B9BD1) : _labelText,
            fontWeight: FontWeight.w500),
      ),
    );
  }
}

// ==================== 答案统计组件 ====================
class _AnswerStats extends GetView<QuestionTrainController> {
  final int index;
  final bool isDark;
  final _ThemeColors theme;

  const _AnswerStats(
      {required this.index, required this.isDark, required this.theme});

  static const Color _primaryColor = Color(0xFF1890FF);
  static const Color _successColor = Color(0xFF52C41A);
  static const Color _errorColor = Color(0xFFF5222D);

  @override
  Widget build(BuildContext context) {
    final question = controller.questions[index];
    final userAnswers = controller.userAnswers[index] ?? [];
    final isCorrect = controller.answerResults[index] ?? false;

    String correctText;
    if (question.answer != null && question.answer!.isNotEmpty) {
      correctText = question.answer!;
    } else if (question.correctAnswers.isNotEmpty) {
      correctText = controller.formatAnswerIndices(question.correctAnswers);
    } else {
      correctText = '--';
    }
    final userText = controller.formatAnswerIndices(userAnswers);

    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(24)),
      padding: EdgeInsets.all(ScreenAdapter.width(32)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildAnswerRow('正确答案', correctText, _successColor),
          _buildAnswerRow(
              '你的答案', userText, isCorrect ? _successColor : _errorColor),
        ],
      ),
    );
  }

  Widget _buildAnswerRow(String label, String value, Color valueColor) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(40), color: theme.text)),
          Text(value,
              style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(40),
                  color: valueColor,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, Color valueColor) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(48),
                  color: valueColor,
                  fontWeight: FontWeight.w500)),
          SizedBox(height: ScreenAdapter.height(8)),
          Text(label,
              style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(32),
                  color: isDark ? Colors.grey[400] : Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildDivider() => Container(
        width: ScreenAdapter.width(2),
        height: ScreenAdapter.height(80),
        color: isDark ? Colors.grey[700] : Colors.grey[300],
      );
}

// ==================== 视频区域组件 ====================
class _VideoSection extends StatelessWidget {
  final bool isDark;
  final Question question;
  const _VideoSection({required this.isDark, required this.question});

  static const Color _primaryColor = Color(0xFF1890FF);

  @override
  Widget build(BuildContext context) {
    final hasVideo = question.videoUrl != null && question.videoUrl!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: '解析视频', isDark: isDark),
        SizedBox(height: ScreenAdapter.height(24)),
        if (hasVideo) _buildVideoCard() else _buildNoVideoPlaceholder(),
      ],
    );
  }

  Widget _buildVideoCard() {
    return Container(
      width: double.infinity,
      height: ScreenAdapter.height(400),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(ScreenAdapter.radius(16)),
      ),
      child: Stack(
        children: [
          _buildBackgroundImage(),
          _buildOverlay(),
          _buildVideoContent(),
        ],
      ),
    );
  }

  Widget _buildNoVideoPlaceholder() {
    return Container(
      width: double.infinity,
      height: ScreenAdapter.height(200),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(ScreenAdapter.radius(16)),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam_off,
                size: ScreenAdapter.width(48),
                color: isDark ? const Color(0xFF666666) : Colors.grey[400]),
            SizedBox(width: ScreenAdapter.width(16)),
            Text('暂无视频解析',
                style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(32),
                    color:
                        isDark ? const Color(0xFF666666) : Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ScreenAdapter.radius(16)),
        child: Image.asset(
          'assets/images/ceshi.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
              color:
                  isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE0E0E0)),
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(ScreenAdapter.radius(16)),
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    return Positioned.fill(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildVipBadge(),
          SizedBox(height: ScreenAdapter.height(32)),
          Text('会员专享，观看解析视频请开通会员',
              style: TextStyle(
                  color: Colors.white, fontSize: ScreenAdapter.fontSize(40))),
          SizedBox(height: ScreenAdapter.height(48)),
          _buildVipButton(),
          SizedBox(height: ScreenAdapter.height(32)),
          _buildPromoRow(),
        ],
      ),
    );
  }

  Widget _buildVipBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: ScreenAdapter.width(24),
          vertical: ScreenAdapter.height(12)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700),
        borderRadius: BorderRadius.circular(ScreenAdapter.radius(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium,
              color: Colors.brown[700], size: ScreenAdapter.width(32)),
          SizedBox(width: ScreenAdapter.width(8)),
          Text('会员专享',
              style: TextStyle(
                  color: Colors.brown[700],
                  fontSize: ScreenAdapter.fontSize(32),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildVipButton() {
    return GestureDetector(
      onTap: () => Get.snackbar('提示', '开通会员功能开发中',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1890FF),
          colorText: Colors.white,
          duration: const Duration(seconds: 2)),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: ScreenAdapter.width(80),
            vertical: ScreenAdapter.height(24)),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight),
          borderRadius: BorderRadius.circular(ScreenAdapter.radius(40)),
        ),
        child: Text('开通会员',
            style: TextStyle(
                color: Colors.brown[700],
                fontSize: ScreenAdapter.fontSize(36),
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildPromoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.notifications_active,
            color: const Color(0xFFFFD700), size: ScreenAdapter.width(32)),
        SizedBox(width: ScreenAdapter.width(8)),
        Text('送！3 天内无限次观看视频',
            style: TextStyle(
                color: Colors.white70, fontSize: ScreenAdapter.fontSize(28))),
        Icon(Icons.arrow_forward_ios,
            color: Colors.white70, size: ScreenAdapter.width(24)),
      ],
    );
  }
}

// ==================== 解析区域组件 ====================
class _ExplanationSection extends GetView<QuestionTrainController> {
  final Question question;
  final bool isDark;
  final _ThemeColors theme;

  const _ExplanationSection(
      {required this.question, required this.isDark, required this.theme});

  static const Color _primaryColor = Color(0xFF1890FF);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: '答案解析', isDark: isDark),
        SizedBox(height: ScreenAdapter.height(24)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(ScreenAdapter.width(32)),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(ScreenAdapter.radius(16)),
          ),
          child: Text(
            question.explanation,
            style: TextStyle(
                color: theme.text,
                height: 1.6,
                fontSize: ScreenAdapter.fontSize(40) *
                    controller.fontSizeScale.value),
          ),
        ),
      ],
    );
  }
}

// ==================== 考点区域组件 ====================
class _KnowledgePointsSection extends GetView<QuestionTrainController> {
  final bool isDark;
  final _ThemeColors theme;

  const _KnowledgePointsSection({required this.isDark, required this.theme});

  static const Color _primaryColor = Color(0xFF1890FF);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: '考点', isDark: isDark),
        SizedBox(height: ScreenAdapter.height(24)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(ScreenAdapter.width(32)),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(ScreenAdapter.radius(16)),
          ),
          child: Text(
            '本题主要考查相关知识点，请结合题目内容理解和掌握',
            style: TextStyle(
                color: theme.text,
                height: 1.6,
                fontSize: ScreenAdapter.fontSize(40) *
                    controller.fontSizeScale.value),
          ),
        ),
      ],
    );
  }
}

// ==================== 通用组件 ====================
class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;
  static const Color _primaryColor = Color(0xFF1890FF);

  const _SectionTitle({required this.title, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: ScreenAdapter.width(8),
          height: ScreenAdapter.height(32),
          decoration: BoxDecoration(
              color: _primaryColor, borderRadius: BorderRadius.circular(4)),
        ),
        SizedBox(width: ScreenAdapter.width(16)),
        Text(
          title,
          style: TextStyle(
              fontSize: ScreenAdapter.fontSize(44),
              fontWeight: FontWeight.w500,
              color:
                  isDark ? const Color(0xFF999999) : const Color(0xFF3D444C)),
        ),
      ],
    );
  }
}

// ==================== 设置弹窗组件 ====================
class _ModeOptionButton extends GetView<QuestionTrainController> {
  final String mode;
  final String title;
  final Color color;
  final bool isDark;

  const _ModeOptionButton(
      {required this.mode,
      required this.title,
      required this.color,
      required this.isDark});

  static const Color _primaryColor = Color(0xFF1890FF);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 直接使用 controller.pageMode，实时响应变化
      final isSelected = controller.pageMode.value == mode;
      return GestureDetector(
        onTap: () {
          controller.changePageMode(mode);
          SmartDialog.dismiss();
        },
        child: Container(
          height: ScreenAdapter.height(140),
          padding: EdgeInsets.all(ScreenAdapter.width(24)),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFF0F9FF)
                : (isDark ? const Color(0xFF3D3D3D) : const Color(0xFFF5F5F5)),
            borderRadius: BorderRadius.circular(ScreenAdapter.radius(24)),
            border: Border.all(
                color: isSelected ? _primaryColor : Colors.transparent,
                width: ScreenAdapter.width(2)),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(40),
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? _primaryColor
                    : (isDark ? Colors.grey[400] : const Color(0xFF3D444C)),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _FontSizeOption extends GetView<QuestionTrainController> {
  final String label;
  final double scale;
  final bool isDark;

  const _FontSizeOption(
      {required this.label, required this.scale, required this.isDark});

  static const Color _primaryColor = Color(0xFF1890FF);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.fontSizeScale.value == scale;
      return GestureDetector(
        onTap: () => controller.setFontSize(scale),
        child: Container(
          height: ScreenAdapter.height(140),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFF0F9FF)
                : (isDark ? const Color(0xFF3D3D3D) : const Color(0xFFF5F5F5)),
            borderRadius: BorderRadius.circular(ScreenAdapter.radius(24)),
            border: Border.all(
                color: isSelected ? _primaryColor : Colors.transparent,
                width: ScreenAdapter.width(2)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(40),
              color: isSelected
                  ? _primaryColor
                  : (isDark ? Colors.grey[400] : const Color(0xFF3D444C)),
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      );
    });
  }
}

class _NightModeOption extends GetView<QuestionTrainController> {
  final String label;
  final bool isDarkMode;
  final bool isDark;

  const _NightModeOption(
      {required this.label, required this.isDarkMode, required this.isDark});

  static const Color _primaryColor = Color(0xFF1890FF);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.isDarkMode.value == isDarkMode;
      return GestureDetector(
        onTap: () => controller.toggleDarkMode(isDarkMode),
        child: Container(
          height: ScreenAdapter.height(140),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFF0F9FF)
                : (isDark ? const Color(0xFF3D3D3D) : const Color(0xFFF5F5F5)),
            borderRadius: BorderRadius.circular(ScreenAdapter.radius(24)),
            border: Border.all(
                color: isSelected ? _primaryColor : Colors.transparent,
                width: ScreenAdapter.width(2)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(40),
              color: isSelected
                  ? _primaryColor
                  : (isDark ? Colors.grey[400] : const Color(0xFF3D444C)),
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      );
    });
  }
}
