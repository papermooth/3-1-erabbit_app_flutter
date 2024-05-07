import 'package:erabbit_app_flutter/models/home_model.dart';
import 'package:erabbit_app_flutter/widgets/custom_image.dart';
import 'package:erabbit_app_flutter/widgets/price_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// ignore: must_be_immutable
class FreshGoodsWidget extends StatelessWidget {
  FreshGoodsWidget({this.freshGoods});

  /// 新鲜好物数据
  final List<FreshGoodsModel>? freshGoods;

  /// 图片宽度
  double _imageWidth = 0.0;

  /// 构建内容
  Widget _buildContent(List<FreshGoodsModel> freshGoods) {
    return StaggeredGridView.countBuilder(
      crossAxisCount: 4,
      itemCount: freshGoods.length,
      crossAxisSpacing: 20.0,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        FreshGoodsModel freshGoodsModel = freshGoods[index];
        return Column(
          children: [
            // 图片
            // Image.network(
            //   freshGoodsModel.picture!,
            //   width: _imageWidth,
            //   height: _imageWidth,
            //   fit: BoxFit.cover,
            // ),
            CustomImage(
              url: freshGoodsModel.picture!,
              width: _imageWidth,
              height: _imageWidth,
            ),
            // 名称
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                freshGoodsModel.name!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Color(0xFF262626), fontSize: 12.0, fontWeight: FontWeight.w400),
              ),
            ),
            // 价格 '¥19.9' Text('¥' + freshGoodsModel.price!)
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: PriceWidget(
                price: freshGoodsModel.price!,
              ),
            ),
          ],
        );
      },
      staggeredTileBuilder: (int index) {
        return StaggeredTile.fit(1);
      },
    );
  }

  /// 构建标题
  Widget _buildTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 标题
        Text(
          '新鲜好物',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.0,
            fontWeight: FontWeight.w400,
          ),
        ),
        // 更多
        Text(
          '更多>>',
          style: TextStyle(
            color: Color(0xFF7F7F7F),
            fontSize: 12.0,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // 计算图片的宽度：(屏幕宽度 - (4 * 10.0 + 3 * 20.0)) * 0.25;
    double screenWidth = MediaQuery.of(context).size.width;
    _imageWidth = (screenWidth - (4 * 10.0 + 3 * 20.0)) * 0.25;

    if (freshGoods != null) {
      return Container(
        decoration: BoxDecoration(color: Colors.white),
        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
        child: Column(
          children: [
            // 标题
            Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0),
              child: _buildTitle(),
            ),
            // 内容
            Padding(
              padding: EdgeInsets.only(left: 10.0, top: 16.0, right: 10.0),
              child: _buildContent(freshGoods!),
            ),
          ],
        ),
      );
    } else {
      // 将来做骨架屏
      return Container(
        decoration: BoxDecoration(color: Colors.white),
        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
        child: Column(
          children: [
            // 标题
            Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0),
              child: _buildTitle(),
            ),
            // 内容
            Padding(
              padding: EdgeInsets.only(left: 10.0, top: 16.0, right: 10.0),
              child: StaggeredGridView.countBuilder(
                  crossAxisCount: 4,
                  itemCount: 4,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisSpacing: 20.0,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        Container(
                          width: _imageWidth,
                          height: _imageWidth,
                          decoration: BoxDecoration(
                            color: Color(0xFFEBEBEB),
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                        // 名称
                        Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Container(
                            width: _imageWidth,
                            height: 16.0,
                            decoration: BoxDecoration(color: Color(0xFFEBEBEB)),
                          ),
                        ),
                        // 价格
                        Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Container(
                            width: _imageWidth,
                            height: 16.0,
                            decoration: BoxDecoration(color: Color(0xFFEBEBEB)),
                          ),
                        ),
                      ],
                    );
                  },
                  staggeredTileBuilder: (int index) {
                    return StaggeredTile.fit(1);
                  }),
            ),
          ],
        ),
      );
    }
  }
}
