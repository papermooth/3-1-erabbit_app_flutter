import 'package:dio/dio.dart';
import 'package:erabbit_app_flutter/models/home_model.dart';
import 'package:erabbit_app_flutter/service/requests.dart';

class HomeAPI {
  /// 获取首页网络数据的接口方法
  // static Future<Response> homeFetch() {
  //   return XTXRequestManager().handleRequest('home/index', 'GET');
  // }

  /// 获取首页网络数据的接口方法
  static Future<HomeModel> homeFetch() async {
    Response response = await XTXRequestManager().handleRequest('home/index', 'GET');
    // 读取响应体数据中的result字段
    dynamic ret = response.data['result'];

    // 将result字段对应的首页网络数据传给首页总模型，转模型数据
    HomeModel homeModel = HomeModel.fromJson(ret);
    return homeModel;
  }
}
