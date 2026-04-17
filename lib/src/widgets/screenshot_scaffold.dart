import 'package:flutter/material.dart';
import '../config/models/device_spec.dart';
import 'fake_status_bar.dart';

/// Un wrapper che configura correttamente l'ambiente di rendering
/// per uno screenshot, gestendo Safe Area, Status Bar e MediaQuery.
class ScreenshotScaffold extends StatelessWidget {
  /// Il widget dell'applicazione da renderizzare.
  final Widget child;

  /// Il dispositivo su cui si sta simulando il rendering.
  final DeviceSpec device;

  /// Se includere la status bar simulata.
  final bool includeStatusBar;

  /// Il colore del contenuto della status bar (testo e icone).
  final Color statusBarContentColor;

  /// Una chiave opzionale per il [RepaintBoundary].
  final GlobalKey? boundaryKey;

  const ScreenshotScaffold({
    super.key,
    required this.child,
    required this.device,
    this.includeStatusBar = true,
    this.statusBarContentColor = Colors.black,
    this.boundaryKey,
  });

  @override
  Widget build(BuildContext context) {
    // Calcoliamo la dimensione logica considerando il devicePixelRatio
    final logicalSize = Size(
      device.resolution.width / device.pixelRatio,
      device.resolution.height / device.pixelRatio,
    );
    
    // Convertiamo i safe area physical pixels in logical pixels
    final logicalSafeArea = EdgeInsets.only(
      left: device.safeArea.left / device.pixelRatio,
      top: device.safeArea.top / device.pixelRatio,
      right: device.safeArea.right / device.pixelRatio,
      bottom: device.safeArea.bottom / device.pixelRatio,
    );

    Widget appRoot = child;

    if (includeStatusBar) {
      appRoot = Stack(
        children: [
          appRoot,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: FakeStatusBar.forDevice(
              device,
              contentColor: statusBarContentColor,
            ),
          ),
        ],
      );
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: MediaQueryData(
          size: logicalSize,
          devicePixelRatio: device.pixelRatio,
          padding: logicalSafeArea,
          viewPadding: logicalSafeArea,
          viewInsets: EdgeInsets.zero,
        ),
        child: RepaintBoundary(
          key: boundaryKey,
          child: SizedBox(
            width: logicalSize.width,
            height: logicalSize.height,
            child: appRoot,
          ),
        ),
      ),
    );
  }
}
