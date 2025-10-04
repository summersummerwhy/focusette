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
  // 기본값
  int _focusMinutes = 25;
  int _breakMinutes = 5;
  int _sets = 4;

  // 선택 가능한 옵션들
  final List<int> _focusOptions = [15, 25, 45, 60];
  final List<int> _breakOptions = [5, 10, 15, 20];
  final List<int> _setsOptions = List.generate(10, (i) => i + 1); // 1~10

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
                'Focus Forest 🌳',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '집중 시간을 설정하고 나무를 키워보세요',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),

              const SizedBox(height: 60),

              // 설정 카드들
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildSettingCard(
                        icon: Icons.timer,
                        title: '집중 시간',
                        subtitle: '한 세트당 집중할 시간',
                        value: _focusMinutes,
                        unit: '분',
                        options: _focusOptions,
                        onChanged: (value) {
                          setState(() => _focusMinutes = value);
                        },
                      ),

                      const SizedBox(height: 20),

                      _buildSettingCard(
                        icon: Icons.free_breakfast,
                        title: '휴식 시간',
                        subtitle: '각 세트 후 쉬는 시간',
                        value: _breakMinutes,
                        unit: '분',
                        options: _breakOptions,
                        onChanged: (value) {
                          setState(() => _breakMinutes = value);
                        },
                      ),

                      const SizedBox(height: 20),

                      _buildSettingCard(
                        icon: Icons.repeat,
                        title: '세트 수',
                        subtitle: '총 반복할 횟수',
                        value: _sets,
                        unit: '세트',
                        options: _setsOptions,
                        onChanged: (value) {
                          setState(() => _sets = value);
                        },
                      ),

                      const SizedBox(height: 40),

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
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: const TextStyle(fontSize: 18),
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

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required int value,
    required String unit,
    required List<int> options,
    required Function(int) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.green[700]),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 선택 버튼들
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = option == value;
              return ChoiceChip(
                label: Text('$option$unit'),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) onChanged(option);
                },
                selectedColor: Colors.green[100],
                checkmarkColor: Colors.green[700],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalTimeInfo() {
    final totalMinutes =
        (_focusMinutes + _breakMinutes) * _sets - _breakMinutes;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    String timeText;
    if (hours > 0) {
      timeText = minutes > 0 ? '$hours시간 $minutes분' : '$hours시간';
    } else {
      timeText = '$minutes분';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, color: Colors.green[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '예상 총 시간',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                Text(
                  timeText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
          Text('🍅 × $_sets', style: const TextStyle(fontSize: 24)),
        ],
      ),
    );
  }

  void _startSession() {
    final timerProvider = context.read<TimerProvider>();

    // 설정값 전달
    timerProvider.configure(
      focusMinutes: _focusMinutes,
      breakMinutes: _breakMinutes,
      totalSets: _sets,
    );

    // 타이머 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TimerScreen()),
    );
  }
}
