import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:xmshop/app/routes/app_pages.dart';
import '../controllers/questions_result_controller.dart';

class QuestionsResultView extends GetView<QuestionsResultController> {
  const QuestionsResultView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFE8EDFF),
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFE8EDFF),
                      Color(0xFFF6F7F9),
                    ],
                    stops: [0.0, 0.6],
                  ),
                ),
              ),
              Column(
                children: [
                  _buildTopNav(),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 40.w,
                        vertical: 24.h,
                      ),
                      children: [
                        _buildGaugeCard(),
                        SizedBox(height: 24.h),
                        _buildExamSituationCard(),
                        SizedBox(height: 24.h),
                        _buildSubjectCard(),
                        SizedBox(height: 40.h),
                        // 返回首页按钮
                        _buildBottomButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopNav() {
    return Container(
      height: 100.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Icon(
              Icons.chevron_left,
              size: 56.sp,
              color: const Color(0xFF333333),
            ),
          ),
          Expanded(
            child: Text(
              '练习报告',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 50.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF333333),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // TODO: 分享功能
            },
            child: Icon(
              Icons.share_outlined,
              size: 48.sp,
              color: const Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGaugeCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 40.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26.r),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Obx(() => _buildGauge()),
            ],
          ),
          SizedBox(height: 30.h),
          Obx(() => _buildInfoRow(
                icon: Icons.bookmark_outline,
                label: '练习类型：',
                value: controller.title.value,
              )),
          SizedBox(height: 16.h),
          _buildInfoRow(
            icon: Icons.access_time_outlined,
            label: '交卷时间：',
            value: _formatSubmitTime(),
          ),
        ],
      ),
    );
  }

  Widget _buildGauge() {
    final correctCount = controller.correctCount.value;
    final totalCount = controller.questionCount.value;
    final percentage = totalCount > 0 ? correctCount / totalCount : 0.0;

    return SizedBox(
      width: 400.w,
      height: 260.h,
      child: CustomPaint(
        painter: _GaugePainter(percentage: percentage),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '答对',
              style: TextStyle(fontSize: 30.sp, color: const Color(0xFF666666)),
            ),
            Text(
              '$correctCount',
              style: TextStyle(
                  fontSize: 80.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333)),
            ),
            Text('/$totalCount',
                style:
                    TextStyle(fontSize: 30.sp, color: const Color(0xFF999999))),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge() {
    final correctCount = controller.correctCount.value;
    final totalCount = controller.questionCount.value;
    final accuracy =
        totalCount > 0 ? (correctCount / totalCount * 100).round() : 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFF4A90D9),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        '难度 ${_getDifficultyLabel(accuracy)}',
        style: TextStyle(
          fontSize: 26.sp,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getDifficultyLabel(int accuracy) {
    if (accuracy >= 80) return '1.0';
    if (accuracy >= 60) return '2.0';
    if (accuracy >= 40) return '3.0';
    if (accuracy >= 20) return '4.0';
    return '5.0';
  }

  Widget _buildExamSituationCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 36.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26.r),
      ),
      child: Obx(() {
        final totalCount = controller.questionCount.value;
        final answeredCount = controller.answeredCount.value;
        final correctCount = controller.correctCount.value;
        final wrongCount = controller.wrongCount.value;
        final unansweredCount = totalCount - answeredCount;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit_note,
                  size: 44.sp,
                  color: const Color(0xFF4A90D9),
                ),
                SizedBox(width: 12.w),
                Text(
                  '考试情况',
                  style: TextStyle(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF333333),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FB),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                      '一共', '${totalCount}题', const Color(0xFF4A90D9)),
                  _buildStatItem(
                      '答对', '${correctCount}题', const Color(0xFF4CAF50)),
                  _buildStatItem(
                      '答错', '${wrongCount}题', const Color(0xFFFF6B6B)),
                  _buildStatItem(
                      '未答', '${unansweredCount}题', const Color(0xFF999999)),
                  _buildStatItem(
                    '总用时',
                    _formatDuration(controller.durationSeconds.value),
                    const Color(0xFF4A90D9),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(fontSize: 28.sp, color: const Color(0xFF999999))),
        SizedBox(height: 8.h),
        Text(value,
            style: TextStyle(
                fontSize: 32.sp, fontWeight: FontWeight.w500, color: color)),
      ],
    );
  }

  Widget _buildSubjectCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 36.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26.r),
      ),
      child: Obx(() {
        final totalCount = controller.questionCount.value;
        final correctCount = controller.correctCount.value;
        final accuracy = totalCount > 0
            ? (correctCount / totalCount * 100).toStringAsFixed(0)
            : '0';

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle,
                size: 48.sp, color: const Color(0xFF4A90D9)),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.title.value,
                    style: TextStyle(
                        fontSize: 38.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF333333)),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '共${totalCount}道，答对${correctCount}道，正确率${accuracy}%，用时${_formatDuration(controller.durationSeconds.value)}',
                    style: TextStyle(
                        fontSize: 28.sp, color: const Color(0xFF999999)),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildBottomButton() {
    return GestureDetector(
      onTap: () => Get.offAllNamed(Routes.TABS),
      child: Container(
        width: double.infinity,
        height: 96.h,
        decoration: BoxDecoration(
          color: const Color(0xFF4A90D9),
          borderRadius: BorderRadius.circular(26.r),
        ),
        alignment: Alignment.center,
        child: Text(
          '返回首页',
          style: TextStyle(
            fontSize: 36.sp,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      {required IconData icon, required String label, required String value}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 36.sp, color: const Color(0xFF999999)),
          SizedBox(width: 12.w),
          Text(label,
              style:
                  TextStyle(fontSize: 32.sp, color: const Color(0xFF999999))),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 32.sp,
                    color: const Color(0xFF333333),
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}秒';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s > 0 ? '${m}分${s}秒' : '${m}分';
  }

  String _formatSubmitTime() {
    final now = DateTime.now();
    return '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}

/// 弧形仪表盘绘制器
class _GaugePainter extends CustomPainter {
  final double percentage;

  _GaugePainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    // 弧的中心在上方，文字在下方
    final centerX = size.width / 2;
    final centerY = size.height * 0.42;
    final radius = math.min(size.width, size.height) * 0.48;
    final center = Offset(centerX, centerY);

    // 背景弧：上半圆弧（从左到右，约240度）
    final bgPaint = Paint()
      ..color = const Color(0xFFE0E5F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16.w
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _degToRad(150), // 起点：左下方
      _degToRad(240), // 扫过240度到右下方
      false,
      bgPaint,
    );

    // 进度弧
    if (percentage > 0) {
      final progressPaint = Paint()
        ..color = const Color(0xFF4A90D9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16.w
        ..strokeCap = StrokeCap.round;

      final sweepAngle = _degToRad(240) * percentage.clamp(0.0, 1.0);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        _degToRad(150),
        sweepAngle,
        false,
        progressPaint,
      );

      // 端点圆球
      final endAngle = _degToRad(150) + sweepAngle;
      final ballX = center.dx + radius * math.cos(endAngle);
      final ballY = center.dy + radius * math.sin(endAngle);

      // 阴影
      final shadowPaint = Paint()
        ..color = const Color(0xFF4A90D9).withOpacity(0.2)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(ballX, ballY), 16.w, shadowPaint);

      // 主球体
      final ballPaint = Paint()
        ..color = const Color(0xFF4A90D9)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(ballX, ballY), 12.w, ballPaint);

      // 高光
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
          Offset(ballX - 4.w, ballY - 4.h), 4.5.w, highlightPaint);
    }
  }

  double _degToRad(double deg) => deg * math.pi / 180;

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.percentage != percentage;
}
