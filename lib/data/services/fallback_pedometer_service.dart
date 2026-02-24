import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class FallbackPedometerService {
  int _todaySteps = 0;
  StreamSubscription<StepCount>? _subscription;

  Stream<int> get stepStream {
    return Pedometer.stepCountStream.asyncMap((StepCount event) async {
      final prefs = await SharedPreferences.getInstance();
      final String todayKey = 'midnight_step_count_${DateFormat('yyyy-MM-dd').format(DateTime.now())}';
      
      int? midnightSteps = prefs.getInt(todayKey);
      
      if (midnightSteps == null) {
        await prefs.setInt(todayKey, event.steps);
        midnightSteps = event.steps;
      }

      int todaySteps = event.steps - midnightSteps;
      
      if (todaySteps < 0) {
         await prefs.setInt(todayKey, event.steps);
         todaySteps = 0;
      }
      return todaySteps;
    });
  }

  Future<void> setDebugSteps(int targetSteps) async {
    try {
      final currentEvent = await Pedometer.stepCountStream.first;
      final prefs = await SharedPreferences.getInstance();
      final String todayKey = 'midnight_step_count_${DateFormat('yyyy-MM-dd').format(DateTime.now())}';
      
      int newMidnight = currentEvent.steps - targetSteps;
      await prefs.setInt(todayKey, newMidnight);
    } catch (e) {
    }
  }
}
