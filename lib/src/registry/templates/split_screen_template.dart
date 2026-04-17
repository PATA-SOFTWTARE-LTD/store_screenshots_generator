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
    final fontFamily = variables['fontFamily'] as String?;
    final deviceId = variables['deviceId'] as String? ?? 'iphone_15_pro';
    
    final device = DeviceRegistry.getById(deviceId);

    Color parseColor(String? hex, Color fallback) {
      if (hex == null || !hex.startsWith('#') || hex.length != 7) return fallback;
      return Color(int.parse('FF${hex.substring(1)}', radix: 16));
    }
    
    final backgroundColor1 = parseColor(variables['backgroundColor1'] as String?, const Color(0xFFF0F0F0));
    final backgroundColor2 = parseColor(variables['backgroundColor2'] as String?, const Color(0xFF222222));
    final titleColor = parseColor(variables['titleColor'] as String?, const Color(0xFF111111));
    final subtitleColor = parseColor(variables['subtitleColor'] as String?, const Color(0xFF444444));

    Widget innerScreen;
    if (imagePath != null && File(imagePath).existsSync()) {
      innerScreen = Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      );
    } else {
      innerScreen = Container(
        color: const Color(0xFFE0E0E0),
        child: const Center(
          child: Text('No Image', style: TextStyle(color: Color(0xFF888888))),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          // Background 1 (Top Half)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: MediaQuery.of(context).size.height / 2, // Non ideal, ma in headless questo widget ha accesso al size
            child: Container(color: backgroundColor1),
          ),
          // Background 2 (Bottom Half)
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height / 2,
            bottom: 0,
            child: Container(color: backgroundColor2),
          ),
          
          Column(
            children: [
              const SizedBox(height: 120),
              if (title.isNotEmpty || subtitle.isNotEmpty) ...[
                 _buildTextHeader(title, subtitle, titleColor, subtitleColor, fontFamily),
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

  Widget _buildTextHeader(String title, String subtitle, Color titleColor, Color subtitleColor, String? fontFamily) {
    return Column(
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 90,
                height: 1.1,
                fontWeight: FontWeight.w900,
                color: titleColor,
                letterSpacing: -1.0,
                fontFamily: fontFamily,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64.0),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 44,
                height: 1.3,
                fontWeight: FontWeight.w500,
                color: subtitleColor,
                fontFamily: fontFamily,
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

    if (!frameExists) {
      return Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(device.cornerRadius),
            border: Border.all(color: const Color(0xFF333333), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 40,
                offset: Offset(0, 0),
              )
            ],
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

    final totalWidth = device.resolution.width + device.framePadding.left + device.framePadding.right;
    final totalHeight = device.resolution.height + device.framePadding.top + device.framePadding.bottom;

    return Center(
      child: Container(
        decoration: const BoxDecoration(
          boxShadow: [
             BoxShadow(
              color: Color(0x66000000),
              blurRadius: 50,
              offset: Offset(0, 10),
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
                Positioned.fill(
                  child: Image.file(
                    File(device.frameAsset!),
                    fit: BoxFit.fill,
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
