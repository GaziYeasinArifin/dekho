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
  String _query = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = widget.state;
    final loc = st.locale;
    return ListenableBuilder(
      listenable: st,
      builder: (context, _) {
        final q = _query.trim().toLowerCase();
        final gems = hiddenGems.where((g) {
          if (_filter != 'all' && g.state != _filter) return false;
          if (q.isEmpty) return true;
          return g.name.toLowerCase().contains(q) ||
              g.nameHi.contains(_query.trim()) ||
              g.district.toLowerCase().contains(q) ||
              g.state.toLowerCase().contains(q);
        }).toList();
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: S.tr('searchGems', loc),
                  prefixIcon:
                      const Icon(Icons.search, color: DekhoColors.inkSoft),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => setState(() {
                            _query = '';
                            _searchCtrl.clear();
                          }),
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 46,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                children: [
                  _chip(S.tr('all', loc), 'all', loc),
                  for (final s in gemStates) _chip(s, s, loc),
                ],
              ),
            ),
            Expanded(
              child: gems.isEmpty
                  ? Center(
                      child: Text(S.tr('noGems', loc),
                          style: const TextStyle(
                              color: DekhoColors.inkSoft, fontSize: 14)),
                    )
                  : ListView.builder(
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
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showDetail(g, st, loc),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                if (g.photoAsset != null)
                  Image.asset(
                    g.photoAsset!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _photoFallback(done),
                  )
                else
                  _photoFallback(done),
                if (done)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: DekhoColors.marigold,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check,
                              size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(S.tr('visited', loc),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc == 'hi' ? g.nameHi : g.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 17)),
                  const SizedBox(height: 2),
                  Text('${g.district}, ${g.state}',
                      style: const TextStyle(
                          color: DekhoColors.inkSoft, fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(g.why,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13,
                          color: DekhoColors.ink,
                          height: 1.4)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.wallet,
                          size: 14, color: DekhoColors.teal),
                      const SizedBox(width: 4),
                      Text(
                        '₹${g.budgetPerDay} ${S.tr('budgetDay', loc)}',
                        style: const TextStyle(
                            color: DekhoColors.teal,
                            fontSize: 12,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.calendar_month,
                          size: 14, color: DekhoColors.teal),
                      const SizedBox(width: 4),
                      Text(g.bestSeason,
                          style: const TextStyle(
                              color: DekhoColors.teal,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                      const Spacer(),
                      const Icon(Icons.chevron_right,
                          color: DekhoColors.inkSoft),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoFallback(bool done) {
    return Container(
      height: 110,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: done
              ? [DekhoColors.marigold, DekhoColors.marigoldDeep]
              : [DekhoColors.teal, DekhoColors.ink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(done ? Icons.check_circle : Icons.landscape,
          color: Colors.white.withValues(alpha: 0.85), size: 40),
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
        initialChildSize: 0.85,
        builder: (context, ctrl) => ListenableBuilder(
          listenable: st,
          builder: (context, _) {
            final done = st.visitedGems.contains(g.id);
            return ListView(
              controller: ctrl,
              padding: EdgeInsets.zero,
              children: [
                Stack(
                  children: [
                    if (g.photoAsset != null)
                      Image.asset(
                        g.photoAsset!,
                        height: 240,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            _photoFallback(done),
                      )
                    else
                      SizedBox(
                          height: 140,
                          width: double.infinity,
                          child: _photoFallback(done)),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                    if (g.photoCredit != null)
                      Positioned(
                        bottom: 8,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('📷 ${g.photoCredit}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 10)),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loc == 'hi' ? g.nameHi : g.name,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w800)),
                      Text('${g.district}, ${g.state}',
                          style: const TextStyle(
                              color: DekhoColors.inkSoft)),
                      const SizedBox(height: 12),
                      Text(g.why,
                          style: const TextStyle(fontSize: 15, height: 1.5)),
                      const SizedBox(height: 16),
                      _row(Icons.calendar_month, S.tr('bestSeason', loc),
                          g.bestSeason),
                      _row(Icons.wallet, S.tr('budgetDay', loc),
                          '${S.tr('rs', loc)}${g.budgetPerDay}'),
                      _row(Icons.directions, S.tr('howToReach', loc), g.reach),
                      _row(Icons.hotel, S.tr('stay', loc), g.stay),
                      _row(Icons.restaurant, S.tr('localFood', loc), g.food),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () => st.toggleGem(g.id),
                        icon: Icon(done
                            ? Icons.remove_circle_outline
                            : Icons.check),
                        label: Text(done
                            ? S.tr('remove', loc)
                            : S.tr('markVisited', loc)),
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              done ? DekhoColors.inkSoft : DekhoColors.teal,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
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
