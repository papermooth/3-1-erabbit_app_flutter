import 'package:dio/dio.dart';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:erabbit_app_flutter/models/goods_detail_model.dart';
import 'package:erabbit_app_flutter/models/order_payment_model.dart';
import 'package:erabbit_app_flutter/pages/goods_detail/widgets/goods_detail_bottom_bar.dart';
import 'package:erabbit_app_flutter/pages/order_payment/order_settlement_page.dart';
import 'package:erabbit_app_flutter/service/cart_api.dart';
import 'package:erabbit_app_flutter/service/order_payment_api.dart';
import 'package:erabbit_app_flutter/utils/powerset.dart';
import 'package:erabbit_app_flutter/widgets/custom_image.dart';
import 'package:erabbit_app_flutter/widgets/price_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

/// 区分商品规格弹窗不同的入口的
enum SpecsActionType {
  normal, // 点击'请选择规格'，展示'加入购物车'和'立即购买'
  addCart, // 点击'加入购物车'，展示'确定'
  buyNow, // 点击'立即购买'，展示'确定'
}

class GoodsSpecsWidget extends StatefulWidget {
  GoodsSpecsWidget({
    this.goodsDetailModel,
    this.specsStrCallBack,
    this.type,
  });

  /// 商品详情总模型
  final GoodsDetailModel? goodsDetailModel;

  /// 回调规格字符串
  final void Function(String? showSpecsStr)? specsStrCallBack;

  /// 记录商品规格弹窗的入口
  final SpecsActionType? type;

  @override
  _GoodsSpecsWidgetState createState() => _GoodsSpecsWidgetState();
}

class _GoodsSpecsWidgetState extends State<GoodsSpecsWidget> {
  /// 记录商品数量
  int _skuCount = 1;

  /// 未选中状态
  BoxDecoration _unselectedDecoration = BoxDecoration(
    color: Color(0xFFF6F6F6),
    border: Border.all(color: Color(0xFFF6F6F6), width: 0.5),
    borderRadius: BorderRadius.circular(13.0),
  );

  /// 未选中文字颜色
  Color _unselectedTextColor = Color(0xFF333333);

  /// 选中状态
  BoxDecoration _selectedDecoration = BoxDecoration(
    color: Colors.white,
    border: Border.all(color: Color(0xFFCF4444), width: 0.5),
    borderRadius: BorderRadius.circular(13.0),
  );

  /// 选中文字颜色
  Color _selectedTextColor = Color(0xFFCF4444);

  /// 禁用状态
  DottedDecoration _disableDecoration = DottedDecoration(
    shape: Shape.box, // 形状
    color: Color(0xFFCBCBCB), // 颜色
    strokeWidth: 0.5, // 宽度
    borderRadius: BorderRadius.circular(13.0), // 圆角
  );

  /// 禁用文字颜色
  Color _disableTextColor = Color(0xFFCBCBCB);

  /// 记录已选的规格
  List? _selectedSpecsValues;

  /// 记录规格路径字典
  Map _specsPathMap = {};

  /// 记录选中的SKU
  GoodsSkusModel? _selectedSku;

  /// 记录已选的规格字符串
  String? _selectedSpecsStr;

  /// 记录选择齐全的规格
  String? _showSpecsStr;

  @override
  void initState() {
    // 生成规格路径字典
    _specsPathMap = _getSpecsPathMap(widget.goodsDetailModel!.skus!);
    // 默认先做一次匹配，保证那些没有库存的规格组合默认禁用
    _matchSpecsPathMap(widget.goodsDetailModel!.specs!);

    super.initState();
  }

  /// 监听组件即将销毁的生命周期的方法
  @override
  void deactivate() {
    // 回调规格字符串
    if (widget.specsStrCallBack != null) {
      widget.specsStrCallBack!(_showSpecsStr);
    }

    super.deactivate();
  }

