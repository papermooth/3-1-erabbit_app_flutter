import 'package:erabbit_app_flutter/models/home_model.dart';

/// 商品详情总模型
class GoodsDetailModel {
  /// 商品id
  final String? id;

  /// 名称
  final String? name;

  /// spu编码
  final String? spuCode;

  /// 描述
  final String? desc;

  /// 现价
  final String? price;

  /// 原价
  final String? oldPrice;

  /// 折扣信息，当折扣信息大于0时有效
  final double? discount;

  /// 库存
  final int? inventory;

  /// 轮播图数据
  final List? mainPictures;

  /// 品牌信息
  final HotBrandsModel? brand;

  /// 规格
  final List<GoodsSpecsModel>? specs;

  /// SKU
  final List<GoodsSkusModel>? skus;

  /// 用户地址
  final List<UserAddress>? userAddresses;

  /// 商品评价
  final EvaluationInfoModel? evaluationInfo;

  /// 同类推荐
  final List<CategoryGoodsModel>? similarProducts;

  /// 24小时热销
  final List<CategoryGoodsModel>? hotByDay;

  /// 图文详情
  final GoodsDetailsModel? details;

  /// 热门商品推荐
  final List<CategoryGoodsModel>? recommends;

  /// 是否收藏
  final bool? isCollect;

  GoodsDetailModel({
    this.id,
    this.name,
    this.spuCode,
    this.desc,
    this.price,
    this.oldPrice,
    this.discount,
    this.inventory,
    this.brand,
    this.mainPictures,
    this.specs,
    this.skus,
    this.evaluationInfo,
    this.similarProducts,
    this.hotByDay,
    this.details,
    this.userAddresses,
    this.isCollect,
    this.recommends,
  });

  factory GoodsDetailModel.fromJson(Map<dynamic, dynamic> json) {
    // 品牌
    HotBrandsModel brandsModel = HotBrandsModel.fromJson(json['brand']);

    // 规格
    List specsJSON = json['specs'];
    List<GoodsSpecsModel> specs = [];
    specsJSON.forEach((element) {
      specs.add(GoodsSpecsModel.fromjson(element));
    });

    // SKU
    List skusJSON = json['skus'];
    List<GoodsSkusModel> skus = [];
    skusJSON.forEach((element) {
      skus.add(GoodsSkusModel.fromjson(element));
    });

    // 用户地址：注意点 --> 如果用户未登录，地址数据为null，所以获取到的地址数据可以为空
    List? userAddressesJSON = json['userAddresses'];
    List<UserAddress> userAddresses = [];
    userAddressesJSON?.forEach((element) {
      userAddresses.add(UserAddress.fromjson(element));
    });

    // 评价
    EvaluationInfoModel evaluationInfoModel = EvaluationInfoModel.fromjson(json['evaluationInfo']);

    // 同类推荐
    List similarProductsJSON = json['similarProducts'];
    List<CategoryGoodsModel> similarProducts = [];
    similarProductsJSON.forEach((element) {
      similarProducts.add(CategoryGoodsModel.fromJson(element));
    });

    // 24小时热销
    List hotByDayJSON = json['hotByDay'];
    List<CategoryGoodsModel> hotByDay = [];
    hotByDayJSON.forEach((element) {
      hotByDay.add(CategoryGoodsModel.fromJson(element));
    });

    // 图文详情
    GoodsDetailsModel detailsModel = GoodsDetailsModel.fromjson(json['details']);

    // 热门商品推荐
    List recommendsJSON = json['recommends'];
    List<CategoryGoodsModel> recommends = [];
    recommendsJSON.forEach((element) {
      recommends.add(CategoryGoodsModel.fromJson(element));
    });

    return GoodsDetailModel(
      id: json['id'],
      name: json['name'],
      spuCode: json['spuCode'],
      desc: json['desc'],
      price: json['price'],
      oldPrice: json['oldPrice'],
      discount: json['discount'],
      inventory: json['inventory'],
      mainPictures: json['mainPictures'],
      brand: brandsModel,
      specs: specs,
      skus: skus,
      userAddresses: userAddresses,
      evaluationInfo: evaluationInfoModel,
      similarProducts: similarProducts,
      hotByDay: hotByDay,
      details: detailsModel,
      recommends: recommends,
      isCollect: json['isCollect'],
    );
  }
}

