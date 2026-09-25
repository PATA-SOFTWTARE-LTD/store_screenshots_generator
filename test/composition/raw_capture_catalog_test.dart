import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:store_screenshots_generator/studio.dart';

void main() {
  test('listCaptureIds scans PNG stems from disk', () {
    final temp = Directory.systemTemp.createTempSync('raw_catalog_');
    addTearDown(() {
      if (temp.existsSync()) temp.deleteSync(recursive: true);
    });

    final dir = Directory(
      '${temp.path}${Platform.pathSeparator}raw_screenshots'
      '${Platform.pathSeparator}en-US'
      '${Platform.pathSeparator}iphone_15_pro',
    )..createSync(recursive: true);

    for (final id in ['title_frame', 'full_bleed', 'minimal']) {
      File('${dir.path}${Platform.pathSeparator}$id.png')
          .writeAsBytesSync(const [0x89, 0x50, 0x4E, 0x47]);
    }

    final ids = RawCaptureCatalog.listCaptureIds(
      hostRootPath: temp.path,
      rawScreenshotsPath: 'raw_screenshots',
      locale: 'en-US',
      deviceId: 'iphone_15_pro',
    );

    expect(ids, contains('title_frame'));
    expect(ids, contains('full_bleed'));
    expect(ids, contains('minimal'));
    expect(ids, isNot(contains('')));
  });

  test('listCaptureIds returns empty for missing folder', () {
    final ids = RawCaptureCatalog.listCaptureIds(
      hostRootPath: Directory.systemTemp.path,
      rawScreenshotsPath: 'raw_screenshots_missing_xyz',
      locale: 'xx-XX',
      deviceId: 'iphone_15_pro',
    );
    expect(ids, isEmpty);
  });
}
