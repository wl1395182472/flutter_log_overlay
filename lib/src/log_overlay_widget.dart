import 'package:flutter/material.dart';
import 'package:flutter_log_overlay/flutter_log_overlay.dart';
// import 'package:stack_trace/stack_trace.dart';

class LogOverlayWidget extends StatelessWidget {
  ///窗口的宽度
  final double width;

  ///窗口的高度
  final double height;

  ///日志列表
  final List<LogOverlayModel> logList;

  const LogOverlayWidget({
    Key? key,
    required this.width,
    required this.height,
    required this.logList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      constraints: BoxConstraints(
        minHeight: 60.0,
        maxWidth: MediaQuery.of(context).size.width -
            MediaQuery.of(context).padding.left -
            MediaQuery.of(context).padding.right,
        maxHeight: MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.top -
            MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        children: [
          //标题显示
          Material(
            color: Colors.yellow,
            child: Container(
              width: width,
              height: 60.0,
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
                  InkWell(
                    onTap: () => FlutterLogOverlay.clearLog(),
                    child: const Icon(Icons.cleaning_services),
                  ),
                ],
              ),
            ),
          ),
          //堆栈信息列表
          Container(
            width: width,
            height: height - 60.0,
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width -
                  MediaQuery.of(context).padding.left -
                  MediaQuery.of(context).padding.right,
              maxHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: MediaQuery.removePadding(
              //移除ListView顶部padding
              removeTop: true,
              context: context,
              child: ListView(
                scrollDirection: Axis.vertical,
                children: logList
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.0),
                        child: Material(
                          color: e.isCore ? Colors.red : Colors.green,
                          child: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5.0,
                              vertical: 10.0,
                            ),
                            child: Text(
                              e.content,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
