import 'package:erabbit_app_flutter/models/goods_detail_model.dart';
import 'package:erabbit_app_flutter/pages/order_payment/order_settlement_page.dart';
import 'package:flutter/material.dart';

class GoodsDetailAddressWidget extends StatefulWidget {
  GoodsDetailAddressWidget({
    this.userAddresses,
    this.userAddressCallBack,
  });

  /// 收货地址
  final List<UserAddress>? userAddresses;

  /// 回调收货地址的函数
  final void Function(UserAddress? userAddress)? userAddressCallBack;

  @override
  _GoodsDetailAddressWidgetState createState() => _GoodsDetailAddressWidgetState();
}

class _GoodsDetailAddressWidgetState extends State<GoodsDetailAddressWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.7,
      color: Colors.white,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.centerRight,
            children: [
              // 标题：配送至
              Container(
                alignment: Alignment.center,
                height: 40.0,
                width: MediaQuery.of(context).size.width,
                child: Text(
                  '配送至',
                  style: TextStyle(color: Color(0xFF333333), fontSize: 16.0),
                ),
              ),
              // 关闭按钮
              IconButton(
                icon: Image.asset('assets/guanbi.png'),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
            ],
          ),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView.builder(
                itemCount: widget.userAddresses?.length,
                itemBuilder: (BuildContext context, int index) {
                  UserAddress userAddress = widget.userAddresses![index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // 选择收货地址：回调收货地址
                          if (widget.userAddressCallBack != null) {
                            widget.userAddressCallBack!(userAddress);
                          } else {
                            // 使用ValueNotifier发送地址
                            userAddressNotifier.value = userAddress;
                          }

                          // 关闭弹窗
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        child: Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset('assets/location.png'),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 6.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              userAddress.receiver!,
                                              style: TextStyle(color: Color(0xFF333333), fontSize: 14.0, height: 1.0),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          // 如果当前地址是默认地址，才需要展示'默认'标签
                                          userAddress.isDefault!
                                              ? Padding(
                                                  padding: EdgeInsets.only(left: 10.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(color: Color(0xffFF9240), width: 0.5),
                                                    ),
                                                    padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
                                                    child: Text(
                                                      '默认',
                                                      style: TextStyle(
                                                          color: Color(0xffFF9240), fontSize: 10.0, height: 1.0),
                                                    ),
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 6.0),
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            userAddress.fullLocation! + userAddress.address!,
                                            style: TextStyle(color: Color(0xFF333333), fontSize: 14.0),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Container(
                          height: 1.0,
                          color: Color(0xFFEAEAEA),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Container(
            height: 60.0 + MediaQuery.of(context).padding.bottom,
            child: Column(
              children: [
                Divider(height: 1.0, color: Color(0xFFEDEDED)),
                Container(
                  padding: EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Padding(
                    padding: EdgeInsets.only(top: 9.0),
                    child: GestureDetector(
                      onTap: () {
                        debugPrint('添加地址');
                      },
                      child: Container(
                        height: 40.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          gradient: LinearGradient(colors: [Color(0xFF00D2AE), Color(0xFF00BD9A)]),
                        ),
                        child: Text(
                          '添加地址',
                          style: TextStyle(color: Colors.white, fontSize: 14.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
