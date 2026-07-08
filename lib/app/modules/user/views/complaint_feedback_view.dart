import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/screenAdapter.dart';
import '../controllers/complaint_feedback_controller.dart';

class ComplaintFeedbackView extends GetView<ComplaintFeedbackController> {
  const ComplaintFeedbackView({Key? key}) : super(key: key);

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
          '投诉违规内容',
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(40),
            color: const Color(0xFF333333),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Obx(() => Stack(
            children: [
              ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenAdapter.width(30),
                  vertical: ScreenAdapter.height(30),
                ),
                children: [
                  _buildSection(
                    title: '投诉内容',
                    child: TextField(
                      onChanged: (value) => controller.updatePageUrl(value),
                      decoration: InputDecoration(
                        hintText: '请输入投诉页面链接',
                        hintStyle: TextStyle(
                          fontSize: ScreenAdapter.fontSize(32),
                          color: const Color(0xFFCCCCCC),
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(32),
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ),
                  SizedBox(height: ScreenAdapter.height(30)),
                  _buildSection(
                    title: '投诉理由',
                    child: _buildReasonTags(),
                  ),
                  SizedBox(height: ScreenAdapter.height(30)),
                  _buildSection(
                    title: '问题描述',
                    child: _buildDescriptionField(),
                  ),
                  SizedBox(height: ScreenAdapter.height(60)),
                  _buildSubmitButton(),
                ],
              ),
              if (controller.isLoading.value)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          )),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
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
              fontSize: ScreenAdapter.fontSize(36),
              color: const Color(0xFF333333),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: ScreenAdapter.height(20)),
          child,
        ],
      ),
    );
  }

  Widget _buildReasonTags() {
    return Wrap(
      spacing: ScreenAdapter.width(20),
      runSpacing: ScreenAdapter.height(15),
      children: controller.reasonOptions
          .map((option) => GestureDetector(
                onTap: () {
                  controller.selectReason(option);
                },
                child: Obx(() => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenAdapter.width(36),
                        vertical: ScreenAdapter.height(15),
                      ),
                      decoration: BoxDecoration(
                        color: controller.selectedReason.value == option
                            ? const Color(0xFF4A90E2)
                            : const Color(0xFFF4F6FB),
                        borderRadius:
                            BorderRadius.circular(ScreenAdapter.width(30)),
                        border: Border.all(
                          color: controller.selectedReason.value == option
                              ? const Color(0xFF4A90E2)
                              : const Color(0xFFE5E6EC),
                        ),
                      ),
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(32),
                          color: controller.selectedReason.value == option
                              ? Colors.white
                              : const Color(0xFF666666),
                        ),
                      ),
                    )),
              ))
          .toList(),
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      children: [
        TextField(
          onChanged: (value) => controller.updateDescription(value),
          maxLines: 8,
          maxLength: 200,
          decoration: InputDecoration(
            hintText: '请输入问题描述，以便投诉处理团队快速定位问题',
            hintStyle: TextStyle(
              fontSize: ScreenAdapter.fontSize(32),
              color: const Color(0xFFCCCCCC),
            ),
            border: InputBorder.none,
            counterText: '',
          ),
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(32),
            color: const Color(0xFF333333),
          ),
        ),
        Obx(() => Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${controller.description.value.length}/200',
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(26),
                  color: const Color(0xFF999999),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: ScreenAdapter.height(120),
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.submitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A90E2),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScreenAdapter.width(60)),
          ),
        ),
        child: Text(
          '提交',
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(38),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
