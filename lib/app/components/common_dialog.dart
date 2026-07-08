import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/screenAdapter.dart';

class CommonDialog {
  static Future<bool> show({
    required String title,
    required String content,
    String confirmText = '确定',
    String cancelText = '取消',
    bool showCancelButton = true,
    bool barrierDismissible = true,
    Color confirmColor = const Color(0xFF3D7CFF),
    Color cancelColor = const Color(0xFFF0F2F5),
  }) async {
    final completer = Completer<bool>();

    Get.dialog(
      Center(
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            width: ScreenAdapter.width(800),
            margin: EdgeInsets.symmetric(horizontal: ScreenAdapter.width(75)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ScreenAdapter.width(30)),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(ScreenAdapter.width(40)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 标题
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(46),
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      SizedBox(height: ScreenAdapter.height(30)),

                      // 内容
                      Text(
                        content,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(34),
                          color: Color(0xFF666666),
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: ScreenAdapter.height(40)),

                      // 按钮
                      if (showCancelButton)
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Get.back();
                                  completer.complete(false);
                                },
                                child: Container(
                                  height: ScreenAdapter.height(110),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: cancelColor,
                                    borderRadius: BorderRadius.circular(
                                        ScreenAdapter.width(55)),
                                  ),
                                  child: Text(
                                    cancelText,
                                    style: TextStyle(
                                      color: Color(0xFF333333),
                                      fontSize: ScreenAdapter.fontSize(36),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: ScreenAdapter.width(20)),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Get.back();
                                  completer.complete(true);
                                },
                                child: Container(
                                  height: ScreenAdapter.height(110),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: confirmColor,
                                    borderRadius: BorderRadius.circular(
                                        ScreenAdapter.width(55)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: confirmColor.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    confirmText,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: ScreenAdapter.fontSize(36),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        GestureDetector(
                          onTap: () {
                            Get.back();
                            completer.complete(true);
                          },
                          child: Container(
                            height: ScreenAdapter.height(110),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: confirmColor,
                              borderRadius: BorderRadius.circular(
                                  ScreenAdapter.width(55)),
                              boxShadow: [
                                BoxShadow(
                                  color: confirmColor.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Text(
                              confirmText,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: ScreenAdapter.fontSize(36),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  right: ScreenAdapter.width(20),
                  top: ScreenAdapter.width(20),
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                      completer.complete(false);
                    },
                    child: Container(
                      padding: EdgeInsets.all(ScreenAdapter.width(10)),
                      child: Icon(
                        Icons.close,
                        color: const Color(0xFF999999),
                        size: ScreenAdapter.fontSize(40),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: barrierDismissible,
    );

    return completer.future;
  }
}
