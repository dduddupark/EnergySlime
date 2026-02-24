import 'package:health/health.dart';
import '../models/activity_model.dart';

class HealthService {
  final Health health = Health();

  final types = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  Future<bool> requestPermissions() async {
    await health.configure();
    final permissions = types.map((e) => HealthDataAccess.READ).toList();

    try {
      bool? hasPermissions = await health.hasPermissions(types, permissions: permissions);
      if (hasPermissions == true) {
        print("[HealthService] Permissions already granted.");
        return true;
      }

      print("[HealthService] Requesting authorization for $types");
      bool result = await health.requestAuthorization(types, permissions: permissions);
      print("[HealthService] Authorization result: $result");
      return result;
    } catch (e, stacktrace) {
      print("[HealthService] Error requesting permissions: $e");
      print("[HealthService] Stacktrace: $stacktrace");
      return false;
    }
  }

  Future<List<ActivityModel>> fetchDailyData(DateTime startTime, DateTime endTime) async {
    try {
      print("[HealthService] Fetching data from $startTime to $endTime");
      List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: types,
      );

      print("[HealthService] Fetched ${healthData.length} data points");

      int totalSteps = 0;
      double totalCalories = 0.0;
      int totalMinutes = 0; 

      for (var point in healthData) {
        if (point.type == HealthDataType.STEPS) {
          totalSteps += (point.value as NumericHealthValue).numericValue.toInt();
        } else if (point.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
          totalCalories += (point.value as NumericHealthValue).numericValue.toDouble();
        }
      }

      print("[HealthService] Aggregated result - Steps: $totalSteps, Calories: $totalCalories");

      return [
        ActivityModel(
          steps: totalSteps,
          calories: totalCalories,
          activeMinutes: totalMinutes,
          date: startTime,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        )
      ];
    } catch (e, stacktrace) {
      print("[HealthService] Error fetching daily data: $e");
      print("[HealthService] Stacktrace: $stacktrace");
      throw e;
    }
  }

  Future<Map<DateTime, int>> fetchHistoryData(DateTime startTime, DateTime endTime) async {
    try {
      print("[HealthService] Fetching history from $startTime to $endTime");
      List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: [HealthDataType.STEPS],
      );

      Map<DateTime, int> stepsByDay = {};

      for (var point in healthData) {
        if (point.type == HealthDataType.STEPS) {
          DateTime date = DateTime(point.dateFrom.year, point.dateFrom.month, point.dateFrom.day);
          int steps = (point.value as NumericHealthValue).numericValue.toInt();
          stepsByDay[date] = (stepsByDay[date] ?? 0) + steps;
        }
      }

      print("[HealthService] Fetched history for ${stepsByDay.length} days.");
      return stepsByDay;
    } catch (e, stacktrace) {
      print("[HealthService] Error fetching history data: $e");
      print("[HealthService] Stacktrace: $stacktrace");
      return {};
    }
  }
}
