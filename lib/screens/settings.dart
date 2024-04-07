import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weight_tracker/providers/settings_filters.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilters = ref.watch(settingsFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Switch to kilograms'),
            subtitle: const Text('Still saves as lb but converts to kg'),
            value: activeFilters[Filter.useKilograms]!,
            onChanged: (isChecked) {
              ref
                  .read(settingsFilterProvider.notifier)
                  .setFilter(Filter.useKilograms, isChecked);
            },
          ),
        ],
      ),
    );
  }
}
