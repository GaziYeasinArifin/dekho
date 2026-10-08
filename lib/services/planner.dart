import 'dart:math';
import '../data/gems.dart';

/// One day of a generated itinerary. A day with no gems is an "open
/// exploration" day (revisit a favourite, wander) rather than a gap.
class TripDay {
  final int day;
  final List<HiddenGem> gems;
  final int estCost; // INR per person
  const TripDay(this.day, this.gems, this.estCost);

  bool get isExploreDay => gems.isEmpty;
}

/// Offline heuristic planner: picks affordable gems, orders them with a
/// nearest-neighbour route, and spreads them across ALL requested days.
/// Days beyond the gem count become low-cost open-exploration days.
/// Swap this with an LLM-backed planner later — the UI won't change.
List<TripDay> buildPlan({
  required List<HiddenGem> pool,
  required int days,
  required int totalBudget,
  Set<String>? states,
}) {
  if (pool.isEmpty || days < 1) return [];
  var candidates = states == null || states.isEmpty
      ? List<HiddenGem>.from(pool)
      : pool.where((g) => states.contains(g.state)).toList();
  if (candidates.isEmpty) candidates = List<HiddenGem>.from(pool);

  final perDay = totalBudget / days;
  // prefer gems that fit the daily budget, keep a couple of splurges
  candidates.sort((a, b) {
    int score(HiddenGem g) {
      if (g.budgetPerDay <= perDay) return 0;
      if (g.budgetPerDay <= perDay * 1.3) return 1;
      return 2;
    }
    return score(a).compareTo(score(b));
  });

  final want = min(candidates.length, days * 2);
  final picked = candidates.take(want).toList();

  // nearest-neighbour ordering for a sane route
  final ordered = <HiddenGem>[];
  final remaining = List<HiddenGem>.from(picked);
  var cur = remaining.removeAt(0);
  ordered.add(cur);
  double dist(HiddenGem a, HiddenGem b) =>
      sqrt(pow(a.lat - b.lat, 2) + pow(a.lng - b.lng, 2));
  while (remaining.isNotEmpty) {
    remaining.sort((a, b) => dist(cur, a).compareTo(dist(cur, b)));
    cur = remaining.removeAt(0);
    ordered.add(cur);
  }

  // Spread gems across every day: first `remainder` days get one extra.
  // This keeps route order and guarantees no requested day is dropped.
  final base = ordered.length ~/ days;
  final remainder = ordered.length % days;
  final result = <TripDay>[];
  var idx = 0;
  for (var d = 0; d < days; d++) {
    final count = base + (d < remainder ? 1 : 0);
    final chunk = ordered.skip(idx).take(count).toList();
    idx += count;
    if (chunk.isEmpty) {
      // Open exploration day: stay + food buffer, no gem ticket costs.
      result.add(TripDay(d + 1, const [], 800));
    } else {
      final cost = chunk.fold<int>(0, (s, g) => s + g.budgetPerDay) +
          600; // inter-gem travel buffer
      result.add(TripDay(d + 1, chunk, cost));
    }
  }
  return result;
}
