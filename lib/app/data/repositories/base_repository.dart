import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/api_response.dart';
import '../providers/api_client.dart';

/// 基础 Repository 类
/// 提供通用的数据访问方法和错误处理
abstract class BaseRepository {
  /// 获取 ApiClient 实例
  ApiClient get apiClient => ApiClient.to;

  /// 获取 Dio 实例
  Dio get dio => apiClient.dio;

  /// 统一处理 API 响应
  /// [response] Dio 响应对象
  /// [fromJson] 数据转换函数
  Future<ApiResponse<T>> handleResponse<T>(
    Response response,
    T? Function(Map<String, dynamic>)? fromJson,
  ) async {
    if (response.statusCode == 200) {
      dynamic raw = response.data;

      // 处理字符串类型的响应数据
      if (raw is String) {
        try {
          // 尝试解析 JSON 字符串
          raw = _parseJson(raw);
        } catch (e) {
          return ApiResponse<T>(
            code: -1,
            message: '响应数据解析失败: $e',
            data: null,
          );
        }
      }

      // 处理 Map 类型的响应数据
      if (raw is Map<String, dynamic>) {
        return ApiResponse<T>.fromJson(raw, fromJson);
      }

      return ApiResponse<T>(
        code: -1,
        message: '未知的响应格式',
        data: null,
      );
    } else {
      return ApiResponse<T>(
        code: response.statusCode ?? -1,
        message: '请求失败: ${response.statusMessage}',
        data: null,
      );
    }
  }

  /// 解析 JSON 字符串，处理可能的多个 JSON 对象连接的情况
  dynamic _parseJson(String jsonString) {
    jsonString = jsonString.trim();

    // 如果字符串以 { 开头，尝试解析为对象
    if (jsonString.startsWith('{')) {
      // 查找第一个完整的 JSON 对象
      int braceCount = 0;
      int endIndex = 0;
      bool inString = false;

      for (int i = 0; i < jsonString.length; i++) {
        String char = jsonString[i];

        if (char == '"' && (i == 0 || jsonString[i - 1] != '\\')) {
          inString = !inString;
        } else if (!inString) {
          if (char == '{') {
            braceCount++;
          } else if (char == '}') {
            braceCount--;
            if (braceCount == 0) {
              endIndex = i + 1;
              break;
            }
          }
        }
      }

      if (endIndex > 0) {
        String firstJson = jsonString.substring(0, endIndex);
        // 使用 dart:convert 解析
        return _jsonDecode(firstJson);
      }
    }

    // 如果字符串以 [ 开头，尝试解析为数组
    if (jsonString.startsWith('[')) {
      return _jsonDecode(jsonString);
    }

    throw FormatException('无法解析 JSON: $jsonString');
  }

  /// 使用 dart:convert 解析 JSON
  dynamic _jsonDecode(String source) {
    return jsonDecode(source);
  }

  /// 统一处理错误
  ApiResponse<T> handleError<T>(dynamic error) {
    String message = '未知错误';
    int code = -1;

    if (error is DioException) {
      message = error.message ?? '网络请求错误';
      code = error.response?.statusCode ?? -1;
    } else if (error is Exception) {
      message = error.toString();
    } else {
      message = error.toString();
    }

    return ApiResponse<T>(
      code: code,
      message: message,
      data: null,
    );
  }

  /// 检查响应是否成功
  bool isSuccess(ApiResponse response) {
    return response.isSuccess;
  }

  /// 获取考试类型代码
  String resolveExamType(String projectName) {
    switch (projectName) {
      case '中级经济师':
        return 'zjjjs';
      case '初级经济师':
        return 'cjjjs';
      case '一级建造师':
        return 'yjjjs';
      case '二级建造师':
        return 'ejjjs';
      case '社会工作者':
        return 'shggz';
      default:
        return 'zjjjs';
    }
  }
}
