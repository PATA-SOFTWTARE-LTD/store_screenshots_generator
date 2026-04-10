import 'dart:io';
import 'package:flutter/widgets.dart';
import '../../config/models/device_spec.dart';

/// A template that renders a screenshot inside a real hardware frame (PNG).
class DeviceFrameTemplate extends StatelessWidget {
  final Map<String, dynamic> variables;

  const DeviceFrameTemplate({super.key, required this.variables});

  @override
  Widget build(BuildContext context) {
    final title = variables['title'] as String? ?? 'App Title';
    final subtitle = variables['subtitle'] as String? ?? 'App Subtitle';
    final imagePath = variables['imagePath'] as String?;
    final fontFamily = variables['fontFamily'] as String?;
    final deviceId = variables['deviceId'] as String? ?? 'iphone_15_pro_max';
    
    final device = DeviceRegistry.getById(deviceId);

    // Color parsing helper
    Color parseColor(String? hex, Color fallback) {
      if (hex == null || !hex.startsWith('#') || hex.length != 7) return fallback;
      return Color(int.parse('FF${hex.substring(1)}', radix: 16));
    }
    
    final gradientTop = parseColor(variables['gradientTop'] as String?, const Color(0xFFF3E7D3));
    final gradientBottom = parseColor(variables['gradientBottom'] as String?, const Color(0xFF5CD5D5));
    final titleColor = parseColor(variables['titleColor'] as String?, const Color(0xFF1E88E5));
    final subtitleColor = parseColor(variables['subtitleColor'] as String?, const Color(0xFF111111));

    // Aspect Ratio Check
    if (imagePath != null && File(imagePath).existsSync()) {
      _validateImage(imagePath, device);
    }

    Widget innerScreen;
    if (imagePath != null && File(imagePath).existsSync()) {
      innerScreen = Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      );
    } else {
      innerScreen = Container(
        color: const Color(0xFFF5F5F5),
        child: const Center(
          child: Text('No Image', style: TextStyle(color: Color(0xFF888888))),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [gradientTop, gradientBottom],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 120),
            _buildTextHeader(title, subtitle, titleColor, subtitleColor, fontFamily),
            const SizedBox(height: 80),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80.0),
                child: _buildFrame(device, innerScreen),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextHeader(String title, String subtitle, Color titleColor, Color subtitleColor, String? fontFamily) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 84,
              height: 1.1,
              fontWeight: FontWeight.w800,
              color: titleColor,
              letterSpacing: -1.2,
              fontFamily: fontFamily,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 64.0),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 44,
              height: 1.2,
              fontWeight: FontWeight.w500,
              color: subtitleColor,
              fontFamily: fontFamily,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildFrame(DeviceSpec device, Widget innerScreen) {
    final frameExists = device.frameAsset != null && File(device.frameAsset!).existsSync();

    if (!frameExists) {
      // Very simple placeholder if NO frame is provided
      return Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(device.cornerRadius),
            border: Border.all(color: const Color(0xFF333333), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(device.cornerRadius - 2),
            child: AspectRatio(
              aspectRatio: device.aspectRatio,
              child: innerScreen,
            ),
          ),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Content
        Padding(
          padding: device.framePadding,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(device.cornerRadius),
            child: innerScreen,
          ),
        ),
        // Frame Image
        Image.file(
          File(device.frameAsset!),
          fit: BoxFit.contain,
        ),
      ],
    );
  }

  void _validateImage(String path, DeviceSpec device) {
    try {
      final file = File(path);
      final bytes = file.readAsBytesSync();
      final codec = decodeImageFromList(bytes);
      codec.then((image) {
        final imgAspectRatio = image.width / image.height;
        final devAspectRatio = device.aspectRatio;
        final diff = (imgAspectRatio - devAspectRatio).abs();
        
        if (diff > 0.05) {
          print('--- WARNING: Aspect Ratio Mismatch ---');
          print('Image: $path (${image.width}x${image.height})');
          print('Device: ${device.name} (ratio: ${devAspectRatio.toStringAsFixed(2)})');
          print('--------------------------------------');
        }
      });
    } catch (e) {}
  }
}

Widget deviceFrameTemplate(Map<String, dynamic> variables) {
  return DeviceFrameTemplate(variables: variables);
}
