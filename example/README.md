# Example host app

Minimal Flutter app that depends on `store_screenshots_generator` via path.

This example ships **source only** — no `raw_screenshots/` or `store_screenshots/` binaries.

## Layout

```
example/
  screenshots.yaml
  test/raw_screenshots_test.dart
  test/store_screenshots_test.dart
  lib/store_screenshots/generated/   # empty project until you design in Layout Studio
  lib/main.dart
```

## Try it

```bash
cd example
dart run store_screenshots_generator:capture_raw
```

Then open this `example/` folder in Layout Studio, add slots, export, or:

```bash
dart run store_screenshots_generator:export_store_screenshots --root .
```