/// 商品规格
class GoodsSpecsModel {
  /// 规格名称
  final String? name;

  /// 规格值
  final List<GoodsSpecsValues>? values;

  GoodsSpecsModel({this.name, this.values});

  factory GoodsSpecsModel.fromjson(Map<String, dynamic> json) {
    // 规格值
    List valuesJSON = json['values'];
    List<GoodsSpecsValues> values = [];
    valuesJSON.forEach((element) {
      values.add(GoodsSpecsValues.fromjson(element));
    });

    return GoodsSpecsModel(
      name: json['name'],
      values: values,
    );
  }
}

/// 规格值
class GoodsSpecsValues {
  /// 名称
  final String? name;

  /// 图标
  final String? picture;

  /// 描述
  final String? desc;

  /// 选中和未选中状态：false 未选中、true 选中、默认未选中
  /// selected 是可变的，根据用户的交互行为设置选中和未选中
  /// selected 不能放在工厂构造函数中赋值，用户点击了规格时赋值
  bool selected;

  /// 禁用状态：false 未禁用、true 禁用、默认未禁用
  bool disable;

  GoodsSpecsValues({
    this.name,
    this.picture,
    this.desc,
    this.selected = false,
    this.disable= false,
  });

  factory GoodsSpecsValues.fromjson(Map<String, dynamic> json) {
    return GoodsSpecsValues(
      name: json['name'],
      picture: json['picture'],
      desc: json['desc'],
    );
  }
}

/// 商品SKU
class GoodsSkusModel {
  /// SKU id
  final String? id;

  /// SKU编码
  final String? skuCode;

  /// SKU现价
  final String? price;

  /// SKU原价
  final String? oldPrice;

  /// SKU库存
  final int? inventory;

  /// SKU规格
  final List<GoodsSkusSpecsModel>? specs;

  GoodsSkusModel({
    this.id,
    this.skuCode,
    this.price,
    this.oldPrice,
    this.inventory,
    this.specs,
  });

  factory GoodsSkusModel.fromjson(Map<String, dynamic> json) {
    // SKU规格
    List specsJSON = json['specs'];
    List<GoodsSkusSpecsModel> specs = [];
    specsJSON.forEach((element) {
      specs.add(GoodsSkusSpecsModel.fromjson(element));
    });

    return GoodsSkusModel(
      id: json['id'],
      skuCode: json['skuCode'],
      price: json['price'],
      oldPrice: json['oldPrice'],
      inventory: json['inventory'],
      specs: specs,
    );
  }
}

/// 商品SKU规格值
class GoodsSkusSpecsModel {
  /// 名称
  final String? name;

  /// 规格值
  final String? valueName;

  GoodsSkusSpecsModel({this.name, this.valueName});

  factory GoodsSkusSpecsModel.fromjson(Map<String, dynamic> json) {
    return GoodsSkusSpecsModel(
      name: json['name'],
      valueName: json['valueName'],
    );
  }
}

/// 用户地址
class UserAddress {
  /// 地址id
  final String? id;

  /// 收货人
  final String? receiver;

  /// 电话
  final String? contact;

  /// 省编码
  final String? provinceCode;

  /// 市编码
  final String? cityCode;

  /// 区编码
  final String? countyCode;

  /// 详细地址
  final String? address;

  /// 省市区地址
  final String? fullLocation;

  /// 是否默认地址
  final bool? isDefault;

  // /// 标识详情页选中的地址信息
  // final bool? selected;

  UserAddress({
    this.id,
    this.receiver,
    this.contact,
    this.provinceCode,
    this.cityCode,
    this.countyCode,
    this.address,
    this.fullLocation,
    this.isDefault,
    // this.selected,
  });

