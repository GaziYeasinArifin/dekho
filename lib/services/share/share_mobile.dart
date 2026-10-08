import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

/// Mobile/desktop implementation: open the native share sheet with the
/// rendered card PNG attached.
Future<void> exportCardPng(Uint8List pngBytes, String filename,
    {Rect? sharePositionOrigin}) async {
  final file =
      XFile.fromData(pngBytes, name: filename, mimeType: 'image/png');
  await SharePlus.instance.share(
    ShareParams(
      files: [file],
      text: 'My Dekho travel map — apna desh, apna naksha!',
      sharePositionOrigin: sharePositionOrigin,
    ),
  );
}
