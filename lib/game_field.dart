import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'theme.dart';
import 'ffi.dart' as backend;
import 'seed_animation.dart';

const int fieldSize = 15;

/// the GameField will try to maximize its size while still
/// being entirely contained and keeps its aspect ratio.
class GameField extends StatefulWidget {
  const GameField(
      {required this.fieldUpdateStream,
      required this.tapCallback,
      this.gameTheme = GameTheme.basic,
      Key? key})
      : super(key: key);

  final GameTheme gameTheme;
  final Stream<backend.Field> fieldUpdateStream;
  final Function(int, int) tapCallback;

  @override
  State<GameField> createState() => _GameFieldState();
}

class _GameFieldState extends State<GameField> {
  backend.Field? lastField;
  late List<List<StreamController<SeedState>>> seedStateStreams;
  late Widget fieldWidget;

  @override
  void initState() {
    super.initState();
    // the following three must be called in order
    seedStateStreams = buildSeedStreams();
    fieldWidget = listenFieldUpdate(layoutSeeds(buildSeeds(seedStateStreams)));
  }

  @override
  Widget build(BuildContext context) {
    return fieldWidget;
  }

  /// helper functions to build message channels for each cell
  static List<List<StreamController<SeedState>>> buildSeedStreams() {
    final index = [
      for (var i = 0; i < fieldSize; i += 1)
        [
          for (var j = 0; j < fieldSize; j += 1) [i, j]
        ]
    ];
    return index
        .map((e) =>
            e.map((e) => StreamController<SeedState>()).toList(growable: false))
        .toList(growable: false);
  }

  List<List<Seed>> buildSeeds(
      List<List<StreamController<SeedState>>> seedStreams) {
    return seedStreams
        .asMap()
        .map((x, row) => MapEntry(
            x,
            row
                .asMap()
                .map((y, s) => MapEntry(
                      y,
                      Seed(
                        key: ObjectKey(100 * x + y),
                        x: x,
                        y: y,
                        stateStream: s.stream,
                        theme: widget.gameTheme,
                        tapCallback: widget.tapCallback,
                      ),
                    ))
                .values
                .toList(growable: false)))
        .values
        .toList(growable: false);
  }

  /// construct the widget
  static Widget layoutSeeds(List<List<Seed>> allSeeds) {
    return Expanded(child: LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight);
        final halfSize = size / 2;
        final unitSize = size / fieldSize;
        final leftPadding = constraints.maxWidth / 2 - halfSize;
        final topPadding = constraints.maxHeight / 2 - halfSize;
        return Stack(
          children: allSeeds
              .expand((i) => i)
              .map((e) => Positioned(
                    child: e,
                    top: e.x * unitSize + topPadding,
                    height: unitSize,
                    left: e.y * unitSize + leftPadding,
                    width: unitSize,
                  ))
              .toList(growable: false),
        );
      })
    );
  }

  Widget listenFieldUpdate(Widget inner) {
    return StreamBuilder<backend.Field>(
      builder: (context, snap) {
        if (snap.hasData) {
          onFieldUpdate(snap.data!);
        }
        return inner;
      },
      stream: widget.fieldUpdateStream,
    );
  }

  /// compare with previous field to figure out which seeds are updated
  void onFieldUpdate(backend.Field field) {
    for (var x = 0; x < fieldSize; x += 1) {
      for (var y = 0; y < fieldSize; y += 1) {
        final state = field.rows[x].columns[y];
        final latest = isLatest(field.latestX, field.latestY, x, y);
        // in this case, the field is still empty
        if (lastField == null) {
          switch (state) {
            case backend.SingleState.E:
              // do nothing for empty state
              break;
            default:
              // update seeds
              seedStateStreams[x][y].add(SeedState(state, latest));
              break;
          }
        } else {
          final previous = lastField!;
          final previousState = previous.rows[x].columns[y];
          final previousLatest =
              isLatest(previous.latestX, previous.latestY, x, y);
          // update seed if state is updated
          if (state != previousState || latest != previousLatest) {
            seedStateStreams[x][y].add(SeedState(state, latest));
          }
        }
      }
    }
    lastField = field;
  }

  static bool isLatest(int? latestX, int? latestY, int x, int y) {
    return (latestX ?? -1) == x && (latestY ?? -1) == y;
  }
}
