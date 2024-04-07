import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weight_tracker/providers/settings_filters.dart';

// import 'package:weight_tracker/widgets/main_drawer.dart';
import 'package:weight_tracker/screens/dashboard.dart';
import 'package:weight_tracker/screens/new_weight.dart';
import 'package:weight_tracker/screens/analytics.dart';
import 'package:weight_tracker/screens/settings.dart';

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
      appBar: AppBar(
        title: Text(
          activePageTitle,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
      // drawer: const MainDrawer(),
      body: activePage,
      floatingActionButton: FloatingActionButton(
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.analytics), label: 'Analytics'),
        ],
      ),
    );
  }
}
