import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'app/data/providers/api_client.dart';
import 'app/data/services/auth_service.dart';
import 'app/data/repositories/repository_provider.dart';
import 'app/services/global_project_controller.dart';
import 'app/routes/app_pages.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 设置状态栏样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // 初始化本地存储
  await GetStorage.init();

  // ==================== 注册核心服务 ====================

  // 1. 注册API客户端（被其他服务依赖）
  Get.put(ApiClient(), permanent: true);

  // 2. 注册认证服务（依赖API客户端）
  Get.put(AuthService(), permanent: true);

  // 3. 注册所有Repository（依赖API客户端）
  RepositoryProvider.init();

  // 4. 注册全局项目控制器（依赖Repository）
  Get.put(GlobalProjectController(), permanent: true);

  // ==================== 确定初始路由 ====================

  // 根据登录状态决定初始路由（由全局控制器管理）
  final String initialRoute = GlobalProjectController.getInitialRoute();

  // ==================== 启动应用 ====================

  runApp(
    ScreenUtilInit(
      designSize: const Size(1080, 2400), // 设计稿尺寸
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: '在线考试',
          initialRoute: initialRoute,
          getPages: AppPages.routes,
          builder: FlutterSmartDialog.init(),
          // 开启日志（开发环境）
          enableLog: true,
          logWriterCallback: (text, {bool isError = false}) {
            debugPrint('[GetX] $text');
          },
        );
      },
    ),
  );
}
