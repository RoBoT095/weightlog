import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weightlog/providers/settings_filters.dart';
import 'package:weightlog/providers/user_goals.dart';

class UserGoalsCard extends ConsumerStatefulWidget {
  const UserGoalsCard({super.key});

  @override
  ConsumerState<UserGoalsCard> createState() => _UserGoalsCardState();
}

class _UserGoalsCardState extends ConsumerState<UserGoalsCard> {
  late TextEditingController _weightGoalController;
  bool _isGoalEditMode = false;

  @override
  void initState() {
    super.initState();
    _weightGoalController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final isKilograms = ref.watch(settingsFilterProvider)[Filter.useKilograms];
    final weightGoal = ref.watch(weightGoalProvider);

    _weightGoalController.text = weightGoal.toString();

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Center(
        child: Card(
          color: Theme.of(context).colorScheme.surfaceContainer,
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
                        weightGoal.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withRed(255),
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
                            label: Text('Goal:'),
                            labelStyle: TextStyle(fontSize: 20)),
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
              icon: Icon(
                !_isGoalEditMode ? Icons.edit : Icons.save,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () {
                if (_isGoalEditMode) {
                  final newWeightGoal =
                      double.parse(_weightGoalController.text);
                  ref
                      .watch(weightGoalProvider.notifier)
                      .setWeightGoal(newWeightGoal);
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

  @override
  void dispose() {
    _weightGoalController;
    super.dispose();
  }
}
