import 'package:flutter/material.dart';

class PriceWidget extends StatelessWidget {
  PriceWidget({
    this.price,
    this.color,
    this.symbolFontSize,
    this.integerFontSize,
    this.decimalFontSize,
    this.fontWeight,
  });

  /// 价格字符串
  final String? price;

  /// 颜色
  final Color? color;

  /// 人命币符号字号
  final double? symbolFontSize;

  /// 价格整数部分字号
  final double? integerFontSize;

  /// 价格小数部分字号
  final double? decimalFontSize;

  /// 粗体
  final FontWeight? fontWeight;

  /// '19.9' ==> ['19','9']
  List<String> _splitPriceString(String? price) {
    // 如果价格字符串为空或者是空字符串，我们需要制定一个默认的价格字符串 '0.00'
    if (price == null || price == '') {
      price = '0.00';
    }

    return price.split('.');
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: '¥',
        style: TextStyle(
          color: color ?? Color(0xFFCF4444),
          fontWeight: fontWeight,
          fontSize: symbolFontSize ?? 9.0,
        ),
        children: [
          TextSpan(
            text: _splitPriceString(price)[0],
            style: TextStyle(fontSize: integerFontSize ?? 13.0, height: 1.0),
          ),
          TextSpan(
            text: '.' + _splitPriceString(price)[1],
            style: TextStyle(fontSize: decimalFontSize ?? 10.0),
          ),
        ],
      ),
    );
  }
}
