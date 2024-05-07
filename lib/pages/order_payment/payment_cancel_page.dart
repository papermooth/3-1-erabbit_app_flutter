import 'dart:async';

import 'package:dio/dio.dart';
import 'package:erabbit_app_flutter/pages/order_payment/payment_failed_page.dart';
import 'package:erabbit_app_flutter/pages/order_payment/payment_success_page.dart';
import 'package:erabbit_app_flutter/service/order_payment_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:tobias/tobias.dart';

class PaymentCancelPage extends StatefulWidget {
  PaymentCancelPage({this.orderId});

  /// 订单ID
  final String? orderId;

  @override
  _PaymentCancelPageState createState() => _PaymentCancelPageState();
}

class _PaymentCancelPageState extends State<PaymentCancelPage> {
  /// 支付渠道：1 支付宝、2 微信
  List<Map> _paymentMethods = [
    {'name': '支付宝支付', 'payChannel': 1, 'selected': true},
    {'name': '微信支付', 'payChannel': 2, 'selected': false}
  ];

  /// 订单详情数据
  Map? _orderDetail;

  /// 倒计时定时器
  Timer? _countdownTimer;

  /// 局部刷新倒计时
  ValueNotifier<String>? _countdownNotifier;

  @override
  void initState() {
    _countdownNotifier = ValueNotifier('');

    // 获取订单详情
    _getOrderDetail();

    super.initState();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _countdownNotifier?.dispose();
    super.dispose();
  }

  /// 唤起支付宝钱包并进行支付
  void _openAlipay(String orderString) async {
    // 判断是否安装支付宝APP
    bool isinstall = await isAliPayInstalled();
    if (!isinstall) {
      EasyLoading.showToast('请先安装支付宝APP!');
      return;
    }
    // 唤起支付宝并支付：当前开发阶段对接沙箱环境，SANDBOX；项目上线时需要对接正式环境，ONLINE
    Map alipayRet = await aliPay(orderString, evn: AliPayEvn.SANDBOX);

    // 获取并处理支付结果
    // 判断支付结果状态：成功、取消、失败
    if (alipayRet['resultStatus'] == '9000') {
      // 支付成功：进入到支付成功页面
      Navigator.pushReplacement(context, CupertinoPageRoute(builder: (BuildContext context) {
        return PaymentSuccessPage();
      }));
    } else if (alipayRet['resultStatus'] == '6001') {
      // 取消支付：如果在待支付页面继续取消订单，则不作任何处理
    } else {
      // 支付失败
      Navigator.pushReplacement(context, CupertinoPageRoute(builder: (BuildContext context) {
        return PaymentFailedPage(orderId: widget.orderId);
      }));
    }
  }

  /// 支付宝支付
  void _orderAlipay() async {
    try {
      String orderString = await OrderPaymentAPI.orderAlipay(widget.orderId!);
      debugPrint('支付宝支付：$orderString');

      // 唤起支付宝钱包并进行支付
      _openAlipay(orderString);
    } on DioError catch (e) {
      EasyLoading.showToast(e.response!.data['message']);
    }
  }

  /// 获取订单详情
  void _getOrderDetail() async {
    try {
      _orderDetail = await OrderPaymentAPI.orderDetail(widget.orderId!);
      debugPrint('订单详情：$_orderDetail');

      // 展示支付超时倒计时
      int countdown = _orderDetail!['countdown'];
      // 测试倒计时超时
      // countdown = 7;
      // 判断支付是否已超时
      if (countdown <= -1) {
        // 已超时
        // 局部刷新倒计时
        _countdownNotifier?.value = '剩下 00:00';
        // 展示超时对话框
        _showPaymentTimeOutDialog();
      } else {
        // 未超时:先展示初始的倒计时时间
        String m = (countdown / 60).floor().toString().padLeft(2, '0');
        String s = (countdown % 60).toString().padLeft(2, '0');
        String countdownStr = '剩下 $m:$s';
        // 局部刷新倒计时
        _countdownNotifier?.value = countdownStr;

        // 创建定时器
        _countdownTimer?.cancel();
        _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
          // 倒计时
          countdown--;

          // 如果倒计时超时
          if (countdown < 1) {
            // 停止定时器
            _countdownTimer?.cancel();
            // 展示超时对话框
            _showPaymentTimeOutDialog();
          }

          // 倒计时时间转秒数：剩下 185秒 ==> 剩下 03:05
          // 生成分：185秒 ==> 03分
          String m = (countdown / 60).floor().toString().padLeft(2, '0');
          // 生成秒：185秒 ==> 05秒
          String s = (countdown % 60).toString().padLeft(2, '0');
          String countdownStr = '剩下 $m:$s';

          // 局部刷新倒计时
          _countdownNotifier?.value = countdownStr;
        });
      }

