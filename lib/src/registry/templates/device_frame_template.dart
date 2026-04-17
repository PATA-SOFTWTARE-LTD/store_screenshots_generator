import 'dart:io';
import 'package:flutter/widgets.dart';
import '../../config/models/device_spec.dart';

class DeviceFrameTemplate extends StatelessWidget {
  final Map<String, dynamic> variables;

  const DeviceFrameTemplate({super.key, required this.variables});

  @override
  Widget build(BuildContext context) {
    final title = variables['title'] as String? ?? 'App Title';
    final subtitle = variables['subtitle'] as String? ?? 'App Subtitle';
    final imagePath = variables['imagePath'] as String?;
    final deviceId = variables['deviceId'] as String? ?? 'iphone_15_pro';
    
    // Theme values
    final titleFont = variables['titleFont'] as String?;
    final subtitleFont = variables['subtitleFont'] as String?;

    final device = DeviceRegistry.getById(deviceId);

    Color parseColor(dynamic value, Color fallback) {
      if (value is! String || !value.startsWith('#')) return fallback;
      final hex = value.substring(1);
      if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
      if (hex.length == 8) return Color(int.parse(hex, radix: 16));
      return fallback;
    }
    
    final gradTop = parseColor(variables['gradientTop'], const Color(0xFFF3E7D3));
    final gradBottom = parseColor(variables['gradientBottom'], const Color(0xFF5CD5D5));
    final titleColor = parseColor(variables['titleColor'], const Color(0xFF1E88E5));
    final subtitleColor = parseColor(variables['subtitleColor'], const Color(0xFF111111));

    Widget innerScreen;
    if (imagePath != null && File(imagePath).existsSync()) {
      innerScreen = Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      );
    } else {
      innerScreen = Container(color: const Color(0xFFF5F5F5));
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [gradTop, gradBottom],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 120),
            _buildTextHeader(title, subtitle, titleColor, subtitleColor, titleFont, subtitleFont),
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

  Widget _buildTextHeader(String title, String subtitle, Color titleColor, Color subtitleColor, String? titleFont, String? subtitleFont) {
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
              fontFamily: titleFont,
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
              fontFamily: subtitleFont,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildFrame(DeviceSpec device, Widget innerScreen) {
    final frameExists = device.frameAsset != null && File(device.frameAsset!).existsSync();
    final totalWidth = device.resolution.width + device.framePadding.left + device.framePadding.right;
    final totalHeight = device.resolution.height + device.framePadding.top + device.framePadding.bottom;

    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: totalWidth,
          height: totalHeight,
          child: Stack(
            children: [
              Positioned(
                left: device.framePadding.left,
                top: device.framePadding.top,
                width: device.resolution.width,
                height: device.resolution.height,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(device.cornerRadius),
                  child: innerScreen,
                ),
              ),
              if (frameExists)
                Positioned.fill(
                  child: Image.file(
                    File(device.frameAsset!),
                    fit: BoxFit.fill,
                  ),
                )
              else
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(device.cornerRadius),
                      border: Border.all(color: const Color(0xFF333333), width: 8),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget deviceFrameTemplate(Map<String, dynamic> variables) {
  return DeviceFrameTemplate(variables: variables);
}
