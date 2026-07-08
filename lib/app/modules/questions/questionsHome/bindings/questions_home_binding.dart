import 'package:get/get.dart';

import '../controllers/questions_home_controller.dart';

class QuestionsHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuestionsHomeController>(
      () => QuestionsHomeController(),
    );
  }

  final currentTab = 0.obs;

  final tabs = [
    '中国近现代史纲要',
    '自考英语二',
    '自考英语二',
    '自考英语二',
  ];
}
