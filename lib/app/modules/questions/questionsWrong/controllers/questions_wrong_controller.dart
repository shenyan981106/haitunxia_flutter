import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/providers/api_client.dart';
import '../../../../services/global_project_controller.dart';
import '../../../../services/screenAdapter.dart';

/// 错题单项模型（对 API 返回的单条错题记录）
class WrongItem {
  final int id;
  final int userId;
  final int questionId;
  final int wrongCount; // 错误次数
  final int? createTime;
  final int? updateTime;

  // 嵌套 question 对象字段
  final int? qid;
  final String? kind; // 题型: SINGLE/MULTI/JUDGE
  final String? title; // 题目内容
  final String? answer; // 答案
  final String? optionsJson; // 选项 JSON
  final String? difficulty; // 难度
  final String? explain; // 解析

  WrongItem({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.wrongCount,
    this.createTime,
    this.updateTime,
    this.qid,
    this.kind,
    this.title,
    this.answer,
    this.optionsJson,
    this.difficulty,
    this.explain,
  });

  factory WrongItem.fromJson(dynamic json) {
    if (json is! Map) {
      return WrongItem(
        id: 0,
        userId: 0,
        questionId: 0,
        wrongCount: 0,
      );
    }

    //嵌套 question 对嵌套 question 对象（Map<dynamic, dynamic> -> Map<String, dynamic    Map<String, dynamic>? qMap;
    Map<String, dynamic>? qMap;
    final question = json['question'] ?? json['question_info'];
    if (question is Map) {
      qMap = <String, dynamic>{};
      for (final key in question.keys) {
        qMap[key.toString()] = question[key];
      }
    }

    return WrongItem(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      questionId: json['question_id'] ?? 0,
      wrongCount: json['wrong_count'] ?? json['error_count'] ?? 1,
      createTime: json['createtime'],
      updateTime: json['updatetime'],

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

/// 按分类分组的模型
class WrongGroup {
  final String cateName; // 列表标题（后端直接返回的 cate_name）
  final List<WrongItem> items; // 该分类下的所有错题

  WrongGroup({required this.cateName, required this.items});

  int get count => items.length;
}

/// 错题本页面控制器
class QuestionsWrongController extends GetxController {
  late GlobalProjectController globalController;

  /// 分组后的展示列表（后端已按 cate_name 分好组）
  final RxList<WrongGroup> wrongGroups = <WrongGroup>[].obs;

  /// 所有错题总数
  final RxInt totalCount = 0.obs;

  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;

  // 排序选项状态
  final RxString currentSortTime = '不限'.obs;
  final RxString currentSortOrder = '最近错误在前'.obs;

  @override
  void onInit() {
    super.onInit();
    try {
      globalController = GlobalProjectController.to;
    } catch (e) {
      debugPrint('GlobalProjectController 获取失败: $e');
    }
    Future.delayed(const Duration(milliseconds: 100), () {
      _loadWrongQuestions();
    });
  }

  /// 加载错题列表，调用 wrongList 接口
  /// 后端返回格式与收藏一致 { code: 1, data: { total: N, list: [{ cate_name: "...", items: [...] }] } }
  Future<void> _loadWrongQuestions({bool refresh = false}) async {
    if (refresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final params = <String, dynamic>{};
      params['order'] = currentSortOrder.value == '最近错误在前' ? 'desc' : 'asc';

      // 录入时间筛选
      if (currentSortTime.value != '不限') {
        params['days'] = currentSortTime.value.replaceAll('天', '');
      }

      final response = await ApiClient.to.getExam(
        'question/wrongList',
        queryParameters: params.isEmpty ? null : params,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        debugPrint('错题API返回: $data');

        if (data is Map && data['code'] == 1) {
          final innerData = data['data'];
          if (innerData is! Map) {
            errorMessage.value = '数据格式异常';
            return;
          }

          // 注意：后端可能不返回 total 字段，需根据 list 累计计算
          final listData = innerData['list'];

          final groups = <WrongGroup>[];
          int computedTotal = 0;

          if (listData is List && listData.isNotEmpty) {
            for (final group in listData) {
              if (group is! Map) continue;

              final cateName = group['cate_name']?.toString() ?? '未分组';
              final itemsRaw = group['items'];

              final items = <WrongItem>[];
              if (itemsRaw is List) {
                for (final item in itemsRaw) {
                  items.add(WrongItem.fromJson(item));
                }
              }

              if (items.isNotEmpty) {
                computedTotal += items.length;
                groups.add(WrongGroup(cateName: cateName, items: items));
              }
            }
          }

          // 优先使用后端返回的 total 字段，否则用累计计算
          final totalVal = innerData['total'];
          totalCount.value = totalVal ?? computedTotal;

          wrongGroups.assignAll(groups);

          debugPrint('错题列表加载成功: ${groups.length} 分组, ${totalCount.value} 条');
          for (final g in groups) {
            debugPrint('  - ${g.cateName}: ${g.count} 条');
          }
        } else {
          errorMessage.value =
              data is Map ? (data['msg']?.toString() ?? '获取错题列表失败') : '数据异常';
        }
      } else {
        errorMessage.value = '网络请求失败';
      }
    } catch (e) {
      debugPrint('加载错题列表失败: $e');
      errorMessage.value = '网络错误，请稍后重试';
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  /// 下拉刷新
  Future<void> onRefresh() async => _loadWrongQuestions(refresh: true);

  // 排序选项
  static const _timeOptions = ['不限', '15天', '30天'];
  static const _orderOptions = ['最近错误在前', '最近错误在后'];

  /// 显示录入时间筛选弹窗（紧贴筛选栏下方）与收藏页一致
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
        _loadWrongQuestions();
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

  /// 显示排序方式弹窗（无动画，从顶部弹出）与收藏页一致
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
                          _loadWrongQuestions();
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

  /// 点击某个分组，跳转做题页面与收藏页逻辑一致
  void onTapGroup(WrongGroup group) {
    Get.toNamed('/question-train', arguments: {
      'pageType': 'wrong',
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
                'wrong_count': e.wrongCount,
              })
          .toList(),
    });
  }
}
