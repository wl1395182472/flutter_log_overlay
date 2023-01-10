import 'package:flutter/material.dart';

import 'log_overlay_model.dart';
import 'log_overlay_widget.dart';

class FlutterLogOverlay {
  ///init:需要获取home的context
  ///
  ///(MaterialApp的context还未对页面开始初始化，无法获取MediaQuery)
  ///
  ///(需要在home的initState中第二帧开始初始化)
  static late BuildContext _currentContext;

  ///init:弹窗的宽度
  static double _width = 0.0;

  ///init:弹窗的高度
  static double _height = 0.0;

  ///init:控制弹窗的左上角的x轴坐标(相对于屏幕)
  static double _overlayLeft = 0.0;

  ///init:控制弹窗的左上角的yx轴坐标(相对于屏幕)
  static double _overlayTop = 0.0;

  ///init:标题的高度
  static double _titleHeight = 0.0;

  ///init:标题的背景颜色
  static Color? _barColor;

  ///init:消息的背景颜色
  static Color? _itemColor;

  ///init:error消息的背景颜色
  static Color? _errorColor;

  ///init:需要标题
  static bool _needTitle = true;

  ///init:需要清除按钮
  static bool _needClean = true;

  ///init:日志的TextStyle
  static TextStyle? _logTextStyle;

  ///悬浮是否显示
  static bool get isShow => entry.mounted;

  ///是否展开listview
  static bool showListView = true;

  ///可自定义widget(LogOverlayWidget)
  static Widget? logOverlayWidget;

  ///日志缓存
  static final List<LogOverlayModel> logList = [];

  ///context的mediaQueryData
  static final _mediaQueryData = MediaQuery.of(_currentContext);

  ///context的overlay
  static final _overlay = Overlay.of(_currentContext);

  ///初始化
  ///
  ///[context]为当前页面的context
  static void init({
    required BuildContext context,
    double? width,
    double? height,
    double? overlayLeft,
    double? overlayTop,
    double? titleHeight,
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
    _overlayLeft = overlayLeft ?? _mediaQueryData.padding.left;
    _overlayTop = overlayTop ?? _mediaQueryData.padding.top;
    _titleHeight = titleHeight ?? 60.0;
    _barColor = barColor;
    _itemColor = itemColor;
    _errorColor = errorColor;
    _needTitle = needTitle;
    _needClean = needClean;
    _logTextStyle = logTextStyle;
  }

  ///使用OverlayEntry全局悬浮
  static final OverlayEntry entry = OverlayEntry(
    builder: (context) => Positioned(
      left: _overlayLeft,
      top: _overlayTop,
      child: logOverlayWidget ??
          LogOverlayWidget(
            overlayLeft: _overlayLeft,
            overlayTop: _overlayTop,
            width: _width,
            height: _height,
            logList: logList,
            titleHeight: _titleHeight,
            barColor: _barColor,
            itemColor: _itemColor,
            errorColor: _errorColor,
            needTitle: _needTitle,
            needClean: _needClean,
            logTextStyle: _logTextStyle,
            showListView: showListView,
            onTap: () async {
              showListView = !showListView;
              await _update();
            },
            onDoubleTap: hide,
            onPanUpdate: (DragUpdateDetails detail) async {
              await boundaryConstraint(
                context: context,
                detail: detail,
              );
            },
          ),
    ),
  );

  ///展示悬浮
  static void show() {
    if (_overlay != null) {
      if (!isShow) {
        _overlay!.insert(entry);
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
      if (_overlay != null) {
        // ignore: invalid_use_of_protected_member
        _overlay!.setState(() {});
      }
    }
  }

  ///边界约束
  static Future<void> boundaryConstraint({
    required BuildContext context,
    required DragUpdateDetails detail,
  }) async {
    if (_overlay != null) {
      //屏幕约束
      final left = _overlayLeft;
      final right = _width + left;
      final top = _overlayTop;
      final bottom = (showListView ? _height : _titleHeight) + top;
      if (left < _mediaQueryData.padding.left) {
        _overlayLeft = _mediaQueryData.padding.left;
      } else if (right >
          (_mediaQueryData.size.width - _mediaQueryData.padding.right)) {
        _overlayLeft =
            _mediaQueryData.size.width - _width - _mediaQueryData.padding.right;
      } else if (top < _mediaQueryData.padding.top) {
        _overlayTop = _mediaQueryData.padding.top;
      } else if (bottom >
          (_mediaQueryData.size.height - _mediaQueryData.padding.bottom)) {
        _overlayTop = _mediaQueryData.size.height -
            (showListView ? _height : _titleHeight) -
            _mediaQueryData.padding.bottom;
      } else {
        _overlayLeft += detail.delta.dx;
        _overlayTop += detail.delta.dy;
      }
      await _update();
    }
  }

  ///增加新日志
  static void addLog({
    required bool isCore,
    required List<String> content,
  }) async {
    logList.add(
      LogOverlayModel(
        isError: isCore,
        content: content,
      ),
    );
    await _update();
  }

  ///清空日志
  static void clearLog() async {
    logList.clear();
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
