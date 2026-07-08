import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/screenAdapter.dart';
import '../controllers/question_feedback_controller.dart';

class QuestionFeedbackView extends GetView<QuestionFeedbackController> {
  const QuestionFeedbackView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF333333),
        centerTitle: true,
        title: Text(
          '问题反馈',
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(36),
            color: const Color(0xFF333333),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenAdapter.width(30),
                vertical: ScreenAdapter.height(20),
              ),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(ScreenAdapter.width(20)),
                  ),
                  padding: EdgeInsets.all(ScreenAdapter.width(30)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: ScreenAdapter.fontSize(42),
                            color: const Color(0xFF3D7CFF),
                          ),
                          SizedBox(width: ScreenAdapter.width(10)),
                          Text(
                            '反馈内容',
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(46),
                              color: const Color(0xFF333333),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: ScreenAdapter.height(20)),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: controller.textController,
                        builder: (context, value, child) {
                          return TextField(
                            controller: controller.textController,
                            maxLines: 8,
                            maxLength: 500,
                            decoration: InputDecoration(
                              hintText: '请详细描述您遇到的问题或建议，我们会认真对待每一条反馈～',
                              hintStyle: TextStyle(
                                fontSize: ScreenAdapter.fontSize(36),
                                color: const Color(0xFF999999),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    ScreenAdapter.width(16)),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    ScreenAdapter.width(16)),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    ScreenAdapter.width(16)),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8F9FA),
                              contentPadding:
                                  EdgeInsets.all(ScreenAdapter.width(24)),
                              counterText: '${value.text.length}/500',
                              counterStyle: TextStyle(
                                fontSize: ScreenAdapter.fontSize(30),
                                color: const Color(0xFF999999),
                              ),
                            ),
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(30),
                              color: const Color(0xFF333333),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: ScreenAdapter.height(20)),
                Obx(() => Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(ScreenAdapter.width(20)),
                      ),
                      padding: EdgeInsets.all(ScreenAdapter.width(30)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.photo_library_outlined,
                                size: ScreenAdapter.fontSize(42),
                                color: const Color(0xFF3D7CFF),
                              ),
                              SizedBox(width: ScreenAdapter.width(10)),
                              Text(
                                '添加截图',
                                style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(46),
                                  color: const Color(0xFF333333),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: ScreenAdapter.height(20)),
                          Wrap(
                            spacing: ScreenAdapter.width(16),
                            runSpacing: ScreenAdapter.height(16),
                            children: [
                              ...List.generate(controller.images.length, (index) {
                                return Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          ScreenAdapter.width(12)),
                                      child: Image.file(
                                        width: ScreenAdapter.width(200),
                                        height: ScreenAdapter.width(200),
                                        File(controller.images[index].path),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: GestureDetector(
                                        onTap: () =>
                                            controller.removeImage(index),
                                        child: Container(
                                          padding: EdgeInsets.all(
                                              ScreenAdapter.width(4)),
                                          decoration: const BoxDecoration(
                                            color: Color(0x80000000),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.close,
                                            size: ScreenAdapter.fontSize(28),
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                              if (controller.images.length < 9)
                                GestureDetector(
                                  onTap: controller.pickImage,
                                  child: Container(
                                    width: ScreenAdapter.width(200),
                                    height: ScreenAdapter.width(200),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          ScreenAdapter.width(12)),
                                      border: Border.all(
                                        color: const Color(0xFFDDDDDD),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      size: ScreenAdapter.fontSize(60),
                                      color: const Color(0xFF999999),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          SafeArea(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: ScreenAdapter.width(30),
                vertical: ScreenAdapter.height(20),
              ),
              child: Obx(() => ElevatedButton(
                    onPressed: (controller.isSubmitting.value ||
                            controller.isUploading.value)
                        ? null
                        : controller.submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3D9EFF),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFCCCCCC),
                      padding: EdgeInsets.symmetric(
                        vertical: ScreenAdapter.height(28),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(ScreenAdapter.width(16)),
                      ),
                      elevation: 0,
                    ),
                    child: (controller.isSubmitting.value ||
                            controller.isUploading.value)
                        ? SizedBox(
                            width: ScreenAdapter.width(32),
                            height: ScreenAdapter.width(32),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            '提交反馈',
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(34),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
