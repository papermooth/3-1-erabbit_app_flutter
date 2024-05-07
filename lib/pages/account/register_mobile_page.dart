import 'package:dio/dio.dart';
import 'package:erabbit_app_flutter/pages/account/register_verify_page.dart';
import 'package:erabbit_app_flutter/service/account_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class RegisterMobilePage extends StatefulWidget {
  @override
  _RegisterMobilePageState createState() => _RegisterMobilePageState();
}

class _RegisterMobilePageState extends State<RegisterMobilePage> {
  /// 是否展示手机号一键清空按钮
  bool _isShowMobileClean = false;

  /// 手机号输入框控制器
  TextEditingController? _mobileController;

  /// 手机号输入框焦点
  FocusNode? _mobileFocusNode;

  /// 是否勾选用户协议
  bool _isAgree = true;

  @override
  void initState() {
    _mobileController = TextEditingController(text: '');
    _mobileFocusNode = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    _mobileController?.dispose();
    _mobileFocusNode?.dispose();

    super.dispose();
  }

  /// 下一步点击事件：校验手机号是否已注册
  void _nextStepOnTap() async {
    // 手机号有信息时才校验
    if (_mobileController!.text.length == 0) return;
    // 校验手机号格式
    RegExp accountRegExp = RegExp(r'^1[0-9]\d{9}$');
    bool isMatch = accountRegExp.hasMatch(_mobileController!.text);
    if (!isMatch) {
      EasyLoading.showToast('手机号格式错误');
      return;
    }

    // 校验用户协议
    if (!_isAgree) {
      EasyLoading.showToast('请勾选用户协议');
      return;
    }

    // 校验手机号是否已注册
    try {
      bool valid = await AccountAPI.registerCheck(_mobileController!.text);
      if (valid) {
        // 已注册：轻提示，手机号已存在
        EasyLoading.showToast('手机号已存在');
      } else {
        // 未注册：跳转到短信验证码页面
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (BuildContext context) {
            return RegisterVerifyPage(mobile: _mobileController!.text);
          }),
        );
      }
    } on DioError catch (e) {
      EasyLoading.showToast(e.response!.data['message']);
    }
  }

  /// 监听手机号输入框
  void _mobileOnChanged(String? mobile) {
    setState(() {
      _isShowMobileClean = mobile!.length > 0;
    });
  }

  /// 一键清空账号输入框
  void _mobileClean() {
    _mobileController?.clear();
    _mobileOnChanged('');
  }

  /// 手机号文本输入框
  Widget _buildMobileTextField() {
    return Container(
      height: 82.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              Text("手机号", style: TextStyle(fontSize: 14.0, color: Color(0xFF333333))),
              // 这里必须限定TextField的范围，不然会报布局的异常
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Container(
                    height: 34.0,
                    child: TextField(
                      focusNode: _mobileFocusNode,
                      controller: _mobileController,
                      onChanged: (String? text) {
                        _mobileOnChanged(text);
                      },
                      cursorRadius: Radius.circular(10.0),
                      cursorColor: Color(0xFFFFBD3B),
                      cursorHeight: 18.0,
                      style: TextStyle(fontSize: 14.0, color: Color(0xFF333333)),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 8.0),
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: '请输入手机号',
                        hintStyle: TextStyle(fontSize: 13.0, color: Color(0xffD8D8D8)),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                ),
              ),
              // 一键清除
              _isShowMobileClean
                  ? GestureDetector(
                      onTap: _mobileClean,
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
          // 去除点击和长按时的背景色
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
          _mobileFocusNode!.unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 注册步骤提示
              Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: Text('请输入手机号', style: TextStyle(fontSize: 15.0, color: Colors.black)),
              ),
              // 手机号文本输入框
              Padding(
                padding: EdgeInsets.only(left: 30.0, top: 30.0, right: 30.0),
                child: _buildMobileTextField(),
              ),
              // 服务条款
              Padding(
                padding: EdgeInsets.only(top: 60.0),
                child: _buildAgree(),
              ),
              // 下一步按钮 + 需要帮助
              Padding(
                padding: EdgeInsets.only(left: 20.0, top: 20.0, right: 20.0),
                child: _buildNextButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
