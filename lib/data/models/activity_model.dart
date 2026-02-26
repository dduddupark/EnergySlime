import 'dart:convert';

enum ActivityType { calories, activeTime }

class ActivityModel {
  final int? id;
  final int steps;
  final double calories;
  final int activeMinutes;
  final DateTime date;
  final int timestamp;

  ActivityModel({
    this.id,
    required this.steps,
    required this.calories,
    required this.activeMinutes,
    required this.date,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'steps': steps,
      'calories': calories,
      'activeMinutes': activeMinutes,
      'date': date.toIso8601String(),
      'timestamp': timestamp,
    };
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'],
      steps: map['steps'],
      calories: map['calories'],
      activeMinutes: map['activeMinutes'],
      date: DateTime.parse(map['date']),
      timestamp: map['timestamp'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ActivityModel.fromJson(String source) =>
      ActivityModel.fromMap(json.decode(source));
}
