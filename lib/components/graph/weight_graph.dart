import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weightlog/models/weight.dart';
import 'package:weightlog/providers/settings_filters.dart';
import 'package:weightlog/providers/user_weight.dart';

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
    final weightProv = ref.read(userWeightProvider.notifier);
    final isKilograms = ref.watch(settingsFilterProvider)[Filter.useKilograms]!;
    List<FlSpot> dataPoints = [];

    // flip data around so graph starts with oldest to newest data points
    weightData.sort((a, b) => a.date.compareTo(b.date));

    int startIndex = weightData.length - graphDayDuration;
    if (startIndex < 0) startIndex = 0;

    for (int i = startIndex; i < weightData.length; i++) {
      double weight = weightData[i].weight;
      if (isKilograms) {
        weight = weightProv.convertToKilograms(weightData[i].weight);
      }
      dataPoints.add(FlSpot((i - startIndex).toDouble(), (weight)));
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
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((lineSpot) {
                  if (lineSpot.x.toInt() > weightData.length) {
                    return null;
                  }
                  return LineTooltipItem(
                    '${isKilograms ? weightProv.convertToKilograms(weightData[lineSpot.x.toInt()].weight) : weightData[lineSpot.x.toInt()].weight} \n ${weightProv.convertDate(weightData[lineSpot.x.toInt()].date)}',
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
