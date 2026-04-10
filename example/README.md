# Store Screenshots Generator - Example 📱

This folder contains a ready-to-use setup showcasing the core capabilities of the generator, including multi-locale support and advanced templates.

## 📁 What's inside

- **`screenshots.yaml`**: The main configuration file.
    - Demonstrates localized content for `en-US` and `it-IT`.
    - Showcases two templates: `default` (text-only) and `device_frame` (image within a phone frame).
- **`screenshots/`**: Directory containing sample app screenshots to be wrapped inside device frames.

## 🚀 How to Run

From the **root of the project**, execute the following command:

```bash
dart run bin/generate.dart -c example/screenshots.yaml
```

*Note: Use `dart run store_screenshots_generator:generate` if the package is already installed as a dependency.*

## 🖼 Resulting Assets

The generator will process the config and create the following structure in the root `output/` directory:

```text
output/
├── en-US/
│   ├── welcome_screen.png  (Simple layout)
│   ├── stats_screen.png    (Simple layout)
│   └── 2_device_frame.png  (Screenshot wrapped in a smartphone frame)
└── it-IT/
    ├── welcome_screen.png  (Localized Italian)
    └── stats_screen.png    (Localized Italian)
```

## 🪄 Key Features to Observe

1.  **Typography**: Observe how the Italian text matches the English layout despite different string lengths.
2.  **Device Rendering**: Open `2_device_frame.png` to see the procedurally drawn iPhone-style frame, including the notch and bezels.
3.  **Recursive Pipeline**: Notice that `2_device_frame` uses another generated screenshot as its source image, demonstrating a build pipeline.
