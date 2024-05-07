import 'package:erabbit_app_flutter/pages/account/account_login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  // 设置顶部导航栏首选（默认）的高度: kToolbarHeight = 56.0
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 状态栏高度 + 底部导航栏高度,
      height: MediaQuery.of(context).padding.top + kToolbarHeight,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/home_appBar_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      padding: EdgeInsets.only(left: 18.0, right: 18.0),
      // SafeArea解决了不规则屏幕遮挡内容的问题
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 扫描图标
            GestureDetector(
              onTap: () async {
                // 测试：演示token过期时访问我的订单接口
                // String path = 'member/order?page=1&pageSize=10';
                // Response response = await XTXRequestManager().handleRequest(path, 'GET');
                // debugPrint('测试：我的订单 ${response.data}');

                // 测试订单列表页
                // Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) {
                //   return OrderListPage();
                // }));
              },
              child: Image.asset('assets/home_scan.png'),
            ),

            // 搜索框
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                child: Container(
                  height: 30.0,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(245, 245, 245, 0.4),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  padding: EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Row(
                    children: [
                      // 放大镜
                      Image.asset('assets/home_search.png'),
                      // 提示文字
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(
                          '搜索商品',
                          style: TextStyle(color: Colors.white, fontSize: 14.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 登录图标
            GestureDetector(
              // 设置点击手势事件
              onTap: () {
                // debugPrint('点击了登录图标，将来会进入到登录页或者个人中心');
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    // 决定页面推入的方式的
                    // false:默认值,从屏幕右侧向左推入新页面
                    // true:从屏幕底下向上推入新页面（OK）
                    fullscreenDialog: true,
                    builder: (BuildContext context) {
                      return AccountLoginPage();
                    },
                  ),
                );
              },
              child: Image.asset('assets/home_login.png'),
            ),
          ],
        ),
      ),
    );
  }
}
