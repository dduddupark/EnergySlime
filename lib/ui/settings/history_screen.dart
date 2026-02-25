import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../data/services/health_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:stepflow/l10n/app_localizations.dart';
import '../../data/services/fallback_pedometer_service.dart';
import 'dart:math';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HealthService _healthService = HealthService();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, int> _stepsByDay = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko_KR', null).then((_) {
      _loadHistory();
    });
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    final now = DateTime.now();
    // Fetch last 3 months to be safe
    final startTime = DateTime(now.year, now.month - 2, 1);
    final endTime = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final permsGranted = await _healthService.requestPermissions();
    if (permsGranted) {
      final data = await _healthService.fetchHistoryData(startTime, endTime);
      if (mounted) {
        setState(() {
          _stepsByDay = data;
        });
      }
    }

    if (mounted) {
      setState(() {
        // -- 목업 데이터 삽입 (1월 1일 ~ 2월 23일까지 1~10000 랜덤) --
        final random = Random();
        final year = now.year;
        DateTime fakeDate = DateTime(year, 1, 1);
        final endDate = DateTime(year, now.month, now.day).subtract(const Duration(days: 1));
        
        while (!fakeDate.isAfter(endDate)) {
          if (!_stepsByDay.containsKey(fakeDate)) {
             _stepsByDay[fakeDate] = random.nextInt(10000) + 1; // 1 ~ 10000 보
          }
          fakeDate = fakeDate.add(const Duration(days: 1));
        }

        _isLoading = false;
      });
      
      try {
        final todaySteps = await FallbackPedometerService().stepStream.first;
        if (mounted) {
          setState(() {
            final now = DateTime.now();
            final normalizedToday = DateTime(now.year, now.month, now.day);
            _stepsByDay[normalizedToday] = todaySteps;
          });
        }
      } catch (e) {
        print('Could not fetch real-time today steps: $e');
      }
    }
  }

  Widget _buildSlimeIndicator(int steps) {
    const int dailyGoal = 10000;
    final progress = (steps / dailyGoal).clamp(0.0, 1.0);

    return Container(
      width: 30,
      height: 30,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFEBF4F5),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.elliptical(14, 20),
          topRight: Radius.elliptical(14, 20),
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          FractionallySizedBox(
            heightFactor: progress,
            child: Container(
              color: const Color(0xFFA7D8DE),
              width: double.infinity,
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFF1E293B), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFF1E293B), shape: BoxShape.circle)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localeStr = Localizations.localeOf(context).languageCode == 'ko' ? 'ko_KR' : 'en_US';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.checkHistory, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(28.0),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: TableCalendar(
                      locale: localeStr,
                      firstDay: DateTime.utc(2023, 1, 1),
                      lastDay: DateTime.utc(DateTime.now().year + 1, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      rowHeight: 80, // 슬라임과 겹치기 때문에 높이 축소
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      daysOfWeekHeight: 30, // 요일 헤더가 잘리지 않도록 높이 명시
                      calendarStyle: CalendarStyle(
                    defaultTextStyle: TextStyle(color: colorScheme.onSurface),
                    weekendTextStyle: const TextStyle(color: Colors.redAccent),
                    outsideTextStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.3)),
                    todayDecoration: const BoxDecoration(), // 오늘 날짜 기본 동그라미 제거
                  ),
                  headerStyle: HeaderStyle(
                    titleTextStyle: TextStyle(color: colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
                    formatButtonVisible: false,
                    titleCentered: true,
                    leftChevronIcon: Icon(Icons.chevron_left, color: colorScheme.onSurface),
                    rightChevronIcon: Icon(Icons.chevron_right, color: colorScheme.onSurface),
                  ),
                  calendarBuilders: CalendarBuilders(
                    dowBuilder: (context, day) {
                      final text = DateFormat.E(localeStr).format(day);
                      return Center(
                        child: Text(
                          text,
                          style: TextStyle(
                            color: day.weekday == DateTime.sunday 
                              ? Colors.redAccent 
                              : day.weekday == DateTime.saturday 
                                ? Colors.blueAccent 
                                : colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      );
                    },
                    defaultBuilder: (context, day, focusedDay) {
                      final isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
                      return _buildCalendarCell(day, colorScheme, isWeekend: isWeekend);
                    },
                    outsideBuilder: (context, day, focusedDay) {
                      final isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
                      return _buildCalendarCell(day, colorScheme, isOutside: true, isWeekend: isWeekend);
                    },
                      todayBuilder: (context, day, focusedDay) {
                        final isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
                        return _buildCalendarCell(day, colorScheme, isToday: true, isWeekend: isWeekend);
                      },
                    ),
                  ), // Close TableCalendar
                  ), // Close Container
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(AppLocalizations.of(context)!.goalFullText, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(AppLocalizations.of(context)!.kcalInfoText, style: const TextStyle(color: Colors.orangeAccent, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCalendarCell(DateTime day, ColorScheme colorScheme, {bool isToday = false, bool isWeekend = false, bool isOutside = false}) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final steps = _stepsByDay[normalizedDay] ?? 0;

    Color textColor = colorScheme.onSurface;
    if (isOutside) {
      textColor = colorScheme.onSurface.withOpacity(0.3);
    } else if (day.weekday == DateTime.sunday) {
      textColor = isOutside ? Colors.redAccent.withOpacity(0.3) : Colors.redAccent;
    } else if (day.weekday == DateTime.saturday) {
      textColor = isOutside ? Colors.blueAccent.withOpacity(0.3) : Colors.blueAccent;
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // 뒤에 깔리는 슬라임
              if (steps > 0 || isToday)
                _buildSlimeIndicator(steps)
              else
                const SizedBox(width: 30, height: 30),
                
              // 앞에 표기되는 날짜 숫자
              if (isToday)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.9), // 슬라임 위에서 잘 보이도록
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${day.day}', 
                    style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
                  ),
                )
              else
                Text(
                  '${day.day}', 
                  style: TextStyle(
                    color: textColor, 
                    fontWeight: FontWeight.bold,
                    shadows: [
                      // 슬라임과 겹쳤을 때 글자가 잘 보이도록 외곽선 효과
                      Shadow(color: colorScheme.surface, blurRadius: 6),
                      Shadow(color: colorScheme.surface, blurRadius: 6),
                    ]
                  )
                ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          if (steps > 0 || isToday)
            Text(
              '${(steps * 0.04).toInt()}',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.orangeAccent,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            const SizedBox(height: 14), // 공간 유지
        ],
      ),
    );
  }
}
