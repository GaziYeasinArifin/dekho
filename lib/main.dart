import 'package:flutter/material.dart';
import 'l10n/strings.dart';
import 'screens/badges_screen.dart';
import 'screens/gems_screen.dart';
import 'screens/map_screen.dart';
import 'screens/planner_screen.dart';
import 'state/app_state.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  await state.init();
  runApp(DekhoApp(state: state));
}

class DekhoApp extends StatelessWidget {
  final AppState state;
  const DekhoApp({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) => MaterialApp(
        title: 'Dekho — apna desh, apna naksha',
        debugShowCheckedModeBanner: false,
        theme: dekhoTheme(),
        home: MainTabs(state: state),
      ),
    );
  }
}

class MainTabs extends StatefulWidget {
  final AppState state;
  const MainTabs({super.key, required this.state});

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final st = widget.state;
    final loc = st.locale;
    final tabs = [
      MapScreen(state: st),
      GemsScreen(state: st),
      PlannerScreen(state: st),
      BadgesScreen(state: st),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: DekhoColors.teal,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.remove_red_eye,
                  color: Colors.white, size: 19),
            ),
            const SizedBox(width: 8),
            const Text('dekho',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    letterSpacing: -0.5)),
            const SizedBox(width: 8),
            Text(S.tr('tagline', loc),
                style: const TextStyle(
                    fontSize: 11, color: DekhoColors.inkSoft)),
          ],
        ),
        actions: [
          // EN / हिं toggle
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'en', label: Text('EN')),
                ButtonSegment(value: 'hi', label: Text('हिं')),
              ],
              selected: {loc},
              onSelectionChanged: (s) => st.setLocale(s.first),
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 10)),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.map_outlined),
              activeIcon: const Icon(Icons.map),
              label: S.tr('tabMap', loc)),
          BottomNavigationBarItem(
              icon: const Icon(Icons.landscape_outlined),
              activeIcon: const Icon(Icons.landscape),
              label: S.tr('tabGems', loc)),
          BottomNavigationBarItem(
              icon: const Icon(Icons.route_outlined),
              activeIcon: const Icon(Icons.route),
              label: S.tr('tabPlan', loc)),
          BottomNavigationBarItem(
              icon: const Icon(Icons.emoji_events_outlined),
              activeIcon: const Icon(Icons.emoji_events),
              label: S.tr('tabBadges', loc)),
        ],
      ),
    );
  }
}
