import 'package:erabbit_app_flutter/models/home_model.dart';
import 'package:erabbit_app_flutter/pages/goods_detail/goods_detail_page.dart';
import 'package:erabbit_app_flutter/pages/home/widgets/category_grids_widget.dart';
import 'package:erabbit_app_flutter/pages/home/widgets/fresh_goods_widget.dart';
import 'package:erabbit_app_flutter/pages/home/widgets/home_app_bar.dart';
import 'package:erabbit_app_flutter/pages/home/widgets/hot_brands_widget.dart';
import 'package:erabbit_app_flutter/pages/home/widgets/hot_projects_widget.dart';
import 'package:erabbit_app_flutter/pages/home/widgets/hot_recommends_widget.dart';
import 'package:erabbit_app_flutter/pages/home/widgets/image_swiper_widget.dart';
import 'package:erabbit_app_flutter/service/home_api.dart';
import 'package:erabbit_app_flutter/widgets/custom_image.dart';
import 'package:erabbit_app_flutter/widgets/custom_refresher.dart';
import 'package:erabbit_app_flutter/widgets/price_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // 是否记录状态:true表示需要记录组件状态
  @protected
  bool get wantKeepAlive => true;

  /// 轮播图数据
  List<ImageBannersModel>? imageBanners;

  /// 分类快捷入口数据
  List<CategoryGridsModel>? categoryGrids;

  /// 热门推荐
  List<HotRecommendsModel>? hotRecommends;

  /// 新鲜好物
  List<FreshGoodsModel>? freshGoods;

  /// 热门品牌
  List<HotBrandsModel>? hotBrands;

  /// 热门专题
  List<HotProjectsModel>? hotProjects;

  /// 推荐分类导航
  List<CategoryBannersModel>? categoryBanners;

  /// TabController
  TabController? _controller;

  /// 分类商品图片宽度
  double _categoryGoodsImageW = 0.0;

  /// 刷新数据插件的控制器
  late RefreshController _refreshController;

  /// 控制回到顶部按钮是否显示
  bool _isShowTop = false;

  /// CustomScrollView的控制器
  late ScrollController? _scrollController;

  @override
  void initState() {
    // 创建TabController：为了保证在拿到数据之前，可以使用一个正常的TabController
    _controller = TabController(length: 0, vsync: this);
    // 创建刷新数据插件的控制器
    _refreshController = RefreshController();

    // 创建CustomScrollView的控制器
    _scrollController = ScrollController();

    // 获取首页网络数据
    _loadData();

    super.initState();
  }

  @override
  void dispose() {
    // 销毁控制器
    _controller?.dispose();
    _refreshController.dispose();
    _scrollController?.dispose();

    super.dispose();
  }

  /// 使用dio插件发送网络请求获取首页网络数据
  void _loadData() async {
    // 发送请求并得到响应
    try {
      // 使用首页接口方法发送请求获取首页模型数据
      HomeModel homeModel = await HomeAPI.homeFetch();
      // debugPrint('$homeModel');

      // 提取首页数据
      setState(() {
        imageBanners = homeModel.imageBanners;
        categoryGrids = homeModel.categoryGrids;
        // 为了后续的演示效果，再加五个分类
        categoryGrids!.addAll(categoryGrids!.sublist(0, 5));
        // 热门推荐数据
        hotRecommends = homeModel.hotRecommends;
        // 新鲜好物数据
        freshGoods = homeModel.freshGoods;
        // 热门品牌数据
        hotBrands = homeModel.hotBrands;
        // 热门专题数据
        hotProjects = homeModel.projects;
        // 推荐分类导航数据
        categoryBanners = homeModel.categoryBanners;
        // 创建TabController：拿到数据之后，创建带有元素个数的TabController
        _controller = TabController(length: categoryBanners!.length, vsync: this);
      });

      // 获取网络数据成功时:刷新结束
      _refreshController.refreshCompleted();
    } catch (e) {
      // 捕获异常
      // print(e);
      debugPrint('$e');
      // 刷新失败
      _refreshController.refreshFailed();
    }
  }

  /// 用于演示上拉加载更多(没有实际意义)
  // void _onLoading() async {
  //   // monitor network fetch
  //   await Future.delayed(Duration(milliseconds: 3000));
  //   // if failed,use loadFailed(),if no data return,use LoadNodata()
  //   _refreshController.loadComplete();
  // }

  @override
  Widget build(BuildContext context) {
    // 记录状态
    super.build(context);

    // 计算分类商品图片宽度：(屏幕宽度 - 7 * 10.0) * 0.5
    double screenW = MediaQuery.of(context).size.width;
    _categoryGoodsImageW = (screenW - 7 * 10.0) * 0.5;

    // 计算TabBarView总高度：一个分类商品盒子的高度 * 5
    double tabBarViewH = ((2 * 10.0) + _categoryGoodsImageW + 8.0 + (13.0 * 1.4 * 2) + 8.0 + (13.0 * 1.0) + 10.0) * 5;

    return Scaffold(
      backgroundColor: Color(0xFFF7F7F8),
      // appBar: AppBar(title: Text('首页')),
      // 设置自定义AppBar
      appBar: HomeAppBar(),
      // Stack可以保证回到顶部按钮能够堆叠到首页上
      body: NotificationListener(
        // onNotification:监听滚动视图的滚动状态的
        // scrollNotification：保存滚动视图的滚动状态的
        onNotification: (ScrollNotification scrollNotification) {
          // 监听首页滚动组件是否滚动结束
          // scrollNotification.depth == 0 : 表示当前监听的是首页的CustomScrollView
          // scrollNotification is ScrollEndNotification:表示当前首页的CustomScrollView滚动结束了
          if (scrollNotification.depth == 0 && scrollNotification is ScrollEndNotification) {
            // 获取滚动的距离
            // debugPrint('scroll end ${scrollNotification.metrics.pixels}');
            // 根据滚动距离显示或隐藏回到顶部按钮：如果滚动距离超过一屏，就显示回到顶部按钮
            if (scrollNotification.metrics.pixels >= MediaQuery.of(context).size.height) {
              // 显示
              _isShowTop = true;
            } else {
              // 隐藏
              _isShowTop = false;
            }
            // 刷新状态
            setState(() {});
          }

          return true; // 通知不再继续冒泡，不再继续下发通知
        },
        child: Stack(
          children: [
            CustomRefresher(
              controller: _refreshController,
              enablePullUp: false, // 首页没有上拉加载更多的功能
              onRefresh: _loadData,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // 轮播图
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0),
                      child: ImageSwiperWidget(
                        imageBanners: imageBanners,
                        height: 140.0,
                        type: CustomSwiperPaginatioType.rect,
                      ),
                    ),
                  ),
                  // 分类快捷入口
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: CategoryGridsWidget(categoryGrids: categoryGrids),
                    ),
                  ),
                  // 热门推荐
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 10.0),
                      child: HotRecommendsWidget(hotRecommends: hotRecommends),
                    ),
                  ),
                  // 新鲜好物
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0),
                      child: FreshGoodsWidget(freshGoods: freshGoods),
                    ),
                  ),
                  // 热门品牌
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0),
                      child: HotBrandsWidget(hotBrands: hotBrands),
                    ),
                  ),
                  // 热门专题
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0),
                      child: HotProjectsWidget(hotProjects: hotProjects),
                    ),
                  ),
                  // 推荐吸顶分类导航
                  // delegate : 构建吸顶视图
                  SliverPersistentHeader(
                    pinned: true, // 设置是否吸顶
                    delegate: CustomSliverPersistentHeaderDelegate(
                      tabBar: TabBar(
                        // 是否允许滚动
                        isScrollable: true,
                        // 选中和未选中状态颜色
                        labelColor: Color(0xFF27BA9B),
                        unselectedLabelColor: Color(0xFF333333),
                        // 去除底部指示器
                        indicator: BoxDecoration(),
                        // 取消文本左右间距
                        labelPadding: EdgeInsets.zero,
                        controller: _controller,
                        tabs: _buildTabBar(categoryBanners),
                      ),
                    ),
                  ),
                  // 推荐分类商品
                  SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.only(left: 10.0, right: 10.0),
                      height: tabBarViewH,
                      child: TabBarView(
                        controller: _controller,
                        children: _buildCategoryGoods(categoryBanners),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Positioned可以定位回到顶部按钮
            _isShowTop
                ? Positioned(
                    right: 30.0,
                    bottom: 100.0,
                    child: ClipOval(
                      child: GestureDetector(
                        onTap: () {
                          // 回到顶部逻辑
                          _scrollController!.animateTo(
                            0.0,
                            duration: Duration(milliseconds: 400),
                            curve: Curves.ease,
                          );
                        },
                        child: Container(
                          width: 46.0,
                          height: 46.0,
                          color: Colors.black12,
                          child: Icon(Icons.arrow_upward),
                        ),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  /// 构建推荐分类商品
  List<Widget> _buildCategoryGoods(List<CategoryBannersModel>? categoryBanners) {
    List<Widget> items = [];

    // 判断categoryBanners是否为空，如果为空返回空的items
    if (categoryBanners == null) return items;

    for (var i = 0; i < categoryBanners.length; i++) {
      // 取出当前页的CategoryBannersModel
      CategoryBannersModel categoryBannersModel = categoryBanners[i];

      items.add(
        StaggeredGridView.countBuilder(
          crossAxisCount: 2,
          // 这里是指定分类下商品的个数
          itemCount: categoryBannersModel.goods!.length,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            CategoryGoodsModel categoryGoodsModel = categoryBannersModel.goods![index];
            return GestureDetector(
              onTap: () {
                // 进入到商品详情页
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (BuildContext context) {
                    return GoodsDetailPage(id: categoryGoodsModel.id!);
                  }),
                );
              },
              child: Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(color: Colors.white),
                child: Column(
                  // 横轴(副轴)方向左对齐
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 图片
                    // Image.network(
                    //   categoryGoodsModel.picture!,
                    //   width: _categoryGoodsImageW,
                    //   height: _categoryGoodsImageW,
                    //   fit: BoxFit.cover,
                    // ),
                    CustomImage(
                      url: categoryGoodsModel.picture!,
                      width: _categoryGoodsImageW,
                      height: _categoryGoodsImageW,
                    ),
                    // 名称
                    Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        categoryGoodsModel.name!,
                        style: TextStyle(color: Color(0xFF262626), fontSize: 13.0, height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // 价格
                    Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: PriceWidget(
                        price: categoryGoodsModel.price!,
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

    return items;
  }

  /// TabBar组件构建分类导航内容
  List<Widget> _buildTabBar(List<CategoryBannersModel>? categoryBanners) {
    List<Widget> items = [];
    // 判断categoryBanners是否为空，如果为空返回空的items
    if (categoryBanners == null) return items;

    for (var i = 0; i < categoryBanners.length; i++) {
      CategoryBannersModel categoryBannersModel = categoryBanners[i];
      items.add(
        Container(
          width: 60.0,
          height: 44.0,
          alignment: Alignment.center,
          child: Row(
            children: [
              Container(
                width: 59.0,
                alignment: Alignment.center,
                child: Text(
                  categoryBannersModel.name!,
                  style: TextStyle(fontSize: 13.0),
                ),
              ),
              // 分割线:判断当前是否是最后一个分类，如果是，就不构建分割线
              i != categoryBanners.length - 1
                  ? Expanded(
                      child: Container(
                        height: 12.0,
                        decoration: BoxDecoration(color: Color(0xFFC7C7C7)),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      );
    }

    return items;
  }
}

/// 自定义SliverPersistentHeaderDelegate子类，构建吸顶视图
class CustomSliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  CustomSliverPersistentHeaderDelegate({this.tabBar});

  /// 接收TabBar组件
  final TabBar? tabBar;

  // 构建吸顶视图内容
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // shrinkOffset：记录吸顶之后底部视图的滚动的距离(范围是：0.0 ~ maxExtent)
    // debugPrint('$shrinkOffset');
    return Container(
      height: 44.0,
      // 当视图未吸顶时，展示灰色背景，吸顶并且分类商品移动了30像素再变成白色
      decoration: BoxDecoration(color: shrinkOffset >= 30.0 ? Colors.white : Color(0xFFF7F7F8)),
      // 将构造好的分类导航展示出来
      child: tabBar,
    );
  }

  // 吸顶视图最大的高度
  @override
  double get maxExtent => 44.0;

  // 吸顶视图最小的高度
  @override
  double get minExtent => 44.0;

  // 在视图吸顶的时候，是否需要重新构建吸顶视图
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    // 如果返回true表示在视图吸顶的时候需要重新构建吸顶视图
    return true;
  }
}
