import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weight_tracker/providers/settings_filters.dart';
import 'package:weight_tracker/providers/user_weight.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilters = ref.watch(settingsFilterProvider);

    void snackBarMessage(String text) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(text)),
        );
      }
    }

    void exportDatabase() async {
      String? selectDir = await FilePicker.platform.getDirectoryPath();
      if (selectDir != null) {
        ref.read(userWeightProvider.notifier).exportDatabase(selectDir);
        snackBarMessage('Exported successfully');
      } else {
        snackBarMessage('Exported failed');
      }
    }

    void importDatabase() async {
      final selectFile = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: true,
      );
      if (selectFile != null && selectFile.files.isNotEmpty) {
        final file = selectFile.files.first;

        if (file.name.endsWith('.db')) {
          ref.read(userWeightProvider.notifier).importDatabase(file);
          snackBarMessage('Imported successfully');
        } else {
          snackBarMessage('File was not a .db file');
        }
      } else {
        snackBarMessage('Failed to import because no file was selected');
      }
    }

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
            subtitle: const Text('Still saves as lb. but converts to kg.'),
            value: activeFilters[Filter.useKilograms]!,
            onChanged: (isChecked) {
              ref
                  .read(settingsFilterProvider.notifier)
                  .setFilter(Filter.useKilograms, isChecked);
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Export Database'),
            subtitle: const Text('Export all your weight data as an .db file'),
            trailing: const Icon(Icons.file_download),
            onTap: () => exportDatabase(),
          ),
          ListTile(
            title: const Text('Import Database'),
            subtitle: const Text(
                'Import the .db file with all your weights, \nTHIS WILL OVERWRITE CURRENT DATA!'),
            trailing: const Icon(Icons.file_upload),
            onTap: () => importDatabase(),
          ),
        ],
      ),
    );
  }
}
