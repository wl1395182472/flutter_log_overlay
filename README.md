## Usage

Must
```dart
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterLogOverlay.notMaterialAppContext = context;
      FlutterLogOverlay.logOverlayWidget = const LogOverlayWidget(
        width: 300.0,
        height: 500.0,
      );
    });
  }
```

Optional
```dart
    return GestureDetector(
      onPanEnd: FlutterLogOverlay.showOverlayPan,
      behavior: HitTestBehavior.translucent,
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MyHomePage(),
      ),
    );
```