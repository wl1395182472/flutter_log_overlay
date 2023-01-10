import 'package:flutter/material.dart';
import 'package:flutter_log_overlay/flutter_log_overlay.dart';

class LogOverlayWidget extends StatefulWidget {
  ///日志列表
  final List<LogOverlayModel> logList;

  ///窗口的宽度
  final double width;

  ///窗口的高度
  final double height;

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

  ///日志的TextStyle
  final TextStyle? logTextStyle;

  ///双击关闭
  final void Function()? onDoubleTap;

  ///位置更新刷新
  final void Function(DragUpdateDetails)? onPanUpdate;

  const LogOverlayWidget({
    Key? key,
    required this.width,
    required this.height,
    this.barColor,
    this.itemColor,
    this.errorColor,
    required this.logList,
    this.needTitle = true,
    this.needClean = true,
    this.logTextStyle,
    this.onDoubleTap,
    this.onPanUpdate,
  }) : super(key: key);

  @override
  State<LogOverlayWidget> createState() => _LogOverlayWidgetState();
}

class _LogOverlayWidgetState extends State<LogOverlayWidget> {
  bool _showListView = true;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final currentContext = MediaQuery.of(context);
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.transparent,
      constraints: BoxConstraints(
        minHeight: widget.needTitle ? 60.0 : 0.0,
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
          if (widget.needTitle)
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                setState(() {
                  _showListView = !_showListView;
                });
              },
              onDoubleTap: widget.onDoubleTap,
              onPanUpdate: widget.onPanUpdate,
              child: Material(
                color: Colors.transparent,
                child: buildBar(
                  color: widget.barColor ?? Colors.yellowAccent,
                ),
              ),
            ),
          //堆栈信息列表
          if (_showListView)
            buildListview(
              context: context,
              color: widget.itemColor ?? Colors.greenAccent,
              errorColor: widget.errorColor ?? Colors.redAccent,
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
      width: widget.width,
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
          FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              "调试控制台\n"
              "当前信息数:${widget.logList.length}\n"
              "(此区域可以拖动 单击展开或收起 双击隐藏)",
            ),
          ),
          if (widget.needClean)
            InkWell(
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
      width: widget.width,
      height: widget.height - 60.0,
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
            children: widget.logList.reversed
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
                          style: widget.logTextStyle ??
                              const TextStyle(fontSize: 10.0),
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
