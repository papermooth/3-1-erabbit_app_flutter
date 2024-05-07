import 'package:dio/dio.dart';
import 'package:erabbit_app_flutter/models/cart_model.dart';
import 'package:erabbit_app_flutter/models/home_model.dart';
import 'package:erabbit_app_flutter/service/requests.dart';

class CartAPI {
  /// 获取猜你喜欢数据
  static Future<List<CategoryGoodsModel>> getUserLike(int limit) async {
    String path = 'goods/relevant?limit=$limit';
    Response response = await XTXRequestManager().handleRequest(path, 'GET');
    List ret = response.data['result'];

    // 转数据模型
    List<CategoryGoodsModel> categoryGoods = [];
    ret.forEach((element) {
      categoryGoods.add(CategoryGoodsModel.fromJson(element));
    });

    return categoryGoods;
  }

  /// 获取购物车商品总数量
  static Future<int> getCartTotalCount() async {
    Response response = await XTXRequestManager().handleRequest('member/cart/count', 'GET');
    int count = response.data['result']['count'];

    return count;
  }

  /// 全选购物车
  static Future<dynamic> selecteAll(bool selected) async {
    Map data = {'selected': selected};
    Response response = await XTXRequestManager().handleRequest('member/cart/selected', 'PUT', data: data);
    dynamic ret = response.data['result'];

    return ret;
  }

  /// 删除购物车
  static Future<dynamic> deleteCart(String id) async {
    Map data = {
      'ids': [id]
    };
    Response response = await XTXRequestManager().handleRequest('member/cart', 'DELETE', data: data);
    dynamic ret = response.data['result'];

    return ret;
  }

  /// 修改购物车
  static Future<CartItemModel> updateCart(String id, int count, bool selected) async {
    String path = 'member/cart/$id';
    Map data = {'count': count, 'selected': selected};
    Response response = await XTXRequestManager().handleRequest(path, 'PUT', data: data);
    Map ret = response.data['result'];

    // 把修改后的商品数据转数据模型
    CartItemModel updateModel = CartItemModel.fromjson(ret);

    return updateModel;
  }

  /// 获取购物车
  static Future<CartModel> getCart() async {
    Response response = await XTXRequestManager().handleRequest('member/cart/mutli', 'GET');
    Map ret = response.data['result'];

    // 转数据模型
    CartModel cartModel = CartModel.fromjson(ret);

    return cartModel;
  }

  /// 添加购物车
  static Future<Map> addCart(String skuId, int count) async {
    Map data = {'skuId': skuId, 'count': count};
    Response response = await XTXRequestManager().handleRequest('member/cart', 'POST', data: data);
    Map ret = response.data['result'];

    return ret;
  }
}
