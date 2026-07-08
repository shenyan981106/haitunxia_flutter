import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/global_project_controller.dart';
import '../../../data/models/category_model.dart';

class MyBankController extends GetxController {
  late final GlobalProjectController globalController;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final examPapers = <Map<String, dynamic>>[].obs;

  final List<Map<String, dynamic>> mockPapers = [
    {
      'id': 1,
      'title': '2025年中级经济师经济基础知识模拟试卷(一)',
      'join_count': 1285,
      'quantity': 100,
      'total_score': 140,
      'pass_score': 84,
      'limit_time': 90,
    },
    {
      'id': 2,
      'title': '2025年中级经济师经济基础知识模拟试卷(二)',
      'join_count': 986,
      'quantity': 100,
      'total_score': 140,
      'pass_score': 84,
      'limit_time': 90,
    },
    {
      'id': 3,
      'title': '2024年中级经济师经济基础知识真题试卷',
      'join_count': 2568,
      'quantity': 100,
      'total_score': 140,
      'pass_score': 84,
      'limit_time': 90,
    },
    {
      'id': 4,
      'title': '2023年中级经济师经济基础知识真题试卷',
      'join_count': 3241,
      'quantity': 100,
      'total_score': 140,
      'pass_score': 84,
      'limit_time': 90,
    },
    {
      'id': 5,
      'title': '中级经济师章节练习第一卷',
      'join_count': 568,
      'quantity': 30,
      'total_score': 42,
      'pass_score': 25,
      'limit_time': 30,
    }
  ];

  @override
  void onInit() {
    super.onInit();
    globalController = GlobalProjectController.to;
    loadExamPapers();
  }

  Future<void> loadExamPapers() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await Future.delayed(const Duration(milliseconds: 300));

      examPapers.assignAll(mockPapers);
    } catch (e) {
      errorMessage.value = '加载数据失败';
    } finally {
      isLoading.value = false;
    }
  }

  void onPaperTap(Map<String, dynamic> paper) {
    final paperId = paper['id'];
    final title = paper['title'] ?? '';
    final limitTime = paper['limit_time'] ?? 0;
    final totalScore = paper['total_score'] ?? 0;
    final passScore = paper['pass_score'] ?? 0;
    final joinCount = paper['join_count'] ?? 0;

    Get.toNamed(
      '/question-train',
      arguments: {
        'paper_id': paperId,
        'title': title,
        'limit_time': limitTime,
        'total_score': totalScore,
        'pass_score': passScore,
        'join_count': joinCount,
        'mode': 'EXAM',
        'pageType': 'my_bank',
      },
    );
  }
}
