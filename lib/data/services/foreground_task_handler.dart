import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:pedometer/pedometer.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(PedometerTaskHandler());
}

class PedometerTaskHandler extends TaskHandler {
  StreamSubscription<StepCount>? _stepSubscription;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    final languageCode = Platform.localeName.split('_')[0];
    final locale = Locale(languageCode);
    final l10n = lookupAppLocalizations(locale);

    FlutterForegroundTask.updateService(
      notificationTitle: 'Energy Slime',
      notificationText: l10n.initStepData,
    );
    // 백그라운드에서 만보기 스트림 시작
    _stepSubscription = Pedometer.stepCountStream.listen((StepCount event) {
      // 센서 업데이트 시 노티피케이션 업데이트
      FlutterForegroundTask.updateService(
        notificationTitle: 'Energy Slime',
        notificationText: l10n.trackingSteps,
      );
    });
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // 주기적 작업 (비워둠)
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    _stepSubscription?.cancel();
  }
}
