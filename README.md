# Store Screenshots Generator

Generate localized App Store and Google Play screenshots from Flutter widgets — no emulators required.

| Product | Role |
|---------|------|
| **This package** | CLI + test harness + composition models (host apps / CI) |
| **Layout Studio** | Separate desktop app to design slots (private distribution) |

## Workflow

| Step | Tool | Result |
|------|------|--------|
| 0. Scaffold | `dart run store_screenshots_generator:init` | `screenshots.yaml`, generated stubs, tests |
| 1. Capture | `capture_raw` | `raw_screenshots/{locale}/{device}/{id}.png` |
| 2. Design | **Layout Studio** (separate app) | `lib/store_screenshots/generated/` (commit this) |
| 3. Export | Studio **Export** or `export_store_screenshots` | `store_screenshots/` |

`screenshots.yaml` defines **technical scope** (devices, locales, raw path). Store slots and layouts live in Layout Studio; persistence is generated Dart under `lib/store_screenshots/generated/`.

## Getting started (host app)

```yaml
dev_dependencies:
  store_screenshots_generator:
    git:
      url: https://github.com/PATA-SOFTWTARE-LTD/store_screenshots_generator.git
      ref: v0.3.0
```

After this package is on pub.dev you can use `store_screenshots_generator: ^0.3.0` instead.

### 0. Scaffold

```bash
dart run store_screenshots_generator:init --root path/to/my-app
```

### Host project layout

```
my-app/
  screenshots.yaml
  raw_screenshots/{locale}/{device}/{screen_id}.png   # produced by capture_raw
  lib/store_screenshots/layout_registry.dart
  lib/store_screenshots/generated/
    compositions.dart
    project.dart
  test/store_screenshots_test.dart
  test/raw_screenshots_test.dart
  store_screenshots/{locale}/{device}/01_{screen_id}.png  # produced by export
```

Raw and store PNGs are **not** shipped with this package; generate them in your app.

### 1. Capture raw screenshots

Edit `test/raw_screenshots_test.dart` with your routes, then:

```bash
dart run store_screenshots_generator:capture_raw
```

### 2. Design (Layout Studio)

Open your Flutter project root in Layout Studio (separate desktop app). Edits auto-save to `lib/store_screenshots/generated/`.

Host / CI imports:

```dart
import 'package:store_screenshots_generator/store_screenshots_generator.dart';
```

### 3. Export (CI)

```bash
dart run store_screenshots_generator:export_store_screenshots --root .
```

## Example

See [example/](example/) — a minimal host app (source only, no screenshot binaries).

## Docs

- [Usage](doc/USAGE.md)
- [Architecture](doc/ARCHITECTURE.md)

## Testing

```bash
flutter test
```

## License

MIT