  /// 底部操作栏点击事件
  void _bottomBarOnTap(SpecsActionType type) async {
    // 校验规格
    // 遍历已选规格组合 ['蓝色', '', '中国']  ==> 提示"请选择尺寸"
    for (var i = 0; i < _selectedSpecsValues!.length; i++) {
      // 读取规格并判断是否是空字符串
      String sepcs = _selectedSpecsValues![i];
      // 如果规格是空字符串，提示缺少的规格的类型
      if (sepcs == '') {
        EasyLoading.showToast('请选择' + widget.goodsDetailModel!.specs![i].name!);
        return;
      }
    }

    // 区分加入购物车和立即购买的逻辑
    switch (type) {
      case SpecsActionType.addCart:
        // 添加购物车
        try {
          Map ret = await CartAPI.addCart(_selectedSku!.id!, _skuCount);
          debugPrint('添加购物车：$ret');

          // 同步购物车商品总数量
          // 一旦修改了value，ValueListenableBuilder就会重构内部组件
          totalCountNotifier?.value += _skuCount;

          // 关闭弹窗
          Navigator.of(context, rootNavigator: true).pop();

          EasyLoading.showToast('添加购物车成功');
        } on DioError catch (e) {
          EasyLoading.showToast(e.response!.data['message']);
        }

        break;
      case SpecsActionType.buyNow:
        // 发送立即购买请求：调用立即购买接口方法
        try {
          OrderSettlementModel settlementModel = await OrderPaymentAPI.orderBuyNow(_selectedSku!.id!, _skuCount);

          // 关闭弹窗
          Navigator.of(context, rootNavigator: true).pop();

          // 进入订单结算页面
          Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) {
            return OrderSettlementPage(orderSettlementModel: settlementModel);
          }));
        } on DioError catch (e) {
          EasyLoading.showToast(e.response!.data['message']);
        }
        break;
      default:
        break;
    }
  }

  /// 根据规格状态，读取选中、未选中、禁用状态
  dynamic _getDecoration(GoodsSpecsValues specsValue) {
    dynamic decoration;
    // 判断是否是禁用状态，如果是禁用状态，直接展示禁用状态，反之，再去判断是否是选中状态
    if (specsValue.disable) {
      decoration = _disableDecoration;
    } else {
      decoration = specsValue.selected ? _selectedDecoration : _unselectedDecoration;
    }

    return decoration;
  }

  /// 根据规格状态，读取选中、未选中、禁用文字颜色
  Color _getTextColor(GoodsSpecsValues specsValue) {
    Color color;
    if (specsValue.disable) {
      color = _disableTextColor;
    } else {
      color = specsValue.selected ? _selectedTextColor : _unselectedTextColor;
    }

    return color;
  }

  /// 匹配规格路径
  void _matchSpecsPathMap(List<GoodsSpecsModel> specs) {
    // 准备存放选中规格的列表：元素个数是规格类型的个数（specs的长度）
    _selectedSpecsValues = List.filled(specs.length, '', growable: true);
    // 获取已选中的规格
    for (var i = 0; i < specs.length; i++) {
      GoodsSpecsModel specsModel = specs[i];
      // 遍历规格对应的值
      specsModel.values!.forEach((GoodsSpecsValues specsValue) {
        if (specsValue.selected) {
          // 将选中状态的规格值存储到List中
          _selectedSpecsValues![i] = specsValue.name;
        }
      });
    }
    debugPrint('获取已选中的规格：$_selectedSpecsValues');

    // 根据已选的规格组合，生成规格路径key
    // 遍历所有的规格
    for (var i = 0; i < specs.length; i++) {
      GoodsSpecsModel specsModel = specs[i];
      specsModel.values!.forEach((GoodsSpecsValues specsValue) {
        // 复制一份已选规格列表：为了避免将来在生成规格路径key由于操作数据影响_selectedSpecsValues
        List selectedSpecsValuesTmp = List.from(_selectedSpecsValues!);
        // 注意点：已选的规格不需要组合的
        if (selectedSpecsValuesTmp.contains(specsValue.name)) return;
        // 使用已选的规格跟遍历出来的规格进行组合
        selectedSpecsValuesTmp[i] = specsValue.name;
        debugPrint('当前要匹配的规格组合：$selectedSpecsValuesTmp');

        // 生成规格路径key [蓝色, 30cm, ''] ==>  [蓝色, 30cm] ==> '蓝色*30cm'
        // 去除空字符串 [蓝色, 30cm]
        selectedSpecsValuesTmp.removeWhere((element) => element == '');
        // join('*') [蓝色, 30cm] ==> '蓝色*30cm'
        String selectedKey = selectedSpecsValuesTmp.join('*');
        debugPrint('规格路径key：$selectedKey');

        // 匹配规格路径字典
        specsValue.disable = !_specsPathMap.containsKey(selectedKey);
      });
    }

    // 展示选中的SKU信息
    // 获取选中的SKU
    // 判断所有类型的规格是否选择齐全：判断已选的规格组合列表中是否有空字符串，如果没有空字符串就表示规格选择齐全
    if (!_selectedSpecsValues!.contains('')) {
      // 使用已选的规格组合去规格路径字典中读取对应的SKU
      // [蓝色, 10cm, 中国] ==> '蓝色*10cm*中国'
      String key = _selectedSpecsValues!.join('*');
      _selectedSku = _specsPathMap[key][0];
      debugPrint('获取选中的SKU：${_selectedSku!.id}');

      // 规格选择齐全：生成规格字符串  ['蓝色', '10cm', '中国'] ==> '蓝色 10cm 中国'
      _showSpecsStr = _selectedSpecsValues!.join(' ');
    } else {
      // 规格选择不齐全
      _showSpecsStr = null;
    }

    // 如果没有选择任何规格，则_selectedSku = null
    if (_selectedSpecsValues!.join('').length == 0) {
      _selectedSku = null;
    }

    // 展示已选规格：['蓝色', '10cm', ''] ==> ['蓝色', '10cm'] ==> 使用空格分隔列表 ==> '蓝色 10cm'
    List selectedSpecsValuesTmp = List.from(_selectedSpecsValues!);
    selectedSpecsValuesTmp.removeWhere((element) => element == '');
    String selectedSpecsStr = selectedSpecsValuesTmp.join(' ');
    // 判断是否选择了规格，根据判断结果，展示规格还是提示
    if (selectedSpecsStr.length != 0) {
      _selectedSpecsStr = '已选: ' + selectedSpecsStr;
    } else {
      _selectedSpecsStr = null;
    }
  }

  /// 生成规格路径字典
  Map _getSpecsPathMap(List<GoodsSkusModel> skus) {
    Map pathMap = {};
    // 提取有库存的SKU规格
    // 遍历skus
    skus.forEach((GoodsSkusModel sku) {
      List skuSpecs = [];
      // 取出有库存的SKU
      if (sku.inventory! > 0) {
        // 取出有库存的SKU的规格，存放到List中
        sku.specs!.forEach((GoodsSkusSpecsModel skusSpecsModel) {
          skuSpecs.add(skusSpecsModel.valueName!);
        });
        debugPrint('有库存的SKU规格: $skuSpecs');

        // 计算有库存规格幂集：幂集算法库
        List<List> skuSpecsPowerset = powerset(skuSpecs).toList();
        debugPrint('有库存规格幂集: $skuSpecsPowerset');

        // 生成有库存的规格路径字典
        skuSpecsPowerset.forEach((List subSet) {
          if (subSet.length != 0) {
            // 将规格组合转成字典的key: ['蓝色', '10cm'] ==> '蓝色*10cm'
            String key = subSet.join('*');
            if (!pathMap.containsKey(key)) {
              // 如果key不存在，就新建记录
              pathMap[key] = [sku];
            } else {
              // 如果key存在，就追加记录
              pathMap[key].add(sku);
            }
          }
        });
      }
    });

    debugPrint('有库存的规格路径字典: $pathMap');

    return pathMap;
  }

  /// 构建商品规格值
  List<Widget> _buildGoodsSpecsValues(List<GoodsSpecsValues> specsValues) {
    List<Widget> items = [];

    // 遍历values,并且生成流式布局的元素
    specsValues.forEach((GoodsSpecsValues specsValue) {
      items.add(
        GestureDetector(
          onTap: () {
            // 禁用状态的规格不响应点击事件
            if (specsValue.disable) return;

            // 遍历规格
            specsValues.forEach((GoodsSpecsValues element) {
              // 如果被点击的规格未选中，则选中该规格，其他规格不选中
              // 如果被点击的规格已选中，则取消选中该规格，其他规格不选中
              if (element.name == specsValue.name) {
                element.selected = !specsValue.selected;
              } else {
                element.selected = false;
              }
            });

            // 匹配规格路径
            _matchSpecsPathMap(widget.goodsDetailModel!.specs!);

            // 更新状态
            setState(() {});
          },
          child: Container(
            padding: EdgeInsets.only(left: 15.0, top: 6.0, right: 15.0, bottom: 6.0),
            decoration: _getDecoration(specsValue),
            child: Text(
              specsValue.name!,
              style: TextStyle(
                color: _getTextColor(specsValue),
                fontSize: 14.0,
                // 统一中文和英文字符的行高：保证规格盒子的高度一致
                height: 1.0,
              ),
            ),
          ),
        ),
      );
    });

    return items;
  }

  /// 构建商品规格
  List<Widget> _buildGoodsSpecs(List<GoodsSpecsModel> specs) {
    List<Widget> items = [];

    // 遍历specs,并且纵向布局商品规格(名称、值)
    specs.forEach((GoodsSpecsModel specsModel) {
      items.add(
        Padding(
          padding: EdgeInsets.only(bottom: 10.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 规格名称
                Text(specsModel.name!, style: TextStyle(color: Color(0xFF333333), fontSize: 14.0)),
                // 规格值：Wrap(流式布局)
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Wrap(
                    // 元素间的间距
                    spacing: 14.0,
                    // 行间距（换行之后才有的）
                    runSpacing: 14.0,
                    children: _buildGoodsSpecsValues(specsModel.values!),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });

    return items;
  }

  /// 底部操作栏
  Widget _buildBottomBar() {
    Widget ret;

    if (widget.type == SpecsActionType.normal) {
      // 如果是点击'请选择规格'进入的规格弹窗，展示'加入购物车'和'立即购买'
      ret = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                _bottomBarOnTap(SpecsActionType.addCart);
              },
              child: Container(
                height: 40.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.0),
                  gradient: LinearGradient(colors: [Color(0xffFFA868), Color(0xffFF9240)]),
                ),
                child: Text(
                  '加入购物车',
                  style: TextStyle(fontSize: 13.0, color: Colors.white),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 20.0,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                _bottomBarOnTap(SpecsActionType.buyNow);
              },
              child: Container(
                height: 40.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.0),
                  gradient: LinearGradient(colors: [Color(0xff3CCEAF), Color(0xff27BA9B)]),
                ),
                child: Text(
                  '立即购买',
                  style: TextStyle(fontSize: 13.0, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // 如果是点击'加入购物车'和'立即购买'进入的规格弹窗，展示'确定'
      ret = GestureDetector(
        onTap: () {
          _bottomBarOnTap(widget.type!);
        },
        child: Container(
          height: 40.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            gradient: LinearGradient(colors: [Color(0xFF00D2AE), Color(0xFF00BD9A)]),
          ),
          child: Text(
            '确定',
            style: TextStyle(color: Colors.white, fontSize: 14.0),
          ),
        ),
      );
    }

    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.7,
      color: Colors.white,
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(left: 10.0, top: 18.0, right: 10.0),
                    child: Column(
                      children: [
                        // 商品信息
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // 图片
                            CustomImage(
                              url: widget.goodsDetailModel!.mainPictures![0],
                              width: 100.0,
                              height: 100.0,
                            ),
                            // 价格 + 已选规格属性
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 现价和原价
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        // 现价
                                        PriceWidget(
                                          price: _selectedSku != null
                                              ? _selectedSku!.price!
                                              : widget.goodsDetailModel!.price!,
                                          symbolFontSize: 12.0,
                                          integerFontSize: 20.0,
                                          decimalFontSize: 14.0,
                                        ),
                                        // 原价
                                        Padding(
                                          padding: EdgeInsets.only(left: 6.0),
                                          child: Text(
                                            '¥' +
                                                (_selectedSku != null
                                                    ? _selectedSku!.oldPrice!
                                                    : widget.goodsDetailModel!.oldPrice!),
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: Color(0xFF555555),
                                              decoration: TextDecoration.lineThrough,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    // 已选规格属性
                                    Padding(
                                      padding: EdgeInsets.only(top: 6.0),
                                      child: Text(
                                        _selectedSpecsStr ?? '请选择规格属性',
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          color: Color(0xFF555555),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        // 规格信息
                        Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: Container(
                            // height: 200.0,
                            // color: Colors.blue,
                            padding: EdgeInsets.only(left: 6.0, right: 6.0),
                            child: Column(
                              children: _buildGoodsSpecs(widget.goodsDetailModel!.specs!),
                            ),
                          ),
                        ),
                        // 商品数量
                        Padding(
                          padding: EdgeInsets.only(top: 20.0, bottom: 30.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '数量',
                                style: TextStyle(color: Color(0xFF333333), fontSize: 14.0),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      if (_skuCount <= 1) return;
                                      setState(() {
                                        _skuCount--;
                                      });
                                    },
                                    icon: Image.asset(
                                      _skuCount != 1 ? 'assets/price_jian_on.png' : 'assets/price_jian.png',
                                    ),
                                  ),
                                  Container(
                                    width: 40.0,
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(vertical: 1.0),
                                    color: Color(0xFFF6F6F6),
                                    child: Text(
                                      _skuCount.toString(),
                                      style: TextStyle(color: Color(0xFF333333), fontSize: 14.0),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _skuCount++;
                                      });
                                    },
                                    icon: Image.asset('assets/price_jia_on.png'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // 底部操作栏
              Container(
                height: 60.0 + MediaQuery.of(context).padding.bottom,
                child: Column(
                  children: [
                    Divider(height: 1.0, color: Color(0xFFEDEDED)),
                    Container(
                      padding: EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Padding(
                        padding: EdgeInsets.only(top: 9.0),
                        child: _buildBottomBar(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // 关闭按钮
          Positioned(
            top: 0.0,
            right: 0.0,
            child: IconButton(
              icon: Image.asset('assets/guanbi.png'),
              onPressed: () {
                // 关闭商品规格弹窗
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
