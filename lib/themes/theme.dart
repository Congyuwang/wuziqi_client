import 'package:wuziqi/themes/field_background.dart';
import 'package:wuziqi/themes/basic/provider.dart';
import 'seed.dart';

/// Theme types.
enum GameTheme {
  /// basic black and white seeds
  basic,
}

/// Builders of game components
abstract class ThemeProvider {
  SeedBuilder get seedBuilder;
  FieldBackgroundBuilder get fieldBackgroundBuilder;
}

/// use `ThemeFactory.getProvider(Theme theme)` to load theme assets.
///
/// Requirement:
/// - seed Rive animation state machine name: `Seed`
class ThemeFactory {
  ThemeFactory(this.theme);
  final GameTheme theme;

  ThemeProvider getProvider() {
    switch (theme) {
      case GameTheme.basic:
        return BasicThemeProvider();
    }
  }
}
