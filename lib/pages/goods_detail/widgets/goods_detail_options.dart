import 'package:erabbit_app_flutter/models/goods_detail_model.dart';
import 'package:erabbit_app_flutter/pages/goods_detail/widgets/goods_detail_address.dart';
import 'package:erabbit_app_flutter/pages/goods_detail/widgets/goods_specs_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 不能是私有的，因为需要再其他组件使用这个key获取该组件的状态
GlobalKey<_GoodsDetailOptionsWidgetState> goodsDetailOptionsKey = GlobalKey(debugLabel: 'goodsDetailOptionsKey');

class GoodsDetailOptionsWidget extends StatefulWidget {
  GoodsDetailOptionsWidget({
    Key? key,
    this.goodsDetailModel,
  }) : super(key: key);

  /// 商品详情总模型
  final GoodsDetailModel? goodsDetailModel;

  @override
  _GoodsDetailOptionsWidgetState createState() => _GoodsDetailOptionsWidgetState();
}

class _GoodsDetailOptionsWidgetState extends State<GoodsDetailOptionsWidget> {
  String? _showSpecsStr;

  /// 收货地址
  UserAddress? _userAddress;

  @override
  void initState() {
    // 遍历用户所有的收货地址，取出默认地址
    _getUserDefaultAddress(widget.goodsDetailModel!.userAddresses);
    super.initState();
  }

  /// 遍历用户所有的收货地址，取出默认地址
  /// 用户可以没有地址，如果无地址，则服务端返回的userAddresses字段为空
  _getUserDefaultAddress(List<UserAddress>? userAddresses) {
    userAddresses?.forEach((UserAddress userAddress) {
      if (userAddress.isDefault!) {
        _userAddress = userAddress;
        return;
      }
    });
  }

  /// 展示商品规格弹窗的公共方法
  showGoodsSpecsCupertinoModalPopup(SpecsActionType type) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        // 弹窗的内容：需要自定义
        return GoodsSpecsWidget(
          type: type,
          goodsDetailModel: widget.goodsDetailModel,
          specsStrCallBack: (String? showSpecsStr) {
            setState(() {
              _showSpecsStr = showSpecsStr;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 20.0, right: 20.0),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            GestureDetector(
              onTap: () {
                // 展示商品规格弹窗：从屏幕底部向上弹出一个新的页面
                showGoodsSpecsCupertinoModalPopup(SpecsActionType.normal);
                // showCupertinoModalPopup(
                //   context: context,
                //   builder: (BuildContext context) {
                //     // 弹窗的内容：需要自定义
                //     return GoodsSpecsWidget(
                //       goodsDetailModel: widget.goodsDetailModel,
                //       specsStrCallBack: (String? showSpecsStr) {
                //         setState(() {
                //           _showSpecsStr = showSpecsStr;
                //         });
                //       },
                //     );
                //   },
                // );
              },
              child: Container(
                height: 44.0,
                alignment: Alignment.center,
                color: Colors.white,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '已选',
                            style: TextStyle(fontSize: 13.0, color: Color(0xFF898B94)),
                          ),
                          // 保证选项撑满剩余的中间的位置
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text(
                                _showSpecsStr ?? '请选择规格数量',
                                style: TextStyle(fontSize: 13.0, color: Color(0xFF262626)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: Image.asset('assets/arrow_right.png'),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 1.0, color: Color(0xFFF7F7F8)),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // 展示收货地址弹窗
                showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) {
                    return GoodsDetailAddressWidget(
                      userAddresses: widget.goodsDetailModel!.userAddresses,
                      userAddressCallBack: (UserAddress? userAddress) {
                        // 更新状态
                        setState(() {
                          _userAddress = userAddress;
                        });
                      },
                    );
                  },
                );
              },
              child: Container(
                height: 44.0,
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '送至',
                            style: TextStyle(fontSize: 13.0, color: Color(0xFF898B94)),
                          ),
                          // 保证选项撑满剩余的中间的位置
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text(
                                _userAddress != null ? _userAddress!.fullLocation! + _userAddress!.address! : '暂无地址',
                                style: TextStyle(fontSize: 13.0, color: Color(0xFF262626)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: Image.asset('assets/arrow_right.png'),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 1.0, color: Color(0xFFF7F7F8)),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                debugPrint('点击了服务');
              },
              child: Container(
                height: 44.0,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '服务',
                      style: TextStyle(fontSize: 13.0, color: Color(0xFF898B94)),
                    ),
                    // 保证选项撑满剩余的中间的位置
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          '无忧退 货快速退款 免费包邮',
                          style: TextStyle(fontSize: 13.0, color: Color(0xFF262626)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Image.asset('assets/arrow_right.png'),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
