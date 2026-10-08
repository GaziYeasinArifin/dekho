// Renders real screenshots of the app UI into test/goldens/.
// Run: flutter test --update-goldens test/screenshots_test.dart
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
}

void main() {
  testWidgets('dekho screenshots', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await _loadFonts();

    // iPhone-ish canvas
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final state = AppState();
    await state.init();
    state.setUserName('Aarav');
    for (final s in [
      'Rajasthan', 'Kerala', 'Assam', 'Himachal Pradesh', 'Tamil Nadu', 'Goa'
    ]) {
      state.toggleState(s);
    }
    state.toggleGem('chand-baori');
    state.toggleGem('nongriat');

    await tester.pumpWidget(DekhoApp(state: state));
    await tester.pumpAndSettle();

    // 1. Map tab
    await expectLater(
        find.byType(MaterialApp), matchesGoldenFile('goldens/01_map.png'));

    // 2. Hidden Gems tab
    await tester.tap(find.text('Hidden Gems'));
    await tester.pumpAndSettle();
    await expectLater(
        find.byType(MaterialApp), matchesGoldenFile('goldens/02_gems.png'));

    // 3. Trip Plan tab + generate a plan
    await tester.tap(find.text('Trip Plan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Plan my trip'));
    await tester.pumpAndSettle();
    await expectLater(
        find.byType(MaterialApp), matchesGoldenFile('goldens/03_planner.png'));

    // 4. Badges tab
    await tester.tap(find.text('Badges'));
    await tester.pumpAndSettle();
    await expectLater(
        find.byType(MaterialApp), matchesGoldenFile('goldens/04_badges.png'));
  });
}
