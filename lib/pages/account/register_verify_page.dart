import 'dart:async';

import 'package:dio/dio.dart';
import 'package:erabbit_app_flutter/pages/account/register_setting_page.dart';
import 'package:erabbit_app_flutter/service/account_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class RegisterVerifyPage extends StatefulWidget {
  RegisterVerifyPage({this.mobile});

  /// 手机号
  final String? mobile;

  @override
  _RegisterVerifyPageState createState() => _RegisterVerifyPageState();
}

class _RegisterVerifyPageState extends State<RegisterVerifyPage> {
  /// 是否展示验证码一键清空按钮
  bool _isShowVerifyClean = false;

  /// 验证码输入框控制器
  TextEditingController? _verifyController;

  /// 验证码输入框焦点
  FocusNode? _verifyFocusNode;

  /// 倒计时时长
  int _countdownTime = 0;

  /// 倒计时Timer
  Timer? _timer;

  /// 标记是否正在发送验证码:默认值false，表示默认未发送验证码
  bool _isSending = false;

  @override
  void initState() {
    _verifyController = TextEditingController(text: '');
    _verifyFocusNode = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    _verifyController?.dispose();
    _verifyFocusNode?.dispose();
    // 停止Timer的回调
    _timer!.cancel();

    super.dispose();
  }

  /// 下一步点击事件
  void _nextStepOnTap() async {
    if (_verifyController!.text.length == 0) return;
    // 校验短信验证码是否满足条件
    RegExp regExp = RegExp(r'^\d{6}$');
    bool isMatch = regExp.hasMatch(_verifyController!.text);
    if (!isMatch) {
      EasyLoading.showToast('短信验证码格式错误');
      return;
    }

    // 校验短信验证码是否正确
    try {
      bool valid = await AccountAPI.checkSMSVerifyCode(widget.mobile!, _verifyController!.text);
      // 判断短信验证码是否正确
      if (valid) {
        // 停止倒计时
        _timer?.cancel();
        // 将正在倒计时的标记设置false
        _isSending = false;
        // 重置倒计时时间、刷新文字为"发送验证码"
        setState(() {
          _countdownTime = 0;
        });

        // 跳转到用户注册页面
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (BuildContext context) {
            return RegisterSettingPage(mobile: widget.mobile!, code: _verifyController!.text);
          }),
        );
      } else {
        EasyLoading.showToast('验证码输入错误');
      }
    } on DioError catch (e) {
      EasyLoading.showToast(e.response!.data['message']);
    }
  }

  /// 发送验证码点击事件
  void _sendVerifyCodeOnTap() async {
    // 判断是否正在发送验证码：如果正在发送验证码，终止逻辑
    if (_isSending) return;
    // 逻辑进入这里，表示即将要发送短信验证码
    _isSending = true;

    // 倒计时60秒
    setState(() {
      _countdownTime = 60;
    });

    // 倒计时：按秒倒计时
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      debugPrint('$_countdownTime');
      // 倒计时
      _countdownTime--;

      // 判断倒计时是否结束
      if (_countdownTime < 1) {
        // 停止倒计时：停止Timer的回调
        _timer!.cancel();
        // 倒计时结束，没有正在发送验证码
        _isSending = false;
      }

      // 更新状态
      setState(() {});
    });

    // 发送短信验证码
    try {
      await AccountAPI.getSMSVerifyCode(widget.mobile!, 'register');
      // 测试：提示短信验证码接口调用成功的
      EasyLoading.showToast('获取短信验证码成功');
    } on DioError catch (e) {
      EasyLoading.showToast(e.response!.data['message']);
    }
  }

  /// 监听验证码输入框
  void _verifyOnChanged(String? verifyCode) {
    setState(() {
      _isShowVerifyClean = verifyCode!.length > 0;
    });
  }

  /// 一键清空验证码输入框
  void _mobileClean() {
    _verifyController?.clear();
    _verifyOnChanged('');
  }

  /// 验证码文本输入框
  Widget _buildVerifyTextField() {
    return Container(
      height: 82.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              Text("手机验证码", style: TextStyle(fontSize: 14.0, color: Color(0xFF333333))),
              // 这里必须限定TextField的范围，不然会报布局的异常
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Container(
                    height: 34.0,
                    child: TextField(
                      focusNode: _verifyFocusNode,
                      controller: _verifyController,
                      onChanged: (String? text) {
                        _verifyOnChanged(text);
                      },
                      cursorRadius: Radius.circular(10.0),
                      cursorColor: Color(0xFFFFBD3B),
                      cursorHeight: 18.0,
                      style: TextStyle(fontSize: 14.0, color: Color(0xFF333333)),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 8.0),
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: '请输入手机验证码',
                        hintStyle: TextStyle(fontSize: 13.0, color: Color(0xffD8D8D8)),
                      ),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                ),
              ),
              // 一键清除
              _isShowVerifyClean
                  ? GestureDetector(
                      onTap: _mobileClean,
                      child: Image.asset('assets/text_clean.png'),
                    )
                  : Container(),
              // 发送验证码
              Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: GestureDetector(
                  onTap: _sendVerifyCodeOnTap,
                  child: Text(
                    _countdownTime > 0 ? '重新发送(${_countdownTime}s)' : '发送验证码',
                    style: TextStyle(color: Color(0xFF333333), fontSize: 13.0),
                  ),
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

  /// 下一步按钮 + 需要帮助
  Widget _buildNextButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: _nextStepOnTap,
          child: Container(
            height: 44.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              gradient: LinearGradient(colors: [Color(0xFF3CCEAF), Color(0xFF27BA9B)]),
            ),
            child: Text('下一步', style: TextStyle(color: Colors.white, fontSize: 14.0)),
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
        title: Text('用户注册', style: TextStyle(color: Color(0xFF282828), fontSize: 16.0)),
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
          _verifyFocusNode!.unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 注册步骤提示
              Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: Text('请输入接收到的验证码', style: TextStyle(fontSize: 15.0, color: Colors.black)),
              ),
              // 验证码文本输入框
              Padding(
                padding: EdgeInsets.only(left: 30.0, top: 30.0, right: 30.0),
                child: _buildVerifyTextField(),
              ),
              // 下一步按钮 + 需要帮助
              Padding(
                padding: EdgeInsets.only(left: 20.0, top: 60.0, right: 20.0),
                child: _buildNextButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
