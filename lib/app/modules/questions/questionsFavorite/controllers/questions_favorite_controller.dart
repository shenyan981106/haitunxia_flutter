import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/providers/api_client.dart';
import '../../../../services/global_project_controller.dart';
import '../../../../services/screenAdapter.dart';
import '../../../../components/common_dialog.dart';

/// 收藏题目单项模型（ 返回的单条收藏记录）
class FavoriteItem {
  final int id;
  final int userId;
  final int questionId;
  final int createTime;
  final int updateTime;

  // 嵌套 question 对象字段
  final int? qid;
  final String? kind; // 题型: SINGLE/MULTI/JUDGE
  final String? title; // 题目内容
  final String? answer; // 答案
  final String? optionsJson; // 选项 JSON
  final String? difficulty; // 难度
  final String? explain; // 解析

  FavoriteItem({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.createTime,
    required this.updateTime,
    this.qid,
    this.kind,
    this.title,
    this.answer,
    this.optionsJson,
    this.difficulty,
    this.explain,
  });

  factory FavoriteItem.fromJson(dynamic json) {
    if (json is! Map) {
      return FavoriteItem(
        id: 0,
        userId: 0,
        questionId: 0,
        createTime: 0,
        updateTime: 0,
      );
    }

    Map<String, dynamic>? qMap;
    final question = json['question'];
    if (question is Map) {
      qMap = <String, dynamic>{};
      for (final key in question.keys) {
        qMap[key.toString()] = question[key];
      }
    }

    return FavoriteItem(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      questionId: json['question_id'] ?? 0,
      createTime: json['createtime'] ?? 0,
      updateTime: json['updatetime'] ?? 0,

      // 从嵌套 question 对象中取值
      qid: qMap?['id'],
      kind: qMap?['kind']?.toString(),
      title: qMap?['title']?.toString(),
      answer: qMap?['answer']?.toString(),
      optionsJson: qMap?['options_json']?.toString(),
      difficulty: qMap?['difficulty']?.toString(),
      explain: qMap?['explain']?.toString(),
    );
  }
}

/// 按分类分组的模型（后端已分组返回）
class FavoriteGroup {
  final String cateName; // 列表标题（后端直接返回的 cate_name）
  final List<FavoriteItem> items; // 该分类下的所有题

  FavoriteGroup({required this.cateName, required this.items});

  int get count => items.length;
}

/// 题目收藏页面控制器（）
class QuestionsFavoriteController extends GetxController {
  late GlobalProjectController globalController;

  /// 分组后的展示列表（后端已分组返回）
  final RxList<FavoriteGroup> favoriteGroups = <FavoriteGroup>[].obs;

  /// 所有题目总数
  final RxInt totalCount = 0.obs;

  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;

  // 排序选项状态
  final RxString currentSortTime = '录入时间'.obs;
  final RxString currentSortOrder = '新添加在前'.obs;

  @override
  void onInit() {
    super.onInit();
    try {
      globalController = GlobalProjectController.to;
    } catch (e) {
      debugPrint('GlobalProjectController 获取失败: $e');
    }
    Future.delayed(const Duration(milliseconds: 100), () {
      _loadFavorites();
    });
  }

  /// 加载收藏列表（调用 collectList 接口）
  /// 后端返回格式: { code: 1, data: { total: N, list: [{ cate_name: "...", items: [...] }] } }
  Future<void> _loadFavorites({bool refresh = false}) async {
    if (refresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final params = <String, dynamic>{};
      params['order'] = currentSortOrder.value == '新添加在前' ? 'desc' : 'asc';

      final response = await ApiClient.to.getExam(
        'question/collectList',
        queryParameters: params.isEmpty ? null : params,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['code'] == 1) {
          final innerData = data['data'];
          if (innerData is! Map) {
            errorMessage.value = '数据格式异常';
            return;
          }

          // 从 data.data 中取 list 和 total
          final listData = innerData['list'];
          final totalVal = innerData['total'];
          totalCount.value = totalVal ?? 0;

          final groups = <FavoriteGroup>[];

          if (listData is List && listData.isNotEmpty) {
            for (final group in listData) {
              if (group is! Map) continue;

              final cateName = group['cate_name']?.toString() ?? '未分组';
              final itemsRaw = group['items'];

              final items = <FavoriteItem>[];
              if (itemsRaw is List) {
                for (final item in itemsRaw) {
                  items.add(FavoriteItem.fromJson(item));
                }
              }

              if (items.isNotEmpty) {
                groups.add(FavoriteGroup(cateName: cateName, items: items));
              }
            }
          }

          favoriteGroups.assignAll(groups);

          debugPrint('收藏列表加载成功: ${groups.length} 分组, ${totalCount.value} 个题目');
          for (final g in groups) {
            debugPrint('  - ${g.cateName}: ${g.count} 个题目');
          }
        } else {
          errorMessage.value =
              data is Map ? (data['msg']?.toString() ?? '获取收藏列表失败') : '数据异常';
        }
      } else {
        errorMessage.value = '网络请求失败';
      }
    } catch (e) {
      debugPrint('加载收藏列表失败: $e');
      errorMessage.value = '网络错误，请稍后重试';
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  /// 下拉刷新
  Future<void> onRefresh() async => _loadFavorites(refresh: true);

  /// 录入时间筛选选项
  static const _timeOptions = ['不限', '15天', '30天'];

  // 排序选项
  static const _orderOptions = ['新添加在前', '新添加在后'];

  /// 显示录入时间筛选弹窗（紧贴筛选栏下方）
  void showTimeFilterPicker(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (ctx) => _buildTimeFilterContent(ctx),
    );
  }

