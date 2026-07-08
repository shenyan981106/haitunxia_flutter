import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/keepAliveWrapper.dart';
import '../controllers/study_controller.dart';
import '../../../services/screenAdapter.dart';
import '../../../data/providers/api_client.dart';

class CourseItemWidget extends StatelessWidget {
  final Map<String, dynamic> course;
  final VoidCallback onTap;

  const CourseItemWidget({Key? key, required this.course, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 字段映射适配 API 返回结构
    final String title = course['title']?.toString() ?? '';
    final String description = course['description']?.toString() ?? '';
    final String teacherTags = course['teacher_tags']?.toString() ?? '';
    final String subtitle = description.isNotEmpty
        ? description
        : teacherTags.replaceAll(',', ' · ');

    final bool isFree = course['is_free']?.toString() == '1';
    final String price = isFree ? '免费' : '¥${course['price']}';
    final String originalPrice =
        course['original_price'] != null ? '¥${course['original_price']}' : '';

    // 报名人数
    int students =
        int.tryParse(course['total_students']?.toString() ?? '0') ?? 0;
    final String enrollment = students > 0 ? '$students已报名' : '';

    // 难度星级
    int difficulty = int.tryParse(course['difficulty']?.toString() ?? '0') ?? 0;

    // 总课时
    int totalLessons =
        int.tryParse(course['total_lessons']?.toString() ?? '0') ?? 0;

    final String coverImage = course['cover_image_url']?.toString() ??
        course['cover_image']?.toString() ??
        '';

    // 标签处理
    List tags = [];
    if (teacherTags.isNotEmpty) {
      tags = teacherTags.split(',');
    }

    bool hasVipTag = course['is_recommend'] == 1;
    bool hasTrial = course['is_trial'] == 1;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: ScreenAdapter.height(24)),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(ScreenAdapter.width(30)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(ScreenAdapter.width(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 标题和会员Tag
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(44),
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF333333),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ScreenAdapter.height(20)),

                  // 2. 老师列表
                  if ((course['teacher_list'] as List?)?.isNotEmpty == true)
                    Padding(
                      padding:
                          EdgeInsets.only(bottom: ScreenAdapter.height(16)),
                      child: Row(
                        children: (course['teacher_list'] as List)
                            .map<Widget>((teacher) {
                          final t = teacher as Map<String, dynamic>;
                          return Padding(
                            padding:
                                EdgeInsets.only(right: ScreenAdapter.width(32)),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Color(0xFFE8E8E8), width: 1.5),
                                  ),
                                  child: CircleAvatar(
                                    radius: ScreenAdapter.width(40),
                                    backgroundImage: NetworkImage(
                                        ApiClient.replaceUri(
                                            t['avatar']?.toString() ?? '')),
                                    onBackgroundImageError: (e, s) {},
                                    backgroundColor: Color(0xFFF0F0F0),
                                  ),
                                ),
                                SizedBox(height: ScreenAdapter.height(8)),
                                Text(
                                  t['name']?.toString() ?? '',
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(26),
                                    color: Color(0xFF666666),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  // 3. 标签列表
                  if (tags.isNotEmpty)
                    Padding(
                      padding:
                          EdgeInsets.only(bottom: ScreenAdapter.height(20)),
                      child: Wrap(
                        spacing: ScreenAdapter.width(16),
                        runSpacing: ScreenAdapter.height(10),
                        children: tags.take(3).map((tag) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ScreenAdapter.width(12),
                              vertical: ScreenAdapter.height(6),
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFF0F7FF),
                              borderRadius:
                                  BorderRadius.circular(ScreenAdapter.width(8)),
                            ),
                            child: Text(
                              tag.toString(),
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(26),
                                color: Color(0xFF3D7CFF),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  SizedBox(height: ScreenAdapter.height(20)),
                  Divider(height: 1, color: Color(0xFFF5F5F5)),
                  SizedBox(height: ScreenAdapter.height(20)),

                  // 4. 底部 课时和价格
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$totalLessons课时',
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(30),
                          color: Color(0xFF999999),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '¥',
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(32),
                              color: Color(0xFFFF4D4F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            isFree ? '0' : course['price']?.toString() ?? '0',
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(52),
                              color: Color(0xFFFF4D4F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isFree)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenAdapter.width(22),
                    vertical: ScreenAdapter.height(12),
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF4E5),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(ScreenAdapter.width(30)),
                      bottomLeft: Radius.circular(ScreenAdapter.width(30)),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: Color(0xFFFF9900),
                        size: ScreenAdapter.fontSize(30),
                      ),
                      SizedBox(width: ScreenAdapter.width(8)),
                      Text(
                        '会员免费',
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(30),
                          color: Color(0xFFFF9900),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class StudyView extends GetView<StudyController> {
  const StudyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return KeepAliveWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          title: Text(
            '全部课程',
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(44),
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0, // 防止滚动时颜色变化
          surfaceTintColor: Colors.transparent, // 防止 Material 3 风格下的表面着色
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,
                color: Colors.black, size: ScreenAdapter.fontSize(44)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Column(
          children: [
            // 筛选栏
            _buildFilterBar(),

            // 课程列表
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.courseList.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }

                if (controller.courseList.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => controller.getCourseList(),
                    child: ListView(
                      physics: AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.55,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.library_books_outlined,
                                  size: 64, color: Colors.grey[300]),
                              SizedBox(height: 16),
                              Text(
                                '暂无课程数据',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: ScreenAdapter.fontSize(32),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.getCourseList(),
                  child: ListView.builder(
                    controller: controller.scrollController,
                    physics:
                        AlwaysScrollableScrollPhysics(), // 确保即使内容不足也能触发下拉刷新
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenAdapter.width(46),
                      vertical: ScreenAdapter.height(32),
                    ),
                    itemCount: controller.courseList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == controller.courseList.length) {
                        return _buildLoadMoreFooter();
                      }

                      return CourseItemWidget(
                        course: controller.courseList[index],
                        onTap: () => controller
                            .goToCourseDetail(controller.courseList[index]),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreFooter() {
    return Obx(() {
      if (controller.isLoadingMore.value) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: ScreenAdapter.height(24)),
          child: Center(
            child: SizedBox(
              width: ScreenAdapter.width(36),
              height: ScreenAdapter.width(36),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }

      if (!controller.hasMore.value) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: ScreenAdapter.height(24)),
          child: Center(
            child: Text(
              '没有更多了',
              style: TextStyle(
                color: Colors.grey,
                fontSize: ScreenAdapter.fontSize(28),
              ),
            ),
          ),
        );
      }

      return SizedBox(height: ScreenAdapter.height(12));
    });
  }

  // 筛选栏
  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        vertical: ScreenAdapter.height(24),
        horizontal: ScreenAdapter.width(46),
      ),
      child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(controller.filterList.length, (index) {
              bool isSelected = index == controller.currentFilterIndex.value;
              return InkWell(
                // 改用 InkWell 以获得更好的点击反馈
                onTap: () {
                  debugPrint("🖱点击筛选按钮 $index");
                  controller.changeFilterIndex(index);
                },
                borderRadius: BorderRadius.circular(ScreenAdapter.width(40)),
                child: Container(
                  margin: EdgeInsets.only(right: ScreenAdapter.width(20)),
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenAdapter.width(32),
                    vertical: ScreenAdapter.height(16),
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFF3D7CFF) : Color(0xFFF7F8FA),
                    borderRadius:
                        BorderRadius.circular(ScreenAdapter.width(40)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    controller.filterList[index],
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(38),
                      color: isSelected ? Colors.white : Color(0xFF666666),
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.normal,
                      height: 1.2,
                    ),
                    strutStyle: StrutStyle(
                      fontSize: ScreenAdapter.fontSize(38),
                      height: 1.2,
                      forceStrutHeight: true,
                    ),
                  ),
                ),
              );
            }),
          )),
    );
  }
}
