import 'package:erabbit_app_flutter/models/home_model.dart';
import 'package:erabbit_app_flutter/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// ignore: must_be_immutable
class HotRecommendsWidget extends StatelessWidget {
  HotRecommendsWidget({this.hotRecommends});

  /// 热门推荐数据
  final List<HotRecommendsModel>? hotRecommends;

  /// 图片宽度
  double _imageWidth = 0.0;

  /// 构建推荐内容
  Widget _buildItem(HotRecommendsModel hotRecommendsModel) {
    return Container(
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          // 主标题和副标题
          Row(
            children: [
              Text(
                hotRecommendsModel.title!,
                style: TextStyle(color: Color(0xFF262626), fontSize: 16.0, fontWeight: FontWeight.w400),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Text(
                  hotRecommendsModel.caption!,
                  style: TextStyle(color: Color(0xFF7F7F7F), fontSize: 12.0, fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
          // 左侧图片和右侧图片
          Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Image.network(
                //   hotRecommendsModel.leftIcon!,
                //   width: _imageWidth,
                //   height: _imageWidth,
                //   fit: BoxFit.cover,
                // ),
                // 插件
                // CachedNetworkImage(
                //   imageUrl: hotRecommendsModel.leftIcon!,
                //   width: _imageWidth,
                //   height: _imageWidth,
                //   fit: BoxFit.cover,
                // ),
                // 自定义的加载网络图片的组件
                CustomImage(
                  url: hotRecommendsModel.leftIcon!,
                  width: _imageWidth,
                  height: _imageWidth,
                ),
                // Padding(
                //   padding: EdgeInsets.only(left: 10.0),
                //   child: Image.network(
                //     hotRecommendsModel.rightIcon!,
                //     width: _imageWidth,
                //     height: _imageWidth,
                //     fit: BoxFit.cover,
                //   ),
                // ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: CustomImage(
                    url: hotRecommendsModel.rightIcon!,
                    width: _imageWidth,
                    height: _imageWidth,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 计算图片宽度：(屏幕宽度 - (8 * 10.0 +1.0)) * 0.25
    double screenWidth = MediaQuery.of(context).size.width;
    _imageWidth = (screenWidth - (8 * 10.0 + 1.0)) * 0.25;

    if (hotRecommends != null) {
      return StaggeredGridView.countBuilder(
        crossAxisCount: 2, // 每行item的个数
        itemCount: hotRecommends!.length, // item的个数
        crossAxisSpacing: 1.0, // 左右间距
        mainAxisSpacing: 1.0, // 上下间距
        // 禁用滚动
        physics: NeverScrollableScrollPhysics(),
        // 保证网格视图是一个整体（使用内容限定视图大小），跟CustomScrollView具有一样的滚动效果
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          HotRecommendsModel hotRecommendsModel = hotRecommends![index];
          return _buildItem(hotRecommendsModel);
        },
        staggeredTileBuilder: (int index) {
          return StaggeredTile.fit(1);
        },
      );
    } else {
      // 加载等待的骨架屏
      return StaggeredGridView.countBuilder(
          crossAxisCount: 2,
          itemCount: 4,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          mainAxisSpacing: 1.0,
          crossAxisSpacing: 1.0,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              decoration: BoxDecoration(color: Colors.white),
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: [
                  // 标题
                  Row(
                    children: [
                      // 主标题
                      Container(
                        width: _imageWidth,
                        height: 20.0,
                        decoration: BoxDecoration(color: Color(0xFFEBEBEB)),
                      ),
                      // 副标题
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Container(
                          width: _imageWidth,
                          height: 16.0,
                          decoration: BoxDecoration(color: Color(0xFFEBEBEB)),
                        ),
                      ),
                    ],
                  ),
                  // 图片
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: _imageWidth,
                          height: _imageWidth,
                          decoration: BoxDecoration(
                            color: Color(0xFFEBEBEB),
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                        Container(
                          width: _imageWidth,
                          height: _imageWidth,
                          decoration: BoxDecoration(
                            color: Color(0xFFEBEBEB),
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          staggeredTileBuilder: (int index) {
            return StaggeredTile.fit(1);
          });
    }
  }
}
