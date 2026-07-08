import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import '../data/providers/api_client.dart';

/// 通用 HTML 内容展示页
///
/// 用于展示从接口获取的 HTML 富文本内容，如平台资质、企业团报合作等。
class HtmlContentView extends StatelessWidget {
  /// 页面标题
  final String title;

  /// 富文本内容 ID（传给 common/richtextContent）
  final int richtextId;

  const HtmlContentView({
    Key? key,
    required this.title,
    required this.richtextId,
  }) : super(key: key);

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

  Future<String> _fetchContent() async {
    try {
      final response = await ApiClient.to.exam(
        'common/richtextContent',
        queryParameters: {'id': richtextId},
      );
      final data = response.data;

      if (data is String) {
        return data;
      }

      if (data is Map) {
        final candidate =
            data['data'] ?? data['content'] ?? data['text'] ?? data;
        final extracted = _extractText(candidate);
        if (extracted != null) {
          return extracted;
        }
      }

      return data?.toString() ?? '';
    } catch (e) {
      return '加载失败：${e}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF333333),
        centerTitle: true,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 48.sp,
            color: const Color(0xFF333333),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 48.sp,
            color: const Color(0xFF333333),
          ),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return FutureBuilder<String>(
      future: _fetchContent(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: const Color(0xFF2E3A6B),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 120.sp,
                  color: const Color(0xFF999999),
                ),
                SizedBox(height: 24.h),
                Text(
                  '加载失败',
                  style: TextStyle(
                    fontSize: 36.sp,
                    color: const Color(0xFF999999),
                  ),
                ),
              ],
            ),
          );
        } else {
          final content = snapshot.data ?? '';
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 40.w,
              vertical: 40.h,
            ),
            child: Container(
              padding: EdgeInsets.all(30.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26.w),
              ),
              child: HtmlWidget(
                content,
                textStyle: TextStyle(
                  fontSize: 32.sp,
                  height: 1.8,
                  color: const Color(0xFF333333),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
