import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 圆角筛选下拉按钮
/// 用于筛选栏中的下拉选择按钮，统一风格：灰色圆角背景 + 文字 + 下拉箭头
class FilterDropdownButton extends StatelessWidget {
  /// 按钮显示的文字
  final String label;

  /// 点击回调
  final VoidCallback onTap;

  /// 按钮宽度，默认 340.w
  final double? width;

  /// 按钮高度，默认 80.h
  final double? height;

  /// 背景颜色，默认 Color(0xFFF5F6F8)
  final Color? backgroundColor;

  /// 文字颜色，默认 Color(0xFFB1B8CA)
  final Color? textColor;

  /// 文字大小，默认 34.sp
  final double? fontSize;

  const FilterDropdownButton({
    super.key,
    required this.label,
    required this.onTap,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? 340.w,
        height: height ?? 80.h,
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0xFFF5F6F8),
          borderRadius: BorderRadius.circular((height ?? 80.h) / 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize ?? 34.sp,
                color: textColor ?? const Color(0xFFB1B8CA),
              ),
            ),
            SizedBox(width: 6.w),
            Icon(
              Icons.keyboard_arrow_down,
              size: (fontSize ?? 34.sp) * 0.94,
              color: textColor ?? const Color(0xFFB1B8CA),
            ),
          ],
        ),
      ),
    );
  }
}
