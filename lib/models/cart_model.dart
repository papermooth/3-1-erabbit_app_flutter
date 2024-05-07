/// 购物车总模型
class CartModel {
  /// 有效商品
  List<CartItemModel>? valids;

  /// 失效商品
  final List<CartItemModel>? invalids;

  CartModel({this.valids, this.invalids});

  factory CartModel.fromjson(Map json) {
    // 有效商品
    List validsJSON = json['valids'];
    List<CartItemModel> valids = [];
    validsJSON.forEach((element) {
      valids.add(CartItemModel.fromjson(element));
    });
    // 失效商品
    List invalidsJSON = json['invalids'];
    List<CartItemModel> invalids = [];
    invalidsJSON.forEach((element) {
      valids.add(CartItemModel.fromjson(element));
    });

    return CartModel(valids: valids, invalids: invalids);
  }
}

/// 购物车模型
class CartItemModel {
  /// SPU ID
  final String? id;

  /// SKU ID
  final String? skuId;

  /// 商品名称
  final String? name;

  /// 规格字符串
  final String? attrsText;

  /// 图片
  final String? picture;

  /// 原价
  final String? price;

  /// 数量：可变的，用于展示和修改数量
  int count;

  /// 库存
  final int? stock;

  /// 现价
  final String? nowPrice;

  /// 是否选中：可变的，用于展示和修改选中状态
  bool selected;

  /// 是否收藏
  final bool? isCollect;

  CartItemModel({
    this.id,
    this.skuId,
    this.name,
    this.attrsText,
    this.picture,
    this.price,
    this.count = 1,
    this.stock,
    this.nowPrice,
    this.selected = true,
    this.isCollect,
  });

  factory CartItemModel.fromjson(Map json) {
    return CartItemModel(
      id: json["id"],
      skuId: json["skuId"],
      name: json["name"],
      attrsText: json["attrsText"],
      picture: json["picture"],
      price: json["price"],
      count: json["count"],
      stock: json["stock"],
      nowPrice: json["nowPrice"],
      selected: json["selected"],
      isCollect: json["isCollect"],
    );
  }
}
