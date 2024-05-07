import 'package:dio/dio.dart';
import 'package:erabbit_app_flutter/models/goods_detail_model.dart';
import 'package:erabbit_app_flutter/pages/goods_detail/widgets/goods_detail_appBar.dart';
import 'package:erabbit_app_flutter/pages/goods_detail/widgets/goods_detail_bottom_bar.dart';
import 'package:erabbit_app_flutter/pages/goods_detail/widgets/goods_detail_details.dart';
import 'package:erabbit_app_flutter/pages/goods_detail/widgets/goods_detail_evaluation.dart';
import 'package:erabbit_app_flutter/pages/goods_detail/widgets/goods_detail_info.dart';
import 'package:erabbit_app_flutter/pages/goods_detail/widgets/goods_detail_options.dart';
import 'package:erabbit_app_flutter/pages/goods_detail/widgets/goods_detail_recommends.dart';
import 'package:erabbit_app_flutter/pages/goods_detail/widgets/goods_detail_similar.dart';
import 'package:erabbit_app_flutter/pages/goods_detail/widgets/goods_detail_title_appBar.dart';
import 'package:erabbit_app_flutter/service/goods_detail_api.dart';
import 'package:erabbit_app_flutter/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class GoodsDetailPage extends StatefulWidget {
  GoodsDetailPage({
    required this.id,
  });

  /// 商品id（必传）
  final String id;

  @override
  _GoodsDetailPageState createState() => _GoodsDetailPageState();
}

class _GoodsDetailPageState extends State<GoodsDetailPage> {
  /// 商品详情数据
  GoodsDetailModel? _goodsDetailModel;

  /// 屏幕高度
  double _screenHeight = 0.0;

  /// 顶部导航栏高度
  double _appBarHeight = 0.0;

  /// 商品、评价、详情、推荐的key
  List<GlobalKey> _keys = [
    GlobalKey(debugLabel: 'goods'),
    GlobalKey(debugLabel: 'comment'),
    GlobalKey(debugLabel: 'details'),
    GlobalKey(debugLabel: 'recommends'),
  ];

  /// ScrollController
  late ScrollController _scrollController;

