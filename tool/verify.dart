// Data-integrity verification: run with `dart run tool/verify.dart`
// (pure Dart — no flutter imports needed).
import 'package:dekho/data/gems.dart';
import 'package:dekho/data/india_map.dart';
import 'package:dekho/services/planner.dart';

void main() {
  final names = indiaStates.map((s) => s.name).toSet();
  print('states in map data: ${names.length}');
  var ok = true;

  for (final g in hiddenGems) {
    if (!names.contains(g.state)) {
      print('MISMATCH: gem "${g.id}" -> unknown state "${g.state}"');
      ok = false;
    }
  }

  // state names hardcoded in badges + traveler titles
  const refs = [
    'Rajasthan', 'Gujarat', 'Andaman and Nicobar', 'Lakshadweep',
    'Uttar Pradesh', 'Bihar', 'West Bengal', 'Arunachal Pradesh', 'Assam',
    'Manipur', 'Meghalaya', 'Mizoram', 'Nagaland', 'Sikkim', 'Tripura',
    'Himachal Pradesh', 'Uttarakhand', 'Jammu and Kashmir', 'Ladakh',
    'Goa', 'Kerala', 'Karnataka', 'Tamil Nadu', 'Delhi', 'Maharashtra',
  ];
  for (final s in refs) {
    if (!names.contains(s)) {
      print('MISMATCH: badge/title references unknown state "$s"');
      ok = false;
    }
  }

  // planner smoke test
  final plan = buildPlan(
      pool: hiddenGems, days: 4, totalBudget: 20000, states: {'Rajasthan'});
  print('planner: ${plan.length} days from Rajasthan pool');
  for (final d in plan) {
    print('  day ${d.day}: ${d.gems.map((g) => g.name).join(' → ')} '
        '(₹${d.estCost})');
  }
  if (plan.isEmpty) {
    print('MISMATCH: planner returned no days');
    ok = false;
  }
  final total = plan.fold(0, (s, d) => s + d.estCost);
  print('  total est: ₹$total (budget was ₹20000)');

  print(ok ? 'VERIFY OK' : 'VERIFY FAILED');
}
