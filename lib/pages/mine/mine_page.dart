import 'package:erabbit_app_flutter/main.dart';
import 'package:erabbit_app_flutter/models/user_center_model.dart';
import 'package:erabbit_app_flutter/pages/account/account_login_page.dart';
import 'package:erabbit_app_flutter/pages/mine/user_center_page.dart';
import 'package:erabbit_app_flutter/pages/order_payment/order_list_page.dart';
import 'package:erabbit_app_flutter/service/user_center_api.dart';
import 'package:erabbit_app_flutter/utils/common_utils.dart';
import 'package:erabbit_app_flutter/widgets/custom_image.dart';
import 'package:erabbit_app_flutter/widgets/price_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

/// 监听用户信息
ValueNotifier<UserModel?>? userInfoNotifier;

class MinePage extends StatefulWidget {
  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  /// 图片宽度
  double _imageWidth = 0.0;

  /// 订单图标
  List _orderStates = [
    {"state": "待付款", "image": "assets/daifukuan.png"},
    {"state": "待发货", "image": "assets/daifahuo.png"},
    {"state": "待收货", "image": "assets/daishouhuo.png"},
    {"state": "待评价", "image": "assets/daipingjia.png"},
    {"state": "售后", "image": "assets/shouhou.png"},
  ];

  /// TabBar控制器
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    userInfoNotifier = ValueNotifier(null);

    // 监听用户登录成功
    eventBus.on<LoginSuccessEvent>().listen((event) async {
      // 登录成功后，刷新用户中心页面（本地缓存的用户信息）
      Map userInfo = await getUserInfo();
      // 转模型,刷新用户个人信息
      userInfoNotifier?.value = UserModel.fromjson(userInfo);
    });

