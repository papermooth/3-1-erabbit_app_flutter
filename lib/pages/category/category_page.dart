import 'package:erabbit_app_flutter/models/category_model.dart';
import 'package:erabbit_app_flutter/models/home_model.dart';
import 'package:erabbit_app_flutter/pages/goods_detail/goods_detail_page.dart';
import 'package:erabbit_app_flutter/service/category_api.dart';
import 'package:erabbit_app_flutter/widgets/loading_widget.dart';
import 'package:erabbit_app_flutter/widgets/price_widget.dart';
import 'package:erabbit_app_flutter/widgets/custom_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> with AutomaticKeepAliveClientMixin {
  // 记录页面状态
  @override
  bool get wantKeepAlive => true;

  /// 一级分类数据
  List<PrimaryCategoryModel> _primaryCategories = [];

  /// 当前选中的一级分类索引:默认第一个被选中
  int _currentIndex = 0;

  /// 一级分类滚动视图控制器
  ScrollController? _primaryController;

  /// 一级分类滚动视图的key:用来获取一级分类滚动视图高度的
  GlobalKey _primaryCategoryGlobalKey = GlobalKey(debugLabel: 'primaryCategoryGlobalKey');

  /// 二级分类和商品数据
  SubCategoryModel? _subCategoryModel;

  /// 商品图片宽度
  double _imageWidth = 0.0;

  /// 二级分类滚动视图控制器
  ScrollController? _secondaryController;

  /// 缓存二级分类的字典
  Map<String, dynamic> _secondaryCategoryCache = {};

  /// 记录选中的一级分类的id
  String _selectedId = '';

  @override
  void initState() {
    // 创建一级分类滚动视图控制器
    _primaryController = ScrollController();
    // 创建二级分类滚动视图控制器
    _secondaryController = ScrollController();

    // 获取一级分类
    _loadPrimaryCategoryData();
    super.initState();
  }

  @override
  void dispose() {
    // 销毁一级分类滚动视图控制器
    _primaryController?.dispose();
    // 销毁二级分类滚动视图控制器
    _secondaryController?.dispose();

    super.dispose();
  }

  /// 获取一级分类
  _loadPrimaryCategoryData() async {
    try {
      _primaryCategories = await CategoryAPI.getPrimaryCategory();

      // 默认请求第一个一级分类对应的二级分类和商品数据
      _subCategoryModel = await CategoryAPI.getSecondaryCategory(_primaryCategories[0].id!);

      // 缓存第一个一级分类对应的二级分类和商品数据
      _secondaryCategoryCache[_primaryCategories[0].id!] = _subCategoryModel;

      // 记录第一个一级分类的id
      _selectedId = _primaryCategories[0].id!;

      setState(() {});
    } catch (e) {
      debugPrint('$e');
    }
  }

  /// 获取二级分类和商品数据
  void _loadSecondaryCategoryData(String id) async {
    // 判断是否有缓存
    if (_secondaryCategoryCache.containsKey(id)) {
      // 有缓存：读取并展示缓存数据
      _subCategoryModel = _secondaryCategoryCache[id];
      setState(() {});
    } else {
      // 无缓存：请求数据，并缓存
      try {
        _subCategoryModel = await CategoryAPI.getSecondaryCategory(id);
        // 缓存
        _secondaryCategoryCache[id] = _subCategoryModel;

        setState(() {});
      } catch (e) {
        debugPrint('$e');
      }
    }
  }

  /// 监听一级分类点击事件
  void _primaryCategoryOnTap(int index) {
    // print(primaryCategoryModel.name!);

    // 禁止重复点击一级分类
    if (_currentIndex == index) return;

    // 获取选中的一级分类中心点:(index + 0.5) * 44.0
    double selectedPoint = (index + 0.5) * 44.0;
    // print('selectedPoint: $selectedPoint');

    // 获取一级分类滚动视图高度的一半: GlobalKey
    RenderBox box = _primaryCategoryGlobalKey.currentContext?.findRenderObject() as RenderBox;
    double primaryCategoryHeight = box.size.height;
    // print('primaryCategoryHeight: $primaryCategoryHeight');

    // 计算滚动到的居中位置
    double centerOffset = selectedPoint - primaryCategoryHeight * 0.5;
    // print('centerOffset: $centerOffset');

    // 计算出最小和最大的滚动距离
    double minOffset = 0.0;
    // 最大滚动距离：一级分类内容总高度 - 一级分类滚动视图高度
    double maxOffset = _primaryCategories.length * 44.0 - primaryCategoryHeight;
    // 限制最小和最大滚动距离
    // 如果居中需要滚动的距离<=minOffset,centerOffset=minOffset
    // 如果居中需要滚动的距离>=maxOffset,centerOffset=maxOffset
    if (centerOffset <= minOffset) {
      centerOffset = minOffset;
    } else if (centerOffset >= maxOffset) {
      centerOffset = maxOffset;
    }

    // 滚动到居中的位置
    _primaryController!.animateTo(centerOffset, duration: Duration(milliseconds: 400), curve: Curves.ease);

    setState(() {
      // 记录选中一级分类索引
      _currentIndex = index;
    });

    // 切换一级分类时记录id
    _selectedId = _primaryCategories[index].id!;

    // 切换二级分类时默认滚动到顶部：jumpTo（不带动画）
    _secondaryController!.jumpTo(0.0);

    // 获取一级分类对应的二级分类和商品数据
    _loadSecondaryCategoryData(_primaryCategories[index].id!);
  }

  /// 构建二级分类下的商品
  Widget _buildCategoryGoodsItem(SecondaryCategoryModel secondaryCategoryModel) {
    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: Column(
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    secondaryCategoryModel.name!,
                    style: TextStyle(fontSize: 13.0, color: Color(0xFF333333)),
                  ),
                  GestureDetector(
                    child: Text(
                      "全部 >>",
                      style: TextStyle(fontSize: 11.0, color: Color(0xFF999999)),
                    ),
                    onTap: () {},
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Container(
                  height: 1.0,
                  decoration: BoxDecoration(color: Color(0xFFF7F7F8)),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: StaggeredGridView.countBuilder(
              crossAxisCount: 3,
              itemCount: secondaryCategoryModel.goods!.length,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 24.0,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                CategoryGoodsModel categoryGoodsModel = secondaryCategoryModel.goods![index];
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomImage(
                        url: categoryGoodsModel.picture!,
                        width: _imageWidth,
                        height: _imageWidth,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          categoryGoodsModel.desc!,
                          style: TextStyle(fontSize: 11.0, color: Color(0xFF333333)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: PriceWidget(
                          price: categoryGoodsModel.price!,
                          symbolFontSize: 11.0,
                          integerFontSize: 11.0,
                          decimalFontSize: 11.0,
                        ),
                      ),
                    ],
                  ),
                );
              },
              staggeredTileBuilder: (int index) {
                return StaggeredTile.fit(1);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建二级分类
  Widget _buildSecondaryCategory() {
    // 判断是否有二级分类缓存数据
    // if (_secondaryCategoryCache.containsKey(_primaryCategories[_currentIndex].id!)) {
    if (_secondaryCategoryCache.containsKey(_selectedId)) {
      return Container(
        color: Colors.white,
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        child: ListView.builder(
          controller: _secondaryController,
          itemCount: _subCategoryModel!.children!.length,
          itemBuilder: (BuildContext context, int index) {
            SecondaryCategoryModel secondaryCategoryModel = _subCategoryModel!.children![index];
            return _buildCategoryGoodsItem(secondaryCategoryModel);
          },
        ),
      );
    } else {
      // 将来展示loading动画效果
      return LoadingWidget();
    }
  }

  /// 构建一级分类
  Widget _buildPrimaryCategory() {
    return Container(
      color: Color(0xFFF2F2F2),
      child: ListView.builder(
        key: _primaryCategoryGlobalKey,
        controller: _primaryController,
        itemCount: _primaryCategories.length,
        itemBuilder: (BuildContext context, int index) {
          PrimaryCategoryModel primaryCategoryModel = _primaryCategories[index];
          return GestureDetector(
            onTap: () {
              _primaryCategoryOnTap(index);
            },
            child: Container(
              // 设置选中和未选中背景色
              color: _currentIndex == index ? Colors.white : Color(0xFFF2F2F2),
              height: 44.0,
              child: Row(
                children: [
                  // 指示器
                  Container(
                    width: 4.0,
                    height: 30.0,
                    color: _currentIndex == index ? Color(0xFF3CCEAF) : Color(0xFFF2F2F2),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        primaryCategoryModel.name!,
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 13.0,
                          // 设置选中和未选中粗体字
                          fontWeight: _currentIndex == index ? FontWeight.w500 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 记录页面状态
    super.build(context);

    // 计算二级分类商品图片宽度:((屏幕宽度 / 4 * 3) - (4 * 10.0)) / 3
    double screenWidth = MediaQuery.of(context).size.width;
    _imageWidth = ((screenWidth / 4 * 3) - (4 * 10.0)) / 3;

    return Scaffold(
      backgroundColor: Color(0xFFF7F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        shadowColor: Colors.transparent,
        title: Text(
          '分类',
          style: TextStyle(color: Color(0xFF282828), fontSize: 16.0),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 6.0),
        child: Row(
          children: [
            // 一级分类
            Expanded(
              flex: 1,
              child: _buildPrimaryCategory(),
            ),
            // 二级分类和商品
            Expanded(
              flex: 3,
              child: _buildSecondaryCategory(),
            ),
          ],
        ),
      ),
    );
  }
}
