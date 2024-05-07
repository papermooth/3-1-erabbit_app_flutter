import 'package:dio/dio.dart';
import 'package:erabbit_app_flutter/models/goods_detail_model.dart';
import 'package:erabbit_app_flutter/models/order_payment_model.dart';
import 'package:erabbit_app_flutter/pages/goods_detail/widgets/goods_detail_address.dart';
import 'package:erabbit_app_flutter/pages/order_payment/payment_cancel_page.dart';
import 'package:erabbit_app_flutter/pages/order_payment/payment_failed_page.dart';
import 'package:erabbit_app_flutter/pages/order_payment/payment_success_page.dart';
import 'package:erabbit_app_flutter/pages/order_payment/widgets/deliveryTime_types_widget.dart';
import 'package:erabbit_app_flutter/service/order_payment_api.dart';
import 'package:erabbit_app_flutter/widgets/custom_image.dart';
import 'package:erabbit_app_flutter/widgets/loading_widget.dart';
import 'package:erabbit_app_flutter/widgets/price_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:tobias/tobias.dart';

/// 监听收货地址
late ValueNotifier<UserAddress?> userAddressNotifier;

/// 监听配送时间
late ValueNotifier<Map> deliveryTimeTypeNotifier;

class OrderSettlementPage extends StatefulWidget {
  OrderSettlementPage({this.orderSettlementModel});

  /// 订单结算数据：立即购买时生成的订单结算数据
  final OrderSettlementModel? orderSettlementModel;

  @override
  _OrderSettlementPageState createState() => _OrderSettlementPageState();
}

class _OrderSettlementPageState extends State<OrderSettlementPage> {
  /// 支付渠道：1 支付宝、2 微信
  List<Map> _paymentMethods = [
    {'name': '支付宝支付', 'payChannel': 1, 'selected': true},
    {'name': '微信支付', 'payChannel': 2, 'selected': false}
  ];

  /// 配送时间和类型：1 不限，2 工作日，3 双休或节假日
  List<Map> _deliveryTimeTypes = [
    {
      'deliveryTimeType': 1,
      'name': '时间不限（周一至周日）',
      'selected': true,
    },
    {
      'deliveryTimeType': 2,
      'name': '工作日配送（周一至周五）',
      'selected': false,
    },
    {
      'deliveryTimeType': 3,
      'name': '周末配送（包括节假日）',
      'selected': false,
    },
  ];

  /// 备注输入框控制器
  late TextEditingController _noteMessageController;

  /// 监听一键清除按钮
  late ValueNotifier<bool> _noteMessageNotifier;

  /// 备注输入框焦点
  late FocusNode _noteMessageFocusNode;

  /// 订单结算总模型
  OrderSettlementModel? _settlementModel;

  /// 收货地址
  List<UserAddress> _userAddresses = [];

  /// 结算商品
  List<OrderSettlementGoodsModel> _goods = [];

  /// 结算金额
  OrderSettlementSummaryModel? _summary;

  /// 订单ID
  String _orderId = '';

  @override
  void initState() {
    // 配送时间
    deliveryTimeTypeNotifier = ValueNotifier({
      'deliveryTimeType': 1,
      'name': '时间不限（周一至周日）',
      'selected': true,
    });

    // 买家备注
    _noteMessageController = TextEditingController(text: '');
    _noteMessageNotifier = ValueNotifier(false);
    _noteMessageFocusNode = FocusNode();

    // 订单结算
    // 如果外界传入了订单结算数据，直接使用传入的订单结算数据渲染页面，去结算时才发请求
    if (widget.orderSettlementModel != null) {
      _settlementModel = widget.orderSettlementModel;
      _userAddresses = _settlementModel!.userAddresses!;
      _goods = _settlementModel!.goods!;
      _summary = _settlementModel!.summary!;

      // 监听默认的收货地址
      userAddressNotifier = ValueNotifier(_getUserDefaultAddress());

      // 更新状态
      setState(() {});
    } else {
      _orderSettlement();
    }

    super.initState();
  }

