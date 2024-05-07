import 'package:erabbit_app_flutter/models/home_model.dart';
import 'package:erabbit_app_flutter/pages/order_payment/payment_cancel_page.dart';
import 'package:erabbit_app_flutter/service/cart_api.dart';
import 'package:erabbit_app_flutter/widgets/custom_image.dart';
import 'package:erabbit_app_flutter/widgets/price_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class PaymentFailedPage extends StatefulWidget {
  PaymentFailedPage({this.orderId});

  /// 订单ID
  final String? orderId;

  @override
  _PaymentFailedPageState createState() => _PaymentFailedPageState();
}

class _PaymentFailedPageState extends State<PaymentFailedPage> {
  /// 猜你喜欢数据
  List<CategoryGoodsModel> _categoryGoods = [];

  @override
  void initState() {
    // 猜你喜欢
    _loadUserLike();

    super.initState();
  }

  /// 猜你喜欢
  void _loadUserLike() async {
    try {
      _categoryGoods = await CartAPI.getUserLike(10);
      setState(() {});
    } catch (e) {
      debugPrint('$e');
    }
  }

  /// 支付成功的头部
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
        color: Color(0xFFFF9240),
      ),
      child: Column(
        children: [
          Column(
            children: [
              Image.asset('assets/payment_failed.png'),
              Padding(
                padding: EdgeInsets.only(top: 15.0),
                child: Text(
                  '支付失败',
                  style: TextStyle(fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          // 返回首页和查看订单
          Padding(
            padding: EdgeInsets.symmetric(vertical: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                  },
                  child: Container(
                    height: 30.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 18.0, right: 18.0),
                      child: Text(
                        '继续逛逛',
                        style: TextStyle(fontSize: 15.0, color: Colors.white, height: 1.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 30.0),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(context, CupertinoPageRoute(builder: (BuildContext context) {
                      return PaymentCancelPage(orderId: widget.orderId);
                    }));
                  },
                  child: Container(
                    height: 30.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 18.0, right: 18.0),
                      child: Text(
                        '重新支付',
                        style: TextStyle(fontSize: 15.0, color: Colors.white, height: 1.0),
                      ),
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
      itemBuilder: (BuildContext context, int index) {
        CategoryGoodsModel goodsModel = _categoryGoods[index];
        return GestureDetector(
          onTap: () {
            // Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) {
            //   return GoodsDetailPage(id: goodsModel.id!);
            // }));
          },
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
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F8),
      appBar: AppBar(
        backgroundColor: Color(0xFFFF9240),
        shadowColor: Colors.transparent,
        leading: IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image.asset('assets/fanhui_light.png'),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Image.asset('assets/user_like.png'),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: _buildUserLike(),
            ),
          ),
        ],
      ),
    );
  }
}
