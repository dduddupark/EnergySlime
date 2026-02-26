import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/activity_state.dart';
import '../../data/models/activity_model.dart';
import '../../data/services/health_service.dart';
import '../../data/services/fallback_pedometer_service.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import '../../data/services/foreground_task_handler.dart';
import '../../data/services/shop_storage_service.dart';
import 'points_provider.dart';

final activityProvider = NotifierProvider<ActivityNotifier, ActivityState>(ActivityNotifier.new);

class ActivityNotifier extends Notifier<ActivityState> {
  final HealthService _healthService = HealthService();
  final FallbackPedometerService _pedometerService = FallbackPedometerService();
  StreamSubscription<int>? _stepSubscription;
  DateTime? _lastPermissionRequestTime;
  bool _isRequestingPermission = false;

  @override
  ActivityState build() {
    ref.onDispose(() {
      _stepSubscription?.cancel();
    });
    return ActivityState();
  }

  Future<void> loadData({
    bool isUserInitiated = false, 
    bool forceRequest = false, 
    String? notificationTitle, 
    String? notificationText
  }) async {
    if (state.isFetching || _isRequestingPermission) return;
    
    // 안티루프 로직
    if (_lastPermissionRequestTime != null &&
        DateTime.now().difference(_lastPermissionRequestTime!).inMilliseconds < 1000) {
      return;
    }

    state = state.copyWith(isFetching: true, isLoading: !isUserInitiated ? true : state.isLoading);

    try {
      bool hasHealthData = false;
      final permissions = _healthService.types.map<HealthDataAccess>((e) => HealthDataAccess.READ).toList();
      bool? hasHealthConnectPerms = await _healthService.health.hasPermissions(_healthService.types, permissions: permissions);
      bool authorized = hasHealthConnectPerms == true;

      // 권한 요청
      if (!authorized && forceRequest) {
        _isRequestingPermission = true;
        authorized = await _healthService.requestPermissions();
        _lastPermissionRequestTime = DateTime.now();
        _isRequestingPermission = false;
      }

      // 1. Health Connect (헬스 커넥트) 데이터 조회
      if (authorized) {
        final now = DateTime.now();
        final midnight = DateTime(now.year, now.month, now.day);
        try {
          final data = await _healthService.fetchDailyData(midnight, now);
          if (data.isNotEmpty && data.first.steps > 0) {
            hasHealthData = true;
            state = state.copyWith(todayActivity: data.first, isLoading: false, hasHealthData: true);
          }
        } catch (e) {
          debugPrint('Error fetching Health Connect data: $e');
        }
      }

      // 2. Health Connect가 없거나 0걸음이면 센서(Pedometer) 구독
      if (!hasHealthData) {
        bool isSensorGranted = await Permission.activityRecognition.isGranted;

        if (!isSensorGranted && forceRequest) {
          _isRequestingPermission = true;
          final status = await Permission.activityRecognition.request();
          isSensorGranted = status.isGranted;
          _lastPermissionRequestTime = DateTime.now();
          _isRequestingPermission = false;
        }

        if (isSensorGranted) {
          hasHealthData = true;

          if (await Permission.notification.isDenied) {
            await Permission.notification.request();
          }

          if (await FlutterForegroundTask.isRunningService == false && notificationTitle != null && notificationText != null) {
            FlutterForegroundTask.startService(
              notificationTitle: notificationTitle,
              notificationText: notificationText,
              callback: startCallback,
            );
          }

          _stepSubscription?.cancel();
          _stepSubscription = _pedometerService.stepStream.listen((steps) async {
            
            // 포인트 적립 로직 (Riverpod으로 위임)
            int earned = await ShopStorageService().checkAndEarnPoints(steps);
            if (earned > 0) {
              ref.read(pointsProvider.notifier).refreshPoints();
            }

            final newActivity = ActivityModel(
              steps: steps,
              calories: steps * 0.04,
              activeMinutes: (steps / 100).floor(),
              date: DateTime.now(),
              timestamp: DateTime.now().millisecondsSinceEpoch,
            );
            
            // 상태 업데이트 (UI 자동 갱신 트리거)
            state = state.copyWith(todayActivity: newActivity, isLoading: false, hasHealthData: true);
          }, onError: (error) {
            debugPrint("Pedometer stream error: $error");
          });
          
          state = state.copyWith(isLoading: false, hasHealthData: true);
        }
      }

      state = state.copyWith(isLoading: false, hasHealthData: hasHealthData);

    } finally {
      state = state.copyWith(isFetching: false);
    }
  }
}
