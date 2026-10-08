// Widget interaction tests: map taps, tab navigation, planner output,
// gem search, locale toggle. Uses bounded pumps (no pumpAndSettle).
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dekho/main.dart';
import 'package:dekho/state/app_state.dart';
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
  final rect = tester.getRect(find.byType(IndiaMap).first);
  final scale = min(rect.width, rect.height) / 1000;
  final dx = (rect.width - 1000 * scale) / 2;
  final dy = (rect.height - 1000 * scale) / 2;
  await tester.tapAt(rect.topLeft + Offset(dx + 184 * scale, dy + 308 * scale));
  await _pumps(tester);
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

  group('navigation', () {
    testWidgets('all four tabs render', (tester) async {
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
