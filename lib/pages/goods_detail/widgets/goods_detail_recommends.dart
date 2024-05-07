import 'package:erabbit_app_flutter/models/home_model.dart';
import 'package:erabbit_app_flutter/widgets/custom_image.dart';
import 'package:erabbit_app_flutter/widgets/price_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class GoodsDetailRecommendsWidget extends StatelessWidget {
  GoodsDetailRecommendsWidget({this.recommends});

  /// 商品推荐
  final List<CategoryGoodsModel>? recommends;

  /// 推荐title
  Widget _buildRecommendsTitle() {
    return Container(
      height: 44.0,
      color: Colors.white,
      padding: EdgeInsets.only(left: 10, right: 20),
      child: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // 起始线
                    Container(
                      width: 2.0,
                      height: 15.0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xff3CCEAF), Color(0xff27BA9B)]),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        '热门推荐',
                        style: TextStyle(fontSize: 14.0, color: Color(0xFF262626), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 热门推荐商品
  Widget _buildRecommendsContent() {
    return StaggeredGridView.countBuilder(
      crossAxisCount: 2,
      itemCount: recommends!.length,
      crossAxisSpacing: 10.0,
      mainAxisSpacing: 10.0,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        CategoryGoodsModel categoryGoodsModel = recommends![index];
        return Container(
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomImage(url: categoryGoodsModel.picture!),
              // 名称
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  categoryGoodsModel.name!,
                  style: TextStyle(color: Color(0xFF262626), fontSize: 13.0),
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
        );
      },
      staggeredTileBuilder: (int index) {
        return StaggeredTile.fit(1);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRecommendsTitle(),
        Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: _buildRecommendsContent(),
          ),
        ),
      ],
    );
  }
}
