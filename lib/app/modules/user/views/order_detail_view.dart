import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/screenAdapter.dart';
import '../controllers/order_detail_controller.dart';

class OrderDetailView extends GetView<OrderDetailController> {
  const OrderDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Obx(() => _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    final order = controller.order.value;
    if (order == null || order.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final course = order['coures'] as Map<String, dynamic>? ?? {};
    final String title = course['title']?.toString() ?? '';
    final String statusText = order['order_status_text']?.toString() ?? '已完成';
    final String startTime = _formatTimestamp(order['start_time']);
    final String endTime = _formatTimestamp(order['end_time']);

    // 授课老师
    final teacherList = course['teacher_list'] as List? ?? [];
    String teacherName = '知知学堂';
    if (teacherList.isNotEmpty) {
      final names = teacherList
          .map((t) => t['name']?.toString())
          .whereType<String>()
          .toList();
      if (names.isNotEmpty) teacherName = names.join('、');
    }

    // 价格
    final double price =
        double.tryParse(course['price']?.toString() ?? '0') ?? 0;

    // 订单信息
    final String payTime = order['payment_time_text']?.toString() ??
        _formatFullTimestamp(order['paytime']);
    final String payMethod = price == 0 || course['is_free'] == 1
        ? '免费兑换'
        : (order['pay_type_text']?.toString() ?? '-');
    final String orderNo = order['order_no']?.toString() ?? '';

    return CustomScrollView(
      slivers: [
        // 顶部蓝色区域 + 状态
        SliverAppBar(
          expandedHeight: ScreenAdapter.height(280),
          pinned: true,
          backgroundColor: const Color(0xFF3D7CFF),
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,
                color: Colors.white, size: ScreenAdapter.fontSize(44)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            titlePadding: EdgeInsets.only(
              bottom: ScreenAdapter.height(60),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: ScreenAdapter.fontSize(40),
                  color: Colors.white,
                ),
                SizedBox(width: ScreenAdapter.width(10)),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(36),
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 内容区
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenAdapter.width(24),
              vertical: ScreenAdapter.height(24),
            ),
            child: Column(
              children: [
                // 课程信息卡片
                _CourseInfoCard(
                  title: title,
                  startTime: startTime,
                  endTime: endTime,
                  teacherName: teacherName,
                  price: price,
                ),
                SizedBox(height: ScreenAdapter.height(20)),

                // 付款信息卡片
                _PaymentInfoCard(price: price),
                SizedBox(height: ScreenAdapter.height(20)),

                // 订单信息卡片
                _OrderInfoCard(
                  payTime: payTime,
                  payMethod: payMethod,
                  orderNo: orderNo,
                  onCopy: () => controller.copyOrderNo(orderNo),
                ),
                SizedBox(height: ScreenAdapter.height(20)),

                // // 支付协议链接
                // GestureDetector(
                //   onTap: () {},
                //   child: Text(
                //     '《知知知学堂支付协议》',
                //     style: TextStyle(
                //       fontSize: ScreenAdapter.fontSize(28),
                //       color: const Color(0xFF3D7CFF),
                //       decoration: TextDecoration.underline,
                //     ),
                //   ),
                // ),
                // SizedBox(height: ScreenAdapter.height(40)),

                // 客服电话
                // Text(
                //   '客服电话：400-075-9866',
                //   style: TextStyle(
                //     fontSize: ScreenAdapter.fontSize(28),
                //     color: const Color(0xFF999999),
                //   ),
                // ),
                // SizedBox(height: ScreenAdapter.height(60)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 课程信息卡片
class _CourseInfoCard extends StatelessWidget {
  final String title;
  final String startTime;
  final String endTime;
  final String teacherName;
  final double price;

  const _CourseInfoCard({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.teacherName,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  vertical: ScreenAdapter.height(4),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FF),
                  borderRadius: BorderRadius.circular(ScreenAdapter.width(8)),
                ),
                child: Text(
                  '职场',
                  style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(26),
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
                    fontSize: ScreenAdapter.fontSize(34),
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

          _infoRow('开课时间：', '$startTime-$endTime'),
          SizedBox(height: ScreenAdapter.height(12)),
          _infoRow('授课老师：', teacherName),
          SizedBox(height: ScreenAdapter.height(12)),
          _infoRow('课程价格：', '${price.toStringAsFixed(2)} 元'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(28),
              color: const Color(0xFF999999),
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(28),
              color: const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }
}

/// 付款信息卡片
class _PaymentInfoCard extends StatelessWidget {
  final double price;

  const _PaymentInfoCard({required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenAdapter.width(30)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ScreenAdapter.width(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '付款信息',
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(34),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ),
          ),
          SizedBox(height: ScreenAdapter.height(28)),
          _paymentRow('购买数量', '1 件'),
          SizedBox(height: ScreenAdapter.height(16)),
          _paymentRow('商品总额', '${price.toStringAsFixed(2)} 元'),
          SizedBox(height: ScreenAdapter.height(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '实付金额',
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(30),
                  color: const Color(0xFF666666),
                ),
              ),
              Text(
                '${price.toStringAsFixed(2)} 元',
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(32),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFF6B00),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paymentRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(30),
            color: const Color(0xFF666666),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(30),
            color: const Color(0xFF333333),
          ),
        ),
      ],
    );
  }
}

/// 订单信息卡片
class _OrderInfoCard extends StatelessWidget {
  final String payTime;
  final String payMethod;
  final String orderNo;
  final VoidCallback onCopy;

  const _OrderInfoCard({
    required this.payTime,
    required this.payMethod,
    required this.orderNo,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenAdapter.width(30)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ScreenAdapter.width(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '订单信息',
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(34),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ),
          ),
          SizedBox(height: ScreenAdapter.height(28)),
          _orderRow('付款时间', payTime),
          SizedBox(height: ScreenAdapter.height(16)),
          _orderRow('支付方式', payMethod),
          SizedBox(height: ScreenAdapter.height(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '交易单号',
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(30),
                  color: const Color(0xFF666666),
                ),
              ),
              GestureDetector(
                onTap: onCopy,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '复制 ',
                      style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(28),
                        color: const Color(0xFFFF6B00),
                      ),
                    ),
                    Text(
                      orderNo,
                      style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(28),
                        color: const Color(0xFFFF6B00),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _orderRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(30),
            color: const Color(0xFF666666),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(30),
              color: const Color(0xFF333333),
            ),
          ),
        ),
      ],
    );
  }
}

/// 时间戳转 yyyy 年 MM 月 dd 日
String _formatTimestamp(dynamic ts) {
  final int t = int.tryParse(ts.toString()) ?? 0;
  if (t == 0) return '-';
  final dt = DateTime.fromMillisecondsSinceEpoch(t * 1000);
  return '${dt.year}年${dt.month.toString().padLeft(2, '0')}月${dt.day.toString().padLeft(2, '0')}日';
}

/// 时间戳转完整日期时间
String _formatFullTimestamp(dynamic ts) {
  final int t = int.tryParse(ts.toString()) ?? 0;
  if (t == 0) return '-';
  final dt = DateTime.fromMillisecondsSinceEpoch(t * 1000);
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
}
