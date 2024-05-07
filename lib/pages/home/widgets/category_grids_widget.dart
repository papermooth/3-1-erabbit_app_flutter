import 'package:erabbit_app_flutter/models/home_model.dart';
import 'package:erabbit_app_flutter/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class CategoryGridsWidget extends StatefulWidget {
  CategoryGridsWidget({this.categoryGrids});

  /// 分类网格数据
  final List<CategoryGridsModel>? categoryGrids;

  @override
  _CategoryGridsWidgetState createState() => _CategoryGridsWidgetState();
}

class _CategoryGridsWidgetState extends State<CategoryGridsWidget> {
  /// 图标的宽度
  double _imageWidth = 0.0;

  /// 是否是单行
  bool isSingle = false;

  /// 分页的总页数
  int _pages = 0;

  /// 当前页的页码
  int _activeIndex = 0;

  /// 根据总页数循环创建指示器元素
  List<Widget> _buildIndicator() {
    List<Widget> items = [];

    for (var i = 0; i < _pages; i++) {
      bool isActive = i == _activeIndex;

      items.add(
        Container(
          width: 15.0,
          height: 3.0,
          color: isActive ? Color(0xFF3CCEAF) : Color(0xFFE2E2E2),
        ),
      );
    }

    return items;
  }

  /// 构建分类网格:使用插件构建网格视图
  Widget _buildItem(List<CategoryGridsModel> categoryGrids) {
    return StaggeredGridView.countBuilder(
        crossAxisCount: 5, // 每一行要展示的item的个数 = crossAxisCount / StaggeredTile.fit(1)
        itemCount: categoryGrids.length,
        mainAxisSpacing: 18.0, // 上下两行间距
        // 为了解决StaggeredGridView和CustomScrollView的滚动冲突，需要禁用滚动效果
        physics: NeverScrollableScrollPhysics(),
        // shrinkWrap搭配禁用滚动，解决滚动视图间的滚动冲突
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          CategoryGridsModel categoryGridsModel = categoryGrids[index];
          return Column(
            children: [
              // Image.network(
              //   categoryGridsModel.picture!,
              //   width: _imageWidth,
              //   height: _imageWidth,
              //   fit: BoxFit.cover,
              // ),
              CustomImage(
                url: categoryGridsModel.picture!,
                width: _imageWidth,
                height: _imageWidth,
              ),
              Container(
                height: 20.0,
                child: Text(
                  categoryGridsModel.name!,
                  style: TextStyle(color: Color(0xFF131313), fontSize: 13.0),
                ),
              ),
            ],
          );
        },
        staggeredTileBuilder: (int index) {
          return StaggeredTile.fit(1);
        });
  }

  /// 构建分页网格视图
  List<Widget> _buildPages(List<CategoryGridsModel> categoryGrids) {
    List<Widget> items = [];

    // 计算分页的总页数
    // categoryGrids.length * 0.1 ： 分类总个数(14)除以每页最多展示的分类个数(10) ==> 1.4
    // (1.4).ceil() ==> 2
    // ceil() 取某个数值的上限的整数，会读取某个数值等于或者大于他的整数
    _pages = (categoryGrids.length * 0.1).ceil();

    // 根据分页的总页数，循环构建分页网格视图
    for (var i = 0; i < _pages; i++) {
      // 1. 计算当前页网格数据的起始位置
      int start = i * 10;
      // 2. 计算当前页网格数据的结束位置
      int end = 0;
      if (categoryGrids.sublist(start, categoryGrids.length).length > 10) {
        // 剩下的分类个数大于10，结束位置继续取10个
        end = start + 10;
      } else {
        end = categoryGrids.length;
      }
      // 3. 将当前页的网格数据传入到网格视图
      items.add(_buildItem(categoryGrids.sublist(start, end)));
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕宽度
    double screenWidth = MediaQuery.of(context).size.width;
    // 6 * 16.0 : 五个图标之间的6个间距
    // 计算分类图标的宽度：(屏幕宽度 - 6 * 16.0) * 0.2
    _imageWidth = (screenWidth - 6 * 16.0) * 0.2;

    // 2. 计算单行时和两行时的网格高度
    // 单行高度：图标高度 + 文字高度(20.0)
    double totalHeight1 = _imageWidth + 20.0;
    // 两行高度：2 * totalHeight1 + 上下两行的间距(18.0）
    double totalHeight2 = 2 * totalHeight1 + 18.0;

    if (widget.categoryGrids != null) {
      return Column(
        children: [
          // 分类网格
          // PageView在使用时一定要限制大小
          // 1. AnimatedContainer组件作为PageView组件的父组件
          AnimatedContainer(
            duration: Duration(milliseconds: 400),
            curve: Curves.ease, // 动画的样式：先快后慢
            height: isSingle ? totalHeight1 : totalHeight2,
            child: PageView(
              children: _buildPages(widget.categoryGrids!),
              // 3. 监听PageView翻页事件，计算当前页是否是单行
              onPageChanged: (int index) {
                int count = widget.categoryGrids!.sublist(index * 10, widget.categoryGrids!.length).length;
                setState(() {
                  isSingle = count <= 5; // 如果是单行，isSingle=true
                  _activeIndex = index; // 当前页的页码
                });
              },
            ),
          ),
          // 指示器
          Padding(
            padding: EdgeInsets.only(top: 10.0, bottom: 14.0),
            child: Row(
              // 设置指示器居中
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildIndicator(),
            ),
          ),
        ],
      );
    } else {
      // 将来补充加载中的骨架屏
      return StaggeredGridView.countBuilder(
          crossAxisCount: 5, // 每一行要展示的item的个数 = crossAxisCount / StaggeredTile.fit(1)
          itemCount: 10,
          mainAxisSpacing: 18.0, // 上下两行间距
          // 为了解决StaggeredGridView和CustomScrollView的滚动冲突，需要禁用滚动效果
          physics: NeverScrollableScrollPhysics(),
          // shrinkWrap搭配禁用滚动，解决滚动视图间的滚动冲突
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                Container(
                  width: _imageWidth,
                  height: _imageWidth,
                  decoration: BoxDecoration(
                    color: Color(0xFFEBEBEB),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Container(
                    width: _imageWidth,
                    height: 20.0,
                    decoration: BoxDecoration(color: Color(0xFFEBEBEB)),
                  ),
                ),
              ],
            );
          },
          staggeredTileBuilder: (int index) {
            return StaggeredTile.fit(1);
          });
    }
  }
}
