// Widget interaction tests: map taps, tab navigation, planner output,
// gem search, locale toggle. Uses bounded pumps (no pumpAndSettle).
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dekho/main.dart';
import 'package:dekho/state/app_state.dart';
import 'package:dekho/widgets/district_map.dart';
import 'package:dekho/widgets/india_map.dart';

Future<AppState> _app(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final state = AppState();
  await state.init();
  await tester.pumpWidget(DekhoApp(state: state));
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  return state;
}

Future<void> _pumps(WidgetTester tester, [int n = 8]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Tap Rajasthan at its map-space label (184, 308).
/// Note: two IndiaMaps exist (screen + offscreen share card); the screen's
/// is first in the tree.
Future<void> _tapRajasthan(WidgetTester tester) async {
  final mapFinder = find.byType(IndiaMap).first;
  final scrollable = find.byType(SingleChildScrollView).first;
  // The Rajasthan tap point sits in the map's upper third. The screen has
  // grown taller, so drag the scroll view until the point clears the
  // bottom nav (test viewport is only 600px tall).
  for (var i = 0; i < 4; i++) {
    final rect = tester.getRect(mapFinder);
    final scale = min(rect.width, rect.height) / 1000;
    final dx = (rect.width - 1000 * scale) / 2;
    final dy = (rect.height - 1000 * scale) / 2;
    final pt =
        rect.topLeft + Offset(dx + 184 * scale, dy + 308 * scale);
    if (pt.dy < 500) {
      await tester.tapAt(pt);
      await _pumps(tester);
      return;
    }
    await tester.drag(scrollable, const Offset(0, -160));
    await _pumps(tester);
  }
  fail('could not bring the Rajasthan tap point into view');
}

void main() {
  group('map interactions', () {
    testWidgets('tapping Rajasthan toggles visited + counter',
        (tester) async {
      final state = await _app(tester);
      expect(find.text('0 / 36'), findsOneWidget);

      await _tapRajasthan(tester);
      expect(state.visitedStates, contains('Rajasthan'));
      expect(find.text('1 / 36'), findsOneWidget);

      await _tapRajasthan(tester);
      expect(state.visitedStates, isNot(contains('Rajasthan')));
      expect(find.text('0 / 36'), findsOneWidget);
    });

    testWidgets('visited state persists across restart', (tester) async {
      final state = await _app(tester);
      await _tapRajasthan(tester);
      expect(state.visitedStates, contains('Rajasthan'));

      // "restart": new widget tree, same mock storage
      final state2 = AppState();
      await state2.init();
      expect(state2.visitedStates, contains('Rajasthan'));
    });
  });

  group('district collection', () {
    testWidgets('districts mode toggles a district + counter',
        (tester) async {
      final state = await _app(tester);
      // switch to Districts level
      await tester.tap(find.text('Districts'));
      await _pumps(tester);
      expect(find.text('0 / 785'), findsOneWidget);

      // tap the center of the district map (Rajasthan's default view).
      // The map may sit low on the short test viewport, so drag it up first.
      final mapFinder = find.byType(DistrictMap);
      expect(mapFinder, findsOneWidget);
      final scrollable = find.byType(Scrollable).first;
      for (var i = 0; i < 4; i++) {
        final rect = tester.getRect(mapFinder);
        if (rect.center.dy < 500) break;
        await tester.drag(scrollable, const Offset(0, -160));
        await _pumps(tester);
      }
      final rect = tester.getRect(mapFinder);
      await tester.tapAt(rect.center);
      await _pumps(tester);
      expect(state.districtsCount, 1);
      expect(find.text('1 / 785'), findsOneWidget);

      // persistence across restart
      final state2 = AppState();
      await state2.init();
      expect(state2.districtsCount, 1);
    });
  });

  group('navigation', () {    testWidgets('all four tabs render', (tester) async {
      await _app(tester);
      await tester.tap(find.text('Hidden Gems'));
      await _pumps(tester);
      expect(find.text('Hidden Gems').first, findsWidgets);

      await tester.tap(find.text('Trip Plan'));
      await _pumps(tester);
      expect(find.text('Plan my trip'), findsOneWidget);

      await tester.tap(find.text('Badges'));
      await _pumps(tester);
      expect(find.text('Badges').first, findsWidgets);

      await tester.tap(find.text('My Map'));
      await _pumps(tester);
      expect(find.text('0 / 36'), findsOneWidget);
    });
  });

  group('planner UI', () {
    testWidgets('plan button renders one card per requested day',
        (tester) async {
      await _app(tester);
      await tester.tap(find.text('Trip Plan'));
      await _pumps(tester);
      await tester.scrollUntilVisible(find.text('Plan my trip'), 200);
      await _pumps(tester);
      await tester.tap(find.text('Plan my trip'));
      await _pumps(tester, 12);
      // default is 4 days -> Day 1..4 cards
      expect(find.text('Day 1'), findsOneWidget);
      expect(find.text('Day 4'), findsOneWidget);
      expect(find.text('Day 5'), findsNothing);
    });
  });

  group('gems UI', () {
    testWidgets('search filters the gem list', (tester) async {
      await _app(tester);
      await tester.tap(find.text('Hidden Gems'));
      await _pumps(tester);
      expect(find.text('Chand Baori'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'bekal');
      await _pumps(tester);
      expect(find.text('Chand Baori'), findsNothing);
      expect(find.text('Bekal Fort'), findsOneWidget);
    });
  });

  group('locale', () {
    testWidgets('EN/हिं toggle switches UI language', (tester) async {
      final state = await _app(tester);
      expect(find.text('My Map'), findsOneWidget);
      await state.setLocale('hi');
      await _pumps(tester);
      // tab labels switch to Hindi
      expect(find.text('My Map'), findsNothing);
    });
  });
}
