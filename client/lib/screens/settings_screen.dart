import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import 'timer_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 슬라이더용 더블 값
  double _focusMinutes = 45.0;
  double _breakMinutes = 5.0;
  int _sets = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // 타이틀
              const Text(
                'Focusette',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '집중 시간을 설정하고 나무를 키워보세요',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),

              const SizedBox(height: 40),

              // 설정 + 타임라인
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 집중 시간 슬라이더
                      _buildSliderCard(
                        icon: Icons.timer,
                        iconColor: Colors.orange,
                        title: '집중 시간',
                        subtitle: '한 세트당 집중할 시간',
                        value: _focusMinutes,
                        min: 5,
                        max: 90,
                        divisions: 12, // 5분 단위
                        unit: '분',
                        onChanged: (value) {
                          setState(() => _focusMinutes = value);
                        },
                      ),

                      const SizedBox(height: 20),

                      // 휴식 시간 슬라이더
                      _buildSliderCard(
                        icon: Icons.free_breakfast,
                        iconColor: Colors.green,
                        title: '휴식 시간',
                        subtitle: '각 세트 후 쉬는 시간',
                        value: _breakMinutes,
                        min: 3,
                        max: 15,
                        divisions: 12,
                        unit: '분',
                        onChanged: (value) {
                          setState(() => _breakMinutes = value);
                        },
                      ),

                      const SizedBox(height: 20),

                      // 세트 수 (+ - 버튼)
                      _buildSetsCard(),

                      const SizedBox(height: 32),

                      // 타임라인 시각화
                      _buildTimeline(),

                      const SizedBox(height: 32),

                      // 예상 시간 표시
                      _buildTotalTimeInfo(),
                    ],
                  ),
                ),
              ),

              // 시작 버튼
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _startSession,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('시작하기 🚀'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String unit,
    required Function(double) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              // 큰 숫자 표시
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${value.round()}$unit',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 슬라이더
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: iconColor,
              inactiveTrackColor: iconColor.withOpacity(0.2),
              thumbColor: iconColor,
              overlayColor: iconColor.withOpacity(0.2),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),

          // 최소/최대값 표시
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${min.round()}$unit',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                Text(
                  '${max.round()}$unit',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.repeat, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '세트 수',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  '총 반복할 횟수',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // - 버튼
          IconButton(
            onPressed: _sets > 1
                ? () {
                    setState(() => _sets--);
                  }
                : null,
            icon: const Icon(Icons.remove_circle_outline),
            iconSize: 32,
            color: Colors.blue,
            disabledColor: Colors.grey[300],
          ),

          // 숫자 표시
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$_sets',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),

          // + 버튼
          IconButton(
            onPressed: _sets < 10
                ? () {
                    setState(() => _sets++);
                  }
                : null,
            icon: const Icon(Icons.add_circle_outline),
            iconSize: 32,
            color: Colors.blue,
            disabledColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final now = DateTime.now();

    // 현재 시각의 정각 (시작점)
    final startHour = DateTime(now.year, now.month, now.day, now.hour);

    // 전체 세션 리스트 만들기
    DateTime currentTime = now;
    final sessions = <Map<String, dynamic>>[];

    for (int i = 0; i < _sets; i++) {
      // 집중 시간
      sessions.add({
        'type': 'focus',
        'index': i + 1,
        'start': currentTime,
        'end': currentTime.add(Duration(minutes: _focusMinutes.round())),
        'duration': _focusMinutes.round(),
      });
      currentTime = currentTime.add(Duration(minutes: _focusMinutes.round()));

      // 휴식 (마지막 세트 제외)
      if (i < _sets - 1) {
        sessions.add({
          'type': 'break',
          'index': i + 1,
          'start': currentTime,
          'end': currentTime.add(Duration(minutes: _breakMinutes.round())),
          'duration': _breakMinutes.round(),
        });
        currentTime = currentTime.add(Duration(minutes: _breakMinutes.round()));
      }
    }

    final endTime = currentTime;

    // 몇 시간 라인이 필요한지 계산
    final endHour = DateTime(
      endTime.year,
      endTime.month,
      endTime.day,
      endTime.hour,
    );
    final hoursDiff = endHour.difference(startHour).inHours + 2; // 여유있게 +2

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple[50]!, Colors.blue[50]!],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: Colors.purple[700]),
              const SizedBox(width: 8),
              Text(
                '타임라인',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[700],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '현재 ${_formatHourMinute(now)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 시간표 그리기
          ...List.generate(hoursDiff, (hourIndex) {
            final hourTime = startHour.add(Duration(hours: hourIndex));
            return _buildHourLine(hourTime, sessions, now, endTime);
          }),

          // 종료 표시
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const SizedBox(width: 60),
                Icon(Icons.flag, size: 16, color: Colors.purple[700]),
                const SizedBox(width: 4),
                Text(
                  '종료: ${_formatHourMinute(endTime)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourLine(
    DateTime hourTime,
    List<Map<String, dynamic>> sessions,
    DateTime now,
    DateTime endTime,
  ) {
    final nextHour = hourTime.add(const Duration(hours: 1));
    final hourInMinutes = 60.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        children: [
          // 시간 라벨
          Row(
            children: [
              SizedBox(
                width: 55,
                child: Text(
                  '${hourTime.hour}:00',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Expanded(child: Container(height: 1, color: Colors.grey[300])),
            ],
          ),
          const SizedBox(height: 4),

          // 이 시간대의 세션들
          Row(
            children: [
              const SizedBox(width: 60),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: Stack(
                    children: [
                      // 현재 시간 표시 (이 시간대에 포함되면)
                      if (now.isAfter(hourTime) && now.isBefore(nextHour))
                        _buildCurrentTimeMarker(now, hourTime, hourInMinutes),

                      // 각 세션 블록
                      ...sessions.map((session) {
                        final sessionStart = session['start'] as DateTime;
                        final sessionEnd = session['end'] as DateTime;

                        // 이 시간대와 겹치는지 확인
                        if (sessionEnd.isAfter(hourTime) &&
                            sessionStart.isBefore(nextHour)) {
                          return _buildSessionBlock(
                            session,
                            hourTime,
                            nextHour,
                            hourInMinutes,
                          );
                        }
                        return const SizedBox.shrink();
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTimeMarker(
    DateTime now,
    DateTime hourTime,
    double hourInMinutes,
  ) {
    final minutesFromHour = now.difference(hourTime).inMinutes;
    final position = minutesFromHour / hourInMinutes;

    return Positioned(
      left: 0,
      right: 0,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: position,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: Colors.red, width: 2)),
          ),
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${now.hour}:${now.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionBlock(
    Map<String, dynamic> session,
    DateTime hourStart,
    DateTime hourEnd,
    double hourInMinutes,
  ) {
    final sessionStart = session['start'] as DateTime;
    final sessionEnd = session['end'] as DateTime;
    final isFocus = session['type'] == 'focus';

    // 이 시간대에서 실제로 보여줄 시작/끝 시간
    final visibleStart = sessionStart.isBefore(hourStart)
        ? hourStart
        : sessionStart;
    final visibleEnd = sessionEnd.isAfter(hourEnd) ? hourEnd : sessionEnd;

    // 위치와 길이 계산
    final startOffset =
        visibleStart.difference(hourStart).inMinutes / hourInMinutes;
    final duration =
        visibleEnd.difference(visibleStart).inMinutes / hourInMinutes;

    // 음수 방지 및 범위 체크
    if (duration <= 0 || startOffset < 0 || startOffset >= 1) {
      return const SizedBox.shrink();
    }

    final totalWidth = (startOffset + duration).clamp(0.0, 1.0);
    final widthFactor = (duration / totalWidth).clamp(0.0, 1.0);

    final color = isFocus ? Colors.orange : Colors.green;
    final label = isFocus ? '집중${session['index']}' : '휴식';

    return Positioned(
      left: 0,
      right: 0,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: totalWidth,
        child: Align(
          alignment: Alignment.centerRight,
          child: FractionallySizedBox(
            widthFactor: widthFactor,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.7), color.withOpacity(0.5)],
                ),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: color, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color.withOpacity(0.9),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$period $displayHour:$minute';
  }

  String _formatHourMinute(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildTotalTimeInfo() {
    final totalMinutes = (_focusMinutes * _sets + _breakMinutes * (_sets - 1))
        .round();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    String timeText;
    if (hours > 0) {
      timeText = minutes > 0 ? '$hours시간 $minutes분' : '$hours시간';
    } else {
      timeText = '$minutes분';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[600]!],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.access_time, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '예상 총 시간',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeText,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Text('🍅 × $_sets', style: const TextStyle(fontSize: 32)),
        ],
      ),
    );
  }

  void _startSession() {
    final timerProvider = context.read<TimerProvider>();

    // 설정값 전달
    timerProvider.configure(
      focusMinutes: _focusMinutes.round(),
      breakMinutes: _breakMinutes.round(),
      totalSets: _sets,
    );

    // 타이머 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TimerScreen()),
    );
  }
}
