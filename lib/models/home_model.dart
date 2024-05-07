/// 首页总数据模型
class HomeModel {
  // 1. 模型属性：存储并读取数据
  /// 图片轮播图
  final List<ImageBannersModel>? imageBanners;

  /// 分类快捷入口
  final List<CategoryGridsModel>? categoryGrids;

  /// 热门推荐
  final List<HotRecommendsModel>? hotRecommends;

  /// 新鲜好物
  final List<FreshGoodsModel>? freshGoods;

  /// 热门品牌
  final List<HotBrandsModel>? hotBrands;

  /// 热门专题
  final List<HotProjectsModel>? projects;

  /// 推荐分类商品
  final List<CategoryBannersModel>? categoryBanners;

  // 2. 类名构造函数：实例化模型对象
  HomeModel({
    this.imageBanners,
    this.categoryGrids,
    this.hotRecommends,
    this.freshGoods,
    this.hotBrands,
    this.projects,
    this.categoryBanners,
  });

  // 3. 命名工厂构造函数：将网络数据(字典数据)转模型数据并返回
  // json：网络数据(字典数据)
  factory HomeModel.fromJson(Map<String, dynamic> json) {
    // 将图片轮播图字典列表转模型列表
    // 1. 获取图片轮播图字典列表
    List imageBannersJSON = json['imageBanners'];
    // 2. 字典列表转模型列表(element:图片轮播图字典数据)
    List<ImageBannersModel> imageBanners = [];
    imageBannersJSON.forEach((element) {
      imageBanners.add(ImageBannersModel.fromJson(element));
    });

    // 将推荐分类商品字典列表转模型列表
    List categoryBannersJSON = json['categoryBanners'];
    List<CategoryBannersModel> categoryBanners = [];
    categoryBannersJSON.forEach((element) {
      categoryBanners.add(CategoryBannersModel.fromJson(element));
    });

    // 将分类快捷入口的字典列表转模型列表
    List categoryGridsJSON = json['categoryGrids'];
    List<CategoryGridsModel> categoryGrids = [];
    categoryGridsJSON.forEach((element) {
      categoryGrids.add(CategoryGridsModel.fromJson(element));
    });

    // 将人气推荐的字典列表转模型列表
    List hotRecommendsJSON = json['hotRecommends'];
    List<HotRecommendsModel> hotRecommends = [];
    hotRecommendsJSON.forEach((element) {
      hotRecommends.add(HotRecommendsModel.fromJson(element));
    });

    // 将新鲜好物的字典列表转模型列表
    List freshGoodsJSON = json['freshGoods'];
    List<FreshGoodsModel> freshGoods = [];
    freshGoodsJSON.forEach((element) {
      freshGoods.add(FreshGoodsModel.fromJson(element));
    });

    // 将热门品牌的字典列表转模型列表
    List hotBrandsJSON = json['hotBrands'];
    List<HotBrandsModel> hotBrands = [];
    hotBrandsJSON.forEach((element) {
      hotBrands.add(HotBrandsModel.fromJson(element));
    });

    // 将热门专题的字典列表转模型列表
    List projectsJSON = json['projects'];
    List<HotProjectsModel> projects = [];
    projectsJSON.forEach((element) {
      projects.add(HotProjectsModel.fromJson(element));
    });

    return HomeModel(
      imageBanners: imageBanners,
      categoryGrids: categoryGrids,
      hotRecommends: hotRecommends,
      freshGoods: freshGoods,
      hotBrands: hotBrands,
      projects: projects,
      categoryBanners: categoryBanners,
    );
  }
}

/// 图片轮播图
class ImageBannersModel {
  // 1. 属性
  /// id
  final String? id;

  /// 图片地址
  final String? imgUrl;

  /// 跳转链接
  final String? hrefUrl;

  /// 类型
  final String? type;

  // 2. 构造函数
  ImageBannersModel({this.id, this.imgUrl, this.hrefUrl, this.type});

  // 3. 工厂构造函数
  // json：图片轮播图的网络数据(字典数据)
  factory ImageBannersModel.fromJson(Map<String, dynamic> json) {
    return ImageBannersModel(
      id: json['id'],
      imgUrl: json['imgUrl'],
      hrefUrl: json['hrefUrl'],
      type: json['type'],
    );
  }
}

/// 推荐分类商品
class CategoryBannersModel {
  // 1. 属性
  /// 分类id
  final String? id;

  /// 分类名称
  final String? name;

  /// 分类图片
  final String? picture;

  /// 分类商品
  final List<CategoryGoodsModel>? goods;

