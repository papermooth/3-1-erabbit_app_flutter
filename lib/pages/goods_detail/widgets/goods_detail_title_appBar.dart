import 'package:flutter/material.dart';

/// 顶部标题导航栏的key
GlobalKey<_GoodsDetailTitleAppBarState> goodsDetailTitleAppBarKey = GlobalKey(debugLabel: 'goodsDetailTitleAppBarKey');

class GoodsDetailTitleAppBar extends StatefulWidget {
  GoodsDetailTitleAppBar({
    Key? key,
    this.titleOnTap,
  }) : super(key: key);

  /// 监听顶部导航栏标题的点击事件
  final void Function(int index)? titleOnTap;

  @override
  _GoodsDetailTitleAppBarState createState() => _GoodsDetailTitleAppBarState();
}

class _GoodsDetailTitleAppBarState extends State<GoodsDetailTitleAppBar> with TickerProviderStateMixin {
  /// 记录透明度:默认标题导航栏是不可以被看见的
  double _opacity = 0.0;

  /// TabBar的控制器
  late TabController _tabController;

  /// 顶部导航栏高度
  double _appBarHeight = 0.0;

  /// 标记是否是点击了顶部导航栏
  bool _isClick = false;

  /// 是否禁止事件输入:标题导航栏默认是透明的，所以默认禁止事件输入
  bool _absorbing = true;

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 取消点击的标记
  void cancelTag() {
    _isClick = false;
  }

  /// 获取顶部导航栏透明度
  void getGoodsDetailTitleAppBarOpacity(
    double opacity,
    double goodsY,
    double commentY,
    double detailsY,
    double recommendsY,
  ) {
    // 判断当前内容组件的纵坐标是否是顶部导航栏高度：判断当前内容组件是否滚动到顶部导航栏下面
    // 如果当前是点击顶部导航栏造成商品详情页的滚动，那么以下滚动定位的逻辑就不执行
    if (!_isClick) {
      if (goodsY <= _appBarHeight && commentY > _appBarHeight) {
        _tabController.animateTo(0);
      } else if (commentY <= _appBarHeight && detailsY > _appBarHeight) {
        _tabController.animateTo(1);
      } else if (detailsY <= _appBarHeight && recommendsY > _appBarHeight) {
        _tabController.animateTo(2);
      } else if (recommendsY <= _appBarHeight) {
        _tabController.animateTo(3);
      }
    }

    setState(() {
      // 标题导航栏透明度渐变的规律：0.0 ~ 1.0
      _opacity = opacity;

      // 如果透明度为1.0时指定absorbing属性为false（允许事件输入），反之，为true（禁止事件输入）
      _absorbing = _opacity < 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 顶部导航栏高度 = 顶部工具栏高度 + 不规则屏幕上边距
    _appBarHeight = kToolbarHeight + MediaQuery.of(context).padding.top;

    return Opacity(
      opacity: _opacity,
      child: Container(
        height: _appBarHeight,
        color: Colors.white,
        child: Stack(
          children: [
            SafeArea(
              child: Container(
                height: kToolbarHeight,
                padding: EdgeInsets.only(left: 60.0, right: 60.0),
                child: AbsorbPointer(
                  // true：禁止事件输入；false：允许事件输入
                  absorbing: _absorbing,
                  child: TabBar(
                    onTap: (int index) {
                      // 标记当前是点击顶部导航栏，定位详情内容
                      _isClick = true;

                      if (widget.titleOnTap != null) {
                        widget.titleOnTap!(index);
                      }
                    },
                    controller: _tabController,
                    labelColor: Color(0xFF27BA9B),
                    unselectedLabelColor: Color(0xFF282828),
                    labelPadding: EdgeInsets.zero,
                    indicatorColor: Color(0xFF27BA9B),
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorPadding: EdgeInsets.only(left: 6.0, right: 6.0, bottom: 12.0),
                    tabs: [Text('商品'), Text('评价'), Text('详情'), Text('推荐')],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 18.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    'assets/appbar_fanhui.png',
                    width: 28.0,
                    height: 28.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
