import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/providers/api_client.dart';
import '../services/screenAdapter.dart';

class CustomerServiceDialog {
  static void show({String? qrCodeUrl}) {
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
                        '客服中心',
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(46),
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      SizedBox(height: ScreenAdapter.height(30)),

                      // 提示文字
                      Text(
                        '立即添加老师，领取专属资料',
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(34),
                          color: Color(0xFF333333),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: ScreenAdapter.height(40)),

                      // 二维码容器
                      Container(
                        width: ScreenAdapter.width(500),
                        height: ScreenAdapter.width(500),
                        padding: EdgeInsets.all(ScreenAdapter.width(30)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(ScreenAdapter.width(20)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: qrCodeUrl != null && qrCodeUrl.isNotEmpty
                            ? Image.network(
                                ApiClient.getFullImageUrl(qrCodeUrl),
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildDefaultQRCode();
                                },
                              )
                            : _buildDefaultQRCode(),
                      ),
                      SizedBox(height: ScreenAdapter.height(40)),

                      // 关闭按钮
                      GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          width: double.infinity,
                          height: ScreenAdapter.height(110),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Color(0xFF3D7CFF),
                            borderRadius:
                                BorderRadius.circular(ScreenAdapter.width(55)),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF3D7CFF).withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Text(
                            '关闭',
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
                    },
                    child: Container(
                      padding: EdgeInsets.all(ScreenAdapter.width(10)),
                      child: Icon(
                        Icons.close,
                        color: Color(0xFF999999),
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
      barrierDismissible: true,
    );
  }

  static Widget _buildDefaultQRCode() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[100],
      child: Icon(
        Icons.qr_code,
        size: ScreenAdapter.fontSize(100),
        color: Color(0xFFCCCCCC),
      ),
    );
  }
}
