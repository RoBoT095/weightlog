import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weightlog/models/weight.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weightlog/providers/settings_filters.dart';
import 'package:weightlog/providers/user_weight.dart';

class WeightEntryScreen extends ConsumerStatefulWidget {
  const WeightEntryScreen({super.key, required this.userWeight});

  final WeightTrackModel userWeight;

  @override
  ConsumerState<WeightEntryScreen> createState() => _WeightEntryScreenState();
}

class _WeightEntryScreenState extends ConsumerState<WeightEntryScreen> {
  late final weightProv = ref.read(userWeightProvider.notifier);
  late final isKilograms =
      ref.watch(settingsFilterProvider)[Filter.useKilograms]!;

  late TextEditingController _weightController;
  late TextEditingController _commentController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late bool _isEditMode;

  @override
  void initState() {
    super.initState();
    _weightController =
        TextEditingController(text: widget.userWeight.weight.toString());
    _commentController = TextEditingController(text: widget.userWeight.comment);
    _selectedDate = DateTime.fromMillisecondsSinceEpoch(widget.userWeight.date);
    _selectedTime = TimeOfDay.fromDateTime(_selectedDate);
    _isEditMode = false;
  }

  @override
  void dispose() {
    _weightController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveChanges() {
    final updatedDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    final parseWeight = double.parse(_weightController.text);
    double updatedWeight = parseWeight;
    if (isKilograms) {
      updatedWeight = weightProv.convertToPounds(parseWeight);
    }
    final updatedComment = _commentController.text;
    final updatedId = widget.userWeight.id;

    weightProv.updateWeight(
      updatedId,
      updatedDate.millisecondsSinceEpoch,
      updatedWeight,
      updatedComment,
    );

    setState(() {
      _isEditMode = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMMM dd, yyyy');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weight Entry',
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.save : Icons.edit),
            onPressed: () {
              setState(() {
                if (!_isEditMode) {
                  _weightController.text = isKilograms
                      ? weightProv
                          .convertToKilograms(widget.userWeight.weight)
                          .toString()
                      : widget.userWeight.weight.toString();
                  _commentController.text = widget.userWeight.comment;
                  _selectedDate = DateTime.fromMillisecondsSinceEpoch(
                      widget.userWeight.date);
                  _selectedTime = TimeOfDay.fromDateTime(_selectedDate);
                }
                _isEditMode = !_isEditMode;
              });

              if (!_isEditMode) {
                _saveChanges();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Weight
            _isEditMode
                ? TextFormField(
                    controller: _weightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Weight (${isKilograms ? 'kg' : 'lb'}):',
                      labelStyle: const TextStyle(fontSize: 20),
                    ),
                  )
                : Center(
                    child: Text(
                      '${isKilograms ? weightProv.convertToKilograms(widget.userWeight.weight) : widget.userWeight.weight} ${isKilograms ? 'kg' : 'lb'}',
                      style: TextStyle(
                        fontSize: MediaQuery.sizeOf(context).width / 10,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
            // Date and Time
            _isEditMode
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => _selectDate(context),
                        child: Text(
                          formatter.format(_selectedDate),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _selectTime(context),
                        child: Text(
                          _selectedTime.format(context),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      '${formatter.format(_selectedDate)} ${_selectedTime.format(context)}',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
            const SizedBox(height: 20),
            const Divider(),
            // Comment
            if (!_isEditMode)
              const Text(
                "Comment:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            _isEditMode
                ? TextFormField(
                    controller: _commentController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      labelText: 'Comment:',
                      labelStyle: TextStyle(fontSize: 20),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.userWeight.comment,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
