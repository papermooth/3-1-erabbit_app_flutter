import 'package:erabbit_app_flutter/pages/cart/cart_page.dart';
import 'package:erabbit_app_flutter/pages/goods_detail/widgets/goods_detail_options.dart';
import 'package:erabbit_app_flutter/pages/goods_detail/widgets/goods_specs_widget.dart';
import 'package:erabbit_app_flutter/service/cart_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

/// 定义ValueNotifier指定要监听购物车商品总数量
/// ValueNotifier(要监听的数据的初始值);
 ValueNotifier<int>? totalCountNotifier;

class GoodsDetailBottomBar extends StatefulWidget {
  @override
  _GoodsDetailBottomBarState createState() => _GoodsDetailBottomBarState();
}

class _GoodsDetailBottomBarState extends State<GoodsDetailBottomBar> {
  /// 底部操作栏的高度
  double _bottomBarHeight = 0.0;

  /// 是否收藏
  bool _isCollection = false;

  @override
  void initState() {
    // 定义ValueNotifier指定要监听购物车商品总数量
    totalCountNotifier = ValueNotifier(0);

    // 获取购物车商品总数量
    _loadCartTotalCount();

    super.initState();
  }

  /// 获取购物车商品总数量
  void _loadCartTotalCount() async {
    try {
      int totalCount = await CartAPI.getCartTotalCount();
      debugPrint('购物车商品总数量：$totalCount');
      // 更新状态(局部)
      // 一旦修改了value，ValueListenableBuilder就会重构内部组件
      totalCountNotifier?.value = totalCount;

      // 更新状态(全局)
      // setState(() {
      //   _totalCount = totalCount;
      // });
    } catch (e) {
      debugPrint('购物车商品总数量：$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 底部操作栏的高度：自身高度 + 不规则屏幕底部间距
    _bottomBarHeight = 60.0 + MediaQuery.of(context).padding.bottom;
    return Container(
      height: _bottomBarHeight,
      color: Colors.white,
      child: Column(
        children: [
          Container(height: 1.0, color: Color(0xFFEDEDED)),
          Container(
            height: 59.0,
            padding: EdgeInsets.only(left: 20.0, right: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isCollection = !_isCollection;
                        });
                        if (_isCollection) {
                          EasyLoading.showToast('已收藏');
                        } else {
                          EasyLoading.showToast('已取消');
                        }
                      },
                      child: Container(
                        width: 30.0,
                        height: 30.0,
                        child: _isCollection
                            ? Image.asset('assets/star_collection.png', gaplessPlayback: true)
                            : Image.asset('assets/star_uncollection.png', gaplessPlayback: true),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) {
                            return CartPage(isShowBack: true);
                          }));
                        },
                        child: ValueListenableBuilder(
                          valueListenable: totalCountNotifier!,
                          // value: 要监听的数据（更新之后的值）
                          builder: (BuildContext context, int value, Widget? child) {
                            return Container(
                              width: 35.0,
                              height: 30.0,
                              child: Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  Image.asset('assets/shopping_cart.png'),
                                  value > 0
                                      ? Positioned(
                                          left: 10.0,
                                          top: 2.0,
                                          child: Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 2.0),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius: BorderRadius.circular(4.0),
                                            ),
                                            // 最小宽度是16.0
                                            constraints: BoxConstraints(minWidth: 16.0),
                                            child: Text(
                                              // _totalCount.toString(),
                                              // '100', // 如果数量 >= 100，展示 99+
                                              value >= 100 ? '99+' : value.toString(),
                                              style: TextStyle(fontSize: 11.0, color: Colors.white, height: 1.0),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // 使用详情选项组件的key,去调用商品规格弹窗的公共方法
                            goodsDetailOptionsKey.currentState
                                ?.showGoodsSpecsCupertinoModalPopup(SpecsActionType.addCart);
                          },
                          child: Container(
                            width: 100.0,
                            height: 40.0,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2.0),
                              gradient: LinearGradient(colors: [Color(0xffFFA868), Color(0xffFF9240)]),
                            ),
                            child: Text(
                              '加入购物车',
                              style: TextStyle(fontSize: 13.0, color: Colors.white),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // 使用详情选项组件的key,去调用商品规格弹窗的公共方法
                            goodsDetailOptionsKey.currentState
                                ?.showGoodsSpecsCupertinoModalPopup(SpecsActionType.buyNow);
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
                              '立即购买',
                              style: TextStyle(fontSize: 13.0, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
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
}
