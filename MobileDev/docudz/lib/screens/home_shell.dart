import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';
import 'cost_calculator_screen.dart';
import 'home_screen.dart';
import 'office_screen.dart';
import 'settings_screen.dart';

/// Root with the 4-tab bottom navigation: Home, Costs, Offices, Settings.
/// Checklist and Steps are pushed on top (focused task flows, no tab bar).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<HomeShell> createState() => HomeShellState();
}

class HomeShellState extends State<HomeShell> {
  late int _index = widget.initialIndex;

  void selectTab(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onSelectTab: selectTab),
          const CostCalculatorScreen(),
          const OfficeScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        key: const ValueKey('nav'),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.hairline)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: selectTab,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: l.navHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.calculate_outlined),
              selectedIcon: const Icon(Icons.calculate_rounded),
              label: l.navCosts,
            ),
            NavigationDestination(
              icon: const Icon(Icons.location_on_outlined),
              selectedIcon: const Icon(Icons.location_on_rounded),
              label: l.navOffices,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings_rounded),
              label: l.navSettings,
            ),
          ],
        ),
      ),
    );
  }
}
