import 'ffi.dart';
import 'package:rive/rive.dart';
import 'theme.dart';
import 'package:flutter/material.dart';

class Seed extends StatefulWidget {
  const Seed(
      {Key? key,
      required this.theme,
      required this.x,
      required this.y,
      required this.stateStream,
      required this.tapCallback})
      : super(key: key);

  final GameTheme theme;
  final int x;
  final int y;
  final Stream<SeedState> stateStream;
  final void Function(int, int) tapCallback;

  @override
  State<Seed> createState() => _SeedState();
}

class _SeedState extends State<Seed> {
  static const seedStateMachine = 'Seed';
  static const stateController = 'state';
  static const activeController = 'active';

  SingleState seedState = SingleState.E;
  bool isLatest = false;
  SMINumber? _state;
  SMIBool? _active;

  late Widget seedWidget;

  @override
  void initState() {
    super.initState();
    final seedAnimation = RiveAnimation.asset(
      ThemeFactory(widget.theme).getProvider().seedRivePath,
      stateMachines: const [seedStateMachine],
      fit: BoxFit.contain,
      alignment: Alignment.center,
      onInit: _onRiveInit,
    );
    seedWidget = Expanded(child: AspectRatio(
      aspectRatio: 1.0,
        child: GestureDetector(
        onTap: _onTap,
        child: SeedStateListener(
            onStateUpdate: _updateState,
            stateStream: widget.stateStream,
            inner: seedAnimation))
    ));
  }

  @override
  Widget build(BuildContext context) {
    return seedWidget;
  }

  /// when an empty seed is tapped, execute `tapCallback`
  void _onTap() {
    switch (seedState) {
      case SingleState.E:
        widget.tapCallback(widget.x, widget.y);
        break;
      default:
        break;
    }
  }

  /// acquire animation controllers
  void _onRiveInit(Artboard artboard) {
    final controller =
        StateMachineController.fromArtboard(artboard, seedStateMachine);
    artboard.addController(controller!);
    _state = controller.findInput<double>(stateController) as SMINumber;
    _active = controller.findInput<bool>(activeController) as SMIBool;
  }

  /// controls the animation
  void _updateState(SeedState state) {
    seedState = state.state;
    isLatest = state.isLatest;
    _state?.change(_stateToSMINumber(state.state));
    _active?.change(state.isLatest);
  }

  double _stateToSMINumber(SingleState state) {
    switch (state) {
      case SingleState.B:
        return 1.0;
      case SingleState.W:
        return 2.0;
      case SingleState.E:
        return 0.0;
    }
  }
}

/// state of a single seed
class SeedState {
  SeedState(this.state, this.isLatest);
  final SingleState state;
  final bool isLatest;
}

/// widget that listens to seed state update
class SeedStateListener extends StatelessWidget {
  const SeedStateListener(
      {Key? key,
      required this.onStateUpdate,
      required this.stateStream,
      required this.inner})
      : super(key: key);

  final void Function(SeedState) onStateUpdate;
  final Stream<SeedState> stateStream;
  final Widget inner;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SeedState>(
      stream: stateStream,
      builder: (context, snap) {
        if (snap.data != null) {
          onStateUpdate(snap.data!);
        }
        return inner;
      },
    );
  }
}
