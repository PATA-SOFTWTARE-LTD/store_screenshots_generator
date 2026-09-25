# Usage Guide

## Overview

1. **Scaffold** — `init` (or auto on first CLI run)
2. **Capture** — `capture_raw` writes widget screenshots to `raw_screenshots/`
3. **Design** — Layout Studio (separate desktop app) defines slots and compositions
4. **Export** — Layout Studio **Export** or `export_store_screenshots` writes `store_screenshots/`

This **package** is for host apps and CI. Layout Studio is distributed separately.

## Init scaffold

```bash
dart run store_screenshots_generator:init --root path/to/flutter/app
```

Store export test stub (`test/store_screenshots_test.dart`):

```dart
import 'package:my_app/store_screenshots/layout_registry.dart';
import 'package:store_screenshots_generator/store_screenshots_generator.dart';

void main() {
  runStoreScreenshotExportTests(loadProject: loadGeneratedStudioProject);
}
```

## `screenshots.yaml` (technical scope only)

```yaml
rawScreenshotsPath: raw_screenshots
statusBar: dark

devices:
  - iphone_15_pro
  - pixel_8

locales:
  - en-US
  - it-IT
```

Store slots are **not** listed here. Define them in Layout Studio (`generated/project.dart`).

## Capture raw screenshots

```bash
dart run store_screenshots_generator:capture_raw
```

Output: `raw_screenshots/{locale}/{device_id}/{capture_id}.png` (local to your app — not part of this package).

## Generated compositions (do not edit by hand)

Layout Studio writes:

```
lib/store_screenshots/
  layout_registry.dart
  generated/
    compositions.dart
    project.dart
```

## CI export

```bash
dart run store_screenshots_generator:export_store_screenshots --root path/to/flutter/project
```

## Composition presets

Bootstrap templates for new slots:

- `title_and_frame`
- `full_bleed`
- `minimal`

## Public libraries

| Import | Audience |
|--------|----------|
| `package:store_screenshots_generator/store_screenshots_generator.dart` | Host apps, generated Dart, CI |
| `package:store_screenshots_generator/studio.dart` | Layout Studio only |
