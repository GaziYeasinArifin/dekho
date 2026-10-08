import 'package:flutter/material.dart';
import '../data/gems.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';
import '../theme.dart';

class GemsScreen extends StatefulWidget {
  final AppState state;
  const GemsScreen({super.key, required this.state});

  @override
  State<GemsScreen> createState() => _GemsScreenState();
}

class _GemsScreenState extends State<GemsScreen> {
  String _filter = 'all'; // 'all' or a state name

  @override
  Widget build(BuildContext context) {
    final st = widget.state;
    final loc = st.locale;
    return ListenableBuilder(
      listenable: st,
      builder: (context, _) {
        final gems = _filter == 'all'
            ? hiddenGems
            : hiddenGems.where((g) => g.state == _filter).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.tr('gemsTitle', loc),
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: DekhoColors.ink)),
                  Text(S.tr('gemsSubtitle', loc),
                      style: const TextStyle(
                          color: DekhoColors.inkSoft, fontSize: 13)),
                ],
              ),
            ),
            SizedBox(
              height: 46,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _chip(S.tr('all', loc), 'all', loc),
                  for (final s in gemStates) _chip(s, s, loc),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                itemCount: gems.length,
                itemBuilder: (context, i) => _gemCard(gems[i], st, loc),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _chip(String label, String value, String loc) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: DekhoColors.teal,
        labelStyle: TextStyle(
            color: selected ? Colors.white : DekhoColors.ink,
            fontWeight: FontWeight.w600),
        onSelected: (_) => setState(() => _filter = value),
      ),
    );
  }

  Widget _gemCard(HiddenGem g, AppState st, String loc) {
    final done = st.visitedGems.contains(g.id);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showDetail(g, st, loc),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: done ? DekhoColors.marigold : DekhoColors.sand,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                    done ? Icons.check_circle : Icons.landscape,
                    color: done ? Colors.white : DekhoColors.teal,
                    size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc == 'hi' ? g.nameHi : g.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text('${g.district}, ${g.state}',
                        style: const TextStyle(
                            color: DekhoColors.inkSoft, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      '${S.tr('rs', loc)}${g.budgetPerDay} ${S.tr('budgetDay', loc)} · ${g.bestSeason}',
                      style: const TextStyle(
                          color: DekhoColors.teal,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: DekhoColors.inkSoft),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(HiddenGem g, AppState st, String loc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        builder: (context, ctrl) => ListenableBuilder(
          listenable: st,
          builder: (context, _) {
            final done = st.visitedGems.contains(g.id);
            return ListView(
              controller: ctrl,
              padding: const EdgeInsets.all(24),
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: done ? DekhoColors.marigold : DekhoColors.teal,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(done ? Icons.check_circle : Icons.landscape,
                      color: Colors.white, size: 30),
                ),
                const SizedBox(height: 14),
                Text(loc == 'hi' ? g.nameHi : g.name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w800)),
                Text('${g.district}, ${g.state}',
                    style: const TextStyle(color: DekhoColors.inkSoft)),
                const SizedBox(height: 12),
                Text(g.why, style: const TextStyle(fontSize: 15, height: 1.5)),
                const SizedBox(height: 16),
                _row(Icons.calendar_month, S.tr('bestSeason', loc), g.bestSeason),
                _row(Icons.wallet, S.tr('budgetDay', loc),
                    '${S.tr('rs', loc)}${g.budgetPerDay}'),
                _row(Icons.directions, S.tr('howToReach', loc), g.reach),
                _row(Icons.hotel, S.tr('stay', loc), g.stay),
                _row(Icons.restaurant, S.tr('localFood', loc), g.food),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => st.toggleGem(g.id),
                  icon: Icon(done ? Icons.remove_circle_outline : Icons.check),
                  label: Text(done
                      ? (loc == 'hi' ? 'हटाएं' : 'Remove')
                      : S.tr('markVisited', loc)),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        done ? DekhoColors.inkSoft : DekhoColors.teal,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: DekhoColors.teal),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style:
                    const TextStyle(color: DekhoColors.ink, fontSize: 14),
                children: [
                  TextSpan(
                      text: '$label: ',
                      style:
                          const TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
