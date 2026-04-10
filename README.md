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

### 1. Create a Configuration File
Create a `screenshots.yaml` file to define your screenshots and locales.

```yaml
fontPath: "assets/fonts/Inter-Bold.ttf" # Optional: Custom branding
locales:
  - locale: "en-US"
    screenshots:
      - id: "welcome"
        template: "default"
        variables:
          title: "Welcome to App"
          subtitle: "The best experience on mobile"
          backgroundColor: "#1E88E5"

      - id: "device_promo"
        template: "device_frame"
        variables:
          title: "Track Everything"
          subtitle: "All your data in one place."
          gradientTop: "#F4EDDC"
          gradientBottom: "#5FD1D3"
          imagePath: "output/en-US/welcome.png" # Recursive loading!
```

### 2. Run the Generator
Execute the CLI tool pointing to your configuration:

```bash
dart run store_screenshots_generator:generate -c path/to/screenshots.yaml
```

### 3. Collect Output
Check the `output/` directory (created automatically). Your assets will be organized by locale:
- `output/en-US/welcome.png`
- `output/en-US/device_promo.png`

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
