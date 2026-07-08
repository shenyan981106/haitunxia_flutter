import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../components/common_empty_state.dart';
import '../controllers/questions_elist_controller.dart';

class QuestionsElistView extends GetView<QuestionsElistController> {
  const QuestionsElistView({Key? key}) : super(key: key);

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
                    SizedBox(height: 50.h),
                    _buildTabs(),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: const Color(0xFFF3F4F9),
                  child: Obx(() {
                    final count = controller.tabTitles.length;
                    if (count == 0) return const SizedBox.shrink();
                    return PageView.builder(
                      controller: controller.pageController,
                      onPageChanged: controller.onPageChanged,
                      itemCount: count,
                      itemBuilder: (context, index) {
                        return _buildContent();
                      },
                    );
                  }),
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
            child: Obx(() => Text(
                  controller.pageTitle.value,
                  style: TextStyle(
                    fontSize: 50.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF333333),
                  ),
                )),
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

  Widget _buildTabs() {
    return SizedBox(
      height: 110.h,
      child: Obx(() {
        final titles = controller.tabTitles;
        if (titles.isEmpty) return const SizedBox.shrink();
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: titles.length,
          separatorBuilder: (c, i) => SizedBox(width: 40.w),
          itemBuilder: (context, index) {
            return Obx(() {
              final isSelected = controller.selectedSubIndex.value == index;
              return GestureDetector(
                key: ValueKey('questions_elist_tab_$index'),
                behavior: HitTestBehavior.opaque,
                onTap: () => controller.changeSubTab(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      titles[index],
                      style: TextStyle(
                        fontSize: isSelected ? 46.sp : 44.sp,
                        color: isSelected
                            ? const Color(0xFF3D7CFF)
                            : const Color(0xFF999999),
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Container(
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF3D7CFF)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6.h),
                      ),
                      child: Text(
                        titles[index],
                        style: TextStyle(
                          fontSize: isSelected ? 46.sp : 44.sp,
                          color: Colors.transparent,
                          fontWeight:
                              isSelected ? FontWeight.w500 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            });
          },
        );
      }),
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

      if (controller.examPapers.isEmpty) {
        return CommonEmptyState(
          icon: Icons.description_outlined,
          iconColor: Colors.grey.shade400,
          title: '暂无试卷',
          titleFontSize: 36.sp,
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
    final subjectName = paper['subject']?['name']?.toString() ?? '';
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
                      '$joinCount 人做过',
                      style: TextStyle(
                        fontSize: 28.sp,
                        color: const Color(0xFF999999),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$quantity题/$totalScore分',
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
