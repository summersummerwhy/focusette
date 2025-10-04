import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Forest 🌳'),
        centerTitle: true,
        actions: [
          // 세션 종료 버튼
          IconButton(
            onPressed: () {
              _showEndSessionDialog(context);
            },
            icon: const Icon(Icons.close),
            tooltip: '세션 종료',
          ),
        ],
      ),
      body: Consumer<TimerProvider>(
        builder: (context, timerProvider, child) {
          // 모든 세트 완료 확인
          if (timerProvider.isAllSetsCompleted &&
              timerProvider.status == TimerStatus.initial) {
            return _buildCompletionScreen(context, timerProvider);
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 세트 진행 상황
                _buildSetProgress(timerProvider),
                const SizedBox(height: 20),

                // 상태 표시
                _buildStatusChip(timerProvider.status),
                const SizedBox(height: 40),

                // 타이머 디스플레이
                _buildTimerDisplay(timerProvider),
                const SizedBox(height: 20),

                // 진행률 바
                _buildProgressBar(timerProvider),
                const SizedBox(height: 60),

                // 컨트롤 버튼들
                _buildControls(context, timerProvider),
                const SizedBox(height: 40),

                // 완료한 뽀모도로 개수
                _buildStats(timerProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSetProgress(TimerProvider timerProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.loop, size: 20),
          const SizedBox(width: 8),
          Text(
            '${timerProvider.currentSet} / ${timerProvider.totalSets} 세트',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(TimerStatus status) {
    String text;
    Color color;

    switch (status) {
      case TimerStatus.initial:
        text = '준비';
        color = Colors.grey;
        break;
      case TimerStatus.running:
        text = '집중 중 🔥';
        color = Colors.orange;
        break;
      case TimerStatus.paused:
        text = '일시정지';
        color = Colors.blue;
        break;
      case TimerStatus.break_time:
        text = '휴식 시간 ☕';
        color = Colors.green;
        break;
      case TimerStatus.completed:
        text = '완료! 🎉';
        color = Colors.purple;
        break;
    }

    return Chip(
      label: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      backgroundColor: color.withOpacity(0.2),
      side: BorderSide(color: color),
    );
  }

  Widget _buildTimerDisplay(TimerProvider timerProvider) {
    return Text(
      timerProvider.formattedTime,
      style: const TextStyle(
        fontSize: 80,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildProgressBar(TimerProvider timerProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          // 현재 세트 진행률
          LinearProgressIndicator(
            value: timerProvider.progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            '${(timerProvider.progress * 100).toInt()}%',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),

          // 전체 진행률
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '전체 진행률',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    '${timerProvider.completedPomodoros}/${timerProvider.totalSets}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: timerProvider.totalProgress,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
                backgroundColor: Colors.grey[200],
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context, TimerProvider timerProvider) {
    if (timerProvider.status == TimerStatus.completed) {
      return Column(
        children: [
          ElevatedButton.icon(
            onPressed: () => timerProvider.startBreak(),
            icon: const Icon(Icons.free_breakfast),
            label: const Text('휴식 시작'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => timerProvider.skipBreak(),
            child: const Text('휴식 건너뛰기'),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 리셋 버튼
        if (timerProvider.status != TimerStatus.initial)
          IconButton(
            onPressed: () => timerProvider.resetTimer(),
            icon: const Icon(Icons.refresh),
            iconSize: 32,
            tooltip: '리셋',
          ),

        const SizedBox(width: 20),

        // 메인 버튼 (시작/일시정지/재개)
        _buildMainButton(timerProvider),

        const SizedBox(width: 20),

        // 공간 맞추기용
        if (timerProvider.status != TimerStatus.initial)
          const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildMainButton(TimerProvider timerProvider) {
    IconData icon;
    VoidCallback onPressed;
    Color color;

    switch (timerProvider.status) {
      case TimerStatus.initial:
        icon = Icons.play_arrow;
        onPressed = () => timerProvider.startTimer();
        color = Colors.green;
        break;
      case TimerStatus.running:
      case TimerStatus.break_time:
        icon = Icons.pause;
        onPressed = () => timerProvider.pauseTimer();
        color = Colors.orange;
        break;
      case TimerStatus.paused:
        icon = Icons.play_arrow;
        onPressed = () => timerProvider.resumeTimer();
        color = Colors.blue;
        break;
      default:
        icon = Icons.play_arrow;
        onPressed = () => timerProvider.startTimer();
        color = Colors.grey;
    }

    return FloatingActionButton.large(
      onPressed: onPressed,
      backgroundColor: color,
      child: Icon(icon, size: 48),
    );
  }

  Widget _buildStats(TimerProvider timerProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            '완료한 뽀모도로',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🍅', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                '${timerProvider.completedPomodoros}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen(
    BuildContext context,
    TimerProvider timerProvider,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 24),
            const Text(
              '모든 세트 완료!',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              '${timerProvider.totalSets}개의 뽀모도로를 완료했습니다',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 60),

            // 통계
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        '🍅',
                        '뽀모도로',
                        '${timerProvider.totalSets}개',
                      ),
                      _buildStatItem(
                        '⏱️',
                        '총 시간',
                        '${timerProvider.totalSets * 25}분',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            FilledButton(
              onPressed: () {
                timerProvider.endSession();
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
              ),
              child: const Text('새로운 세션 시작'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 40)),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _showEndSessionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('세션 종료'),
          content: const Text('정말로 현재 세션을 종료하시겠습니까?\n진행 상황이 저장되지 않습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () {
                context.read<TimerProvider>().endSession();
                Navigator.pop(dialogContext); // 다이얼로그 닫기
                Navigator.pop(context); // 타이머 화면 닫기
              },
              child: const Text('종료'),
            ),
          ],
        );
      },
    );
  }
}
