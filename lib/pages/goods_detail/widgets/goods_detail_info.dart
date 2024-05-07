import 'package:erabbit_app_flutter/models/home_model.dart';
import 'package:erabbit_app_flutter/widgets/custom_image.dart';
import 'package:erabbit_app_flutter/widgets/price_widget.dart';
import 'package:flutter/material.dart';

class GoodsDetailInfoWidget extends StatefulWidget {
  GoodsDetailInfoWidget({
    this.mainPictures,
    this.price,
    this.brand,
    this.name,
    this.desc,
  });

  /// 轮播图数据
  final List? mainPictures;

  /// 现价
  final String? price;

  /// 品牌信息
  final HotBrandsModel? brand;

  /// 商品名称
  final String? name;

  /// 商品描述
  final String? desc;

  @override
  _GoodsDetailInfoWidgetState createState() => _GoodsDetailInfoWidgetState();
}

class _GoodsDetailInfoWidgetState extends State<GoodsDetailInfoWidget> {
  /// 屏幕高度
  double _screenHeight = 0.0;

  /// 分页控制器
  PageController _pageController = PageController();

  /// 当前选中的index
  int _currentIndex = 1;

  @override
  void initState() {
    _pageController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 轮播图指示器
  Widget _buildIndicator(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 40.0,
      height: 20.0,
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: RichText(
        text: TextSpan(
          text: _currentIndex.toString(),
          style: TextStyle(color: Colors.white, fontSize: 12.0),
          children: [
            TextSpan(
              text: ' / ',
              style: TextStyle(color: Colors.white, fontSize: 10.0),
            ),
            TextSpan(
              text: widget.mainPictures!.length.toString(),
              style: TextStyle(color: Colors.white, fontSize: 10.0),
            ),
          ],
        ),
      ),
    );
  }

  /// 轮播图图片
  List<Widget> _buildItems() {
    List<Widget> items = [];

    for (var i = 0; i < widget.mainPictures!.length; i++) {
      items.add(
        CustomImage(url: widget.mainPictures![i]),
      );
    }

    return items;
  }

  /// 构建轮播图
  Widget _buildBanner() {
    return Container(
      height: _screenHeight * 0.382,
      child: Stack(
        children: [
          PageView(
            controller: _pageController,
            children: _buildItems(),
            onPageChanged: (int index) {
              setState(() {
                // 序号显示的时候是从1开始的
                _currentIndex = index + 1;
              });
            },
          ),
          Positioned(
            right: 20.0,
            bottom: 20.0,
            child: _buildIndicator(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _screenHeight = MediaQuery.of(context).size.height;
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // 轮播图
          _buildBanner(),
          // 商品价格和品牌图标
          Container(
            height: 66.0,
            decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF3CCEAF), Color(0xFF27BA9B)])),
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PriceWidget(
                  price: widget.price,
                  color: Colors.white,
                  symbolFontSize: 14.0,
                  integerFontSize: 28.0,
                  decimalFontSize: 18.0,
                ),
                Container(
                  child: Image.network(widget.brand!.logo!, width: 85.0, height: 40.0, fit: BoxFit.fitWidth),
                ),
              ],
            ),
          ),
          // 商品名称
          Padding(
            padding: EdgeInsets.only(top: 14.0),
            child: Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              alignment: Alignment.centerLeft,
              child: Text(
                widget.name!,
                style: TextStyle(color: Color(0xFF333333), fontSize: 16.0),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // 商品描述
          Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              alignment: Alignment.centerLeft,
              child: Text(
                widget.desc!,
                style: TextStyle(color: Color(0xFFCF4444), fontSize: 12.0),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // 分割线
          Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: Container(height: 1.0, color: Color(0xFFF7F7F8)),
          )
        ],
      ),
    );
  }
}
