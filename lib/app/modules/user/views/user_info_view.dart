import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../services/screenAdapter.dart';
import '../../../services/global_project_controller.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../../services/snackbar_utils.dart';
import '../controllers/user_controller.dart';
import 'modify_nickname_view.dart';
import 'delete_account_view.dart';

class UserInfoView extends GetView<UserController> {
  const UserInfoView({Key? key}) : super(key: key);

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
          '个人信息',
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(40),
            color: const Color(0xFF333333),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenAdapter.width(30),
          vertical: ScreenAdapter.height(30),
        ),
        children: [
          _buildActionCard(),
          SizedBox(height: ScreenAdapter.height(40)),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    if (!controller.checkLoginStatus()) {
      SnackbarUtils.showError('请先登录后再操作');
      return;
    }

    await Get.dialog(
      Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(
              horizontal: ScreenAdapter.width(60),
            ),
            padding: EdgeInsets.all(ScreenAdapter.width(40)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ScreenAdapter.width(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '注销账号申请',
                  style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(40),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF333333),
                  ),
                ),
                SizedBox(height: ScreenAdapter.height(24)),
                Text(
                  '尊敬的用户，您正在申请注销账号。请注意以下事项：\n\n'
                  '1、账号注销后无法恢复，请谨慎操作\n'
                  '2、您的所有个人信息将被清除\n'
                  '3、您的学习记录、考试成绩将永久丢失\n'
                  '4、已购买的课程将无法继续观看\n\n'
                  '注销申请提交后，我们将在7个工作日内审核。\n\n'
                  '如确认无误，请提交申请。',
                  style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(28),
                    color: const Color(0xFF666666),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: ScreenAdapter.height(30)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text(
                        '取消',
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(30),
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ),
                    SizedBox(width: ScreenAdapter.width(20)),
                    ElevatedButton(
                      onPressed: () async {
                        final success =
                            await controller.submitDeleteAccountRequest();
                        if (success) {
                          SnackbarUtils.showSuccess('注销申请已提交，请等待审核');
                          Get.back();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenAdapter.width(40),
                          vertical: ScreenAdapter.height(10),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ScreenAdapter.width(24),
                          ),
                        ),
                      ),
                      child: Text(
                        '提交申请',
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(30),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildActionCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ScreenAdapter.width(24)),
      ),
      child: Column(
        children: [
          _buildAvatarSection(),
          _buildDivider(),
          _buildActionItem(
            '修改昵称',
            onTap: () {
              Get.toNamed('/modify-nickname');
            },
          ),
          _buildDivider(),
          _buildActionItem(
            '彻底注销账号',
            onTap: () {
              Get.toNamed('/delete-account');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Obx(() {
      final user = AuthService.to.user.value;
      final avatarUrl = user?.avatar;

      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: ScreenAdapter.height(40),
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickAndUploadAvatar,
              child: Container(
                width: ScreenAdapter.width(200),
                height: ScreenAdapter.width(200),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8EDF5),
                  image: avatarUrl != null && avatarUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(avatarUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: avatarUrl == null || avatarUrl.isEmpty
                    ? Icon(
                        Icons.person,
                        size: ScreenAdapter.fontSize(80),
                        color: const Color(0xFFB0B5C0),
                      )
                    : null,
              ),
            ),
            SizedBox(height: ScreenAdapter.height(16)),
            GestureDetector(
              onTap: _pickAndUploadAvatar,
              child: Container(
                width: ScreenAdapter.width(72),
                height: ScreenAdapter.width(72),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF666666),
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: ScreenAdapter.fontSize(36),
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _pickAndUploadAvatar() async {
    await controller.pickAndUploadAvatar();
  }

  Widget _buildDivider() {
    return Container(
      margin: EdgeInsets.only(
        left: ScreenAdapter.width(40),
      ),
      height: 0.5,
      color: const Color(0xFFE5E6EC),
    );
  }

  Widget _buildActionItem(String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: ScreenAdapter.height(150),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenAdapter.width(30),
          ),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(38),
                  color: const Color(0xFF333333),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                size: ScreenAdapter.fontSize(40),
                color: const Color(0xFFB0B5C0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: EdgeInsets.only(
        top: ScreenAdapter.height(10),
      ),
      child: SizedBox(
        height: ScreenAdapter.height(150),
        child: ElevatedButton(
          onPressed: () {
            controller.logout();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFFE53935),
            elevation: 0,
            minimumSize: const Size(double.infinity, 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ScreenAdapter.width(24)),
            ),
          ),
          child: Text(
            '退出当前账号',
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(38),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
