# Templates Guide

The Store Screenshots Generator is built on an extensible `TemplateRegistry`. When a screenshot is defined in `screenshots.yaml`, it specifies a `template` identifier. During runtime, the engine looks up this identifier to render the final composition.

## Built-in Templates

The package provides standard out-of-the-box templates:

### 1. `default`
The basic template which just places the raw screenshot and a text.

### 2. `device_frame`
Wraps the raw screenshot in a fully rendered physical device frame matching the currently processing device (e.g., iPhone 15 Pro, Pixel 4 XL) and applies localized texts above it.

### 3. `split_screen` (Sprint 2 Feature)
A specialized template used for showing high-impact contrast or showing two features on the same image.

### 4. `solid_background` (Sprint 2 Feature)
Displays the device with a solid background and custom text placement, overriding any gradients.

## Creating Custom Templates

You can inject your own templates before invoking the generation loop. A template is simply a Flutter widget that takes standard parameters injected by the engine.

1. Create a `StatelessWidget`.
2. Add fields for variables defined in `screenshots.yaml` (e.g., `title`, `gradientTop`, `titleColor`).
3. Call `TemplateRegistry.register(name, builder)` in your CLI tool or custom wrapper.

**Example Implementation**:

```dart
import 'package:flutter/material.dart';
import 'package:store_screenshots_generator/src/registry/template_registry.dart';

void registerCustomTemplates() {
  TemplateRegistry.register('my_creative_template', (variables, rawScreenshotImage, deviceSpec) {
    return Container(
      color: _parseColor(variables['backgroundColor']),
      child: Stack(
        children: [
          // Text positioned at the top
          Positioned(
            top: 100,
            left: 50,
            child: Text(
              variables['title'] ?? '',
              style: TextStyle(
                fontSize: 80,
                color: _parseColor(variables['titleColor']),
                fontFamily: 'MyCustomFont', // Will be loaded automatically if defined in yaml
              ),
            ),
          ),
          // Device centered
          Center(
            child: Image(image: rawScreenshotImage),
          ),
        ],
      ),
    );
  });
}
```

## Supported Variables in YAML

The `variables` map in the `screenshots.yaml` supports everything you want to pass, but the core ones usually handled by built-in templates are:
- `title` (Supports Locale Maps)
- `subtitle` (Supports Locale Maps)
- `gradientTop` (Hex color string)
- `gradientBottom` (Hex color string)
- `titleColor` (Hex color string)
- `subtitleColor` (Hex color string)
- `backgroundColor` (Hex color string, takes precedence over gradients)
