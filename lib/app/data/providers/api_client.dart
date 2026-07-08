import 'dart:io';
import 'package:dio/dio.dart' as dio_package;
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:xmshop/app/config/env_config.dart';
import 'package:xmshop/app/routes/app_pages.dart';
import 'package:xmshop/app/data/services/auth_service.dart';

/// API客户端单例
/// 统一的网络请求层，处理Token自动注入、拦截、统一错误处理
class ApiClient extends GetxService {
  static ApiClient get to => Get.find();

  late final dio_package.Dio _dio;

  /// 获取Dio实例
  dio_package.Dio get dio => _dio;

  @override
  void onInit() {
    super.onInit();
    _initDio();
    _setupInterceptors();
  }

  /// 初始化Dio配置
  void _initDio() {
    _dio = dio_package.Dio(
      dio_package.BaseOptions(
        baseUrl: EnvConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 忽略SSL证书错误（用于开发环境或自签名证书）
    // 仅在支持的平台上执行，避免鸿蒙等平台报错
    _configureSSLCertificate();
  }

  /// 平台相关的 SSL 证书配置
  void _configureSSLCertificate() {
    try {
      // 检查是否为支持 IOHttpClientAdapter 的平台
      // Android、iOS、macOS、Linux、Windows 支持
      // 鸿蒙可能使用不同的 HTTP 适配器
      if (_dio.httpClientAdapter is IOHttpClientAdapter) {
        (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
          final client = HttpClient();
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        };
      }
      // 如果不是 IOHttpClientAdapter（如鸿蒙平台），跳过 SSL 自定义配置
      // 鸿蒙平台的 SSL 证书通过系统默认配置处理
    } catch (e) {
      // 捕获任何平台不兼容导致的异常
      debugPrint('SSL 证书配置跳过（当前平台可能不支持自定义）: $e');
    }
  }

  /// 设置拦截器
  void _setupInterceptors() {
    _dio.interceptors.add(
      dio_package.InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );

    // 日志拦截器（仅开发环境）
    if (EnvConfig.enableLog) {
      _dio.interceptors.add(dio_package.LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (o) => debugPrint(o.toString()),
      ));
    }
  }

  /// 请求拦截
  void _onRequest(dio_package.RequestOptions options,
      dio_package.RequestInterceptorHandler handler) {
    // 自动注入Token
    if (Get.isRegistered<AuthService>()) {
      final token = AuthService.to.token.value;
      if (token != null && token.isNotEmpty) {
        options.headers['token'] = token;
      }
    }

    if (EnvConfig.enableLog) {
      debugPrint('🌐 REQUEST[${options.method}] => PATH: ${options.path}');
    }

    handler.next(options);
  }

  /// 响应拦截
  void _onResponse(dio_package.Response response,
      dio_package.ResponseInterceptorHandler handler) {
    if (EnvConfig.enableLog) {
      debugPrint(
          '🌐 RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
      debugPrint('📦 RESPONSE DATA: ${response.data}');
    }

    // 处理业务错误
    final data = response.data;
    if (data is Map) {
      final code = data['code'];
      if (code != null && code != 0 && code != 1 && code != 200) {
        // 业务错误，不中断流程，由调用方处理
      }
    }

    handler.next(response);
  }

  /// 错误拦截
  Future<void> _onError(dio_package.DioException err,
      dio_package.ErrorInterceptorHandler handler) async {
    if (EnvConfig.enableLog) {
      debugPrint('🌐 ERROR[${err.type}] => PATH: ${err.requestOptions.path}');
    }

    switch (err.type) {
      case dio_package.DioExceptionType.connectionTimeout:
      case dio_package.DioExceptionType.sendTimeout:
      case dio_package.DioExceptionType.receiveTimeout:
        err = dio_package.DioException(
          requestOptions: err.requestOptions,
          type: err.type,
          message: '网络连接超时，请稍后重试',
        );
        break;

      case dio_package.DioExceptionType.connectionError:
        err = dio_package.DioException(
          requestOptions: err.requestOptions,
          type: err.type,
          message: '网络连接失败，请检查网络设置',
        );
        break;

      case dio_package.DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        if (statusCode == 401) {
          // Token过期或无效，跳转登录页面
          if (Get.isRegistered<AuthService>()) {
            AuthService.to.clearAuth();
          }
          // 防止重复跳转
          if (!Get.currentRoute.startsWith(Routes.LOGIN)) {
            Get.offAllNamed(Routes.LOGIN);
          }
          err = dio_package.DioException(
            requestOptions: err.requestOptions,
            type: err.type,
            message: '登录已过期，请重新登录',
          );
        } else if (statusCode == 403) {
          err = dio_package.DioException(
            requestOptions: err.requestOptions,
            type: err.type,
            message: '没有权限访问该资源',
          );
        } else if (statusCode == 404) {
          err = dio_package.DioException(
            requestOptions: err.requestOptions,
            type: err.type,
            message: '请求的资源不存在',
          );
        } else if (statusCode != null && statusCode >= 500) {
          err = dio_package.DioException(
            requestOptions: err.requestOptions,
            type: err.type,
            message: '服务器繁忙，请稍后重试',
          );
        }
        break;

      case dio_package.DioExceptionType.cancel:
        err = dio_package.DioException(
          requestOptions: err.requestOptions,
          type: err.type,
          message: '请求已取消',
        );
        break;

      default:
        if (err.message?.contains('SocketException') == true) {
          err = dio_package.DioException(
            requestOptions: err.requestOptions,
            type: err.type,
            message: '网络连接失败，请检查网络设置',
          );
        }
    }

    handler.next(err);
  }

  // ==================== 便捷请求方法 ====================

  /// GET请求
  Future<dio_package.Response<T>> get<T>(
    String path, {
    String? baseUrl,
    Map<String, dynamic>? queryParameters,
    dio_package.Options? options,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST请求
  Future<dio_package.Response<T>> post<T>(
    String path, {
    String? baseUrl,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio_package.Options? options,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT请求
  Future<dio_package.Response<T>> put<T>(
    String path, {
    String? baseUrl,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio_package.Options? options,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE请求
  Future<dio_package.Response<T>> delete<T>(
    String path, {
    String? baseUrl,
    Map<String, dynamic>? queryParameters,
    dio_package.Options? options,
  }) async {
    return _dio.delete<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// 考试相关API请求
  Future<dio_package.Response<T>> exam<T>(
    String path, {
    String method = 'GET',
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final examPath = 'addons/exam/$path';
    switch (method.toUpperCase()) {
      case 'POST':
        return post<T>(examPath, data: data, queryParameters: queryParameters);
      case 'PUT':
        return put<T>(examPath, data: data, queryParameters: queryParameters);
      case 'DELETE':
        return delete<T>(examPath, queryParameters: queryParameters);
      default:
        return get<T>(examPath, queryParameters: queryParameters);
    }
  }

  /// 获取考试相关数据（兼容旧代码）
  Future<dio_package.Response<T>> getExam<T>(String path,
      {Map<String, dynamic>? queryParameters}) async {
    return get<T>('addons/exam/$path', queryParameters: queryParameters);
  }

  /// 提交考试相关数据（兼容旧代码）
  Future<dio_package.Response<T>> postExam<T>(String path,
      {dynamic data}) async {
    return post<T>('addons/exam/$path', data: data);
  }

  /// 获取通用插件数据（addons/common/ 前缀）
  Future<dio_package.Response<T>> getCommon<T>(String path,
      {Map<String, dynamic>? queryParameters}) async {
    return get<T>('addons/common/$path', queryParameters: queryParameters);
  }

  /// 上传文件到考试插件
  Future<dio_package.Response<T>> uploadFile<T>(String filePath) async {
    final formData = dio_package.FormData.fromMap({
      'file': await dio_package.MultipartFile.fromFile(filePath),
    });
    return post<T>('/api/common/upload', data: formData);
  }

  /// 获取完整的图片URL（使用CDN域名）
  static String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;
    return '${EnvConfig.cdnUrl}${imagePath}'.replaceAll('\\', '/');
  }

  /// 兼容旧代码的图片URL处理
  static String replaceUri(String? picUrl) {
    return getFullImageUrl(picUrl);
  }

  /// 初始化接口（版本检测、上传配置等）
  /// [version] 当前APP版本号
  /// [lng] 经度
  /// [lat] 纬度
  Future<dio_package.Response<T>> initApp<T>({
    required String version,
    String lng = '',
    String lat = '',
  }) async {
    return post<T>(
      '/api/common/init',
      queryParameters: {
        'version': version,
        'lng': lng,
        'lat': lat,
      },
    );
  }
}
