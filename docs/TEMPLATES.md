# Templates & Building Blocks Guide

The Store Screenshots Generator uses an extensible, component-based `TemplateRegistry`. When a screen is defined in `screenshots.yaml`, it specifies a `template` identifier. During runtime, the engine uses this identifier to render the final composition using **Building Blocks**.

## Built-in Templates

The package provides standard out-of-the-box templates:

### 1. `default`
The basic template which places the raw screenshot wrapped in its device frame with a title and subtitle at the top.

### 2. `device_frame`
Similar to the default template, but specifically optimized for loading a fully rendered physical device frame matching the current processing device.

### 3. `split_screen`
A specialized template used for showing high-impact contrast. It uses a split background (top/bottom colors) with the device centered.

### 4. `solid_background`
Displays the device with a solid background and custom text placement, overriding any gradients.

## Building Blocks Architecture

To make template creation simple and declarative, the package provides a set of **Building Blocks** and **Layouts** that you can compose:

- **`StoreBackground`**: Handles solid colors and linear gradients automatically based on the variables provided.
- **`StoreText`**: A typography wrapper that automatically resolves localized strings, custom fonts, and fallback styles.
- **`DeviceMockup`**: Renders the screenshot inside its hardware frame, supporting advanced transformations like scale, rotation angle, and offsets.
- **`TopTextLayout`**: A common layout block that places text at the top and the device mockup at the bottom, handling spacing and padding.

All these components interact with a centralized **`TemplateContext`**, which provides easy access to resolved variables, localized strings, colors, and device specifications.

## Creating Custom Templates

You can inject your own templates before invoking the generation loop. A template is simply a function that takes a `TemplateContext` and returns a standard Flutter Widget.

1. Create a function matching the `TemplateBuilder` signature: `Widget Function(TemplateContext context)`.
2. Use the provided Building Blocks (or your own custom widgets) and pass them the `TemplateContext`.
3. Call `TemplateRegistry.register(name, builder)` in your CLI tool or custom wrapper.

**Example Implementation**:

```dart
import 'package:flutter/widgets.dart';
import 'package:store_screenshots_generator/src/registry/template_registry.dart';
import 'package:store_screenshots_generator/src/registry/template_context.dart';
import 'package:store_screenshots_generator/src/registry/templates/blocks/blocks.dart';
import 'package:store_screenshots_generator/src/registry/templates/layouts/layouts.dart';

void registerCustomTemplates() {
  TemplateRegistry.register('my_creative_template', (TemplateContext context) {
    
    return StoreBackground(
      context: context,
      fallbackBgColor: const Color(0xFF1E88E5), // Fallback if not in YAML
      child: Stack(
        children: [
          // Custom positioned text
          Positioned(
            top: 100,
            left: 50,
            child: StoreText(
              context: context,
              text: context.string('title', fallback: 'Default Title'),
              styleKey: 'title', // Will look for titleFont, titleColor
              defaultFontSize: 80,
              defaultColor: const Color(0xFFFFFFFF),
            ),
          ),
          
          // Rotated and scaled device mockup
          Positioned(
            bottom: -50,
            right: -50,
            child: DeviceMockup.fromContext(
              context,
              angle: 0.15, // Rotate by 15% of a radian
              scale: 1.2,  // Scale up by 20%
              shadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 40,
                  offset: Offset(0, 20),
                )
              ],
            ),
          ),
        ],
      ),
    );
  });
}
```

## Supported Variables in YAML

The `variables` map in the `screenshots.yaml` supports custom keys, but the core ones usually handled by built-in blocks and layouts are:
- `title` (Supports Locale Maps)
- `subtitle` (Supports Locale Maps)
- `gradientTop` (Hex color string)
- `gradientBottom` (Hex color string)
- `titleColor` (Hex color string)
- `subtitleColor` (Hex color string)
- `backgroundColor` (Hex color string, takes precedence over gradients in some templates)
- `backgroundColor1` / `backgroundColor2` (Used in `split_screen`)
