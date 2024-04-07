import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weight_tracker/providers/settings_filters.dart';

class UserGoalsCard extends ConsumerStatefulWidget {
  const UserGoalsCard({super.key});

  @override
  ConsumerState<UserGoalsCard> createState() => _UserGoalsCardState();
}

class _UserGoalsCardState extends ConsumerState<UserGoalsCard> {
  late TextEditingController _weightGoalController;
  late double _weightGoal;
  bool _isGoalEditMode = false;

  @override
  void initState() {
    super.initState();
    _weightGoalController = TextEditingController();
    _loadWeightGoal();
  }

  Future<void> _loadWeightGoal() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _weightGoal = prefs.getDouble('weightGoal') ?? 0.0;
      _weightGoalController.text = _weightGoal.toString();
    });
  }

  Future<void> _saveWeightGoal(double weightGoal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('weightGoal', weightGoal);
  }

  @override
  void dispose() {
    _weightGoalController;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKilograms = ref.watch(settingsFilterProvider)[Filter.useKilograms];

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Center(
        child: Card(
          child: ListTile(
            leading: const Icon(
              Icons.flag,
              color: Colors.green,
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                !_isGoalEditMode
                    ? Text(
                        _weightGoalController.text,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      )
                    : Expanded(
                        child: TextField(
                        controller: _weightGoalController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'(^\d*\.?\d*)')),
                        ],
                        decoration: const InputDecoration(
                          label: Text('Goal'),
                        ),
                      )),
                Text(
                  isKilograms! ? ' kg' : ' lb',
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(!_isGoalEditMode ? Icons.settings : Icons.save),
              onPressed: () {
                if (_isGoalEditMode) {
                  final newWeightGoal =
                      double.parse(_weightGoalController.text);
                  _saveWeightGoal(newWeightGoal);
                }
                setState(() {
                  _isGoalEditMode = !_isGoalEditMode;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
