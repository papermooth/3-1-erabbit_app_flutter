import 'package:flutter/material.dart';

/// 顶部普通导航栏的key
GlobalKey<_GoodsDetailAppBarState> goodsDetailAppBarKey = GlobalKey(debugLabel: 'goodsDetailAppBarKey');

class GoodsDetailAppBar extends StatefulWidget {
  GoodsDetailAppBar({Key? key}) : super(key: key);

  @override
  _GoodsDetailAppBarState createState() => _GoodsDetailAppBarState();
}

class _GoodsDetailAppBarState extends State<GoodsDetailAppBar> {
  /// 记录透明度:默认普通导航栏是可以被看见的
  double _opacity = 1.0;

  /// 获取顶部导航栏透明度
  void getGoodsDetailAppBarOpacity(double opacity) {
    setState(() {
      // 普通导航栏透明度渐变的规律：1.0 ~ 0.0
      _opacity = 1.0 - opacity;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 顶部导航栏高度 = 顶部工具栏高度 + 不规则屏幕上边距
    double appBarHeight = kToolbarHeight + MediaQuery.of(context).padding.top;

    return Opacity(
      // opacity：取值范围 1.0 ~ 0.0；
      // 普通导航栏透明度渐变的规律：1.0 ~ 0.0
      opacity: _opacity,
      child: Container(
        height: appBarHeight,
        child: SafeArea(
          child: Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 18.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.asset('assets/fanhui_float.png'),
            ),
          ),
        ),
      ),
    );
  }
}
