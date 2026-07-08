import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:dio/dio.dart' as dio_package;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../services/screenAdapter.dart';
import '../../../data/providers/api_client.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../../../components/common_dialog.dart';
import '../controllers/details_controller.dart';
import '../../../services/snackbar_utils.dart';
import '../../../components/customer_service_dialog.dart';

// 单个目录项组件
class CatalogItemWidget extends StatefulWidget {
  final dynamic item;
  final int index;
  final int level;
  final Function(dynamic) onTap;
  final bool isExpanded;
  final int selectedLessonId;
  final VoidCallback? onExpandToggle;

  const CatalogItemWidget({
    Key? key,
    required this.item,
    required this.index,
    required this.level,
    required this.onTap,
    required this.isExpanded,
    required this.selectedLessonId,
    this.onExpandToggle,
  }) : super(key: key);

  @override
  _CatalogItemWidgetState createState() => _CatalogItemWidgetState();
}

class _CatalogItemWidgetState extends State<CatalogItemWidget> {
  @override
  Widget build(BuildContext context) {
    final title = widget.item['title']?.toString() ?? '未知课程';

    final dynamic childrenList =
        widget.item['childlist'] ?? widget.item['children'];
    final bool hasChildren = childrenList is List && childrenList.isNotEmpty;

    // 父级章节：标题 + 右箭头，可展开收起
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 章节标题行
        GestureDetector(
          onTap: () {
            if (hasChildren && widget.onExpandToggle != null) {
              widget.onExpandToggle!();
            }
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              left: ScreenAdapter.width(32),
              right: ScreenAdapter.width(32),
              top: ScreenAdapter.height(36),
              bottom: ScreenAdapter.height(36),
            ),
            child: Row(
              children: [
                // 标题
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(32),
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
                // 右侧箭头
                Icon(Icons.chevron_right,
                    color: Color(0xFFCCCCCC), size: ScreenAdapter.fontSize(34)),
              ],
            ),
          ),
        ),

        // 标题下方浅灰色分割线
        if (widget.isExpanded && hasChildren)
          Container(
            height: 1,
            margin: EdgeInsets.symmetric(
              horizontal: ScreenAdapter.width(20),
            ),
            color: Color(0xFFEEEEEE),
          ),

