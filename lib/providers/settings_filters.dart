import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Filter { useKilograms }

class SettingsFilterNotifier extends StateNotifier<Map<Filter, bool>> {
  SettingsFilterNotifier() : super({Filter.useKilograms: false});

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final useKilograms = prefs.getBool('useKilograms') ?? false;
    state = {Filter.useKilograms: useKilograms};
  }

  Future<void> setFilter(Filter filter, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_filterToString(filter), value);
    state = {...state, filter: value};
  }

  String _filterToString(Filter filter) {
    switch (filter) {
      case Filter.useKilograms:
        return 'useKilograms';
    }
  }
}

final settingsFilterProvider =
    StateNotifierProvider<SettingsFilterNotifier, Map<Filter, bool>>(
  (ref) => SettingsFilterNotifier(),
);
