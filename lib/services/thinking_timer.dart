import 'dart:async';
import '../models/hint_phase.dart';
import '../models/hint_settings.dart';

class ThinkingTimer {
  Timer? _timer;
  final Function(HintPhase) onHintPhaseChange;
  final HintSettings settings;
  
  int _currentPhaseIndex = 0;
  DateTime? _startTime;
  bool _isRunning = false;
  
  // ヒント段階の順序
  final List<HintPhase> _hintPhases = [
    HintPhase.initial,
    HintPhase.extended,
    HintPhase.keywords,
  ];

  ThinkingTimer({
    required this.onHintPhaseChange,
    required this.settings,
  });

  /// タイマーを開始
  void start() {
    if (_isRunning) return;
    
    _isRunning = true;
    _currentPhaseIndex = 0;
    _startTime = DateTime.now();
    
    // 有効なヒント段階のみをフィルタリング
    final enabledPhases = _hintPhases.where((phase) {
      return settings.hintPhasesEnabled.contains(phase.value);
    }).toList();
    
    if (enabledPhases.isEmpty) return;
    
    _scheduleNextHint(enabledPhases);
  }

  /// 次のヒントをスケジュール
  void _scheduleNextHint(List<HintPhase> enabledPhases) {
    if (_currentPhaseIndex >= enabledPhases.length) return;
    
    final currentPhase = enabledPhases[_currentPhaseIndex];
    int delaySeconds;
    
    // 最初のヒントまでの遅延
    if (_currentPhaseIndex == 0) {
      delaySeconds = settings.initialHintDelaySeconds;
    } else {
      // 前のヒントからの相対遅延
      final previousPhase = enabledPhases[_currentPhaseIndex - 1];
      final previousDelay = _getDelayForPhase(previousPhase);
      final currentDelay = _getDelayForPhase(currentPhase);
      delaySeconds = currentDelay - previousDelay;
    }
    
    _timer = Timer(Duration(seconds: delaySeconds), () {
      onHintPhaseChange(currentPhase);
      _currentPhaseIndex++;
      _scheduleNextHint(enabledPhases);
    });
  }

  /// 段階に応じた遅延秒数を取得
  int _getDelayForPhase(HintPhase phase) {
    switch (phase) {
      case HintPhase.initial:
        return settings.initialHintDelaySeconds;
      case HintPhase.extended:
        return settings.extendedHintDelaySeconds;
      case HintPhase.keywords:
        return settings.keywordsHintDelaySeconds;
      default:
        return 0;
    }
  }

  /// タイマーをリセット
  void reset() {
    _timer?.cancel();
    _timer = null;
    _currentPhaseIndex = 0;
    _isRunning = false;
    _startTime = null;
  }

  /// タイマーを停止
  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  /// 現在の思考時間を取得（秒）
  int get thinkingTimeSeconds {
    if (_startTime == null) return 0;
    return DateTime.now().difference(_startTime!).inSeconds;
  }

  /// タイマーが実行中かどうか
  bool get isRunning => _isRunning;

  /// リソースを解放
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
