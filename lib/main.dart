import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:wuziqi/pages/game_page/game_field.dart';
import 'package:wuziqi/themes/theme.dart';
import 'ffi.dart' as backend;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '五子棋',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: '五子棋'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(
      {Key? key, required this.title, this.gameTheme = GameTheme.basic})
      : super(key: key);

  final String title;
  final GameTheme gameTheme;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final StreamController<backend.Field> testController =
      StreamController<backend.Field>();
  Future<backend.Field> testField = backend.api.emptyField();
  bool isBlack = true;
  late ThemeProvider builders;

  @override
  void initState() {
    super.initState();
    builders = ThemeFactory(widget.gameTheme).getProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            isBlack ? const Text("playing black") : const Text("playing white"),
            GameField(
                fieldUpdateStream: testController.stream,
                tapCallback: (x, y) {
                  testController.addStream(testPlay(x, y,
                      isBlack ? backend.Color.Black : backend.Color.White));
                  // switch color
                  setState(() {
                    if (isBlack) {
                      isBlack = false;
                    } else {
                      isBlack = true;
                    }
                  });
                },
                gameTheme: builders),
          ],
        ),
      ),
      backgroundColor: Colors.green,
    );
  }

  /// this is test code
  Stream<backend.Field> testPlay(int x, int y, backend.Color color) async* {
    final bytes = (await testField)
        .rows
        .expand((e) => e.columns.map((s) {
              switch (s) {
                case backend.SingleState.B:
                  return 1;
                case backend.SingleState.W:
                  return 2;
                case backend.SingleState.E:
                  return 0;
              }
            }))
        .toList(growable: false);
    final field = await backend.api.constructFieldWithLatest(
        latestX: x, latestY: y, seeds: Uint8List.fromList(bytes));
    switch (color) {
      case backend.Color.Black:
        field.rows[x].columns[y] = backend.SingleState.B;
        break;
      case backend.Color.White:
        field.rows[x].columns[y] = backend.SingleState.W;
        break;
    }
    testField = Future.sync(() => field);
    yield field;
  }
}
