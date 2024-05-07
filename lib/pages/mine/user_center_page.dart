import 'dart:io';
import 'dart:convert' as convert; // 给库起别名，为了方便调用库里面的方法

import 'package:erabbit_app_flutter/models/user_center_model.dart';
import 'package:erabbit_app_flutter/pages/account/account_login_page.dart';
import 'package:erabbit_app_flutter/pages/mine/mine_page.dart';
import 'package:erabbit_app_flutter/utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';

class UserCenterPage extends StatefulWidget {
  UserCenterPage({this.token});

  /// 登录用户的token
  final String? token;

  @override
  _UserCenterPageState createState() => _UserCenterPageState();
}

class _UserCenterPageState extends State<UserCenterPage> {
  /// 网页控制器
  late WebViewController _webViewController;

  /// 图片选择器
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // 如果是安卓设备，指定网页执行的平台
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  /// 拍照和打开相册
  void _cameraAndGallery(ImageSource source) async {
    try {
      XFile? avatarFile = await _imagePicker.pickImage(source: source, maxWidth: 1500, maxHeight: 1500);
      // 判断头像是否为空，如果为空终止逻辑
      if (avatarFile == null) return;
      // 网页回显用户头像
      // 将头像文件转字节类型
      List<int> avatarBytes = await avatarFile.readAsBytes();
      // 将字节类型的头像进行base64编码
      String avatarBase64Str = convert.base64Encode(avatarBytes);
      // 给base64字符串添加图片文件前缀：为了方便网页中<img>标签渲染该头像
      avatarBase64Str = 'data:image/jpg;base64,' + avatarBase64Str;

      // Flutter调用网页注入用户头像的JS方法（该JS方法需要传入头像base64编码后的字符串）
      _webViewController.evaluateJavascript('window.XtxBridge.previewAvatar("$avatarBase64Str",true)');
    } catch (e) {
      debugPrint('相机：$e');
    }
  }

  /// 退出登录的频道
  JavascriptChannel _javascriptChannelForUserLogout() {
    return JavascriptChannel(
      name: 'FlutterUserLogout',
      onMessageReceived: (JavascriptMessage message) async {
        // 清空本地缓存的用户信息
        await saveUserInfo({});
        // 更新用户个人信息
        userInfoNotifier?.value = null;
        // 进入登录页：用户中心 --> 个人中心(退出登录) --> 登录页
        // 进入登录页：用户中心 --> 登录页（OK）
        Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) {
          return AccountLoginPage();
        }));
      },
    );
  }

  /// 修改用户信息的频道
  JavascriptChannel _javascriptChannelForNewUser() {
    return JavascriptChannel(
      name: 'FlutterNewUser',
      onMessageReceived: (JavascriptMessage message) async {
        // 更新本地缓存的用户信息
        Map updateUserInfo = convert.json.decode(message.message);
        await saveUserInfo(updateUserInfo);

        // 刷新用户中心页面的个人信息
        userInfoNotifier?.value = UserModel.fromjson(updateUserInfo);
      },
    );
  }

  /// 监听用户头像点击事件的频道
  JavascriptChannel _javascriptChannelForUserIcon() {
    return JavascriptChannel(
      name: 'FlutterUserIcon',
      onMessageReceived: (JavascriptMessage message) {
        // 展示拍照和我的相册对话框
        _showSelectUserIconDialog();
      },
    );
  }

  /// 监听网页顶部导航栏返回按钮点击事件频道
  JavascriptChannel _javascriptChannelForGoBack() {
    return JavascriptChannel(
      name: 'FlutterBack',
      onMessageReceived: (JavascriptMessage message) {
        // 接收返回按钮点击事件：返回上一级页面
        Navigator.pop(context);
      },
    );
  }

  /// 构建选择头像对话框：拍照或打开相册
  void _showSelectUserIconDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: (60.0 * 3) + 21.0,
          padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF7F7F8),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // 拍照
                        _cameraAndGallery(ImageSource.camera);

                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child: Container(
                        height: 60.0,
                        color: Colors.white,
                        alignment: Alignment.center,
                        child: Text(
                          '拍照',
                          style: TextStyle(color: Colors.black, fontSize: 16.0),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 1.0),
                      child: GestureDetector(
                        onTap: () {
                          // 打开相册
                          _cameraAndGallery(ImageSource.gallery);

                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        child: Container(
                          height: 60.0,
                          color: Colors.white,
                          alignment: Alignment.center,
                          child: Text(
                            '我的相册',
                            style: TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Container(
                    height: 60.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Text(
                      '取消',
                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 嵌套网页
      body: SafeArea(
        child: WebView(
          // unrestricted ：允许JS的执行不受限制的
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: 'http://zhoushugang.gitee.io/erabbit-client-hybrid',
          // 指定网页向Flutter发送消息的频道
          javascriptChannels: [
            _javascriptChannelForGoBack(),
            _javascriptChannelForUserIcon(),
            _javascriptChannelForNewUser(),
            _javascriptChannelForUserLogout(),
          ].toSet(),
          // 监听网页创建完成
          onWebViewCreated: (WebViewController controller) {
            // 获取网页控制器
            _webViewController = controller;
          },
          // 监听网页加载完成
          onPageFinished: (String url) {
            // 注入token
            String token = widget.token!;
            _webViewController.evaluateJavascript('window.XtxBridge.setToken("$token")');
          },
        ),
      ),
    );
  }
}
