import 'package:erabbit_app_flutter/models/home_model.dart';
import 'package:erabbit_app_flutter/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

class ImageSwiperWidget extends StatelessWidget {
  ImageSwiperWidget({
    this.imageBanners,
    this.height,
    this.borderRadius= 4.0,
    this.type,
  });

  /// 轮播图数据
  final List<ImageBannersModel>? imageBanners;

  /// 高度
  final double? height;

  /// 圆角
  final double? borderRadius;

  /// 指示器类型
  final CustomSwiperPaginatioType? type;

  @override
  Widget build(BuildContext context) {
    return imageBanners != null
        ? Container(
            height: height,
            // 设置圆角并切割出来
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(borderRadius!)),
            clipBehavior: Clip.antiAlias,
            child: Swiper(
              itemCount: imageBanners!.length,
              itemBuilder: (BuildContext context, int index) {
                ImageBannersModel imageBannersModel = imageBanners![index];
                // return Image.network(imageBannersModel.imgUrl!, fit: BoxFit.cover);
                return CustomImage(url: imageBannersModel.imgUrl!);
              },
              // 自动播放
              autoplay: true,
              // 指示器
              pagination: SwiperPagination(
                // 指示器距离轮播图底部的距离
                margin: EdgeInsets.only(bottom: 6.0),
                builder: CustomSwiperPagination(type: type),
              ),
            ),
          )
        : Container(
            height: height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xFFEBEBEB),
              borderRadius: BorderRadius.circular(borderRadius!),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset('assets/placeholder.png'),
          );
  }
}

/// 枚举:定义指示器类型
enum CustomSwiperPaginatioType {
  rect, // 矩形
  dot, // 圆点
}

/// 自定义指示器
class CustomSwiperPagination extends SwiperPlugin {
  CustomSwiperPagination({this.type});

  /// 指示器的类型
  final CustomSwiperPaginatioType? type;

  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    // config：可以提供指示器元素个数和当前展示的指示器索引
    // 获取到指示器元素个数
    int itemCount = config.itemCount;
    // 获取到当前展示的指示器索引
    int activeIndex = config.activeIndex;
    // 存放指示器
    List<Widget> items = [];

    // 循环创建指示器元素
    for (var i = 0; i < itemCount; i++) {
      // 判断哪个元素被选中
      bool isActive = i == activeIndex;
      items.add(
        type == CustomSwiperPaginatioType.rect
            ? Container(
                // 元素之前有间距
                margin: EdgeInsets.only(left: 3.0, right: 3.0),
                child: Container(
                  width: 13.0,
                  height: 3.0,
                  color: isActive ? Colors.white : Colors.white60,
                ),
              )
            : Container(
                // 元素之前有间距
                margin: EdgeInsets.only(left: 3.0, right: 3.0),
                child: ClipOval(
                  child: Container(
                    width: 5.0,
                    height: 5.0,
                    color: isActive ? Colors.white : Colors.white60,
                  ),
                ),
              ),
      );
    }

    return Row(
      // 设置指示器居中
      mainAxisAlignment: MainAxisAlignment.center,
      children: items,
    );
  }
}