        // 子级课程列表
        if (widget.isExpanded && hasChildren)
          ..._buildLessonRows(childrenList as List),
      ],
    );
  }

  /// 构建子级课程行列
  List<Widget> _buildLessonRows(List childrenList) {
    return childrenList.asMap().entries.map((entry) {
      return _buildLessonRow(entry.value, entry.key);
    }).toList();
  }

  /// 构建子级课程行：标题 + 上次学习标签 | 视频信息 | 播放按钮
  Widget _buildLessonRow(dynamic item, int index) {
    final lessonTitle = item['title']?.toString() ?? '未知课时';
    final lessonId = int.tryParse(item['id']?.toString() ?? '') ?? 0;
    final isSelected =
        widget.selectedLessonId > 0 && lessonId == widget.selectedLessonId;

    // 类型标签
    final typeStr = item['type_name']?.toString() ??
        item['type']?.toString()?.replaceAll('video', '视频') ??
        '视频';
    final displayType = typeStr == 'video' ? '视频' : typeStr;

    // 学习次数
    final studyCount = item['student_num']?.toString() ?? '0';

    // 上次播放进度（从 progress 对象中读取）
    final progress = item['progress'];
    final lastPlaySeconds =
        int.tryParse(progress?['last_position']?.toString() ?? '0') ?? 0;
    final duration =
        int.tryParse(progress?['duration']?.toString() ?? '0') ?? 0;
    // 学习进度百分比
    final progressPercent = (duration > 0 && lastPlaySeconds > 0)
        ? ((lastPlaySeconds / duration) * 100).toInt()
        : 0;
    final hasProgress = lastPlaySeconds > 0;

    // 是否显示"上次学习"标签（有进度时显示）
    final showLastStudyBadge = hasProgress;

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          widget.onTap(item);
        },
        child: Container(
          padding: EdgeInsets.only(
            left: ScreenAdapter.width(32),
            right: ScreenAdapter.width(24),
            top: ScreenAdapter.height(36),
            bottom: ScreenAdapter.height(36),
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 左侧：标题和信息
              Expanded(
                flex: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 第一行：标题
                    Text(
                      lessonTitle,
                      style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(30),
                        color:
                            isSelected ? Color(0xFF3D7CFF) : Color(0xFF333333),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: ScreenAdapter.height(20)),
                    // 第二行：视频 + 次数 + 进度
                    Row(
                      children: [
                        Text(
                          displayType,
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(24),
                            color: Color(0xFF999999),
                          ),
                        ),
                        SizedBox(width: ScreenAdapter.width(16)),
                        Text(
                          '$studyCount次学习',
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(24),
                            color: Color(0xFF999999),
                          ),
                        ),
                        if (hasProgress && progressPercent > 0) ...[
                          SizedBox(width: ScreenAdapter.width(16)),
                          Text(
                            '已学$progressPercent%',
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              color: Color(0xFF999999),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // 右侧：上次学习标签 + 播放按钮
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (showLastStudyBadge)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenAdapter.width(12),
                          vertical: ScreenAdapter.height(4),
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF3D7CFF),
                          borderRadius:
                              BorderRadius.circular(ScreenAdapter.width(6)),
                        ),
                        child: Text(
                          '上次学习',
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(20),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    if (showLastStudyBadge)
                      SizedBox(height: ScreenAdapter.height(8)),
                    GestureDetector(
                      onTap: () {
                        widget.onTap(item);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: ScreenAdapter.width(72),
                        height: ScreenAdapter.width(72),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Color(0xFF3D7CFF)
                                : Color(0xFFCCCCCC),
                            width: ScreenAdapter.width(2),
                          ),
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          size: ScreenAdapter.fontSize(36),
                          color: isSelected
                              ? Color(0xFF3D7CFF)
                              : Color(0xFF999999),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 目录列表容器，管理展开/折叠状态
class _CatalogListContent extends StatefulWidget {
  final List<dynamic> items;
  final Function(dynamic) onItemTap;
  final int selectedLessonId;

  const _CatalogListContent({
    required this.items,
    required this.onItemTap,
    required this.selectedLessonId,
  });

  @override
  State<_CatalogListContent> createState() => _CatalogListContentState();
}

class _CatalogListContentState extends State<_CatalogListContent> {
  int expandedIndex = 0; // 默认第一个展开

  @override
  void didUpdateWidget(covariant _CatalogListContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedLessonId != widget.selectedLessonId) {
      _expandSelectedChapter();
    }
  }

  void _expandSelectedChapter() {
    if (widget.selectedLessonId <= 0) return;

    final selectedChapterIndex =
        widget.items.indexWhere((item) => _containsLesson(item));
    if (selectedChapterIndex >= 0 && selectedChapterIndex != expandedIndex) {
      setState(() => expandedIndex = selectedChapterIndex);
    }
  }

  bool _containsLesson(dynamic item) {
    if (item is! Map) return false;

    final lessonId = int.tryParse(item['id']?.toString() ?? '') ?? 0;
    if (lessonId == widget.selectedLessonId) return true;

    final children = item['childlist'] ?? item['children'];
    if (children is List) {
      return children.any(_containsLesson);
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Center(
        child: Text(
          '暂无相关目录',
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(36),
            color: Color(0xFF999999),
          ),
        ),
      );
    }

    return Container(
      color: Color(0xFFF5F5F5),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenAdapter.width(32),
          vertical: ScreenAdapter.height(16),
        ),
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final isExpanded = index == expandedIndex;
          return Container(
            margin: EdgeInsets.only(bottom: ScreenAdapter.height(16)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ScreenAdapter.width(12)),
            ),
            child: CatalogItemWidget(
              item: widget.items[index],
              index: index,
              level: 0,
              onTap: widget.onItemTap,
              isExpanded: isExpanded,
              selectedLessonId: widget.selectedLessonId,
              onExpandToggle: () {
                setState(() {
                  if (isExpanded) {
                    expandedIndex = -1;
                  } else {
                    expandedIndex = index;
                  }
                });
              },
            ),
          );
        },
      ),
    );
  }
}

class DetailsView extends GetView<DetailsController> {
  const DetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 强制注册控制器，以防路由跳转时丢控制器
    if (!Get.isRegistered<DetailsController>()) {
      Get.put(DetailsController());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '学习目录',
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(46),
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.courseDetail.isEmpty) {
          return const Center(child: Text("加载失败或数据为空"));
        }

