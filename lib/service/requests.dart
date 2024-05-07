import 'package:dio/dio.dart';
import 'package:erabbit_app_flutter/main.dart';
import 'package:erabbit_app_flutter/pages/account/account_login_page.dart';
import 'package:erabbit_app_flutter/service/account_api.dart';
import 'package:erabbit_app_flutter/utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 网络请求单例类
class XTXRequestManager {
  // 声明Dio
  Dio? _dio;

  // 1. 私有的静态属性
  static XTXRequestManager? _instance;

  // 2. 私有的命名构造函数:用于实例化单例类
  XTXRequestManager._initManager() {
    // 创建Dio实例
    if (_dio == null) {
      // 使用BaseOptions设置全局的配置信息
      BaseOptions baseOptions = BaseOptions(
        // 超时时间:连接超时和响应超时
        connectTimeout:15000, // 单位毫秒，15秒
        receiveTimeout: 5000,// 单位毫秒，5秒
        // baseUrl
        baseUrl: 'https://pcapi-xiaotuxian-front.itheima.net/',
      );

      _dio = Dio(baseOptions);

      // 记录本地缓存的用户信息
      Map userInfo = {};

      /// 记录获取购物车数据Token异常时请求路径
      String getCartErrorPath = '';

      // 使用dio插件的拦截器
      _dio!.interceptors.add(InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
          // 发送请求前的拦截操作
          // 读取登录用户token
          userInfo = await getUserInfo();
          String authorization = userInfo.isNotEmpty ? 'Bearer ${userInfo['token']}' : '';
          debugPrint('本地缓存的token：${userInfo['token']}');
          // 设置全局的请求头信息
          options.headers = {
            'Authorization': authorization, // 用户身份信息（只有注册登录才有，如果当前没有可以指定''）
            'source-client': 'app', // 客户端类型
          };

          return handler.next(options);
        },
        onResponse: (Response e, ResponseInterceptorHandler handler) {
          // 接收响应前的拦截操作
          // 如果需要在接收响应前补充一些额外的逻辑，代码写这里 (过滤出需要的数据)

          return handler.next(e);
        },
        onError: (DioError e, ErrorInterceptorHandler handler) async {
          // 捕获到异常时的拦截操作
          // 统一的异常处理(用户身份信息过期了，后端会返回状态码401，如果拦截到401，可以统一的处理401的逻辑)
          // 1. 监听错误码401
          if (e.response!.statusCode == 401) {
            // print('Token过期了，需要刷新Token');

            // 判断当前401异常是否是获取购物车数据时产生的，如果是，记录请求路径
            if (e.requestOptions.path.contains('member/cart/mutli')) {
              getCartErrorPath = e.requestOptions.path;
            } else {
              // 重置401异常的接口路径：为了保证除了获取购物车以外的其他情况，用户都要进入登录页
              getCartErrorPath = '';
            }

            // 4. 刷新Token失败：跳转到账号密码登录页
            // if ('判断当前出错的请求路径是否是刷新Token的接口路径') {}
            // 补充：如果本地没有缓存任何的用户信息，表示用户未登录过，同样的需要进入登录页
            if (e.requestOptions.path == 'login/refresh' || userInfo.isEmpty) {
              // print('刷新Token失败，跳转到到登录页');
              // 清空本地缓存:本地缓存一个空字典
              await saveUserInfo({});
              // 跳转到到登录页
              // 问题：无组件上下文（context）的情况下做页面跳转
              // 解决：需要获取到Navigator的状态（NavigatorState），只要拿到了Navigator的状态，不需要context也能跳转页面
              // 核心点：如何获取Navigator的状态？ ===> MaterialApp.navigatorKey属性
              // Navigator.push(context, '登录页');

              // 判断刷新Token失败，是否是获取购物车数据时刷新失败了。
              // 如果不是，进入登录页，反之，不进入登录页，留在购物车页面
              if (!getCartErrorPath.contains('member/cart/mutli')) {
                navigatorKey.currentState!.push(
                  CupertinoPageRoute(builder: (BuildContext context) {
                    return AccountLoginPage();
                  }),
                );
              } else {
                // 发布获取购物车数据Token异常事件
                eventBus.fire(GetCartTokenError());
              }

              // 结束本次请求：以一个异常结束，而且异常不被再被onError拦截到
              return handler.reject(e);
            }

            // 2. 请求刷新Token接口
            Map tokenInfo = await AccountAPI.refreshToken(userInfo['account'], userInfo['id']);
            debugPrint('刷新的Token：${tokenInfo['token']}');
            // 再次本地缓存包含新Token的用户信息
            await saveUserInfo(tokenInfo);

            // 3. 刷新Token成功：使用新Token再次发起请求
            // 使用新Token再次设置请求头的Authorization字段
            RequestOptions requestOptions = e.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer ${tokenInfo['token']}';
            // 再次发起请求
            Response response = await _dio!.fetch(requestOptions);
            // 正常的做一次响应，将获取的正确的数据响应给接口调用者
            // resolve：以正常的响应结束本次请求
            return handler.resolve(response);
          }

          return handler.next(e);
        },
      ));
    }
  }

  // 3. 创建单例对象并向外界提供单例对象的方法(工厂构造函数)
  factory XTXRequestManager() {
    // 判断单例对象是否存在，如果不存在，新建单例对象，反之，直接返回单例对象
    if (_instance == null) {
      _instance = XTXRequestManager._initManager();
    }
    return _instance!;
  }

  /// 处理请求的公共方法
  Future<Response> handleRequest(
    String path,
    String method, {
    data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio!.request(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(method: method),
    );
  }
}
