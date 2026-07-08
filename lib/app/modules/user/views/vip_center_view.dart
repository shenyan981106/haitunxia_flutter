import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/screenAdapter.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/providers/api_client.dart';
import '../../../services/snackbar_utils.dart';
import '../../../components/common_dialog.dart';
import '../controllers/vip_center_controller.dart';

class VipCenterView extends GetView<VipCenterController> {
  const VipCenterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenAdapter.width(30),
                  vertical: ScreenAdapter.height(20),
                ),
                children: [
                  _buildPrivilegeSection(),
                  SizedBox(height: ScreenAdapter.height(20)),
                  _buildPlansSection(),
                  SizedBox(height: ScreenAdapter.height(40)),
                  _buildBottomButton(),
                  SizedBox(height: ScreenAdapter.height(20)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final backgroundHeight = ScreenAdapter.height(400);
    final cardHeight = ScreenAdapter.height(400);
    final cardWidth = ScreenAdapter.width(1000);
    final headerHeight = backgroundHeight + cardHeight * 0.5;

    return SizedBox(
      height: headerHeight,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: backgroundHeight,
            padding: EdgeInsets.fromLTRB(
              ScreenAdapter.width(20),
              ScreenAdapter.height(10),
              ScreenAdapter.width(20),
              ScreenAdapter.height(20),
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF151A2F), Color(0xFF11121F)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(ScreenAdapter.width(40)),
                bottomRight: Radius.circular(ScreenAdapter.width(40)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          '会员中心',
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(46),
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: ScreenAdapter.width(80),
                    ),
                  ],
                ),
                SizedBox(height: ScreenAdapter.height(26)),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: _buildVipInfoCard(),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVipInfoCard() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF27324A), Color(0xFF1F2638)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(
          ScreenAdapter.width(34),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.35),
            blurRadius: 50,
            spreadRadius: 2,
            offset: Offset(0, ScreenAdapter.height(30)),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: ScreenAdapter.width(36),
            bottom: ScreenAdapter.height(26),
            child: Icon(
              Icons.emoji_events,
              size: ScreenAdapter.width(360),
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenAdapter.width(40),
              vertical: ScreenAdapter.height(36),
            ),
            child: _buildVipInfoContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildVipInfoContent() {
    final info = AuthService.to.user.value?.toJson();
    final isLoggedIn = AuthService.to.isLoggedIn.value;
    final displayName = isLoggedIn
        ? (info?['nickname']?.toString() ??
            info?['username']?.toString() ??
            '未登录用户')
        : '未登录用户';
    final avatar = info?['avatar']?.toString() ?? '';
    final hasAvatar = avatar.isNotEmpty;
    final relativePath = hasAvatar
        ? avatar
        : 'uploads/20260221/d058aab5aa43767fd921131ae4a9a88e.png';
    final url = ApiClient.getFullImageUrl(relativePath);
    final radius = ScreenAdapter.width(70);

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(ScreenAdapter.width(3)),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1B2140),
          ),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: Colors.white,
            backgroundImage: NetworkImage(url),
          ),
        ),
        SizedBox(width: ScreenAdapter.width(28)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                displayName,
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(50),
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: ScreenAdapter.height(10)),
              Text(
                '升级会员享额外特权',
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(30),
                  color: Colors.white.withOpacity(0.82),
                ),
              ),
              if (_isMember())
                Padding(
                  padding: EdgeInsets.only(top: ScreenAdapter.height(8)),
                  child: Text(
                    '有效期至 ${_getExpireTimeText()}',
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(26),
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  bool _isMember() {
    final info = AuthService.to.user.value?.info;
    return info?.status == 1;
  }

  String _getExpireTimeText() {
    final info = AuthService.to.user.value?.info;
    return info?.expireTimeText ?? '';
  }

  Widget _buildPrivilegeSection() {
    return Container(
      margin: EdgeInsets.only(
        top: ScreenAdapter.height(40),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '会员特权',
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(43),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF333333),
            ),
          ),
          SizedBox(height: ScreenAdapter.height(30)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenAdapter.width(24),
              vertical: ScreenAdapter.height(24),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                ScreenAdapter.width(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPrivilegeItem(Icons.stars, '积分功能'),
                _buildPrivilegeItem(Icons.menu_book, '限用题库'),
                _buildPrivilegeItem(Icons.assignment, '限用试卷'),
                _buildPrivilegeItem(Icons.school, '免费考场'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivilegeItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: ScreenAdapter.width(140),
          height: ScreenAdapter.width(140),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6E5),
            borderRadius: BorderRadius.circular(
              ScreenAdapter.width(40),
            ),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFF1A83A),
            size: ScreenAdapter.fontSize(64),
          ),
        ),
        SizedBox(height: ScreenAdapter.height(10)),
        Text(
          label,
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(34),
            color: const Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  Widget _buildPlansSection() {
    return Obx(() {
      final configs = controller.memberConfigs;
      final List<Widget> cards = [];
      final int count = configs.length < 3 ? configs.length : 3;
      for (int i = 0; i < count; i++) {
        if (i > 0) {
          cards.add(SizedBox(width: ScreenAdapter.width(10)));
        }
        cards.add(
          Expanded(
            child: GestureDetector(
              onTap: () => controller.selectPlan(i),
              child: _buildPlanItemFromConfig(
                configs[i],
                isSelected: controller.selectedIndex.value == i,
              ),
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ScreenAdapter.height(20)),
          Text(
            '会员开通',
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(43),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF333333),
            ),
          ),
          SizedBox(height: ScreenAdapter.height(40)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenAdapter.width(20),
              vertical: ScreenAdapter.height(26),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                ScreenAdapter.width(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: cards,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPlanItemFromConfig(Map<String, dynamic> config,
      {bool isSelected = false}) {
    final tag = config['tag']?.toString() ?? '会员套餐';
    final title = config['title']?.toString() ?? '会员';
    final price = config['price']?.toString() ?? '';
    final desc = config['desc']?.toString() ?? '';
    return _buildPlanItem(
      tag: tag,
      title: title,
      price: price,
      desc: desc,
      isSelected: isSelected,
    );
  }

  Widget _buildPlanItem({
    required String tag,
    required String title,
    required String price,
    required String desc,
    bool isSelected = false,
  }) {
    return Container(
      width: ScreenAdapter.width(280),
      height: ScreenAdapter.height(430),
      padding: EdgeInsets.all(ScreenAdapter.width(16)),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFBF1E5) : const Color(0xFFF9FAFF),
        borderRadius: BorderRadius.circular(
          ScreenAdapter.width(20),
        ),
        border: Border.all(
          color: isSelected ? const Color(0xFFE89A3C) : const Color(0xFFE5E6EC),
          width: isSelected ? 1.2 : 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              height: ScreenAdapter.height(60),
              padding: EdgeInsets.symmetric(
                horizontal: ScreenAdapter.width(32),
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF323758), Color(0xFF141621)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ScreenAdapter.width(20)),
                  bottomRight: Radius.circular(ScreenAdapter.width(20)),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                tag,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(24),
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: ScreenAdapter.height(20)),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(40),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF333333),
            ),
          ),
          SizedBox(height: ScreenAdapter.height(8)),
          Text(
            price,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(60),
              fontWeight: FontWeight.w500,
              color: const Color(0xFFE89A3C),
            ),
          ),
          SizedBox(height: ScreenAdapter.height(4)),
          Text(
            desc,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(30),
              color: const Color(0xFF999999),
            ),
          ),
          SizedBox(height: ScreenAdapter.height(4)),
          Text(
            '更多权益',
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(26),
              color: const Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Column(
      children: [
        _buildCommonButton(
          text: '立即开通',
          onTap: () {
            _showPayMethodSheet();
          },
        ),
        SizedBox(height: ScreenAdapter.height(20)),
        _buildActivationCodeButton(),
        SizedBox(height: ScreenAdapter.height(30)),
      ],
    );
  }

  Widget _buildActivationCodeButton() {
    return _buildCommonButton(
      text: '激活码兑换',
      onTap: () => _showActivationCodeDialog(),
    );
  }

  void _showActivationCodeDialog() {
    final textController = TextEditingController();
    showDialog(
      context: Get.context!,
      barrierColor: Colors.black45,
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: ScreenAdapter.width(820),
              padding: EdgeInsets.fromLTRB(
                ScreenAdapter.width(48),
                ScreenAdapter.height(48),
                ScreenAdapter.width(48),
                ScreenAdapter.height(40),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(ScreenAdapter.width(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 标题 - 居中
                  Text(
                    '激活码兑换',
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(42),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  SizedBox(height: ScreenAdapter.height(32)),

                  // 输入框
                  Container(
                    height: ScreenAdapter.height(90),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius:
                          BorderRadius.circular(ScreenAdapter.width(12)),
                      border: Border.all(
                        color: const Color(0xFFE8E9ED),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: textController,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: '请输入激活码',
                        hintStyle: TextStyle(
                          color: const Color(0xFFBBBBCC),
                          fontSize: ScreenAdapter.fontSize(28),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: ScreenAdapter.width(24),
                          vertical: ScreenAdapter.height(16),
                        ),
                        isDense: true,
                      ),
                      style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(30),
                        color: const Color(0xFF999999),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: ScreenAdapter.height(36)),

                  // 确认按钮 - 居中，蓝色圆角按钮
                  GestureDetector(
                    onTap: () async {
                      final code = textController.text.trim();
                      if (code.isEmpty) {
                        SnackbarUtils.showError('请输入激活码');
                        return;
                      }
                      Navigator.pop(context);
                      await controller.exchangeActivationCode(code);
                    },
                    child: Container(
                      width: ScreenAdapter.width(400),
                      height: ScreenAdapter.height(80),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4A9FF5), Color(0xFF3B8DE6)],
                        ),
                        borderRadius:
                            BorderRadius.circular(ScreenAdapter.width(40)),
                      ),
                      child: Text(
                        '确认兑换',
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(32),
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 显示支付方式选择底部弹窗
  void _showPayMethodSheet() {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildPayMethodSheet(),
    );
  }

  Widget _buildPayMethodSheet() {
    return StatefulBuilder(
      builder: (context, setSheetState) {
        return Obx(() {
          final selectedPayMethod = controller.selectedPayMethod.value;
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(ScreenAdapter.width(40)),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              ScreenAdapter.width(40),
              ScreenAdapter.height(50),
              ScreenAdapter.width(40),
              ScreenAdapter.height(60),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '选择支付方式',
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(42),
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF333333),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.close,
                          size: ScreenAdapter.fontSize(56),
                          color: const Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ScreenAdapter.height(30)),

                  // 套餐信息
                  Obx(() {
                    final configs = controller.memberConfigs;
                    final selectedIndex = controller.selectedIndex.value;
                    if (configs.isEmpty || selectedIndex >= configs.length) {
                      return const SizedBox.shrink();
                    }
                    final selected = configs[selectedIndex];
                    return Container(
                      padding: EdgeInsets.all(ScreenAdapter.width(24)),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBF1E5),
                        borderRadius: BorderRadius.circular(
                          ScreenAdapter.width(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            selected['title']?.toString() ?? '会员',
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(36),
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFE89A3C),
                            ),
                          ),
                          SizedBox(width: ScreenAdapter.width(16)),
                          Text(
                            selected['price']?.toString() ?? '',
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(48),
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFE89A3C),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  SizedBox(height: ScreenAdapter.height(30)),

                  // 支付方式选项
                  Text(
                    '支付方式',
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(34),
                      color: const Color(0xFF666666),
                    ),
                  ),
                  SizedBox(height: ScreenAdapter.height(20)),
                  Row(
                    children: [
                      _buildPayOption(
                        icon: Icons.chat_bubble,
                        label: '微信支付',
                        value: 0,
                        isSelected: selectedPayMethod == 0,
                        onTap: () => controller.selectPayMethod(0),
                      ),
                      SizedBox(width: ScreenAdapter.width(24)),
                      _buildPayOption(
                        icon: Icons.account_balance_wallet,
                        label: '支付宝',
                        value: 1,
                        isSelected: selectedPayMethod == 1,
                        onTap: () => controller.selectPayMethod(1),
                      ),
                    ],
                  ),
                  SizedBox(height: ScreenAdapter.height(40)),

                  // 确认支付按钮
                  SizedBox(
                    width: double.infinity,
                    height: ScreenAdapter.height(140),
                    child: ElevatedButton(
                      onPressed: selectedPayMethod != null
                          ? () {
                              Navigator.pop(context);
                              _showConfirmDialog();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ScreenAdapter.width(100),
                          ),
                        ),
                        backgroundColor: selectedPayMethod != null
                            ? null
                            : const Color(0xFFCCCCCC),
                        disabledBackgroundColor: const Color(0xFFCCCCCC),
                      ).copyWith(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.transparent),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            ScreenAdapter.width(100),
                          ),
                          gradient: selectedPayMethod != null
                              ? const LinearGradient(colors: [
                                  Color(0xFFF4D18C),
                                  Color(0xFFE6B870)
                                ])
                              : null,
                          color: selectedPayMethod == null
                              ? const Color(0xFFCCCCCC)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '确认支付',
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(42),
                              fontWeight: FontWeight.w500,
                              color: selectedPayMethod != null
                                  ? const Color(0xFF3D2B1F)
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: ScreenAdapter.height(20)),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildPayOption({
    required IconData icon,
    required String label,
    required int value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenAdapter.width(24),
            vertical: ScreenAdapter.height(28),
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF07C160).withOpacity(0.06)
                : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(ScreenAdapter.width(20)),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF07C160)
                  : const Color(0xFFE5E5E5),
              width: isSelected ? 1.2 : 0.8,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: ScreenAdapter.fontSize(48),
                color: isSelected
                    ? const Color(0xFF07C160)
                    : const Color(0xFF666666),
              ),
              SizedBox(width: ScreenAdapter.width(12)),
              Text(
                label,
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(34),
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  color: isSelected
                      ? const Color(0xFF07C160)
                      : const Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 确认支付弹窗 - 使用公共弹窗组件
  void _showConfirmDialog() async {
    final configs = controller.memberConfigs;
    String priceInfo = '';
    if (configs.isNotEmpty && controller.selectedIndex.value < configs.length) {
      final selected = configs[controller.selectedIndex.value];
      priceInfo = '${selected["title"] ?? ""} - ${selected["price"] ?? ""}';
    }

    final content =
        '即将使用${controller.selectedPayMethod.value == 0 ? "微信" : "支付宝"}支付\n$priceInfo';

    final confirmed = await CommonDialog.show(
      title: '确认开通',
      content: content,
      confirmText: '立即支付',
      cancelText: '取消',
      barrierDismissible: false,
      confirmColor: const Color(0xFFE89A3C),
    );

    if (confirmed) {
      controller.doPay();
    }
  }
}

Widget _buildCommonButton({required String text, required VoidCallback onTap}) {
  return SizedBox(
    width: double.infinity,
    height: ScreenAdapter.height(96),
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ScreenAdapter.width(48),
          ),
        ),
      ).copyWith(
        backgroundColor: MaterialStateProperty.all(Colors.transparent),
        shadowColor: MaterialStateProperty.all(
          const Color(0xFFE5C07B).withOpacity(0.4),
        ),
      ),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            ScreenAdapter.width(48),
          ),
          gradient: const LinearGradient(
            colors: [Color(0xFFF4D18C), Color(0xFFE6B870)],
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(34),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF3D2B1F),
            ),
          ),
        ),
      ),
    ),
  );
}
