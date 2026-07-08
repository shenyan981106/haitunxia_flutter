import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/api_client.dart';

/// 收藏题目单项模型
class FavoriteItem {
  final int id;
  final int userId;
  final int questionId;
  final int createTime;
  final int updateTime;
  final int? qid;
  final String? kind;
  final String? title;
  final String? answer;
  final String? optionsJson;
  final String? difficulty;
  final String? explain;

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
class FavoriteGroup {
  final String cateName;
  final List<FavoriteItem> items;

  FavoriteGroup({required this.cateName, required this.items});

  int get count => items.length;
}

class MyFavoritesController extends GetxController {
  final RxList<FavoriteGroup> favoriteGroups = <FavoriteGroup>[].obs;
  final RxInt totalCount = 0.obs;
  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;

  // 排序选项状态
  final RxString currentSortTime = '录入时间'.obs;
  final RxString currentSortOrder = '新添加在前'.obs;

  /// 录入时间筛选选项
  static const timeOptions = ['不限', '15天', '30天'];

  /// 排序选项
  static const orderOptions = ['新添加在前', '新添加在后'];

  @override
  void onReady() {
    super.onReady();
    _loadFavorites();
  }

  /// 加载收藏列表（调用 collectList 接口）
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

  /// 选择录入时间筛选
  void selectTime(String time) {
    currentSortTime.value = time;
    _loadFavorites();
  }

  /// 选择排序方式
  void selectOrder(String order) {
    currentSortOrder.value = order;
    _loadFavorites();
  }

  /// 点击某个分组 - 跳转做题页面
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
