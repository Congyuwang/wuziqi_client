import 'package:flutter/material.dart';

typedef FieldBackgroundBuilder = FieldBackground Function();

abstract class FieldBackground extends StatefulWidget {
  const FieldBackground({Key? key}) : super(key: key);
}
