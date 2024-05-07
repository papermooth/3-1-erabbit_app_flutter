import 'package:flutter/material.dart';

class OrderListBottomBar extends StatelessWidget {
  OrderListBottomBar({
    this.title= '',
    this.onTap,
  });

  /// 标题
  final String title;

  /// 点击事件
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2.0),
          border: Border.all(width: 0.5, color: Color(0xFF666666)),
          color: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
          child: Text(
            title,
            style: TextStyle(color: Color(0xFF666666), fontSize: 13.0),
          ),
        ),
      ),
    );
  }
}