  @override
  void initState() {
    debugPrint('商品id：${widget.id}');

    _scrollController = ScrollController();

    // 加载商品详情数据
    _loadGoodsDetailData();

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 加载商品详情数据
  void _loadGoodsDetailData() async {
    try {
      _goodsDetailModel = await GoodsDetailAPI.getGoodsDetail(widget.id);
      // _goodsDetailModel = await GoodsDetailAPI.getGoodsDetail('1369155859933827074');
      // debugPrint('商品详情数据：$_goodsDetailModel');

      setState(() {});
    } on DioError catch (e) {
      EasyLoading.showToast(e.response!.data['message']);
    }
  }

  /// 监听顶部导航栏点击事件：定义商品详情内容
  void _titleOnTap(int index) {
    // 商品详情内容定位的位置：商品详情页已滚动的距离 + 内容组件的纵坐标 - 顶部导航栏高度
    double locationY = _getLocationY(index);
    double point = _scrollController.offset + locationY - _appBarHeight;

    _scrollController.animateTo(point, duration: Duration(milliseconds: 400), curve: Curves.ease);
  }

  /// 获取商品、评价、详情、推荐的纵坐标
  double _getLocationY(int index) {
    RenderBox box = _keys[index].currentContext?.findRenderObject() as RenderBox;
    // Offset.zero : 表示从屏幕左上角去坐标
    Offset location = box.localToGlobal(Offset.zero);
    // 读取纵坐标
    double locationY = location.dy;

    return locationY;
  }

  /// 监听商品详情页滚动中的事件
  void _goodsDetailOnScroll(double offset) {
    debugPrint('ScrollUpdateNotification：$offset');

    // 获取商品、评价、详情、推荐的纵坐标
    double goodsY = _getLocationY(0);
    double commentY = _getLocationY(1);
    double detailsY = _getLocationY(2);
    double recommendsY = _getLocationY(3);
    debugPrint('组件纵坐标：$goodsY -- $commentY -- $detailsY -- $recommendsY');

    // 计算顶部导航栏透明度：商品详情页滚动的距离 / (轮播图高度 - 顶部导航栏高度)
    double opacity = offset / (_screenHeight * 0.382 - _appBarHeight);
    // 注意：opacity：取值范围 1.0 ~ 0.0；
    if (opacity < 0.0) {
      opacity = 0.0;
    } else if (opacity > 1.0) {
      opacity = 1.0;
    }
    debugPrint('顶部导航栏透明度：$opacity');

    // 向顶部导航栏传入透明度
    goodsDetailAppBarKey.currentState?.getGoodsDetailAppBarOpacity(opacity);
    goodsDetailTitleAppBarKey.currentState!.getGoodsDetailTitleAppBarOpacity(
      opacity,
      goodsY,
      commentY,
      detailsY,
      recommendsY,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 屏幕高度
    _screenHeight = MediaQuery.of(context).size.height;
    // 顶部导航栏高度 = 顶部工具栏高度 + 不规则屏幕上边距
    _appBarHeight = kToolbarHeight + MediaQuery.of(context).padding.top;

    return Scaffold(
      body: _goodsDetailModel != null
          ? Stack(
              children: [
                // 页面内容：商品详情内容 + 底部操作栏
                Column(
                  children: [
                    // 商品详情内容
                    Expanded(
                      child: NotificationListener(
                        onNotification: (ScrollNotification scrollNotification) {
                          // 监听商品详情页滚动中的事件
                          if (scrollNotification is ScrollUpdateNotification && scrollNotification.depth == 0) {
                            _goodsDetailOnScroll(scrollNotification.metrics.pixels);
                          }

                          // 监听滚动结束
                          if (scrollNotification is ScrollEndNotification && scrollNotification.depth == 0) {
                            // 取消点击的标记
                            goodsDetailTitleAppBarKey.currentState!.cancelTag();
                          }

                          // true：禁止通知冒泡
                          return true;
                        },
                        child: CustomScrollView(
                          controller: _scrollController,
                          slivers: [
                            // 商品基本信息
                            SliverToBoxAdapter(
                              child: Container(
                                key: _keys[0],
                                child: GoodsDetailInfoWidget(
                                  mainPictures: _goodsDetailModel!.mainPictures,
                                  price: _goodsDetailModel!.price,
                                  brand: _goodsDetailModel!.brand,
                                  name: _goodsDetailModel!.name,
                                  desc: _goodsDetailModel!.desc,
                                ),
                              ),
                            ),
                            // 商品规格选项
                            SliverToBoxAdapter(
                              child: Container(
                                child: GoodsDetailOptionsWidget(
                                  key: goodsDetailOptionsKey,
                                  goodsDetailModel: _goodsDetailModel,
                                ),
                              ),
                            ),
                            // 商品评价信息
                            SliverToBoxAdapter(
                              child: Padding(
                                key: _keys[1],
                                padding: EdgeInsets.only(top: 8.0),
                                child: GoodsDetailEvaluationWidget(
                                  evaluationInfoModel: _goodsDetailModel!.evaluationInfo,
                                ),
                              ),
                            ),
                            // 同类推荐和24小时热销
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: GoodsDetailSimilarWidget(
                                  similarProducts: _goodsDetailModel!.similarProducts,
                                  hotByDay: _goodsDetailModel!.hotByDay,
                                ),
                              ),
                            ),
                            // 商品图文详情
                            SliverToBoxAdapter(
                              child: Padding(
                                key: _keys[2],
                                padding: EdgeInsets.only(top: 8.0),
                                child: GoodsDetailDetailsWidget(
                                  details: _goodsDetailModel!.details,
                                ),
                              ),
                            ),
                            // 热门商品推荐
                            SliverToBoxAdapter(
                              child: Padding(
                                key: _keys[3],
                                padding: EdgeInsets.only(top: 8.0),
                                child: GoodsDetailRecommendsWidget(
                                  recommends: _goodsDetailModel!.recommends,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 底部操作栏
                    GoodsDetailBottomBar(),
                  ],
                ),
                // 顶部导航栏：普通导航栏 + 标题导航栏
                // 标题导航栏
                GoodsDetailTitleAppBar(
                  key: goodsDetailTitleAppBarKey,
                  titleOnTap: _titleOnTap,
                ),
                // 普通导航栏：默认先看到普通导航栏，所以需要在层叠的最上层
                GoodsDetailAppBar(key: goodsDetailAppBarKey),
              ],
            )
          : LoadingWidget(),
    );
  }
}
