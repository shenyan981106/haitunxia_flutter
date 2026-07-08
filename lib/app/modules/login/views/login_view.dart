import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../data/providers/api_client.dart';
import '../controllers/login_controller.dart';
import 'agreement_view.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF3F3),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 80.w),
                    child: Column(
                      children: [
                        SizedBox(height: 220.h),
                        Text(
                          '海豚侠',
                          style: TextStyle(
                            fontSize: 68.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        SizedBox(height: 40.h),
                        Container(
                          width: 200.w,
                          height: 200.w,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(100.w),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(
                            ApiClient.getFullImageUrl(
                              'uploads/20260221/25421395d1396d43f6f5954af5e540c5.png',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 120.h),
                        Center(
                          child: SizedBox(
                            width: 800.w,
                            height: 156.h,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 40.w),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F3F5),
                                borderRadius: BorderRadius.circular(78.h),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '+86',
                                    style: TextStyle(
                                      fontSize: 44.sp,
                                      color: const Color(0xFF333333),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    size: 44.sp,
                                    color: const Color(0xFFB0B5BD),
                                  ),
                                  Container(
                                    width: 1.w,
                                    height: 48.h,
                                    color: const Color(0xFFE0E0E5),
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 24.w),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller:
                                          controller.phoneController.value,
                                      keyboardType: TextInputType.phone,
                                      maxLength: 11,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      decoration: InputDecoration(
                                        counterText: '',
                                        hintText: '输入手机号',
                                        hintStyle: TextStyle(
                                          fontSize: 44.sp,
                                          color: const Color.fromARGB(
                                            255,
                                            165,
                                            180,
                                            202,
                                          ),
                                        ),
                                        border: InputBorder.none,
                                        isCollapsed: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      style: TextStyle(
                                        fontSize: 44.sp,
                                        color: const Color(0xFF333333),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 80.h),
                        Obx(() {
                          bool isPhoneValid =
                              controller.phoneController.value.text.length ==
                                  11;
                          return SizedBox(
                            height: 130.h,
                            child: Center(
                              child: SizedBox(
                                width: 800.w,
                                height: 130.h,
                                child: ElevatedButton(
                                  onPressed: () {
                                    controller.sendVerificationCode();
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.resolveWith<Color>(
                                      (states) => const Color(0xFF0164E5),
                                    ),
                                    foregroundColor:
                                        WidgetStateProperty.all<Color>(
                                      Colors.white,
                                    ),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(65.h),
                                      ),
                                    ),
                                    textStyle:
                                        MaterialStateProperty.all<TextStyle>(
                                      TextStyle(
                                        fontSize: 52.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    elevation:
                                        MaterialStateProperty.all<double>(0),
                                    overlayColor: MaterialStateProperty
                                        .resolveWith<Color?>(
                                      (states) {
                                        if (!isPhoneValid) {
                                          return const Color(0xFF0164E5)
                                              .withOpacity(0.7);
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  child: Text('验证码登录'),
                                ),
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: 40.h),
                        Center(
                          child: SizedBox(
                            width: 800.w,
                            child: Row(
                              children: [
                                Obx(() {
                                  return Transform.scale(
                                    scale: 0.9,
                                    child: Checkbox(
                                      value: controller.isAgreed.value,
                                      onChanged: (value) {
                                        controller.isAgreed.value =
                                            value ?? false;
                                      },
                                      activeColor: const Color(0xFF0164E5),
                                      shape: const CircleBorder(),
                                      side: BorderSide(
                                        width: 2.w,
                                        color: const Color(0xFFD0D0D5),
                                      ),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: const VisualDensity(
                                        horizontal: -4,
                                        vertical: -4,
                                      ),
                                    ),
                                  );
                                }),
                                Expanded(
                                  child: RichText(
                                    textAlign: TextAlign.left,
                                    text: TextSpan(
                                      text: '我已阅读并同意',
                                      style: TextStyle(
                                        color: const Color(0xFF999999),
                                        fontSize: 34.sp,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '《用户协议》',
                                          style: TextStyle(
                                            color: const Color(0xFF507DAF),
                                            fontSize: 34.sp,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Get.to(() => const AgreementView(
                                                    initialIndex: 0,
                                                  ));
                                            },
                                        ),
                                        TextSpan(
                                          text: '和',
                                          style: TextStyle(
                                            color: const Color(0xFF999999),
                                            fontSize: 34.sp,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '《隐私政策》',
                                          style: TextStyle(
                                            color: const Color(0xFF507DAF),
                                            fontSize: 34.sp,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Get.to(() => const AgreementView(
                                                    initialIndex: 1,
                                                  ));
                                            },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 80.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
