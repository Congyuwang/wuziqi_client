import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wuziqi/pages/game_page/seed_field.dart';
import 'package:wuziqi/themes/field_background.dart';
import '../../themes/theme.dart';
import '../../ffi.dart' as backend;

class GameField extends StatefulWidget {
  const GameField(
      {required this.fieldUpdateStream,
      required this.tapCallback,
      required this.gameTheme,
      Key? key})
      : super(key: key);

  final ThemeProvider gameTheme;
  final Stream<backend.Field> fieldUpdateStream;
  final Function(int, int) tapCallback;

  @override
  State<GameField> createState() => _GameFieldState();
}

class _GameFieldState extends State<GameField> {
  late SeedField seedField;
  late FieldBackground background;
  late Widget gameField;
  static const int fieldPX = 500;
  static const int seedPX = 30;
  static const int borderPX = 40;
  static const double paddingRatio = (borderPX - seedPX / 2) / fieldPX;

  @override
  void initState() {
    seedField = SeedField(
        fieldUpdateStream: widget.fieldUpdateStream,
        tapCallback: widget.tapCallback,
        gameTheme: widget.gameTheme);
    background = widget.gameTheme.fieldBackgroundBuilder();
    gameField = Expanded(child: LayoutBuilder(builder: (context, constraints) {
      final size = min(constraints.maxWidth, constraints.maxHeight);
      final halfSize = size / 2;
      final leftPadding = constraints.maxWidth / 2 - halfSize;
      final topPadding = constraints.maxHeight / 2 - halfSize;
      final paddingSize = paddingRatio * size;
      return Stack(
        children: [
          Positioned(
            child: background,
            left: leftPadding,
            top: topPadding,
            height: size,
            width: size,
          ),
          Positioned(
            child: seedField,
            left: leftPadding + paddingSize,
            top: topPadding + paddingSize,
            height: size - 2 * paddingSize,
            width: size - 2 * paddingSize,
          ),
        ],
      );
    }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return gameField;
  }
}
