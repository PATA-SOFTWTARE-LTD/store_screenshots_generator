import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import '../../../config/models/device_spec.dart';
import '../../template_context.dart';

class DeviceMockup extends StatelessWidget {
  final DeviceSpec deviceSpec;
  final String? rawImagePath;
  final double angle;
  final double scale;
  final Offset offset;

  const DeviceMockup({
    super.key,
    required this.deviceSpec,
    this.rawImagePath,
    this.angle = 0.0,
    this.scale = 1.0,
    this.offset = Offset.zero,
  });

  factory DeviceMockup.fromContext(
    TemplateContext context, {
    String? customImagePath,
    double angle = 0.0,
    double scale = 1.0,
    Offset offset = Offset.zero,
  }) {
    return DeviceMockup(
      deviceSpec: context.device,
      rawImagePath: customImagePath ?? context.imagePath,
      angle: angle,
      scale: scale,
      offset: offset,
    );
  }

  @override
  Widget build(BuildContext context) {
    final frameExists = deviceSpec.frameAsset != null && File(deviceSpec.frameAsset!).existsSync();
    final hasRawImage = rawImagePath != null && File(rawImagePath!).existsSync();
    
    final totalWidth = deviceSpec.resolution.width + deviceSpec.framePadding.left + deviceSpec.framePadding.right;
    final totalHeight = deviceSpec.resolution.height + deviceSpec.framePadding.top + deviceSpec.framePadding.bottom;

    Widget innerScreen;
    if (hasRawImage) {
      innerScreen = Image.file(
        File(rawImagePath!),
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      );
    } else {
      innerScreen = Container(color: const Color(0xFFF5F5F5));
    }

    Widget mockup = Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: totalWidth,
          height: totalHeight,
          child: Stack(
            children: [
              Positioned(
                left: deviceSpec.framePadding.left,
                top: deviceSpec.framePadding.top,
                width: deviceSpec.resolution.width,
                height: deviceSpec.resolution.height,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(deviceSpec.cornerRadius),
                  child: innerScreen,
                ),
              ),
              if (frameExists)
                Positioned.fill(
                  child: Image.file(
                    File(deviceSpec.frameAsset!),
                    fit: BoxFit.fill,
                  ),
                )
              else
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(deviceSpec.cornerRadius),
                      border: Border.all(color: const Color(0xFF333333), width: 8),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (offset != Offset.zero || scale != 1.0 || angle != 0.0) {
      mockup = Transform(
        transform: Matrix4.identity()
          ..translate(offset.dx, offset.dy)
          ..scale(scale)
          ..rotateZ(angle * math.pi / 180),
        alignment: Alignment.center,
        child: mockup,
      );
    }

    return mockup;
  }
}
