import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class SnackbarUtils {
  // 成功提示
  static void showSuccess(String message) {
    SmartDialog.dismiss();
    SmartDialog.showToast(
      message,
      displayType: SmartToastType.onlyRefresh,
      alignment: Alignment.center,
      maskColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xE6000000),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        );
      },
    );
  }

  // 错误提示
  static void showError(String message) {
    SmartDialog.dismiss();
    SmartDialog.showToast(
      message,
      displayType: SmartToastType.onlyRefresh,
      alignment: Alignment.center,
      maskColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xE6FF4B4B),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        );
      },
    );
  }

  // 警告提示
  static void showWarning(String message) {
    SmartDialog.showToast(
      message,
      displayType: SmartToastType.onlyRefresh,
      alignment: Alignment.center,
      maskColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFE6A800),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        );
      },
    );
  }

  // 信息提示
  static void showInfo(String message) {
    // 先清除之前的提示，避免重复
    SmartDialog.dismiss();
    SmartDialog.showToast(
      message,
      displayType: SmartToastType.onlyRefresh,
      alignment: Alignment.center,
      maskColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xE6000000),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        );
      },
    );
  }

  // 显示加载
  static void showLoading({String? msg}) {
    SmartDialog.showLoading(
      msg: msg ?? '加载中..',
      maskColor: Colors.black.withValues(alpha: 0.3),
    );
  }

  // 关闭加载
  static void dismissLoading() {
    SmartDialog.dismiss();
  }
}
