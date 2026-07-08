import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../components/filter_dropdown_button.dart';
import '../../../../components/common_empty_state.dart';
import '../../../../components/common_error_state.dart';
import '../controllers/questions_wrong_controller.dart';

/// 错题本页 - 风格与收藏页面完全一致（筛选栏 + 分组列表）
class QuestionsWrongView extends GetView<QuestionsWrongController> {
  const QuestionsWrongView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              _buildFilterBar(context),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建顶部导航栏：返回 | 错题 | 错题数量
  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 36.w),
      height: 112.h,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      child: Row(
        children: [
          // 左侧返回按钮
          GestureDetector(
            onTap: () => Get.back(),
            child: Icon(
              Icons.arrow_back_ios,
              size: 44.sp,
              color: Color(0xFF333333),
            ),
          ),

          // 中间标题（居中）
          Expanded(
            child: Center(
              child: Text(
                '错题',
                style: TextStyle(
                  fontSize: 48.sp,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ),

          // 右侧：错题数量
          Obx(() => Text(
                '${controller.totalCount.value}题',
                style: TextStyle(
                  fontSize: 32.sp,
                  color: Color(0xFF999999),
                ),
              )),
        ],
      ),
    );
  }

  /// 构建筛选栏：录入时 + 排序按钮（与收藏页布局完全一致）
  Widget _buildFilterBar(BuildContext context) {
    return Container(
      height: 140.h,
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左侧按钮：录入时
          Obx(() => FilterDropdownButton(
                label: controller.currentSortTime.value,
                onTap: () => controller.showTimeFilterPicker(context),
              )),

          // 右侧按钮：排序方式
          Obx(() => FilterDropdownButton(
                label: controller.currentSortOrder.value,
                onTap: () => controller.showOrderPicker(context),
              )),
        ],
      ),
    );
  }

  /// 构建主体内容区域（与收藏页逻辑完全一致）
  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1890FF)),
          ),
        );
      }

      if (controller.errorMessage.value.isNotEmpty &&
          controller.wrongGroups.isEmpty) {
        return _buildErrorState();
      }

      if (controller.wrongGroups.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: () => controller.onRefresh(),
        color: Color(0xFF1890FF),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: controller.wrongGroups.length,
          separatorBuilder: (_, __) =>
              Divider(height: 1, color: Color(0xFFF5F5F5)),
          itemBuilder: (context, index) {
            final group = controller.wrongGroups[index];
            return _buildListItem(group);
          },
        ),
      );
    });
  }

  /// 构建列表项：（与收藏页结构一致，图标改为红色错误标识）
  Widget _buildListItem(WrongGroup group) {
    return GestureDetector(
      onTap: () => controller.onTapGroup(group),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 140.h,
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Row(
          children: [
            // 左侧红色错误图标（圆形）（区别于收藏页的蓝色勾）
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFF4D4F),
              ),
              child: Icon(
                Icons.close_rounded,
                size: 28.sp,
                color: Colors.white,
              ),
            ),

            SizedBox(width: 24.w),

            // 中间分类名称（来自question.cate_name）
            Expanded(
              child: Text(
                group.cateName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 40.sp,
                  color: Color(0xFF333333),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // 右侧数量和箭头
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${group.count}题',
                  style: TextStyle(
                    fontSize: 30.sp,
                    color: Color(0xFF999999),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 38.sp,
                  color: Color(0xFFCCCCCC),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建空状态视图
  Widget _buildEmptyState() {
    return const CommonEmptyState(
      icon: Icons.error_outline_outlined,
      title: '暂无错题',
      subtitle: '去做题吧，做错的题目会记录在这里',
    );
  }

  /// 构建错误状态视图
  Widget _buildErrorState() {
    return CommonErrorState(
      message: controller.errorMessage.value,
      onRetry: () => controller.onRefresh(),
    );
  }
}
