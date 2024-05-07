import 'package:erabbit_app_flutter/models/home_model.dart';
import 'package:erabbit_app_flutter/widgets/custom_image.dart';
import 'package:erabbit_app_flutter/widgets/price_widget.dart';
import 'package:flutter/material.dart';

class GoodsDetailSimilarWidget extends StatefulWidget {
  GoodsDetailSimilarWidget({this.similarProducts, this.hotByDay});

  /// 同类推荐
  final List<CategoryGoodsModel>? similarProducts;

  /// 24小时热销
  final List<CategoryGoodsModel>? hotByDay;

  @override
  _GoodsDetailSimilarWidgetState createState() => _GoodsDetailSimilarWidgetState();
}

class _GoodsDetailSimilarWidgetState extends State<GoodsDetailSimilarWidget> with TickerProviderStateMixin {
  /// TabBar控制器
  late TabController? _tabController;

  /// 内容宽度
  double _itemW = 0.0;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);

    super.initState();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  // item切换的导航bar
  List<Widget> _buildTabBars() {
    List bars = ["同类商品", "24小时热销"];
    List<Widget> items = [];
    for (var i = 0; i < bars.length; i++) {
      items.add(
        Container(
          alignment: Alignment.center,
          child: Text(
            bars[i],
            style: TextStyle(fontSize: 14.0, color: Color(0xFF333333)),
          ),
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    // 屏幕宽高
    double screenWidth = MediaQuery.of(context).size.width;
    _itemW = (screenWidth - 4 * 10.0) / 3;

    return Column(
      children: [
        // 同类商品和24小时热销的tab
        Container(
          height: 44.0,
          decoration: BoxDecoration(color: Colors.white),
          child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorPadding: EdgeInsets.only(left: 30.0, right: 30.0),
            indicatorColor: Color(0xFF3CCEAF),
            tabs: _buildTabBars(),
          ),
        ),
        // 对应的内容
        Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Container(
            height: (2 * 10.0) + (3 * 8.0) + (_itemW - 2 * 10.0) + 12.0 + 11.0 + 13.0,
            child: TabBarView(
              controller: _tabController,
              children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _buildSimilarSellingItems(widget.similarProducts!),
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _buildSimilarSellingItems(widget.hotByDay!),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 同类商品和24小时热销商品内容
  List<Widget> _buildSimilarSellingItems(List<CategoryGoodsModel> recommendsSource) {
    List<Widget> items = [];
    if (recommendsSource.length == 0) return items;

    for (var i = 0; i < 3; i++) {
      items.add(_buildSimilarSellingItem(i, recommendsSource));
    }

    return items;
  }

  /// 同类商品和24小时热销商品的封装
  Widget _buildSimilarSellingItem(int index, List<CategoryGoodsModel> recommendsSource) {
    CategoryGoodsModel goodsModel = recommendsSource[index];

    return Container(
      width: _itemW,
      decoration: BoxDecoration(color: Colors.white),
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: [
          CustomImage(url: goodsModel.picture!),
          Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              goodsModel.name!,
              style: TextStyle(color: Color(0xFF262626), fontSize: 12.0, height: 1.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              goodsModel.desc!,
              style: TextStyle(color: Color(0xFF999999), fontSize: 11.0, height: 1.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: PriceWidget(price: goodsModel.price),
          ),
        ],
      ),
    );
  }
}
