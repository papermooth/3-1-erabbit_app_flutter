import 'package:erabbit_app_flutter/pages/order_payment/order_settlement_page.dart';
import 'package:flutter/material.dart';

class DeliveryTimeTypesWidget extends StatefulWidget {
  DeliveryTimeTypesWidget({this.deliveryTimeTypes});

  /// 配送时间
  final List<Map>? deliveryTimeTypes;

  @override
  _DeliveryTimeTypesWidgetState createState() => _DeliveryTimeTypesWidgetState();
}

class _DeliveryTimeTypesWidgetState extends State<DeliveryTimeTypesWidget> {
  /// 获取选中的配送时间
  Map _getDeliveryTimeType() {
    Map deliveryTimeType = {};
    widget.deliveryTimeTypes?.forEach((Map element) {
      if (element['selected']) {
        deliveryTimeType = element;
      }
    });
    return deliveryTimeType;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.5,
      color: Colors.white,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.centerRight,
            children: [
              // 标题：配送时间
              Container(
                alignment: Alignment.center,
                height: 40.0,
                width: MediaQuery.of(context).size.width,
                child: Text(
                  '配送时间',
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
                itemCount: widget.deliveryTimeTypes?.length,
                itemBuilder: (BuildContext context, int index) {
                  Map deliveryTimeType = widget.deliveryTimeTypes![index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // 更新选中状态
                          widget.deliveryTimeTypes!.forEach((element) {
                            element['selected'] = element['name'] == deliveryTimeType['name'];
                          });

                          setState(() {});
                        },
                        child: Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(deliveryTimeType['name']),
                              ),
                              deliveryTimeType['selected']
                                  ? Image.asset('assets/check.png', gaplessPlayback: true)
                                  : Image.asset('assets/uncheck.png', gaplessPlayback: true),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Container(
                          height: 0.5,
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
                        // 同步配送时间
                        deliveryTimeTypeNotifier.value = _getDeliveryTimeType();
                        Navigator.of(context, rootNavigator: true).pop();
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
