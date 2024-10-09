import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weightlog/providers/settings_filters.dart';
import 'package:weightlog/providers/user_weight.dart';

class NewWeightScreen extends ConsumerStatefulWidget {
  const NewWeightScreen({super.key});

  @override
  ConsumerState<NewWeightScreen> createState() => _NewWeightScreenState();
}

class _NewWeightScreenState extends ConsumerState<NewWeightScreen> {
  late final weightProv = ref.read(userWeightProvider.notifier);
  late final isKilograms =
      ref.watch(settingsFilterProvider)[Filter.useKilograms]!;
  final _weightValueController = TextEditingController();
  final _commentController = TextEditingController();
  double _enteredWeight = 0.00;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  late DateTime _selectedDateAndTime;
  String _userComment = '';

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 20, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );
    setState(() {
      _selectedDate = pickedDate!;
    });
  }

  void _presentTimePicker() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    setState(() {
      _selectedTime = pickedTime!;
    });
  }

  void _showDialog() {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Invalid Input'),
          content: const Text('Please make sure a valid weight was entered.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Okay"))
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Invalid Input'),
          content: const Text('Please make sure a valid weight was entered.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Okay"))
          ],
        ),
      );
    }
  }

  void _submitNewWeightData() {
    _userComment = _commentController.text;
    double? sum = double.tryParse(_weightValueController.text);

    if (sum == null || sum <= 0) {
      _showDialog();
      return;
    }

    _enteredWeight = sum;
    if (isKilograms) {
      _enteredWeight = weightProv.convertToPounds(sum);
    }

    _selectedDateAndTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    int epochConvertedDate = _selectedDateAndTime.millisecondsSinceEpoch;

    ref
        .read(userWeightProvider.notifier)
        .addWeight(epochConvertedDate, _enteredWeight, _userComment);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Weight',
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _weightValueController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)')),
              ],
              decoration: InputDecoration(
                  hintText: "Weight",
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  )),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Day:',
                  style: TextStyle(fontSize: 20),
                ),
                TextButton.icon(
                  onPressed: _presentDatePicker,
                  style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.secondary),
                  icon: const Icon(Icons.calendar_month),
                  label: Text(formatter.format(_selectedDate)),
                ),
                const Text(
                  'Time:',
                  style: TextStyle(fontSize: 20),
                ),
                TextButton.icon(
                  onPressed: _presentTimePicker,
                  style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.secondary),
                  icon: const Icon(Icons.more_time),
                  label: Text(_selectedTime.format(context)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _commentController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                hintText: "Add a comment",
                hintStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6)),
                border: const OutlineInputBorder(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    )),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _submitNewWeightData,
                  child: const Text("Save"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _weightValueController.dispose();
    _commentController.dispose();
    super.dispose();
  }
}
