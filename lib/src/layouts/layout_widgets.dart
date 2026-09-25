import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../config/models/device_spec.dart';
import 'raw_path_resolver.dart';

/// Shared helpers for store screenshot rendering and export.
class LayoutWidgets {
  LayoutWidgets._();

  /// Preloads raw PNG bytes for [captureIds] (sync I/O).
  static Map<String, Uint8List> preloadRawImages({
    required String hostRootPath,
    required String rawScreenshotsPath,
    required String locale,
    required String deviceId,
    required Iterable<String> captureIds,
  }) {
    final cache = <String, Uint8List>{};
    for (final captureId in captureIds) {
      final path = RawPathResolver.rawScreenshotPath(
        hostRootPath: hostRootPath,
        rawScreenshotsPath: rawScreenshotsPath,
        locale: locale,
        deviceId: deviceId,
        captureId: captureId,
      );
      final file = File(path);
      if (file.existsSync()) {
        cache[path] = file.readAsBytesSync();
      }
    }
    return cache;
  }
}

/// Fixed-size canvas at device store resolution with a [RepaintBoundary].
class StoreScreenshotCanvas extends StatelessWidget {
  final DeviceSpec device;
  final Widget child;
  final Key boundaryKey;

  const StoreScreenshotCanvas({
    super.key,
    required this.device,
    required this.child,
    required this.boundaryKey,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: boundaryKey,
      child: SizedBox(
        width: device.resolution.width,
        height: device.resolution.height,
        child: MediaQuery(
          data: (MediaQuery.maybeOf(context) ?? const MediaQueryData())
              .copyWith(textScaler: TextScaler.noScaling),
          child: DefaultTextStyle(
            style: const TextStyle(
              decoration: TextDecoration.none,
              color: Colors.white,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
