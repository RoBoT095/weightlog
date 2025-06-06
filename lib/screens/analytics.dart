import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weightlog/providers/user_weight.dart';
import 'package:weightlog/components/graph/weight_graph.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weightData = ref.watch(userWeightProvider);
    const double heightSpacing = 15;

    if (weightData.isEmpty) {
      return Center(
        child: Text(
          'Add at least 1 weight entry to view analytics.',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Past Week',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            WeightGraph(
              weightData: weightData,
              graphDayDuration: 7,
            ),
            const SizedBox(height: heightSpacing),
            const Text(
              'Past Month',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            WeightGraph(
              weightData: weightData,
              graphDayDuration: 30,
            ),
            const SizedBox(height: heightSpacing),
            const Text(
              'Past 3 Months',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            WeightGraph(
              weightData: weightData,
              graphDayDuration: 90,
            ),
            const SizedBox(height: heightSpacing),
            const Text(
              'All Time',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            WeightGraph(
              weightData: weightData,
              graphDayDuration: weightData.length,
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