  // 2. 构造函数
  CategoryBannersModel({this.id, this.name, this.picture, this.goods});

  // 3. 工厂构造函数
  // json：推荐分类商品字典数据
  factory CategoryBannersModel.fromJson(Map<String, dynamic> json) {
    // 将推荐的分类商品子模型嵌套到CategoryBannersModel
    // 将分类商品字典列表转模型列表
    List goodsJSON = json['goods'];
    List<CategoryGoodsModel> goods = [];
    goodsJSON.forEach((element) {
      goods.add(CategoryGoodsModel.fromJson(element));
    });

    return CategoryBannersModel(
      id: json['id'],
      name: json['name'],
      picture: json['picture'],
      goods: goods,
    );
  }
}

/// 推荐分类商品的子模型
class CategoryGoodsModel {
  final String? id;
  final String? name;
  final String? desc;
  final String? price;
  final String? picture;

  CategoryGoodsModel({this.id, this.name, this.desc, this.price, this.picture});

  factory CategoryGoodsModel.fromJson(Map<String, dynamic> json) {
    return CategoryGoodsModel(
      id: json['id'],
      name: json['name'],
      desc: json['desc'],
      price: json['price'],
      picture: json['picture'],
    );
  }
}

/// 分类快捷入口数据模型
class CategoryGridsModel {
  /// 分类id
  final String? id;

  /// 分类名称
  final String? name;

  /// 分类图标
  final String? picture;

  CategoryGridsModel({this.id, this.name, this.picture});

  factory CategoryGridsModel.fromJson(Map<String, dynamic> json) {
    return CategoryGridsModel(
      id: json['id'],
      name: json['name'],
      picture: json['picture'],
    );
  }
}

/// 人气推荐数据模型
class HotRecommendsModel {
  /// 左侧图片
  final String? leftIcon;

  /// 右侧图片
  final String? rightIcon;

  /// 商品标题
  final String? title;

  /// 商品副标题
  final String? caption;

  HotRecommendsModel({this.leftIcon, this.rightIcon, this.title, this.caption});

  /// 字典数据转模型数据的工厂方法
  factory HotRecommendsModel.fromJson(Map<String, dynamic> json) {
    return HotRecommendsModel(
      leftIcon: json['leftIcon'],
      rightIcon: json['rightIcon'],
      title: json['title'],
      caption: json['caption'],
    );
  }
}

/// 新鲜好物数据模型
class FreshGoodsModel {
  /// id
  final String? id;

  /// 商品名称
  final String? name;

  /// 商品描述
  final String? desc;

  /// 商品价格
  final String? price;

  /// 商品图片
  final String? picture;

  FreshGoodsModel({this.id, this.name, this.desc, this.price, this.picture});

  factory FreshGoodsModel.fromJson(Map<String, dynamic> json) {
    return FreshGoodsModel(
      id: json['id'],
      name: json['name'],
      desc: json['desc'],
      price: json['price'],
      picture: json['picture'],
    );
  }
}

/// 热门品牌数据模型
class HotBrandsModel {
  /// id
  final String? id;

  /// 品牌名称
  final String? name;

  /// 品牌英文名称
  final String? nameEn;

  /// 品牌logo
  final String? logo;

  /// 品牌图片
  final String? picture;

  /// 品牌描述
  final String? desc;

  /// 品牌产地
  final String? place;

  HotBrandsModel({
    this.id,
    this.name,
    this.nameEn,
    this.logo,
    this.picture,
    this.desc,
    this.place,
  });

  factory HotBrandsModel.fromJson(Map<String, dynamic> json) {
    return HotBrandsModel(
      id: json['id'],
      name: json['name'],
      nameEn: json['nameEn'],
      logo: json['logo'],
      picture: json['picture'],
      desc: json['desc'],
      place: json['place'],
    );
  }
}

/// 热门专题数据模型
class HotProjectsModel {
  /// id
  final String? id;

  /// 专题图片
  final String? cover;

  /// 专题标题
  final String? title;

  /// 最低价
  final String? lowestPrice;

  /// 专题收藏数
  final String? collectNum;

  /// 专题访问数
  final String? viewNum;

  HotProjectsModel({
    this.id,
    this.cover,
    this.title,
    this.lowestPrice,
    this.collectNum,
    this.viewNum,
  });

  factory HotProjectsModel.fromJson(Map<String, dynamic> json) {
    return HotProjectsModel(
      id: json['id'],
      cover: json['cover'],
      title: json['title'],
      lowestPrice: json['lowestPrice'].toString(),
      collectNum: json['collectNum'].toString(),
      viewNum: json['viewNum'].toString(),
    );
  }
}
