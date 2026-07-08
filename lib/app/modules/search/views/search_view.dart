import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/question_search_controller.dart';

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final QuestionSearchController controller =
      Get.find<QuestionSearchController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Obx(() {
                if (controller.isSearching.value) {
                  return _buildLoading();
                } else if (controller.hasSearched.value) {
                  if (controller.searchError.value.isNotEmpty) {
                    return _buildError(controller.searchError.value);
                  } else if (controller.searchResults.isEmpty) {
                    return _buildEmpty();
                  } else {
                    return _buildResults();
                  }
                } else {
                  return _buildInitial();
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: 32.w,
        vertical: 20.h,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Icon(
              Icons.arrow_back_ios,
              size: 44.sp,
              color: const Color(0xFF333333),
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Container(
              height: 100.h,
              padding: EdgeInsets.symmetric(
                horizontal: 24.w,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(50.w),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 48.sp,
                    color: const Color(0xFF999999),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: TextField(
                      controller: controller.searchController,
                      decoration: InputDecoration(
                        hintText: '输入要查找的题目',
                        hintStyle: TextStyle(
                          fontSize: 36.sp,
                          color: const Color(0xFF999999),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: TextStyle(
                        fontSize: 36.sp,
                        color: const Color(0xFF333333),
                      ),
                      onSubmitted: (_) => controller.search(),
                      textInputAction: TextInputAction.search,
                      autofocus: true,
                    ),
                  ),
                  Obx(() {
                    if (controller.searchText.value.isNotEmpty) {
                      return GestureDetector(
                        onTap: controller.clearSearch,
                        child: Padding(
                          padding: EdgeInsets.only(left: 16.w),
                          child: Icon(
                            Icons.cancel,
                            size: 40.sp,
                            color: const Color(0xFFCCCCCC),
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  }),
                ],
              ),
            ),
          ),
          SizedBox(width: 20.w),
          GestureDetector(
            onTap: () => controller.search(),
            child: Text(
              '搜索',
              style: TextStyle(
                fontSize: 36.sp,
                color: const Color(0xFF3D7CFF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitial() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 160.sp,
            color: const Color(0xFFE0E0E0),
          ),
          SizedBox(height: 32.h),
          Text(
            '搜索你想要的题目',
            style: TextStyle(
              fontSize: 36.sp,
              color: const Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3D7CFF)),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 160.sp,
            color: const Color(0xFFFF6B6B),
          ),
          SizedBox(height: 32.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 36.sp,
              color: const Color(0xFF666666),
            ),
          ),
          SizedBox(height: 32.h),
          GestureDetector(
            onTap: controller.search,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 48.w,
                vertical: 20.h,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF3D7CFF),
                borderRadius: BorderRadius.circular(40.w),
              ),
              child: Text(
                '重试',
                style: TextStyle(
                  fontSize: 36.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 160.sp,
            color: const Color(0xFFE0E0E0),
          ),
          SizedBox(height: 32.h),
          Text(
            '没有找到相关题目',
            style: TextStyle(
              fontSize: 36.sp,
              color: const Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: 32.w,
        vertical: 24.h,
      ),
      itemCount: controller.searchResults.length,
      separatorBuilder: (context, index) => SizedBox(height: 24.h),
      itemBuilder: (context, index) {
        final question = controller.searchResults[index];
        return _buildQuestionCard(question);
      },
    );
  }

  Widget _buildQuestionCard(SearchQuestion question) {
    return GestureDetector(
      onTap: () => controller.goToQuestionDetail(question.id, question.content),
      child: Container(
        padding: EdgeInsets.all(32.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.w),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (question.categoryName != null &&
                question.categoryName!.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 8.h,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1FF),
                  borderRadius: BorderRadius.circular(20.w),
                ),
                child: Text(
                  question.categoryName!,
                  style: TextStyle(
                    fontSize: 28.sp,
                    color: const Color(0xFF3D7CFF),
                  ),
                ),
              ),
            if (question.categoryName != null &&
                question.categoryName!.isNotEmpty)
              SizedBox(height: 20.h),
            Text(
              question.content,
              style: TextStyle(
                fontSize: 36.sp,
                color: const Color(0xFF333333),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (question.options.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 20.h),
                child: Wrap(
                  spacing: 16.w,
                  runSpacing: 12.h,
                  children: question.options.take(4).map((option) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(16.w),
                      ),
                      child: Text(
                        (option = option.toString()).length > 20
                            ? '${option.substring(0, 20)}...'
                            : option,
                        style: TextStyle(
                          fontSize: 30.sp,
                          color: const Color(0xFF666666),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ),
              ),
            SizedBox(height: 20.h),
            Row(
              children: [
                if (question.difficulty != null &&
                    question.difficulty!.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7E6),
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                    child: Text(
                      question.difficulty!,
                      style: TextStyle(
                        fontSize: 26.sp,
                        color: const Color(0xFFFF9500),
                      ),
                    ),
                  ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 32.sp,
                  color: const Color(0xFFCCCCCC),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