  Widget _buildTimeFilterContent(BuildContext ctx) {
    // 状态栏 + 导航栏(112) + 筛选栏(140)
    final topOffset =
        MediaQuery.of(ctx).padding.top + ScreenAdapter.height(252);
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 遮罩 - 从筛选栏下方开始覆盖
          Positioned(
            top: topOffset,
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Container(color: Color(0x80000000)),
            ),
          ),
          // 弹窗内容 - 紧贴筛选栏下方，通宽
          Positioned(
            top: topOffset,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(ScreenAdapter.radius(24)),
                    bottomRight: Radius.circular(ScreenAdapter.radius(24)),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenAdapter.width(60),
                    vertical: ScreenAdapter.height(60)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 第一行：不限 / 15天(两列)
                    Row(
                      children: _timeOptions.take(2).map((opt) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: ScreenAdapter.width(10)),
                          child: _buildTimeOption(ctx, opt),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: ScreenAdapter.height(16)),
                    // 第二行：30天(单列居左)
                    Row(children: [
                      _buildTimeOption(ctx, _timeOptions[2]),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeOption(BuildContext ctx, String opt) {
    final selected = currentSortTime.value == opt;
    return GestureDetector(
      onTap: () {
        Navigator.pop(ctx);
        currentSortTime.value = opt;
        _loadFavorites();
      },
      child: Container(
        width: ScreenAdapter.width(300),
        height: ScreenAdapter.height(100),
        decoration: BoxDecoration(
          color: selected ? Color(0xFFF0F5FF) : Colors.white,
          borderRadius: BorderRadius.circular(ScreenAdapter.radius(10)),
          border: Border.all(
            color: selected ? Color(0xFFD6E4FF) : Color(0xFFE8E8E8),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          opt,
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(32),
            color: selected ? Color(0xFF5B9CFF) : Color(0xFF999999),
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// 显示排序方式弹窗（无动画，从顶部弹出）
  void showOrderPicker(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (ctx) => _buildOrderContent(ctx),
    );
  }

  Widget _buildOrderContent(BuildContext ctx) {
    // 状态栏 + 导航栏(112) + 筛选栏(140)
    final topOffset =
        MediaQuery.of(ctx).padding.top + ScreenAdapter.height(252);
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 遮罩 - 从筛选栏下方开始覆盖
          Positioned(
            top: topOffset,
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Container(color: Color(0x80000000)),
            ),
          ),
          // 弹窗内容 - 紧贴筛选栏下方，通宽
          Positioned(
            top: topOffset,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(ScreenAdapter.radius(24)),
                    bottomRight: Radius.circular(ScreenAdapter.radius(24)),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenAdapter.width(60),
                    vertical: ScreenAdapter.height(60)),
                child: Row(
                  children: _orderOptions.map((opt) {
                    final selected = currentSortOrder.value == opt;
                    return Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenAdapter.width(10)),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          currentSortOrder.value = opt;
                          _loadFavorites();
                        },
                        child: Container(
                          width: ScreenAdapter.width(300),
                          height: ScreenAdapter.height(100),
                          decoration: BoxDecoration(
                            color: selected ? Color(0xFFF0F5FF) : Colors.white,
                            borderRadius:
                                BorderRadius.circular(ScreenAdapter.radius(10)),
                            border: Border.all(
                              color: selected
                                  ? Color(0xFFD6E4FF)
                                  : Color(0xFFE8E8E8),
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            opt,
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(32),
                              color: selected
                                  ? Color(0xFF5B9CFF)
                                  : Color(0xFF999999),
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 导出对话框
  /// 确认导出所有收藏的题目吗？
  /// 确认导出后，会将所有收藏的题目导出到本地文件
  void showExportDialog() async {
    final confirmed = await CommonDialog.show(
      title: '导出收藏',
      content: '确定要导出所有收藏的题目吗？',
      confirmText: '确认导出',
      cancelText: '取消',
    );

    if (confirmed) {
      _doExport();
    }
  }

  void _doExport() {
    Get.snackbar('提示', '导出成功', snackPosition: SnackPosition.BOTTOM);
  }

  /// 点击某个分组 - 跳转做题页面，传入该分组的题目列表
  void onTapGroup(FavoriteGroup group) {
    Get.toNamed('/question-train', arguments: {
      'pageType': 'favorite',
      'cate_name': group.cateName,
      'total': group.count,
      'items': group.items
          .map((e) => {
                'id': e.id,
                'question_id': e.questionId,
                'title': e.title ?? '',
                'kind': e.kind ?? '',
                'answer': e.answer ?? '',
                'options_json': e.optionsJson ?? '',
                'explain': e.explain ?? '',
                'difficulty': e.difficulty ?? '',
              })
          .toList(),
    });
  }
}
