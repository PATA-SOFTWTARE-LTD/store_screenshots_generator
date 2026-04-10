# Store Screenshots Generator 🚀

Generate beautiful, localized marketing screenshots for App Store and Google Play directly from Flutter widgets. No emulators required.

## 🌟 Features

- **Headless Rendering**: Uses the Flutter Test engine to render screenshots off-screen. Lightning fast and CI/CD friendly.
- **Responsive Device Frames**: Procedurally drawn smartphone frames (bezels, notch/dynamic island, shadows) that scale to any resolution.
- **Recursive Generation**: Use a previously generated screenshot as an input for another template (e.g., placing an app screen inside a device frame).
- **Multi-Locale Support**: Manage all languages and variants from a single YAML configuration file.
- **Custom Typography**: Support for custom `.ttf` font loading to match your brand identity.
- **Pure Flutter/Dart**: No external dependencies like Node.js or heavy SaaS platforms.

## 📦 Getting Started

Add the package as a development dependency in your `pubspec.yaml`:

```yaml
dev_dependencies:
  store_screenshots_generator:
    path: ../ # or latest version from pub.dev
```

## 🚀 Usage

### 1. Structure your Raw Screenshots
By default, the tool expects your raw screenshots (e.g. from integration tests) to be organized as follows:
`raw_screenshots/{locale}/{device_id}/{screen_id}.png`

### 2. Create a Configuration File
Create a `screenshots.yaml` file to define your devices, locales, and templates.

```yaml
rawScreenshotsPath: "raw_screenshots" # Base path for raw images
fontPath: "assets/fonts/Inter-Bold.ttf" # Optional: Custom branding

devices:
  - iphone_15_pro
  - ipad_pro_13

locales:
  - en-US
  - it-IT

screens:
  - id: "welcome"
    template: "default"
    variables:
      title: 
        en-US: "Welcome to App"
        it-IT: "Benvenuto nell'App"
      subtitle: 
        en-US: "The best experience on mobile"
        it-IT: "La migliore esperienza mobile"
      backgroundColor: "#1E88E5"

  - id: "device_promo"
    template: "device_frame"
    variables:
      title: 
        en-US: "Track Everything"
        it-IT: "Traccia Tutto"
      gradientTop: "#F4EDDC"
      gradientBottom: "#5FD1D3"
      # The frame template will automatically fetch:
      # raw_screenshots/{locale}/{device}/device_promo.png
```

### 3. Run the Generator
Execute the CLI tool pointing to your configuration:

```bash
dart run store_screenshots_generator:generate -c path/to/screenshots.yaml
```

### 4. Collect Output
Check the `output/` directory (created automatically). Your assets will be organized by locale and device:
- `output/en-US/iphone_15_pro/welcome.png`
- `output/en-US/ipad_pro_13/welcome.png`
- `output/it-IT/iphone_15_pro/welcome.png`

## 🛠 Advanced Usage

### Custom Templates
You can register your own widgets as templates in the `TemplateRegistry`. Each template receives a `Map<String, dynamic>` of variables defined in the YAML.

```dart
TemplateRegistry.register('my_custom_tmpl', (vars) {
  return MyCreativeWidget(
    title: vars['text'],
    color: vars['color'],
  );
});
```

## 🧪 Testing
The package includes a full test suite covering configuration parsing, template registration, and engine stability.

```bash
flutter test
```

## 📄 License
MIT
