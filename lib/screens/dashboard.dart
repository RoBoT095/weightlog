import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weight_tracker/providers/user_weight.dart';
import 'package:weight_tracker/widgets/weight_list.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends ConsumerState<DashboardScreen> {
  late Future<void> _weightFuture;

  @override
  void initState() {
    super.initState();
    _weightFuture = ref.read(userWeightProvider.notifier).loadWeight();
  }

  @override
  Widget build(BuildContext context) {
    final userWeights = ref.watch(userWeightProvider);

    return FutureBuilder(
      future: _weightFuture,
      builder: (context, snapshot) =>
          snapshot.connectionState == ConnectionState.waiting
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : WeightList(userWeights: userWeights),
    );
  }
}