      // 更新状态
      setState(() {});
    } catch (e) {
      debugPrint('$e');
    }
  }

  /// 展示支付超时对话框
  void _showPaymentTimeOutDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false, // 禁止点击背景退出对话框
      barrierLabel: '',
      transitionDuration: Duration(milliseconds: 200),
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return _buildPaymentTimeOutDialog();
      },
    );
  }

  /// 构建支付超时对话框
  Widget _buildPaymentTimeOutDialog() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
        ),
        clipBehavior: Clip.antiAlias,
        width: MediaQuery.of(context).size.width - 100.0,
        height: 160.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/payment_failed_tip.png"),
            Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text(
                '订单超时已失效',
                style: TextStyle(color: Color(0xFF333333), fontSize: 16.0, fontWeight: FontWeight.w500),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // 全部删除，所以不需要Navigator.of(context, rootNavigator: true).pop();
                        Navigator.popUntil(context, ModalRoute.withName('/'));
                      },
                      child: Container(
                        height: 40.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.0),
                          border: Border.all(color: Color(0xFF666666)),
                        ),
                        child: Text(
                          '返回首页',
                          style: TextStyle(fontSize: 13.0, color: Color(0xFF666666)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 40.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.0),
                          gradient: LinearGradient(colors: [Color(0xff3CCEAF), Color(0xff27BA9B)]),
                        ),
                        child: Text(
                          '重新购买',
                          style: TextStyle(fontSize: 13.0, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 倒计时
  Widget _buildCountDown() {
    return Container(
      height: 152.0,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            // '¥129.00',
            '¥' + (_orderDetail != null ? _orderDetail!['payMoney'].toString() : ''),
            style: TextStyle(color: Color(0xFF333333), fontSize: 24.0, fontWeight: FontWeight.w500),
          ),
          Padding(
            padding: EdgeInsets.only(top: 6),
            child: ValueListenableBuilder(
              valueListenable: _countdownNotifier!,
              builder: (BuildContext context, String value, Widget? child) {
                return Text(
                  value,
                  style: TextStyle(color: Color(0xFF999999), fontSize: 12.0),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 支付渠道
  Widget _buildPaymentMethods() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _paymentMethods.length,
        itemBuilder: (BuildContext context, int index) {
          Map paymentMethod = _paymentMethods[index];
          return GestureDetector(
            onTap: () {
              // 控制选中状态
              for (var i = 0; i < _paymentMethods.length; i++) {
                Map element = _paymentMethods[i];
                element["selected"] = index == i;
              }

              // 更新状态
              setState(() {});
            },
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(color: Colors.white),
                  height: 54.0,
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Container(
                          width: 18.0,
                          height: 18.0,
                          child: paymentMethod['selected']
                              ? Image.asset('assets/check.png', gaplessPlayback: true)
                              : Image.asset('assets/uncheck.png', gaplessPlayback: true),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 15.0),
                        child: Image.asset('assets/pay_$index.png'),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text(
                          paymentMethod['name'],
                          style: TextStyle(color: Color(0xFF333333), fontSize: 14.0),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 1.0, color: Color(0xFFF7F7F8)),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 底部操作栏
  Widget _buildBottomBar() {
    // 底部操作栏的高度：自身高度 + 不规则屏幕底部间距
    return Container(
      height: 60.0 + MediaQuery.of(context).padding.bottom,
      color: Colors.white,
      child: Column(
        children: [
          Divider(height: 1.0, color: Color(0xFFEDEDED)),
          Container(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Padding(
              padding: EdgeInsets.only(top: 9.0),
              child: GestureDetector(
                onTap: () {
                  _orderAlipay();
                },
                child: Container(
                  height: 40.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.0),
                    gradient: LinearGradient(colors: [Color(0xff3CCEAF), Color(0xff27BA9B)]),
                  ),
                  child: Text(
                    '确定付款',
                    style: TextStyle(fontSize: 13.0, color: Colors.white),
                  ),
                ),
              ),
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
        title: Text('待支付', style: TextStyle(fontSize: 16.0, color: Color(0xFF282828))),
        backgroundColor: Colors.white,
        centerTitle: true,
        shadowColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image.asset('assets/appbar_fanhui.png'),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
      ),
      body: Column(
        children: [
          // 待支付倒计时
          _buildCountDown(),
          // 支付渠道
          Expanded(
            child: Container(
              color: Colors.white,
              child: Container(
                padding: EdgeInsets.only(left: 20.0),
                child: _buildPaymentMethods(),
              ),
            ),
          ),
          // 立即购买
          _buildBottomBar(),
        ],
      ),
    );
  }
}
