import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/models/device_spec.dart';
import 'fake_status_bar.dart';

class _ScreenshotFontBootstrap {
  static Future<void>? _loadFuture;

  static Future<void> ensureLoaded() {
    _loadFuture ??= _load();
    return _loadFuture!;
  }

  static Future<void> _load() async {
    final medium = await rootBundle.load(
      'packages/store_screenshots_generator/assets/fonts/Roboto-Medium.ttf',
    );
    final semiBold = await rootBundle.load(
      'packages/store_screenshots_generator/assets/fonts/Roboto-SemiBold.ttf',
    );

    final statusBarLoader = FontLoader('StatusBarRoboto')
      ..addFont(Future.value(medium))
      ..addFont(Future.value(semiBold));

    final appTextLoader = FontLoader('Roboto')
      ..addFont(Future.value(medium))
      ..addFont(Future.value(semiBold));

    await Future.wait([
      statusBarLoader.load(),
      appTextLoader.load(),
    ]);
  }
}

/// Un wrapper che configura correttamente l'ambiente di rendering
/// per uno screenshot, gestendo Safe Area, Status Bar e MediaQuery.
class ScreenshotScaffold extends StatefulWidget {
  /// Il widget dell'applicazione da renderizzare.
  final Widget child;

  /// Il dispositivo su cui si sta simulando il rendering.
  final DeviceSpec device;

  /// Una chiave opzionale per il [RepaintBoundary].
  final GlobalKey? boundaryKey;

  const ScreenshotScaffold({
    super.key,
    required this.child,
    required this.device,
    this.boundaryKey,
  });

  @override
  State<ScreenshotScaffold> createState() => _ScreenshotScaffoldState();
}

class _ScreenshotScaffoldState extends State<ScreenshotScaffold> {
  late final Future<void> _fontsReady;

  @override
  void initState() {
    super.initState();
    _fontsReady = _ScreenshotFontBootstrap.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    const statusBarRawValue = String.fromEnvironment(
      'STATUS_BAR_MODE',
      defaultValue: 'dark',
    );
    final statusBarMode = StatusBarMode.fromConfigValue(statusBarRawValue);

    // Calcoliamo la dimensione logica considerando il devicePixelRatio
    final logicalSize = Size(
      widget.device.resolution.width / widget.device.pixelRatio,
      widget.device.resolution.height / widget.device.pixelRatio,
    );
    
    // Convertiamo i safe area physical pixels in logical pixels
    final logicalSafeArea = EdgeInsets.only(
      left: widget.device.safeArea.left / widget.device.pixelRatio,
      top: widget.device.safeArea.top / widget.device.pixelRatio,
      right: widget.device.safeArea.right / widget.device.pixelRatio,
      bottom: widget.device.safeArea.bottom / widget.device.pixelRatio,
    );

    Widget appRoot = widget.child;

    if (statusBarMode != StatusBarMode.hidden) {
      appRoot = Stack(
        children: [
          appRoot,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: FakeStatusBar.forDevice(
              widget.device,
              mode: statusBarMode,
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
          devicePixelRatio: widget.device.pixelRatio,
          padding: logicalSafeArea,
          viewPadding: logicalSafeArea,
          viewInsets: EdgeInsets.zero,
        ),
        child: FutureBuilder<void>(
          future: _fontsReady,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return SizedBox(
                width: logicalSize.width,
                height: logicalSize.height,
              );
            }
            return RepaintBoundary(
              key: widget.boundaryKey,
              child: SizedBox(
                width: logicalSize.width,
                height: logicalSize.height,
                child: appRoot,
              ),
            );
          },
        ),
      ),
    );
  }
}
