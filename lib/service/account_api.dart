import 'package:dio/dio.dart';
import 'package:erabbit_app_flutter/service/requests.dart';

/// 账号相关API
class AccountAPI {
  /// 账号密码登录
  static Future<Map> login(String account, String password) async {
    // 请求体数据
    Map data = {"account": account, "password": password};
    Response response = await XTXRequestManager().handleRequest('login', 'POST', data: data);
    // 登录后的用户信息
    Map userInfo = response.data['result'];

    return userInfo;
  }

  /// 刷新Token
  static Future<Map> refreshToken(String account, String id) async {
    // 请求体
    Map data = {'account': account, 'id': id};
    Response response = await XTXRequestManager().handleRequest('login/refresh', 'PUT', data: data);
    // 包括新Token和用户信息
    Map tokenInfo = response.data['result'];
    return tokenInfo;
  }

  /// 校验账号(用户名和手机号)是否唯一
  static Future<bool> registerCheck(String account) async {
    String path = 'register/check?account=$account';
    Response response = await XTXRequestManager().handleRequest(path, 'GET');
    Map ret = response.data['result'];
    return ret['valid'];
  }

  /// 获取短信验证码
  static Future<dynamic> getSMSVerifyCode(String mobile, String type) async {
    String path = 'code?mobile=$mobile&type=$type';
    Response response = await XTXRequestManager().handleRequest(path, 'GET');
    return response.data['result'];
  }

  /// 校验短信验证码
  static Future<bool> checkSMSVerifyCode(String mobile, String code) async {
    String path = 'register/code/check?mobile=$mobile&code=$code';
    Response response = await XTXRequestManager().handleRequest(path, 'GET');
    Map ret = response.data['result'];
    return ret['valid'];
  }

  /// 用户账号注册
  static Future<Map> register(String account, String mobile, String code, String password) async {
    // 注册时的请求体数据
    Map data = {
      'account': account,
      'mobile': mobile,
      'code': code,
      'password': password,
      'type': 'app',
    };
    Response response = await XTXRequestManager().handleRequest('register', 'POST', data: data);
    Map userInfo = response.data['result'];
    return userInfo;
  }
}