    // 获取用户个人信息
    _getUserInfo();

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    userInfoNotifier?.dispose();
    super.dispose();
  }

  /// 获取用户个人信息
  void _getUserInfo() async {
    try {
      UserModel? userModel = await UserCenterAPI.getUserInfo();
      debugPrint('用户信息：$userModel');

      // 刷新用户个人信息
      userInfoNotifier?.value = userModel;
    } catch (e) {
      debugPrint('用户信息：$e');
    }
  }

  /// 用户头像点击事件
  void _userIconOnTap() {
    // 判断用户数据是否为空
    if (userInfoNotifier?.value == null) {
      // 如果用户数据为空，未登录，进入登录页
      Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) {
        return AccountLoginPage();
      }));
    } else {
      // 如果用户数据不为空，已登录，进入个人中心页面(展示个人中心网页)
      Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) {
        return UserCenterPage(token: userInfoNotifier?.value?.token);
      }));
    }
  }

  /// 订单状态的点击事件：获取订单状态序号并传递给订单列表页
  void _orderStateOnTap(int orderState) {
    // 判断是否登录
    if (userInfoNotifier?.value == null) {
      EasyLoading.showToast('登录才能查看订单哦!');
      return;
    }
    // 判断是否是点击了售后
    if (orderState == 5) {
      EasyLoading.showToast('暂无售后!');
      return;
    }

    Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) {
      return OrderListPage(orderState: orderState);
    }));
  }

  /// 构建用户信息
  Widget _buildUserInfo() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 140.0 - MediaQuery.of(context).padding.top,
        padding: EdgeInsets.only(left: 20.0, top: 10.0, right: 20.0),
        child: ValueListenableBuilder(
          valueListenable: userInfoNotifier!,
          builder: (BuildContext context, UserModel? value, Widget? child) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头像
                GestureDetector(
                  onTap: _userIconOnTap,
                  child: ClipOval(
                    child: Container(
                      width: 50.0,
                      height: 50.0,
                      child: CustomImage(url: value?.avatar ?? ''),
                    ),
                  ),
                ),
                Container(
                  height: 50.0,
                  padding: EdgeInsets.only(left: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 昵称+等级
                      Row(
                        children: [
                          Container(
                            constraints: BoxConstraints(maxWidth: 120.0),
                            child: Text(
                              value?.nickname ?? '点击登录',
                              style: TextStyle(color: Colors.white, fontSize: 15.0),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 4.0),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2.0)),
                              child: Text(
                                '钻石',
                                style: TextStyle(color: Color(0xFF36C8A9), fontSize: 10.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // 设置
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.0)),
                        child: Row(
                          children: [
                            Text(
                              '账户管理',
                              style: TextStyle(color: Color(0xFF36C8A9), fontSize: 10.0, height: 1.0),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 5.0),
                              child: Image.asset('assets/right_triangle.png'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 构建我的订单导航栏
  Widget _buildOrderStateBars() {
    return Container(
      height: 122.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Container(
        padding: EdgeInsets.all(15.0),
        child: Column(
          children: [
            // 构建全部订单入口
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '我的订单',
                    style: TextStyle(color: Color(0xFF1E1E1E), fontSize: 13.0),
                  ),
                  GestureDetector(
                    onTap: () {
                      // 全部
                      _orderStateOnTap(0);
                    },
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white),
                      child: Row(
                        children: [
                          Text(
                            '查看全部订单',
                            style: TextStyle(color: Color(0xFF939393), fontSize: 12.0),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: Image.asset('assets/arrow_right.png'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 构建我的订单导航栏item
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _buildOrderStateBarItem(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建我的订单导航栏item
  List<Widget> _buildOrderStateBarItem() {
    List<Widget> items = [];

    for (var i = 0; i < _orderStates.length; i++) {
      items.add(
        GestureDetector(
          onTap: () {
            // 进入不同状态的订单列表
            _orderStateOnTap(i + 1);
          },
          child: Container(
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              children: [
                Image.asset(_orderStates[i]["image"]),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    _orderStates[i]["state"],
                    style: TextStyle(fontSize: 12.0, color: Color(0xFF333333)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    _imageWidth = (MediaQuery.of(context).size.width - 7 * 10.0) * 0.5;

    return Scaffold(
      backgroundColor: Color(0xFFF7F7F8),
      body: Column(
        children: [
          Container(
            height: 212.0 + 50.0,
            child: Stack(
              children: [
                // 用户信息
                Container(
                  height: 212.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage('assets/mine_nav_bg.png'), fit: BoxFit.cover),
                  ),
                  child: _buildUserInfo(),
                ),
                // 我的订单导航栏
                Positioned(
                  top: 140.0,
                  left: 10.0,
                  right: 10.0,
                  child: _buildOrderStateBars(),
                ),
              ],
            ),
          ),
          // 猜你喜欢+我的收藏+我的足迹
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Container(
              height: 54.0,
              color: Color(0xFFF7F7F8),
              child: TabBar(
                onTap: (int index) {},
                controller: _tabController,
                labelColor: Color(0xFF282828),
                unselectedLabelColor: Color(0xFF282828),
                labelPadding: EdgeInsets.zero,
                indicatorColor: Color(0xFF27BA9B),
                indicatorSize: TabBarIndicatorSize.label,
                indicatorPadding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 8.0),
                tabs: [
                  Text('猜你喜欢'),
                  Text('我的收藏'),
                  Text('我的足迹'),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 猜你喜欢
                  _buildUserLike(),
                  // 我的收藏
                  _buildGoodsCollection(),
                  // 我的足迹
                  _buildBrowsingHistory(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 猜你喜欢
  Widget _buildUserLike() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: StaggeredGridView.countBuilder(
        itemCount: 10,
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomImage(
                    url: 'https://yanxuan-item.nosdn.127.net/690e5cb552428321311e6ee03a4b12ed.png',
                    width: _imageWidth,
                    height: _imageWidth,
                  ),
                  // 名称
                  Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      '毛茸茸小熊出没，儿童羊羔绒背心73-90cm',
                      style: TextStyle(color: Color(0xFF262626), fontSize: 13.0),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // 价格
                  Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: PriceWidget(
                      price: '79.00',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        staggeredTileBuilder: (int index) {
          return StaggeredTile.fit(1);
        },
      ),
    );
  }

  /// 我的收藏
  Widget _buildGoodsCollection() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: StaggeredGridView.countBuilder(
        itemCount: 10,
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomImage(
                    url: 'https://yanxuan-item.nosdn.127.net/01759e41a2109938871ae99d4ec0f365.png',
                    width: _imageWidth,
                    height: _imageWidth,
                  ),
                  // 名称
                  Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      '毛茸茸小熊出没，儿童羊羔绒背心73-90cm',
                      style: TextStyle(color: Color(0xFF262626), fontSize: 13.0),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // 价格
                  Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: PriceWidget(
                      price: '79.00',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        staggeredTileBuilder: (int index) {
          return StaggeredTile.fit(1);
        },
      ),
    );
  }

  /// 我的足迹
  Widget _buildBrowsingHistory() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: StaggeredGridView.countBuilder(
        itemCount: 5,
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomImage(
                    url: 'https://yanxuan-item.nosdn.127.net/cd4b840751ef4f7505c85004f0bebcb5.png',
                    width: _imageWidth,
                    height: _imageWidth,
                  ),
                  // 名称
                  Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      '毛茸茸小熊出没，儿童羊羔绒背心73-90cm',
                      style: TextStyle(color: Color(0xFF262626), fontSize: 13.0),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // 价格
                  Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: PriceWidget(
                      price: '79.00',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        staggeredTileBuilder: (int index) {
          return StaggeredTile.fit(1);
        },
      ),
    );
  }
}
