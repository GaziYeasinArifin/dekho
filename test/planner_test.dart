import 'package:flutter_test/flutter_test.dart';
import 'package:dekho/data/gems.dart';
import 'package:dekho/services/planner.dart';

HiddenGem _g(String id, String state, int budget, double lat) => HiddenGem(
      id: id,
      name: id,
      nameHi: id,
      state: state,
      district: 'd',
      why: 'w',
      bestSeason: 's',
      budgetPerDay: budget,
      reach: 'r',
      stay: 's',
      food: 'f',
      lat: lat,
      lng: 0,
    );

List<HiddenGem> _pool(int n, {String state = 'Rajasthan'}) =>
    List.generate(n, (i) => _g('g$i', state, 1000 + i * 100, i.toDouble()));

void main() {
  group('buildPlan', () {
    test('fills every requested day (6 gems, 4 days)', () {
      final plan = buildPlan(pool: _pool(6), days: 4, totalBudget: 20000);
      expect(plan.length, 4);
      expect(plan.every((d) => d.gems.isNotEmpty), isTrue);
      final total = plan.fold<int>(0, (s, d) => s + d.gems.length);
      expect(total, 6);
      // no duplicates
      final ids = plan.expand((d) => d.gems.map((g) => g.id)).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('days beyond gem count become explore days (2 gems, 5 days)', () {
      final plan = buildPlan(pool: _pool(2), days: 5, totalBudget: 20000);
      expect(plan.length, 5);
      expect(plan[0].isExploreDay, isFalse);
      expect(plan[1].isExploreDay, isFalse);
      expect(plan[2].isExploreDay, isTrue);
      expect(plan[3].isExploreDay, isTrue);
      expect(plan[4].isExploreDay, isTrue);
      expect(plan[2].estCost, lessThan(plan[0].estCost));
    });

    test('caps at ~2 gems per day for large pools', () {
      final plan = buildPlan(pool: _pool(20), days: 4, totalBudget: 50000);
      expect(plan.length, 4);
      expect(plan.every((d) => d.gems.length <= 3), isTrue);
    });

    test('empty pool and bad input return empty', () {
      expect(buildPlan(pool: [], days: 4, totalBudget: 20000), isEmpty);
      expect(buildPlan(pool: _pool(5), days: 0, totalBudget: 20000), isEmpty);
    });

    test('state filter respected, falls back to all when empty', () {
      final pool = [..._pool(3, state: 'Rajasthan'), ..._pool(3, state: 'Kerala')];
      final plan = buildPlan(
          pool: pool, days: 3, totalBudget: 20000, states: {'Kerala'});
      final states = plan.expand((d) => d.gems.map((g) => g.state)).toSet();
      expect(states, {'Kerala'});
      // unknown state -> fallback keeps trip non-empty
      final fallback = buildPlan(
          pool: pool, days: 2, totalBudget: 20000, states: {'Atlantis'});
      expect(fallback.length, 2);
    });

    test('cheapest gems preferred under tight budget', () {
      final pool = [
        _g('cheap', 'Rajasthan', 500, 1),
        _g('pricey', 'Rajasthan', 9000, 2),
      ];
      final plan =
          buildPlan(pool: pool, days: 1, totalBudget: 2000, states: null);
      expect(plan.length, 1);
      expect(plan.first.gems.first.id, 'cheap');
    });

    test('day numbers are sequential from 1', () {
      final plan = buildPlan(pool: _pool(7), days: 3, totalBudget: 30000);
      expect(plan.map((d) => d.day).toList(), [1, 2, 3]);
    });
  });
}
