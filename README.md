# Dekho — apna desh, apna naksha

A personal India travel map: tap the states you've visited, discover hidden
gems, generate AI-style trip plans, earn badges, and share your travel card.
Inspired by Unseen Bangladesh, built for India.

## Run (web)

```bash
flutter pub get
flutter run -d chrome
```

## Build

```bash
# Web (production)
flutter build web --release
# → build/web/  (deploy to any static host)

# Android
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk

# iOS (on a Mac with Xcode)
flutter build ipa --release
```

## Project layout

```
lib/
  main.dart            App shell, bottom nav, EN/हिं toggle
  theme.dart           Dekho brand palette + Material theme
  l10n/strings.dart    Hand-rolled EN/HI localization (no build step)
  data/
    india_map.dart     GENERATED — 36 states/UTs, simplified polygons
                       (regen: build_data/make_dart_map.py, source: Natural Earth)
    gems.dart          Curated hidden gems (deep coverage first)
  state/
    app_state.dart     Visited states/gems, locale, badges, traveler titles
    badges.dart        Badge model
  services/
    planner.dart       Offline heuristic trip planner (swap for LLM later)
    share/             Platform-aware card export
      share.dart           (conditional import)
      share_web.dart       PNG download on web
      share_stub.dart      fallback until mobile share sheet is wired
  widgets/
    india_map.dart     CustomPainter interactive map (tap/hover, tiny-state hit areas)
    share_card.dart     4:5 viral share card (captured at 3x → 1080×1350)
  screens/
    map_screen.dart    Core loop: tap → count → share
    gems_screen.dart   Hidden gems browser + detail sheets
    planner_screen.dart Days/budget/states → itinerary
    badges_screen.dart  Badge collection grid
build_data/
  make_dart_map.py     GeoJSON → simplified Dart (re-run to refresh map data)
```

## Roadmap

- [ ] District-level map (700+ districts — the real collection game)
- [ ] More states' hidden gems (currently 8 states, 20 gems)
- [ ] LLM-backed trip planner (drop-in replacement in `services/planner.dart`)
- [ ] Mobile share sheet (`services/share/share_mobile.dart`)
- [ ] Backend: accounts, leaderboards, UGC gems
- [ ] Devanagari-first brand assets (देखो wordmark)

## Data credits

State boundaries: Natural Earth 10m admin_1 (public domain).
