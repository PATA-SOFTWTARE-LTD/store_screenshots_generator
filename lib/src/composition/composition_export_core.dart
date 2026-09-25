import 'dart:io';
import 'dart:typed_data';

import '../config/models/device_spec.dart';
import '../layouts/device_catalog.dart';
import '../layouts/layout_widgets.dart';
import '../layouts/store_screenshot_context.dart';
import 'composition_lookup.dart';
import 'models/composition.dart';
import '../composition/composition_capture.dart';
import 'models/studio_project.dart';

class CompositionExportProgress {
  final int completed;
  final int total;
  final String? currentLabel;

  const CompositionExportProgress({
    required this.completed,
    required this.total,
    this.currentLabel,
  });
}

class CompositionExportResult {
  final int exportedCount;
  final String outputRoot;
  final List<String> paths;

  const CompositionExportResult({
    required this.exportedCount,
    required this.outputRoot,
    required this.paths,
  });
}

typedef CompositionCapture = Future<Uint8List?> Function({
  required StudioProject project,
  required Composition composition,
  required DeviceSpec device,
  required StoreScreenshotContext renderContext,
});

/// Shared export loop for GUI, CI, and tests.
class CompositionExportCore {
  static const outputDirName = 'store_screenshots';

  static Future<CompositionExportResult> exportAll({
    required StudioProject project,
    required String hostRootPath,
    required CompositionCapture capture,
    void Function(CompositionExportProgress progress)? onProgress,
    bool syncIo = false,
  }) async {
    final outputRoot = '$hostRootPath${Platform.pathSeparator}$outputDirName';
    final dir = Directory(outputRoot);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final paths = <String>[];
    final slots = project.slots;
    final total = _exportableScreenshotCount(project);
    var completed = 0;

    for (final locale in project.locales) {
      for (final deviceId in project.deviceIds) {
        final device = DeviceCatalog.getById(deviceId);
        final deviceFolder = DeviceCatalog.fastlaneNameFor(deviceId);
        final localeDir = Directory(
          '$outputRoot${Platform.pathSeparator}$locale${Platform.pathSeparator}$deviceFolder',
        );
        if (!localeDir.existsSync()) {
          localeDir.createSync(recursive: true);
        }

        final imageCache = LayoutWidgets.preloadRawImages(
          hostRootPath: hostRootPath,
          rawScreenshotsPath: project.rawScreenshotsPath,
          locale: locale,
          deviceId: deviceId,
          captureIds: project.configuredRawCaptureIds().toSet(),
        );

        for (var i = 0; i < slots.length; i++) {
          final slot = slots[i];
          if (!slotIsExportable(project, slot)) continue;

          onProgress?.call(
            CompositionExportProgress(
              completed: completed,
              total: total,
              currentLabel: '$locale / $deviceFolder / ${slot.id}',
            ),
          );

          final composition = lookupComposition(
            project: project,
            locale: locale,
            deviceId: deviceId,
            slotId: slot.id,
          );

          final fileName =
              '${(i + 1).toString().padLeft(2, '0')}_${slot.id}.png';
          final outputPath =
              '${localeDir.path}${Platform.pathSeparator}$fileName';

          final renderContext = StoreScreenshotContext(
            hostRootPath: hostRootPath,
            rawScreenshotsPath: project.rawScreenshotsPath,
            locale: locale,
            deviceId: deviceId,
            slotId: slot.id,
            rawCaptureId: fallbackCaptureId(slot, composition.elements),
            fileImageCache: imageCache,
          );

          final bytes = await capture(
            project: project,
            composition: composition,
            device: device,
            renderContext: renderContext,
          );

          if (bytes != null) {
            if (syncIo) {
              File(outputPath).writeAsBytesSync(bytes);
            } else {
              await File(outputPath).writeAsBytes(bytes);
            }
            paths.add(outputPath);
          }

          completed++;
        }
      }
    }

    if (syncIo) {
      _writeReadmeSync(outputRoot);
    } else {
      await _writeReadme(outputRoot);
    }

    onProgress?.call(
      CompositionExportProgress(completed: total, total: total),
    );

    return CompositionExportResult(
      exportedCount: paths.length,
      outputRoot: outputRoot,
      paths: paths,
    );
  }

  static int _exportableScreenshotCount(StudioProject project) {
    var count = 0;
    for (final _ in project.locales) {
      for (final _ in project.deviceIds) {
        for (final slot in project.slots) {
          if (slotIsExportable(project, slot)) count++;
        }
      }
    }
    return count;
  }

  static void _writeReadmeSync(String outputRoot) {
    File(
      '$outputRoot${Platform.pathSeparator}README.md',
    ).writeAsStringSync(_readmeContent());
  }

  static Future<void> _writeReadme(String outputRoot) async {
    await File(
      '$outputRoot${Platform.pathSeparator}README.md',
    ).writeAsString(_readmeContent());
  }

  static String _readmeContent() => '''
# Store Screenshots

Exported by Layout Studio for Fastlane / manual store upload.

## Folder layout

```
store_screenshots/
  {locale}/
    {device}/
      01_{slot_id}.png
```

## Device folder names

${DeviceCatalog.allIds.map((id) => '- `$id` → `${DeviceCatalog.fastlaneNameFor(id)}`').join('\n')}
''';
}
