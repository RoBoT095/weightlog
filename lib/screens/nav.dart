import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weightlog/providers/settings_filters.dart';

import 'package:weightlog/screens/dashboard.dart';
import 'package:weightlog/screens/new_weight.dart';
import 'package:weightlog/screens/analytics.dart';
import 'package:weightlog/screens/settings.dart';

class NavScreen extends ConsumerStatefulWidget {
  const NavScreen({super.key});

  @override
  ConsumerState<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends ConsumerState<NavScreen> {
  int _selectedPageIndex = 0;

  @override
  void initState() {
    ref.read(settingsFilterProvider.notifier).loadSettings();
    super.initState();
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget activePage = const DashboardScreen();
    var activePageTitle = 'Dashboard';

    if (_selectedPageIndex == 1) {
      activePage = const AnalyticsScreen();
      activePageTitle = 'Analytics';
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          activePageTitle,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: activePage,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const NewWeightScreen(),
          ));
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        iconSize: 40,
        backgroundColor: Theme.of(context).colorScheme.surface,
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.inbox,
                color: Theme.of(context).colorScheme.secondary,
              ),
              label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.analytics,
                color: Theme.of(context).colorScheme.secondary,
              ),
              label: 'Analytics'),
        ],
      ),
    );
  }
}
