import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'ffi.dart' as backend;

const int fieldSize = 15;

class GameField extends StatefulWidget {
  const GameField(
      {required this.fieldUpdateStream,
      required this.tapCallback,
      this.themeName = "basic",
      Key? key})
      : super(key: key);

  final String themeName;
  final Stream<backend.Field> fieldUpdateStream;
  final Function(int, int) tapCallback;

  @override
  State<GameField> createState() => _GameFieldState();
}

class _GameFieldState extends State<GameField> {
  late Widget blackSeedPop;
  late Widget whiteSeedPop;
  late Widget blackSeed;
  late Widget whiteSeed;
  backend.Field? latestField;

  // load assets
  @override
  void initState() {
    super.initState();
    final String themeName = widget.themeName;
    final String themeFolder = "./assets/game_field_themes/$themeName";
    blackSeed = RiveAnimation.asset("$themeFolder/black_seed.riv");
    whiteSeed = RiveAnimation.asset("$themeFolder/white_seed.riv");
    blackSeedPop = RiveAnimation.asset("$themeFolder/black_seed_pop.riv");
    whiteSeedPop = RiveAnimation.asset("$themeFolder/black_seed_pop.riv");
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<backend.Field>(
      builder: (context, snap) {
        if (snap.data != null) {
          return AspectRatio(
            aspectRatio: 1.0,
            child: _drawField(snap.data!),
          );
        } else {
          return AspectRatio(
            aspectRatio: 1.0,
            child: _emptyField(),
          );
        }
      },
      stream: widget.fieldUpdateStream,
    );
  }

  /// build a field based on a list of `FieldRow`
  Widget _drawField(backend.Field field) {
    final latestX = field.latestX ?? -1;
    final latestY = field.latestY ?? -1;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: field.rows
          .asMap()
          .map((x, r) => MapEntry(
              x,
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: r.columns
                      .asMap()
                      .map((y, e) => MapEntry(
                          y,
                          _buildSingleSeed(
                              x: x,
                              y: y,
                              state: e,
                              isLatest: latestX == x && latestY == y)))
                      .values
                      .toList(growable: false))))
          .values
          .toList(growable: false),
    );
  }

  /// construct an empty field
  Widget _emptyField() {
    final index = [
      for (var i = 0; i < fieldSize; i += 1)
        [
          for (var j = 0; j < fieldSize; j += 1) [i, j]
        ]
    ];
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: index
          .map((r) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: r
                  .map((p) => _buildSingleSeed(
                      x: p.first,
                      y: p.last,
                      state: backend.SingleState.E,
                      isLatest: false))
                  .toList(growable: false)))
          .toList(growable: false),
    );
  }

  /// draw a single state
  Widget _buildSingleSeed({
    required int x,
    required int y,
    required backend.SingleState state,
    required bool isLatest,
  }) {
    switch (state) {
      case backend.SingleState.B:
        return Expanded(
            child: AspectRatio(
                aspectRatio: 1.0, child: isLatest ? blackSeedPop : blackSeed));
      case backend.SingleState.W:
        return Expanded(
            child: AspectRatio(
                aspectRatio: 1.0, child: isLatest ? whiteSeedPop : whiteSeed));
      case backend.SingleState.E:
        // allow tapping only for empty position
        return SingleSeedTap(
            x: x,
            y: y,
            inner: const Center(child: Text("E")),
            tapCallback: widget.tapCallback);
    }
  }
}

/// This widget implement the tap callback for a single position.
class SingleSeedTap extends StatelessWidget {
  const SingleSeedTap(
      {required this.x,
      required this.y,
      required this.inner,
      required this.tapCallback,
      Key? key})
      : super(key: key);

  final int x;
  final int y;
  final Widget inner;
  final Function(int, int) tapCallback;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
        onTap: _tryTap,
        child: Tooltip(
          message: "play($x, $y)",
          child: inner,
        ),
      ),
    ));
  }

  void _tryTap() {
    tapCallback(x, y);
  }
}
