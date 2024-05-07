import 'package:erabbit_app_flutter/pages/order_payment/widgets/order_list_content_widget.dart';
import 'package:flutter/material.dart';

class OrderListPage extends StatefulWidget {
  OrderListPage({this.orderState= 0});

  /// 订单状态序号
  final int? orderState;

  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> with TickerProviderStateMixin {
  /// 订单标题
  List<String> _orderStatuTitles = ['全部', '待付款', '待发货', '待收货', '待评价'];

  /// TabBar控制器
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(
      length: _orderStatuTitles.length,
      vsync: this,
      initialIndex: widget.orderState!, // 指定默认选中的tab
    );
    super.initState();
  }

  /// 构建订单列表内容
  List<Widget> _buildOrderListContent() {
    List<Widget> items = [];

    for (var i = 0; i < _orderStatuTitles.length; i++) {
      items.add(OrderListContentWidget(orderState: i));
    }

    return items;
  }

  /// 构建订单标题
  List<Widget> _buildOrderStatusTitles() {
    List<Widget> tabs = [];

    _orderStatuTitles.forEach((element) {
      tabs.add(Container(
        height: 44.0,
        alignment: Alignment.center,
        child: Text(element),
      ));
    });

    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F8),
      appBar: AppBar(
        title: Text('我的订单', style: TextStyle(fontSize: 16.0, color: Color(0xFF282828))),
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
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              onTap: (int index) {},
              controller: _tabController,
              labelColor: Color(0xFF27BA9B),
              unselectedLabelColor: Color(0xFF282828),
              labelPadding: EdgeInsets.zero,
              indicatorColor: Color(0xFF27BA9B),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: EdgeInsets.only(left: 26.0, right: 26.0, bottom: 8.0),
              tabs: _buildOrderStatusTitles(),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(),
              children: _buildOrderListContent(),
            ),
          ),
        ],
      ),
    );
  }
}
