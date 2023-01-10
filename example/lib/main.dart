import 'package:flutter/material.dart';
import 'package:flutter_log_overlay/flutter_log_overlay.dart';
import 'package:logger/logger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
}

///first page
class FirstPgae extends StatefulWidget {
  const FirstPgae({
    super.key,
  });

  @override
  State<FirstPgae> createState() => _FirstPgaeState();
}

class _FirstPgaeState extends State<FirstPgae> {
  void _incrementCounter() {
    sLog.i('first page add');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterLogOverlay.init(context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('first page'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SecondPage(),
                ),
              );
            },
            icon: const Icon(Icons.navigate_next),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            ElevatedButton(
              onPressed: FlutterLogOverlay.show,
              child: Text('show'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

///second page
class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  void _incrementCounter() {
    sLog.i('second page add');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('second page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            ElevatedButton(
              onPressed: FlutterLogOverlay.show,
              child: Text('show'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

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
      content: [
        getTime(),
        "--------------------",
        ((printer ?? PrettyPrinter()) as PrettyPrinter)
            .stringifyMessage(message),
      ],
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
