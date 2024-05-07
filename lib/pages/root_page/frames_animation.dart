import 'package:flutter/material.dart';

class FramesAnimation extends StatefulWidget {
  FramesAnimation({
    Key? key, // 记录组件状态的
    this.initIndex= 0,
    required this.images,
  }) : super(key: key);

  /// 当前帧动画索引(标记)
  final int initIndex;

  /// 帧动画图片
  final List images;

  @override
  FramesAnimationState createState() => FramesAnimationState();
}

class FramesAnimationState extends State<FramesAnimation> with SingleTickerProviderStateMixin {
  /// 动画控制器
  late AnimationController _animationController;

  /// 动画对象
  late Animation _animation;

  @override
  void initState() {
    // 创建动画控制器
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    // 创建动画对象
    _animation = Tween(begin: 0.0, end: (widget.images.length - 1).toDouble()).animate(_animationController);

    // 监听动画刷新:Flutter的动画每一秒钟刷新60次(帧)左右
    _animationController.addListener(() {
      // 如果监听到动画刷新，就刷新当前组件
      setState(() {});
    });

    // 默认启动首页动画
    if (widget.initIndex == 0) {
      startAnimation();
    }

    super.initState();
  }

  @override
  void dispose() {
    // 释放动画资源
    _animationController.dispose();
    super.dispose();
  }

  /// 启动动画
  void startAnimation() => _animationController.forward();

  /// 重置动画
  void resetAnimation() => _animationController.reset();

  /// 准备帧动画内容（测试用的7个色块）
  // List frames = [
  //   Container(width: 20.0, height: 20.0, color: Colors.red), // 0
  //   Container(width: 20.0, height: 20.0, color: Colors.orange), // 1
  //   Container(width: 20.0, height: 20.0, color: Colors.yellow), // 2
  //   Container(width: 20.0, height: 20.0, color: Colors.green), // 3
  //   Container(width: 20.0, height: 20.0, color: Colors.cyan), // 4
  //   Container(width: 20.0, height: 20.0, color: Colors.blue), // 5
  //   Container(width: 20.0, height: 20.0, color: Colors.purple) // 6
  // ];

  @override
  Widget build(BuildContext context) {
    // 输出帧动画的取值
    // print(_animation.value);

    // 获取帧动画索引（重要）
    int framesIndex = _animation.value.floor();
    // print(framesIndex);

    return Container(
      // 读取并展示当前帧
      // child: frames[framesIndex],
      // 读取并展示帧动画图片
      child: widget.images[framesIndex],
    );
  }
}
