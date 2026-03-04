import 'package:flutter/services.dart';

import 'analytics_service.dart';

/// Phase A: 触覚統一
/// 主要アクションのハプティクスを共通ルールで制御し、品質と計測を統一する。
/// - 端末非対応・例外時は no-op（UX阻害防止）
/// - 連打時はレート制御で過剰発火を抑制
class FeedbackService {
  FeedbackService(this._analytics);

  final AnalyticsService? _analytics;

  /// レート制御: 同一キーでこの間隔以内の連打は間引く（ms）
  static const int _rateLimitMs = 100;

  final Map<String, DateTime> _lastFiredAt = {};

  bool _shouldThrottle(String key) {
    final now = DateTime.now();
    final last = _lastFiredAt[key];
    if (last == null) return false;
    if (now.difference(last).inMilliseconds < _rateLimitMs) return true;
    return false;
  }

  void _markFired(String key) {
    _lastFiredAt[key] = DateTime.now();
  }

  void _tryHaptic(void Function() fn, String key, String? trigger) {
    if (_shouldThrottle(key)) return;
    try {
      fn();
      _markFired(key);
      _analytics?.logHapticFired(trigger: trigger ?? key);
    } catch (_) {
      // 非対応端末・例外時は no-op
    }
  }

  /// 軽い選択操作（リスト選択、タブ切替、CTA押下など）
  void selection({String? trigger}) {
    _tryHaptic(HapticFeedback.selectionClick, trigger ?? 'selection', trigger);
  }

  /// 中程度の成功（再生開始、1ステップ完了など）
  void light({String? trigger}) {
    _tryHaptic(HapticFeedback.lightImpact, trigger ?? 'light', trigger);
  }

  /// 重い成功（セッション完了、学習完了など）
  void medium({String? trigger}) {
    _tryHaptic(HapticFeedback.mediumImpact, trigger ?? 'medium', trigger);
  }

  /// エラー・失敗通知（原則 light 以下に抑制）
  void error({String? trigger}) {
    _tryHaptic(HapticFeedback.lightImpact, trigger ?? 'error', trigger);
  }
}
