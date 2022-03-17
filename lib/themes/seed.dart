import 'package:flutter/material.dart';
import '../ffi.dart';

/// state of a single seed
class SeedState {
  SeedState(this.state, this.isLatest);
  final SingleState state;
  final bool isLatest;
}

/// A seed builder listens to seed state updates
typedef SeedBuilder = Seed Function(
    Stream<SeedState> seedStates, VoidCallback onTap, Key? key);

/// a seed listens to seed state changes,
/// and calls `onTap` callback when tapped on.
abstract class Seed extends StatefulWidget {
  const Seed({
    required Stream<SeedState> seedStates,
    required VoidCallback onTap,
    Key? key,
  }) : super(key: key);
}
