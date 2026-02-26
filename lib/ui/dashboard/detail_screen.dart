import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:stepflow/data/models/activity_model.dart';
import '../../data/services/health_service.dart';
import '../../data/services/fallback_pedometer_service.dart';

class DetailScreen extends StatefulWidget {
  final String title;
  final ActivityType type; // ActivityType.calories or ActivityType.active_time
  final Color primaryColor;
  final String currentValue;

  const DetailScreen({
    super.key,
    required this.title,
    required this.type,
    required this.primaryColor,
    required this.currentValue,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isLoading = true;
  List<FlSpot> _chartData = [];
  double _maxY = 100;

  @override
  void initState() {
    super.initState();
    _loadWeeklyData();
  }

  Future<void> _loadWeeklyData() async {
    final healthService = HealthService();
    final now = DateTime.now();
    final startTime = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6));
    final endTime = DateTime(now.year, now.month, now.day, 23, 59, 59);

    Map<DateTime, int> stepsByDay = {};

    try {
      final permsGranted = await healthService.requestPermissions();
      if (permsGranted) {
        stepsByDay = await healthService.fetchHistoryData(startTime, endTime);
      }
    } catch (e) {
      debugPrint('Error fetching history from HealthService: $e');
    }

    try {
      final todaySteps = await FallbackPedometerService().stepStream.first;
      final normalizedToday = DateTime(now.year, now.month, now.day);
      if (todaySteps > (stepsByDay[normalizedToday] ?? 0)) {
        stepsByDay[normalizedToday] = todaySteps;
      }
    } catch (e) {
      debugPrint('Could not fetch real-time today steps: $e');
    }

    List<FlSpot> spots = [];
    double maxVal = 0;

    for (int i = 0; i < 7; i++) {
      final day = startTime.add(Duration(days: i));
      final steps = stepsByDay[day] ?? 0;

      double val = 0;
      if (widget.type == ActivityType.calories) {
        val = steps * 0.04;
      } else {
        val = (steps / 100).floor().toDouble();
      }

      if (val > maxVal) {
        maxVal = val;
      }
      spots.add(FlSpot(i.toDouble(), val));
    }

    // Default max values if data is 0 to keep the chart clean
    double computedMaxY = maxVal * 1.2;
    if (widget.type == ActivityType.calories && computedMaxY < 500) {
      computedMaxY = 500;
    } else if (widget.type == ActivityType.activeTime && computedMaxY < 60) {
      computedMaxY = 60;
    }

    if (mounted) {
      setState(() {
        _chartData = spots;
        _maxY = computedMaxY;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final String unit = widget.type == ActivityType.calories ? 'kcal' : 'min';
    final Color mintColor = const Color(0xFFA7D8DE);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(24),
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
                      child: Column(
                        children: [
                          Text(
                            '오늘의 기록',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                widget.currentValue,
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                unit,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Chart Title
                    Text(
                      '최근 7일 ${widget.title}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Chart Card
                    Container(
                      height: 250,
                      padding: const EdgeInsets.all(20),
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
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: _maxY / 4,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.withValues(alpha: 0.1),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 22,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  switch (value.toInt()) {
                                    case 0:
                                      return const Text('D-6');
                                    case 3:
                                      return const Text('D-3');
                                    case 6:
                                      return const Text('오늘');
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: _maxY / 4 > 0
                                    ? _maxY / 4
                                    : 1, // Prevent interval 0
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  if (value == 0 || value == _maxY)
                                    return const Text('');
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: 6,
                          minY: 0,
                          maxY: _maxY,
                          lineBarsData: [
                            LineChartBarData(
                              spots: _chartData,
                              isCurved: true,
                              curveSmoothness: 0.35,
                              color: mintColor,
                              barWidth: 4,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    mintColor.withValues(alpha: 0.4),
                                    mintColor.withValues(alpha: 0.0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