  factory UserAddress.fromjson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['id'],
      receiver: json['receiver'],
      contact: json['contact'],
      provinceCode: json['provinceCode'],
      cityCode: json['cityCode'],
      countyCode: json['countyCode'],
      address: json['address'],
      fullLocation: json['fullLocation'],
      isDefault: json['isDefault'] == 0 ? true : false,
      // selected: json['selected'],
    );
  }
}

/// 商品评价
class EvaluationInfoModel {
  /// 评价id
  final String? id;

  // 商品商品的订单信息
  final EvaluationOrderInfo? orderInfo;

  /// 评价用户信息
  final EvaluationMember? member;

  /// 评价分数
  final int? score;

  /// 评价内容
  final String? content;

  /// 评价图片
  final List? pictures;

  /// 评价量
  final int? praiseCount;

  /// 好评度
  final int? praisePercent;

  /// 评价时间
  final String? createTime;

  EvaluationInfoModel({
    this.id,
    this.orderInfo,
    this.member,
    this.score,
    this.content,
    this.pictures,
    this.praiseCount,
    this.praisePercent,
    this.createTime,
  });

  factory EvaluationInfoModel.fromjson(Map<String, dynamic> json) {
    // 商品订单信息
    EvaluationOrderInfo orderInfo = EvaluationOrderInfo.fromjson(json['orderInfo']);

    // 评价用户信息
    EvaluationMember member = EvaluationMember.fromjson(json['member']);

    return EvaluationInfoModel(
      id: json['id'],
      orderInfo: orderInfo,
      member: member,
      score: json['score'],
      content: json['content'],
      pictures: json['pictures'],
      praiseCount: json['praiseCount'],
      praisePercent: json['praisePercent'],
      createTime: json['createTime'],
    );
  }
}

class EvaluationOrderInfo {
  /// 商品数量
  final int? quantity;

  /// 商品规格
  final List<GoodsSkusSpecsModel>? specs;

  /// 下单时间
  final String? createTime;

  EvaluationOrderInfo({this.quantity, this.specs, this.createTime});

  factory EvaluationOrderInfo.fromjson(Map<String, dynamic> json) {
    List specsJSON = json['specs'];
    List<GoodsSkusSpecsModel> specs = [];
    specsJSON.forEach((element) {
      specs.add(GoodsSkusSpecsModel.fromjson(element));
    });

    return EvaluationOrderInfo(
      quantity: json['quantity'],
      specs: specs,
      createTime: json['createTime'],
    );
  }
}

/// 评价用户信息
class EvaluationMember {
  /// 用户id
  final String? id;

  /// 用户账号
  final String? account;

  /// 用户头像
  final String? avatar;

  EvaluationMember({this.id, this.account, this.avatar});

  factory EvaluationMember.fromjson(Map<String, dynamic> json) {
    return EvaluationMember(
      id: json['id'],
      account: json['account'],
      avatar: json['avatar'],
    );
  }
}

/// 商品详情：属性和图文
class GoodsDetailsModel {
  /// 详情属性
  final List<GoodsDetailsPropertiesModel>? properties;

  /// 详情图文
  final List? pictures;

  GoodsDetailsModel({this.properties, this.pictures});

  factory GoodsDetailsModel.fromjson(Map<String, dynamic> json) {
    // 详情属性
    List propertiesJSON = json['properties'];
    List<GoodsDetailsPropertiesModel> properties = [];
    propertiesJSON.forEach((element) {
      properties.add(GoodsDetailsPropertiesModel.fromjson(element));
    });

    return GoodsDetailsModel(
      properties: properties,
      pictures: json['pictures'],
    );
  }
}

/// 商品详情属性
class GoodsDetailsPropertiesModel {
  /// 属性名称
  final String? name;

  /// 属性值
  final String? value;

  GoodsDetailsPropertiesModel({this.name, this.value});

  factory GoodsDetailsPropertiesModel.fromjson(Map<String, dynamic> json) {
    return GoodsDetailsPropertiesModel(
      name: json['name'],
      value: json['value'],
    );
  }
}
