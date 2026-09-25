/// Capture-scope manifest parsed from [screenshots.yaml].
///
/// Store screenshot slots are defined in Layout Studio (`generated/`), not here.
class ProjectConfig {
  final List<String> devices;
  final List<String> locales;
  final String rawScreenshotsPath;
  final String statusBar;

  const ProjectConfig({
    required this.devices,
    required this.locales,
    this.rawScreenshotsPath = 'raw_screenshots',
    this.statusBar = 'dark',
  });

  factory ProjectConfig.fromJson(Map<String, dynamic> json) {
    final devices =
        (json['devices'] as List<dynamic>?)
            ?.map((d) => d.toString())
            .toList() ??
        [];
    final locales =
        (json['locales'] as List<dynamic>?)
            ?.map((l) => l.toString())
            .toList() ??
        [];

    return ProjectConfig(
      devices: devices.isNotEmpty
          ? devices
          : ['iphone_15_pro'],
      locales: locales.isNotEmpty ? locales : ['en-US'],
      rawScreenshotsPath:
          json['rawScreenshotsPath'] as String? ?? 'raw_screenshots',
      statusBar: json['statusBar'] as String? ?? 'dark',
    );
  }
}
