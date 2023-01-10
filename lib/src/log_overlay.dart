import 'package:flutter/material.dart';

import 'log_overlay_model.dart';
import 'log_overlay_widget.dart';

class FlutterLogOverlay {
  ///需要获取home的context
  ///
  ///(MaterialApp的context还未对页面开始初始化，无法获取MediaQuery)
  ///
  ///(需要在home的initState中第二帧开始初始化)
  static late BuildContext _currentContext;

  ///弹窗的宽度
  static double _width = 0.0;

  ///弹窗的高度
  static double _height = 0.0;

  ///控制弹窗的左上角的x轴坐标(相对于屏幕)
  static double _overlayLeft = 0.0;

  ///控制弹窗的左上角的yx轴坐标(相对于屏幕)
  static double _overlayTop = 0.0;

  ///标题的背景颜色
  static Color? _barColor;

  ///消息的背景颜色
  static Color? _itemColor;

  ///error消息的背景颜色
  static Color? _errorColor;

  ///需要标题
  static bool _needTitle = true;

  ///需要清除按钮
  static bool _needClean = true;

  ///日志的TextStyle
  static TextStyle? _logTextStyle;

  ///初始化
  ///
  ///[context]为当前页面的context
  static void init({
    required BuildContext context,
    double? width,
    double? height,
    double? overlayLeft,
    double? overlayTop,
    Color? backgroundColor,
    Color? barColor,
    Color? itemColor,
    Color? errorColor,
    bool needTitle = true,
    bool needClean = true,
    TextStyle? logTextStyle,
  }) {
    _currentContext = context;
    _width = width ?? 300.0;
    _height = height ?? 500.0;
    _overlayLeft = overlayLeft ?? MediaQuery.of(_currentContext).padding.left;
    _overlayTop = overlayTop ?? MediaQuery.of(_currentContext).padding.top;
    _barColor = barColor;
    _itemColor = itemColor;
    _errorColor = errorColor;
    _needTitle = needTitle;
    _needClean = needClean;
    _logTextStyle = logTextStyle;
  }

  static Widget? logOverlayWidget;

  ///使用OverlayEntry全局悬浮
  static final OverlayEntry entry = OverlayEntry(
    builder: (context) {
      return Positioned(
        left: _overlayLeft,
        top: _overlayTop,
        child: logOverlayWidget ??
            LogOverlayWidget(
              width: _width,
              height: _height,
              logList: _logList,
              barColor: _barColor,
              itemColor: _itemColor,
              errorColor: _errorColor,
              needTitle: _needTitle,
              needClean: _needClean,
              logTextStyle: _logTextStyle,
              onDoubleTap: hide,
              onPanUpdate: (DragUpdateDetails detail) async {
                await boundaryConstraint(
                  context: context,
                  detail: detail,
                );
              },
            ),
      );
    },
  );

  ///悬浮是否显示
  static bool get isShow => entry.mounted;

  ///展示悬浮
  static void show() {
    final overlay = Overlay.of(_currentContext);
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
  static Future<void> _update() async {
    if (isShow) {
      final overlay = Overlay.of(_currentContext);
      if (overlay != null) {
        // ignore: invalid_use_of_protected_member
        overlay.setState(() {});
      }
    }
  }

  ///边界约束
  static Future<void> boundaryConstraint({
    required BuildContext context,
    required DragUpdateDetails detail,
  }) async {
    final mediaQueryData = MediaQuery.of(context);
    final overlay = Overlay.of(context);
    if (overlay != null) {
      //屏幕约束
      final left = _overlayLeft;
      final right = _width + left;
      final top = _overlayTop;
      final bottom = _height + top;
      if (left < mediaQueryData.padding.left) {
        _overlayLeft = mediaQueryData.padding.left;
      } else if (right >
          (mediaQueryData.size.width - mediaQueryData.padding.right)) {
        _overlayLeft =
            mediaQueryData.size.width - _width - mediaQueryData.padding.right;
      } else if (top < mediaQueryData.padding.top) {
        _overlayTop = mediaQueryData.padding.top;
      } else if (bottom >
          (mediaQueryData.size.height - mediaQueryData.padding.bottom)) {
        _overlayTop = mediaQueryData.size.height -
            _height -
            mediaQueryData.padding.bottom;
      } else {
        _overlayLeft += detail.delta.dx;
        _overlayTop += detail.delta.dy;
      }
      await _update();
    }
  }

  ///日志缓存
  static final List<LogOverlayModel> _logList = [];

  ///增加新日志
  static void addLog({
    required bool isCore,
    required List<String> content,
  }) async {
    _logList.add(
      LogOverlayModel(
        isError: isCore,
        content: content,
      ),
    );
    await _update();
  }

  ///清空日志
  static void clearLog() async {
    _logList.clear();
    await _update();
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
