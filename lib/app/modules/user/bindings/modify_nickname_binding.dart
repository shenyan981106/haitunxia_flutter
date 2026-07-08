import 'package:get/get.dart';
import '../controllers/modify_nickname_controller.dart';

class ModifyNicknameBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ModifyNicknameController>(() => ModifyNicknameController());
  }
}
