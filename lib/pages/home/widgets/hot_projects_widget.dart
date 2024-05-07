import 'package:erabbit_app_flutter/models/home_model.dart';
import 'package:erabbit_app_flutter/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// ignore: must_be_immutable
class HotProjectsWidget extends StatelessWidget {
  HotProjectsWidget({this.hotProjects});

  /// 热门专题数据
  final List<HotProjectsModel>? hotProjects;

  /// 图片宽度
  double _itemWidth = 0.0;

  /// 构建内容
  Widget _buildContent(List<HotProjectsModel> hotProjects) {
    return StaggeredGridView.countBuilder(
      crossAxisCount: 2,
      itemCount: hotProjects.length,
      crossAxisSpacing: 10.0,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        HotProjectsModel hotProjectsModel = hotProjects[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片
            // Image.network(
            //   hotProjectsModel.cover!,
            //   width: _itemWidth,
            //   height: 84.0,
            //   fit: BoxFit.cover,
            // ),
            CustomImage(
              url: hotProjectsModel.cover!,
              width: _itemWidth,
              height: 84.0,
            ),
            // 名称
            Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text(
                hotProjectsModel.title!,
                style: TextStyle(color: Color(0xFF333333), fontSize: 12.0),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // 价格
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: RichText(
                text: TextSpan(
                  text: hotProjectsModel.lowestPrice! + '元',
                  style: TextStyle(color: Color(0xFFCF4444), fontSize: 11.0),
                  children: [
                    TextSpan(
                      text: '起',
                      style: TextStyle(color: Color(0xFF999999), fontSize: 11.0),
                    )
                  ],
                ),
              ),
            ),
            // 收藏量
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Row(
                    children: [
                      Image.asset('assets/xin.png'),
                      Padding(
                        padding: EdgeInsets.only(left: 2.0),
                        child: Text(
                          hotProjectsModel.collectNum!,
                          style: TextStyle(color: Color(0xFF333333), fontSize: 10.0),
                        ),
                      ),
                    ],
                  ),
                  // 查看量
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Row(
                      children: [
                        Image.asset('assets/chakan.png'),
                        Padding(
                          padding: EdgeInsets.only(left: 2.0),
                          child: Text(
                            hotProjectsModel.viewNum!,
                            style: TextStyle(color: Color(0xFF333333), fontSize: 10.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
        Text(
          '专题',
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
    double screenWidth = MediaQuery.of(context).size.width;
    _itemWidth = (screenWidth - (4 * 10.0 + 10.0)) * 0.5;

    if (hotProjects != null) {
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
              child: _buildContent(hotProjects!),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}
