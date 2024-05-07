import 'package:dio/dio.dart';
import 'package:erabbit_app_flutter/pages/account/account_login_page.dart';
import 'package:erabbit_app_flutter/service/account_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class RegisterSettingPage extends StatefulWidget {
  RegisterSettingPage({this.mobile, this.code});

  /// 手机号
  final String? mobile;

  /// 短信验证码
  final String? code;

  @override
  _RegisterSettingPageState createState() => _RegisterSettingPageState();
}

class _RegisterSettingPageState extends State<RegisterSettingPage> {
  /// 是否展示用户名一键清空按钮
  bool _isShowUserNameClean = false;

  /// 用户名输入框控制器
  TextEditingController? _userNameController;

  /// 用户名输入框焦点
  FocusNode? _userNameFocusNode;

  /// 是否展示密码一键清空按钮
  bool _isShowPasswordClean = false;

  /// 密码输入框控制器
  TextEditingController? _passwordController;

  /// 密码输入框焦点
  FocusNode? _passwordFocusNode;

  /// 是否展示密文密码
  bool _isObscureText = true;

  @override
  void initState() {
    _userNameController = TextEditingController(text: '');
    _userNameFocusNode = FocusNode();
    _passwordController = TextEditingController(text: '');
    _passwordFocusNode = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    _userNameController?.dispose();
    _userNameFocusNode?.dispose();
    _passwordController?.dispose();
    _passwordFocusNode?.dispose();

    super.dispose();
  }

