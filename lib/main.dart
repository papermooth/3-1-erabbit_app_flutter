import 'dart:io';

import 'package:erabbit_app_flutter/pages/root_page/root_page.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

/// 全局的，用于获取NavigatorState的key
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// 全局的，用于发布和订阅EventBus的事件的
EventBus eventBus = EventBus();

void main() {
  runApp(MyApp());

  // 程序启动之后，一次性的设置状态栏颜色
  // 判断设备是否是安卓
  if (Platform.isAndroid) {
    // 如果是安卓:将状态栏设置成透明的
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 指定APP默认展示的第一个页面(APP根页面)
      home: RootPage(),
      // 安装Flutter_EasyLoading
      builder: EasyLoading.init(),
      // navigatorKey: '用于记录并获取全局的Navigator的状态（NavigatorState）',
      navigatorKey: navigatorKey,
    );
  }
}
