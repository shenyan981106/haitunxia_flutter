import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../components/filter_dropdown_button.dart';
import '../../../../components/common_empty_state.dart';
import '../../../../components/common_error_state.dart';
import '../controllers/questions_favorite_controller.dart';

/// 题目收藏页面 - 设计稿尺寸：1080x2400
class QuestionsFavoriteView extends GetView<QuestionsFavoriteController> {
  const QuestionsFavoriteView({super.key});

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

  /// 构建顶部导航栏：返回 | 收藏题目 | 导出
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
                '收藏题目',
                style: TextStyle(
                  fontSize: 48.sp,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ),

          // 右侧占位，保持标题居中
          SizedBox(width: 44.w),
        ],
      ),
    );
  }

  /// 构建筛选栏：两个独立圆角按钮（左右分布）
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
          // 左侧按钮：录入时间
          Obx(() => FilterDropdownButton(
                label: controller.currentSortTime.value,
                onTap: () => controller.showTimeFilterPicker(context),
              )),

          // 右侧按钮：新添加在前
          Obx(() => FilterDropdownButton(
                label: controller.currentSortOrder.value,
                onTap: () => controller.showOrderPicker(context),
              )),
        ],
      ),
    );
  }

  /// 构建主体内容区域
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
          controller.favoriteGroups.isEmpty) {
        return _buildErrorState();
      }

      if (controller.favoriteGroups.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: () => controller.onRefresh(),
        color: Color(0xFF1890FF),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: controller.favoriteGroups.length,
          separatorBuilder: (_, __) =>
              Divider(height: 1, color: Color(0xFFF5F5F5)),
          itemBuilder: (context, index) {
            final group = controller.favoriteGroups[index];
            return _buildListItem(group);
          },
        ),
      );
    });
  }

  /// 构建列表项
  Widget _buildListItem(FavoriteGroup group) {
    return GestureDetector(
      onTap: () => controller.onTapGroup(group),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 140.h,
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Row(
          children: [
            // 左侧蓝色勾选图标（圆形）
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1890FF),
              ),
              child: Icon(
                Icons.check_rounded,
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

  /// 构建空状态视
  Widget _buildEmptyState() {
    return const CommonEmptyState(
      icon: Icons.bookmark_border_outlined,
      title: '暂无收藏题目',
      subtitle: '去练习页面收藏你感兴趣的题目',
    );
  }

  /// 构建错误状态视
  Widget _buildErrorState() {
    return CommonErrorState(
      message: controller.errorMessage.value,
      onRetry: () => controller.onRefresh(),
    );
  }
}
