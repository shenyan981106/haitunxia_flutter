import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 通用错误状态组件
class CommonErrorState extends StatelessWidget {
  /// 错误信息文字
  final String message;

  /// 点击重新加载回调
  final VoidCallback onRetry;

  /// 按钮文字（默认"重新加载"）
  final String? buttonText;

  const CommonErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 120.sp,
            color: const Color(0xFFFFB3B3),
          ),
          SizedBox(height: 32.h),
          Text(
            message,
            style: TextStyle(fontSize: 32.sp, color: const Color(0xFF999999)),
          ),
          SizedBox(height: 48.h),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 56.w, vertical: 24.h),
              decoration: BoxDecoration(
                color: const Color(0xFF1890FF),
                borderRadius: BorderRadius.circular(44.r),
              ),
              child: Text(
                buttonText ?? '重新加载',
                style: TextStyle(
                  fontSize: 30.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
