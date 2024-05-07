import 'package:erabbit_app_flutter/models/goods_detail_model.dart';

/// 订单列表
class OrderListModel {
  /// 订单总数
  final int? counts;

  /// 当前页订单数
  final int? pageSize;

  /// 订单总页数
  final int? pages;

  /// 当前页码
  final int? page;

  /// 订单商品列表
  final List<OrderInfoModel>? items;

  OrderListModel({this.counts, this.pageSize, this.pages, this.page, this.items});

  factory OrderListModel.fromjson(Map json) {
    List itemsJSON = json['items'];
    List<OrderInfoModel> items = [];
    itemsJSON.forEach((element) {
      items.add(OrderInfoModel.fromjson(element));
    });

    return OrderListModel(
      counts: json["counts"],
      pageSize: json["pageSize"],
      pages: json["pages"],
      page: json["page"],
      items: items,
    );
  }
}

/// 订单基本信息
class OrderInfoModel {
  /// 订单id
  final String? id;

  /// 订单创建时间
  final String? createTime;

  /// 订单状态
  final int? orderState;

  /// 支付方式
  final int? payType;

  /// 付款截止的秒数
  final int? countdown;

  /// 支付渠道
  final int? payChannel;

  /// 支付方式
  final int? deliveryTimeType;

  /// 支付截止日期
  final String? payLatestTime;

  /// 商品总数量
  final int? totalNum;

  /// 邮费
  final String? postFee;

  /// 金额合计
  final String? totalMoney;

  /// 实付款
  final String? payMoney;

  /// 收货人
  final String? receiverContact;

  /// 收货人手机号
  final String? receiverMobile;

  /// 收货地址
  final String? receiverAddress;

  /// 订单结束时间
  final String? endTime;

  /// 订单关闭时间
  final String? closeTime;

  /// 评价时间
  final String? evaluationTime;

  /// 预计送达时间
  final String? arrivalEstimatedTime;

  /// 订单商品信息
  final List<OrderSkuModel>? skus;

  OrderInfoModel({
    this.id,
    this.createTime,
    this.orderState,
    this.payType,
    this.countdown,
    this.payChannel,
    this.deliveryTimeType,
    this.payLatestTime,
    this.totalNum,
    this.postFee,
    this.totalMoney,
    this.payMoney,
    this.receiverContact,
    this.receiverMobile,
    this.receiverAddress,
    this.endTime,
    this.closeTime,
    this.evaluationTime,
    this.arrivalEstimatedTime,
    this.skus,
  });

  factory OrderInfoModel.fromjson(Map json) {
    List skusJSON = json['skus'];
    List<OrderSkuModel> skus = [];
    skusJSON.forEach((element) {
      skus.add(OrderSkuModel.fromjson(element));
    });

    return OrderInfoModel(
      id: json["id"],
      createTime: json["createTime"],
      orderState: json["orderState"],
      payType: json["payType"],
      countdown: json["countdown"],
      payChannel: json["payChannel"],
      deliveryTimeType: json["deliveryTimeType"],
      payLatestTime: json["payLatestTime"],
      totalNum: json["totalNum"],
      postFee: json["postFee"].toString(),
      totalMoney: json["totalMoney"].toString(),
      payMoney: json["payMoney"].toString(),
      receiverContact: json["receiverContact"],
      receiverMobile: json["receiverMobile"],
      receiverAddress: json["receiverAddress"],
      endTime: json["endTime"],
      closeTime: json["closeTime"],
      evaluationTime: json["evaluationTime"],
      arrivalEstimatedTime: json["arrivalEstimatedTime"],
      skus: skus,
    );
  }
}

/// 订单商品信息
class OrderSkuModel {
  final String? id;
  final String? spuId;
  final String? name;
  final int? quantity;
  final String? image;
  final String? realPay;
  final String? curPrice;
  final String? totalMoney;
  final String? attrsText;

