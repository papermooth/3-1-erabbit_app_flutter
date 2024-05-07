import 'package:dio/dio.dart';
import 'package:erabbit_app_flutter/models/category_model.dart';
import 'package:erabbit_app_flutter/service/requests.dart';

class CategoryAPI {
  /// 一级分类
  static Future<List<PrimaryCategoryModel>> getPrimaryCategory() async {
    Response response = await XTXRequestManager().handleRequest('home/category/head/app', 'GET');
    List ret = response.data['result'];

    // 将一级分类字典列表转模型列表
    List<PrimaryCategoryModel> models = [];
    ret.forEach((element) {
      PrimaryCategoryModel primaryCategoryModel = PrimaryCategoryModel.fromJosn(element);
      models.add(primaryCategoryModel);
    });

    return models;
  }

  /// 二级分类
  /// id:一级分类id,必传
  static Future<SubCategoryModel> getSecondaryCategory(String id) async {
    String path = 'category?id=$id';
    Response response = await XTXRequestManager().handleRequest(path, 'GET');
    dynamic ret = response.data['result'];

    // 将一级分类对应的二级分类数据转模型数据
    SubCategoryModel subCategoryModel = SubCategoryModel.fromJosn(ret);

    return subCategoryModel;
  }
}
