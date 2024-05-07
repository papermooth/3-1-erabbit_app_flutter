import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

typedef VoidCallback = void Function();

class CustomRefresher extends StatelessWidget {
  CustomRefresher({
    required this.controller,
    this.onRefresh,
    this.onLoading,
    this.child,
    this.enablePullDown = true,
    this.enablePullUp= true,
  });

  /// 控制器
  final RefreshController controller;

  /// 下拉刷新的回调
  final VoidCallback? onRefresh;

  /// 上拉加载更多的回调
  final VoidCallback? onLoading;

  /// 子组件(可滚动组件)
  final Widget? child;

  /// 是否允许下拉刷新
  final bool enablePullDown;

  /// 是否允许上拉加载更多
  final bool enablePullUp;

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: controller, // 控制刷新的状态的
      enablePullDown: enablePullDown,
      enablePullUp: enablePullUp,
      onRefresh: onRefresh,
      onLoading: onLoading,
      header: CustomHeader(
        builder: (BuildContext context, RefreshStatus? mode) {
          String refreshText = '下拉刷新';
          // 默认是静态图标
          String refreshIcon = 'assets/refresh.png';
          if (mode == RefreshStatus.idle) {
            refreshText = '下拉刷新';
          } else if (mode == RefreshStatus.canRefresh) {
            refreshText = '松开刷新';
          } else if (mode == RefreshStatus.refreshing) {
            refreshText = '刷新中';
            // 动态图标
            refreshIcon = 'assets/refresh.gif';
          } else if (mode == RefreshStatus.completed) {
            refreshText = '刷新完成';
          } else if (mode == RefreshStatus.failed) {
            refreshText = '刷新失败';
          } else {
            refreshText = '再刷新看看吧！';
          }
          return Container(
            height: 60.0,
            alignment: Alignment.center,
            child: Column(
              children: [
                // 兔子图标: 静态、动态
                Image.asset(refreshIcon, width: 42.0, height: 42.0),
                Text(
                  refreshText,
                  style: TextStyle(color: Color(0xFF2626262), fontSize: 12.0),
                ),
              ],
            ),
          );
        },
      ), // 可以自定义
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text("继续加载看看吧！", style: TextStyle(color: Color(0xFF2626262), fontSize: 12.0));
          } else if (mode == LoadStatus.loading) {
            body = CupertinoActivityIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text("加载失败，再试试看吧！", style: TextStyle(color: Color(0xFF2626262), fontSize: 12.0));
          } else if (mode == LoadStatus.canLoading) {
            body = Text("松手，加载更多", style: TextStyle(color: Color(0xFF2626262), fontSize: 12.0));
          } else {
            body = Text("-- 我们是有底线的 --", style: TextStyle(color: Color(0xFF2626262), fontSize: 12.0));
          }
          return Container(
            height: 55.0,
            child: Center(child: body),
          );
        },
      ),
      child: child,
    );
  }
}
