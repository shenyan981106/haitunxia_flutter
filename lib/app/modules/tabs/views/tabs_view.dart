import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tabs_controller.dart';
import '../../../services/screenAdapter.dart';
import '../../../services/htxFonts.dart';

class TabsView extends GetView<TabsController> {
  const TabsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        // 页面主体部分，显示内容区
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: controller.pages,
        ),
        // 为嵌套导航器设置 key，用于管理嵌套路由
        key: Get.nestedKey(1),
        // 底部导航栏固定在底部
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: const Color(0xFFEEEEEE),
                width: ScreenAdapter.width(1).toDouble(),
              ),
            ),
          ),
          child: SafeArea(
            top: false, // 不处理顶部安全区
            child: Container(
              height: ScreenAdapter.height(150).toDouble(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 第一个导航项：首页
                  _buildNavItem(
                    index: 0,
                    currentIndex: controller.currentIndex.value,
                    icon: htxFonts.tabHome,
                    selectedIcon: htxFonts.tabHomeSelected,
                    label: "首页",
                  ),

                  // 第二个导航项：学习
                  _buildNavItem(
                    index: 1,
                    currentIndex: controller.currentIndex.value,
                    icon: htxFonts.tabStudy,
                    selectedIcon: htxFonts.tabStudySelected,
                    label: "学习",
                  ),

                  // 第三个导航项：题库
                  _buildNavItem(
                    index: 2,
                    currentIndex: controller.currentIndex.value,
                    icon: htxFonts.tabQuestions,
                    selectedIcon: htxFonts.tabQuestionsSelected,
                    label: "题库",
                  ),

                  // 第四个导航项：我的
                  _buildNavItem(
                    index: 3,
                    currentIndex: controller.currentIndex.value,
                    icon: htxFonts.tabMe,
                    selectedIcon: htxFonts.tabMeSelected,
                    label: "我的",
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // 自定义方法：构建单个导航项
  Widget _buildNavItem({
    required int index,
    required int currentIndex,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    bool isSelected = currentIndex == index;
    // 选中颜色改为类似个人所得税APP的蓝色
    const Color selectedColor = Color(0xFF1890FF);
    const Color unselectedColor = Color(0xFF999999);
    final double iconSize =
        ScreenAdapter.fontSize(isSelected ? 78 : 74).toDouble();

    return GestureDetector(
      onTap: () {
        controller.setCurrentIndex(index);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: ScreenAdapter.width(180),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              size: iconSize,
              color: isSelected ? selectedColor : unselectedColor,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(32).toDouble(),
                color: isSelected ? selectedColor : unselectedColor,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
