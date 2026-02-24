import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:pedometer/pedometer.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(PedometerTaskHandler());
}

class PedometerTaskHandler extends TaskHandler {
  StreamSubscription<StepCount>? _stepSubscription;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    FlutterForegroundTask.updateService(
      notificationTitle: 'Energy Slime',
      notificationText: '걸음 수 데이터를 초기화 중입니다...',
    );
    // 백그라운드에서 만보기 스트림 시작
    _stepSubscription = Pedometer.stepCountStream.listen((StepCount event) {
      // 센서 업데이트 시 노티피케이션 업데이트
      FlutterForegroundTask.updateService(
        notificationTitle: 'Energy Slime',
        notificationText: '걸음 수 기록 중...', // 단순 상태 메시지만 표출
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
