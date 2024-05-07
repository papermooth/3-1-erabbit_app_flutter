import 'package:dio/dio.dart';
import 'package:erabbit_app_flutter/models/order_payment_model.dart';
import 'package:erabbit_app_flutter/pages/order_payment/payment_success_page.dart';
import 'package:erabbit_app_flutter/pages/order_payment/widgets/order_list_bottom_bar.dart';
import 'package:erabbit_app_flutter/service/order_payment_api.dart';
import 'package:erabbit_app_flutter/widgets/custom_image.dart';
import 'package:erabbit_app_flutter/widgets/custom_refresher.dart';
import 'package:erabbit_app_flutter/widgets/loading_widget.dart';
import 'package:erabbit_app_flutter/widgets/price_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tobias/tobias.dart';

class OrderListContentWidget extends StatefulWidget {
  OrderListContentWidget({this.orderState= 0});

  /// 订单状态
  final int? orderState;

  @override
  _OrderListContentWidgetState createState() => _OrderListContentWidgetState();
}

class _OrderListContentWidgetState extends State<OrderListContentWidget> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  /// 订单列表总数据模型
  OrderListModel? _orderListModel;

  /// 订单列表数据
  List<OrderInfoModel> _items = [];

  /// 刷新控制器
  late RefreshController _refreshController;

  /// 记录当前页码:默认加载第一页
  int _currentPage = 1;

  /// 记录当前操作的订单模型
  OrderInfoModel? _currentInfoModel;

  @override
  void initState() {
    _refreshController = RefreshController();

    // 获取订单列表数据
    _refreshOrderListData();

    super.initState();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  /// 取消订单
  void _orderCancel(int index) async {
    try {
      OrderInfoModel updateInfoModel = await OrderPaymentAPI.orderCancel(_currentInfoModel!.id!, '');

      // 判断当前是在<全部>还是在<待付款>
      if (widget.orderState! == 0) {
        // 当前在全部页面：重新设置订单列表状态
        _items[index] = updateInfoModel;
      } else {
        // 当前在待支付页面：直接移除该订单
        _items.removeAt(index);
      }

      // 更新状态
      setState(() {});
    } on DioError catch (e) {
      EasyLoading.showToast(e.response!.data['message']);
    }
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
      // 取消支付：因为没有修改订单状态，不作任何处理
    } else {
      // 支付失败：因为没有修改订单状态，不作任何处理
    }
  }

  /// 支付宝支付
  void _orderAlipay() async {
    try {
      String orderString = await OrderPaymentAPI.orderAlipay(_currentInfoModel!.id!);
      debugPrint('支付宝支付：$orderString');

      // 唤起支付宝钱包并进行支付
      _openAlipay(orderString);
    } on DioError catch (e) {
      EasyLoading.showToast(e.response!.data['message']);
    }
  }

  /// 上拉加载更多
  void _loadOrderListData() async {
    // 页码加1
    _currentPage++;
    // 如果在做上拉加载更多，重置下拉刷新的状态
    _refreshController.loadComplete();

    try {
      _orderListModel = await OrderPaymentAPI.orderList(page: _currentPage, orderState: widget.orderState);
      // 注意：需要将当前页订单列表添加到原有数据中
      _items.addAll(_orderListModel!.items!);

      // 加载成功：后面还有数据，或者后面没有数据（我们是有底线的）
      if (_orderListModel!.items!.length < 10) {
        // 后面没有数据了
        _refreshController.loadNoData();
      } else {
        _refreshController.loadComplete();
      }

      // 更新状态
      setState(() {});
    } catch (e) {
      // 加载失败
      _refreshController.loadFailed();
      debugPrint('$e');
    }
  }

  /// 获取订单列表数据
  void _refreshOrderListData() async {
    // 重置页码到第一页:因为下拉刷新时，默认加载第一页数据
    _currentPage = 1;
    // 如果在做下拉刷新，重置上拉加载更多的状态
    _refreshController.loadComplete();

    try {
      _orderListModel = await OrderPaymentAPI.orderList(orderState: widget.orderState);
      _items = _orderListModel!.items!;

      // 刷新成功
      _refreshController.refreshCompleted();

      // 更新状态
      setState(() {});
    } catch (e) {
      // 刷新失败
      _refreshController.refreshFailed();
      debugPrint('$e');
    }
  }

  /// 构建删除对话框
  void _buildCancelOrderDialog(int index) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true, // 点击背景是否可以关闭对话框
      barrierLabel: '',
      transitionDuration: Duration(milliseconds: 200),
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
            ),
            clipBehavior: Clip.antiAlias,
            width: MediaQuery.of(context).size.width - 100.0,
            height: 138.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '确认取消订单?',
                  style: TextStyle(color: Color(0xFF333333), fontSize: 16.0),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 28.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          child: Container(
                            height: 40.0,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2.0),
                              border: Border.all(color: Color(0xFF666666)),
                            ),
                            child: Text(
                              '取消',
                              style: TextStyle(fontSize: 13.0, color: Color(0xFF666666)),
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // 调用取消订单的接口方法
                            _orderCancel(index);
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          child: Container(
                            height: 40.0,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2.0),
                              gradient: LinearGradient(colors: [Color(0xff3CCEAF), Color(0xff27BA9B)]),
                            ),
                            child: Text(
                              '确认',
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
      },
    );
  }

  /*
  1：待付款：取消订单 + 继续支付
  2：待发货：再次购买
  3：待收货：再次购买 + 查看物流 + 确认收货
  4：待评价：再次购买 + 去评价
  5：已完成：再次购买 + 删除订单
  6：已取消/关闭：删除订单
  */
  /// 构建底部操作栏
  List<Widget> _buildBottomBar(int index, OrderInfoModel orderInfoModel) {
    List<Widget> bars = [];

    switch (orderInfoModel.orderState!) {
      case 1:
        bars = [
          OrderListBottomBar(
            title: '取消订单',
            onTap: () {
              // 记录当前操作的订单模型
              _currentInfoModel = orderInfoModel;
              _buildCancelOrderDialog(index);
            },
          ),
          Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: OrderListBottomBar(
              title: '继续支付',
              onTap: () {
                // 记录当前操作的订单模型
                _currentInfoModel = orderInfoModel;
                // 重新唤起支付宝再支付一次即可，如果出现取消订单和支付失败，什么都不用做，因为这两种情况没有修改订单转改
                _orderAlipay();
              },
            ),
          )
        ];
        break;
      case 2:
        bars = [
          OrderListBottomBar(
            title: '再次购买',
            onTap: () {},
          ),
        ];
        break;
      case 3:
        bars = [
          OrderListBottomBar(
            title: '再次购买',
            onTap: () {},
          ),
          Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: OrderListBottomBar(
              title: '查看物流',
              onTap: () {},
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: OrderListBottomBar(
              title: '确认收货',
              onTap: () {},
            ),
          )
        ];
        break;
      case 4:
        bars = [
          OrderListBottomBar(
            title: '再次购买',
            onTap: () {},
          ),
          Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: OrderListBottomBar(
              title: '去评价',
              onTap: () {},
            ),
          )
        ];
        break;
      case 5:
        bars = [
          OrderListBottomBar(
            title: '再次购买',
            onTap: () {},
          ),
          Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: OrderListBottomBar(
              title: '删除订单',
              onTap: () {},
            ),
          )
        ];
        break;
      case 6:
        bars = [
          OrderListBottomBar(
            title: '删除订单',
            onTap: () {},
          ),
        ];
        break;
      default:
        break;
    }

    return bars;
  }

  /// 构建状态字符串
  /// 订单状态：1为待付款、2为待发货、3为待收货、4为待评价、5为已完成、6为已取消
  Widget _buildOrderStateText(int orderState) {
    String text = '';
    switch (orderState) {
      case 1:
        text = '待付款';
        break;
      case 2:
        text = '待发货';
        break;
      case 3:
        text = '待收货';
        break;
      case 4:
        text = '待评价';
        break;
      case 5:
        text = '已完成';
        break;
      case 6:
        text = '交易关闭';
        break;
      default:
        break;
    }

    Color color;
    if (orderState == 5 || orderState == 6) {
      color = Color(0xFF999999);
    } else {
      color = Color(0xFFFF9240);
    }

    return Text(
      text,
      style: TextStyle(color: color, fontSize: 14.0),
    );
  }

  /// 构建订单商品
  Widget _buildOrderSkus(List<OrderSkuModel> skus) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: skus.length,
      itemBuilder: (BuildContext context, int index) {
        OrderSkuModel skuModel = skus[index];
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          color: Colors.white,
          child: Row(
            children: [
              // 图片
              CustomImage(
                url: skuModel.image!,
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
                              skuModel.name!,
                              style: TextStyle(color: Color(0xFF262626), fontSize: 13.0),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 15.0),
                            child: Text(
                              'x ${skuModel.quantity}',
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
                          decoration: BoxDecoration(color: Color(0xFFF7F7F8), borderRadius: BorderRadius.circular(2.0)),
                          child: Text(
                            skuModel.attrsText!,
                            style: TextStyle(color: Color(0xFF888888), fontSize: 11.0, height: 1.0),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      // 价格
                      Padding(
                        padding: EdgeInsets.only(top: 6.0),
                        child: PriceWidget(price: skuModel.curPrice),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建订单列表元素
  Widget _buildOrderItem(int index) {
    OrderInfoModel infoModel = _items[index];

    return Container(
      margin: EdgeInsets.only(top: 10.0),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5.0)),
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            // 订单时间 + 状态
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 订单时间
                Text(
                  infoModel.createTime!,
                  style: TextStyle(color: Color(0xFF666666), fontSize: 13.0),
                ),
                // 订单状态
                _buildOrderStateText(infoModel.orderState!),
              ],
            ),
            // 订单商品信息
            Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: _buildOrderSkus(infoModel.skus!),
            ),
            // 订单实付款
            Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '合计：',
                    style: TextStyle(color: Color(0xFF262626), fontSize: 12.0),
                  ),
                  PriceWidget(
                      price: infoModel.payMoney, symbolFontSize: 12.0, integerFontSize: 16.0, decimalFontSize: 12.0),
                ],
              ),
            ),
            // 订单状态对应的选项：不同的订单状态对应不同的选项
            Padding(
              padding: EdgeInsets.only(top: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: _buildBottomBar(index, infoModel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建空订单列表
  Widget _buildEmptyOrderList() {
    return GestureDetector(
      onTap: () {
        _refreshOrderListData();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/empty_content.png'),
          Text(
            "暂无订单信息哦!",
            style: TextStyle(fontSize: 16.0, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  /// 展示订单列表内容
  Widget _buildContent() {
    return _items.length != 0
        ? Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: CustomRefresher(
              controller: _refreshController,
              // 下拉刷新列表
              onRefresh: _refreshOrderListData,
              // 上拉加载更多
              onLoading: _loadOrderListData,
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildOrderItem(index);
                },
              ),
            ),
          )
        : _buildEmptyOrderList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return _orderListModel != null ? _buildContent() : LoadingWidget();
  }
}