  /// 注册按钮点击事件
  void _registerButtonOnTap() async {
    // 用户名和密码都有信息时才校验
    if (_userNameController!.text.length == 0 || _passwordController!.text.length == 0) return;
    // 校验用户名格式
    RegExp accountRegExp = RegExp(r'^[a-zA-Z0-9]{5,20}$');
    bool isMatchUserName = accountRegExp.hasMatch(_userNameController!.text);
    if (!isMatchUserName) {
      EasyLoading.showToast('用户名格式错误');
      return;
    }
    // 校验密码格式
    RegExp passwordRegExp = RegExp(r'^[a-zA-Z0-9]{6,20}$');
    bool isMatchPassword = passwordRegExp.hasMatch(_passwordController!.text);
    if (!isMatchPassword) {
      EasyLoading.showToast('密码格式错误');
      return;
    }

    // 发送注册请求
    try {
      await AccountAPI.register(
        _userNameController!.text,
        widget.mobile!,
        widget.code!,
        _passwordController!.text,
      );

      // 注册成功：清除路由栈中除首页路由以外的所有路由，并推入一个账号密码登录的路由
      // 正确的方式
      // 第二个参数：目标路由、页面
      // 第三个参数：决定如何删除路由栈中的路由（true：不再清空路由，false：清空所有路由）
      Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(builder: (BuildContext context) {
          return AccountLoginPage();
        }),
        ModalRoute.withName('/'),
      );

      // 以下方式有问题
      // Navigator.push(
      //   context,
      //   CupertinoPageRoute(builder: (BuildContext context) {
      //     return AccountLoginPage();
      //   }),
      // );
    } on DioError catch (e) {
      EasyLoading.showToast(e.response!.data['message']);
    }
  }

  /// 监听密码输入框
  void _passwordOnChanged(String? password) {
    setState(() {
      _isShowPasswordClean = password!.length > 0;
    });
  }

  /// 一键清空密码输入框
  void _passwordClean() {
    _passwordController?.clear();
    _passwordOnChanged('');
  }

  /// 是否密文展示密码
  void _obscureTextOnTap() {
    setState(() {
      _isObscureText = !_isObscureText;
    });
  }

  /// 监听用户名输入框
  void _userNameOnChanged(String? userName) {
    setState(() {
      _isShowUserNameClean = userName!.length > 0;
    });
  }

  /// 一键清空用户名输入框
  void _userNameClean() {
    _userNameController?.clear();
    _userNameOnChanged('');
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
              Text("密码", style: TextStyle(fontSize: 14.0, color: Color(0xFF333333))),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Container(
                    height: 34.0,
                    child: TextField(
                      focusNode: _passwordFocusNode,
                      controller: _passwordController,
                      onChanged: (String? text) {
                        _passwordOnChanged(text);
                      },
                      cursorRadius: Radius.circular(10.0),
                      cursorColor: Color(0xFFFFBD3B),
                      cursorHeight: 18.0,
                      style: TextStyle(fontSize: 14.0, color: Color(0xFF333333)),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 8.0),
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: '6到20位字母、数字和符号组合',
                        hintStyle: TextStyle(fontSize: 13.0, color: Color(0xffD8D8D8)),
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      // 密文展示密码
                      obscureText: _isObscureText,
                    ),
                  ),
                ),
              ),
              // 一键清除
              _isShowPasswordClean
                  ? GestureDetector(
                      onTap: _passwordClean,
                      child: Image.asset('assets/text_clean.png'),
                    )
                  : Container(),
              // 是否明文显示密码
              Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: GestureDetector(
                  onTap: _obscureTextOnTap,
                  child: _isObscureText
                      ? Image.asset('assets/yanjing.png', gaplessPlayback: true)
                      : Image.asset('assets/yanjing_on.png', gaplessPlayback: true),
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

  /// 构建用户名输入框
  Widget _buildAccountTextField() {
    return Container(
      height: 82.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              Text("用户名", style: TextStyle(fontSize: 14.0, color: Color(0xFF333333))),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Container(
                    height: 34.0,
                    child: TextField(
                      focusNode: _userNameFocusNode,
                      controller: _userNameController,
                      onChanged: (String? text) {
                        _userNameOnChanged(text);
                      },
                      cursorRadius: Radius.circular(10.0),
                      cursorColor: Color(0xFFFFBD3B),
                      cursorHeight: 18.0,
                      style: TextStyle(fontSize: 14.0, color: Color(0xFF333333)),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 8.0),
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: '请输入用户名',
                        hintStyle: TextStyle(fontSize: 13.0, color: Color(0xffD8D8D8)),
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                ),
              ),
              // 一键清除
              _isShowUserNameClean
                  ? GestureDetector(
                      onTap: _userNameClean,
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

  /// 用户名密码输入框
  Widget _buildUserNameCard() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 用户名
        _buildAccountTextField(),
        // 密码
        _buildPasswordTextField(),
      ],
    );
  }

  /// 注册完成按钮 + 需要帮助
  Widget _buildRegisterButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: _registerButtonOnTap,
          child: Container(
            height: 44.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              gradient: LinearGradient(colors: [Color(0xFF3CCEAF), Color(0xFF27BA9B)]),
            ),
            child: Text('完成', style: TextStyle(color: Colors.white, fontSize: 14.0)),
          ),
        ),
        // 需要帮助
        Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Text('需要帮助', style: TextStyle(fontSize: 14.0, color: Color(0xFF00BE9A))),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          '用户注册',
          style: TextStyle(color: Color(0xFF282828), fontSize: 16.0),
        ),
        leading: Theme(
          data: ThemeData(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
          ),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Image.asset('assets/appbar_fanhui.png'),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          _userNameFocusNode!.unfocus();
          _passwordFocusNode!.unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 注册步骤提示
              Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: Text('设置用户名和登录密码', style: TextStyle(fontSize: 15.0, color: Colors.black)),
              ),
              // 用户名密码文本输入框
              Padding(
                padding: EdgeInsets.only(left: 30.0, top: 30.0, right: 30.0),
                child: _buildUserNameCard(),
              ),
              // 注册完成按钮 + 需要帮助
              Padding(
                padding: EdgeInsets.only(left: 20.0, top: 60.0, right: 20.0),
                child: _buildRegisterButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
