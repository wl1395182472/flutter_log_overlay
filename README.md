## Usage

Must
```dart
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterLogOverlay.init(context: context);
    });
  }
```

Optional
```dart
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanEnd: FlutterLogOverlay.showOverlayPan,
      behavior: HitTestBehavior.translucent,
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FirstPgae(),
      ),
    );
  }
```

Use
```dart
  void showLogOverlay(){
    FlutterLogOverlay.show();
  }
```

plugin for logger
restructure Logger
```dart
final sLog = MyLogger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 0,
    printEmojis: false,
    printTime: true,
  ),
);

///类方法重构，增加FlutterLogOverlay.addLog打印日志
class MyLogger extends Logger {
  LogFilter? filter;
  LogPrinter? printer;
  LogOutput? output;
  Level? level;

  MyLogger({
    this.filter,
    this.printer,
    this.output,
    this.level,
  }) : super(
          filter: filter,
          printer: printer,
          output: output,
          level: level,
        );

  @override
  void log(
    Level level,
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    _startTime = DateTime.now();
    FlutterLogOverlay.addLog(
      isCore: level == Level.error,
      content: [getTime(), message],
    );
    super.log(
      level,
      message,
      error != null || stackTrace != null
          ? [
              error,
              stackTrace,
            ]
          : null,
    );
  }

  DateTime? _startTime;

  String getTime() {
    var now = DateTime.now();
    var year = _fourDigits(now.year);
    var month = _twoDigits(now.month);
    var day = _twoDigits(now.day);
    var h = _twoDigits(now.hour);
    var min = _twoDigits(now.minute);
    var sec = _twoDigits(now.second);
    var ms = _threeDigits(now.millisecond);
    var timeSinceStart = now.difference(_startTime!).toString();
    return '$year-$month-$day $h:$min:$sec.$ms (+$timeSinceStart)';
  }

  String _fourDigits(int n) {
    if (n >= 1000) return '$n';
    if (n >= 100) return '0$n';
    if (n >= 10) return '00$n';
    return '000$n';
  }

  String _threeDigits(int n) {
    if (n >= 100) return '$n';
    if (n >= 10) return '0$n';
    return '00$n';
  }

  String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }
}
```