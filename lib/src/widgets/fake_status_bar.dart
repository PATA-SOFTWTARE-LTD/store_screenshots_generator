import 'package:flutter/material.dart';

/// Un widget che simula la status bar nativa (iOS o Android)
/// per la cattura degli screenshot.
class FakeStatusBar extends StatelessWidget {
  final bool isIOS;
  final String timeText;
  final Color contentColor;
  final double height;

  const FakeStatusBar({
    super.key,
    required this.isIOS,
    this.timeText = '9:41',
    this.contentColor = Colors.black,
    this.height = 44.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
              fontFamily: 'Roboto',
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
            fontFamily: 'Roboto',
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
          border: Border.all(color: contentColor.withOpacity(0.4), width: 1),
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
