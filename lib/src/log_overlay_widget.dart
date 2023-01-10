import 'package:flutter/material.dart';
import 'package:flutter_log_overlay/flutter_log_overlay.dart';
// import 'package:stack_trace/stack_trace.dart';

class LogOverlayWidget extends StatelessWidget {
  ///日志列表
  final List<LogOverlayModel> logList;

  ///窗口的宽度
  final double width;

  ///窗口的高度
  final double height;

  ///窗口的背景颜色
  final Color? backgroundColor;

  ///标题的背景颜色
  final Color? barColor;

  ///消息的背景颜色
  final Color? itemColor;

  ///error消息的背景颜色
  final Color? errorColor;

  ///需要标题
  final bool needTitle;

  ///需要清除按钮
  final bool needClean;

  ///双击关闭
  final void Function()? onDoubleTap;

  ///位置更新刷新
  final void Function(DragUpdateDetails)? onPanUpdate;

  const LogOverlayWidget({
    Key? key,
    required this.width,
    required this.height,
    this.backgroundColor,
    this.barColor,
    this.itemColor,
    this.errorColor,
    required this.logList,
    this.needTitle = true,
    this.needClean = true,
    this.onDoubleTap,
    this.onPanUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentContext = MediaQuery.of(context);
    return Container(
      width: width,
      height: height,
      color: backgroundColor,
      constraints: BoxConstraints(
        minHeight: needTitle ? 60.0 : 0.0,
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
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onDoubleTap: onDoubleTap,
              onPanUpdate: onPanUpdate,
              child: Material(
                color: Colors.transparent,
                child: buildBar(
                  color: barColor ?? Colors.yellowAccent,
                ),
              ),
            ),
          //堆栈信息列表
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
      height: 60.0,
      color: color,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        horizontal: 5.0,
        vertical: 10.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "调试控制台 当前信息数:${logList.length}\n"
            "(此区域可以拖动 双击隐藏)",
          ),
          if (needClean)
            InkWell(
              onTap: () => FlutterLogOverlay.clearLog(),
              child: const Icon(Icons.cleaning_services),
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
      height: height - 60.0,
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
        child: ListView(
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
                        e.content.reduce((a, b) => "${a.trim()}\n${b.trim()}"),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
