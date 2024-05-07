import 'package:dio/dio.dart';
import 'package:erabbit_app_flutter/main.dart';
import 'package:erabbit_app_flutter/pages/account/register_mobile_page.dart';
import 'package:erabbit_app_flutter/service/account_api.dart';
import 'package:erabbit_app_flutter/utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AccountLoginPage extends StatefulWidget {
  @override
  _AccountLoginPageState createState() => _AccountLoginPageState();
}

class _AccountLoginPageState extends State<AccountLoginPage> {
  /// 是否展示一键清空账号按钮:默认不展示
  bool _isShowCleanAccount = false;

  /// 账号输入框控制器
  TextEditingController? _accountController;

  /// 账号焦点
  FocusNode? _accountFocusNode;

  /// 是否展示一键清空密码按钮:默认不展示
  bool _isShowCleanPassword = false;

  /// 账号输入框控制器
  TextEditingController? _passwordController;

  /// 密码焦点
  FocusNode? _passwordFocusNode;

  /// 是否密文展示密码:默认密文展示
  bool _isobscureText = true;

  /// 是否勾选用户协议:默认勾选
  bool _isAgree = true;

  @override
  void initState() {
    _accountController = TextEditingController(text: '');
    _accountFocusNode = FocusNode();
    _passwordController = TextEditingController(text: '');
    _passwordFocusNode = FocusNode();

    // 监听密码输入框的焦点
    _passwordFocusNode!.addListener(() {
      // print('_passwordFocusNode: ${_passwordFocusNode!.hasFocus}');
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _accountController?.dispose();
    _accountFocusNode?.dispose();
    _passwordController?.dispose();
    _passwordFocusNode?.dispose();
    super.dispose();
  }

  /// 登录按钮点击事件
  void _loginButtonOnTap() async {
    // 校验用户登录信息
    // 账号和密码都有信息时才校验
    if (_accountController!.text.length == 0 ||
        _passwordController!.text.length == 0) return;
    // print('账号和密码有信息吗？');

    // 校验账号格式：5-20位的数字和字母组合
    RegExp accountRegExp = RegExp(r'^[0-9a-zA-Z]{5,20}$');
    bool isMatchAccount = accountRegExp.hasMatch(_accountController!.text);
    if (!isMatchAccount) {
      // print('账号格式错误');
      EasyLoading.showToast('账号格式错误');
      return;
    }

    // 校验密码格式：6-20位的数字和字母组合
    RegExp passwordRegExp = RegExp(r'^[0-9a-zA-Z]{6,20}$');
    bool isMatchPassword = passwordRegExp.hasMatch(_passwordController!.text);
    if (!isMatchPassword) {
      // print('密码格式错误');
      EasyLoading.showToast('密码格式错误');
      return;
    }

    // 校验是否同意用户协议：必须同意用户协议
    if (!_isAgree) {
      // print('请勾选用户协议');
      EasyLoading.showToast('请勾选用户协议');
      return;
    }

    // 发送登录请求
    try {
      Map userInfo = await AccountAPI.login(
          _accountController!.text, _passwordController!.text);
      print('登录成功后：$userInfo');

      // 本地缓存用户信息
      await saveUserInfo(userInfo);

      // 测试:读取本地缓存的用户信息
      // Map userInfoMap = await getUserInfo();
      // print(userInfoMap);

      // 发布登录成功事件
      eventBus.fire(LoginSuccessEvent());

      // 登录成功：返回上一级页面
      Navigator.pop(context);
    } on DioError catch (e) {
      // 捕获指定的异常DioError
      // debugPrint('$e');

      // 处理异常
      EasyLoading.showToast(e.response!.data['message']);
    }
  }

  /// 监听密码输入框文本变化
  void _passwordOnChanged(String? password) {
    // print('_passwordOnChanged: $password');
    setState(() {
      _isShowCleanPassword = password!.length > 0;
    });
  }

  /// 一键清空密码输入框
  void _cleanPassword() {
    _passwordController!.clear();
    // 隐藏一键清空按钮
    _passwordOnChanged('');
  }

  /// 监听账号输入框文本变化
  void _accountOnChanged(String? account) {
    // print('_accountOnChanged: $account');
    setState(() {
      _isShowCleanAccount = account!.length > 0;
    });
  }

  /// 一键清空账号输入框
  void _cleanAccount() {
    _accountController!.clear();
    // 隐藏一键清空按钮
    _accountOnChanged('');
  }

  /// 构建密码输入框
  Widget _buildPasswordTextField() {
    return Container(
      height: 82.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(
                "密码",
                style: TextStyle(fontSize: 14.0, color: Color(0xFF333333)),
              ),
              // 这里必须限定TextField的范围，不然会报布局的异常
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Container(
                    height: 34.0,
                    child: TextField(
                      // 控制密码密文展示
                      obscureText: _isobscureText,
                      focusNode: _passwordFocusNode,
                      controller: _passwordController,
                      onChanged: (String? text) {
                        _passwordOnChanged(text);
                      },
                      cursorRadius: Radius.circular(10.0),
                      cursorColor: Color(0xFFFFBD3B),
                      cursorHeight: 18.0,
                      style:
                          TextStyle(fontSize: 14.0, color: Color(0xFF333333)),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 8.0),
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: '6到20位字母、数字和符号组合',
                        hintStyle:
                            TextStyle(fontSize: 13.0, color: Color(0xffD8D8D8)),
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                ),
              ),
              // 一键清除
              _isShowCleanPassword
                  ? GestureDetector(
                      onTap: _cleanPassword,
                      child: Image.asset('assets/text_clean.png'),
                    )
                  : Container(),
              // 是否明文显示密码
              Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isobscureText = !_isobscureText;
                    });
                  },
                  child: _isobscureText
                      ? Image.asset('assets/yanjing.png', gaplessPlayback: true)
                      : Image.asset('assets/yanjing_on.png',
                          gaplessPlayback: true),
                ),
              ),
            ],
          ),
          // 分割线
          Padding(
            padding: EdgeInsets.only(top: 14.0),
            child: Container(
              height: 1.0,
              decoration: BoxDecoration(color: Color(0xFFE4E4E4)),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建账号输入框
  Widget _buildAccountTextField() {
    return Container(
      height: 82.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              Text(
                "账号",
                style: TextStyle(fontSize: 14.0, color: Color(0xFF333333)),
              ),
              // 这里必须限定TextField的范围，不然会报布局的异常
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Container(
                    height: 34.0,
                    child: TextField(
                      focusNode: _accountFocusNode,
                      controller: _accountController,
                      // 监听输入框文本变化
                      onChanged: (String? text) {
                        _accountOnChanged(text);
                      },
                      // 光标的设置
                      cursorRadius: Radius.circular(10.0),
                      cursorColor: Color(0xFFFFBD3B),
                      cursorHeight: 18.0,
                      style:
                          TextStyle(fontSize: 14.0, color: Color(0xFF333333)),
                      // 输入文本的样式
                      decoration: InputDecoration(
                        // TextField文本居中
                        contentPadding: EdgeInsets.only(top: 8.0),
                        // 辅助文本居中
                        isCollapsed: true,
                        // 去除边框
                        border: InputBorder.none,
                        // 占位提示文字和样式
                        hintText: '请输入用户名或手机号',
                        hintStyle:
                            TextStyle(fontSize: 13.0, color: Color(0xffD8D8D8)),
                      ),
                      // 键盘的设置
                      keyboardType: TextInputType.text, // 键盘类型
                      textInputAction: TextInputAction.done, // 控制键盘的enter键
                    ),
                  ),
                ),
              ),
              // 一键清除
              _isShowCleanAccount
                  ? GestureDetector(
                      onTap: _cleanAccount,
                      child: Image.asset('assets/text_clean.png'),
                    )
                  : Container(),
            ],
          ),
          // 分割线
          Padding(
            padding: EdgeInsets.only(top: 14.0),
            child: Container(
              height: 1.0,
              decoration: BoxDecoration(color: Color(0xFFE4E4E4)),
            ),
          ),
        ],
      ),
    );
  }

  /// 绿色背景 + 账号密码输入框 + 小兔子
  Widget _buildLoginCard() {
    // 定位的父组件
    return Container(
      height: 316.0, // 绿色背景高度+账号密码输入框高度-重合的高度20.0
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // 绿色背景
          Container(
            height: 132.0,
            color: Color(0xFF00BF9B),
          ),
          // 账号密码输入框
          Positioned(
            top: 110.0,
            left: 20.0,
            right: 20.0,
            child: Container(
              height: 204.0,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0)),
              padding: EdgeInsets.only(
                  left: 20.0, top: 10.0, right: 20.0, bottom: 30.0),
              // 账号和密码
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 用户名
                  _buildAccountTextField(),
                  // 密码
                  _buildPasswordTextField(),
                ],
              ),
            ),
          ),
          // 小兔子
          Positioned(
            top: 0.0,
            child: _passwordFocusNode!.hasFocus
                ? Image.asset('assets/close_eyes_half.png',
                    gaplessPlayback: true)
                : Image.asset('assets/open_eyes.png', gaplessPlayback: true),
          ),
        ],
      ),
    );
  }

  /// 用户协议
  Widget _buildAgree() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isAgree = !_isAgree;
            });
          },
          child: _isAgree
              ? Image.asset('assets/isAgree_on.png', gaplessPlayback: true)
              : Image.asset('assets/isAgree.png', gaplessPlayback: true),
        ),
        Padding(
          padding: EdgeInsets.only(left: 6.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Color(0xFF7F7F7F), fontSize: 14.0),
              text: '我已同意',
              children: [
                TextSpan(
                  text: '《隐私条款》',
                  style: TextStyle(color: Color(0xFF00BE9A)),
                ),
                TextSpan(text: '和'),
                TextSpan(
                  text: '《服务条款》',
                  style: TextStyle(color: Color(0xFF00BE9A)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 登录按钮 + 验证码登录 + 需要帮助
  Widget _buildLoginButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: _loginButtonOnTap,
          child: Container(
            height: 44.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              gradient: LinearGradient(
                // 渐变色
                colors: [Color(0xFF3CCEAF), Color(0xFF27BA9B)],
              ),
            ),
            child: Text(
              '登录',
              style: TextStyle(color: Colors.white, fontSize: 14.0),
            ),
          ),
        ),
        // 验证码登录和需要帮助
        Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Container(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '验证码登录',
                  style: TextStyle(fontSize: 14.0, color: Color(0xff7F7F7F)),
                ),
                // 需要帮助
                Text(
                  '需要帮助',
                  style: TextStyle(fontSize: 14.0, color: Color(0xFF00BE9A)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 其他登录方式
  Widget _buildOtherLogin() {
    return Container(
      padding: EdgeInsets.only(left: 20.0, right: 20.0),
      child: Column(
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 18.0,
                  height: 1.0,
                  decoration: BoxDecoration(color: Color(0xFFC4C4C4)),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Container(
                    child: Text(
                      '其他登录方式',
                      style:
                          TextStyle(color: Color(0xFF7F7F7F), fontSize: 14.0),
                    ),
                  ),
                ),
                Container(
                  width: 18.0,
                  height: 1.0,
                  decoration: BoxDecoration(color: Color(0xFFC4C4C4)),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/icon_login_wechat.png'),
                Padding(
                  padding: EdgeInsets.only(left: 32.0, right: 32.0),
                  child: Image.asset('assets/icon_login_qq.png'),
                ),
                Image.asset('assets/icon_login_weibo.png'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F8),
      appBar: AppBar(
        // 背景色
        backgroundColor: Color(0xFF00BF9B),
        // 左侧布局：返回按钮
        leading: IconButton(
          onPressed: () {
            // 返回上一级页面
            Navigator.pop(context);
          },
          icon: Image.asset('assets/fanhui_light.png'),
        ),
        // 去除底部阴影
        shadowColor: Colors.transparent,
        // 右侧布局：新用户注册
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (BuildContext context) {
                  return RegisterMobilePage();
                }),
              );
            },
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(right: 20.0),
              child: Text('新用户注册', style: TextStyle(fontSize: 14.0)),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // 账号密码失去焦点，隐藏键盘
          _accountFocusNode!.unfocus();
          _passwordFocusNode!.unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 绿色背景 + 账号密码输入框 + 小兔子
              _buildLoginCard(),
              // 用户协议
              Padding(
                padding: EdgeInsets.only(top: 26.0),
                child: _buildAgree(),
              ),
              // 登录按钮 + 验证码登录 + 需要帮助
              Padding(
                padding: EdgeInsets.only(top: 26.0, left: 20.0, right: 20.0),
                child: _buildLoginButton(),
              ),
              // 其他登录方式
              Padding(
                padding: EdgeInsets.only(top: 60.0),
                child: _buildOtherLogin(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
