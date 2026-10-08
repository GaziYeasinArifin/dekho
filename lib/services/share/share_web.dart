import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

/// Web implementation: trigger a PNG download via an anchor element.
Future<void> exportCardPng(Uint8List pngBytes, String filename,
    {Rect? sharePositionOrigin}) async {
  final blob =
      web.Blob([pngBytes.toJS].toJS, web.BlobPropertyBag(type: 'image/png'));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = filename;
  anchor.click();
  web.URL.revokeObjectURL(url);
}
