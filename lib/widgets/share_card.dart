import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';
import '../theme.dart';
import 'india_map.dart';

/// The viral artifact: a 4:5 personal travel card, rendered offscreen at
/// 360x450 and captured at 3x for a crisp 1080x1350 share image.
class ShareCard extends StatelessWidget {
  final AppState state;
  const ShareCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final loc = state.locale;
    final theme = dekhoMapThemes[state.mapTheme.clamp(0, dekhoMapThemes.length - 1)];
    final name = state.userName.isEmpty
        ? (loc == 'hi' ? 'मुसाफ़िर' : 'Traveller')
        : state.userName;
    return SizedBox(
      width: 360,
      height: 450,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [DekhoColors.paper, Color(0xFFF3EAD3)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 26, 28, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // brand row
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: DekhoColors.teal,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.remove_red_eye,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text('dekho',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: DekhoColors.ink,
                          letterSpacing: -0.5)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(S.tr('tagline', loc),
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 10, color: DekhoColors.inkSoft)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: DekhoColors.ink)),
              Text(state.travelerTitle(),
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.accent)),
              const SizedBox(height: 8),
              // mini map
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: DekhoColors.sandDark),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: IndiaMap(
                      visited: state.visitedStates,
                      interactive: false,
                      theme: theme),
                ),
              ),
              const SizedBox(height: 12),
              // stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _stat('${state.statesCount}', '/36',
                      loc == 'hi' ? 'राज्य' : 'states'),
                  _stat('${state.gemsCount}', '',
                      loc == 'hi' ? 'छिपे रत्न' : 'hidden gems'),
                  _stat('${state.badges().where((b) => b.earned).length}', '',
                      loc == 'hi' ? 'बैज' : 'badges'),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: DekhoColors.ink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: RichText(
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
                    children: [
                      TextSpan(text: '${S.tr('madeWith', loc)} '),
                      const TextSpan(
                          text: 'dekho',
                          style: TextStyle(
                              color: DekhoColors.marigold,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String big, String small, String label) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: DekhoColors.ink),
            children: [
              TextSpan(text: big),
              TextSpan(
                  text: small,
                  style: const TextStyle(
                      fontSize: 14, color: DekhoColors.inkSoft)),
            ],
          ),
        ),
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: DekhoColors.inkSoft)),
      ],
    );
  }
}
