import 'dart:typed_data';

import 'package:flutter/widgets.dart';

/// Platform-aware card export. Web downloads a PNG; mobile/desktop open the
/// native share sheet with the PNG attached. Keeps `package:web` out of
/// shared code so `flutter build apk/ipa` keeps working.
import 'share_stub.dart'
    if (dart.library.html) 'share_web.dart'
    if (dart.library.io) 'share_mobile.dart' as impl;

Future<void> exportCardPng(Uint8List pngBytes, String filename,
        {Rect? sharePositionOrigin}) =>
    impl.exportCardPng(pngBytes, filename,
        sharePositionOrigin: sharePositionOrigin);
