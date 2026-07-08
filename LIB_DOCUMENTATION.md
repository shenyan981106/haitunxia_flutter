# Lib 目录详细文档

## 目录结构概览

```
lib/
├── main.dart                          # 应用入口文件
└── app/
    ├── components/                    # 可复用组件
    │   ├── customer_service_dialog.dart
    │   └── verification_code_input.dart
    ├── config/                        # 配置文件
    │   └── env_config.dart
    ├── data/                          # 数据层
    │   ├── models/                    # 数据模型
    │   ├── providers/                 # 数据提供者
    │   ├── repositories/              # 数据仓库
    │   └── services/                  # 业务服务
    ├── modules/                       # 功能模块
    │   ├── home/
    │   ├── login/
    │   ├── project/
    │   ├── questions/
    │   ├── study/
    │   ├── tabs/
    │   └── user/
    ├── routes/                        # 路由配置
    │   ├── app_pages.dart
    │   └── app_routes.dart
    └── services/                      # 应用服务
```

---

## 1. 入口文件

### main.dart

**文件路径**: `lib/main.dart`

**功能描述**:
- Flutter 应用的入口点
- 初始化核心服务和依赖注入
- 配置状态栏样式
- 配置屏幕适配
- 设置初始路由

**核心流程**:
```
1. WidgetsFlutterBinding.ensureInitialized()  - 确保 Flutter 绑定初始化
2. SystemChrome.setSystemUIOverlayStyle()    - 设置状态栏透明
3. GetStorage.init()                          - 初始化本地存储
4. 注册核心服务（永久实例）:
   - ApiClient
   - AuthService
   - RepositoryProvider（初始化所有仓库）
   - GlobalProjectController
5. 确定初始路由（根据登录状态）
6. ScreenUtilInit + GetMaterialApp 启动应用
```

**关键依赖**:
- `package:flutter/material.dart`
- `package:get/get.dart`
- `package:get_storage/get_storage.dart`
- `package:flutter_screenutil/flutter_screenutil.dart`
- `package:flutter_smart_dialog/flutter_smart_dialog.dart`

---

## 2. Components 组件层

### 2.1 customer_service_dialog.dart

**文件路径**: `lib/app/components/customer_service_dialog.dart`

**功能描述**:
- 客服对话框组件
- 显示扫码添加老师的弹窗
- 包含二维码图片、权益说明和操作按钮

**类定义**:
```dart
class CustomerServiceDialog {
  static void show() { ... }
}
```

**主要功能**:
- 显示居中的 Material 弹窗
- 加载老师二维码图片
- 展示加群权益（备考资料、报考指导、学习规划、惊喜大奖）
- 关闭弹窗时提示用户截屏后在微信中扫码

**UI 元素**:
- 白色圆角容器（宽度自适应）
- 标题："扫码添加老师"
- 二维码图片区域（带边框）
- 权益说明框（浅蓝背景）
- 蓝色主按钮
- 右上角关闭图标

**依赖**:
- `package:flutter/material.dart`
- `package:get/get.dart`
- `../services/screenAdapter.dart`
- `../config/env_config.dart`
- `../services/snackbar_utils.dart`

---

### 2.2 verification_code_input.dart

**文件路径**: `lib/app/components/verification_code_input.dart`

**功能描述**:
- 验证码输入组件
- 支持自定义长度的验证码输入框
- 每个输入框独立的焦点管理
- 自动聚焦到下一个输入框
- 输入完成时的回调通知

**类定义**:
```dart
class VerificationCodeInput extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final TextStyle? textStyle;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final double? borderRadius;
  final double? width;
  final double? height;
  final List<BoxShadow>? boxShadow;
  
  const VerificationCodeInput({...});
}

class _VerificationCodeInputState extends State<VerificationCodeInput> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  late String _code;
  
  Widget _buildInputBox(int index) { ... }
  void _onInputChanged(int index, String value) { ... }
  String getCode() { ... }
}
```

**主要属性**:
- `length`: 验证码长度（默认 6 位）
- `onCompleted`: 输入完成回调
- `onChanged`: 输入变化回调
- `textStyle`: 文字样式
- `fillColor`: 填充色（默认浅灰）
- `borderColor`: 边框色（默认浅灰）
- `focusedBorderColor`: 聚焦时边框色（默认蓝色）
- `borderRadius`: 圆角半径
- `width/height`: 单个输入框尺寸
- `boxShadow`: 阴影效果

**核心功能**:
- 为每个输入框创建独立的 FocusNode 和 TextEditingController
- 自动聚焦第一个输入框
- 输入一位数字后自动聚焦到下一位
- 删除时自动聚焦到上一位
- 支持焦点状态的边框颜色变化
- 仅允许输入数字

**依赖**:
- `package:flutter/material.dart`
- `package:flutter/services.dart`

---

## 3. Config 配置层

### 3.1 env_config.dart

**文件路径**: `lib/app/config/env_config.dart`

**功能描述**:
- 环境配置类
- 定义 API 基础地址
- 配置日志开关

**类定义**:
```dart
class EnvConfig {
  static const String baseUrl = 'https://ceshi.zgjan.cn/';
  static const bool enableLog = true;
}
```

**配置项**:
- `baseUrl`: API 基础地址（测试环境）
- `enableLog`: 是否启用网络请求日志（开发模式开启）

---

## 4. Data 数据层

### 4.1 Models 数据模型

#### api_response.dart

**文件路径**: `lib/app/data/models/api_response.dart`

**功能描述**:
- API 统一响应模型
- 处理服务端返回的标准数据格式
- 支持业务状态码判断
- 包含通用列表数据和考试倒计时模型

**类定义**:

```dart
class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;
  final int? timestamp;
  
  factory ApiResponse.fromJson(Map<String, dynamic> json, T? Function(Map<String, dynamic>)? fromJsonT);
  bool get isSuccess => code == 0 || code == 200;
  Map<String, dynamic> toJson();
}

class ExamCountdown {
  final int remainDays;
  final String remainText;
  final String? examDate;
  
  factory ExamCountdown.fromJson(Map<String, dynamic>? json);
}

class ListData<T> {
  final List<T>? list;
  final int? total;
  final int? page;
  final int? pageSize;
  
  factory ListData.fromJson(Map<String, dynamic>? json, T? Function(Map<String, dynamic>)? fromJsonT);
}
```

**主要功能**:
- `ApiResponse`: 封装 API 响应的通用结构
  - `code`: 业务状态码（0 或 200 表示成功）
  - `message`: 响应消息
  - `data`: 响应数据（泛型）
  - `timestamp`: 时间戳
  - `isSuccess`: 判断是否成功的 getter

- `ExamCountdown`: 考试倒计时信息
  - `remainDays`: 剩余天数
  - `remainText`: 剩余时间文本
  - `examDate`: 考试日期

