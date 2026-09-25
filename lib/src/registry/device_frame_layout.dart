import 'package:flutter/widgets.dart';

import '../config/models/device_spec.dart';

Size deviceFrameTotalSize(DeviceSpec device) {
  return Size(
    device.resolution.width +
        device.framePadding.left +
        device.framePadding.right,
    device.resolution.height +
        device.framePadding.top +
        device.framePadding.bottom,
  );
}

/// Device bezel + screen stack at logical pixel size (no outer [FittedBox]).
Widget buildDeviceFrameStack(DeviceSpec device, Widget innerScreen) {
  final totalSize = deviceFrameTotalSize(device);

  return SizedBox(
    width: totalSize.width,
    height: totalSize.height,
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
        if (device.frameAsset != null)
          Positioned.fill(
            child: Image.asset(
              device.frameAsset!,
              package: kDeviceFrameAssetPackage,
              fit: BoxFit.fill,
              errorBuilder: (_, error, stackTrace) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(device.cornerRadius),
                  border: Border.all(
                    color: const Color(0xFF333333),
                    width: 8,
                  ),
                ),
              ),
            ),
          )
        else
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(device.cornerRadius),
                border: Border.all(
                  color: const Color(0xFF333333),
                  width: 8,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

Widget buildDeviceFrameLayout(DeviceSpec device, Widget innerScreen) {
  return Center(
    child: FittedBox(
      fit: BoxFit.contain,
      child: buildDeviceFrameStack(device, innerScreen),
    ),
  );
}
