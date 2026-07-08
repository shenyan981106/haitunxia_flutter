import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/home_controller.dart';
import '../../../data/providers/api_client.dart';
import '../../../data/models/home_model.dart';
import '../../../data/models/version_model.dart';

final FontWeight w500 = FontWeight.w500;

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeController controller = Get.find<HomeController>();
  final ScrollController _scrollController = ScrollController();
  final PageController _bannerPageController = PageController();
  Timer? _bannerTimer;
  Worker? _updateWorker;
  int _bannerIndex = 0;

  @override
  void initState() {
    super.initState();
    // 首页加载完成后检测版本更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.checkVersion();
    });
    // 监听版本更新模型变化，触发弹窗

    _updateWorker = ever(controller.pendingUpdate, (model) {
      if (model != null && mounted) {
        _showUpdateDialog(model);
      }
    });
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _autoScrollBanner();
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _updateWorker?.dispose();
    _bannerPageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _autoScrollBanner() {
    final slides = controller.homeApiResponse.value?.data?.slides ?? [];
    if (slides.length <= 1 || !_bannerPageController.hasClients) return;

    final nextIndex = (_bannerIndex + 1) % slides.length;
    _bannerPageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  /// 显示版本更新弹窗
  void _showUpdateDialog(VersionModel model) {
    Get.dialog(
      PopScope(
        canPop: !model.enforce,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 640.w,
              margin: EdgeInsets.symmetric(horizontal: 32.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: EdgeInsets.fromLTRB(48.w, 56.h, 48.w, 48.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 标题
                    Text(
                      '发现新版本',
                      style: TextStyle(
                        fontSize: 38.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4A6CF7),
                      ),
                    ),
                    SizedBox(height: 40.h),

                    // 版本信息
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (model.newVersion != null)
                            Text(
                              '最新版本${model.newVersion}',
                              style: TextStyle(
                                fontSize: 30.sp,
                                color: const Color(0xFF666666),
                              ),
                            ),
                          if (model.packageSize != null) ...[
                            SizedBox(height: 10.h),
                            Text(
                              '新版本大小${model.packageSize}',
                              style: TextStyle(
                                fontSize: 30.sp,
                                color: const Color(0xFF666666),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // 更新内容标题
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '更新内容?',
                        style: TextStyle(
                          fontSize: 30.sp,
                          color: const Color(0xFF333333),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // 更新内容列表
                    if (model.content != null && model.content!.isNotEmpty)
                      ...model.content!
                          .split('\n')
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final text = entry.value;
                        if (text.trim().isEmpty) return SizedBox.shrink();
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${index + 1}.',
                                style: TextStyle(
                                  fontSize: 29.sp,
                                  color: const Color(0xFF333333),
                                  height: 1.6,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  text.replaceFirst(RegExp(r'^\d+\.\s*'), ''),
                                  style: TextStyle(
                                    fontSize: 29.sp,
                                    color: const Color(0xFF666666),
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList()
                    else
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Center(
                          child: Text(
                            '暂无更新内容',
                            style: TextStyle(
                              fontSize: 26.sp,
                              color: const Color(0xFF999999),
                            ),
                          ),
                        ),
                      ),

                    SizedBox(height: 44.h),

                    // 按钮区域
                    if (!model.enforce)
                      Row(
                        children: [
                          // 以后再说
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Get.back(),
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                height: 88.h,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(44.r),
                                  border: Border.all(
                                    color: const Color(0xFFDDDDDD),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '以后再说',
                                  style: TextStyle(
                                    fontSize: 30.sp,
                                    color: const Color(0xFF666666),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 24.w),
                          // 立即更新
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  controller.downloadUpdate(model.downloadUrl),
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                height: 88.h,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4A6CF7),
                                  borderRadius: BorderRadius.circular(44.r),
                                ),
                                child: Text(
                                  '立即更新',
                                  style: TextStyle(
                                    fontSize: 30.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      // 强制更新只显示立即更新按钮
                      SizedBox(
                        width: double.infinity,
                        height: 88.h,
                        child: GestureDetector(
                          onTap: () =>
                              controller.downloadUpdate(model.downloadUrl),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A6CF7),
                              borderRadius: BorderRadius.circular(44.r),
                            ),
                            child: Text(
                              '立即更新',
                              style: TextStyle(
                                fontSize: 30.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      barrierColor: Colors.black54,
      barrierDismissible: !model.enforce,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // 顶部导航栏（吸顶）
              SliverPersistentHeader(
                pinned: true,
                floating: false,
                delegate: _TopBarHeaderDelegate(
                  child: Container(
                    color: const Color(0xFFF8FAFF),
                    padding:
                        EdgeInsets.only(left: 32.w, right: 32.w, top: 30.h),
                    child: _buildTopBar(),
                  ),
                ),
              ),
              // 顶部内容区域（可滚动）
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 40.h),
                      _buildSearchBar(),
                      _buildBannerCarousel(),
                      _buildNoticeBar(),
                      SizedBox(height: 30.h),
                      _buildTopFeatureCards(),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
              // tabs导航（吸顶，在顶部导航栏下方）
              SliverPersistentHeader(
                pinned: true,
                floating: false,
                delegate: _TabsHeaderDelegate(
                  child: Container(
                    color: const Color(0xFFF8FAFF),
                    child: _buildStickyTabsNavigation(),
                  ),
                ),
              ),
              // 内容区域
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Obx(() {
                    return IndexedStack(
                      index: controller.currentTabIndex.value,
                      children: [
                        _buildCoursesList(), // 精选推荐课程列表
                        _buildPastExamsList(), // 历年真题
                        _buildMockExamsList(), // 模拟考试
                      ],
                    );
                  }),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 120.h),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: controller.switchSubject,
          child: Row(
            children: [
              Obx(() => Text(
                    controller.currentProjectName.value,
                    style: TextStyle(
                      fontSize: 50.sp,
                      fontWeight: w500,
                      color: const Color(0xFF333333),
                    ),
                  )),
              Icon(
                Icons.arrow_drop_down,
                size: 48.sp,
                color: const Color(0xFF333333),
              ),
            ],
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => controller.fetchCompanyConfigAndOpenH5(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1FF),
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Row(
              children: [
                Text(
                  '企业合作',
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: w500,
                    color: const Color(0xFF3D7CFF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () => controller.goToSearch(),
      child: Container(
        height: 140.h,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search,
                size: 80.sp, color: const Color.fromARGB(255, 208, 217, 230)),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                '输入要查找的题目',
                style: TextStyle(
                  fontSize: 42.sp,
                  color: const Color(0xFF999999),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerCarousel() {
    return Obx(() {
      final slides = controller.homeApiResponse.value?.data?.slides ?? [];
      if (slides.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.only(top: 30.h),
        child: SizedBox(
          height: 280.h,
          child: Stack(
            children: [
              PageView.builder(
                controller: _bannerPageController,
                itemCount: slides.length,
                onPageChanged: (index) {
                  if (!mounted) return;
                  setState(() {
                    _bannerIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => controller.onBannerTap(slide.url),
                    child: Container(
                      margin: EdgeInsets.only(right: 2.w),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF1FF),
                        borderRadius: BorderRadius.circular(36.r),
                      ),
                      child: slide.image.isNotEmpty
                          ? Image.network(
                              ApiClient.replaceUri(slide.image),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint(
                                    '轮播图加载失败: ${slide.image}, Error: $error');
                                return _buildBannerFallback(slide.title);
                              },
                            )
                          : _buildBannerFallback(slide.title),
                    ),
                  );
                },
              ),
              if (slides.length > 1)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 18.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(slides.length, (index) {
                      final isActive = index == _bannerIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isActive ? 28.w : 10.w,
                        height: 10.h,
                        margin: EdgeInsets.symmetric(horizontal: 5.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: isActive ? 0.95 : 0.55,
                          ),
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBannerFallback(String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.w),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3D7CFF), Color(0xFF6EA8FF)],
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.isNotEmpty ? title : '推荐内容',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 44.sp,
            color: Colors.white,
            fontWeight: w500,
          ),
        ),
      ),
    );
  }

  Widget _buildNoticeBar() {
    return Obx(() {
      final notices = controller.homeApiResponse.value?.data?.notices ?? [];
      if (notices.isEmpty) return const SizedBox.shrink();

      final notice = notices.first;
      return Padding(
        padding: EdgeInsets.only(top: 24.h),
        child: Container(
          height: 88.h,
          padding: EdgeInsets.symmetric(horizontal: 26.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF000000).withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.campaign,
                size: 38.sp,
                color: const Color(0xFF3D7CFF),
              ),
              SizedBox(width: 14.w),
              Text(
                '公告',
                style: TextStyle(
                  fontSize: 30.sp,
                  color: const Color(0xFF3D7CFF),
                  fontWeight: w500,
                ),
              ),
              SizedBox(width: 18.w),
              Expanded(
                child: Text(
                  notice.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 30.sp,
                    color: const Color(0xFF333333),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ignore: unused_element
  Widget _buildLearningStatsCard() {
    return Obx(() {
      final stats = controller.homeApiResponse.value?.data?.stats;

      return Container(
        height: 390.h,
        padding: EdgeInsets.symmetric(horizontal: 72.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF3D7CFF), Color(0xFF5B8FF9)],
          ),
          borderRadius: BorderRadius.circular(60.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3D7CFF).withValues(alpha: 0.18),
              spreadRadius: 0,
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLearningStatItem(
              value: (stats?.totalDays ?? 0).toString(),
              label: '已学天数',
            ),
            _buildLearningStatItem(
              value: _formatStudyHours(stats?.todayHours ?? 0),
              label: '今日学习',
            ),
            _buildLearningStatItem(
              value: (stats?.total ?? 0).toString(),
              label: '已刷题数',
            ),
          ],
        ),
      );
    });
  }

  String _formatStudyHours(num hours) {
    final text = hours % 1 == 0 ? hours.toInt().toString() : hours.toString();
    return '${text}h';
  }

  Widget _buildLearningStatItem({
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 84.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 22.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 34.sp,
              color: Colors.white.withValues(alpha: 0.68),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopFeatureCards() {
    final spacing = 18.w;
    return SizedBox(
      height: 210.h,
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 210.h,
              child: _buildFeatureCard(
                title: '我的课程',
                subtitle: '听课学习',
                colors: const [Color(0xFF2E9E8F), Color(0xFF62C7B6)],
                icon: Icons.school,
                badgeText: null,
                onTap: () => controller.onStatusItemTap('我的课程'),
              ),
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: SizedBox(
              height: 210.h,
              child: _buildFeatureCard(
                title: '每日一练',
                subtitle: '做题',
                colors: const [Color(0xFFFF7A45), Color(0xFFFF9C6C)],
                icon: Icons.edit_note,
                badgeText: null,
                onTap: () => controller.onStatusItemTap('每日一练'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required List<Color> colors,
    required IconData icon,
    required String? badgeText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(22.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors[0].withOpacity(0.95),
              colors[1].withOpacity(1.0),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -16.w,
              bottom: -30.h,
              child: Icon(
                icon,
                size: 170.sp,
                color: Colors.white.withOpacity(0.22),
              ),
            ),
            if (badgeText != null)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD666),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 40.sp,
                      fontWeight: w500,
                      color: const Color(0xFF7A4E00),
                    ),
                  ),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 44.sp,
                    fontWeight: w500,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 28.sp,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesList() {
    final courses = controller.homeApiResponse.value?.data?.courses ?? [];
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.8,
      ),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return _buildCoursesCard(courses[index]);
      },
    );
  }

  Widget _buildCoursesCard(dynamic course) {
    // 动态获取数据
    String title = '课程标题';
    String description = '课程描述';
    String imageUrl = '';
    int count = 0;
    int courseId = 0;

    if (course is HomeCourse) {
      // 如果是 HomeCourse 对象
      title = course.title;
      description = course.categoryName;
      imageUrl = course.coverImage;
      courseId = course.id;
      count = course.enrollCount;
    } else if (course is Map<String, dynamic>) {
      // 如果是 Map 对象
      title = course['title'] ?? '课程标题';
      description = course['description'] ?? course['category_name'] ?? '课程描述';
      imageUrl = (course['cover_image'] ??
              course['cover_image_url'] ??
              course['image'] ??
              '')
          .toString();
      count = course['enroll_count'] ?? 0;
      courseId = course['id'] ?? 0;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // 跳转到课程详情页
        Get.toNamed('/study/details', arguments: {'id': courseId});
      },
      child: Container(
        height: 700.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部图片
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              child: Container(
                width: double.infinity,
                height: 400.h,
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        ApiClient.replaceUri(imageUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('课程图片加载失败: $imageUrl, Error: $error');
                          return _buildPlaceholderImage();
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: const Color(0xFF3D7CFF),
                            ),
                          );
                        },
                      )
                    : _buildPlaceholderImage(),
              ),
            ),
            // 内容部分
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 40.sp,
                        fontWeight: w500,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // 描述
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 34.sp,
                        color: const Color(0xFF666666),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // 已报名人数
                    Text(
                      '${count}人已报名',
                      style: TextStyle(
                        fontSize: 28.sp,
                        color: const Color(0xFF999999),
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

  Widget _buildPastExamsList() {
    final papers = controller.homeApiResponse.value?.data?.papers ?? [];
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        crossAxisSpacing: 32.w,
        mainAxisSpacing: 32.h,
        childAspectRatio: 3,
      ),
      itemCount: papers.length,
      itemBuilder: (context, index) {
        return _buildPastExamsCard(papers[index]);
      },
    );
  }

  Widget _buildMockExamsList() {
    final rooms = controller.homeApiResponse.value?.data?.rooms ?? [];
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        crossAxisSpacing: 32.w,
        mainAxisSpacing: 32.h,
        childAspectRatio: 3,
      ),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        return _buildMockExamsCard(rooms[index]);
      },
    );
  }

  Widget _buildPastExamsCard(dynamic paper) {
    // 动态获取数据
    String title = '历年真题';
    String description = '';
    String validity = '永久有效';

    if (paper is HomePaper) {
      // 如果是 HomePaper 对象
      title = paper.title;
      description = '总分: ${paper.totalScore}, 及格分数: ${paper.passScore}';
      validity = paper.typeText.isNotEmpty ? paper.typeText : '点击开始做';
    } else if (paper is Map<String, dynamic>) {
      // 如果是 Map 对象
      title = paper['title'] ?? paper['name'] ?? '历年真题';
      final totalScore = paper['total_score'] ?? 0;
      final passScore = paper['pass_score'] ?? 0;
      description = '总分: $totalScore, 及格分数: $passScore';
      validity = paper['type_text'] ?? '点击开始做';
    }

    return Container(
      height: 120.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(32.w, 16.w, 16.w, 16.w),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 分类标签
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF1FF),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    '历年真题',
                    style: TextStyle(
                      fontSize: 24.sp,
                      color: const Color(0xFF3D7CFF),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                // 标题
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 40.sp,
                    fontWeight: w500,
                    color: const Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 8.h),
                // 描述文字
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 28.sp,
                    color: const Color(0xFF999999),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                // 有效时间
                Text(
                  validity,
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: const Color(0xFF999999),
                  ),
                ),
              ],
            ),
            // 立即参加按钮
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () {
                  int paperId = 0;
                  String paperTitle = title;
                  int paperTotalScore = 0;
                  int paperPassScore = 0;

                  if (paper is HomePaper) {
                    paperId = paper.id;
                    paperTotalScore = paper.totalScore;
                    paperPassScore = paper.passScore;
                  } else if (paper is Map<String, dynamic>) {
                    paperId = paper['id'] ?? 0;
                    paperTotalScore = paper['total_score'] ?? 0;
                    paperPassScore = paper['pass_score'] ?? 0;
                  }

                  Get.toNamed(
                    '/question-train',
                    arguments: {
                      'paper_id': paperId,
                      'title': paperTitle,
                      'limit_time': 0,
                      'total_score': paperTotalScore,
                      'pass_score': paperPassScore,
                      'join_count': 0,
                      'mode': 'EXAM',
                      'pageType': 'past',
                    },
                  );
                },
                child: Container(
                  width: 240.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50.r),
                    border: Border.all(
                      color: const Color(0xFF3D7CFF),
                      width: 2.w,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '立即参加',
                      style: TextStyle(
                        fontSize: 32.sp,
                        color: const Color(0xFF3D7CFF),
                        fontWeight: w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockExamsCard(HomeRoom room) {
    return Container(
      height: 120.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(32.w, 16.w, 16.w, 16.w),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 分类标签
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF1FF),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    '模拟考试',
                    style: TextStyle(
                      fontSize: 24.sp,
                      color: const Color(0xFF3D7CFF),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                // 标题
                Text(
                  room.title,
                  style: TextStyle(
                    fontSize: 40.sp,
                    fontWeight: w500,
                    color: const Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 8.h),
                // 描述文字
                Text(
                  '总分: ${room.totalScore}, 及格分数: ${room.passScore}',
                  style: TextStyle(
                    fontSize: 28.sp,
                    color: const Color(0xFF999999),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                // 描述
                Text(
                  room.typeText.isNotEmpty ? room.typeText : '点击开始做',
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: const Color(0xFF999999),
                  ),
                ),
              ],
            ),
            // 立即参加按钮
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () {
                  Get.toNamed(
                    '/question-train',
                    arguments: {
                      'paper_id': room.id,
                      'title': room.title,
                      'limit_time': 0,
                      'total_score': room.totalScore,
                      'pass_score': room.passScore,
                      'join_count': 0,
                      'mode': 'EXAM',
                      'pageType': 'mock',
                    },
                  );
                },
                child: Container(
                  width: 240.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50.r),
                    border: Border.all(
                      color: const Color(0xFF3D7CFF),
                      width: 2.w,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '立即参加',
                      style: TextStyle(
                        fontSize: 32.sp,
                        color: const Color(0xFF3D7CFF),
                        fontWeight: w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: const Color(0xFFE8F4FD),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image,
              size: 60.sp,
              color: const Color(0xFF3D7CFF),
            ),
            SizedBox(height: 10.h),
            Text(
              '快速入门\n短视频变换',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.sp,
                color: const Color(0xFF3D7CFF),
                fontWeight: w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 吸顶tabs导航
  Widget _buildStickyTabsNavigation() {
    final titles = ['精选推荐', '历年真题', '模拟考试'];
    return Container(
      height: 140.h,
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Obx(() {
        final currentTab = controller.currentTabIndex.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: titles.length,
          separatorBuilder: (context, index) => SizedBox(width: 40.w),
          itemBuilder: (context, index) {
            final isActive = index == currentTab;
            return GestureDetector(
              onTap: () {
                controller.switchTab(index);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                alignment: Alignment.bottomCenter,
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        titles[index],
                        style: TextStyle(
                          fontSize: isActive ? 48.sp : 44.sp,
                          fontWeight: isActive ? w500 : FontWeight.normal,
                          color: isActive
                              ? const Color(0xFF000000)
                              : const Color(0xFF999999),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        height: 6.h,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF3D7CFF)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// 吸顶header委托类（顶部导航栏）
class _TopBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _TopBarHeaderDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: 120.h,
      child: child,
    );
  }

  @override
  double get maxExtent => 120.h;

  @override
  double get minExtent => 120.h;

  @override
  bool shouldRebuild(covariant _TopBarHeaderDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}

// 吸顶header委托类（tabs导航）
class _TabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _TabsHeaderDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: 140.h,
      child: child,
    );
  }

  @override
  double get maxExtent => 140.h;

  @override
  double get minExtent => 140.h;

  @override
  bool shouldRebuild(covariant _TabsHeaderDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
