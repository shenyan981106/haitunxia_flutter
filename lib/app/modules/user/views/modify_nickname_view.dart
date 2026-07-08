import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/screenAdapter.dart';
import '../controllers/modify_nickname_controller.dart';

class ModifyNicknameView extends GetView<ModifyNicknameController> {
  const ModifyNicknameView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF333333),
        centerTitle: true,
        title: Text(
          '修改昵称',
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(40),
            color: const Color(0xFF333333),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: ScreenAdapter.width(750),
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: 0,
              vertical: ScreenAdapter.height(40),
            ),
            children: [
              SizedBox(height: ScreenAdapter.height(100)),
              Text(
                '修改昵称',
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(50),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF333333),
                ),
              ),
              SizedBox(height: ScreenAdapter.height(60)),
              SizedBox(height: ScreenAdapter.height(12)),
              TextField(
                controller: controller.textController,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.only(
                    top: ScreenAdapter.height(16),
                    bottom: ScreenAdapter.height(8),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFE5E6EC)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF3D7CFF)),
                  ),
                  hintText: '请输入新的昵称',
                  hintStyle: TextStyle(
                    fontSize: ScreenAdapter.fontSize(34),
                    color: const Color(0xFFCCCCCC),
                  ),
                ),
              ),
              SizedBox(height: ScreenAdapter.height(60)),
              Obx(() => SizedBox(
                    width: ScreenAdapter.width(750),
                    height: ScreenAdapter.height(150),
                    child: ElevatedButton(
                      onPressed: controller.isSubmitting.value
                          ? null
                          : controller.submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3D7CFF),
                        foregroundColor: Colors.white,
                        minimumSize: Size(
                          ScreenAdapter.width(750),
                          ScreenAdapter.height(150),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ScreenAdapter.width(100),
                          ),
                        ),
                      ),
                      child: Text(
                        '提交',
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(50),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )),
              SizedBox(height: ScreenAdapter.height(30)),
            ],
          ),
        ),
      ),
    );
  }
}
