import 'package:flutter/material.dart';
import 'package:flutter_log_overlay/flutter_log_overlay.dart';

class LogOverlayWidget extends StatelessWidget {
  ///控制弹窗的左上角的x轴坐标(相对于屏幕)
  final double overlayLeft;

  ///控制弹窗的左上角的yx轴坐标(相对于屏幕)
  final double overlayTop;

  ///窗口的宽度
  final double width;

  ///窗口的高度
  final double height;

  ///日志列表
  final List<LogOverlayModel> logList;

  ///标题的高度
  final double titleHeight;

  ///窗口的背景颜色
  final Color? backgroundColor;

  ///标题的背景颜色
  final Color? barColor;

  ///消息的背景颜色
  final Color? itemColor;

  ///error消息的背景颜色
  final Color? errorColor;

  ///日志的TextStyle
  final TextStyle? logTextStyle;

  ///需要标题
  final bool needTitle;

  ///需要清除按钮
  final bool needClean;

  ///是否展开listview
  final bool showListView;

  ///单击展开或收起listview
  final void Function()? onTap;

  ///双击隐藏listview
  final void Function()? onDoubleTap;

  ///拖动改变位置
  final void Function(DragUpdateDetails)? onPanUpdate;

  LogOverlayWidget({
    Key? key,
    required this.overlayLeft,
    required this.overlayTop,
    required this.width,
    required this.height,
    required this.logList,
    required this.titleHeight,
    this.backgroundColor,
    this.barColor,
    this.itemColor,
    this.errorColor,
    this.logTextStyle,
    this.needTitle = true,
    this.needClean = true,
    this.showListView = true,
    this.onTap,
    this.onDoubleTap,
    this.onPanUpdate,
  }) : super(key: key);

  ///控制scrollbar和listview的滚动控制
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final currentContext = MediaQuery.of(context);
    return Container(
      width: width,
      height: showListView ? height : titleHeight,
      constraints: BoxConstraints(
        minHeight: needTitle ? titleHeight : 0.0,
        maxWidth: currentContext.size.width -
            currentContext.padding.left -
            currentContext.padding.right,
        maxHeight: currentContext.size.height -
            currentContext.padding.top -
            currentContext.padding.bottom,
      ),
      child: Column(
        children: [
          //标题显示
          if (needTitle)
            Material(
              color: Colors.transparent,
              child: buildBar(
                color: barColor ?? Colors.yellowAccent,
              ),
            ),

          //堆栈信息列表
          if (showListView)
            buildListview(
              context: context,
              color: itemColor ?? Colors.greenAccent,
              errorColor: errorColor ?? Colors.redAccent,
            ),
        ],
      ),
    );
  }

  ///标题
  Widget buildBar({
    Color? color,
  }) {
    return Container(
      width: width,
      height: titleHeight,
      color: color,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        horizontal: 5.0,
        vertical: 10.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: onTap,
              onDoubleTap: onDoubleTap,
              onPanUpdate: onPanUpdate,
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  "调试控制台(${showListView ? '展开' : '收起'})\n"
                  "当前信息数:${logList.length}\n"
                  "(此区域可以拖动 单击展开或收起 双击隐藏)",
                ),
              ),
            ),
          ),
          if (needClean)
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FlutterLogOverlay.clearLog(),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Icon(Icons.cleaning_services),
              ),
            ),
        ],
      ),
    );
  }

  ///listview
  Widget buildListview({
    required BuildContext context,
    Color? color,
    Color? errorColor,
  }) {
    final mediaQueryFromContext = MediaQuery.of(context);
    return Container(
      width: width,
      height: height - titleHeight,
      constraints: BoxConstraints(
        maxWidth: mediaQueryFromContext.size.width -
            mediaQueryFromContext.padding.left -
            mediaQueryFromContext.padding.right,
        maxHeight: mediaQueryFromContext.size.height -
            mediaQueryFromContext.padding.top -
            mediaQueryFromContext.padding.bottom,
      ),
      child: MediaQuery.removePadding(
        //移除ListView顶部padding
        removeTop: true,
        context: context,
        child: Scrollbar(
          controller: _scrollController,
          radius: const Radius.circular(9),
          thickness: 4.0,
          // 总是显示滚动条
          thumbVisibility: true,
          child: ListView(
            controller: _scrollController,
            scrollDirection: Axis.vertical,
            reverse: true,
            children: logList.reversed
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1.0),
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        color: e.isError ? errorColor : color,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5.0,
                          vertical: 10.0,
                        ),
                        child: Text(
                          e.content
                              .reduce((a, b) => "${a.trim()}\n${b.trim()}"),
                          style:
                              logTextStyle ?? const TextStyle(fontSize: 10.0),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
