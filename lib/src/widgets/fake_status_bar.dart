import 'package:flutter/material.dart';
import '../config/models/device_spec.dart';

const String _kStatusBarFontFamily = 'StatusBarRoboto';

enum StatusBarMode {
  light,
  dark,
  hidden;

  static StatusBarMode fromConfigValue(String rawValue) {
    switch (rawValue.trim().toLowerCase()) {
      case 'light':
        return StatusBarMode.light;
      case 'dark':
        return StatusBarMode.dark;
      case 'hidden':
        return StatusBarMode.hidden;
    }
    throw ArgumentError(
      'Invalid status bar mode "$rawValue". Use: hidden, light, dark.',
    );
  }

  Color get contentColor {
    switch (this) {
      case StatusBarMode.light:
        return Colors.white;
      case StatusBarMode.dark:
        return Colors.black;
      case StatusBarMode.hidden:
        return Colors.transparent;
    }
  }
}

/// Un widget che simula la status bar nativa (iOS o Android)
/// per la cattura degli screenshot.
class FakeStatusBar extends StatelessWidget {
  final bool isIOS;
  final String timeText;
  final StatusBarMode mode;
  final double height;
  final DeviceSpec? deviceSpec;
  Color get contentColor => mode.contentColor;

  const FakeStatusBar({
    super.key,
    required this.isIOS,
    required this.mode,
    this.timeText = '9:41',
    this.height = 44.0,
    this.deviceSpec,
  });

  /// Crea una status bar ottimizzata per uno specifico dispositivo.
  factory FakeStatusBar.forDevice(
    DeviceSpec device, {
    StatusBarMode mode = StatusBarMode.dark,
    String timeText = '9:41',
  }) {
    final logicalTop = device.safeArea.top / device.pixelRatio;
    return FakeStatusBar(
      isIOS: device.id.startsWith('iphone') || device.id.startsWith('ipad'),
      timeText: timeText,
      mode: mode,
      height: logicalTop > 0 ? logicalTop : 44.0,
      deviceSpec: device,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (mode == StatusBarMode.hidden) {
      return const SizedBox.shrink();
    }

    return Container(
      height: height,
      padding: EdgeInsets.symmetric(
        horizontal: isIOS ? 32.0 : 16.0, // Più padding su iOS per allontanarsi dai bordi/angoli
      ),
      child: isIOS ? _buildIOSStatusBar() : _buildAndroidStatusBar(),
    );
  }

  Widget _buildIOSStatusBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Time (Left)
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Text(
            timeText,
            style: TextStyle(
              inherit: false,
              fontFamily: _kStatusBarFontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: contentColor,
              letterSpacing: -0.2,
            ),
          ),
        ),
        // Icons (Right)
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.signal_cellular_4_bar, size: 18, color: contentColor),
            const SizedBox(width: 8),
            Icon(Icons.wifi, size: 20, color: contentColor),
            const SizedBox(width: 8),
            _buildBatteryIcon(isIOS: true),
          ],
        ),
      ],
    );
  }

  Widget _buildAndroidStatusBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Time (Left)
        Text(
          timeText,
          style: TextStyle(
            inherit: false,
            fontFamily: _kStatusBarFontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: contentColor,
            letterSpacing: 0.1,
          ),
        ),
        // Icons (Right)
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.wifi, size: 18, color: contentColor),
            const SizedBox(width: 6),
            Icon(Icons.signal_cellular_4_bar, size: 18, color: contentColor),
            const SizedBox(width: 6),
            _buildBatteryIcon(isIOS: false),
          ],
        ),
      ],
    );
  }

  Widget _buildBatteryIcon({required bool isIOS}) {
    if (isIOS) {
      return Container(
        width: 25,
        height: 12,
        decoration: BoxDecoration(
          border: Border.all(color: contentColor.withValues(alpha: 0.4), width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.all(1.5),
          child: Container(
            decoration: BoxDecoration(
              color: contentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      );
    } else {
      // Android style battery
      return Icon(Icons.battery_full, size: 20, color: contentColor);
    }
  }
}
