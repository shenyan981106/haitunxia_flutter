import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/my_bank_controller.dart';

class MyBankView extends GetView<MyBankController> {
  const MyBankView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 50.h),
                    _buildHeader(),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: const Color(0xFFF3F4F9),
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 110.h,
      child: Stack(
        children: [
          Center(
            child: Text(
              '我的题库',
              style: TextStyle(
                fontSize: 50.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF333333),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Icon(
                Icons.arrow_back_ios,
                size: 44.sp,
                color: const Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final bottomInset = MediaQuery.of(Get.context!).padding.bottom;
    final bottomSafeSpace = bottomInset + 240.h;

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 120.sp,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 24.h),
              Text(
                controller.errorMessage.value,
                style: TextStyle(
                  fontSize: 36.sp,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () => controller.loadExamPapers(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D7CFF),
                  foregroundColor: Colors.white,
                ),
                child: const Text('重新加载'),
              ),
            ],
          ),
        );
      }

      if (controller.examPapers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.description_outlined,
                size: 120.sp,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 24.h),
              Text(
                '暂无试卷',
                style: TextStyle(
                  fontSize: 36.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: 24.h, bottom: bottomSafeSpace),
        itemCount: controller.examPapers.length,
        itemBuilder: (context, index) {
          final paper = controller.examPapers[index];
          return _buildPaperItem(paper);
        },
      );
    });
  }

  Widget _buildPaperItem(Map<String, dynamic> paper) {
    final title = paper['title']?.toString() ?? '';
    final joinCount = paper['join_count']?.toString() ?? '0';
    final quantity = paper['quantity']?.toString() ?? '0';
    final totalScore = paper['total_score']?.toString() ?? '0';

    return Container(
      margin: EdgeInsets.only(left: 30.w, right: 30.w, bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.onPaperTap(paper),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 50.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF333333),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Text(
                      '$joinCount 人做',
                      style: TextStyle(
                        fontSize: 28.sp,
                        color: const Color(0xFF999999),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$quantity/$quantity 人 $totalScore 分',
                      style: TextStyle(
                        fontSize: 28.sp,
                        color: const Color(0xFF999999),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Icon(
                      Icons.chevron_right,
                      size: 32.sp,
                      color: const Color(0xFFCCCCCC),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
