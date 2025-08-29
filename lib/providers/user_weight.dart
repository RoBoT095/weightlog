import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';
import 'package:intl/intl.dart';

import 'package:weightlog/models/weight.dart';

final formatter = DateFormat.yMMMd();

Future<Database> _getDatabase() async {
  final dbPath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(
    path.join(dbPath, 'weightTracker.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE user_weight (id TEXT PRIMARY KEY, date INTEGER, weight REAL, comment TEXT)',
      );
    },
    version: 1,
  );
  return db;
}

class UserWeightNotifier extends StateNotifier<List<WeightTrackModel>> {
  UserWeightNotifier() : super(const []);

  List<WeightTrackModel> _parseWeights(List<Map<String, Object?>> data) {
    return data
        .map(
          (row) => WeightTrackModel(
            id: row['id'] as String,
            date: row['date'] as int,
            weight: row['weight'] as double,
            comment: row['comment'] as String,
          ),
        )
        .toList();
  }

  Future<void> loadWeight() async {
    final db = await _getDatabase();
    final data = await db.query(
      'user_weight',
      orderBy: 'date DESC',
    );
    final weights = _parseWeights(data);

    state = weights;
  }

  void addWeight(int date, double weight, String comment) async {
    final newWeight =
        WeightTrackModel(date: date, weight: weight, comment: comment);

    final db = await _getDatabase();
    await db.transaction((txn) async {
      await txn.insert('user_weight', {
        'id': newWeight.id,
        'date': newWeight.date,
        'weight': newWeight.weight,
        'comment': newWeight.comment,
      });

      final data = await txn.query(
        'user_weight',
        orderBy: 'date DESC',
      );

      state = _parseWeights(data);
    });
  }

  void deleteWeight(String id) async {
    final db = await _getDatabase();
    await db.rawDelete('DELETE FROM user_weight WHERE id = ?', [id]);
  }

  void updateWeight(String id, int date, double weight, String comment) async {
    final updatedWeight =
        WeightTrackModel(id: id, date: date, weight: weight, comment: comment);

    final db = await _getDatabase();
    await db.update(
      'user_weight',
      {
        'date': updatedWeight.date,
        'weight': updatedWeight.weight,
        'comment': updatedWeight.comment,
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    final data = await db.query(
      'user_weight',
      orderBy: 'date DESC',
    );

    state = _parseWeights(data);
  }

  Future<void> exportDatabase(String saveToDir) async {
    final dbPath = await sql.getDatabasesPath();
    final sourcePath = path.join(dbPath, 'weightTracker.db');
    final targetPath = path.join(saveToDir, 'weightTracker_export.db');

    try {
      await File(targetPath).writeAsBytes(await File(sourcePath).readAsBytes());
      debugPrint('Database exported to: $targetPath');
    } catch (e) {
      debugPrint('Error exporting database: $e');
    }
  }

  Future<void> importDatabase(PlatformFile file) async {
    final dbPath = await sql.getDatabasesPath();
    final targetPath = path.join(dbPath, 'weightTracker.db');

    try {
      if (file.bytes != null) {
        await File(targetPath).writeAsBytes(file.bytes!);
        debugPrint('Database imported successfully');
        loadWeight();
      } else {
        debugPrint('File bytes is null');
      }
    } catch (e) {
      debugPrint('Error importing database: $e');
    }
  }

  String convertDate(int date) {
    DateTime newDate = DateTime.fromMillisecondsSinceEpoch(date);
    return formatter.format(newDate);
  }

  double dp(double val, int places) {
    num mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }

  double convertToKilograms(double weight) {
    final newWeight = dp((weight / 2.2046), 2);
    return newWeight;
  }

  double convertToPounds(double weight) {
    final newWeight = dp((weight * 2.2046), 2);
    return newWeight;
  }
}

final userWeightProvider =
    StateNotifierProvider<UserWeightNotifier, List<WeightTrackModel>>(
  (ref) => UserWeightNotifier(),
);
