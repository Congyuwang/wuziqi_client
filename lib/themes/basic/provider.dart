import 'package:wuziqi/themes/basic/field_background.dart';

import '../seed.dart';
import '../theme.dart';
import 'seed.dart';

/// ThemeProvider includes assets for different themes.
class BasicThemeProvider extends ThemeProvider {
  @override
  SeedBuilder get seedBuilder {
    return (seedStates, onTap, key) =>
        BasicSeed(seedStates: seedStates, onTap: onTap, key: key);
  }

  @override
  get fieldBackgroundBuilder {
    return () => const BasicFieldBackground();
  }
}
