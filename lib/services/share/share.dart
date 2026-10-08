import 'dart:typed_data';

/// Platform-aware card export. Web downloads a PNG; mobile (later) will use
/// the native share sheet. Keeps `dart:html`/`package:web` out of shared code
/// so `flutter build apk/ipa` keeps working.
import 'share_stub.dart' if (dart.library.html) 'share_web.dart' as impl;

Future<void> exportCardPng(Uint8List pngBytes, String filename) =>
    impl.exportCardPng(pngBytes, filename);
