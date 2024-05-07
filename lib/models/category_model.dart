import 'package:erabbit_app_flutter/models/home_model.dart';

/// 一级分类
class PrimaryCategoryModel {
  /// 一级分类id
  final String? id;

  /// 一级分类名称
  final String? name;

  /// 一级分类图标
  final String? icon;

  PrimaryCategoryModel({this.id, this.name, this.icon});

  factory PrimaryCategoryModel.fromJosn(Map<String, dynamic> json) {
    return PrimaryCategoryModel(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
    );
  }
}

/// 二级分类总模型 
class SubCategoryModel {
  /// 一级分类id
  final String? id;

  /// 一级分类名称
  final String? name;

  /// 一级分类对应的二级分类
  final List<SecondaryCategoryModel>? children;

  SubCategoryModel({this.id, this.name, this.children});

  factory SubCategoryModel.fromJosn(Map<String, dynamic> json) {
    List childrenJSON = json['children'];

    List<SecondaryCategoryModel> children = [];
    childrenJSON.forEach((element) {
      children.add(SecondaryCategoryModel.fromJosn(element));
    });

    return SubCategoryModel(
      id: json['id'],
      name: json['name'],
      children: children,
    );
  }
}

// 二级分类
class SecondaryCategoryModel {
  /// 二级分类id
  final String? id;

  /// 二级分类名称
  final String? name;

  /// 二级分类图标
  final String? picture;

  /// 二级分类对应的商品
  final List<CategoryGoodsModel>? goods;

  SecondaryCategoryModel({this.id, this.name, this.picture, this.goods});

  factory SecondaryCategoryModel.fromJosn(Map<String, dynamic> json) {
    List goodsJSON = json['goods'];

    List<CategoryGoodsModel> goods = [];
    goodsJSON.forEach((element) {
      goods.add(CategoryGoodsModel.fromJson(element));
    });

    return SecondaryCategoryModel(
      id: json['id'],
      name: json['name'],
      picture: json['picture'],
      goods: goods,
    );
  }
}