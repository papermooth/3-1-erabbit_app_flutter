import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomImage extends StatelessWidget {
  CustomImage({
    required this.url,
    this.width,
    this.height,
  });

  /// 图片地址
  final String url;

  /// 宽度
  final double? width;

  /// 高度
  final double? height;

  /// 构建占位图
  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(2.0),
      ),
      padding: EdgeInsets.all(10.0),
      child: Image.asset('assets/placeholder.png'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(2.0)),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        // 设置占位图
        placeholder: (BuildContext context, String url) {
          return _buildPlaceholder();
        },
        // 处理异常
        errorWidget: (BuildContext context, String url, dynamic error) {
          return _buildPlaceholder();
        },
      ),
    );
  }
}
