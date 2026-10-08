import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img_pkg;
import 'dart:typed_data';
import 'dart:ui' as ui;
import '../data/india_districts.dart';
import '../data/india_map.dart';
import '../l10n/strings.dart';
import '../services/share/share.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/district_map.dart';
import '../widgets/india_map.dart';
import '../widgets/share_card.dart';

/// The core loop: tap states -> watch the count grow -> share the card.
class MapScreen extends StatefulWidget {
  final AppState state;
  const MapScreen({super.key, required this.state});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _cardKey = GlobalKey();
  final _nameCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  bool _busy = false;
  bool _listMode = false;
  bool _districtsMode = false;
  String _districtState = 'Rajasthan';
  String _query = '';

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.state.userName;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _share(BuildContext btnCtx, {bool jpg = false}) async {
    setState(() => _busy = true);
    try {
      // render the offscreen card
      final boundary = _cardKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final img = await boundary.toImage(pixelRatio: 3.0);
      final data = await img.toByteData(format: ui.ImageByteFormat.png);
      Uint8List bytes = data!.buffer.asUint8List();
      var filename =
          'dekho-card-${DateTime.now().millisecondsSinceEpoch}.png';
      if (jpg) {
        // re-encode as JPEG for smaller, universally-compatible files
        final decoded = img_pkg.decodeImage(bytes);
        if (decoded != null) {
          bytes = Uint8List.fromList(img_pkg.encodeJpg(decoded, quality: 92));
          filename = filename.replaceAll('.png', '.jpg');
        }
      }
      // anchor for the iPad share popover
      final box =
          btnCtx.mounted ? btnCtx.findRenderObject() as RenderBox? : null;
      final origin =
          box == null ? null : box.localToGlobal(Offset.zero) & box.size;
      await exportCardPng(
        bytes,
        filename,
        sharePositionOrigin: origin,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final st = widget.state;
    final loc = st.locale;
    final theme =
        dekhoMapThemes[st.mapTheme.clamp(0, dekhoMapThemes.length - 1)];
    return ListenableBuilder(
      listenable: st,
      builder: (context, _) {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // counter hero
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.heroFrom, theme.heroTo],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _districtsMode
                                    ? '${st.districtsCount} / ${indiaDistricts.length}'
                                    : '${st.statesCount} / 36',
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                  _districtsMode
                                      ? S.tr('districtsVisited', loc)
                                      : S.tr('statesVisited', loc),
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14)),
                              const SizedBox(height: 8),
                              Text(st.travelerTitle(),
                                  style: const TextStyle(
                                      color: DekhoColors.marigold,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 96,
                          child: LinearProgressIndicator(
                            value: _districtsMode
                                ? st.districtsCount / indiaDistricts.length
                                : st.statesCount / 36,
                            backgroundColor: Colors.white24,
                            color: DekhoColors.marigold,
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // states / districts level toggle
                  SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                          value: false,
                          icon:
                              const Icon(Icons.map_outlined, size: 18),
                          label: Text(S.tr('statesLevel', loc))),
                      ButtonSegment(
                          value: true,
                          icon: const Icon(Icons.grid_on_outlined,
                              size: 18),
                          label: Text(S.tr('districtsLevel', loc))),
                    ],
                    selected: {_districtsMode},
                    onSelectionChanged: (s) =>
                        setState(() => _districtsMode = s.first),
                    style: SegmentedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_districtsMode)
                    _DistrictSection(
                      state: st,
                      theme: theme,
                      selectedState: _districtState,
                      onSelectState: (s) =>
                          setState(() => _districtState = s),
                    )
                  else ...[
                  Text(S.tr('tapHint', loc),
                      style: const TextStyle(
                          color: DekhoColors.inkSoft, fontSize: 13),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  // map / list toggle + bulk actions
                  Row(
                    children: [
                      Expanded(
                        child: SegmentedButton<bool>(
                          segments: [
                            ButtonSegment(
                                value: false,
                                icon: const Icon(Icons.map_outlined, size: 18),
                                label: Text(S.tr('mapView', loc))),
                            ButtonSegment(
                                value: true,
                                icon: const Icon(Icons.list, size: 18),
                                label: Text(S.tr('listView', loc))),
                          ],
                          selected: {_listMode},
                          onSelectionChanged: (s) =>
                              setState(() => _listMode = s.first),
                          style: SegmentedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => st.selectAllStates(
                            indiaStates.map((s) => s.name)),
                        child: Text(S.tr('selectAll', loc)),
                      ),
                      TextButton(
                        onPressed:
                            st.statesCount == 0 ? null : st.clearStates,
                        child: Text(S.tr('clearAll', loc)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (_listMode)
                    _StateList(
                      state: st,
                      query: _query,
                      searchCtrl: _searchCtrl,
                      onQuery: (q) => setState(() => _query = q),
                    )
                  else
                    // the map
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: DekhoColors.sandDark),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: IndiaMap(
                          visited: st.visitedStates,
                          onToggle: st.toggleState,
                          theme: theme,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  // theme picker
                  Text(S.tr('mapTheme', loc),
                      style: const TextStyle(
                          color: DekhoColors.inkSoft,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 64,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: dekhoMapThemes.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 10),
                      itemBuilder: (ctx, i) {
                        final t = dekhoMapThemes[i];
                        final selected = st.mapTheme == i;
                        return GestureDetector(
                          onTap: () => st.setMapTheme(i),
                          child: Container(
                            width: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected
                                    ? DekhoColors.ink
                                    : DekhoColors.sandDark,
                                width: selected ? 2.5 : 1,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: Container(
                                            color: t.unvisited)),
                                    Expanded(
                                        child:
                                            Container(color: t.visited)),
                                  ],
                                ),
                                Container(
                                  alignment: Alignment.bottomCenter,
                                  padding:
                                      const EdgeInsets.only(bottom: 4),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(
                                            alpha: 0.55)
                                      ],
                                    ),
                                  ),
                                  child: Text(
                                    loc == 'hi' ? t.nameHi : t.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                if (selected)
                                  const Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Icon(Icons.check_circle,
                                        color: Colors.white, size: 18),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // name field
                  TextField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: S.tr('yourName', loc),
                      hintText: S.tr('nameHint', loc),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: st.setUserName,
                  ),
                  const SizedBox(height: 12),
                  Builder(
                    builder: (btnCtx) => Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _busy
                                ? null
                                : () => _share(btnCtx, jpg: false),
                            icon: _busy
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white))
                                : const Icon(Icons.share),
                            label: Text(_busy
                                ? S.tr('downloading', loc)
                                : S.tr('shareCard', loc)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<bool>(
                          enabled: !_busy,
                          tooltip: S.tr('exportFormat', loc),
                          icon: const Icon(Icons.file_download_outlined),
                          style: IconButton.styleFrom(
                            side: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          onSelected: (jpg) => _share(btnCtx, jpg: jpg),
                          itemBuilder: (_) => [
                            PopupMenuItem(
                                value: false,
                                child: Text(S.tr('sharePng', loc))),
                            PopupMenuItem(
                                value: true,
                                child: Text(S.tr('shareJpg', loc))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // offscreen share card (kept laid out but invisible)
            Positioned(
              left: -10000,
              top: 0,
              child: RepaintBoundary(
                key: _cardKey,
                child: ShareCard(state: st),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Itemized state/UT list with search — an alternative to tapping the map.
class _StateList extends StatelessWidget {
  final AppState state;
  final String query;
  final TextEditingController searchCtrl;
  final ValueChanged<String> onQuery;

  const _StateList({
    required this.state,
    required this.query,
    required this.searchCtrl,
    required this.onQuery,
  });

  @override
  Widget build(BuildContext context) {
    final loc = state.locale;
    final q = query.trim().toLowerCase();
    final filtered = indiaStates.where((s) {
      if (q.isEmpty) return true;
      return s.name.toLowerCase().contains(q) ||
          s.nameHi.toLowerCase().contains(q);
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: searchCtrl,
          decoration: InputDecoration(
            hintText: S.tr('searchStates', loc),
            prefixIcon: const Icon(Icons.search),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: onQuery,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: DekhoColors.sandDark),
          ),
          constraints: const BoxConstraints(maxHeight: 420),
          child: filtered.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(S.tr('noStates', loc),
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(color: DekhoColors.inkSoft)),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 56),
                  itemBuilder: (ctx, i) {
                    final s = filtered[i];
                    final visited = state.visitedStates.contains(s.name);
                    return CheckboxListTile(
                      value: visited,
                      onChanged: (_) => state.toggleState(s.name),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: DekhoColors.teal,
                      title: Text(
                        loc == 'hi' ? s.nameHi : s.name,
                        style: TextStyle(
                          fontWeight:
                              visited ? FontWeight.w700 : FontWeight.w400,
                          color: visited
                              ? DekhoColors.tealDeep
                              : DekhoColors.ink,
                        ),
                      ),
                      secondary: visited
                          ? const Icon(Icons.check_circle,
                              color: DekhoColors.teal, size: 22)
                          : null,
                      dense: true,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// District-collection mode: pick a state, then tap its districts.
class _DistrictSection extends StatelessWidget {
  final AppState state;
  final DekhoMapTheme theme;
  final String selectedState;
  final ValueChanged<String> onSelectState;

  const _DistrictSection({
    required this.state,
    required this.theme,
    required this.selectedState,
    required this.onSelectState,
  });

  @override
  Widget build(BuildContext context) {
    final loc = state.locale;
    final districts =
        indiaDistricts.where((d) => d.state == selectedState).toList();
    final stateNames =
        indiaDistricts.map((d) => d.state).toSet().toList()..sort();
    final visitedHere =
        districts.where((d) => state.visitedDistricts.contains(d.lgd)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(S.tr('districtHint', loc),
            style:
                const TextStyle(color: DekhoColors.inkSoft, fontSize: 13),
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        // state picker
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: DekhoColors.sandDark),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: stateNames.contains(selectedState)
                  ? selectedState
                  : stateNames.first,
              isExpanded: true,
              items: [
                for (final s in stateNames)
                  DropdownMenuItem(
                    value: s,
                    child: Text(
                      '$s (${indiaDistricts.where((d) => d.state == s).length})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (s) {
                if (s != null) onSelectState(s);
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        // per-state progress + bulk actions
        Row(
          children: [
            Expanded(
              child: Text(
                '$visitedHere / ${districts.length} ${S.tr('districtsInState', loc)}',
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: DekhoColors.ink,
                    fontSize: 14),
              ),
            ),
            TextButton(
              onPressed: () =>
                  state.selectDistricts(districts.map((d) => d.lgd)),
              child: Text(S.tr('markAll', loc)),
            ),
            TextButton(
              onPressed: visitedHere == 0
                  ? null
                  : () => state
                      .clearDistricts(districts.map((d) => d.lgd)),
              child: Text(S.tr('clearAll', loc)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // the district map
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: DekhoColors.sandDark),
            ),
            padding: const EdgeInsets.all(12),
            child: DistrictMap(
              districts: districts,
              visited: state.visitedDistricts,
              onToggle: state.toggleDistrict,
              theme: theme,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(S.tr('districtCredit', loc),
            style:
                const TextStyle(color: DekhoColors.inkSoft, fontSize: 11),
            textAlign: TextAlign.center),
      ],
    );
  }
}