  OrderSkuModel({
    this.id,
    this.spuId,
    this.name,
    this.quantity,
    this.image,
    this.realPay,
    this.curPrice,
    this.totalMoney,
    this.attrsText,
  });

  factory OrderSkuModel.fromjson(Map json) {
    return OrderSkuModel(
      id: json["id"],
      spuId: json["spuId"],
      name: json["name"],
      quantity: json["quantity"],
      image: json["image"],
      realPay: json["realPay"].toString(),
      curPrice: json["curPrice"].toString(),
      totalMoney: json["totalMoney"].toString(),
      attrsText: json["attrsText"],
    );
  }
}

/// 订单结算
class OrderSettlementModel {
  /// 收货地址
  final List<UserAddress>? userAddresses;

  /// 结算商品
  final List<OrderSettlementGoodsModel>? goods;

  /// 结算金额
  final OrderSettlementSummaryModel? summary;

  OrderSettlementModel({this.userAddresses, this.goods, this.summary});

  factory OrderSettlementModel.fromjson(Map json) {
    // 收货地址
    List? userAddressesJSON = json['userAddresses'];
    List<UserAddress> userAddresses = [];
    userAddressesJSON?.forEach((element) {
      userAddresses.add(UserAddress.fromjson(element));
    });
    // 结算商品
    List? goodsJSON = json['goods'];
    List<OrderSettlementGoodsModel> goods = [];
    goodsJSON?.forEach((element) {
      goods.add(OrderSettlementGoodsModel.fromjson(element));
    });
    // 结算金额
    OrderSettlementSummaryModel summary = OrderSettlementSummaryModel.fromjson(json['summary']);

    return OrderSettlementModel(
      userAddresses: userAddresses,
      goods: goods,
      summary: summary,
    );
  }
}

/// 订单结算-商品
class OrderSettlementGoodsModel {
  /// id
  final String? id;

  /// 名称
  final String? name;

  /// 图片
  final String? picture;

  /// 数量
  final int? count;

  /// SKU ID
  final String? skuId;

  /// 规格字符串
  final String? attrsText;

  /// 原单价
  final String? price;

  /// 实付单价
  final String? payPrice;

  /// 原价小计
  final String? totalPrice;

  /// 实付小计
  final String? totalPayPrice;

  OrderSettlementGoodsModel({
    this.id,
    this.name,
    this.picture,
    this.count,
    this.skuId,
    this.attrsText,
    this.price,
    this.payPrice,
    this.totalPrice,
    this.totalPayPrice,
  });

  factory OrderSettlementGoodsModel.fromjson(Map<String, dynamic> json) {
    return OrderSettlementGoodsModel(
      id: json["id"],
      name: json["name"],
      picture: json["picture"],
      count: json["count"],
      skuId: json["skuId"],
      attrsText: json["attrsText"],
      price: json["price"].toString(),
      payPrice: json["payPrice"].toString(),
      totalPrice: json["totalPrice"].toString(),
      totalPayPrice: json["totalPayPrice"].toString(),
    );
  }
}

/// 订单结算-金额
class OrderSettlementSummaryModel {
  /// 结算商品总数量
  final int? goodsCount;

  ///  结算总价
  final String? totalPrice;

  /// 结算优惠
  final String? discountPrice;

  /// 结算实付款 = 原价的总价 - 优惠的价格
  final String? totalPayPrice;

  /// 运费
  final String? postFee;

  OrderSettlementSummaryModel({
    this.goodsCount,
    this.totalPrice,
    this.discountPrice,
    this.totalPayPrice,
    this.postFee,
  });

  factory OrderSettlementSummaryModel.fromjson(Map<String, dynamic> json) {
    return OrderSettlementSummaryModel(
      goodsCount: json["goodsCount"],
      totalPrice: json["totalPrice"].toString(),
      totalPayPrice: json["totalPayPrice"].toString(),
      discountPrice: json["discountPrice"].toString(),
      postFee: json["postFee"].toString(),
    );
  }
}