- `ListData`: 分页列表数据
  - `list`: 数据列表
  - `total`: 总数量
  - `page`: 当前页码
  - `pageSize`: 每页数量

---

#### user_model.dart

**文件路径**: `lib/app/data/models/user_model.dart`

**功能描述**:
- 用户数据模型
- 存储登录用户的基本信息
- 支持 JSON 序列化/反序列化

**类定义**:

```dart
class UserModel {
  final int? id;
  final String? nickname;
  final String? mobile;
  final String? avatar;
  
  factory UserModel.fromJson(Map<String, dynamic>? json);
  Map<String, dynamic> toJson();
  UserModel copyWith({...});
}
```

**字段说明**:
- `id`: 用户 ID
- `nickname`: 昵称
- `mobile`: 手机号
- `avatar`: 头像 URL

**特殊处理**:
- `avatar` 字段支持多种字段名解析：`avatar`、`headimg`、`head_img`
- 提供 `copyWith` 方法用于创建新实例并修改部分属性

---

#### project_model.dart

**文件路径**: `lib/app/data/models/project_model.dart`

**功能描述**:
- 考试项目数据模型
- 存储考试项目的基本信息

**类定义**:

```dart
class Project {
  final String id;
  final String name;
  final String code;
  final String description;
  final String icon;
  final bool isActive;
  final int subjectCount;
  final int questionCount;
  
  factory Project.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  @override String toString();
}
```

**字段说明**:
- `id`: 项目 ID
- `name`: 项目名称（如：中级经济师、一级建造师）
- `code`: 项目代码（如：zjjjs、yjjjs）
- `description`: 项目描述
- `icon`: 图标 URL
- `isActive`: 是否激活
- `subjectCount`: 科目数量
- `questionCount`: 题目总数

---

#### question_model.dart

**文件路径**: `lib/app/data/models/question_model.dart`

**功能描述**:
- 题目相关数据模型
- 包含章节、小节和题目的完整结构

**类定义**:

```dart
class ChapterModel {
  final String title;
  final List<SectionModel> sections;
  
  factory ChapterModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}

class SectionModel {
  final String title;
  final int questionCount;
  final int doneCount;
  final int accuracy;
  final String? difficulty;
  final String? status;
  final List<SubsectionModel>? subsections;
  
  factory SectionModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}

class SubsectionModel {
  final String title;
  final int count;
  final String difficulty;
  final String status;
  
  factory SubsectionModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}

class Question {
  final String id;
  final String projectId;
  final String subjectId;
  final String type; // single/multi/judgment
  final String kind; // X, JUDGE, SINGLE, MULTI, FILL, SHORT, MATERIAL
  final String content;
  final List<String> options;
  final List<int> correctAnswers;
  final String? answer;
  final String explanation;
  final String difficulty;
  final String? videoUrl;
  final bool isCollected;
  
  factory Question.fromJson(Map<String, dynamic> json);
}
```

**结构说明**:
- `ChapterModel`: 章节模型
  - `title`: 章节标题
  - `sections`: 小节列表

- `SectionModel`: 小节模型
  - `title`: 小节标题
  - `questionCount`: 题目数量
  - `doneCount`: 已做数量
  - `accuracy`: 正确率
  - `difficulty`: 难度
  - `status`: 状态
  - `subsections`: 子小节列表（可选）

- `SubsectionModel`: 子小节模型
  - `title`: 子小节标题
  - `count`: 题目数量
  - `difficulty`: 难度
  - `status`: 状态

- `Question`: 题目模型
  - `id`: 题目 ID
  - `projectId`: 项目 ID
  - `subjectId`: 科目 ID
  - `type`: 题目类型（single 单选、multi 多选、judgment 判断）
  - `kind`: 题目种类（X、JUDGE、SINGLE、MULTI、FILL、SHORT、MATERIAL）
  - `content`: 题目内容
  - `options`: 选项列表
  - `correctAnswers`: 正确答案索引列表
  - `answer`: 答案文本（可选）
  - `explanation`: 解析
  - `difficulty`: 难度
  - `videoUrl`: 视频讲解 URL（可选）
  - `isCollected`: 是否已收藏

---

#### home_model.dart

**文件路径**: `lib/app/data/models/home_model.dart`

**功能描述**:
- 首页相关数据模型
- 包含公告、直播间、积分、轮播图、课程、试卷等数据

**类定义**:

```dart
class HomeData {
  final List<HomeNotice> notices;
  final List<HomeRoom> rooms;
  final HomePoint? point;
  final HomeSystem? system;
  final List<HomeSlide> slides;
  final List<HomeCourse> courses;
  final List<HomePaper> papers;
  
  factory HomeData.fromJson(Map<String, dynamic> json);
}

class HomeSystem {
  final String loginChannel;
  factory HomeSystem.fromJson(Map<String, dynamic> json);
}

class HomeNotice {
  final int id;
  final String name;
  final String statusText;
  final String createTimeText;
  factory HomeNotice.fromJson(Map<String, dynamic> json);
}

class HomeRoom {
  final int id;
  final String name;
  final String contents;
  final String coverImage;
  final int cateId;
  final int subjectId;
  final int paperId;
  final int peopleCount;
  final int startTime;
  final int endTime;
  final int weigh;
  final String status;
  final String signupMode;
  final int isMakeup;
  final int makeupCount;
  final int isRank;
  final int signupCount;
  final int gradeCount;
  final int passCount;
  final String passRate;
  final int certConfigId;
  final int isCreateQrcodeH5;
  final dynamic qrcodeH5;
  final int createtime;
  final int updatetime;
  final dynamic deletetime;
  final List<dynamic> users;
  final String startTimeText;
  final String endTimeText;
  final String statusText;
  final String signupModeText;
  final String isMakeupText;
  
  factory HomeRoom.fromJson(Map<String, dynamic> json);
}

class HomePoint {
  final int getPoint;
  final String type;
  factory HomePoint.fromJson(Map<String, dynamic> json);
}

class HomeSlide {
  final int id;
  final String title;
  final String image;
  final String url;
  factory HomeSlide.fromJson(Map<String, dynamic> json);
}

class HomeCourse {
  final int id;
  final String title;
  final String coverImage;
  final String price;
  final String salePrice;
  final int categoryId;
  final String categoryName;
  factory HomeCourse.fromJson(Map<String, dynamic> json);
}

class HomePaper {
  final int id;
  final String name;
  final String coverImage;
  final int paperId;
  final int subjectId;
  final int questionCount;
  final int finishCount;
  factory HomePaper.fromJson(Map<String, dynamic> json);
}
```

