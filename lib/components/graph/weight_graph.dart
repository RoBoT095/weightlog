import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weightlog/models/weight.dart';
import 'package:weightlog/providers/settings_filters.dart';
import 'package:weightlog/providers/user_weight.dart';
import 'package:weightlog/providers/user_goals.dart';

class WeightGraph extends ConsumerWidget {
  const WeightGraph({
    super.key,
    required this.weightData,
    required this.graphDayDuration,
  });

  final List<WeightTrackModel> weightData;
  final int graphDayDuration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isDark = MediaQuery.platformBrightnessOf(context).name == 'dark';
    final weightProv = ref.read(userWeightProvider.notifier);
    final isKilograms = ref.watch(settingsFilterProvider)[Filter.useKilograms]!;
    final weightGoal = ref.watch(weightGoalProvider);

    List<FlSpot> dataPoints = [];
    List<WeightTrackModel> filteredWeightData = [];

    // flip data around so graph starts with oldest to newest data points
    weightData.sort((a, b) => a.date.compareTo(b.date));

    int startIndex = weightData.length - graphDayDuration;
    if (startIndex < 0) startIndex = 0;

    for (int i = startIndex; i < weightData.length; i++) {
      filteredWeightData.add(weightData[i]);
      double w = weightData[i].weight;
      if (isKilograms) {
        w = weightProv.convertToKilograms(w);
      }
      dataPoints.add(FlSpot(i - startIndex.toDouble(), w));
    }

    double calculateMinWeight(List<FlSpot> dataPoints) {
      double minWeight = double.infinity;
      for (final spot in dataPoints) {
        if (spot.y < minWeight) {
          minWeight = spot.y.floorToDouble();
        }
      }
      return minWeight;
    }

    double calculateMaxWeight(List<FlSpot> dataPoints) {
      double maxWeight = 0;
      for (final spot in dataPoints) {
        if (spot.y > maxWeight) {
          maxWeight = spot.y.ceilToDouble();
        }
      }
      return maxWeight;
    }

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: dataPoints,
              gradient: isDark
                  // Dark Theme Line Gradient
                  ? const LinearGradient(colors: [
                      Color.fromRGBO(0, 163, 164, 1),
                      Color.fromRGBO(0, 188, 161, 1),
                      Color.fromRGBO(0, 212, 147, 1),
                      Color.fromRGBO(105, 232, 130, 1),
                      Color.fromRGBO(175, 250, 112, 1),
                    ])
                  // Light Theme Line Gradient
                  : const LinearGradient(colors: [
                      Color.fromRGBO(2, 142, 242, 1),
                      Color.fromRGBO(0, 170, 228, 1),
                      Color.fromRGBO(0, 192, 217, 1),
                      Color.fromRGBO(0, 216, 199, 1),
                      Color.fromRGBO(44, 237, 163, 1),
                    ]),
              barWidth: 4,
              isCurved: true,
              preventCurveOverShooting: true,
            ),
          ],
          extraLinesData: ExtraLinesData(horizontalLines: [
            HorizontalLine(
                y: weightGoal,
                color: Colors.green.withOpacity(0.6),
                dashArray: [20, 20])
          ]),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((lineSpot) {
                  if (lineSpot.x.toInt() > weightData.length) {
                    return null;
                  }
                  final lineData = filteredWeightData[lineSpot.x.toInt()];
                  return LineTooltipItem(
                    '${isKilograms ? weightProv.convertToKilograms(lineData.weight) : lineData.weight} \n ${weightProv.convertDate(lineData.date)}',
                    const TextStyle(
                      color: Colors.white,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          minX: 0,
          maxX: graphDayDuration.toDouble() - 1,
          minY: calculateMinWeight(dataPoints),
          maxY: calculateMaxWeight(dataPoints),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: Text('Weight (${isKilograms ? 'kg' : 'lbs'})'),
              sideTitles: const SideTitles(
                showTitles: true,
                reservedSize: 45,
              ),
            ),
            bottomTitles: AxisTitles(
              axisNameWidget: const Text('Days'),
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    (value.toInt() + 1).toString(),
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
