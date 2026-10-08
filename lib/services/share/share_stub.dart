import 'dart:typed_data';

/// Fallback for non-web platforms until the native share sheet is wired up.
Future<void> exportCardPng(Uint8List pngBytes, String filename) async {
  throw UnimplementedError(
      'Card export is web-only for now; mobile share sheet coming with the app builds.');
}
