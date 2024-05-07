import 'package:dio/dio.dart';
import 'package:erabbit_app_flutter/models/user_center_model.dart';
import 'package:erabbit_app_flutter/service/requests.dart';

class UserCenterAPI {
  /// 个人信息
  static Future<UserModel?> getUserInfo() async {
    Response response = await XTXRequestManager().handleRequest('member/profile/check', 'GET');
    // 注意：如果用户已登录获取的是登录用户信息，反之，获取的是null
    Map? userInfo = response.data['result'];

    // 转模型:只有当获取到登录用户的个人信息才需要转模型
    UserModel? userModel;
    if (userInfo != null) {
      userModel = UserModel.fromjson(userInfo);
    }

    return userModel;
  }
}
