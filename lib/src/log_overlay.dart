import 'package:flutter/material.dart';

import 'log_overlay_model.dart';
import 'log_overlay_widget.dart';

class FlutterLogOverlay {
  ///需要获取home的context
  ///
  ///(MaterialApp的context还未对页面开始初始化，无法获取MediaQuery)
  ///
  ///(需要在home的initState中第二帧开始初始化)
  static late BuildContext notMaterialAppContext;

  ///弹窗的宽度
  static double width = 300.0;

  ///弹窗的高度
  static double height = 500.0;

  ///控制弹窗的左上角的x轴坐标(相对于屏幕)
  static double overlayLeft = MediaQuery.of(notMaterialAppContext).padding.left;

  ///控制弹窗的左上角的yx轴坐标(相对于屏幕)
  static double overlayTop = MediaQuery.of(notMaterialAppContext).padding.top;

  ///使用OverlayEntry全局悬浮
  static final OverlayEntry entry = OverlayEntry(
    builder: (context) {
      final mediaQuery = MediaQuery.of(context);
      return Positioned(
        left: overlayLeft,
        top: overlayTop,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onDoubleTap: hide,
          onPanUpdate: (DragUpdateDetails detail) {
            final overlay = Overlay.of(context);
            if (overlay != null) {
              //屏幕约束
              final left = overlayLeft;
              final right = width + left;
              final top = overlayTop;
              final bottom = height + top;
              if (left < mediaQuery.padding.left) {
                overlayLeft = mediaQuery.padding.left;
              } else if (right >
                  (mediaQuery.size.width - mediaQuery.padding.right)) {
                overlayLeft =
                    mediaQuery.size.width - width - mediaQuery.padding.right;
              } else if (top < mediaQuery.padding.top) {
                overlayTop = mediaQuery.padding.top;
              } else if (bottom >
                  (mediaQuery.size.height - mediaQuery.padding.bottom)) {
                overlayTop =
                    mediaQuery.size.height - height - mediaQuery.padding.bottom;
              } else {
                overlayLeft += detail.delta.dx;
                overlayTop += detail.delta.dy;
              }
              // ignore: invalid_use_of_protected_member
              overlay.setState(() {});
            }
          },
          child: LogOverlayWidget(
            width: width,
            height: height,
            logList: _logList,
          ),
        ),
      );
    },
  );

  ///悬浮是否显示
  static bool get isShow => entry.mounted;

  ///展示悬浮
  static void show() {
    final overlay = Overlay.of(notMaterialAppContext);
    if (overlay != null) {
      if (!isShow) {
        overlay.insert(entry);
      }
    }
  }

  ///隐藏悬浮
  static void hide() {
    if (isShow) {
      entry.remove();
    }
  }

  ///更新悬浮
  static void _update() {
    if (isShow) {
      final overlay = Overlay.of(notMaterialAppContext);
      if (overlay != null) {
        // ignore: invalid_use_of_protected_member
        overlay.setState(() {});
      }
    }
  }

  ///日志缓存
  static final List<LogOverlayModel> _logList = [];

  ///增加新日志
  static void addLog({
    required bool isCore,
    required String content,
  }) {
    _logList.add(LogOverlayModel(
      isCore: isCore,
      content: content,
    ));
    _update();
  }

  ///清空日志
  static void clearLog() {
    _logList.clear();
    _update();
  }

  ///上次拖动的时间戳
  static int _lastPanTime = 0;

  ///拖动的次数
  static int _panTimes = 0;

  ///在1秒内朝屏幕左上角拖动3次触发悬浮窗
  static void showOverlayPan(DragEndDetails details) {
    if (details.velocity.pixelsPerSecond.dx < 0 &&
        details.velocity.pixelsPerSecond.dy < 0) {
      final nowTime = DateTime.now();
      if (nowTime
              .difference(DateTime.fromMillisecondsSinceEpoch(_lastPanTime))
              .inMilliseconds <
          1000) {
        if (_panTimes == 3) {
          _panTimes = 0;
          FlutterLogOverlay.show();
        } else {
          _panTimes++;
        }
      } else {
        _lastPanTime = nowTime.millisecondsSinceEpoch;
        _panTimes = 0;
      }
    }
  }
}
