import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import '../l10n/strings.dart';
import '../services/share/share.dart';
import '../state/app_state.dart';
import '../theme.dart';
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
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.state.userName;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    setState(() => _busy = true);
    try {
      // render the offscreen card
      final boundary = _cardKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final img = await boundary.toImage(pixelRatio: 3.0);
      final data = await img.toByteData(format: ui.ImageByteFormat.png);
      final bytes = data!.buffer.asUint8List();
      await exportCardPng(
          bytes, 'dekho-card-${DateTime.now().millisecondsSinceEpoch}.png');
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
                      gradient: const LinearGradient(
                        colors: [DekhoColors.teal, DekhoColors.tealDeep],
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
                                '${st.statesCount} / 36',
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(S.tr('statesVisited', loc),
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
                            value: st.statesCount / 36,
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
                  Text(S.tr('tapHint', loc),
                      style: const TextStyle(
                          color: DekhoColors.inkSoft, fontSize: 13),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 4),
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
                      ),
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
                  FilledButton.icon(
                    onPressed: _busy ? null : _share,
                    icon: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.share),
                    label: Text(_busy
                        ? S.tr('downloading', loc)
                        : S.tr('shareCard', loc)),
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
