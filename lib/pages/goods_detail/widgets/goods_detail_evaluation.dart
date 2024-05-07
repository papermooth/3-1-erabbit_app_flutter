import 'package:erabbit_app_flutter/models/goods_detail_model.dart';
import 'package:erabbit_app_flutter/widgets/custom_image.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class GoodsDetailEvaluationWidget extends StatelessWidget {
  GoodsDetailEvaluationWidget({this.evaluationInfoModel});

  /// 评价信息
  final EvaluationInfoModel? evaluationInfoModel;

  /// 评价分数图标
  Image uncommentStar = Image.asset('assets/star_uncomment.png', width: 10.0, height: 10.0, fit: BoxFit.cover);
  Image commentStar = Image.asset('assets/star_comment.png', width: 10.0, height: 10.0, fit: BoxFit.cover);

  /// 底部的评价商品规格规格
  String getEvaluationSpecsText() {
    // 购买时间
    String createTime = "购买时间：${evaluationInfoModel!.orderInfo!.createTime} ";
    // 规格
    List<String> specs = [];
    evaluationInfoModel!.orderInfo!.specs!.forEach((element) {
      specs.add(element.valueName!);
    });
    String specsString = specs.join("，") + ' ';
    // 数量
    String quantity = '${evaluationInfoModel!.orderInfo!.quantity}件';

    return createTime + specsString + quantity;
  }

  /// 商品评价图片
  List<Widget> _buildEvaluationPicturs() {
    List<Widget> items = [];
    if (evaluationInfoModel == null) return items;
    // 最多展示三张评价图片
    List pictures = evaluationInfoModel!.pictures!;
    if (pictures.length > 3) {
      pictures = pictures.sublist(0, 3);
    }

    for (var i = 0; i < pictures.length; i++) {
      String url = pictures[i];

      items.add(
        Container(
          // 三张图片，中间的那张左右都有10的间距
          padding: i == 1 ? EdgeInsets.only(left: 10.0, right: 10.0) : null,
          child: CustomImage(url: url, width: 80.0, height: 80.0),
        ),
      );
    }

    return items;
  }

  /// 商品评价分数
  List<Widget> _buildScoreStar() {
    List<Widget> stars = [];

    for (var i = 0; i < 5; i++) {
      stars.add(
        Container(
          padding: EdgeInsets.only(right: 8.0),
          child: evaluationInfoModel!.score! > i ? commentStar : uncommentStar,
        ),
      );
    }

    return stars;
  }

  /// 评价信息
  Widget _buildEvaluationInfo() {
    return Column(
      children: [
        // 评价的用户信息+评分
        Container(
          padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 用户信息
              Row(
                children: [
                  // 头像
                  Container(
                    width: 26.0,
                    height: 26.0,
                    child: ClipOval(
                      child: CustomImage(
                        url: evaluationInfoModel!.member!.avatar!,
                      ),
                    ),
                  ),
                  // 昵称
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      evaluationInfoModel!.member!.account!,
                      style: TextStyle(fontSize: 12.0, color: Color(0xFF666666)),
                    ),
                  ),
                ],
              ),
              // 评分
              Row(
                children: _buildScoreStar(),
              ),
            ],
          ),
        ),
        // 评价的内容
        Padding(
          padding: EdgeInsets.only(top: 8.0, left: 44.0, right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 评价内容
              Text(
                evaluationInfoModel!.content!,
                style: TextStyle(fontSize: 13.0, color: Color(0xFF010101)),
              ),
              // 评价图片
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Row(
                  children: _buildEvaluationPicturs(),
                ),
              ),
              // 评价规格
              Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: Text(
                  getEvaluationSpecsText(),
                  style: TextStyle(fontSize: 10.0, color: Color(0xFF7D7D7D)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  /// 评价title
  Widget _buildEvaluationTitle() {
    return Container(
      height: 44.0,
      padding: EdgeInsets.only(left: 10.0, right: 20.0),
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
                        '评价',
                        style: TextStyle(fontSize: 14.0, color: Color(0xFF262626), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      evaluationInfoModel != null ? '好评度 ${evaluationInfoModel!.praisePercent}%' : "好评度 0%",
                      style: TextStyle(color: Color(0xFF666666), fontSize: 12.0),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Image.asset('assets/arrow_right.png'),
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
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          // 评价title
          _buildEvaluationTitle(),
          // 推荐评价内容
          _buildEvaluationInfo(),
        ],
      ),
    );
  }
}
