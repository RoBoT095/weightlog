import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weight_tracker/models/weight.dart';
import 'package:weight_tracker/providers/settings_filters.dart';
import 'package:weight_tracker/providers/user_weight.dart';
import 'package:weight_tracker/screens/weight_entry.dart';
import 'package:weight_tracker/widgets/goals_card.dart';

class WeightList extends ConsumerStatefulWidget {
  const WeightList({super.key, required this.userWeights});

  final List<WeightTrackModel> userWeights;

  @override
  ConsumerState<WeightList> createState() => _WeightListState();
}

class _WeightListState extends ConsumerState<WeightList> {
  late WeightTrackModel copiedForUndo;

  @override
  Widget build(BuildContext context) {
    final weightProv = ref.read(userWeightProvider.notifier);
    final isKilograms = ref.watch(settingsFilterProvider)[Filter.useKilograms]!;

    void addItemBack() {
      ref.read(userWeightProvider.notifier).addWeight(
            copiedForUndo.date,
            copiedForUndo.weight,
            copiedForUndo.comment,
          );
    }

    void removeItem(WeightTrackModel item) {
      copiedForUndo = item;
      weightProv.deleteWeight(item.id);

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Removed weight entry'),
        action: SnackBarAction(label: 'Undo', onPressed: addItemBack),
      ));
    }

    if (widget.userWeights.isEmpty) {
      return Center(
        child: Text(
          'No weight entries added yet.',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      );
    }
    return Column(
      children: [
        const UserGoalsCard(),
        Expanded(
          child: ListView.builder(
            itemCount: widget.userWeights.length,
            itemBuilder: (context, index) => Dismissible(
              key: ValueKey(widget.userWeights[index].id),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                removeItem(widget.userWeights[index]);
                setState(() {
                  widget.userWeights.removeAt(index);
                });
              },
              background: Container(
                color: Colors.red,
                margin: const EdgeInsets.symmetric(horizontal: 15),
                alignment: Alignment.centerRight,
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ListTile(
                  leading: const Icon(Icons.fitness_center),
                  title: Row(
                    children: [
                      Text(
                        isKilograms
                            ? weightProv
                                .convertToKilograms(
                                    widget.userWeights[index].weight)
                                .toString()
                            : widget.userWeights[index].weight.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Color.fromARGB(255, 224, 128, 2),
                        ),
                      ),
                      Text(
                        isKilograms ? ' kg' : ' lb',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    weightProv.convertDate(widget.userWeights[index].date),
                    style: const TextStyle(fontSize: 14),
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => WeightEntryScreen(
                              userWeight: widget.userWeights[index],
                            )));
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
