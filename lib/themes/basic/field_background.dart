import 'package:flutter/material.dart';
import 'package:wuziqi/themes/field_background.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BasicFieldBackground extends FieldBackground {
  const BasicFieldBackground({Key? key}) : super(key: key);
  static String themeFolder = "./assets/themes/basic";
  static String gameFieldSVG = "$themeFolder/game_field.svg";

  @override
  State<BasicFieldBackground> createState() => _BasicFieldBackgroundState();
}

class _BasicFieldBackgroundState extends State<BasicFieldBackground> {
  static Widget backGround = SvgPicture.asset(
    BasicFieldBackground.gameFieldSVG,
    fit: BoxFit.contain,
    alignment: Alignment.center,
  );

  @override
  Widget build(BuildContext context) {
    return backGround;
  }
}
