import 'package:get/get.dart';
import '../controllers/question_feedback_controller.dart';

class QuestionFeedbackBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuestionFeedbackController>(() => QuestionFeedbackController());
  }
}
