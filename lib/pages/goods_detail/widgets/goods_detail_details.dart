import 'package:erabbit_app_flutter/models/goods_detail_model.dart';
import 'package:erabbit_app_flutter/widgets/custom_image.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class GoodsDetailDetailsWidget extends StatelessWidget {
  GoodsDetailDetailsWidget({this.details});

  /// 图文详情
  final GoodsDetailsModel? details;

  /// 屏幕宽度
  double _screenWidth = 0.0;

  /// 分割线
  Widget _buildSeparator(BuildContext context) {
    final double dashWidth = 2.0;
    final double dashHeight = 1.0;

    final dashCount = ((_screenWidth - 2 * 10.0) / (2 * dashWidth)).floor();
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(dashCount, (_) {
        return SizedBox(
          width: dashWidth,
          height: dashHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(color: Color(0xFFE4E4E4)),
          ),
        );
      }),
    );
  }

  /// title
  Widget _buildTitle() {
    return Container(
      height: 44.0,
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
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
                        '商品详情',
                        style: TextStyle(fontSize: 14.0, color: Color(0xFF262626), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 分割线
          Container(
            height: 1.0,
            decoration: BoxDecoration(color: Color(0xFFF7F7F8)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        _buildTitle(),
        // 商品属性
        Container(
          decoration: BoxDecoration(color: Colors.white),
          padding: EdgeInsets.only(left: 10.0, right: 10.0),
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: details!.properties!.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 44.0,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          details!.properties![index].name!,
                          style: TextStyle(fontSize: 14.0, color: Color(0xFF898B94)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: EdgeInsets.only(left: 10.0),
                          child: Text(
                            details!.properties![index].value!,
                            style: TextStyle(fontSize: 14.0, color: Color(0xFF262626)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return _buildSeparator(context);
              },
            ),
          ),
        ),
        // 商品图文
        Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Container(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: true,
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: details!.pictures!.length,
                itemBuilder: (BuildContext context, int index) {
                  return CustomImage(url: details!.pictures![index]);
                },
              ),
            ),
          ),
        ),
        // 常见问题
        Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Container(
            height: 44.0,
            padding: EdgeInsets.only(left: 10.0, right: 20.0),
            decoration: BoxDecoration(color: Colors.white),
            child: Row(
              children: [
                Image.asset('assets/qa.png'),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      "常见问题",
                      style: TextStyle(fontSize: 14.0, color: Color(0xFF262626)),
                    ),
                  ),
                ),
                Image.asset('assets/arrow_right.png'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
