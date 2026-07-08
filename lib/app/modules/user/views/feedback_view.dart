import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/screenAdapter.dart';

// 意见反馈页面
class FeedbackView extends StatelessWidget {
  const FeedbackView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF333333),
        centerTitle: true,
        title: Text(
          '意见反馈',
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(40),
            color: const Color(0xFF333333),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenAdapter.width(30),
          vertical: ScreenAdapter.height(30),
        ),
        children: [
          _buildFeedbackCard(
            title: '问题反馈',
            description: '留下您的建议或反馈，帮助商家做的更好',
            onTap: () => Get.toNamed('/question-feedback'),
          ),
          SizedBox(height: ScreenAdapter.height(30)),
          _buildFeedbackCard(
            title: '投诉反馈',
            description: '提交交易纠纷投诉、内容违规投诉、内容侵权投诉',
            onTap: () => Get.toNamed('/complaint-feedback'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard({
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ScreenAdapter.width(24)),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: ScreenAdapter.width(30),
          vertical: ScreenAdapter.height(30),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(38),
                color: const Color(0xFF333333),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: ScreenAdapter.height(10)),
            Text(
              description,
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(30),
                color: const Color(0xFF999999),
              ),
            ),
            SizedBox(height: ScreenAdapter.height(10)),
            Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.chevron_right,
                size: ScreenAdapter.fontSize(44),
                color: const Color(0xFFCCCCCC),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