**模型说明**:
- `HomeData`: 首页数据聚合
- `HomeNotice`: 公告模型
- `HomeRoom`: 直播间模型（包含直播信息、报名人数、通过率等）
- `HomePoint`: 积分模型
- `HomeSlide`: 轮播图模型
- `HomeCourse`: 课程模型
- `HomePaper`: 试卷模型

---

#### global_project_model.dart

**文件路径**: `lib/app/data/models/global_project_model.dart`

**功能描述**:
- 全局项目相关数据模型
- 简化版本的首页数据模型

**类定义**:

```dart
class GlobalExamCountdown {
  final String examType;
  final String target;
  final int remainSeconds;
  final int remainDays;
  final String remainText;
  
  factory GlobalExamCountdown.fromJson(Map<String, dynamic> json);
}

class GlobalSystem {
  final String loginChannel;
  factory GlobalSystem.fromJson(Map<String, dynamic> json);
}

class GlobalNotice {
  final int id;
  final String name;
  final String statusText;
  final String createTimeText;
  factory GlobalNotice.fromJson(Map<String, dynamic> json);
}

class GlobalRoom {
  final int id;
  final String name;
  final String contents;
  final String startTimeText;
  final String endTimeText;
  final String statusText;
  factory GlobalRoom.fromJson(Map<String, dynamic> json);
}

class GlobalPoint {
  final int getPoint;
  final String type;
  factory GlobalPoint.fromJson(Map<String, dynamic> json);
}
```

**说明**:
- 这些是简化版本的模型，用于全局项目控制器
- 只保留了核心字段，结构与 home_model 中对应的模型类似

---

#### category_model.dart

**文件路径**: `lib/app/data/models/category_model.dart`

**功能描述**:
- 分类数据模型
- 支持多级分类结构（最多三级）
- 包含完整的数据验证和类型转换

**类定义**:

```dart
class Category {
  final int id;
  final String name;
  final List<CategoryChild> children;
  
  factory Category.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}

class CategoryChild {
  final int id;
  final String name;
  final int parentId;
  final int weigh;
  final List<CategoryChild> children;
  
  factory CategoryChild.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

**字段说明**:
- `id`: 分类 ID
- `name`: 分类名称
- `parentId`: 父分类 ID
- `weigh`: 权重（排序用）
- `children`: 子分类列表

**特殊处理**:
- 完整的数据类型验证
- 支持 String 类型的 ID 自动转换为 int
- 支持字段缺失时的默认值处理
- 递归解析子分类（支持三级分类结构）

---

#### subject_model.dart

**文件路径**: `lib/app/data/models/subject_model.dart`

**功能描述**:
- 科目数据模型
- 存储考试科目的基本信息和学习进度

**类定义**:

```dart
class Subject {
  final String id;
  final String projectId;
  final String name;
  final String description;
  final String icon;
  final int chapterCount;
  final int questionCount;
  final double progress;
  
