import 'dart:typed_data';

import 'package:flutter/widgets.dart';

/// Fallback for platforms with no share implementation (shouldn't happen:
/// web and io are both covered).
Future<void> exportCardPng(Uint8List pngBytes, String filename,
    {Rect? sharePositionOrigin}) async {
  throw UnimplementedError('Card export is not supported on this platform.');
}
