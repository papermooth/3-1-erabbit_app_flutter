import 'package:erabbit_app_flutter/models/home_model.dart';
import 'package:erabbit_app_flutter/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// ignore: must_be_immutable
class HotBrandsWidget extends StatelessWidget {
  HotBrandsWidget({this.hotBrands});

  /// 热门品牌数据
  final List<HotBrandsModel>? hotBrands;

  double _imageWidth = 0.0;

  /// 构建内容
  Widget _buildContent(List<HotBrandsModel> hotBrands) {
    return StaggeredGridView.countBuilder(
        crossAxisCount: 4,
        itemCount: hotBrands.length,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisSpacing: 20.0,
        itemBuilder: (BuildContext context, int index) {
          HotBrandsModel hotBrandsModel = hotBrands[index];
          return Column(
            children: [
              // 图片
              // Image.network(
              //   hotBrandsModel.picture!,
              //   width: _imageWidth,
              //   height: _imageWidth,
              //   fit: BoxFit.cover,
              // ),
              CustomImage(
                url: hotBrandsModel.picture!,
                width: _imageWidth,
                height: _imageWidth,
              ),
              // 名称
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  hotBrandsModel.name!,
                  style: TextStyle(color: Color(0xFF262626), fontSize: 12.0),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // 描述
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  hotBrandsModel.desc!,
                  style: TextStyle(color: Color(0xFF999999), fontSize: 12.0),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
        staggeredTileBuilder: (int index) {
          return StaggeredTile.fit(1);
        });
  }

  /// 构建标题
  Widget _buildTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '热门品牌',
          style: TextStyle(color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.w400),
        ),
        Text(
          '更多>>',
          style: TextStyle(color: Color(0xFF7F7F7F), fontSize: 12.0),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // 计算图片的宽度：(屏幕宽度 -  (3 * 20.0 + 4 * 10)) * 0.25
    double screenWidth = MediaQuery.of(context).size.width;
    _imageWidth = (screenWidth - (3 * 20.0 + 4 * 10.0)) * 0.25;

    if (hotBrands != null) {
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
              child: _buildContent(hotBrands!),
            ),
          ],
        ),
      );
    } else {
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
