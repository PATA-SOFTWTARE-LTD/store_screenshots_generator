## 0.3.0

**Breaking:**
- Removed legacy `LayoutSpec` preset widgets, `layoutFromSpec`, `PresetDefaults`, and unused `StoreExportCore`. Compositions (`Composition` / `CompositionArtboard`) are the only layout IR.
- Split public API: host/CI imports `package:store_screenshots_generator/store_screenshots_generator.dart`; Layout Studio imports `package:store_screenshots_generator/studio.dart` for editor helpers (parser, snap, raw catalog).

**Added:**
- `init` CLI — scaffolds `screenshots.yaml`, `lib/store_screenshots/`, and test stubs in a host app
- `ProjectScaffold` — shared scaffold logic; `capture_raw` and `export_store_screenshots` auto-scaffold when files are missing
- `runStoreScreenshotExportTests` — package-side export test harness; host `test/store_screenshots_test.dart` is now a ~8-line stub
- Alignment snap while dragging in Layout Studio (Alt to bypass)
- Italic / underline / strikethrough text properties
- Proportional text/shadow scaling when adapting compositions across devices

**Changed:**
- Package metadata ready for pub.dev (`description`, `repository`, `topics`, version aligned with changelog)
- Capture logging is quieter by default (`verbose` opt-in)

## 0.2.0

**Breaking:** Replaced JSON `screenshot_studio/project.json` with code-first Dart layouts under `lib/store_screenshots/`.

**Added:**
- Composition IR, Layout Studio GUI, Dart codegen, and canvas editing
- `export_store_screenshots` CLI (replaces `export_studio`)

**Removed:**
- `export_studio` CLI and `lib/src/studio/` JSON composition model

## 0.1.0

**Breaking:** Removed the legacy `generate` CLI, YAML template system, and `TemplateRegistry`.

**Changed:** `screenshots.yaml` is now a capture manifest only (`id`, `name`, `preset` per screen).

## 0.0.1

* Initial release.
