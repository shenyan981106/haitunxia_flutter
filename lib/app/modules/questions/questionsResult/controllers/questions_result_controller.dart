import 'package:get/get.dart';

class QuestionsResultController extends GetxController {
  final title = '考试试卷'.obs;
  final nickname = '未设置'.obs;
  final durationSeconds = 0.obs;
  final totalScore = 100.obs;
  final passScore = 60.obs;
  final questionCount = 0.obs;
  final answeredCount = 0.obs;
  final correctCount = 0.obs;
  final wrongCount = 0.obs;
  final score = 0.obs;
  final passed = false.obs;
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      title.value = (args['title'] ?? '考试试卷').toString();
      nickname.value = (args['nickname'] ?? '未设置').toString();
      durationSeconds.value = (args['durationSeconds'] ?? 0) as int;
      totalScore.value = (args['totalScore'] ?? 100) as int;
      passScore.value = (args['passScore'] ?? 60) as int;
      questionCount.value = (args['questionCount'] ?? 0) as int;
      answeredCount.value = (args['answeredCount'] ?? 0) as int;
      correctCount.value = (args['correctCount'] ?? 0) as int;
      wrongCount.value = (args['wrongCount'] ?? 0) as int;
      score.value = (args['score'] ?? 0) as int;
      passed.value = (args['passed'] ?? false) as bool;
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
