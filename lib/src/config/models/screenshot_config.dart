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

class LocaleConfig {
  final String locale;
  final List<ScreenshotConfig> screenshots;

  LocaleConfig({
    required this.locale,
    required this.screenshots,
  });

  factory LocaleConfig.fromJson(Map<String, dynamic> json) {
    final screenshots = (json['screenshots'] as List<dynamic>?)?.map((s) => ScreenshotConfig.fromJson(Map<String, dynamic>.from(s))).toList() ?? [];
    return LocaleConfig(
      locale: json['locale'] as String,
      screenshots: screenshots,
    );
  }
}

class ProjectConfig {
  final List<LocaleConfig> locales;
  final String? fontPath;
  final String deviceId;

  ProjectConfig({required this.locales, this.fontPath, this.deviceId = 'iphone_15_pro_max'});
  
  factory ProjectConfig.fromJson(Map<String, dynamic> json) {
    final locales = (json['locales'] as List<dynamic>?)?.map((l) => LocaleConfig.fromJson(Map<String, dynamic>.from(l))).toList() ?? [];
    return ProjectConfig(
      locales: locales,
      fontPath: json['fontPath'] as String?,
      deviceId: json['device'] as String? ?? 'iphone_15_pro_max',
    );
  }

  // A mock config for MVP
  static ProjectConfig get mock {
    return ProjectConfig(
      locales: [
        LocaleConfig(
          locale: 'en-US',
          screenshots: [
            ScreenshotConfig(
              id: '1',
              templateName: 'default',
              variables: {
                'title': 'Welcome to our App!',
                'subtitle': 'The best app on the store.',
                'backgroundColor': '#FF3366',
              },
            ),
          ],
        ),
      ],
    );
  }
}
