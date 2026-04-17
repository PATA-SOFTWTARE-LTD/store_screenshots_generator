import 'dart:io';
import 'package:flutter/widgets.dart';
import '../../config/models/device_spec.dart';

class SplitScreenTemplate extends StatelessWidget {
  final Map<String, dynamic> variables;

  const SplitScreenTemplate({super.key, required this.variables});

  @override
  Widget build(BuildContext context) {
    final title = variables['title'] as String? ?? '';
    final subtitle = variables['subtitle'] as String? ?? '';
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
    
    final color1 = parseColor(variables['gradientTop'] ?? variables['backgroundColor1'], const Color(0xFFF0F0F0));
    final color2 = parseColor(variables['gradientBottom'] ?? variables['backgroundColor2'], const Color(0xFFE0E0E0));
    final titleColor = parseColor(variables['titleColor'], const Color(0xFF111111));
    final subtitleColor = parseColor(variables['subtitleColor'], const Color(0xFF444444));

    Widget innerScreen;
    if (imagePath != null && File(imagePath).existsSync()) {
      innerScreen = Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      );
    } else {
      innerScreen = Container(color: const Color(0xFFCCCCCC));
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          // Split Background
          Column(
            children: [
              Expanded(child: Container(color: color1)),
              Expanded(child: Container(color: color2)),
            ],
          ),
          
          // Content
          Column(
            children: [
              const SizedBox(height: 120),
              if (title.isNotEmpty || subtitle.isNotEmpty) ...[
                 _buildTextHeader(title, subtitle, titleColor, subtitleColor, titleFont, subtitleFont),
                 const SizedBox(height: 60),
              ],
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100.0),
                  child: _buildFrame(device, innerScreen),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextHeader(String title, String subtitle, Color titleColor, Color subtitleColor, String? titleFont, String? subtitleFont) {
    return Column(
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 88,
                height: 1.1,
                fontWeight: FontWeight.w900,
                color: titleColor,
                fontFamily: titleFont,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64.0),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 40,
                height: 1.3,
                fontWeight: FontWeight.w500,
                color: subtitleColor,
                fontFamily: subtitleFont,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildFrame(DeviceSpec device, Widget innerScreen) {
    final frameExists = device.frameAsset != null && File(device.frameAsset!).existsSync();
    final totalWidth = device.resolution.width + device.framePadding.left + device.framePadding.right;
    final totalHeight = device.resolution.height + device.framePadding.top + device.framePadding.bottom;

    return Center(
      child: Container(
        decoration: const BoxDecoration(
          boxShadow: [
             BoxShadow(
              color: Color(0x33000000),
              blurRadius: 40,
              offset: Offset(0, 20),
            )
          ]
        ),
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
                        border: Border.all(color: const Color(0xFF444444), width: 8),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget splitScreenTemplate(Map<String, dynamic> variables) {
  return SplitScreenTemplate(variables: variables);
}
