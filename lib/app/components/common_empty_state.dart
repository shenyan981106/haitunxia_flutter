import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 通用空状态组件
///
/// 用于展示列表/页面为空时的占位提示，
/// 统一项目中各页面的空状态样式。
class CommonEmptyState extends StatelessWidget {
  /// 空状态图标
  final IconData icon;

  /// 图标大小（默认 160.sp）
  final double? iconSize;

  /// 图标颜色（默认 #DDDDDD）
  final Color? iconColor;

  /// 主标题文字
  final String title;

  /// 副标题文字（可选）
  final String? subtitle;

  /// 标题字号（默认 34.sp）
  final double? titleFontSize;

  /// 副标题字号（默认 28.sp）
  final double? subtitleFontSize;

  const CommonEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconSize,
    this.iconColor,
    this.titleFontSize,
    this.subtitleFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: iconSize ?? 160.sp,
            color: iconColor ?? const Color(0xFFDDDDDD),
          ),
          SizedBox(height: 32.h),
          Text(
            title,
            style: TextStyle(
              fontSize: titleFontSize ?? 34.sp,
              color: const Color(0xFF999999),
            ),
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: subtitleFontSize ?? 28.sp,
                color: const Color(0xFFBBBBBB),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
