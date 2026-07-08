import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/login_controller.dart';

class VerificationView extends GetView<LoginController> {
  const VerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final focusNode = FocusNode();

    // 确保在widget构建完成后请求焦点
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            colors: [
              Color(0xFFEAF2FF),
              Color(0xFFF5F9FF),
              Color(0xFFFFF9F0),
              Color(0xFFFFF3E6),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 60.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部返回区域
                Container(
                  padding: EdgeInsets.all(24.w),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios,
                        color: Color(0xFF333333), size: 40.sp),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ),

                // 页面主标题区域
                SizedBox(height: 120.h),
                Text(
                  '输入验证码',
                  style: TextStyle(
                    fontSize: 64.sp,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F1F1F),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  '短信已发送至 已填写手机号',
                  style: TextStyle(
                    fontSize: 32.sp,
                    color: Color(0xFF8A8F99),
                  ),
                ),

                // 验证码输入区域
                SizedBox(height: 120.h),
                Container(
                  child: Column(
                    children: [
                      // 验证码输入框
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 40.h),
                        child: Column(
                          children: [
                            // 验证码输入组
                            Obx(() {
                              int codeLength =
                                  controller.verificationCode.value.length;
                              const int totalDigits = 4;
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  // 显示的验证码数字
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children:
                                        List.generate(totalDigits, (index) {
                                      String digit = '';
                                      if (index < codeLength) {
                                        digit = controller
                                            .verificationCode.value[index];
                                      }
                                      return Container(
                                        width: 96.w,
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 24.w),
                                        child: Text(
                                          digit,
                                          style: TextStyle(
                                            fontSize: 60.sp,
                                            color: Color(0xFF1F1F1F),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                  // 隐藏的TextField，用于获取输入的验证码
                                  Container(
                                    width: 96.w * totalDigits +
                                        24.w * (totalDigits * 2 - 2),
                                    height: 100.h,
                                    child: TextField(
                                      focusNode: focusNode,
                                      controller:
                                          controller.codeController.value,
                                      keyboardType: TextInputType.number,
                                      maxLength: totalDigits,
                                      textAlign: TextAlign.center,
                                      cursorColor: Colors.transparent,
                                      cursorWidth: 0,
                                      cursorHeight: 0,
                                      decoration: const InputDecoration(
                                        counterText: '',
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                      ),
                                      style: TextStyle(
                                        fontSize: 60.sp,
                                        color: Colors.transparent,
                                        height: 1.2,
                                      ),
                                      onChanged: (value) {
                                        controller.verificationCode.value =
                                            value;
                                        // 输入4位验证码时延迟执行登录，避免卡顿
                                        if (value.length == totalDigits) {
                                          Future.delayed(
                                              const Duration(milliseconds: 100),
                                              () {
                                            controller.login();
                                          });
                                        }
                                      },
                                      autofocus: true,
                                      showCursor: false,
                                    ),
                                  ),
                                  // 底部横线模拟验证码输入框
                                  Positioned(
                                    bottom: 0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children:
                                          List.generate(totalDigits, (index) {
                                        bool isActive = codeLength > index;
                                        return Container(
                                          width: 96.w,
                                          height: 2.h,
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 24.w),
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? const Color(0xFF3D7CFF)
                                                : const Color(0xFFE6EAF0),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 倒计时提示区
                SizedBox(height: 32.h),
                Center(
                  child: Obx(() {
                    if (controller.countdownSeconds.value > 0) {
                      return Text(
                        '${controller.countdownSeconds.value}s 后可重新获取',
                        style: TextStyle(
                          fontSize: 32.sp,
                          color: Color(0xFF8A8F99),
                        ),
                      );
                    } else {
                      return GestureDetector(
                        onTap: () {
                          controller.sendVerificationCode();
                        },
                        child: Text(
                          '重新获取验证码',
                          style: TextStyle(
                            fontSize: 32.sp,
                            color: Color(0xFF3D7CFF),
                          ),
                        ),
                      );
                    }
                  }),
                ),

                SizedBox(height: 160.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
