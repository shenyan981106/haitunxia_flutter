import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/screenAdapter.dart';
import '../../../components/common_empty_state.dart';
import '../../../data/providers/api_client.dart';
import '../controllers/my_courses_controller.dart';

class MyCourseItemWidget extends StatelessWidget {
  final Map<String, dynamic> course;
  final VoidCallback onTap;

  const MyCourseItemWidget(
      {Key? key, required this.course, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String title = course['title']?.toString() ?? '';
    final String description = course['description']?.toString() ?? '';

    final bool isFree = course['is_free']?.toString() == '1';
    final String price = isFree ? '免费' : '\u00a5${course['price']}';

    int students =
        int.tryParse(course['total_students']?.toString() ?? '0') ?? 0;
    final String enrollment = students > 0 ? '$students\u5df2\u62a5\u540d' : '';

    int totalLessons =
        int.tryParse(course['total_lessons']?.toString() ?? '0') ?? 0;
    int completedLessons =
        int.tryParse(course['completed_lessons']?.toString() ?? '0') ?? 0;

    final String coverImage = course['cover_image_url']?.toString() ??
        course['cover_image']?.toString() ??
        '';

    bool hasVipTag = course['is_recommend'] == 1;

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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(46),
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF333333),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ScreenAdapter.height(20)),
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
                  SizedBox(height: ScreenAdapter.height(20)),
                  Divider(height: 1, color: Color(0xFFF5F5F5)),
                  SizedBox(height: ScreenAdapter.height(20)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '\u00a5',
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
                        '\u4f1a\u5458\u514d\u8d39',
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

class MyCoursesView extends GetView<MyCoursesController> {
  const MyCoursesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(
          '\u6211\u7684\u8bfe\u7a0b',
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(44),
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: Colors.black, size: ScreenAdapter.fontSize(44)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.courseOrderList.isEmpty) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.courseOrderList.isEmpty) {
          return CommonEmptyState(
            icon: Icons.school_outlined,
            title: '还没有课程哦，去看看吧',
          );
        }

        return RefreshIndicator(
          onRefresh: controller.onRefresh,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenAdapter.width(46),
              vertical: ScreenAdapter.height(32),
            ),
            itemCount: controller.courseOrderList.length,
            itemBuilder: (context, index) {
              final orderItem = controller.courseOrderList[index];
              // \u4ece\u8ba2\u5355\u9879\u4e2d\u63d0\u53d6\u8bfe\u7a0b\u6570\u636e\uff08coures\u5b57\u6bb5\uff09\uff0c\u5e76\u5408\u5e76\u8ba2\u5355\u7ea7\u522b\u4fe1\u606f
              final coures = orderItem['coures'] as Map<String, dynamic>? ?? {};
              final courseData = Map<String, dynamic>.from(coures);
              // \u5408\u5e76\u8ba2\u5355\u72b6\u6001\u7b49\u4fe1\u606f\u5230\u8bfe\u7a0b\u6570\u636e\u4e2d
              courseData['is_expired'] = orderItem['is_expired'];
              courseData['order_status_text'] = orderItem['order_status_text'];
              courseData['start_time_text'] = orderItem['start_time_text'];
              courseData['end_time_text'] = orderItem['end_time_text'];

              return MyCourseItemWidget(
                course: courseData,
                onTap: () {
                  Get.toNamed('/study/details', arguments: courseData);
                },
              );
            },
          ),
        );
      }),
    );
  }
}
