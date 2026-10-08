import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';
import '../theme.dart';

class BadgesScreen extends StatelessWidget {
  final AppState state;
  const BadgesScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final loc = state.locale;
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final badges = state.badges();
        final earned = badges.where((b) => b.earned).length;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.tr('badgesTitle', loc),
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: DekhoColors.ink)),
              Text(S.tr('badgesSubtitle', loc),
                  style: const TextStyle(
                      color: DekhoColors.inkSoft, fontSize: 13)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [
                    DekhoColors.marigold,
                    DekhoColors.marigoldDeep
                  ]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events,
                        color: Colors.white, size: 32),
                    const SizedBox(width: 12),
                    Text('$earned / ${badges.length} ${S.tr('earned', loc)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.92,
                ),
                itemCount: badges.length,
                itemBuilder: (context, i) {
                  final b = badges[i];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: b.earned ? Colors.white : DekhoColors.sand,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: b.earned
                            ? DekhoColors.marigold
                            : DekhoColors.sandDark,
                        width: b.earned ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: b.earned
                                ? DekhoColors.marigold
                                : DekhoColors.sandDark,
                          ),
                          child: Icon(
                            b.earned ? Icons.emoji_events : Icons.lock,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(b.title(loc),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: b.earned
                                    ? DekhoColors.ink
                                    : DekhoColors.inkSoft)),
                        const SizedBox(height: 4),
                        Text(b.desc(loc),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 11,
                                color: DekhoColors.inkSoft)),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
