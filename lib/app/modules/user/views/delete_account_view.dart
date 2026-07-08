import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import '../../../services/screenAdapter.dart';
import '../controllers/delete_account_controller.dart';

class DeleteAccountView extends GetView<DeleteAccountController> {
  const DeleteAccountView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF333333),
        centerTitle: true,
        title: Text(
          '注销账号',
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(46),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF333333),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: ScreenAdapter.fontSize(46),
            color: const Color(0xFF333333),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenAdapter.width(50)),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: ScreenAdapter.height(60)),
                      // 警告图标
                      Container(
                        width: ScreenAdapter.width(260),
                        height: ScreenAdapter.width(260),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE8E8),
                          borderRadius:
                              BorderRadius.circular(ScreenAdapter.width(40)),
                        ),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          size: ScreenAdapter.fontSize(80),
                          color: const Color(0xFFFF6B6B),
                        ),
                      ),
                      SizedBox(height: ScreenAdapter.height(40)),
                      // 标题
                      Text(
                        '注销账号不可逆，且将放弃以下权益和资源',
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(42),
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF333333),
                        ),
                      ),
                      SizedBox(height: ScreenAdapter.height(40)),
                      // 权益列表
                      Obx(() => Container(
                            padding: EdgeInsets.all(ScreenAdapter.width(32)),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F8FA),
                              borderRadius: BorderRadius.circular(
                                  ScreenAdapter.width(24)),
                            ),
                            child: controller.isLoading.value
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : HtmlWidget(
                                    controller.agreementContent.value,
                                    textStyle: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(34),
                                      color: const Color(0xFF666666),
                                      height: 1.6,
                                    ),
                                  ),
                          )),
                      SizedBox(height: ScreenAdapter.height(40)),
                      // 底部提示（带复选框）
                      Obx(() => GestureDetector(
                            onTap: controller.toggleAgreed,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: ScreenAdapter.width(44),
                                  height: ScreenAdapter.width(44),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: controller.isAgreed.value
                                          ? const Color(0xFF7B9CFF)
                                          : const Color(0xFFCCCCCC),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        ScreenAdapter.width(22)),
                                    color: controller.isAgreed.value
                                        ? const Color(0xFF7B9CFF)
                                        : Colors.transparent,
                                  ),
                                  child: controller.isAgreed.value
                                      ? Icon(
                                          Icons.check,
                                          size: ScreenAdapter.fontSize(28),
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                SizedBox(width: ScreenAdapter.width(16)),
                                Text(
                                  '申请注销表示你自愿放弃账号内全部数据、资产和权益',
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(32),
                                    color: const Color(0xFF999999),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      SizedBox(height: ScreenAdapter.height(60)),
                    ],
                  ),
                ),
              ),
              // 确认按钮
              Obx(() => Padding(
                    padding: EdgeInsets.only(bottom: ScreenAdapter.height(40)),
                    child: SizedBox(
                      width: double.infinity,
                      height: ScreenAdapter.height(140),
                      child: ElevatedButton(
                        onPressed: controller.isAgreed.value
                            ? _showConfirmDialog
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7B9CFF),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFB8C8F5),
                          disabledForegroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(ScreenAdapter.width(60)),
                          ),
                        ),
                        child: Text(
                          '确认申请注销',
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(44),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmDialog() {
    SmartDialog.show(
      builder: (context) {
        return Container(
          width: ScreenAdapter.width(800),
          padding: EdgeInsets.all(ScreenAdapter.width(40)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(ScreenAdapter.width(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '确认注销',
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(48),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF333333),
                ),
              ),
              SizedBox(height: ScreenAdapter.height(30)),
              Text(
                '注销后账号将无法恢复，是否确认注销？',
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(36),
                  color: const Color(0xFF666666),
                ),
              ),
              SizedBox(height: ScreenAdapter.height(50)),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => SmartDialog.dismiss(),
                      child: Container(
                        height: ScreenAdapter.height(100),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius:
                              BorderRadius.circular(ScreenAdapter.width(50)),
                        ),
                        child: Text(
                          '取消',
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(40),
                            color: const Color(0xFF999999),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ScreenAdapter.width(30)),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        SmartDialog.dismiss();
                        await controller.submitLogoutRequest();
                      },
                      child: Container(
                        height: ScreenAdapter.height(100),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B),
                          borderRadius:
                              BorderRadius.circular(ScreenAdapter.width(50)),
                        ),
                        child: Text(
                          '确认',
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(40),
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
