import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xmshop/app/services/global_project_controller.dart';
import 'package:xmshop/app/services/screenAdapter.dart';
import '../../../data/models/project_model.dart';
import '../../../data/models/category_model.dart';
import '../controllers/project_controller.dart';

class ProjectView extends StatefulWidget {
  ProjectView({super.key});

  @override
  State<ProjectView> createState() => _ProjectViewState();
}

class _ProjectViewState extends State<ProjectView> {
  // 控制器实例
  final ProjectController _controller = Get.put(ProjectController());

  // 项目数据（保留但不再使用，用于兼容）
  final List<Project> projects = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // 右上角装饰圆
            Positioned(
              top: -ScreenAdapter.height(50),
              right: -ScreenAdapter.width(50),
              child: Container(
                width: ScreenAdapter.width(200),
                height: ScreenAdapter.width(200),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE0B2).withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: ScreenAdapter.height(80),
              right: ScreenAdapter.width(40),
              child: Container(
                width: ScreenAdapter.width(30),
                height: ScreenAdapter.width(30),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE0B2).withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 自定义头部
                _buildHeader(),

                Expanded(
                  child: Obx(() {
                    return _controller.isLoading.value
                        ? // 加载状态
                        Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: const Color(0xFFFF6E40),
                                ),
                                SizedBox(height: ScreenAdapter.height(20)),
                                Text(
                                  '加载中...',
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(28),
                                    color: const Color(0xFF999999),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _controller.errorMessage.value.isNotEmpty
                            ? // 错误状态
                            Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: ScreenAdapter.fontSize(64),
                                      color: const Color(0xFFFF6E40),
                                    ),
                                    SizedBox(height: ScreenAdapter.height(20)),
                                    Text(
                                      _controller.errorMessage.value,
                                      style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(28),
                                        color: const Color(0xFF999999),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: ScreenAdapter.height(30)),
                                    ElevatedButton(
                                      onPressed: () =>
                                          _controller.fetchCategories(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFFF6E40),
                                        foregroundColor: Colors.white,
                                        shape: StadiumBorder(),
                                      ),
                                      child: const Text('重新加载'),
                                    ),
                                  ],
                                ),
                              )
                            : // 数据显示
                            SingleChildScrollView(
                                padding: EdgeInsets.only(
                                  left: ScreenAdapter.width(40),
                                  right: ScreenAdapter.width(40),
                                  bottom: ScreenAdapter.height(50),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 动态构建分类和项目列表
                                    ..._controller.categories.map((category) {
                                      // 提取子分类项目
                                      List<Map<String, dynamic>> items = [];
                                      if (category.children.isNotEmpty) {
                                        items = category.children
                                            .map((child) => {
                                                  'name': child.name,
                                                  'id': child.id.toString(),
                                                })
                                            .toList();
                                      }

                                      return Column(
                                        children: [
                                          _buildCategorySection(
                                            category.name,
                                            items,
                                          ),
                                          SizedBox(
                                              height: ScreenAdapter.height(30)),
                                        ],
                                      );
                                    }).toList(),
                                  ],
                                ),
                              );
                  }),
                ),
              ],
            ),

            // 底部装饰波浪（简单的占位，实际需要图片或CustomPainter）
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  height: ScreenAdapter.height(60),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white.withOpacity(0), Colors.white],
                  )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 自定义头部区域
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        left: ScreenAdapter.width(40),
        right: ScreenAdapter.width(40),
        top: ScreenAdapter.height(100),
        bottom: ScreenAdapter.height(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 关闭按钮
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: EdgeInsets.all(ScreenAdapter.width(10)),
              alignment: Alignment.centerLeft,
              child: Icon(
                Icons.close,
                size: ScreenAdapter.fontSize(60),
                color: const Color(0xFF333333),
              ),
            ),
          ),
          SizedBox(height: ScreenAdapter.height(100)),
          // 大标题
          Text(
            '职业考试',
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(46),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF333333),
            ),
          ),
          SizedBox(height: ScreenAdapter.height(10)),
          // 副标题
          Text(
            '方便我们为您推荐最佳的内容',
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(32),
              color: const Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }

  // 构建考试类别区块
  Widget _buildCategorySection(
      String categoryTitle, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 类别标题
        Padding(
          padding: EdgeInsets.only(
              bottom: ScreenAdapter.height(20),
              left: ScreenAdapter.width(10),
              top: ScreenAdapter.height(60)),
          child: Text(
            categoryTitle,
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(46),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF666666),
            ),
          ),
        ),

        // 项目网格
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: ScreenAdapter.width(24),
            mainAxisSpacing: ScreenAdapter.height(60),
            childAspectRatio: 2.4, // 调整宽高比以适应胶囊形状
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _buildGradientProjectCard(
                categoryTitle,
                items[index]['name'] as String,
                index,
                items[index]['id'] as String);
          },
        ),
      ],
    );
  }

  // 构建胶囊形项目卡片
  Widget _buildGradientProjectCard(
      String categoryTitle, String itemName, int index, String id) {
    final project = Project(
      id: id,
      name: itemName,
      code: '',
      description: '',
      icon: '',
    );

    return Obx(() {
      final currentProject = GlobalProjectController.to.currentProject.value;
      final isSelected = currentProject?.id == project.id;

      return GestureDetector(
        onTap: () {
          GlobalProjectController.to.selectProject(project);

          Future.delayed(const Duration(milliseconds: 150), () {
            Get.back();
          });
        },
        child: Container(
          decoration: BoxDecoration(
            // 选中：蓝色渐变，未选中：浅灰背景
            color: isSelected ? null : const Color(0xFFF5F6F7),
            gradient: isSelected ? _buildBlueGradient() : null,
            borderRadius:
                BorderRadius.circular(ScreenAdapter.width(50)), // 完全圆角
          ),
          child: Center(
            child: Text(
              project.name,
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(34),
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                color: isSelected ? Colors.white : const Color(0xFF666666),
              ),
            ),
          ),
        ),
      );
    });
  }

  // 构建蓝色渐变
  LinearGradient _buildBlueGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF42A5F5), // 浅蓝色（Blue 400）
        Color(0xFF1565C0), // 深蓝色（Blue 800）
      ],
      stops: [0.0, 1.0],
    );
  }

  // 可选：构建更漂亮的渐变
}
