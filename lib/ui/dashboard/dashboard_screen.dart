import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ui/providers/activity_provider.dart';
import '../../ui/providers/points_provider.dart';
import '../../ui/providers/shop_provider.dart';
import '../../data/models/activity_model.dart';
import '../../data/models/activity_state.dart';
import '../../ui/widgets/slime_character.dart';
import 'package:intl/intl.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import '../../data/services/fallback_pedometer_service.dart';
import '../../data/services/shop_storage_service.dart';
import '../../data/models/shop_item.dart';
import '../settings/settings_screen.dart';
import '../shop/shop_screen.dart';
import 'package:stepflow/l10n/app_localizations.dart';
import '../shop/shop_item_visual.dart';
import 'detail_screen.dart';

const Color slateAlpha = Color(0xFF94A3B8);

class DashboardScreen extends ConsumerStatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with WidgetsBindingObserver {
  
  final FallbackPedometerService _pedometerService = FallbackPedometerService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initForegroundTask();
    
    // Call after first frame when context is ready for Localizations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activityProvider.notifier).loadData(
        notificationTitle: AppLocalizations.of(context)!.appTitle,
        notificationText: AppLocalizations.of(context)!.trackingSteps,
      );
    });
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
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(activityProvider.notifier).loadData(
        notificationTitle: AppLocalizations.of(context)!.appTitle,
        notificationText: AppLocalizations.of(context)!.trackingSteps,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activityState = ref.watch(activityProvider);
    final currentPoints = ref.watch(pointsProvider);
    final equippedItems = ref.watch(equippedItemsProvider);

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
              ref.read(pointsProvider.notifier).refreshPoints();
              ref.read(shopItemsProvider.notifier).refreshItems();
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
                  const Icon(Icons.water_drop, color: Colors.blueAccent, size: 16),
                  const SizedBox(width: 4),
                  Text('$currentPoints',
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
              if (activityState.todayActivity == null && !activityState.isLoading)
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
                        onPressed: () => ref.read(activityProvider.notifier).loadData(
                            isUserInitiated: true,
                            forceRequest: true,
                            notificationTitle: AppLocalizations.of(context)!.appTitle,
                            notificationText: AppLocalizations.of(context)!.trackingSteps,
                        ),
                        child: Text(AppLocalizations.of(context)!.connect),
                      )
                    ],
                  ),
                ),
              _buildSummaryCard(colorScheme, activityState, equippedItems),
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
              _buildStatGrid(colorScheme, activityState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ColorScheme colorScheme, ActivityState activityState, List<ShopItem> equippedItems) {
    int targetSteps = 10000;
    int currentSteps = activityState.todayActivity?.steps ?? 0;

    int lifetimeSteps = currentSteps; 

    ShopItem? bgItem;
    try {
      bgItem = equippedItems.firstWhere((i) => i.category == 'bg');
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
                color: colorScheme.primary.withOpacity(0.05),
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
                    height: 220,
                    child: Center(
                      child: SlimeCharacter(
                        currentSteps: currentSteps,
                        dailyGoal: targetSteps,
                        totalLifetimeSteps: lifetimeSteps,
                        equippedItems: equippedItems,
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
                color: colorScheme.onSurface.withOpacity(0.6),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
                      final currentPoints = await ShopStorageService().loadPoints();
                      await ShopStorageService().savePoints(currentPoints + 100);
                      ref.read(pointsProvider.notifier).refreshPoints();
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
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        int steps = (index + 1) * 1000;
                        return ListTile(
                          title: Text(
                              AppLocalizations.of(context)!.stepUnit(steps),
                              style: const TextStyle(color: Colors.white70)),
                          onTap: () async {
                            Navigator.pop(context);
                            await _pedometerService.setDebugSteps(steps);

                            // We can just trigger a fake update into the provider directly for debug UI
                            ref.read(activityProvider.notifier).state = ref.read(activityProvider).copyWith(
                              todayActivity: ActivityModel(
                                steps: steps,
                                calories: steps * 0.04,
                                activeMinutes: (steps / 100).floor(),
                                date: DateTime.now(),
                                timestamp: DateTime.now().millisecondsSinceEpoch,
                              )
                            );

                            if (mounted) {
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

  Widget _buildStatGrid(ColorScheme colorScheme, ActivityState activityState) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            colorScheme,
            AppLocalizations.of(context)!.calories,
            '${activityState.todayActivity?.calories.toInt() ?? 0}',
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
            '${activityState.todayActivity?.activeMinutes ?? 0}',
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
                color: const Color(0xFFF9E076).withOpacity(0.3),
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