  factory Subject.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

**字段说明**:
- `id`: 科目 ID
- `projectId`: 所属项目 ID
- `name`: 科目名称
- `description`: 科目描述
- `icon`: 图标 URL
- `chapterCount`: 章节数量
- `questionCount`: 题目总数
- `progress`: 学习进度（0.0 - 1.0）

---

#### question_list_model.dart

**文件路径**: `lib/app/data/models/question_list_model.dart`

**功能描述**:
- 题目列表数据模型（旧版本，主要在 repository 中使用）
- 包含题目信息、提交结果、练习记录等

**说明**: 该文件中的模型主要在 `exam_repository.dart` 中定义和使用，参见下文

---

#### plist_model.dart

**文件路径**: `lib/app/data/models/plist_model.dart`

**功能描述**:
- 项目列表数据模型（当前未找到实际定义，可能为旧版本或缺失）

---

#### focus_model.dart

**文件路径**: `lib/app/data/models/focus_model.dart`

**功能描述**:
- 焦点图/轮播图数据模型（当前未找到实际定义，可能为旧版本或缺失）

---

### 4.2 Providers 数据提供者

#### api_client.dart

**文件路径**: `lib/app/data/providers/api_client.dart`

**功能描述**:
- API 客户端单例
- 封装 Dio 网络请求库
- 统一处理 Token 注入、401 拦截、错误处理
- 提供便捷的请求方法

**类定义**:

```dart
class ApiClient extends GetxService {
  static ApiClient get to => Get.find();
  late final Dio _dio;
  
  @override void onInit();
  void _initDio();
  void _setupInterceptors();
  void _onRequest(RequestOptions options, RequestInterceptorHandler handler);
  void _onResponse(Response response, ResponseInterceptorHandler handler);
  Future<void> _onError(DioException err, ErrorInterceptorHandler handler);
  
  Future<Response<T>> get<T>(String path, {...});
  Future<Response<T>> post<T>(String path, {...});
  Future<Response<T>> put<T>(String path, {...});
  Future<Response<T>> delete<T>(String path, {...});
  
  Future<Response<T>> exam<T>(String path, {...});
  Future<Response<T>> getExam<T>(String path, {...});
  Future<Response<T>> postExam<T>(String path, {...});
  Future<Response<T>> getCommon<T>(String path, {...});
  
  static String getFullImageUrl(String? imagePath);
  static String replaceUri(String? picUrl);
}
```

**核心功能**:

**1. Dio 初始化**
- 配置基础 URL：`EnvConfig.baseUrl`
- 配置连接超时、接收超时、发送超时：10 秒
- 设置默认请求头：`Content-Type: application/json`、`Accept: application/json`
- 忽略 SSL 证书错误（开发环境）

**2. 拦截器配置**
- **请求拦截器**：自动从 AuthService 获取 Token 并注入到请求头
- **响应拦截器**：处理业务错误码（仅记录日志）
- **错误拦截器**：统一处理各类网络错误
  - 超时：显示"网络连接超时"
  - 连接失败：显示"网络连接失败"
  - 401：清除认证状态并跳转登录页
  - 403：显示"没有权限访问"
  - 404：显示"请求的资源不存在"
  - 500+：显示"服务器繁忙"
  - 其他：显示"网络连接失败"
- **日志拦截器**：开发环境下打印请求和响应详情

**3. 便捷请求方法**
- `get<T>()`: GET 请求
- `post<T>()`: POST 请求
- `put<T>()`: PUT 请求
- `delete<T>()`: DELETE 请求

**4. 考试专用方法**
- `exam<T>()`: 通用考试 API 请求（自动添加 `addons/exam/` 前缀）
- `getExam<T>()`: 获取考试相关数据（兼容旧代码）
- `postExam<T>()`: 提交考试相关数据（兼容旧代码）
- `getCommon<T>()`: 获取通用插件数据（`addons/common/` 前缀）

**5. 图片 URL 处理**
- `getFullImageUrl()`: 拼接完整图片 URL
- `replaceUri()`: 兼容旧代码的图片 URL 处理（别名）

**依赖**:
- `dart:io`
- `package:dio/dio.dart`
- `package:dio/io.dart`
- `package:flutter/foundation.dart`
- `package:get/get.dart`
- `../config/env_config.dart`
- `../routes/app_pages.dart`
- `../services/auth_service.dart`

---

### 4.3 Repositories 数据仓库

#### base_repository.dart

**文件路径**: `lib/app/data/repositories/base_repository.dart`

**功能描述**:
- 基础仓库类
- 提供通用的数据访问方法
- 统一处理 API 响应和错误
- 包含考试类型解析工具

**类定义**:

```dart
abstract class BaseRepository {
  ApiClient get apiClient => ApiClient.to;
  Dio get dio => apiClient.dio;
  
  Future<ApiResponse<T>> handleResponse<T>(Response response, T? Function(Map<String, dynamic>)? fromJson);
  dynamic _parseJson(String jsonString);
  dynamic _jsonDecode(String source);
  ApiResponse<T> handleError<T>(dynamic error);
  bool isSuccess(ApiResponse response);
  String resolveExamType(String projectName);
}
```

**核心方法**:

**1. handleResponse()**
- 统一处理 API 响应
- 支持 JSON 字符串和 Map 类型的响应数据
- 处理多个 JSON 对象连接的情况（寻找第一个完整的 JSON）
- 使用 fromJson 回调转换数据类型

**2. handleError()**
- 统一处理错误
- 支持 DioException 和其他异常类型
- 返回标准化的 ApiResponse 错误格式

**3. resolveExamType()**
- 根据项目名称解析考试类型代码
- 支持的映射关系：
  - 中级经济师 → zjjjs
  - 初级经济师 → cjjjs
  - 一级建造师 → yjjjs
  - 二级建造师 → ejjjs
  - 社会工作者 → shggz
  - 其他 → zjjjs（默认）

**4. isSuccess()**
- 判断 API 响应是否成功的快捷方法

**依赖**:
- `dart:convert`
- `package:dio/dio.dart`
- `../models/api_response.dart`
- `../providers/api_client.dart`

---

#### exam_repository.dart

**文件路径**: `lib/app/data/repositories/exam_repository.dart`

**功能描述**:
- 考试相关数据仓库
- 处理考试项目、科目、章节、题目、收藏、错题等数据的获取和提交
- 继承自 BaseRepository

**类定义**:

```dart
class ExamRepository extends BaseRepository {
  static ExamRepository get to => Get.find<ExamRepository>();
  
  Future<ApiResponse<GlobalExamData>> getCommonIndex(String examType);
  Future<ApiResponse<HomeData>> getHomeData({required String subjectId});
  Future<ApiResponse<GlobalExamCountdown>> getExamCountdown(String examType);
  Future<ApiResponse<List<SubjectInfo>>> getSubjects(String projectId);
  Future<ApiResponse<List<ChapterInfo>>> getChapters(String subjectId);
  Future<ApiResponse<QuestionListData>> getQuestions(Map<String, dynamic> params);
  Future<ApiResponse<QuestionInfo>> getQuestionDetail(String questionId);
  Future<ApiResponse<SubmitResult>> submitAnswer(Map<String, dynamic> data);
  Future<ApiResponse<PracticeRecordData>> getPracticeRecords(Map<String, dynamic> params);
  Future<ApiResponse<List<FavoriteInfo>>> getFavorites(Map<String, dynamic> params);
  Future<ApiResponse<void>> addFavorite(String questionId);
  Future<ApiResponse<void>> removeFavorite(String questionId);
  Future<ApiResponse<List<WrongQuestionInfo>>> getWrongQuestions(Map<String, dynamic> params);
}
```

**API 方法详细说明**:

**1. getCommonIndex()**
- 获取首页公共数据
- 参数：`examType` - 考试类型代码
- 端点：`addons/exam/common/index`
- 返回：`GlobalExamData`

**2. getHomeData()**
- 获取首页数据（按科目）
- 参数：`subjectId` - 科目 ID
- 端点：`addons/exam/common/index`
- 返回：`HomeData`

**3. getExamCountdown()**
- 获取考试倒计时信息
- 参数：`examType` - 考试类型代码
- 返回：`GlobalExamCountdown`

**4. getSubjects()**
- 获取科目列表
- 参数：`projectId` - 项目 ID
- 端点：`addons/exam/subject/list`
- 返回：`List<SubjectInfo>`

**5. getChapters()**
- 获取章节列表
- 参数：`subjectId` - 科目 ID
- 端点：`addons/exam/chapter/list`
- 返回：`List<ChapterInfo>`

**6. getQuestions()**
- 获取题目列表
- 参数：`params` - 查询参数（科目、章节、类型等）
- 端点：`addons/exam/question/list`
- 返回：`QuestionListData`

**7. getQuestionDetail()**
- 获取题目详情
- 参数：`questionId` - 题目 ID
- 端点：`addons/exam/question/detail`
- 返回：`QuestionInfo`

**8. submitAnswer()**
- 提交答案
- 参数：`data` - 答题数据
- 端点：`addons/exam/answer/submit`（POST）
- 返回：`SubmitResult`

**9. getPracticeRecords()**
- 获取练习记录
- 参数：`params` - 查询参数
- 端点：`addons/exam/practice/records`
- 返回：`PracticeRecordData`

**10. getFavorites()**
- 获取收藏列表
- 参数：`params` - 查询参数
- 端点：`addons/exam/favorite/list`
- 返回：`List<FavoriteInfo>`

**11. addFavorite()**
- 添加收藏
- 参数：`questionId` - 题目 ID
- 端点：`addons/exam/favorite/add`（POST）
- 返回：`void`

**12. removeFavorite()**
- 取消收藏
- 参数：`questionId` - 题目 ID
- 端点：`addons/exam/favorite/remove`（POST）
- 返回：`void`

**13. getWrongQuestions()**
- 获取错题本
- 参数：`params` - 查询参数
- 端点：`addons/exam/wrong/list`
- 返回：`List<WrongQuestionInfo>`

**Repository 中定义的数据模型**:

该文件还定义了多个数据模型类（位于文件末尾）：

```dart
class GlobalExamData {
  final GlobalSystem? system;
  final List<GlobalNotice>? notices;
  final List<GlobalRoom>? rooms;
  final GlobalPoint? point;
  final GlobalExamCountdown? examCountdown;
  factory GlobalExamData.fromJson(Map<String, dynamic> json);
}

class SubjectInfo { ... }
class ChapterInfo { ... }
class QuestionListData { ... }
class QuestionInfo { ... }
class SubmitResult { ... }
class PracticeRecordData { ... }
class PracticeRecord { ... }
class FavoriteInfo { ... }
class WrongQuestionInfo { ... }
```

这些模型主要用于该 Repository 的 API 响应解析，结构与 models 目录中的类似但更简化。

**依赖**:
- `package:get/get.dart`
- `../models/api_response.dart`
- `../models/global_project_model.dart`
- `../models/home_model.dart`
- `base_repository.dart`

---

#### repository_provider.dart

**文件路径**: `lib/app/data/repositories/repository_provider.dart`

**功能描述**:
- 仓库提供者
- 初始化并注册所有 Repository 实例

**说明**: 该文件负责在应用启动时初始化所有数据仓库，具体实现参见 main.dart

---

### 4.4 Services 业务服务

#### auth_service.dart

**文件路径**: `lib/app/data/services/auth_service.dart`

**功能描述**:
- 认证服务
- 管理登录状态、Token、用户信息
- 使用 GetxService 实现全局单例
- 本地持久化认证状态

**类定义**:

```dart
class AuthService extends GetxService {
  static AuthService get to => Get.find();
  
  final GetStorage _storage = GetStorage();
  
  final RxBool isLoggedIn = false.obs;
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxnString token = RxnString();
  final RxBool isLoading = false.obs;
  
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';
  
  @override void onInit();
  void _loadAuthState();
  void _saveAuthState(String newToken, UserModel newUser);
  void _clearState();
  
  void setAuth(String newToken, UserModel newUser);
  void clearAuth();
  void updateUser(UserModel updatedUser);
  bool checkLogin();
  
  int? get userId => user.value?.id;
  String? get nickname => user.value?.nickname ?? user.value?.mobile;
  String? get avatar => user.value?.avatar;
  
  void printUserInfo();
}
```

**核心功能**:

**1. 响应式状态**
- `isLoggedIn`: 登录状态（响应式）
- `user`: 用户信息（响应式）
- `token`: Token 字符串（响应式）
- `isLoading`: 加载状态（响应式）

**2. 本地持久化**
- 使用 GetStorage 存储 Token 和用户信息
- 存储 Key：`auth_token`、`auth_user`

**3. 生命周期**
- `onInit()`: 服务初始化时调用，自动加载本地存储的认证状态

**4. 公开方法**
- `setAuth()`: 设置认证状态（登录成功后调用）
- `clearAuth()`: 清除认证状态（登出或 Token 过期时调用）
- `updateUser()`: 更新用户信息
- `checkLogin()`: 检查是否已登录
- `printUserInfo()`: 打印当前用户信息（调试用）

**5. 便捷属性**
- `userId`: 获取用户 ID
- `nickname`: 获取昵称（优先显示昵称，没有则显示手机号）
- `avatar`: 获取头像 URL

**依赖**:
- `package:dio/dio.dart`
- `package:flutter/foundation.dart`
- `package:get/get.dart`
- `package:get_storage/get_storage.dart`
- `../models/user_model.dart`
- `../providers/api_client.dart`

---

## 5. Services 应用服务层

### 5.1 global_project_controller.dart

**文件路径**: `lib/app/services/global_project_controller.dart`

**功能描述**:
- 全局项目控制器
- 管理当前选中的考试项目、科目、章节、页面模式
- 管理考试倒计时数据
- 本地持久化用户选择

**类定义**:

```dart
class GlobalProjectController extends GetxController {
  static GlobalProjectController get to => Get.find();
  
  static String getInitialRoute();
  
  final GetStorage _storage = GetStorage();
  final String _storageKey = 'current_project';
  final String _storageModeKey = 'page_mode';
  
  late final ExamRepository _examRepository;
  
  Rx<Project?> currentProject = Rx<Project?>(null);
  RxString pageMode = 'TRAINING'.obs;
  RxString currentSubject = ''.obs;
  RxString currentChapter = ''.obs;
  RxBool isLoading = false.obs;
  Rx<GlobalExamCountdown?> examCountdown = Rx<GlobalExamCountdown?>(null);
  RxString errorMessage = ''.obs;
  RxInt daysToExam = 200.obs;
  RxString examCountdownText = ''.obs;
  
  String get currentProjectName => currentProject.value?.name ?? '请选择考试项目';
  String get currentModeName { ... }
  
  void selectProject(Project project);
  void setCurrentSubject(String subject);
  void setCurrentChapter(String chapter);
  void setPageMode(String mode);
  Future<void> loadApiData();
  void printGlobalSettings();
  String _resolveExamType();
  void _initialize();
  
  @override void onInit();
}
```

**核心功能**:

**1. 静态方法**
- `getInitialRoute()`: 根据登录状态获取初始路由
  - 已登录：`AppPages.INITIAL`（首页）
  - 未登录：`Routes.LOGIN`（登录页）

**2. 响应式状态**
- `currentProject`: 当前选中的考试项目
- `pageMode`: 当前页面模式（TRAINING 练习、EXAM 考试、VIEW 看题）
- `currentSubject`: 当前选中的科目名称
- `currentChapter`: 当前选中的章节名称
- `isLoading`: 加载状态
- `examCountdown`: 考试倒计时数据
- `errorMessage`: 错误信息
- `daysToExam`: 距离考试天数
- `examCountdownText`: 考试倒计时文本

**3. 计算属性**
- `currentProjectName`: 获取当前项目名称（带默认值）
- `currentModeName`: 获取当前模式的中文名称

**4. 公开方法**
- `selectProject()`: 选择项目，自动保存到本地存储并加载 API 数据
- `setCurrentSubject()`: 设置当前科目
- `setCurrentChapter()`: 设置当前章节
- `setPageMode()`: 设置页面模式，自动保存到本地存储
- `loadApiData()`: 加载公共接口数据（考试倒计时等）
- `printGlobalSettings()`: 打印当前全局设置（调试用）

**5. 本地持久化**
- 存储 Key：`current_project`、`page_mode`
- 在 onInit 时自动加载存储的项目和模式
- 默认项目：中级经济师（ID: 5）

**6. 页面模式**
- `TRAINING`: 练习模式（默认）
- `EXAM`: 考试模式
- `VIEW`: 看题模式

**依赖**:
- `package:flutter/material.dart`
- `package:get/get.dart`
- `package:get_storage/get_storage.dart`
- `../data/services/auth_service.dart`
- `../data/models/project_model.dart`
- `../data/models/global_project_model.dart`
- `../data/repositories/exam_repository.dart`
- `../routes/app_pages.dart`

---

### 5.2 snackbar_utils.dart

**文件路径**: `lib/app/services/snackbar_utils.dart`

**功能描述**:
- Snackbar 工具类
- 封装 flutter_smart_dialog 的提示功能
- 提供成功、错误、警告、信息等多种提示样式
- 提供加载对话框功能

**类定义**:

```dart
class SnackbarUtils {
  static void showSuccess(String message);
  static void showError(String message);
  static void showWarning(String message);
  static void showInfo(String message);
  static void showLoading({String? msg});
  static void dismissLoading();
}
```

**样式说明**:

| 方法 | 背景色 | 文字色 | 用途 |
|------|--------|--------|------|
| showSuccess | 深黑色 (0xE6000000) | 白色 | 成功提示 |
| showError | 红色 (0xE6FF4B4B) | 白色 | 错误提示 |
| showWarning | 橙色 (0xFFE6A800) | 白色 | 警告提示 |
| showInfo | 深黑色 (0xE6000000) | 白色 | 信息提示 |

**功能特点**:
- 所有提示居中显示
- 使用圆角矩形容器
- 透明遮罩层
- 显示/刷新模式（不堆叠）
- 加载对话框带半透明黑色遮罩

**依赖**:
- `package:flutter/material.dart`
- `package:flutter_smart_dialog/flutter_smart_dialog.dart`

---

### 5.3 screenAdapter.dart

**文件路径**: `lib/app/services/screenAdapter.dart`

**功能描述**:
- 屏幕适配工具类
- 封装 flutter_screenutil 的便捷方法
- 提供统一的尺寸适配接口

**类定义**:

```dart
class ScreenAdapter {
  static width(num v) => v.w;
  static height(num v) => v.h;
  static fontSize(num v) => v.sp;
  static getScreenWidth() => 1.sw;
  static getScreenHeight() => 1.sh;
  static radius(num v) => v.r;
  static bottomPadding() => ScreenUtil().bottomBarHeight;
}
```

**方法说明**:
- `width()`: 宽度适配（基于设计稿 1080px 宽度）
- `height()`: 高度适配（基于设计稿 2400px 高度）
- `fontSize()`: 字体大小适配
- `getScreenWidth()`: 获取屏幕宽度
- `getScreenHeight()`: 获取屏幕高度
- `radius()`: 圆角半径适配
- `bottomPadding()`: 获取底部安全区域高度

**设计稿基准**: 1080 x 2400（在 main.dart 中配置）

**依赖**:
- `package:flutter_screenutil/flutter_screenutil.dart`

---

### 5.4 keepAliveWrapper.dart

**文件路径**: `lib/app/services/keepAliveWrapper.dart`

**功能描述**:
- 状态保持包装器
- 用于保持页面状态（如 Tab 切换时不重新渲染）
- 使用 AutomaticKeepAliveClientMixin 实现

**类定义**:

```dart
class KeepAliveWrapper extends StatefulWidget {
  const KeepAliveWrapper({Key? key, @required this.child, this.keepAlive = true});
  
  final Widget? child;
  final bool keepAlive;
  
  @override State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper> with AutomaticKeepAliveClientMixin {
  @override Widget build(BuildContext context);
  @override bool get wantKeepAlive => widget.keepAlive;
}
```

**使用方式**:
```dart
KeepAliveWrapper(
  keepAlive: true,
  child: YourPage(),
)
```

**依赖**:
- `package:flutter/material.dart`

---

### 5.5 htxFonts.dart

**文件路径**: `lib/app/services/htxFonts.dart`

**功能描述**:
- 字体服务（当前未找到具体实现，可能用于自定义字体管理）

---

## 6. Routes 路由层

### 6.1 app_pages.dart

**文件路径**: `lib/app/routes/app_pages.dart`

**功能描述**:
- 页面路由配置
- 定义所有页面的路由路径、页面组件、绑定
- 使用 GetX 的路由系统

**类定义**:

```dart
class AppPages {
  AppPages._();
  
  static const INITIAL = Routes.TABS;
  
  static final routes = [
    GetPage(name: _Paths.TABS, page: () => const TabsView(), binding: TabsBinding()),
    GetPage(name: _Paths.QUESTIONS_LIST, page: () => const QuestionsListView(), binding: QuestionsListBinding()),
    GetPage(name: _Paths.QUESTION_TRAIN, page: () => const QuestionTrainView(), binding: QuestionTrainBinding()),
    GetPage(name: _Paths.QUESTIONS_RESULT, page: () => const QuestionsResultView(), binding: QuestionsResultBinding()),
    GetPage(name: _Paths.QUESTIONS_HOME, page: () => const QuestionsHomeView(), binding: QuestionsHomeBinding()),
    GetPage(name: _Paths.QUESTIONS + _Paths.QUESTIONS_EXAM, page: () => const QuestionsExamView(), binding: QuestionsExamBinding()),
    GetPage(name: _Paths.QUESTIONS + _Paths.QUESTIONS_ELIST, page: () => const QuestionsElistView(), binding: QuestionsElistBinding()),
    GetPage(name: _Paths.QUESTIONS + _Paths.QUESTIONS_FAVORITE, page: () => const QuestionsFavoriteView(), binding: QuestionsFavoriteBinding()),
    GetPage(name: _Paths.QUESTIONS + _Paths.QUESTIONS_WRONG, page: () => const QuestionsWrongView(), binding: QuestionsWrongBinding()),
    GetPage(name: _Paths.STUDY, page: () => const StudyView(), binding: StudyBinding()),
    GetPage(name: _Paths.STUDY + '/details', page: () => const DetailsView(), binding: DetailsBinding()),
    GetPage(name: _Paths.HOME, page: () => const HomeView(), binding: HomeBinding()),
    GetPage(name: _Paths.PROJECT, page: () => ProjectView(), binding: ProjectBinding()),
    GetPage(name: Routes.LOGIN, page: () => const LoginView(), binding: LoginBinding()),
    GetPage(name: Routes.VERIFICATION, page: () => VerificationView(), binding: LoginBinding()),
  ];
}
```

**路由列表**:

| 路由路径 | 页面 | 绑定 |
|----------|------|------|
| `/tabs` | TabsView | TabsBinding |
| `/questions/questions-list` | QuestionsListView | QuestionsListBinding |
| `/questions/question-train` | QuestionTrainView | QuestionTrainBinding |
| `/questions-result` | QuestionsResultView | QuestionsResultBinding |
| `/questions/questions-home` | QuestionsHomeView | QuestionsHomeBinding |
| `/questions/questions-exam` | QuestionsExamView | QuestionsExamBinding |
| `/questions/questions-elist` | QuestionsElistView | QuestionsElistBinding |
| `/questions/favorite` | QuestionsFavoriteView | QuestionsFavoriteBinding |
| `/questions/wrong` | QuestionsWrongView | QuestionsWrongBinding |
| `/study` | StudyView | StudyBinding |
| `/study/details` | DetailsView | DetailsBinding |
| `/home` | HomeView | HomeBinding |
| `/project` | ProjectView | ProjectBinding |
| `/auth/login` | LoginView | LoginBinding |
| `/auth/login/verification` | VerificationView | LoginBinding |

**依赖**:
- `package:get/get.dart`
- 所有模块的 bindings 和 views

---

### 6.2 app_routes.dart

**文件路径**: `lib/app/routes/app_routes.dart`

**功能描述**:
- 路由常量定义
- 自动生成的路由路径常量
- 使用 part of 与 app_pages.dart 关联

**类定义**:

```dart
abstract class Routes {
  Routes._();
  
  static const TABS = _Paths.TABS;
  static const QUESTIONS = _Paths.QUESTIONS;
  static const STUDY = _Paths.STUDY;
  static const HOME = _Paths.HOME;
  static const QUESTIONS_LIST = _Paths.QUESTIONS + _Paths.QUESTIONS_LIST;
  static const QUESTION_TRAIN = _Paths.QUESTIONS + _Paths.QUESTION_TRAIN;
  static const QUESTIONS_RESULT = _Paths.QUESTIONS_RESULT;
  static const QUESTIONS_HOME = _Paths.QUESTIONS + _Paths.QUESTIONS_HOME;
  static const QUESTIONS_EXAM = _Paths.QUESTIONS + _Paths.QUESTIONS_EXAM;
  static const QUESTIONS_ELIST = _Paths.QUESTIONS + _Paths.QUESTIONS_ELIST;
  static const QUESTIONS_FAVORITE = _Paths.QUESTIONS + _Paths.QUESTIONS_FAVORITE;
  static const QUESTIONS_WRONG = _Paths.QUESTIONS + _Paths.QUESTIONS_WRONG;
  static const PROJECT = _Paths.PROJECT;
  static const LOGIN = _Paths.AUTH + _Paths.LOGIN;
  static const VERIFICATION = _Paths.AUTH + _Paths.LOGIN + _Paths.VERIFICATION;
}

abstract class _Paths {
  _Paths._();
  
  static const TABS = '/tabs';
  static const QUESTIONS = '/questions';
  static const STUDY = '/study';
  static const HOME = '/home';
  static const QUESTIONS_LIST = '/questions-list';
  static const QUESTION_TRAIN = '/question-train';
  static const QUESTIONS_RESULT = '/questions-result';
  static const QUESTIONS_HOME = '/questions-home';
  static const QUESTIONS_EXAM = '/questions-exam';
  static const QUESTIONS_ELIST = '/questions-elist';
  static const QUESTIONS_FAVORITE = '/favorite';
  static const QUESTIONS_WRONG = '/wrong';
  static const PROJECT = '/project';
  static const LOGIN = '/login';
  static const VERIFICATION = '/verification';
  static const AUTH = '/auth';
}
```

**说明**:
- 该文件通常由 get_cli 工具自动生成
- 提供类型安全的路由常量
- `Routes` 类提供完整的路由路径
- `_Paths` 类提供路径片段常量

---

## 7. Modules 功能模块

### 7.1 Home 首页模块

**目录结构**:
```
modules/home/
├── bindings/home_binding.dart
├── controllers/home_controller.dart
└── views/home_view.dart
```

**功能描述**:
- 应用首页
- 展示公告、轮播图、课程、试卷等
- 显示考试倒计时
- 提供快捷入口

**核心文件**:
- `home_binding.dart`: 依赖注入绑定
- `home_controller.dart`: 首页逻辑控制器
- `home_view.dart`: 首页 UI 视图

---

### 7.2 Login 登录模块

**目录结构**:
```
modules/login/
├── bindings/login_binding.dart
├── controllers/login_controller.dart
└── views/
    ├── login_view.dart
    ├── verification_view.dart
    └── agreement_view.dart
```

**功能描述**:
- 用户登录功能
- 手机号 + 验证码登录
- 用户协议查看
- 登录状态持久化

**核心文件**:
- `login_binding.dart`: 依赖注入绑定
- `login_controller.dart`: 登录逻辑控制器
- `login_view.dart`: 登录页面 UI
- `verification_view.dart`: 验证码输入页面
- `agreement_view.dart`: 用户协议页面

---

### 7.3 Project 项目模块

**目录结构**:
```
modules/project/
├── bindings/project_binding.dart
├── controllers/project_controller.dart
└── views/project_view.dart
```

**功能描述**:
- 考试项目选择
- 展示所有可选的考试项目
- 切换当前选中的项目
- 保存用户选择到本地存储

**核心文件**:
- `project_binding.dart`: 依赖注入绑定
- `project_controller.dart`: 项目选择逻辑控制器
- `project_view.dart`: 项目选择页面 UI

---

### 7.4 Questions 题目模块

**目录结构**:
```
modules/questions/
├── questionTrain/
│   ├── bindings/question_train_binding.dart
│   ├── controllers/question_train_controller.dart
│   └── views/question_train_view.dart
├── questionsHome/
│   ├── bindings/questions_home_binding.dart
│   ├── controllers/questions_home_controller.dart
│   └── views/questions_home_view.dart
├── questionsList/
│   ├── bindings/questions_list_binding.dart
│   ├── controllers/questions_list_controller.dart
│   └── views/questions_list_view.dart
├── questionsExam/
│   ├── bindings/questions_exam_binding.dart
│   ├── controllers/questions_exam_controller.dart
│   └── views/questions_exam_view.dart
├── questionsElist/
│   ├── bindings/questions_elist_binding.dart
│   ├── controllers/questions_elist_controller.dart
│   └── views/questions_elist_view.dart
├── questionsFavorite/
│   ├── bindings/questions_favorite_binding.dart
│   ├── controllers/questions_favorite_controller.dart
│   └── views/questions_favorite_view.dart
├── questionsWrong/
│   ├── bindings/questions_wrong_binding.dart
│   ├── controllers/questions_wrong_controller.dart
│   └── views/questions_wrong_view.dart
└── questionsResult/
    ├── bindings/questions_result_binding.dart
    ├── controllers/questions_result_controller.dart
    └── views/questions_result_view.dart
```

**功能描述**:
- 完整的题库功能
- 题目练习、模拟考试、错题本、收藏夹
- 题目列表、详情、结果展示

**子模块说明**:

| 子模块 | 功能 |
|--------|------|
| questionTrain | 题目练习页面 |
| questionsHome | 题目首页（分类入口） |
| questionsList | 题目列表 |
| questionsExam | 模拟考试 |
| questionsElist | 题目列表增强版 |
| questionsFavorite | 收藏夹 |
| questionsWrong | 错题本 |
| questionsResult | 考试结果 |

---

### 7.5 Study 学习模块

**目录结构**:
```
modules/study/
├── bindings/
│   ├── study_binding.dart
│   └── details_binding.dart
├── controllers/
│   ├── study_controller.dart
│   └── details_controller.dart
└── views/
    ├── study_view.dart
    └── details_view.dart
```

**功能描述**:
- 学习资料查看
- 视频课程播放
- 资料详情展示

**核心文件**:
- `study_binding.dart`: 学习页依赖注入
- `details_binding.dart`: 详情页依赖注入
- `study_controller.dart`: 学习页控制器
- `details_controller.dart`: 详情页控制器
- `study_view.dart`: 学习页面 UI
- `details_view.dart`: 详情页面 UI

---

### 7.6 Tabs 底部导航模块

**目录结构**:
```
modules/tabs/
├── bindings/tabs_binding.dart
├── controllers/tabs_controller.dart
└── views/tabs_view.dart
```

**功能描述**:
- 应用主框架
- 底部导航栏
- 页面切换管理
- 首页、题库、学习、我的等 Tab

**核心文件**:
- `tabs_binding.dart`: 依赖注入绑定
- `tabs_controller.dart`: 底部导航控制器
- `tabs_view.dart`: 主框架页面 UI

---

### 7.7 User 用户模块

**目录结构**:
```
modules/user/
├── bindings/user_binding.dart
├── controllers/user_controller.dart
└── views/
    ├── user_view.dart
    ├── user_info_view.dart
    ├── modify_nickname_view.dart
    ├── vip_center_view.dart
    └── delete_account_view.dart
```

**功能描述**:
- 用户中心
- 用户信息管理
- 昵称修改
- VIP 中心
- 账号注销

**核心文件**:
- `user_binding.dart`: 依赖注入绑定
- `user_controller.dart`: 用户中心控制器
- `user_view.dart`: 用户中心页面
- `user_info_view.dart`: 用户信息页面
- `modify_nickname_view.dart`: 修改昵称页面
- `vip_center_view.dart`: VIP 中心页面
- `delete_account_view.dart`: 注销账号页面

---

## 8. 架构总结

### 8.1 整体架构

该项目采用 **GetX + MVVM** 架构：

```
┌─────────────────────────────────────────────────────────┐
│                    UI Layer (Views)                      │
│  home_view.dart, login_view.dart, project_view.dart...  │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│              Presentation Layer (Controllers)           │
│  home_controller.dart, login_controller.dart...         │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                Business Logic Layer                     │
│  AuthService, GlobalProjectController, ExamRepository   │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                  Data Layer                             │
│  ApiClient, GetStorage, Models                          │
└─────────────────────────────────────────────────────────┘
```

### 8.2 目录职责

| 目录 | 职责 |
|------|------|
| components | 可复用的 UI 组件 |
| config | 环境配置、常量定义 |
| data/models | 数据模型、DTO |
| data/providers | 数据提供者（API 客户端） |
| data/repositories | 数据仓库（业务数据访问） |
| data/services | 业务服务（认证、用户管理等） |
| modules | 功能模块（按业务划分） |
| routes | 路由配置 |
| services | 应用服务（全局控制器、工具类） |

### 8.3 核心数据流

```
1. 用户操作 UI
   ↓
2. View 调用 Controller 方法
   ↓
3. Controller 调用 Repository/Service
   ↓
4. Repository 通过 ApiClient 发起网络请求
   ↓
5. ApiClient 处理 Token 注入、错误拦截
   ↓
6. 服务器返回数据
   ↓
7. ApiClient 解析响应
   ↓
8. Repository 返回 ApiResponse
   ↓
9. Controller 更新响应式状态
   ↓
10. View 自动刷新 UI
```

---

## 9. 关键技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| Flutter | 3.0+ | UI 框架 |
| GetX | ^4.7.3 | 状态管理、路由、依赖注入 |
| Dio | ^5.4.0 | 网络请求 |
| GetStorage | ^2.1.1 | 本地存储 |
| flutter_screenutil | ^5.9.0 | 屏幕适配 |
| flutter_smart_dialog | ^5.1.0 | 弹窗、提示 |
| video_player | ^2.8.3 | 视频播放 |
| chewie | ^1.5.0 | 视频播放器 UI |
| cached_network_image | ^3.4.1 | 图片缓存 |
| pin_code_fields | ^8.0.1 | 验证码输入 |
| flutter_swiper_view | ^1.1.8 | 轮播图 |
| flutter_staggered_grid_view | ^0.7.0 | 瀑布流布局 |

---

## 10. 开发建议

### 10.1 代码规范

1. **遵循 GetX 架构**
   - 视图只负责 UI，不包含业务逻辑
   - 控制器管理状态和业务逻辑
   - 仓库负责数据访问

2. **使用响应式编程**
   - 使用 `.obs` 定义响应式变量
   - 使用 `Obx()` 或 `GetX()` 监听状态变化

3. **依赖注入**
   - 使用 Bindings 管理依赖
   - 使用 `Get.put()` 注册单例服务
   - 使用 `Get.find()` 获取依赖

4. **命名规范**
   - 文件名：小写 + 下划线
   - 类名：大驼峰
   - 变量/函数：小驼峰
   - 常量：大写下划线

### 10.2 性能优化

1. **使用 KeepAliveWrapper**
   - 保持 Tab 页面状态，避免重复渲染

2. **图片缓存**
   - 使用 cached_network_image 缓存网络图片

3. **列表优化**
   - 使用 ListView.builder 而不是 ListView
   - 实现 item 级别的状态管理

4. **状态更新**
   - 避免不必要的状态更新
   - 使用 GetX 的精细状态监听

### 10.3 安全建议

1. **生产环境配置**
   - 移除 SSL 证书忽略
   - 关闭日志输出
   - 使用 HTTPS

2. **Token 安全**
   - 定期刷新 Token
   - 不要在日志中打印完整 Token
   - 安全退出时清除 Token

3. **用户数据**
   - 敏感信息加密存储
   - 不要在客户端保存密码
   - 实现账号注销功能

---

## 11. 附录

### 11.1 支持的考试项目

| 项目名称 | 代码 | 说明 |
|----------|------|------|
| 中级经济师 | zjjjs | 默认项目 |
| 初级经济师 | cjjjs | |
| 一级建造师 | yjjjs | |
| 二级建造师 | ejjjs | |
| 社会工作者 | shggz | |

### 11.2 API 端点前缀

| 前缀 | 用途 |
|------|------|
| `addons/exam/` | 考试相关 API |
| `addons/common/` | 通用插件 API |

### 11.3 状态码说明

| 状态码 | 说明 |
|--------|------|
| 0 / 200 | 成功 |
| 401 | 未授权（Token 过期） |
| 403 | 禁止访问 |
| 404 | 资源不存在 |
| 500+ | 服务器错误 |

---

**文档生成时间**: 2026-05-29
**项目版本**: 1.0.0+1
