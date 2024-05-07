import 'package:dio/dio.dart';
import 'package:erabbit_app_flutter/main.dart';
import 'package:erabbit_app_flutter/models/cart_model.dart';
import 'package:erabbit_app_flutter/models/home_model.dart';
import 'package:erabbit_app_flutter/pages/account/account_login_page.dart';
import 'package:erabbit_app_flutter/pages/goods_detail/widgets/goods_detail_bottom_bar.dart';
import 'package:erabbit_app_flutter/pages/order_payment/order_settlement_page.dart';
import 'package:erabbit_app_flutter/service/cart_api.dart';
import 'package:erabbit_app_flutter/utils/common_utils.dart';
import 'package:erabbit_app_flutter/widgets/custom_image.dart';
import 'package:erabbit_app_flutter/widgets/custom_refresher.dart';
import 'package:erabbit_app_flutter/widgets/loading_widget.dart';
import 'package:erabbit_app_flutter/widgets/price_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CartPage extends StatefulWidget {
  CartPage({this.isShowBack= false});

  /// 是否展示返回按钮:默认不显示返回按钮
  final bool isShowBack;

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  /// 是否展示loading动效：购物车页面在加载时就要先展示loading动效
  bool _isShowLoading = true;

  /// 有效的购物车列表数据
  List<CartItemModel> _valids = [];

  /// 刷新控制器
  late RefreshController _refreshController;

  /// 侧滑控制器
  SlidableController? _slidableController;

  /// 标记Token异常：用来确定是否展示未登录界面
  bool _isTokenError = false;

  /// 猜你喜欢数据
  List<CategoryGoodsModel> _categoryGoods = [];

  @override
  void initState() {
    // 刷新控制器
    _refreshController = RefreshController();
    // 侧滑控制器
    _slidableController = SlidableController();

    // 订阅获取购物车数据Token异常事件
    eventBus.on<GetCartTokenError>().listen((event) {
      _isTokenError = true; // 标记Token异常
      _isShowLoading = false; // 关闭loading动效
      _refreshController.refreshFailed(); // 下拉刷新失败

      setState(() {});
    });

    // 订阅登录成功的事件
    eventBus.on<LoginSuccessEvent>().listen((event) {
      // 重新的刷新购物车页面
      _loadCartData();
    });

    // 获取购物车数据
    _loadCartData();

    // 获取猜你喜欢
    _loadUserLikeData();

    super.initState();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  /// 计算购物车商品总数量
  int _getTotalCount() {
    int totalCount = 0;

    _valids.forEach((CartItemModel itemModel) {
      totalCount += itemModel.count;
    });

    return totalCount;
  }

  /// 计算价格合计：计算购物车商品列表中被选中的商品价格
  double _getTotalPrice() {
    double ret = 0.00;

    _valids.forEach((CartItemModel itemModel) {
      if (itemModel.selected) {
        // double.parse : '19.90' ==> 19.90
        // 19.90 * 3 ==> 为了保证金额的精度，会把元转成分 ==> 1990 * 3
        ret += (double.parse(itemModel.price!) * 100) * itemModel.count;
      }
    });

    return ret / 100;
  }

  /// 获取全选状态：是否全选，true，全选。false，非全选
  bool _getSelectedAllState() {
    bool ret = true;

    if (_valids.length != 0) {
      // 遍历购物车有效的商品列表
      _valids.forEach((CartItemModel itemModel) {
        // 只要有任意一个商品是未选中的，则展示非全选，反之，展示全选
        if (!itemModel.selected) {
          ret = false;
        }
      });
    } else {
      ret = false;
    }

    return ret;
  }

  /// 获取猜你喜欢
  void _loadUserLikeData() async {
    try {
      _categoryGoods = await CartAPI.getUserLike(10);
      setState(() {});
    } on DioError catch (e) {
      debugPrint('$e');
    }
  }

  /// 全选购物车
  void _selecteAll(bool selected) async {
    try {
      dynamic ret = await CartAPI.selecteAll(selected);
      debugPrint('全选购物车：$ret');

      // 更新有效的购物车列表
      setState(() {
        _valids.forEach((CartItemModel itemModel) {
          itemModel.selected = selected;
        });
      });
    } on DioError catch (e) {
      EasyLoading.showToast(e.response!.data['message']);
    }
  }

  /// 删除购物车
  void _deleteCart(CartItemModel itemModel) async {
    try {
      dynamic ret = await CartAPI.deleteCart(itemModel.skuId!);
      debugPrint('删除购物车：$ret');

      // 更新购物车列表：从有效的购物车列表中移除已删除的商品模型
      setState(() {
        _valids.remove(itemModel);
      });

      // 同步购物车商品总数量
      // 一旦修改了value，ValueListenableBuilder就会重构内部组件
      totalCountNotifier?.value = _getTotalCount();
    } on DioError catch (e) {
      EasyLoading.showToast(e.response!.data['message']);
    }
  }

  /// 修改购物车
  void _updateCart(int index, CartItemModel itemModel) async {
    try {
      CartItemModel updateModel = await CartAPI.updateCart(itemModel.skuId!, itemModel.count, itemModel.selected);
      debugPrint('修改购物车：$updateModel');

      // 同步购物车商品总数量
      // 一旦修改了value，ValueListenableBuilder就会重构内部组件
      totalCountNotifier?.value = _getTotalCount();

      // 更新有效的购物车商品列表：使用更新之后的商品模型替换掉更新之前的商品模型
      setState(() {
        _valids[index] = updateModel;
      });
    } on DioError catch (e) {
      EasyLoading.showToast(e.response!.data['message']);
    }
  }

  /// 获取购物车数据
  void _loadCartData() async {
    try {
      CartModel cartModel = await CartAPI.getCart();
      debugPrint('购物车：$cartModel');

      // 获取到购物车数据后，移除loading动效
      _isShowLoading = false;
      // 标记Token无异常
      _isTokenError = false;
      // 读取有效的购物车列表数据
      _valids = cartModel.valids!;
      // 刷新完成
      _refreshController.refreshCompleted();

      // 更新状态
      setState(() {});
    } on DioError catch (e) {
      // 刷新失败
      _refreshController.refreshFailed();

      EasyLoading.showToast(e.response!.data['message']);
    }
  }

  /// 构建购物车内容
  Widget _buildCartContent() {
    Widget content;

    // 如果Token异常:展示未登录界面
    if (_isTokenError) {
      content = _buildToLogin();
    } else if (_valids.length != 0) {
      // 有效商品列表中有商品:展示商品列表
      content = ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _valids.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildCartItem(index);
        },
      );
    } else {
      // 有效商品列表为空:展示空购物车
      content = _buildEmptyCart();
    }

    return content;
  }

  /// 构建未登录界面
  Widget _buildToLogin() {
    return Padding(
      padding: EdgeInsets.only(left: 120.0, top: 30.0, right: 120.0, bottom: 20.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (BuildContext context) {
              return AccountLoginPage();
            }),
          );
        },
        child: Container(
          width: 120.0,
          height: 40.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2.0),
            gradient: LinearGradient(colors: [Color(0xFF00D2AE), Color(0xFF00BD9A)]),
          ),
          child: Text(
            '去登陆',
            style: TextStyle(color: Colors.white, fontSize: 14.0),
          ),
        ),
      ),
    );
  }

  /// 构建空购物车
  Widget _buildEmptyCart() {
    return Padding(
      padding: EdgeInsets.only(top: 30.0, bottom: 20.0),
      child: GestureDetector(
        onTap: () {
          Navigator.popUntil(context, ModalRoute.withName('/'));
        },
        child: Column(
          children: [
            Image.asset('assets/gouwuchekong.png'),
            Text(
              '购物车是空的',
              style: TextStyle(color: Color(0xFF9EA1A3), fontSize: 14.0),
            ),
            Padding(
              padding: EdgeInsets.only(left: 120.0, top: 20.0, right: 120.0),
              child: GestureDetector(
                onTap: () {
                  // 回到首页
                  if (widget.isShowBack) {
                    // 购物车页面不是一级页面时:直接移除路由栈中除首页以外的所有路由
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                  } else {
                    // 购物车页面是一级页面时:使用EventBus传递事件
                    // event 就是 GoToHomeEvent实例对象
                    eventBus.fire(GoToHomeEvent());
                  }
                },
                child: Container(
                  width: 120.0,
                  height: 40.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.0),
                    gradient: LinearGradient(colors: [Color(0xFF00D2AE), Color(0xFF00BD9A)]),
                  ),
                  child: Text(
                    '去逛逛',
                    style: TextStyle(color: Colors.white, fontSize: 14.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建删除对话框
  Widget _buildDeleteDialog(CartItemModel itemModel, GlobalKey<SlidableState> slidKey) {
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
              '是否确认删除此商品？',
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
                        // 手动关闭侧滑操作面板（有问题）
                        // Slidable.of(slidKey.currentContext!)?.close();
                        // 手动关闭侧滑操作面板（无问题）
                        slidKey.currentState?.close();
                        // 手动关闭删除对话框
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: GestureDetector(
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
                      onTap: () {
                        // 删除购物车
                        _deleteCart(itemModel);
                        // 手动关闭侧滑操作面板（无问题）
                        slidKey.currentState?.close();
                        // 手动关闭删除对话框
                        Navigator.of(context, rootNavigator: true).pop();
                      },
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

  /// 构建购物车item
  Widget _buildCartItem(int index) {
    CartItemModel itemModel = _valids[index];
    // 创建Slidable对应的GlobalKey
    GlobalKey<SlidableState> slidkey = GlobalKey(debugLabel: itemModel.skuId);

    return Container(
      margin: EdgeInsets.only(top: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Slidable(
        key: slidkey,
        actionPane: SlidableDrawerActionPane(), // 操作面板样式
        controller: _slidableController, // 操作面板控制器
        actionExtentRatio: 0.15, // 操作面板比例
        // 右侧操作面板元素：移入收藏 删除
        secondaryActions: [
          SlideAction(
            child: Text(
              '移入\n收藏',
              style: TextStyle(color: Colors.white, fontSize: 14.0),
            ),
            color: Color(0xFFFF9240),
            closeOnTap: false, // true:点击按钮后自动关闭 false:点击按钮后手动关闭
            onTap: () {
              // 移入收藏
            },
          ),
          SlideAction(
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0)),
              clipBehavior: Clip.antiAlias,
              child: Text(
                '删除',
                style: TextStyle(color: Colors.white, fontSize: 14.0),
              ),
            ),
            color: Color(0xFFCF4444),
            closeOnTap: false, // true:点击按钮后自动关闭 false:点击按钮后手动关闭
            onTap: () {
              // 展示删除购物车的对话框：自定义对话框样式
              showGeneralDialog(
                context: context,
                barrierDismissible: true, // 是否点击背景关闭对话框
                barrierLabel: '', // 对话框语义化，必传的，可以是空字符串
                transitionDuration: Duration(milliseconds: 200), // 时间
                pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
                  // 对话框内容
                  return _buildDeleteDialog(itemModel, slidkey);
                },
              );
            },
          ),
        ],
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: [
              // 选择按钮
              GestureDetector(
                onTap: () {
                  // 修改选中状态
                  itemModel.selected = !itemModel.selected;
                  _updateCart(index, itemModel);
                },
                child: itemModel.selected
                    ? Image.asset('assets/check.png', gaplessPlayback: true)
                    : Image.asset('assets/uncheck.png', gaplessPlayback: true),
              ),
              // 商品信息：图片
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: GestureDetector(
                  onTap: () {},
                  child: CustomImage(
                    url: itemModel.picture!,
                    width: 86.0,
                    height: 86.0,
                  ),
                ),
              ),
              // 商品信息：商品名称 + 规格 + 价格和数量
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 商品名称
                      Text(
                        itemModel.name!,
                        style: TextStyle(color: Color(0xFF262626), fontSize: 13.0),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // 规格
                      Padding(
                        padding: EdgeInsets.only(top: 6.0),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
                          decoration: BoxDecoration(
                            color: Color(0xFFF7F7F8),
                            borderRadius: BorderRadius.circular(2.0),
                            border: Border.all(color: Color(0xFFE4E4E4), width: 0.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            // 采用文本所需的最小宽度
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 196.0),
                                child: Text(
                                  itemModel.attrsText!,
                                  style: TextStyle(color: Color(0xFF888888), fontSize: 11.0, height: 1.0),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 6.0),
                                child: Image.asset('assets/arrow_down.png'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 商品信息：价格和数量
                      Padding(
                        padding: EdgeInsets.only(top: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 价格
                            PriceWidget(price: itemModel.price),
                            // 数量
                            Row(
                              children: [
                                Container(
                                  width: 30.0,
                                  height: 20.0,
                                  child: GestureDetector(
                                    onTap: () {
                                      // 设置数量最小的临界值
                                      if (itemModel.count <= 1) {
                                        EasyLoading.showToast('商品数量不能再少啦!');
                                        return;
                                      }
                                      // 修改数量-
                                      itemModel.count -= 1;
                                      _updateCart(index, itemModel);
                                    },
                                    child: Image.asset('assets/price_jian_on.png'),
                                  ),
                                ),
                                Container(
                                  width: 40.0,
                                  height: 20.0,
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(vertical: 2.0),
                                  color: Color(0xFFF6F6F6),
                                  child: Text(
                                    itemModel.count.toString(),
                                    style: TextStyle(color: Color(0xFF333333), fontSize: 13.0),
                                  ),
                                ),
                                Container(
                                  width: 30.0,
                                  height: 20.0,
                                  child: GestureDetector(
                                    onTap: () {
                                      // 修改数量+
                                      itemModel.count += 1;
                                      _updateCart(index, itemModel);
                                    },
                                    child: Image.asset('assets/price_jia_on.png'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
            padding: EdgeInsets.only(left: 20.0, right: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // 全选购物车
                        _selecteAll(!_getSelectedAllState());
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 18.0,
                            height: 18.0,
                            child: _getSelectedAllState()
                                ? Image.asset('assets/check.png', gaplessPlayback: true)
                                : Image.asset('assets/uncheck.png', gaplessPlayback: true),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 6.0),
                            child: Text(
                              '全选',
                              style: TextStyle(color: Color(0xFF1E1E1E), fontSize: 13.0),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20.0),
                      child: Row(
                        children: [
                          Text(
                            '合计: ',
                            style: TextStyle(color: Color(0xFF1E1E1E), fontSize: 13.0),
                          ),
                          PriceWidget(
                            price: _getTotalPrice().toStringAsFixed(2), // 转字符串时保留2位小数 ==> 19.90
                            symbolFontSize: 12.0,
                            integerFontSize: 20.0,
                            decimalFontSize: 18.0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    // 判断用户是否有选择要结算的商品（至少选中一款商品）
                    bool hasSettlementGoods = false;
                    _valids.forEach((CartItemModel itemModel) {
                      if (itemModel.selected) {
                        hasSettlementGoods = true;
                        return;
                      }
                    });
                    if (!hasSettlementGoods) {
                      EasyLoading.showToast('请选择要结算的商品!');
                      return;
                    }

                    // 进入到订单结算页面
                    Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) {
                      return OrderSettlementPage();
                    }));
                  },
                  child: Container(
                    width: 100.0,
                    height: 40.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2.0),
                      gradient: LinearGradient(colors: [Color(0xff3CCEAF), Color(0xff27BA9B)]),
                    ),
                    child: Text(
                      '去结算',
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

  /// 构建猜你喜欢
  Widget _buildUserLike() {
    return StaggeredGridView.countBuilder(
      itemCount: _categoryGoods.length,
      crossAxisCount: 2,
      crossAxisSpacing: 10.0,
      mainAxisSpacing: 10.0,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        CategoryGoodsModel goodsModel = _categoryGoods[index];
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
                CustomImage(url: goodsModel.picture!),
                // 名称
                Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    goodsModel.name!,
                    style: TextStyle(color: Color(0xFF262626), fontSize: 13.0),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // 价格
                Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: PriceWidget(
                    price: goodsModel.price!,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('购物车', style: TextStyle(fontSize: 16.0, color: Color(0xFF282828))),
        backgroundColor: Colors.white,
        centerTitle: true,
        shadowColor: Colors.transparent,
        // 左侧返回箭头
        leading: widget.isShowBack
            ? IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Image.asset('assets/appbar_fanhui.png'),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              )
            : Container(),
      ),
      body: !_isShowLoading
          ? Column(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: CustomRefresher(
                      controller: _refreshController, // 刷新控制器
                      enablePullUp: false, // 禁用上拉加载更多
                      onRefresh: _loadCartData, // 加载购物车数据
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: _buildCartContent(),
                          ),
                          SliverToBoxAdapter(
                            child: Image.asset('assets/user_like.png'),
                          ),
                          // 猜你喜欢
                          SliverToBoxAdapter(
                            child: _buildUserLike(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // 底部导航栏
                _buildBottomBar(),
              ],
            )
          : LoadingWidget(),
    );
  }
}
