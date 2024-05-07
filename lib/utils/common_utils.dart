import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/material.dart';

/// 本地缓存用户信息
Future<bool> saveUserInfo(Map userInfo) async {
  // 获取SharedPreferences单例
  SharedPreferences preferences = await SharedPreferences.getInstance();
  // 将用户信息字典转成字符串(JSON字符串)
  String jsonStr = json.encode(userInfo);
  // 缓存数据
  bool ret = await preferences.setString('userInfo', jsonStr);
  return ret;
}

/// 读取本地缓存的用户信息
Future<Map> getUserInfo() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String? userInfoStr = preferences.getString('userInfo');
  // 将读取的JSON字符串类型的用户信息转成字典，方便使用
  Map userInfoMap = {};
  if (userInfoStr != null) {
    userInfoMap = json.decode(userInfoStr);
  }

  return userInfoMap;
}

/// 回到首页的事件
class GoToHomeEvent {
  // 如果事件在传递时，需要携带数据，数据可以放构造函数中
  GoToHomeEvent();
}

/// 获取购物车数据Token异常事件
class GetCartTokenError {
  GetCartTokenError();
}

/// 登录成功的事件
class LoginSuccessEvent {
  LoginSuccessEvent();
}
