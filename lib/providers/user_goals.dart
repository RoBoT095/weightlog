import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeightGoalNotifier extends StateNotifier<double> {
  WeightGoalNotifier() : super(0.0) {
    loadWeightGoal();
  }
  Future<void> loadWeightGoal() async {
    final prefs = await SharedPreferences.getInstance();
    final getGoal = prefs.getDouble('weightGoal') ?? 0.0;
    state = getGoal;
  }

  Future<void> setWeightGoal(double weightGoal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('weightGoal', weightGoal);
    state = weightGoal;
  }
}

final weightGoalProvider = StateNotifierProvider<WeightGoalNotifier, double>(
  (ref) => WeightGoalNotifier(),
);
