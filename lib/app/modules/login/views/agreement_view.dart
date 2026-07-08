import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import '../../../data/providers/api_client.dart';

class AgreementView extends StatelessWidget {
  final int initialIndex;

  const AgreementView({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialIndex,
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF333333),
          centerTitle: false,
          titleSpacing: 0,
          title: Text(
            "用户协议与隐私政策",
            style: TextStyle(
              fontSize: 40.sp,
              color: const Color(0xFF333333),
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size: 60.sp,
              color: const Color(0xFF333333),
            ),
            onPressed: () {
              Get.back();
            },
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48.h),
            child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: TabBar(
                labelColor: const Color(0xFFE53935),
                unselectedLabelColor: const Color(0xFF666666),
                indicatorColor: const Color(0xFFE53935),
                indicatorWeight: 2,
                labelStyle: TextStyle(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w500,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w400,
                ),
                tabs: const [
                  Tab(text: "服务条款"),
                  Tab(text: "隐私政策"),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildContent(
              "服务条款",
              2,
            ),
            _buildContent(
              "隐私政策",
              3,
            ),
          ],
        ),
      ),
    );
  }

  String? _extractText(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map) {
      return _extractText(
        value['content'] ?? value['text'] ?? value['value'],
      );
    }
    return null;
  }

  Future<String> _fetchContent(int richtextId) async {
    try {
      final response = await ApiClient.to.get(
        'addons/exam/common/richtextContent',
        queryParameters: {'id': richtextId},
      );
      final data = response.data;

      // 纯字符串直接返回
      if (data is String) {
        return data;
      }

      // 常见结构
      if (data is Map) {
        final candidate =
            data['data'] ?? data['content'] ?? data['text'] ?? data;
        final extracted = _extractText(candidate);
        if (extracted != null) {
          return extracted;
        }
      }

      //转成字符串
      return data?.toString() ?? '';
    } catch (e) {
      return '加载失败：${e}';
    }
  }

  Widget _buildContent(String title, int richtextId) {
    return FutureBuilder<String>(
      future: _fetchContent(richtextId),
      builder: (context, snapshot) {
        String content;
        if (snapshot.connectionState == ConnectionState.waiting) {
          content = '加载中..';
        } else if (snapshot.hasError) {
          content = '加载失败：${snapshot.error}';
        } else {
          content = snapshot.data ?? '';
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 50.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF333333),
                ),
              ),
              SizedBox(height: 16.h),
              HtmlWidget(
                content,
                textStyle: TextStyle(
                  fontSize: 36.sp,
                  height: 1.6,
                  color: const Color(0xFF333333),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
