import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/screenAdapter.dart';

// 反馈记录详情页面
class FeedbackRecordDetailView extends StatelessWidget {
  const FeedbackRecordDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final record = Get.arguments as Map<String, dynamic>;
    final status = record['status'] as String;
    final isReplied = status == '已回复';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF333333),
        centerTitle: true,
        title: Text(
          '反馈详情',
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(36),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ScreenAdapter.width(32)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 反馈信息卡片
            Container(
              padding: EdgeInsets.all(ScreenAdapter.width(32)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(ScreenAdapter.width(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 类型 + 状态
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoItem('反馈类型', record['type']),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenAdapter.width(16),
                          vertical: ScreenAdapter.height(8),
                        ),
                        decoration: BoxDecoration(
                          color: isReplied
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFF3E0),
                          borderRadius:
                              BorderRadius.circular(ScreenAdapter.width(8)),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(24),
                            color: isReplied
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFFF9800),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ScreenAdapter.height(24)),
                  _buildInfoItem('所属科目', record['subject']),
                  SizedBox(height: ScreenAdapter.height(24)),
                  _buildInfoItem('提交时间', record['createTime']),
                  SizedBox(height: ScreenAdapter.height(32)),
                  // 详细描述
                  Text(
                    '问题描述',
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(28),
                      color: const Color(0xFF666666),
                    ),
                  ),
                  SizedBox(height: ScreenAdapter.height(12)),
                  Text(
                    record['description'],
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(30),
                      color: const Color(0xFF333333),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // 回复信息（如果有）
            if (isReplied) ...[
              SizedBox(height: ScreenAdapter.height(24)),
              Container(
                padding: EdgeInsets.all(ScreenAdapter.width(32)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(ScreenAdapter.width(16)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: ScreenAdapter.width(6),
                          height: ScreenAdapter.height(28),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3D7CFF),
                            borderRadius:
                                BorderRadius.circular(ScreenAdapter.width(3)),
                          ),
                        ),
                        SizedBox(width: ScreenAdapter.width(12)),
                        Text(
                          '官方回复',
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(32),
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ScreenAdapter.height(20)),
                    Text(
                      record['reply'],
                      style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(30),
                        color: const Color(0xFF333333),
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: ScreenAdapter.height(20)),
                    Text(
                      '回复时间：${record['replyTime']}',
                      style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(24),
                        color: const Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(28),
            color: const Color(0xFF666666),
          ),
        ),
        SizedBox(width: ScreenAdapter.width(24)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(28),
              color: const Color(0xFF333333),
            ),
          ),
        ),
      ],
    );
  }
}
