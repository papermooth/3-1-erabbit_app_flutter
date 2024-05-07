import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // loading动画
          Image.asset('assets/loading.gif', width: 60.0, height: 60.0),
          // 提示文字
          Text(
            '正在加载...',
            style: TextStyle(color: Color(0xFF9EA1A3), fontSize: 12.0),
          ),
        ],
      ),
    );
  }
}
