import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../services/screenAdapter.dart';
import '../../../services/global_project_controller.dart';
import '../../../data/providers/api_client.dart';
import '../../../data/services/auth_service.dart';
import '../../../components/customer_service_dialog.dart';
import '../../../services/snackbar_utils.dart';
import 'user_info_view.dart';
import 'vip_center_view.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/user_controller.dart';

class UserView extends GetView<UserController> {
  const UserView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFE8EDFF),
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFE8EDFF),
                      Color(0xFFF6F7F9),
                    ],
                    stops: [0.0, 0.6],
                  ),
                ),
              ),
              ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenAdapter.width(40),
                  vertical: ScreenAdapter.height(24),
                ),
                children: [
                  _buildTopNav(),
                  SizedBox(height: ScreenAdapter.height(36)),
                  _buildProfileHeader(),
                  SizedBox(height: ScreenAdapter.height(36)),
                  _buildVipCard(),
                  SizedBox(height: ScreenAdapter.height(36)),
                  _buildActivationCodeEntry(),
                  SizedBox(height: ScreenAdapter.height(24)),
                  _buildMenuGroup([
                    _MenuItem(
                      title: '我的订单',
                      icon: Icons.receipt_outlined,
                      onTap: () => Get.toNamed('/my-orders'),
                    ),
                    _MenuItem(
                      title: '我的课程',
                      icon: Icons.play_circle_outline,
                      onTap: () => Get.toNamed('/my-courses', arguments: {
                        'subject_id':
                            GlobalProjectController.to.currentProject.value?.id,
                      }),
                    ),
                    // _MenuItem(
                    //   title: '我的题库',
                    //   icon: Icons.book_outlined,
                    //   onTap: () => Get.toNamed('/my-bank'),
                    // ),
                    _MenuItem(
                      title: '我的收藏',
                      icon: Icons.star_border,
                      onTap: () => Get.toNamed('/my-favorites'),
                    ),
                    _MenuItem(
                      title: '我的错题',
                      icon: Icons.error_outline,
                      onTap: () => Get.toNamed('/questions/wrong'),
                    ),
                  ]),
                  SizedBox(height: ScreenAdapter.height(24)),
                  _buildMenuGroup([
                    _MenuItem(
                      title: '客服中心',
                      icon: Icons.headset_mic_outlined,
                      onTap: () async {
                        final qrCode =
                            await controller.fetchCustomerServiceQrCode();
                        if (qrCode != null) {
                          CustomerServiceDialog.show(qrCodeUrl: qrCode);
                        }
                      },
                    ),
                    _MenuItem(
                      title: '报考咨询',
                      icon: Icons.contact_support_outlined,
                      onTap: () async {
                        final qrCode = await controller.fetchZixunQrCode();
                        if (qrCode != null) {
                          CustomerServiceDialog.show(qrCodeUrl: qrCode);
                        }
                      },
                    ),
                    _MenuItem(
                      title: '意见反馈',
                      icon: Icons.feedback_outlined,
                      onTap: () => Get.toNamed('/question-feedback'),
                    ),
                    _MenuItem(
                      title: '平台资质',
                      icon: Icons.verified_user_outlined,
                      onTap: () => Get.toNamed('/platform-qualification'),
                    ),
                    _MenuItem(
                      title: '企业团报合作',
                      icon: Icons.group_outlined,
                      onTap: () async {
                        final url = await controller.fetchCompanyH5Url();
                        if (url != null) {
                          final uri = Uri.parse(url);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          } else {
                            SnackbarUtils.showError('无法打开链接');
                          }
                        }
                      },
                    ),
                  ]),
                  SizedBox(height: ScreenAdapter.height(40)),
                  _buildIcpLicense(),
                  SizedBox(height: ScreenAdapter.height(120)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopNav() {
    return Container(
      height: ScreenAdapter.height(100),
      alignment: Alignment.center,
      child: Text(
        '个人中心',
        style: TextStyle(
          fontSize: ScreenAdapter.fontSize(50),
          fontWeight: FontWeight.w500,
          color: const Color(0xFF333333),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Get.to(() => const UserInfoView()),
      child: Container(
        height: ScreenAdapter.height(260),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Obx(() {
              final info = AuthService.to.user.value?.toJson();
              final avatar = info?['avatar']?.toString() ?? '';
              final hasAvatar = avatar.isNotEmpty;
              final relativePath = hasAvatar
                  ? avatar
                  : 'uploads/20260221/d058aab5aa43767fd921131ae4a9a88e.png';
              final url = ApiClient.getFullImageUrl(relativePath);
              final avatarWidth = ScreenAdapter.width(180);
              final avatarHeight = ScreenAdapter.height(180);
              return Container(
                padding: EdgeInsets.all(ScreenAdapter.width(6)),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    url,
                    width: avatarWidth,
                    height: avatarHeight,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: avatarWidth,
                        height: avatarHeight,
                        color: Colors.grey[200],
                      );
                    },
                  ),
                ),
              );
            }),
            SizedBox(width: ScreenAdapter.width(18)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() {
                    final info = AuthService.to.user.value?.toJson();
                    final isLoggedIn = AuthService.to.isLoggedIn.value;
                    final displayName = isLoggedIn
                        ? (info?['nickname']?.toString() ??
                            info?['username']?.toString() ??
                            '未登录用户')
                        : '注册/登录';
                    return Text(
                      displayName,
                      style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(50),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF222222),
                      ),
                    );
                  }),
                  SizedBox(height: ScreenAdapter.height(10)),
                  Text(
                    '让学习成为一种乐趣',
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(32),
                      color: const Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: ScreenAdapter.fontSize(60),
              color: const Color(0xFFCCCCCC),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVipCard() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Get.toNamed('/vip-center'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ScreenAdapter.width(26)),
        child: Image.asset(
          'assets/images/vip_open.jpg',
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildActivationCodeEntry() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showActivationCodeDialog(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ScreenAdapter.width(26)),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: ScreenAdapter.width(40),
          vertical: ScreenAdapter.height(30),
        ),
        child: Row(
          children: [
            Icon(
              Icons.card_giftcard_outlined,
              size: ScreenAdapter.fontSize(44),
              color: const Color(0xFF666666),
            ),
            SizedBox(width: ScreenAdapter.width(30)),
            Expanded(
              child: Text(
                '激活码兑换',
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(40),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF333333),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: ScreenAdapter.fontSize(44),
              color: const Color(0xFFCCCCCC),
            ),
          ],
        ),
      ),
    );
  }

  void _showActivationCodeDialog() {
    final controller = TextEditingController();
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
                  Text(
                    '激活码兑换',
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(42),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  SizedBox(height: ScreenAdapter.height(32)),
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
                      controller: controller,
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
                  GestureDetector(
                    onTap: () async {
                      final code = controller.text.trim();
                      if (code.isEmpty) {
                        SnackbarUtils.showError('请输入激活码');
                        return;
                      }
                      Navigator.pop(context);
                      await this.controller.exchangeActivationCode(code);
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

  Widget _buildMenuGroup(List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ScreenAdapter.width(26)),
      ),
      child: Column(
        children: items.map((item) => _buildMenuItem(item)).toList(),
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: item.onTap,
      child: Container(
        height: ScreenAdapter.height(130),
        margin: EdgeInsets.symmetric(vertical: ScreenAdapter.height(10)),
        padding: EdgeInsets.symmetric(horizontal: ScreenAdapter.width(40)),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: ScreenAdapter.fontSize(44),
              color: const Color(0xFF666666),
            ),
            SizedBox(width: ScreenAdapter.width(30)),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(40),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF333333),
                ),
              ),
            ),
            if (item.badge != null)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenAdapter.width(16),
                  vertical: ScreenAdapter.height(6),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4D4F),
                  borderRadius: BorderRadius.circular(ScreenAdapter.width(20)),
                ),
                child: Text(
                  item.badge!,
                  style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(28),
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            if (item.trailing != null)
              Text(
                item.trailing!,
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(36),
                  color: const Color(0xFF999999),
                ),
              ),
            SizedBox(width: ScreenAdapter.width(16)),
            Icon(
              Icons.chevron_right,
              size: ScreenAdapter.fontSize(44),
              color: const Color(0xFFCCCCCC),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcpLicense() {
    return Center(
      child: Text(
        '冀ICP备2023032312号-9A',
        style: TextStyle(
          fontSize: ScreenAdapter.fontSize(24),
          color: const Color(0xFF999999),
        ),
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final String? badge;
  final String? trailing;

  const _MenuItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.badge,
    this.trailing,
  });
}
