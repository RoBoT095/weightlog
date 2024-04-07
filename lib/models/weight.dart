import 'package:uuid/uuid.dart';

const uuid = Uuid();

class WeightTrackModel {
  WeightTrackModel({
    required this.date,
    required this.weight,
    required this.comment,
    String? id,
  }) : id = id ?? uuid.v4();

  final String id;
  final int date;
  final double weight;
  final String comment;
}
