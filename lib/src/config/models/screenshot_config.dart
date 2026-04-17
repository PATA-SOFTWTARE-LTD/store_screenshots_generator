class ScreenshotConfig {
  final String id;
  final String templateName;
  final Map<String, dynamic> variables; // Text, colors, images paths

  ScreenshotConfig({
    required this.id,
    required this.templateName,
    this.variables = const {},
  });

  factory ScreenshotConfig.fromJson(Map<String, dynamic> json) {
    return ScreenshotConfig(
      id: json['id'] as String,
      templateName: json['template'] as String,
      variables: json['variables'] as Map<String, dynamic>? ?? {},
    );
  }
}

class FontConfig {
  final String family;
  final String path;

  FontConfig({required this.family, required this.path});

  factory FontConfig.fromJson(Map<String, dynamic> json) {
    return FontConfig(
      family: json['family'] as String,
      path: json['path'] as String,
    );
  }
}

class ProjectConfig {
  final List<String> devices;
  final List<String> locales;
  final List<ScreenshotConfig> screens;
  final List<FontConfig> fonts;
  final Map<String, dynamic> theme;
  final String rawScreenshotsPath;

  ProjectConfig({
    required this.devices,
    required this.locales,
    required this.screens,
    this.fonts = const [],
    this.theme = const {},
    this.rawScreenshotsPath = 'raw_screenshots',
  });
  
  factory ProjectConfig.fromJson(Map<String, dynamic> json) {
    final devices = (json['devices'] as List<dynamic>?)?.map((d) => d.toString()).toList() ?? [];
    final locales = (json['locales'] as List<dynamic>?)?.map((l) => l.toString()).toList() ?? [];
    final screens = (json['screens'] as List<dynamic>?)?.map((s) => ScreenshotConfig.fromJson(Map<String, dynamic>.from(s))).toList() ?? [];
    final fonts = (json['fonts'] as List<dynamic>?)?.map((f) => FontConfig.fromJson(Map<String, dynamic>.from(f))).toList() ?? [];
    
    return ProjectConfig(
      devices: devices.isNotEmpty ? devices : ['iphone_15_pro'], // fallback default
      locales: locales.isNotEmpty ? locales : ['en-US'], // fallback default
      screens: screens,
      fonts: fonts,
      theme: json['theme'] as Map<String, dynamic>? ?? {},
      rawScreenshotsPath: json['rawScreenshotsPath'] as String? ?? 'raw_screenshots',
    );
  }

  // A mock config for MVP
  static ProjectConfig get mock {
    return ProjectConfig(
      devices: ['iphone_15_pro'],
      locales: ['en-US'],
      screens: [
        ScreenshotConfig(
          id: 'welcome_screen',
          templateName: 'default',
          variables: {
            'title': {
              'en-US': 'Welcome to our App!',
            },
            'subtitle': {
              'en-US': 'The best app on the store.',
            },
            'backgroundColor': '#FF3366',
          },
        ),
      ],
    );
  }
}
