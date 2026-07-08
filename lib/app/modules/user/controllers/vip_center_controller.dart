import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/providers/api_client.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../../services/snackbar_utils.dart';
import '../../../utils/api_error_handler.dart';

class VipCenterController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxnInt selectedPayMethod = RxnInt(); // 0: 微信, 1: 支付宝
  final RxList<Map<String, dynamic>> memberConfigs =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoadingConfigs = true.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchMemberConfigs();
  }

  /// 获取会员配置列表
  Future<void> _fetchMemberConfigs() async {
    try {
      final response =
          await ApiClient.to.get('addons/exam/user/memberOpenConfig');
      final body = response.data;
      dynamic rawList;

      if (body is Map && body['data'] is List) {
        rawList = body['data'];
      } else if (body is Map &&
          body['data'] is Map &&
          (body['data']['list'] is List)) {
        rawList = body['data']['list'];
      } else if (body is List) {
        rawList = body;
      }

      if (rawList is List) {
        memberConfigs.value = rawList
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    } on DioException catch (e) {
      ApiErrorHandler.handleDioError(e, fallbackMessage: '获取VIP配置失败');
    } catch (e) {
      ApiErrorHandler.handleError(e, fallbackMessage: '获取VIP配置失败');
    } finally {
      isLoadingConfigs.value = false;
    }
  }

  /// 选择套餐
  void selectPlan(int index) {
    selectedIndex.value = index;
  }

  /// 选择支付方式
  void selectPayMethod(int method) {
    selectedPayMethod.value = method;
  }

  /// 兑换激活码
  Future<void> exchangeActivationCode(String code) async {
    try {
      final response = await ApiClient.to
          .post('addons/exam/pay/exchangeCode', data: {'code': code});
      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        if (data['code'] == 1 && data['data'] is Map) {
          final result = data['data'] as Map<String, dynamic>;
          final infoMap = result['info'] is Map
              ? Map<String, dynamic>.from(result['info'])
              : null;
          if (infoMap != null) {
            final newInfo = UserInfoModel.fromJson(infoMap);
            final currentUser = AuthService.to.user.value;
            if (currentUser != null) {
              AuthService.to.updateUser(currentUser.copyWith(info: newInfo));
              AuthService.to.updateMemberStatus(newInfo.status ?? 0);
            }
          }
          SnackbarUtils.showSuccess('兑换成功');
        } else {
          SnackbarUtils.showError(data['msg']?.toString() ?? '兑换失败');
        }
      } else {
        SnackbarUtils.showError('兑换失败');
      }
    } on DioException catch (e) {
      ApiErrorHandler.handleDioError(e, fallbackMessage: '兑换失败，请检查激活码是否正确');
    } catch (e) {
      ApiErrorHandler.handleError(e, fallbackMessage: '兑换失败');
    }
  }

  /// 发起支付（三端通用 H5 支付方案）
  Future<void> doPay() async {
    final type = selectedPayMethod.value == 1 ? 'alipay' : 'wechat';

    if (memberConfigs.isEmpty || selectedIndex.value >= memberConfigs.length) {
      SnackbarUtils.showError('请选择会员类型');
      return;
    }
    final memberConfigId = memberConfigs[selectedIndex.value]['id']?.toString();
    if (memberConfigId == null || memberConfigId.isEmpty) {
      SnackbarUtils.showError('会员配置信息异常');
      return;
    }

    try {
      SnackbarUtils.showInfo('正在发起支付...');

      var response = await ApiClient.to.post(
        'addons/exam/pay/pay',
        data: {
          'member_config_id': memberConfigId,
          'type': type,
          // 标识为 H5 支付模式，让服务端返回 payUrl 而非 orderString
          'pay_type': 'h5',
        },
      );

      if (response.data != null) {
        var body = response.data;

        if (type == 'alipay') {
          // H5 支付：获取支付 URL
          final payUrl = body is String
              ? body
              : (body is Map
                  ? body['payUrl']?.toString() ?? body['url']?.toString()
                  : null);

          if (payUrl != null && payUrl.isNotEmpty) {
            // 使用 url_launcher 打开 H5 支付页面（三端通用）
            final uri = Uri.parse(payUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
            } else {
              SnackbarUtils.showError('无法打开支付页面');
            }
          } else {
            // 兼容旧接口：如果仍返回 orderString，提示用户
            final orderString =
                body is Map ? body['orderString']?.toString() : null;
            if (orderString != null && orderString.isNotEmpty) {
              SnackbarUtils.showInfo('当前环境不支持原生支付，请联系后端升级 H5 支付接口');
            } else {
              SnackbarUtils.showError('获取支付参数失败');
            }
          }
        }

        if (type == 'wechat') {
          // 微信 H5 支付同理
          final payUrl = body is String
              ? body
              : (body is Map
                  ? body['payUrl']?.toString() ?? body['url']?.toString()
                  : null);

          if (payUrl != null && payUrl.isNotEmpty) {
            final uri = Uri.parse(payUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
            } else {
              SnackbarUtils.showError('无法打开支付页面');
            }
          } else {
            SnackbarUtils.showInfo('微信支付开发中');
          }
        }
      }
    } on DioException catch (e) {
      ApiErrorHandler.handleDioError(e, fallbackMessage: '支付请求失败');
    } catch (e) {
      ApiErrorHandler.handleError(e, fallbackMessage: '支付失败');
    }
  }
}
