import 'dart:async';
import 'package:flutter/foundation.dart';

enum TimerStatus { initial, running, paused, break_time, completed }

class TimerProvider extends ChangeNotifier {
  // 사용자 설정값 (기본값)
  int _focusDuration = 25 * 60;
  int _breakDuration = 5 * 60;
  int _totalSets = 4;

  // 타이머 상태
  TimerStatus _status = TimerStatus.initial;
  int _remainingSeconds = 25 * 60;
  int _currentSet = 1;
  int _completedPomodoros = 0;
  Timer? _timer;

  // Getters
  TimerStatus get status => _status;
  int get remainingSeconds => _remainingSeconds;
  int get completedPomodoros => _completedPomodoros;
  int get currentSet => _currentSet;
  int get totalSets => _totalSets;

  // 포맷팅된 시간 (MM:SS)
  String get formattedTime {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // 진행률 (0.0 ~ 1.0)
  double get progress {
    if (_status == TimerStatus.break_time) {
      return 1.0 - (_remainingSeconds / _breakDuration);
    }
    return 1.0 - (_remainingSeconds / _focusDuration);
  }

  // 전체 진행률 (모든 세트 기준)
  double get totalProgress {
    return (_completedPomodoros / _totalSets).clamp(0.0, 1.0);
  }

  // 설정값 업데이트
  void configure({
    required int focusMinutes,
    required int breakMinutes,
    required int totalSets,
  }) {
    _focusDuration = focusMinutes * 60;
    _breakDuration = breakMinutes * 60;
    _totalSets = totalSets;
    _remainingSeconds = _focusDuration;
    _currentSet = 1;
    _completedPomodoros = 0;
    _status = TimerStatus.initial;
    notifyListeners();
  }

  // 타이머 시작
  void startTimer() {
    if (_status == TimerStatus.initial) {
      _remainingSeconds = _focusDuration;
    }

    _status = TimerStatus.running;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _onTimerComplete();
      }
    });
    notifyListeners();
  }

  // 타이머 일시정지
  void pauseTimer() {
    if (_status == TimerStatus.running || _status == TimerStatus.break_time) {
      _timer?.cancel();
      _status = TimerStatus.paused;
      notifyListeners();
    }
  }

  // 타이머 재개
  void resumeTimer() {
    if (_status == TimerStatus.paused) {
      startTimer();
    }
  }

  // 타이머 리셋
  void resetTimer() {
    _timer?.cancel();
    _status = TimerStatus.initial;
    _remainingSeconds = _focusDuration;
    notifyListeners();
  }

  // 세션 완전 종료
  void endSession() {
    _timer?.cancel();
    _status = TimerStatus.initial;
    _remainingSeconds = _focusDuration;
    _currentSet = 1;
    _completedPomodoros = 0;
    notifyListeners();
  }

  // 타이머 완료 처리
  void _onTimerComplete() {
    _timer?.cancel();

    if (_status == TimerStatus.running) {
      // 집중 시간 완료
      _completedPomodoros++;
      _status = TimerStatus.completed;
      _remainingSeconds = 0;
      notifyListeners();

      print('🎉 뽀모도로 $_currentSet/$_totalSets 완료!');
    } else if (_status == TimerStatus.break_time) {
      // 휴식 시간 완료
      _currentSet++;

      if (_currentSet > _totalSets) {
        // 모든 세트 완료!
        print('🏆 모든 세트 완료! 수고하셨습니다!');
      } else {
        // 다음 세트 준비
        _status = TimerStatus.initial;
        _remainingSeconds = _focusDuration;
        notifyListeners();
        print('✨ 휴식 완료! 다음 세트 준비됨 ($_currentSet/$_totalSets)');
      }
    }
  }

  // 휴식 시작
  void startBreak() {
    _timer?.cancel();
    _status = TimerStatus.break_time;
    _remainingSeconds = _breakDuration;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _onTimerComplete();
      }
    });
    notifyListeners();
  }

  // 휴식 건너뛰기
  void skipBreak() {
    _timer?.cancel();
    _currentSet++;

    if (_currentSet > _totalSets) {
      // 모든 세트 완료
      _status = TimerStatus.initial;
    } else {
      _status = TimerStatus.initial;
      _remainingSeconds = _focusDuration;
    }
    notifyListeners();
  }

  // 모든 세트 완료 여부
  bool get isAllSetsCompleted => _completedPomodoros >= _totalSets;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
