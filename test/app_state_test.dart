import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dekho/state/app_state.dart';

Future<AppState> _fresh() async {
  SharedPreferences.setMockInitialValues({});
  final s = AppState();
  await s.init();
  return s;
}

void main() {
  group('AppState', () {
    test('init loads empty defaults and marks ready', () async {
      final s = await _fresh();
      expect(s.ready, isTrue);
      expect(s.visitedStates, isEmpty);
      expect(s.visitedGems, isEmpty);
      expect(s.locale, 'en');
      expect(s.userName, '');
    });

    test('toggleState adds and removes', () async {
      final s = await _fresh();
      await s.toggleState('Rajasthan');
      expect(s.visitedStates, contains('Rajasthan'));
      expect(s.statesCount, 1);
      await s.toggleState('Rajasthan');
      expect(s.visitedStates, isEmpty);
    });

    test('toggleGem tracks hidden gems', () async {
      final s = await _fresh();
      await s.toggleGem('chand-baori');
      await s.toggleGem('bhangarh');
      expect(s.gemsCount, 2);
      await s.toggleGem('chand-baori');
      expect(s.gemsCount, 1);
    });

    test('state persists across instances', () async {
      final s = await _fresh();
      await s.toggleState('Kerala');
      await s.toggleGem('bekal');
      await s.setUserName('Aarav');
      await s.setLocale('hi');
      // new instance reads the same mock storage
      final s2 = AppState();
      await s2.init();
      expect(s2.visitedStates, contains('Kerala'));
      expect(s2.visitedGems, contains('bekal'));
      expect(s2.userName, 'Aarav');
      expect(s2.locale, 'hi');
    });

    test('badges unlock at thresholds', () async {
      final s = await _fresh();
      Map<String, bool> earned() =>
          {for (final b in s.badges()) b.id: b.earned};
      expect(earned()['first'], isFalse);
      for (var i = 0; i < 5; i++) {
        await s.toggleState('State$i');
      }
      expect(earned()['first'], isTrue);
      expect(earned()['five'], isTrue);
      expect(earned()['ten'], isFalse);
      await s.toggleState('Rajasthan');
      await s.toggleState('Gujarat');
      expect(earned()['desert'], isTrue);
      for (var i = 0; i < 5; i++) {
        await s.toggleGem('gem$i');
      }
      expect(earned()['gems5'], isTrue);
    });

    test('traveler titles follow visit patterns', () async {
      final s = await _fresh();
      expect(s.travelerTitle(), 'Sapno ka Musafir');
      await s.toggleState('Goa');
      expect(s.travelerTitle(), 'Naya Safar');
      await s.toggleState('Kerala');
      await s.toggleState('Karnataka');
      await s.toggleState('Tamil Nadu');
      expect(s.travelerTitle(), 'Coastal Wanderer');
    });

    test('gemsForStates filters correctly', () async {
      final s = await _fresh();
      final all = s.gemsForStates({});
      final raj = s.gemsForStates({'Rajasthan'});
      expect(all.length, greaterThan(raj.length));
      expect(raj.every((g) => g.state == 'Rajasthan'), isTrue);
    });
  });
}
