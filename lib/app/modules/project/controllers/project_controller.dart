import 'package:get/get.dart';
import 'package:xmshop/app/data/providers/api_client.dart';
import '../../../data/models/category_model.dart';

class ProjectController extends GetxController {
  // 选中的项
  var selectedItem = ''.obs;

  // 分类数据
  var categories = <Category>[].obs;

  // 加载状态
  var isLoading = false.obs;

  // 错误信息
  var errorMessage = ''.obs;

  // 选择项目
  void selectItem(String item) {
    selectedItem.value = item;

    // 这里可以保存到本地存储，以便下次打开时记住选择
    // 例如使用GetStorage或SharedPreferences
    // GetStorage().write('selected_project', item);
  }

  // 获取分类数据
  Future<void> fetchCategories() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await ApiClient.to.getExam('subject/index');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 1) {
          final List<dynamic> categoryData = data['data'];
          categories.value =
              categoryData.map((item) => Category.fromJson(item)).toList();
        } else {
          errorMessage.value = data['msg'] ?? '获取分类数据失败';
        }
      } else {
        errorMessage.value = '网络请求失败，请稍后重试';
      }
    } catch (e) {
      print('Fetch categories error: $e'); // Add console log
      errorMessage.value = '请求出错：$e'; // Show detail to user temporarily
    } finally {
      isLoading.value = false;
    }
  }

  // 初始化时获取分类数据
  @override
  void onInit() {
    super.onInit();
    fetchCategories();

    // 从本地存储读取上次选择
    // selectedItem.value = GetStorage().read('selected_project') ?? '';
  }
}
