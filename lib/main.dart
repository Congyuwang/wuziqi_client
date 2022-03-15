import 'dart:async';

import 'package:flutter/material.dart';
import 'ffi.dart' as backend;
import 'game_field.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final StreamController<backend.Field> testController =
      StreamController<backend.Field>();
  late Future<backend.Field> testField;
  bool isBlack = true;

  @override
  void initState() {
    super.initState();
    testField = backend.api.emptyField();
    testPlay(5, 5, backend.Color.Black);
    testPlay(5, 6, backend.Color.White);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            isBlack ? const Text("playing black") : const Text("playing white"),
            Expanded(
              child: GameField(
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
                  }),
            )
          ],
        ),
      ),
      backgroundColor: Colors.green,
    );
  }

  Stream<backend.Field> testPlay(int x, int y, backend.Color color) async* {
    // update field latest position state
    // final field = await backend.api.modifyFieldLatest(
    //     field: await testField, latestX: x, latestY: y, latestColor: color);
    final field = await testField;
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
