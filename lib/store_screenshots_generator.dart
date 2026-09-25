library;

/// Host / CI public API for store screenshot capture and export.
///
/// Layout Studio should import `package:store_screenshots_generator/studio.dart`
/// for editor helpers (Dart parser, snap guides, raw capture catalog).

export 'src/capture/store_export_test_runner.dart';
export 'src/capture/raw_capturer.dart';
export 'src/capture/store_capturer.dart';
export 'src/capture/test_font_loader.dart';
export 'src/config/models/device_spec.dart';
export 'src/config/models/screenshot_config.dart';
export 'src/config/config_loader.dart';
export 'src/widgets/fake_status_bar.dart';
export 'src/widgets/screenshot_scaffold.dart';
export 'src/registry/device_frame_layout.dart';
export 'src/scaffold/project_scaffold.dart';
export 'src/composition/background_fill.dart';
export 'src/composition/composition_asset_paths.dart';
export 'src/composition/text_style_properties.dart';
export 'src/composition/composition_artboard.dart';
export 'src/composition/composition_capture.dart';
export 'src/composition/composition_export_core.dart';
export 'src/composition/composition_locale_text.dart';
export 'src/composition/composition_lookup.dart';
export 'src/composition/composition_presets.dart';
export 'src/composition/composition_scaler.dart';
export 'src/composition/models/composition.dart';
export 'src/composition/models/composition_key.dart';
export 'src/composition/models/element_frame.dart';
export 'src/composition/models/element_type.dart';
export 'src/composition/models/scene_element.dart';
export 'src/composition/models/store_slot.dart';
export 'src/composition/models/studio_project.dart';
export 'src/composition/studio_project_factory.dart';
export 'src/composition/composition_dart_emitter.dart';
export 'src/layouts/device_catalog.dart';
export 'src/layouts/element_colors.dart';
export 'src/layouts/layout_widgets.dart';
export 'src/layouts/raw_path_resolver.dart';
export 'src/layouts/store_screenshot_context.dart';
