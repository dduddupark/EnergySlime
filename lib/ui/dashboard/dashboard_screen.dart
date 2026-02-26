import 'package:flutter/material.dart';
import '../../data/models/activity_model.dart';
import '../../data/services/health_service.dart';
import '../../ui/widgets/slime_character.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:health/health.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:health/health.dart';
import '../../data/services/fallback_pedometer_service.dart';
import '../../data/services/foreground_task_handler.dart';
import '../../data/services/shop_storage_service.dart';
import '../../data/models/shop_item.dart';
import '../settings/settings_screen.dart';
import '../shop/shop_screen.dart';
import 'package:stepflow/l10n/app_localizations.dart';
import '../shop/shop_item_visual.dart';
import 'detail_screen.dart';
import 'dart:async';
import '../../data/models/activity_model.dart';

// Fixed incorrect extension usage
const Color slateAlpha = Color(0xFF94A3B8);

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  final HealthService _healthService = HealthService();
  final FallbackPedometerService _pedometerService = FallbackPedometerService();
  ActivityModel? _todayActivity;
  bool _isLoading = true;
  bool _isDialogShowing = false;
  bool _isRequestingPermission = false; // Flag to prevent loop
  bool _isFetching = false;
  DateTime? _lastPermissionRequestTime;
  StreamSubscription<int>? _stepSubscription;
  int _currentPoints = 0;
  List<ShopItem> _equippedItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initForegroundTask();
    _loadData();
    _loadPoints();
  }

  void _loadPoints() async {
    final points = await ShopStorageService().loadPoints();
    final items = await ShopStorageService().loadItems();
    if (mounted) {
      setState(() {
        _currentPoints = points;
        _equippedItems = items.where((i) => i.isEquipped).toList();
      });
    }
  }

  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'step_counter',
        channelName: 'Step Counter Notification',
        channelDescription:
            'This notification keeps the step counter alive in the background.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stepSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_isRequestingPermission || _isFetching || _isDialogShowing) return;

      // 권한 요청 팝업이 닫힌 직후에 발생하는 지연된 resumed 이벤트를 무시하여 무한루프 방지
      if (_lastPermissionRequestTime != null &&
          DateTime.now()
                  .difference(_lastPermissionRequestTime!)
                  .inMilliseconds <
              1000) {
        return;
      }

      _loadData();
    }
  }

  Future<void> _loadData(
      {bool isUserInitiated = false, bool forceRequest = false}) async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      if (!isUserInitiated) {
        setState(() => _isLoading = true);
      }

      bool hasHealthData = false;

      // 1. Check if we already have Health Connect permissions.
      // We don't want to trigger the system popup automatically on app start unless forceRequest is true.
      final permissions = _healthService.types
          .map<HealthDataAccess>((e) => HealthDataAccess.READ)
          .toList();
      bool? hasHealthConnectPerms = await _healthService.health
          .hasPermissions(_healthService.types, permissions: permissions);

      bool authorized = hasHealthConnectPerms == true;

      // If user clicked a button, force the request
      if (!authorized && forceRequest) {
        _isRequestingPermission = true;
        authorized = await _healthService.requestPermissions();
        _lastPermissionRequestTime = DateTime.now();
        _isRequestingPermission = false;
      }

      if (authorized) {
        final now = DateTime.now();
        final midnight = DateTime(now.year, now.month, now.day);
        try {
          final data = await _healthService.fetchDailyData(midnight, now);
          if (data.isNotEmpty && data.first.steps > 0) {
            hasHealthData = true;
            setState(() {
              _todayActivity = data.first;
              _isLoading = false;
            });
          }
        } catch (e) {
          debugPrint('Error fetching Health Connect data: $e');
        }
      }

      // 2. If Health Connect didn't work or gave 0 steps, try Activity Recognition (Sensor)
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
          hasHealthData = true; // 우리는 센서에 의존할거임

          // 알림 권한 요청 (Android 13+ 에서 알림을 띄우기 위해 필수)
          if (await Permission.notification.isDenied) {
            await Permission.notification.request();
          }

          // Foreground task (Notification) 시작
          if (await FlutterForegroundTask.isRunningService == false) {
            FlutterForegroundTask.startService(
              notificationTitle: AppLocalizations.of(context)!.appTitle,
              notificationText: AppLocalizations.of(context)!.trackingSteps,
              callback: startCallback,
            );
          }

          // 스트림 구독 해제/재구독 방지
          _stepSubscription?.cancel();
          _stepSubscription =
              _pedometerService.stepStream.listen((steps) async {
            if (mounted) {
              int earned = await ShopStorageService().checkAndEarnPoints(steps);
              if (earned > 0) {
                _loadPoints(); // 포인트 화면 갱신
              }

              setState(() {
                _todayActivity = ActivityModel(
                  steps: steps,
                  calories: steps * 0.04,
                  activeMinutes: (steps / 100).floor(),
                  date: DateTime.now(),
                  timestamp: DateTime.now().millisecondsSinceEpoch,
                );
                _isLoading = false;
              });
            }
          }, onError: (error) {
            debugPrint("Pedometer stream error: $error");
          });

          // 빠른 초기 표시를 위해 로딩 삭제
          setState(() => _isLoading = false);
        }
      }

      // Finish loading state
      setState(() => _isLoading = false);

      if (!hasHealthData && _todayActivity == null && mounted && forceRequest) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.noHealthDataWarning)),
        );
      }
    } finally {
      _isFetching = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShopScreen()),
              );
              _loadPoints(); // 상점에서 나오면 상태 및 포인트 갱신
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(28.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.water_drop,
                      color: Colors.blueAccent, size: 16),
                  const SizedBox(width: 4),
                  Text('$_currentPoints',
                      style: TextStyle(
                          color: Colors.blue[600],
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_todayActivity == null && !_isLoading)
                Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(28.0),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.noDataMsg,
                          style: TextStyle(
                              color: Colors.orange[200], fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _loadData(
                            isUserInitiated: true, forceRequest: true),
                        child: Text(AppLocalizations.of(context)!.connect),
                      )
                    ],
                  ),
                ),
              _buildSummaryCard(colorScheme),
              SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.todayRecord,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              _buildStatGrid(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ColorScheme colorScheme) {
    int targetSteps = 10000;
    int currentSteps = _todayActivity?.steps ?? 0;

    // Determine evolution level based on mock lifetime steps (or just use current for now as MVP)
    // In a real app, this would come from a user stats provider
    int lifetimeSteps =
        currentSteps; // TODO: Replace with actual lifetime steps

    ShopItem? bgItem;
    try {
      bgItem = _equippedItems.firstWhere((i) => i.category == 'bg');
    } catch (e) {
      bgItem = null;
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(28.0),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (bgItem != null)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28.0),
                    child: Opacity(
                      opacity: 0.5,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: ShopItemVisual(itemId: bgItem.id, size: 300),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                child: Center(
                  child: SizedBox(
                    height:
                        220, // Increased height to prevent bottom overflow when hats are equipped
                    child: Center(
                      child: SlimeCharacter(
                        currentSteps: currentSteps,
                        dailyGoal: targetSteps,
                        totalLifetimeSteps: lifetimeSteps,
                        equippedItems: _equippedItems,
                        onMultiTap: () => _showDebugStepDialog(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Step Counter Text below the character container
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              NumberFormat('#,###').format(currentSteps),
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 36,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '/ ${NumberFormat('#,###').format(targetSteps)} ${AppLocalizations.of(context)!.stepsUnit}',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Minimal progress bar
        LinearProgressIndicator(
          value: (currentSteps / targetSteps).clamp(0.0, 1.0),
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.grey[200]!
              : Colors.grey[800]!,
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
          minHeight: 12,
        ),
      ],
    );
  }

  void _showDebugStepDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: Text(AppLocalizations.of(context)!.testingTitle,
                style: const TextStyle(color: Colors.white)),
            content: Container(
              width: double.maxFinite,
              constraints: BoxConstraints(maxHeight: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading:
                        const Icon(Icons.water_drop, color: Colors.blueAccent),
                    title: Text(AppLocalizations.of(context)!.add100Points,
                        style: const TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold)),
                    onTap: () async {
                      Navigator.pop(context);
                      final currentPoints =
                          await ShopStorageService().loadPoints();
                      await ShopStorageService()
                          .savePoints(currentPoints + 100);
                      _loadPoints();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .add100PointsSuccess)),
                        );
                      }
                    },
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: 10, // 1000 ~ 10000
                      itemBuilder: (context, index) {
                        int steps = (index + 1) * 1000;
                        return ListTile(
                          title: Text(
                              AppLocalizations.of(context)!.stepUnit(steps),
                              style: const TextStyle(color: Colors.white70)),
                          onTap: () async {
                            Navigator.pop(context);
                            await _pedometerService.setDebugSteps(steps);

                            if (mounted) {
                              setState(() {
                                _todayActivity = ActivityModel(
                                  steps: steps,
                                  calories: steps * 0.04,
                                  activeMinutes: (steps / 100).floor(),
                                  date: DateTime.now(),
                                  timestamp:
                                      DateTime.now().millisecondsSinceEpoch,
                                );
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(AppLocalizations.of(context)!
                                        .stepsSetMessage(steps))),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildStatGrid(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            colorScheme,
            AppLocalizations.of(context)!.calories,
            '${_todayActivity?.calories.toInt() ?? 0}',
            'kcal',
            Icons.local_fire_department,
            Colors.orangeAccent,
            ActivityType.calories,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            colorScheme,
            AppLocalizations.of(context)!.activeTime,
            '${_todayActivity?.activeMinutes ?? 0}',
            'min',
            Icons.timer,
            Colors.greenAccent,
            ActivityType.activeTime,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(ColorScheme colorScheme, String title, String value,
      String unit, IconData icon, Color color, ActivityType type) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              title: title,
              type: type,
              primaryColor: colorScheme.primary,
              currentValue: value,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(28.0),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9E076).withOpacity(0.3), // Light Lemon
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$title ($unit)',
                    style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
