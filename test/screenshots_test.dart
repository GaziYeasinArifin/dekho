// Renders real screenshots of the app UI into test/goldens/.
// Run: flutter test --timeout 300s --update-goldens test/screenshots_test.dart
// NOTE: font loading must run inside tester.runAsync (engine calls hang
// in the testWidgets zone otherwise).
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dekho/main.dart';
import 'package:dekho/state/app_state.dart';

Future<void> _loadFonts() async {
  const base =
      '/home/hatch/sdks/flutter/bin/cache/artifacts/material_fonts';
  final loader = FontLoader('Roboto');
  for (final f in ['Roboto-Regular.ttf', 'Roboto-Bold.ttf', 'Roboto-Medium.ttf']) {
    final data = await File('$base/$f').readAsBytes();
    loader.addFont(Future.value(ByteData.sublistView(data)));
  }
  await loader.load();
  // Material icons so screenshots show real glyphs, not tofu.
  final iconData = await File('$base/MaterialIcons-Regular.otf').readAsBytes();
  final iconLoader = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.sublistView(iconData)));
  await iconLoader.load();
}

Future<void> _pumps(WidgetTester tester, [int n = 12]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('dekho screenshots', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.runAsync(_loadFonts);

    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final state = AppState();
    await state.init();
    await state.setUserName('Aarav');
    for (final s in [
      'Rajasthan', 'Kerala', 'Assam', 'Himachal Pradesh', 'Tamil Nadu', 'Goa'
    ]) {
      await state.toggleState(s);
    }
    await state.toggleGem('chand-baori');
    await state.toggleGem('nongriat');

    await tester.pumpWidget(DekhoApp(state: state));
    await _pumps(tester);

    await expectLater(
        find.byType(MaterialApp), matchesGoldenFile('goldens/01_map.png'));

    await tester.tap(find.text('Hidden Gems'));
    await _pumps(tester);
    await expectLater(
        find.byType(MaterialApp), matchesGoldenFile('goldens/02_gems.png'));

    await tester.tap(find.text('Trip Plan'));
    await _pumps(tester);
    await tester.tap(find.text('Plan my trip'));
    await _pumps(tester, 20);
    await expectLater(
        find.byType(MaterialApp), matchesGoldenFile('goldens/03_planner.png'));

    await tester.tap(find.text('Badges'));
    await _pumps(tester);
    await expectLater(
        find.byType(MaterialApp), matchesGoldenFile('goldens/04_badges.png'));
  }, timeout: const Timeout(Duration(minutes: 8)));
}
