import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/screenAdapter.dart';
import '../../../components/common_empty_state.dart';
import '../../../components/customer_service_dialog.dart';
import '../../../data/providers/api_client.dart';
import '../../../data/services/auth_service.dart';
import '../controllers/my_orders_controller.dart';

class MyOrdersView extends GetView<MyOrdersController> {
  const MyOrdersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(
          '我的订单',
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(44),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF333333),
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
        if (controller.isLoading.value && controller.orderList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.orderList.isEmpty) {
          return const CommonEmptyState(
            icon: Icons.receipt_long_outlined,
            title: '暂无订单',
          );
        }

        return RefreshIndicator(
          onRefresh: controller.onRefresh,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenAdapter.width(24),
              vertical: ScreenAdapter.height(24),
            ),
            itemCount: controller.orderList.length,
            itemBuilder: (context, index) {
              final order = controller.orderList[index];
              return _OrderCard(order: order);
            },
          ),
        );
      }),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    // 从订单中提取课程信息
    final course = order['coures'] as Map<String, dynamic>? ?? {};
    final String title = course['title']?.toString() ?? '';

    // 从 teacher_list 拼接老师名称
    final teacherList = course['teacher_list'] as List? ?? [];
    String teacherName = '知知学堂';
    if (teacherList.isNotEmpty) {
      final names = teacherList
          .map((t) => t['name']?.toString())
          .whereType<String>()
          .toList();
      if (names.isNotEmpty) {
        teacherName = names.join('、');
      }
    }

    // 价格处理
    final double price =
        double.tryParse(course['price']?.toString() ?? '0') ?? 0;
    final bool isFree = course['is_free'] == 1 || price == 0;

    return GestureDetector(
      onTap: () => Get.toNamed('/order-detail', arguments: order),
      child: Container(
        margin: EdgeInsets.only(bottom: ScreenAdapter.height(24)),
        padding: EdgeInsets.all(ScreenAdapter.width(30)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ScreenAdapter.width(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 职场标签 + 标题
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenAdapter.width(12),
                      vertical: ScreenAdapter.height(4)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FF),
                    borderRadius: BorderRadius.circular(ScreenAdapter.width(8)),
                  ),
                  child: Text(
                    '职场',
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(42),
                      color: const Color(0xFF3D7CFF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: ScreenAdapter.width(16)),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(46),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF333333),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            SizedBox(height: ScreenAdapter.height(24)),

            // 生效时间
            _buildInfoRow(
                '生效时间：',
                order['start_time'] != null
                    ? _formatTimestamp(order['start_time'])
                    : '-'),

            SizedBox(height: ScreenAdapter.height(12)),

            // 授课老师
            _buildInfoRow('授课老师：', teacherName),

            SizedBox(height: ScreenAdapter.height(12)),

            // 课程价格
            _buildInfoRow('课程价格：', '${price.toStringAsFixed(2)} 元'),

            SizedBox(height: ScreenAdapter.height(24)),

            // 分割线
            Divider(height: 1, color: const Color(0xFFF0F0F0)),

            SizedBox(height: ScreenAdapter.height(20)),

            // 底部总计
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '共 1 项，总计：',
                  style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(36),
                    color: const Color(0xFF666666),
                  ),
                ),
                Text(
                  '${price.toStringAsFixed(2)} 元',
                  style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(38),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFF6B00),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(36),
              color: const Color(0xFF999999),
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(36),
              color: const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  /// 将时间戳格式化为 yyyy 年 MM 月 dd 日
  String _formatTimestamp(dynamic timestamp) {
    final int ts = int.tryParse(timestamp.toString()) ?? 0;
    if (ts == 0) return '-';
    final dt = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    return '${dt.year}年${dt.month.toString().padLeft(2, '0')}月${dt.day.toString().padLeft(2, '0')}日';
  }
}