        return Column(
          children: [
            _buildVideoHeader(),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    _buildTabs(),
                    Expanded(
                      child: Obx(() {
                        if (controller.currentTabIndex.value == 0) {
                          return _buildIntroPage();
                        }
                        if (controller.currentTabIndex.value == 1) {
                          return _buildCatalogList();
                        }
                        return _buildMaterialsList();
                      }),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomButton(context),
          ],
        );
      }),
    );
  }

  Widget _buildTabs() {
    final selectedIndex = controller.currentTabIndex.value;
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildTabOption('介绍', 0, selectedIndex == 0),
          _buildTabOption('目录', 1, selectedIndex == 1),
          _buildTabOption('资料', 2, selectedIndex == 2),
        ],
      ),
    );
  }

  Widget _buildTabOption(String text, int index, bool selected,
      {String? suffix}) {
    final label = suffix != null && suffix.isNotEmpty ? '$text $suffix' : text;
    final textStyle = TextStyle(
      fontSize: ScreenAdapter.fontSize(40),
      fontWeight: selected ? FontWeight.w500 : FontWeight.w500,
      color: selected ? Color(0xFF333333) : Color(0xFF999999),
    );

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => controller.switchTab(index),
        child: SizedBox(
          height: ScreenAdapter.height(120),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final textSpan = TextSpan(text: label, style: textStyle);
              final painter =
                  TextPainter(text: textSpan, textDirection: TextDirection.ltr)
                    ..layout();
              final textWidth = painter.width;
              painter.dispose();
              final lineLeft = (constraints.maxWidth - textWidth) / 2;

              return Stack(
                children: [
                  Center(child: Text(label, style: textStyle)),
                  if (selected)
                    Positioned(
                      left: lineLeft,
                      bottom: 0,
                      width: textWidth,
                      height: ScreenAdapter.height(3),
                      child: Container(color: Color(0xFF3D7CFF)),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// 底部按钮：免费显示"立即订阅"，付费显示"立即购买"
  Widget _buildBottomButton(BuildContext context) {
    final detail = controller.courseDetail;
    final bool isFree = detail['is_free']?.toString() == '1';
    final bool isPay =
        detail['is_pay']?.toString() == '1' || detail['is_pay'] == true;
    final String buttonText =
        isFree || AuthService.to.isMember ? '立即订阅' : '立即购买';
    // 已支付时显示的文案和禁用状态
    final String disabledText = isFree ? '已订阅' : '已购买';

    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: ScreenAdapter.width(32),
          vertical: ScreenAdapter.height(20),
        ),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: isPay
              ? null
              : () async {
                  if (isFree || AuthService.to.isMember) {
                    // 免费课程或会员：弹出确认订阅弹窗
                    final confirmed = await CommonDialog.show(
                      title: '提示',
                      content: '确定要订阅该课程吗？',
                      confirmText: '确认',
                      cancelText: '取消',
                    );
                    if (!confirmed) return;

                    // 用户确认后调用订阅接口
                    final courseId = detail['id']?.toString();
                    if (courseId != null && courseId.isNotEmpty) {
                      try {
                        final response = await ApiClient.to.exam(
                          'pay/redeem',
                          method: 'POST',
                          data: {'course_id': courseId},
                        );
                        if (response.statusCode == 200) {
                          final data = response.data;
                          if (data is Map &&
                              (data['code'] == 1 || data['code'] == 200)) {
                            SnackbarUtils.showSuccess('订阅成功');
                            // 刷新当前页面状态
                            controller.getCourseDetail(
                              int.tryParse(courseId) ?? 0,
                            );
                          } else {
                            SnackbarUtils.showError(
                                data['msg']?.toString() ?? '订阅失败');
                          }
                        } else {
                          SnackbarUtils.showError('订阅失败');
                        }
                      } catch (e) {
                        SnackbarUtils.showError('订阅失败：$e');
                      }
                    }
                    return;
                  }
                  // 非会员付费课程：跳转到确认下单页面
                  Get.toNamed(Routes.ORDER_CONFIRM, arguments: detail);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: isPay ? Color(0xFFCCCCCC) : Color(0xFF3D9EFF),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: ScreenAdapter.height(28)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ScreenAdapter.width(16)),
            ),
            elevation: 0,
          ),
          child: Text(
            isPay ? disabledText : buttonText,
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(34),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// 显示购买弹窗（含收货信息 + 支付方式选择）
  void _showPurchaseDialog(BuildContext context) {
    String selectedPayment = 'wechat'; // 默认微信支付
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ScreenAdapter.width(28)),
              ),
              child: Container(
                width: ScreenAdapter.width(1100),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(ScreenAdapter.width(28)),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenAdapter.width(40),
                  vertical: ScreenAdapter.height(40),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 标题
                    Text(
                      '兑换收货信息',
                      style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(40),
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: ScreenAdapter.height(40)),

                    // 收货人
                    _buildInfoInputRow('收货人', nameController),
                    SizedBox(height: ScreenAdapter.height(48)),

                    // 手机号码
                    _buildInfoInputRow('手机号码', phoneController,
                        keyboardType: TextInputType.phone),
                    SizedBox(height: ScreenAdapter.height(48)),

                    // 收货地址
                    _buildInfoInputRow('收货地址', addressController),
                    SizedBox(height: ScreenAdapter.height(48)),

                    // 支付方式选择
                    _buildPaymentSelector(selectedPayment, (value) {
                      setState(() => selectedPayment = value);
                    }),
                    SizedBox(height: ScreenAdapter.height(40)),

                    // 按钮行
                    Row(
                      children: [
                        // 取消按钮
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Color(0xFF3D7CFF),
                              side: BorderSide(
                                  color: Color(0xFF3D7CFF), width: 1),
                              padding: EdgeInsets.symmetric(
                                vertical: ScreenAdapter.height(24),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    ScreenAdapter.width(8)),
                              ),
                            ),
                            child: Text(
                              '取消',
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(30),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: ScreenAdapter.width(24)),
                        // 确认购买按钮
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              String paymentName =
                                  selectedPayment == 'wechat' ? '微信' : '支付宝';
                              SnackbarUtils.showInfo('已选择$paymentName支付');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF3D7CFF),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: ScreenAdapter.height(24),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    ScreenAdapter.width(8)),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              '确认购买',
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(30),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 信息行组件
  Widget _buildInfoRowItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: ScreenAdapter.width(160),
          child: Text(
            label,
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(34),
              color: Color(0xFF666666),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(34),
              color: Color(0xFF333333),
            ),
          ),
        ),
      ],
    );
  }

  /// 可输入信息行组件
  Widget _buildInfoInputRow(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: ScreenAdapter.width(160),
          child: Text(
            label,
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(34),
              color: Color(0xFF333333),
            ),
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(32),
              color: Color(0xFF333333),
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: ScreenAdapter.width(16),
                vertical: ScreenAdapter.height(12),
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFF5F5F5), width: 1),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFF5F5F5), width: 1),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF3D7CFF), width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 支付方式选择组件
  Widget _buildPaymentSelector(
      String selectedValue, ValueChanged<String> onChanged) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '支付方式',
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(34),
            color: Color(0xFF333333),
          ),
        ),
        SizedBox(width: ScreenAdapter.width(80)),
        // 微信支付
        _buildPaymentOption(
          svgPath: 'assets/fonts/wechat.svg',
          label: '微信',
          isSelected: selectedValue == 'wechat',
          onTap: () => onChanged('wechat'),
        ),
        SizedBox(width: ScreenAdapter.width(24)),
        // 支付宝支付
        _buildPaymentOption(
          svgPath: 'assets/fonts/zhifubao.svg',
          label: '支付宝',
          isSelected: selectedValue == 'alipay',
          onTap: () => onChanged('alipay'),
        ),
      ],
    );
  }

  /// 单个支付选项
  Widget _buildPaymentOption({
    required String svgPath,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenAdapter.width(28),
          vertical: ScreenAdapter.height(20),
        ),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFEBF2FF) : Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(ScreenAdapter.width(12)),
          border: Border.all(
            color: isSelected ? Color(0xFF3D7CFF) : Color(0xFFE0E0E0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              svgPath,
              width: ScreenAdapter.width(40),
              height: ScreenAdapter.height(40),
            ),
            SizedBox(width: ScreenAdapter.width(12)),
            Text(
              label,
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(34),
                color: isSelected ? Color(0xFF3D7CFF) : Color(0xFF333333),
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            if (isSelected) ...[
              SizedBox(width: ScreenAdapter.width(8)),
              Icon(
                Icons.check_circle,
                size: ScreenAdapter.fontSize(30),
                color: Color(0xFF3D7CFF),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 介绍页面
  Widget _buildIntroPage() {
    final detail = controller.courseDetail;
    final String title = detail['title']?.toString() ?? '';
    final String description = detail['description']?.toString() ??
        detail['intro']?.toString() ??
        detail['content']?.toString() ??
        '';
    final String courseType = detail['category_name']?.toString() ??
        detail['cate_name']?.toString() ??
        detail['type_name']?.toString() ??
        '未分类';
    final int difficulty =
        int.tryParse(detail['difficulty']?.toString() ?? '0') ?? 0;
    final bool isFree = detail['is_free']?.toString() == '1';
    final String price = isFree ? '免费' : '${detail['price']}';
    final String originalPrice = detail['original_price']?.toString() ?? '';
    final int totalLessons =
        int.tryParse(detail['total_lessons']?.toString() ?? '0') ?? 0;
    final int students =
        int.tryParse(detail['total_students']?.toString() ?? '0') ?? 0;

    // 难度文字映射
    String difficultyText;
    switch (difficulty) {
      case 1:
        difficultyText = '入门';
        break;
      case 2:
        difficultyText = '初级';
        break;
      case 3:
        difficultyText = '中级';
        break;
      case 4:
        difficultyText = '高级';
        break;
      default:
        difficultyText = '中级';
        break;
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenAdapter.width(32),
        vertical: ScreenAdapter.height(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 课程标题
          if (title.isNotEmpty)
            Text(
              title,
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(44),
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),

          SizedBox(height: ScreenAdapter.height(16)),

          // 副标题/描述
          if (description.isNotEmpty)
            Text(
              description,
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(30),
                color: Color(0xFF999999),
              ),
            ),

          SizedBox(height: ScreenAdapter.height(32)),

          // 信息卡片
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(ScreenAdapter.width(16)),
            ),
            child: Column(
              children: [
                _infoRow('课程类型', courseType, showDivider: true),
                _infoRow('难度', difficultyText, showDivider: true),
                _infoRow('价格',
                    '¥$price${originalPrice.isNotEmpty ? '   ¥$originalPrice' : ''}',
                    highlightPrice: true, showDivider: true),
                _infoRow('总课时', '$totalLessons', showDivider: true),
                _infoRow('学员', students > 0 ? '$students' : '--',
                    showDivider: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 信息行（带分隔线）
  Widget _infoRow(String label, String value,
      {bool highlightPrice = false, bool showDivider = true}) {
    return Container(
      decoration: showDivider
          ? BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Color(0xFFF5F5F5), width: 1)),
            )
          : null,
      padding: EdgeInsets.symmetric(
        vertical: ScreenAdapter.height(36),
        horizontal: ScreenAdapter.width(32),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(32),
              color: Color(0xFF666666),
            ),
          ),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: RichText(
                text: TextSpan(
                  children: _parsePriceText(value, highlightPrice),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _parsePriceText(String value, bool highlightPrice) {
    if (!highlightPrice || !value.contains('¥')) {
      return [
        TextSpan(
            text: value,
            style: TextStyle(
                fontSize: ScreenAdapter.fontSize(32), color: Color(0xFF333333)))
      ];
    }
    // 解析 "¥价格   ¥原价" 格式
    final parts = value.split(RegExp(r'\s+'));
    final spans = <TextSpan>[];
    for (var part in parts) {
      if (part.startsWith('¥')) {
        final isFirst = spans.isEmpty;
        spans.add(TextSpan(
          text: '$part ',
          style: TextStyle(
            fontSize: isFirst
                ? ScreenAdapter.fontSize(38)
                : ScreenAdapter.fontSize(30),
            color: isFirst ? Color(0xFFFF4D4F) : Color(0xFF999999),
            fontWeight: isFirst ? FontWeight.w500 : FontWeight.normal,
            decoration: !isFirst ? TextDecoration.lineThrough : null,
            decorationColor: !isFirst ? Color(0xFF999999) : null,
          ),
        ));
      } else {
        spans.add(TextSpan(
            text: '$part ',
            style: TextStyle(
                fontSize: ScreenAdapter.fontSize(32),
                color: Color(0xFF333333))));
      }
    }
    return spans;
  }

  /// 目录页面：课程列表
  Widget _buildCatalogList() {
    return _buildCatalogContent();
  }

  /// 目录列表内容
  Widget _buildCatalogContent() {
    return _CatalogListContent(
      items: controller.courseItems,
      onItemTap: (item) => controller.playCourseItem(item),
      selectedLessonId: controller.currentPlayingLessonId.value,
    );
  }

  List<dynamic> _getMaterialsList() {
    final detail = controller.courseDetail;
    final dynamic v = detail['materials'] ??
        detail['material'] ??
        detail['files'] ??
        detail['file_list'] ??
        detail['attachments'] ??
        detail['resources'];
    return v is List ? v : const [];
  }

  Widget _buildMaterialsList() {
    final materials = _getMaterialsList();
    if (materials.isEmpty) {
      return Center(
        child: Text(
          '暂无相关资料',
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(36),
            color: Color(0xFF999999),
          ),
        ),
      );
    }

    return Container(
      color: Color(0xFFF5F5F5),
      padding: EdgeInsets.symmetric(vertical: ScreenAdapter.height(20)),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenAdapter.width(40),
        ),
        itemCount: materials.length,
        itemBuilder: (context, index) {
          final item = materials[index];
          final name = (item is Map
                  ? (item['name'] ??
                      item['title'] ??
                      item['filename'] ??
                      item['file_name'])
                  : null)
              ?.toString();
          final urlRaw = (item is Map
                  ? (item['url'] ??
                      item['file_url'] ??
                      item['fileurl'] ??
                      item['path'] ??
                      item['download_url'] ??
                      item['downloadurl'] ??
                      item['src'] ??
                      item['href'] ??
                      item['link'] ??
                      item['file_path'])
                  : null)
              ?.toString();
          final size = (item is Map
                  ? (item['size'] ??
                      item['file_size'] ??
                      item['filesize'] ??
                      item['fileSize'])
                  : null)
              ?.toString();

          final safeName = (name == null || name.isEmpty) ? '未知文件' : name;
          final safeUrl = urlRaw == null ? '' : ApiClient.replaceUri(urlRaw);
          final safeSize = (size == null || size.isEmpty) ? '' : size;

          // 解析文件扩展名
          String ext = '';
          if (safeName.contains('.')) {
            ext = safeName.split('.').last.toLowerCase();
          } else if (safeUrl.isNotEmpty) {
            final withoutQuery = safeUrl.split('?').first;
            final withoutHash = withoutQuery.split('#').first;
            if (withoutHash.contains('.')) {
              ext = withoutHash.split('.').last.toLowerCase();
            }
          }
          final extLabel = ext.isNotEmpty ? ext.toUpperCase() : 'FILE';

          return Container(
            margin: EdgeInsets.only(bottom: ScreenAdapter.height(16)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ScreenAdapter.width(12)),
              border: Border.all(color: Color(0xFFEEEEEE), width: 1),
            ),
            child: InkWell(
              onTap: () => _showMaterialActionSheet(
                name: safeName,
                url: safeUrl,
                size: safeSize,
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: ScreenAdapter.width(32),
                  right: ScreenAdapter.width(32),
                  top: ScreenAdapter.height(38),
                  bottom: ScreenAdapter.height(38),
                ),
                child: Row(
                  children: [
                    // 左侧文档图标（蓝色圆角方形）
                    Container(
                      width: ScreenAdapter.width(64),
                      height: ScreenAdapter.width(64),
                      decoration: BoxDecoration(
                        color: Color(0xFFE8F0FF),
                        borderRadius:
                            BorderRadius.circular(ScreenAdapter.width(14)),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/fonts/text.svg',
                          width: ScreenAdapter.width(36),
                          height: ScreenAdapter.width(36),
                          colorFilter: ColorFilter.mode(
                              Color(0xFF3D7CFF), BlendMode.srcIn),
                        ),
                      ),
                    ),
                    SizedBox(width: ScreenAdapter.width(24)),
                    // 标题
                    Expanded(
                      child: Text(
                        safeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(40),
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    // 右侧更多按钮
                    GestureDetector(
                      onTap: () => _showMaterialActionSheet(
                        name: safeName,
                        url: safeUrl,
                        size: safeSize,
                      ),
                      behavior: HitTestBehavior.opaque,
                      child: Icon(
                        Icons.more_horiz,
                        color: Color(0xFFCCCCCC),
                        size: ScreenAdapter.fontSize(34),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showMaterialActionSheet({
    required String name,
    required String url,
    required String size,
  }) {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _actionItem('预览', () {
                Get.back();
                _openPdfPreview(url, name);
              }),
              Divider(height: 1, color: Color(0xFFEEEEEE)),
              _actionItem(size.isEmpty || size == '0' ? '下载' : '下载 ($size)',
                  () {
                Get.back();
                _downloadAndOpen(url, name);
              }),
              Divider(height: 1, color: Color(0xFFEEEEEE)),
              _actionItem('复制下载链接', () async {
                Get.back();
                await Clipboard.setData(ClipboardData(text: url));
                SnackbarUtils.showSuccess('链接已复制');
              }),
              Container(
                height: ScreenAdapter.height(34),
                color: Color(0xFFF5F5F5),
              ),
              _actionItem('取消', () => Get.back()),
            ],
          ),
        ),
      ),
      isScrollControlled: false,
    );
  }

  /// 应用内预览PDF
  Future<void> _openPdfPreview(String url, String name) async {
    if (url.isEmpty) {
      SnackbarUtils.showError('文件地址无效');
      return;
    }

    Get.dialog(
      Center(
        child: Container(
          padding: EdgeInsets.all(ScreenAdapter.width(40)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(ScreenAdapter.width(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: ScreenAdapter.height(20)),
              Text('正在加载文档...'),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final localPath = await _downloadToLocal(url, name);
      Get.back();
      if (localPath == null) return;
      Get.to(() =>
          _PdfPreviewPage(filePath: localPath, title: name, originalUrl: url));
    } catch (e) {
      Get.back();
      SnackbarUtils.showError('预览失败: ${e.toString()}');
    }
  }

  /// 跳转浏览器下载
  Future<void> _downloadAndOpen(String url, String name) async {
    if (url.isEmpty) {
      SnackbarUtils.showError('文件地址无效');
      return;
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      SnackbarUtils.showError('无法打开下载链接');
    }
  }

  /// 下载文件到本地（供预览使用）
  Future<String?> _downloadToLocal(String url, String name) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/$name';

      if (await File(savePath).exists()) return savePath;

      final dio = dio_package.Dio();
      await dio.download(url, savePath);

      return savePath;
    } catch (e) {
      debugPrint('下载失败: $e');
      return null;
    }
  }

  Widget _actionItem(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: ScreenAdapter.height(42)),
        color: Colors.white,
        child: Text(
          title,
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(44),
            color: Color(0xFF333333),
          ),
        ),
      ),
    );
  }

  /// 构建顶部视频区域（支持在封面图内播放视频）
  Widget _buildVideoHeader() {
    final detail = controller.courseDetail;
    final String coverImage = detail['cover_image_url']?.toString() ??
        detail['cover_image']?.toString() ??
        '';
    final String title = detail['title']?.toString() ?? '课程名称';

    return Container(
      width: double.infinity,
      height: ScreenAdapter.height(600),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 视频播放器（如果有）
          Obx(() {
            final chewieCtrl = controller.chewieController.value;
            if (chewieCtrl != null) {
              return Chewie(
                controller: chewieCtrl,
              );
            }
            return const SizedBox.shrink();
          }),

          // 封面图或默认渐变（视频未播放时显示）
          Obx(() {
            if (controller.chewieController.value == null) {
              return coverImage.isNotEmpty
                  ? Image.network(
                      ApiClient.replaceUri(coverImage),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildDefaultCover(),
                    )
                  : _buildDefaultCover();
            }
            return const SizedBox.shrink();
          }),

          // 渐变遮罩（仅封面图显示时显示）
          Obx(() {
            if (controller.chewieController.value == null) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // 右上角分享按钮（已隐藏）
          // Positioned(
          //   top: ScreenAdapter.height(40),
          //   right: ScreenAdapter.width(32),
          //   child: GestureDetector(
          //     onTap: () => SnackbarUtils.showInfo('分享功能'),
          //     child: Container(
          //       padding: EdgeInsets.symmetric(
          //         horizontal: ScreenAdapter.width(24),
          //         vertical: ScreenAdapter.height(12),
          //       ),
          //       decoration: BoxDecoration(
          //         color: Colors.white.withOpacity(0.9),
          //         borderRadius: BorderRadius.circular(ScreenAdapter.width(30)),
          //       ),
          //       child: Row(
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           Icon(Icons.share,
          //               size: ScreenAdapter.fontSize(28),
          //               color: Color(0xFF333333)),
          //           SizedBox(width: ScreenAdapter.width(4)),
          //           Text('分享',
          //               style: TextStyle(
          //                   fontSize: ScreenAdapter.fontSize(26),
          //                   color: Color(0xFF333333))),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),

          // 右上角倍速选择按钮（视频播放时显示）
          Obx(() {
            if (controller.chewieController.value != null) {
              return Positioned(
                top: ScreenAdapter.height(40),
                left: ScreenAdapter.width(32),
                child: Builder(
                  builder: (ctx) => _buildSpeedSelector(ctx),
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // 标题文字叠加在左下角
          Obx(() {
            if (controller.chewieController.value == null) {
              return Positioned(
                left: ScreenAdapter.width(32),
                bottom: ScreenAdapter.height(32),
                right: ScreenAdapter.width(100),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(52),
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.black45, blurRadius: 8),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  /// 构建倍速选择按钮
  Widget _buildSpeedSelector(BuildContext context) {
    return Obx(() {
      final speed = controller.currentSpeed.value;
      return GestureDetector(
        onTap: () => _showSpeedPicker(context),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenAdapter.width(20),
            vertical: ScreenAdapter.height(8),
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(ScreenAdapter.width(20)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.speed,
                  size: ScreenAdapter.fontSize(28), color: Colors.white),
              SizedBox(width: ScreenAdapter.width(4)),
              Text(
                '${speed}x',
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(26),
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// 显示倍速选择面板
  void _showSpeedPicker(BuildContext context) {
    final speeds = controller.playbackSpeeds;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ScreenAdapter.width(24)),
            ),
          ),
          padding: EdgeInsets.symmetric(
            vertical: ScreenAdapter.height(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题栏
              Padding(
                padding: EdgeInsets.only(bottom: ScreenAdapter.height(20)),
                child: Text(
                  '播放速度',
                  style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(34),
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              Divider(height: 1, color: Color(0xFFEEEEEE)),
              // 倍速选项列表
              ...speeds.map((speed) {
                final isSelected = speed == controller.currentSpeed.value;
                return InkWell(
                  onTap: () {
                    Navigator.pop(sheetContext);
                    controller.setPlaybackSpeed(speed);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: ScreenAdapter.height(28),
                      horizontal: ScreenAdapter.width(48),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${speed}x',
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(34),
                            color: isSelected
                                ? Color(0xFF3D7CFF)
                                : Color(0xFF333333),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        if (isSelected) ...[
                          SizedBox(width: ScreenAdapter.width(8)),
                          Icon(Icons.check,
                              size: ScreenAdapter.fontSize(30),
                              color: Color(0xFF3D7CFF)),
                        ],
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(height: ScreenAdapter.height(20)),
              // 安全区域
            ],
          ),
        );
      },
    );
  }

  /// 默认红色渐变封面
  Widget _buildDefaultCover() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD4363C), Color(0xFFB01F24)],
        ),
      ),
    );
  }
}

/// 应用内PDF预览页面（WebView + PDF.js 渲染）
class _PdfPreviewPage extends StatefulWidget {
  final String filePath;
  final String title;

  /// 原始网络URL
  final String? originalUrl;

  const _PdfPreviewPage({
    required this.filePath,
    required this.title,
    this.originalUrl,
  });

  @override
  State<_PdfPreviewPage> createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<_PdfPreviewPage> {
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => isLoading = true),
          onPageFinished: (_) => setState(() => isLoading = false),
          onWebResourceError: (error) {
            setState(() => isLoading = false);
          },
        ),
      );

    // 使用 PDF.js（国内CDN）渲染PDF
    final pdfUrl = widget.originalUrl ?? widget.filePath;
    final html = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=no">
  <script src="https://cdn.bootcdn.net/ajax/libs/pdf.js/3.11.174/pdf.min.js"></script>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { background: #525659; }
    #toolbar { position:fixed;top:0;left:0;right:0;height:44px;background:#292b2e;color:#fff;display:flex;align-items:center;padding:0 12px;z-index:100;font-size:14px; }
    #toolbar span { flex:1;text-align:center; }
    #canvas-container { margin-top:44px;display:flex;justify-content:center;overflow:auto;height:calc(100vh - 44px); }
    canvas { display: block; }
  </style>
</head>
<body>
  <div id="toolbar"><span id="page-num"></span></div>
  <div id="canvas-container"><canvas id="pdf-canvas"></canvas></div>
  <script>
    pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdn.bootcdn.net/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js';
    var url = '$pdfUrl';
    var pdfDoc = null, pageNum = 1, pageRendering = false, pageNumPending = null, scale = 1.5;
    var canvas = document.getElementById('pdf-canvas'), ctx = canvas.getContext('2d');

    function renderPage(num) {
      pageRendering = true;
      pdfDoc.getPage(num).then(function(page) {
        var viewport = page.getViewport({ scale: scale });
        canvas.height = viewport.height;
        canvas.width = viewport.width;
        var renderContext = { canvasContext: ctx, viewport: viewport };
        page.render(renderContext).promise.then(function() {
          pageRendering = false;
          document.getElementById('page-num').textContent = num + ' / ' + pdfDoc.numPages;
          if (pageNumPending !== null) { renderPage(pageNumPending); pageNumPending = null; }
        });
      });
    }

    function queueRenderPage(num) {
      if (pageRendering) { pageNumPending = num; } else { renderPage(num); }
    }

    function onNextPage() { if (pageNum >= pdfDoc.numPages) return; pageNum++; queueRenderPage(pageNum); }
    function onPrevPage() { if (pageNum <= 1) return; pageNum--; queueRenderPage(pageNum); }

    pdfjsLib.getDocument(url).promise.then(function(pdf) {
      pdfDoc = pdf;
      document.getElementById('page-num').textContent = '1 / ' + pdf.numPages;
      renderPage(pageNum);
    }).catch(function(err) { console.error(err); });

    canvas.addEventListener('click', function(e) { var rect = canvas.getBoundingClientRect(); if (e.clientX - rect.left > rect.width / 2) { onNextPage(); } else { onPrevPage(); } });
    canvas.style.cursor = 'pointer';
  </script>
</body>
</html>''';

    _controller.loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF333333),
        elevation: 0.5,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading) Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
