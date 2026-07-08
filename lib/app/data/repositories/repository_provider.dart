import 'package:get/get.dart';
import 'exam_repository.dart';

/// Repository 提供器
/// 统一管理所有Repository 的注册和获取
class RepositoryProvider {
  RepositoryProvider._();

  /// 初始化所有Repository
  static void init() {
    // 注册 ExamRepository
    Get.put<ExamRepository>(ExamRepository(), permanent: true);
  }

  /// 获取 ExamRepository 实例
  static ExamRepository get exam => Get.find<ExamRepository>();
}

/// 便捷的扩展方法
/// 方便在代码中直接访问所有Repository
/// 例如：`ExamRepository examRepository = Get.find<ExamRepository>();`
extension RepositoryExtension on GetInterface {
  /// 获取 ExamRepository
  ExamRepository get examRepository => Get.find<ExamRepository>();
}
