import 'package:erabbit_app_flutter/main.dart';
import 'package:erabbit_app_flutter/pages/cart/cart_page.dart';
import 'package:erabbit_app_flutter/pages/category/category_page.dart';
import 'package:erabbit_app_flutter/pages/home/home_page.dart';
import 'package:erabbit_app_flutter/pages/mine/mine_page.dart';
import 'package:erabbit_app_flutter/pages/root_page/frames_animation.dart';
import 'package:erabbit_app_flutter/utils/common_utils.dart';
import 'package:flutter/material.dart';

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  /// 页面列表
  List<Widget> pages = [HomePage(), CategoryPage(), CartPage(), MinePage()];

  /// 当前item的索引:默认首页item是选中
  int _currentIndex = 0;

  /// 存放帧动画组件的key
  List<GlobalKey<FramesAnimationState>> framesKeys = [
    GlobalKey<FramesAnimationState>(debugLabel: 'home_key'),
    GlobalKey<FramesAnimationState>(debugLabel: 'category_key'),
    GlobalKey<FramesAnimationState>(debugLabel: 'cart_key'),
    GlobalKey<FramesAnimationState>(debugLabel: 'mine_key'),
  ];

  /// 记录当前选中item的索引:默认首页就是上一次被选中的item
  int _lastIndex = 0;

  /// PageView的控制器
  PageController? _controller;

  /// 加载首页帧动画图片
  List<Image> _loadHomeFrames() {
    List<Image> images = [];

    for (var i = 0; i < 24; i++) {
      images.add(Image.asset(
        'assets/home_frames/home_frame_$i.png',
        width: 20.0,
        height: 20.0,
        gaplessPlayback: true,
      ));
    }

    return images;
  }

  /// 加载分类帧动画图片
  List<Image> _loadCategoryFrames() {
    List<Image> images = [];

    for (var i = 0; i < 24; i++) {
      images.add(Image.asset(
        'assets/category_frames/category_frame_$i.png',
        width: 20.0,
        height: 20.0,
        gaplessPlayback: true,
      ));
    }

    return images;
  }

  /// 加载购物车帧动画图片
  List<Image> _loadCartFrames() {
    List<Image> images = [];

    for (var i = 0; i < 24; i++) {
      images.add(Image.asset(
        'assets/cart_frames/cart_frame_$i.png',
        width: 20.0,
        height: 20.0,
        gaplessPlayback: true,
      ));
    }

    return images;
  }

  /// 加载我的帧动画图片
  List<Image> _loadMineFrames() {
    List<Image> images = [];

    for (var i = 0; i < 24; i++) {
      images.add(Image.asset(
        'assets/mine_frames/mine_frame_$i.png',
        width: 20.0,
        height: 20.0,
        gaplessPlayback: true,
      ));
    }

    return images;
  }

  @override
  void initState() {
    // 订阅回到首页的事件
    // event 就是 GoToHomeEvent实例对象
    eventBus.on<GoToHomeEvent>().listen((event) {
      // 让首页选中
      // 判断当前被选中的item索引跟上一次被选中item的索引是否一致
      // 如果一致，直接终止逻辑(return)，如果不一样继续执行切换帧动画逻辑
      if (_lastIndex == 0) return;

      // 切换底部导航帧动画
      // 1. 启动本次被选中Item的帧动画
      framesKeys[0].currentState?.startAnimation();
      // 2. 重置上次被选中Item的帧动画
      framesKeys[_lastIndex].currentState?.resetAnimation();
      // 3. 记录本次被选中的Item索引
      _lastIndex = 0;

      // 控制页面切换
      _controller!.jumpToPage(0);

      // print(index);
      setState(() {
        _currentIndex = 0;
      });
    });

    // 创建PageView的控制器
    _controller = PageController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 页面内容
      // body: pages[_currentIndex],
      body: PageView(
        controller: _controller,
        physics: NeverScrollableScrollPhysics(),
        children: pages,
      ),
      // 底部导航
      bottomNavigationBar: Theme(
        // 指定新的主题样式
        data: ThemeData(
          splashColor: Colors.transparent, // 点击时，透明色
          highlightColor: Colors.transparent, // 长按时，透明色
        ),
        child: BottomNavigationBar(
          // 设置选中和未选中状态的文字颜色
          selectedItemColor: Color(0xFF3CCEAF),
          unselectedItemColor: Color(0xFF383838),
          // 统一选中和未选中状态的字号：10号字
          selectedFontSize: 10.0,
          unselectedFontSize: 10.0,
          // 指定当前选中的item
          currentIndex: _currentIndex,
          // 监听底部导航点击事件
          onTap: (int index) {
            // 判断当前被选中的item索引跟上一次被选中item的索引是否一致
            // 如果一致，直接终止逻辑(return)，如果不一样继续执行切换帧动画逻辑
            if (_lastIndex == index) return;

            // 切换底部导航帧动画
            // 1. 启动本次被选中Item的帧动画
            framesKeys[index].currentState?.startAnimation();
            // 2. 重置上次被选中Item的帧动画
            framesKeys[_lastIndex].currentState?.resetAnimation();
            // 3. 记录本次被选中的Item索引
            _lastIndex = index;

            // 控制页面切换
            _controller!.jumpToPage(index);

            // print(index);
            setState(() {
              _currentIndex = index;
            });
          },
          // 解决了items元素个数超过三个时的样式问题
          type: BottomNavigationBarType.fixed,
          items: [
            // 首页
            BottomNavigationBarItem(
              // icon: Icon(Icons.home),
              // icon: Image.asset('assets/home_nor.png', gaplessPlayback: true),
              // activeIcon: Image.asset('assets/home_sel.png', gaplessPlayback: true),
              icon: FramesAnimation(
                key: framesKeys[0],
                initIndex: 0,
                images: _loadHomeFrames(),
              ),
              label: '首页',
            ),
            // 分类
            BottomNavigationBarItem(
              // icon: Icon(Icons.category),
              // icon: Image.asset('assets/category_nor.png', gaplessPlayback: true),
              // activeIcon: Image.asset('assets/category_sel.png', gaplessPlayback: true),
              icon: FramesAnimation(
                key: framesKeys[1],
                initIndex: 1,
                images: _loadCategoryFrames(),
              ),
              label: '分类',
            ),
            // 购物车
            BottomNavigationBarItem(
              // icon: Icon(Icons.shopping_cart),
              // icon: Image.asset('assets/cart_nor.png', gaplessPlayback: true),
              // activeIcon: Image.asset('assets/cart_sel.png', gaplessPlayback: true),
              icon: FramesAnimation(
                key: framesKeys[2],
                initIndex: 2,
                images: _loadCartFrames(),
              ),
              label: '购物车',
            ),
            // 我的
            BottomNavigationBarItem(
              // icon: Icon(Icons.person),
              // icon: Image.asset('assets/mine_nor.png', gaplessPlayback: true),
              // activeIcon: Image.asset('assets/mine_sel.png', gaplessPlayback: true),
              icon: FramesAnimation(
                key: framesKeys[3],
                initIndex: 3,
                images: _loadMineFrames(),
              ),
              label: '我的',
            ),
          ],
        ),
      ),
    );
  }
}