  @override
  void dispose() {
    deliveryTimeTypeNotifier.dispose();
    _noteMessageController.dispose();
    _noteMessageNotifier.dispose();
    _noteMessageFocusNode.dispose();

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
      // 取消支付
      Navigator.pushReplacement(context, CupertinoPageRoute(builder: (BuildContext context) {
        return PaymentCancelPage(orderId: _orderId);
      }));
    } else {
      // 支付失败
      Navigator.pushReplacement(context, CupertinoPageRoute(builder: (BuildContext context) {
        return PaymentFailedPage(orderId: _orderId);
      }));
    }
  }

  /// 支付宝支付
  void _orderAlipay() async {
    try {
      String orderString = await OrderPaymentAPI.orderAlipay(_orderId);
      debugPrint('支付宝支付：$orderString');

      // 唤起支付宝钱包并进行支付
      _openAlipay(orderString);
    } on DioError catch (e) {
      EasyLoading.showToast(e.response!.data['message']);
    }
  }

  /// 提交订单
  void _orderCommit() async {
    // 准备待提交的订单数据
    // 收货地址：如果没有选择收货地址，需要提示用户
    if (userAddressNotifier.value == null) {
      EasyLoading.showToast('请选择收货地址!');
      return;
    }
    // 结算商品 goods = [{'skuId': '12388778990', 'count': 2},{'skuId': '123875373990', 'count': 1},...]
    List goods = [];
    _goods.forEach((OrderSettlementGoodsModel goodsModel) {
      goods.add({
        'skuId': goodsModel.skuId,
        'count': goodsModel.count,
      });
    });
    // 支付渠道：默认支付宝支付
    // 配送时间：deliveryTimeTypeNotifier.value['deliveryTimeType']
    // 买家备注：_noteMessageController.text
    // 支付方式：默认在线支付

    // 发送提交订单请求：调用提交订单接口方法
    try {
      Map ret = await OrderPaymentAPI.orderCommit(
        goods: goods,
        addressId: userAddressNotifier.value!.id!,
        deliveryTimeType: deliveryTimeTypeNotifier.value['deliveryTimeType'],
        buyerMessage: _noteMessageController.text,
      );
      // 记录订单ID
      _orderId = ret['id'];

      // 提交成功：发起支付宝支付请求
      _orderAlipay();
    } on DioError catch (e) {
      EasyLoading.showToast(e.response!.data['message']);
    }
  }

  /// 订单结算
  void _orderSettlement() async {
    try {
      _settlementModel = await OrderPaymentAPI.orderSettlement();
      _userAddresses = _settlementModel!.userAddresses!;
      _goods = _settlementModel!.goods!;
      _summary = _settlementModel!.summary!;

      // 监听默认的收货地址
      userAddressNotifier = ValueNotifier(_getUserDefaultAddress());

      // 更新状态
      setState(() {});
    } on DioError catch (e) {
      EasyLoading.showToast(e.response!.data['message']);
    }
  }

  /// 获取默认的收货地址
  UserAddress? _getUserDefaultAddress() {
    UserAddress? userAddress;

    _userAddresses.forEach((UserAddress element) {
      if (element.isDefault!) {
        userAddress = element;
        return;
      }
    });

    return userAddress;
  }

  /// 构建收货地址
  Widget _buildUserAddress() {
    return GestureDetector(
      onTap: () {
        // 展示收货地址弹窗
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) {
            return GoodsDetailAddressWidget(userAddresses: _userAddresses);
          },
        );
      },
      child: Container(
        margin: EdgeInsets.only(top: 10.0),
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5.0)),
        clipBehavior: Clip.antiAlias,
        child: ValueListenableBuilder(
          valueListenable: userAddressNotifier,
          builder: (BuildContext context, UserAddress? value, Widget? child) {
            return value != null
                ? Row(
                    children: [
                      // 地址定位图标
                      ClipOval(
                        child: Container(
                          width: 30.0,
                          height: 30.0,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Color(0xFF3CCEAF), Color(0xFF27BA9B)]),
                          ),
                          child: Image.asset('assets/order_location.png'),
                        ),
                      ),
                      // 地址信息：姓名+电话+地址
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 姓名+电话
                              Row(
                                children: [
                                  Text(
                                    value.receiver!,
                                    style: TextStyle(color: Color(0xFF262626), fontSize: 16.0),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 15.0),
                                    child: Text(
                                      value.contact!,
                                      style: TextStyle(color: Color(0xFF333333), fontSize: 14.0),
                                    ),
                                  ),
                                ],
                              ),
                              // 地址
                              Padding(
                                padding: EdgeInsets.only(top: 15.0),
                                child: Text(
                                  value.fullLocation! + value.address!,
                                  style: TextStyle(color: Color(0xFF333333), fontSize: 14.0),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 18.0),
                        child: Image.asset('assets/arrow_right.png'),
                      ),
                    ],
                  )
                : Text(
                    '暂无地址',
                    style: TextStyle(color: Color(0xFF333333), fontSize: 14.0),
                  );
          },
        ),
      ),
    );
  }

  /// 构建结算的商品列表
  Widget _buildSettlementGoods() {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5.0)),
      clipBehavior: Clip.antiAlias,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _goods.length,
        itemBuilder: (BuildContext context, int index) {
          OrderSettlementGoodsModel goodsModel = _goods[index];
          return Container(
            padding: EdgeInsets.all(10.0),
            color: Colors.white,
            child: Row(
              children: [
                // 图片
                CustomImage(
                  url: goodsModel.picture!,
                  width: 86.0,
                  height: 86.0,
                ),
                // 商品名称+数量+规格+价格
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 名称+数量
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                goodsModel.name!,
                                style: TextStyle(color: Color(0xFF262626), fontSize: 13.0),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 15.0),
                              child: Text(
                                'x ${goodsModel.count}',
                                style: TextStyle(fontSize: 14.0, color: Color(0xFF262626)),
                              ),
                            ),
                          ],
                        ),
                        // 规格
                        Padding(
                          padding: EdgeInsets.only(top: 6.0),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
                            decoration:
                                BoxDecoration(color: Color(0xFFF7F7F8), borderRadius: BorderRadius.circular(2.0)),
                            child: Text(
                              goodsModel.attrsText!,
                              style: TextStyle(color: Color(0xFF888888), fontSize: 11.0, height: 1.0),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        // 价格
                        Padding(
                          padding: EdgeInsets.only(top: 6.0),
                          child: PriceWidget(price: goodsModel.payPrice),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 支付渠道
  Widget _buildPaymentMethods() {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5.0)),
      clipBehavior: Clip.antiAlias,
      child: MediaQuery.removePadding(
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
                  index != 0 ? Container(height: 1.0, color: Color(0xFFF7F7F8)) : Container(),
                  Container(
                    decoration: BoxDecoration(color: Colors.white),
                    height: 44.0,
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 构建支付备注：配送时间+买家备注
  Widget _buildNoteMessage() {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5.0)),
      child: Column(
        children: [
          // 配送时间
          ValueListenableBuilder(
            valueListenable: deliveryTimeTypeNotifier,
            builder: (BuildContext context, Map value, Widget? child) {
              return GestureDetector(
                onTap: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (BuildContext context) {
                      return DeliveryTimeTypesWidget(deliveryTimeTypes: _deliveryTimeTypes);
                    },
                  );
                },
                child: Container(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '配送时间',
                        style: TextStyle(fontSize: 14.0, color: Color(0xFF262626)),
                      ),
                      Row(
                        children: [
                          Text(
                            value['name'],
                            style: TextStyle(fontSize: 14.0, color: Color(0xFF262626)),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 15.0),
                            child: Image.asset('assets/arrow_right.png'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // 买家备注
          Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Row(
              children: [
                Text(
                  '买家备注',
                  style: TextStyle(fontSize: 14.0, color: Color(0xFF262626)),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: TextField(
                      focusNode: _noteMessageFocusNode,
                      controller: _noteMessageController,
                      onChanged: (String text) {
                        // 更新一键清除按钮
                        _noteMessageNotifier.value = text.length > 0;
                      },
                      cursorRadius: Radius.circular(10.0),
                      cursorColor: Color(0xFF27BA9B),
                      cursorHeight: 18.0,
                      style: TextStyle(fontSize: 14.0, color: Color(0xFF989898)),
                      decoration: InputDecoration(
                        isCollapsed: true, // 去掉最小高度的约束
                        border: InputBorder.none,
                        hintText: '说点儿什么吧',
                        hintStyle: TextStyle(fontSize: 12.0, color: Color(0xFF989898)),
                      ),
                      keyboardType: TextInputType.text,
                      minLines: 1,
                      maxLines: 7,
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                ),
                // 一键清除
                ValueListenableBuilder(
                  valueListenable: _noteMessageNotifier,
                  builder: (BuildContext context, bool value, Widget? child) {
                    return value
                        ? Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: GestureDetector(
                              onTap: () {
                                _noteMessageController.clear();
                                _noteMessageNotifier.value = false;
                              },
                              child: Image.asset('assets/text_clean.png'),
                            ),
                          )
                        : Container();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建结算金额信息
  Widget _buildSettlementSummary() {
    return Container(
      margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
      padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5.0)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // 商品总价
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '商品总价',
                style: TextStyle(fontSize: 14.0, color: Color(0xFF262626)),
              ),
              Text(
                '¥${_summary!.totalPrice!}',
                style: TextStyle(fontSize: 14.0, color: Color(0xFF262626)),
              ),
            ],
          ),
          // 运费
          Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '运费',
                  style: TextStyle(fontSize: 14.0, color: Color(0xFF262626)),
                ),
                Text(
                  '¥${_summary!.postFee}',
                  style: TextStyle(fontSize: 14.0, color: Color(0xFF262626)),
                ),
              ],
            ),
          ),
          // 折扣
          Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '折扣',
                  style: TextStyle(fontSize: 14.0, color: Color(0xFF262626)),
                ),
                Text(
                  '-¥${_summary!.discountPrice}',
                  style: TextStyle(fontSize: 14.0, color: Color(0xFFEC023A)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建底部操作栏
  Widget _buildBottomBar() {
    // 底部操作栏的高度：自身高度 + 不规则屏幕底部间距
    return Container(
      height: 60.0 + MediaQuery.of(context).padding.bottom,
      color: Colors.white,
      child: Column(
        children: [
          Container(height: 1.0, color: Color(0xFFEDEDED)),
          Container(
            height: 59.0,
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '合计: ',
                      style: TextStyle(color: Color(0xFF1E1E1E), fontSize: 13.0),
                    ),
                    PriceWidget(
                      price: _summary!.totalPayPrice,
                      symbolFontSize: 12.0,
                      integerFontSize: 20.0,
                      decimalFontSize: 18.0,
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _orderCommit,
                  child: Container(
                    width: 100.0,
                    height: 40.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2.0),
                      gradient: LinearGradient(colors: [Color(0xff3CCEAF), Color(0xff27BA9B)]),
                    ),
                    child: Text(
                      '提交订单',
                      style: TextStyle(fontSize: 13.0, color: Colors.white),
                    ),
                  ),
                ),
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
        title: Text('填写订单', style: TextStyle(fontSize: 16.0, color: Color(0xFF282828))),
        backgroundColor: Colors.white,
        centerTitle: true,
        shadowColor: Colors.transparent,
        // 左侧返回箭头
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image.asset('assets/appbar_fanhui.png'),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
      ),
      body: _settlementModel != null
          ? Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: GestureDetector(
                      onTap: () {
                        _noteMessageFocusNode.unfocus();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          children: [
                            // 收货地址
                            _buildUserAddress(),
                            // 结算的商品列表
                            _buildSettlementGoods(),
                            // 支付渠道
                            _buildPaymentMethods(),
                            // 支付备注
                            _buildNoteMessage(),
                            // 结算总金额
                            _buildSettlementSummary(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // 底部操作栏
                _buildBottomBar()
              ],
            )
          : LoadingWidget(),
    );
  }
}
