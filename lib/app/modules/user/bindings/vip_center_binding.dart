import 'package:get/get.dart';
import '../controllers/vip_center_controller.dart';

class VipCenterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VipCenterController>(() => VipCenterController());
  }
}
