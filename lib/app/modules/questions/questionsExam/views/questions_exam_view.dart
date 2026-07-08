import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/category_model.dart';
import '../../../../services/screenAdapter.dart';
import '../../../../services/keepAliveWrapper.dart';
import '../controllers/questions_exam_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class QuestionsExamView extends GetView<QuestionsExamController> {
  const QuestionsExamView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // 构建顶部AppBar - 标题靠左
  AppBar _buildAppBar() {
    // 根据页面类型获取标题
    String title = '';
    switch (controller.pageType) {
      case 'must_brush':
        title = '必刷母题';
        break;
      case 'past_exams':
        title = '历年真题';
        break;
      case 'mock_exams':
        title = '模拟考试';
        break;
      case 'chapter_detail':
        final args = Get.arguments;
        if (args != null && args is Map) {
          title = args['title'] ?? '章节详情';
        } else {
          title = '章节详情';
        }
        break;
    }

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: ScreenAdapter.height(132),
      leadingWidth: ScreenAdapter.width(40), // 添加左边距空白
      leading: SizedBox(), // 空组件，用于占位
      title: Container(
        padding: EdgeInsets.only(
          top: ScreenAdapter.height(38),
          bottom: ScreenAdapter.height(38),
        ),
        child: Align(
          alignment: Alignment.centerLeft, // 靠左对齐
          child: Text(
            title,
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(55),
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      actions: [
        // 可以在这里添加右侧图标按钮，如果需要
      ],
    );
  }

  // 构建页面主体
  Widget _buildBody() {
    return Column(
      children: [
        // 分割线
        Container(
          height: ScreenAdapter.height(1),
          color: const Color(0xFFF0F0F0),
        ),

        _subjectNavigation(),
        Expanded(
          child: Obx(() => PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.subjects.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final subject = controller.subjects[index];
                  // 根据页面类型显示不同的列表内容
                  if (controller.pageType == 'mock_exams' ||
                      controller.pageType == 'past_exams') {
                    return KeepAliveWrapper(child: _buildExamList(subject));
                  }
                  return KeepAliveWrapper(
                      child: _buildCourseList(subject.name));
                },
              )),
        ),
      ],
    );
  }

  // 构建科目导航
  Widget _subjectNavigation() {
    return Container(
      height: ScreenAdapter.height(121),
      padding: EdgeInsets.only(
        left: ScreenAdapter.width(55),
        right: ScreenAdapter.width(20),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: const Color(0xFFF0F0F0))),
      ),
      child: Obx(() => ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.subjects.length,
            itemBuilder: (context, index) {
              return Obx(() => GestureDetector(
                    onTap: () => controller.setCurrentSubjectIndex(index),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenAdapter.width(30),
                        vertical: ScreenAdapter.height(35),
                      ),
                      child: Text(
                        controller.subjects[index].name,
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(42),
                          color: controller.currentSubjectIndex.value == index
                              ? controller.defaultThemeColor
                              : const Color(0xFF999999),
                          fontWeight:
                              controller.currentSubjectIndex.value == index
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                        ),
                      ),
                    ),
                  ));
            },
          )),
    );
  }

  // 构建课程列表
  Widget _buildCourseList(String subject) {
    final filteredList = subject == '全部科目'
        ? controller.courses
        : controller.courses
            .where((element) => (element['title'] as String).contains(subject))
            .toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Text(
          '暂无相关课程',
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(28),
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenAdapter.width(16),
        vertical: ScreenAdapter.height(12),
      ),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final course = filteredList[index];
        return Container(
          margin: EdgeInsets.only(bottom: ScreenAdapter.height(12)),
          height: ScreenAdapter.height(300),
          padding: EdgeInsets.all(ScreenAdapter.width(20)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(ScreenAdapter.width(8)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[200]!,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // 课程图片
              ClipRRect(
                borderRadius: BorderRadius.circular(ScreenAdapter.width(4)),
                child: CachedNetworkImage(
                  imageUrl: course['image'],
                  width: ScreenAdapter.width(100),
                  height: ScreenAdapter.width(100),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: ScreenAdapter.width(100),
                    height: ScreenAdapter.width(100),
                    color: Colors.grey[200],
                  ),
                ),
              ),
              SizedBox(width: ScreenAdapter.width(20)),
              // 课程信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ScreenAdapter.width(10),
                            vertical: ScreenAdapter.height(4),
                          ),
                          decoration: BoxDecoration(
                            color: course['type'] == '直播'
                                ? Colors.red[100]
                                : Colors.blue[100],
                            borderRadius:
                                BorderRadius.circular(ScreenAdapter.width(4)),
                          ),
                          child: Text(
                            course['type'],
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(30),
                              color: course['type'] == '直播'
                                  ? Colors.red[600]
                                  : Colors.blue[600],
                            ),
                          ),
                        ),
                        SizedBox(width: ScreenAdapter.width(12)),
                        Expanded(
                          child: Text(
                            course['title'],
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(52),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ScreenAdapter.height(12)),
                    Text(
                      course['teacher'],
                      style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(34),
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: ScreenAdapter.height(8)),
                    Text(
                      course['progress'],
                      style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(34),
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: ScreenAdapter.height(8)),
                    Text(
                      course['watched'],
                      style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(34),
                        color: controller.defaultThemeColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: ScreenAdapter.width(20)),
              // 操作按钮
              GestureDetector(
                onTap: () {
                  // 跳转到答题页
                  Get.toNamed('/question-train');
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenAdapter.width(30),
                    vertical: ScreenAdapter.height(15),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(ScreenAdapter.width(8)),
                  ),
                  child: Text(
                    '继续学习',
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(34),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 构建试卷列表
  Widget _buildExamList(CategoryChild subject) {
    return Obx(() {
      final subjectId = subject.id;
      final isLoading = controller.isExamLoadingMap[subjectId] ?? false;
      final examPapers = controller.examPapersMap[subjectId] ?? [];

      if (isLoading && examPapers.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (examPapers.isEmpty) {
        return Center(
          child: Text(
            '暂无相关试卷',
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(28),
              color: Colors.grey,
            ),
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenAdapter.width(32),
          vertical: ScreenAdapter.height(24),
        ),
        itemCount: examPapers.length,
        itemBuilder: (context, index) {
          final paper = examPapers[index];
          return GestureDetector(
            onTap: () {
              // 解析 configs 获取实际的题目分类ID
              var cateId = paper['id']; // 默认使用paper id
              try {
                final configs = paper['configs'];
                if (configs is Map) {
                  final configCateIds = configs['cate_ids'];
                  if (configCateIds != null &&
                      configCateIds.toString().isNotEmpty) {
                    cateId = configCateIds;
                  }
                }
              } catch (e) {
                print('Error parsing paper configs: $e');
              }

              // 跳转到考试详情或答题页
              Get.toNamed('/question-train', arguments: {
                'mode': 'EXAM',
                'cate_id': cateId,
                'paper_id': paper['id'],
                'limit_time': paper['limit_time'],
                'title': paper['title'],
                'join_count': paper['join_count'],
                'total_score': paper['total_score'],
                'pass_score': paper['pass_score'],
              });
            },
            child: Container(
              margin: EdgeInsets.only(bottom: ScreenAdapter.height(24)),
              padding: EdgeInsets.all(ScreenAdapter.width(24)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(ScreenAdapter.width(16)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x0D000000),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 封面图片
                  ClipRRect(
                    borderRadius: BorderRadius.circular(ScreenAdapter.width(8)),
                    child: CachedNetworkImage(
                      imageUrl: paper['cover_image'] ?? '',
                      width: ScreenAdapter.width(160),
                      height: ScreenAdapter.width(160),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child:
                            const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(width: ScreenAdapter.width(24)),
                  // 内容
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          paper['title'] ?? '',
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(32),
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF333333),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: ScreenAdapter.height(16)),
                        Row(
                          children: [
                            _buildTag(
                                '${paper['quantity'] ?? 0}题',
                                const Color(0xFFE8F3FF),
                                const Color(0xFF3A7FFF)),
                            SizedBox(width: ScreenAdapter.width(16)),
                            _buildTag(
                                '${(paper['limit_time'] ?? 0) ~/ 60}分钟',
                                const Color(0xFFFFF7E8),
                                const Color(0xFFFF9900)),
                          ],
                        ),
                        SizedBox(height: ScreenAdapter.height(12)),
                        Row(
                          children: [
                            Text(
                              '${paper['join_count'] ?? 0}人已报名',
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(22),
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(width: ScreenAdapter.width(16)),
                            Text(
                              '总分: ${paper['total_score'] ?? 0}',
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(22),
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 开始考试按钮
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenAdapter.width(24),
                      vertical: ScreenAdapter.height(12),
                    ),
                    decoration: BoxDecoration(
                      color: controller.defaultThemeColor,
                      borderRadius:
                          BorderRadius.circular(ScreenAdapter.width(30)),
                    ),
                    child: Text(
                      '开始考试',
                      style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(24),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenAdapter.width(12),
        vertical: ScreenAdapter.height(4),
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(ScreenAdapter.width(4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: ScreenAdapter.fontSize(20),
          color: textColor,
        ),
      ),
    );
  }
}
