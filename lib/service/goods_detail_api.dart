import 'package:dio/dio.dart';
import 'package:erabbit_app_flutter/models/goods_detail_model.dart';
import 'package:erabbit_app_flutter/service/requests.dart';

class GoodsDetailAPI {
  /// 商品详情
  static Future<GoodsDetailModel> getGoodsDetail(String id) async {
    String path = 'goods/app?id=$id';
    Response response = await XTXRequestManager().handleRequest(path, 'GET');
    Map ret = response.data['result'];

    // 转模型
    GoodsDetailModel goodsDetailModel = GoodsDetailModel.fromJson(ret);

    return goodsDetailModel;
  }
}
