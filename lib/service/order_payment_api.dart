import 'package:dio/dio.dart';
import 'package:erabbit_app_flutter/models/order_payment_model.dart';
import 'package:erabbit_app_flutter/service/requests.dart';

class OrderPaymentAPI {
  /// 取消订单
  static Future<OrderInfoModel> orderCancel(String id, String cancelReason) async {
    String path = 'member/order/$id/cancel';
    Map data = {'cancelReason': cancelReason};
    Response response = await XTXRequestManager().handleRequest(path, 'PUT', data: data);
    Map updateOrder = response.data['result'];

    // 转模型
    OrderInfoModel updateInfoModel = OrderInfoModel.fromjson(updateOrder);

    return updateInfoModel;
  }

  /// 订单列表
  static Future<OrderListModel> orderList({int? page= 1, int? pageSize= 10, int? orderState= 0}) async {
    String path = 'member/order?page=$page&pageSize=$pageSize&orderState=$orderState';
    Response response = await XTXRequestManager().handleRequest(path, 'GET');
    Map orders = response.data['result'];

    // 转模型
    OrderListModel orderListModel = OrderListModel.fromjson(orders);

    return orderListModel;
  }

  /// 订单详情
  static Future<Map> orderDetail(String id) async {
    String path = 'member/order/$id';
    Response response = await XTXRequestManager().handleRequest(path, 'GET');
    Map orderDetail = response.data['result'];

    return orderDetail;
  }

  /// 支付宝支付
  static Future<String> orderAlipay(String orderId) async {
    String path = 'pay/aliPay/app?orderId=$orderId';
    Response response = await XTXRequestManager().handleRequest(path, 'GET');

    // 小兔鲜儿后台从支付宝支付后台获取到的订单支付相关的信息，用于唤起支付宝钱包并支付的
    String orderString = response.data['result'];

    return orderString;
  }

  /// 提交订单
  static Future<Map> orderCommit({
    List? goods,
    String? addressId,
    int? deliveryTimeType,
    int? payType= 1,
    int? payChannel= 1,
    String? buyerMessage,
  }) async {
    Map data = {
      'goods': goods,
      'addressId': addressId,
      'deliveryTimeType': deliveryTimeType,
      'payType': payType,
      'payChannel': payChannel,
      'buyerMessage': buyerMessage,
    };
    Response response = await XTXRequestManager().handleRequest('member/order', 'POST', data: data);
    Map ret = response.data['result'];

    return ret;
  }

  /// 立即购买
  static Future<OrderSettlementModel> orderBuyNow(String skuId, int count) async {
    String path = 'member/order/pre/now?skuId=$skuId&count=$count';
    Response response = await XTXRequestManager().handleRequest(path, 'GET');
    Map ret = response.data['result'];

    // 转模型
    OrderSettlementModel settlementModel = OrderSettlementModel.fromjson(ret);

    return settlementModel;
  }

  /// 订单结算
  static Future<OrderSettlementModel> orderSettlement() async {
    Response response = await XTXRequestManager().handleRequest('member/order/pre', 'GET');
    Map ret = response.data['result'];

    // 转模型
    OrderSettlementModel settlementModel = OrderSettlementModel.fromjson(ret);

    return settlementModel;
  }
}
