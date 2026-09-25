library;

/// Layout Studio / editor API.
///
/// Includes the host/CI surface plus helpers used only by the desktop editor:
/// generated-Dart parsing, snap guides, and raw capture catalog scanning.
///
/// Host apps and CI should import
/// `package:store_screenshots_generator/store_screenshots_generator.dart`
/// instead.

export 'store_screenshots_generator.dart';
export 'src/composition/composition_dart_parser.dart';
export 'src/composition/snap_geometry.dart';
export 'src/composition/raw_capture_catalog.dart';
