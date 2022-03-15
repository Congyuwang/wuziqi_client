/// Theme types.
enum GameTheme {
  /// basic black and white seeds
  basic,
}

/// ThemeProvider includes assets for different themes.
class ThemeProvider {
  ThemeProvider({required this.seedRivePath});
  final String seedRivePath;
}

/// use `ThemeFactory.getProvider(Theme theme)` to load theme assets.
///
/// Requirement:
/// - seed Rive animation state machine name: `Seed`
class ThemeFactory {
  ThemeFactory(this.theme);

  final GameTheme theme;

  ThemeProvider getProvider() {
    final String themeName = _fieldThemeName(theme);
    final String themeFolder = "./assets/themes/$themeName";
    return ThemeProvider(seedRivePath: "$themeFolder/seed.riv");
  }

  static String _fieldThemeName(GameTheme theme) {
    switch (theme) {
      case GameTheme.basic:
        return "basic";
    }
  }
}
