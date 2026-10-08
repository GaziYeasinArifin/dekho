import 'package:flutter/material.dart';
import '../data/gems.dart';
import '../l10n/strings.dart';
import '../services/planner.dart';
import '../state/app_state.dart';
import '../theme.dart';

class PlannerScreen extends StatefulWidget {
  final AppState state;
  const PlannerScreen({super.key, required this.state});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  double _days = 4;
  double _budget = 20000;
  double _travelers = 2;
  final Set<String> _states = {};
  List<TripDay> _plan = [];
  bool _planned = false;

  String _inr(int n) {
    // indian-style grouping is complex; standard 3-digit grouping is fine for v1
    return n.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    final st = widget.state;
    final loc = st.locale;
    return ListenableBuilder(
      listenable: st,
      builder: (context, _) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(S.tr('plannerTitle', loc),
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: DekhoColors.ink)),
            Text(S.tr('plannerSubtitle', loc),
                style:
                    const TextStyle(color: DekhoColors.inkSoft, fontSize: 13)),
            const SizedBox(height: 20),
            _label('${S.tr('days', loc)}: ${_days.toInt()}'),
            Slider(
                value: _days,
                min: 2,
                max: 10,
                divisions: 8,
                label: '${_days.toInt()}',
                onChanged: (v) => setState(() => _days = v)),
            _label('${S.tr('budget', loc)}: ₹${_inr(_budget.toInt())}'),
            Slider(
                value: _budget,
                min: 5000,
                max: 100000,
                divisions: 19,
                label: '₹${_inr(_budget.toInt())}',
                onChanged: (v) => setState(() => _budget = v)),
            _label('${S.tr('travelers', loc)}: ${_travelers.toInt()}'),
            Slider(
                value: _travelers,
                min: 1,
                max: 10,
                divisions: 9,
                label: '${_travelers.toInt()}',
                onChanged: (v) => setState(() => _travelers = v)),
            _label(S.tr('states', loc)),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: Text(S.tr('anywhere', loc)),
                  selected: _states.isEmpty,
                  onSelected: (_) => setState(() {
                    _states.clear();
                    _planned = false;
                  }),
                ),
                for (final s in gemStates)
                  FilterChip(
                    label: Text(s),
                    selected: _states.contains(s),
                    onSelected: (on) => setState(() {
                      on ? _states.add(s) : _states.remove(s);
                      _planned = false;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => setState(() {
                _plan = buildPlan(
                  pool: hiddenGems,
                  days: _days.toInt(),
                  totalBudget: _budget.toInt(),
                  states: _states,
                  travelers: _travelers.toInt(),
                );
                _planned = true;
              }),
              icon: const Icon(Icons.route),
              label: Text(S.tr('planMyTrip', loc)),
            ),
            if (_planned) ...[
              const SizedBox(height: 20),
              for (final d in _plan) _dayCard(d, loc),
              if (_plan.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DekhoColors.ink,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          '${S.tr('estCost', loc)} (${S.tr('perPerson', loc)})',
                          style: const TextStyle(color: Colors.white70)),
                      Text(
                          '₹${_inr(_plan.fold(0, (s, d) => s + d.estCost))}',
                          style: const TextStyle(
                              color: DekhoColors.marigold,
                              fontWeight: FontWeight.w800,
                              fontSize: 20)),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 2),
        child: Text(t,
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: DekhoColors.ink)),
      );

  Widget _dayCard(TripDay d, String loc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${S.tr('day', loc)} ${d.day}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16)),
                Text('₹${_inr(d.estCost)}',
                    style: const TextStyle(
                        color: DekhoColors.teal,
                        fontWeight: FontWeight.w700)),
              ],
            ),
            const Divider(),
            if (d.isExploreDay)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: DekhoColors.marigold.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.explore,
                        size: 18, color: DekhoColors.marigoldDeep),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(S.tr('exploreDay', loc),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(S.tr('exploreDayDesc', loc),
                            style: const TextStyle(
                                fontSize: 13, color: DekhoColors.inkSoft)),
                      ],
                    ),
                  ),
                ],
              )
            else
              for (final g in d.gems)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.place,
                          size: 16, color: DekhoColors.marigoldDeep),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                            '${loc == 'hi' ? g.nameHi : g.name} · ${g.district}',
                            style: const TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
