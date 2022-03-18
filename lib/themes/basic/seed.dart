import '../../ffi.dart';
import 'package:rive/rive.dart';
import '../seed.dart';
import 'package:flutter/material.dart';

class BasicSeed extends Seed {
  static String themeFolder = "./assets/themes/basic";
  static String pathToRive = "$themeFolder/seed.riv";
  final Stream<SeedState> seedStates;
  final void Function() onTap;

  const BasicSeed({required this.seedStates, required this.onTap, Key? key})
      : super(seedStates: seedStates, onTap: onTap, key: key);

  @override
  State<BasicSeed> createState() => _BasicSeedState();
}

class _BasicSeedState extends State<BasicSeed> {
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
      BasicSeed.pathToRive,
      stateMachines: const [seedStateMachine],
      fit: BoxFit.contain,
      alignment: Alignment.center,
      onInit: _onRiveInit,
    );
    seedWidget = GestureDetector(
        onTap: _onTap,
        child: StreamBuilder<SeedState>(
          stream: widget.seedStates,
          builder: (context, snap) {
            if (snap.data != null) {
              _updateState(snap.data!);
            }
            return seedAnimation;
          },
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
        widget.onTap();
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
