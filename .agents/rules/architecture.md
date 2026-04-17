---
trigger: always_on
glob: "**/*.dart, **/*.yaml, README.md"
description: Architecture overview and development guidelines for store_screenshots_generator.
---

# Store Screenshots Generator Architecture

This document provides a technical overview of the project architecture to assist AI agents in understanding how the tool works and how to extend it.

## 🚀 Core Philosophy
The project generates marketing screenshots for mobile app stores directly from Flutter widgets. It leverages **headless rendering** via the `flutter_test` engine to achieve high-speed generation without requiring emulators or real devices.

## 🏗 Key Components

### 1. Configuration (`lib/src/config/`)
- **`ProjectConfig`**: The root configuration object, typically loaded from `screenshots.yaml`.
- **`ScreenshotConfig`**: Defines a single screenshot (id, template, and localized variables).
- **`DeviceSpec`**: Contains physical resolution, corner radius, and frame asset information for specific devices.

### 2. Rendering Engine (`lib/src/engine/`)
- **`HeadlessRunner`**: Orchestrates the generation process.
- **Runtime Mechanism**: 
    1. Generates a temporary test file at `test/temp_render_test.dart`.
    2. Executes this file using `flutter test`.
    3. The generated test script renders widgets into a `RepaintBoundary` and exports them as PNGs.
- **Pre-caching**: Critical for rendering! The engine must precache both the device frame and the raw screenshot images before capturing the frame.

### 3. Template System (`lib/src/registry/`)
- **`TemplateRegistry`**: A central hub where widget builders are mapped to string keys (e.g., "default", "device_frame").
- **Custom Templates**: To add a new design, create a widget builder function and register it in the `TemplateRegistry`.

### 4. Device Management (`lib/src/config/models/device_spec.dart`)
- **`DeviceRegistry`**: Hardcoded repository of supported devices. Each entry includes:
    - `id`: Unique identifier (e.g., `iphone_15_pro`).
    - `resolution`: Physical pixels (important for App Store compliance).
    - `frameAsset`: Path to the bezel/frame PNG.
    - `framePadding`: Insets where the app UI should be placed within the frame.

## 📂 Data Flow

1. **Input**: `screenshots.yaml` + `raw_screenshots/{locale}/{device_id}/{screen}.png`.
2. **Processing**: `HeadlessRunner` builds a dynamic test suite.
3. **Rendering**: `flutter test` initializes a Skia/Impeller surface with the device's resolution.
4. **Output**: Beautiful, framed, and localized PNGs in `output/{locale}/{device_id}/{screen}.png`.

## 🛠 Guidelines for AI Agents

- **Modifying Templates**: Look into `lib/src/registry/templates/`. Ensure localized variables are handled correctly (mapping `Map<String, dynamic>` to the correct locale value).
- **Adding Devices**: Update `DeviceRegistry` in `device_spec.dart`. High-resolution displays are preferred.
- **Rendering Issues**: If images are missing in the output, it's usually due to:
    - Failing to `precacheImage`.
    - Incorrect physical size set in `WidgetTester`.
    - Asynchonous loading not being awaited with `tester.pumpAndSettle()`.
- **CLI Changes**: Modify `lib/src/cli/command_runner.dart` to add new flags or options.
- **Documentation**: EVERY time a new feature or command-line option is added, you MUST update `docs/USAGE.md` to reflect the changes.
