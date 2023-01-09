import 'package:flutter/material.dart';
import 'package:flutter_log_overlay/flutter_log_overlay.dart';

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
    FlutterLogOverlay.addLog(
      isCore: false,
      content: 'content',
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterLogOverlay.notMaterialAppContext = context;
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('second page'),
      ),
    );
  }
}
